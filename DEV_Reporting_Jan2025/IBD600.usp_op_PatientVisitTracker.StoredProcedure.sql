USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_PatientVisitTracker]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/27/2020
-- V2.0 Create Date: 11/23/2022
-- Description:	Procedure to create table for Patient Visit Tracker for page 1 of new Visit Planning SMR Report
-- ===================================================================================================
			  --EXECUTE
CREATE PROCEDURE [IBD600].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_op_PatientVisitTracker]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar] (75) NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[YOB] [int] NULL,
	[EnrollingProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[LastFollowUpProviderID] [int] NULL,
	[LastVisitDate] [date] NULL,
	[VisitType] [nvarchar] (30) NULL,
	[MonthsSinceLastVisit] [float] NULL,
	[VisitStatus] [nvarchar] (15) NULL,
	[EarliestEligNextFU] [date] NULL,
	[TargetNextFUVisitDate] [date] NULL

);
*/


TRUNCATE TABLE [Reporting].[IBD600].[t_op_PatientVisitTracker];

IF OBJECT_ID('temp.dbo.#EXITS') IS NOT NULL BEGIN DROP TABLE #EXITS END

--SELECT * FROM #VISITPLANNER

SELECT EXITS.VID
      ,EXITS.SITENUM AS SiteID
	  ,EXITS.SUBNUM AS SubjectID
	  ,EXITS.DISCONTINUE_DT AS ExitDate
	  ,EXITS.VISNAME AS VisitType
INTO #EXITS 
FROM [MERGE_IBD].[staging].[EXIT] EXITS
WHERE DISCONTINUE_DT IS NOT NULL OR EXIT_REASON IS NOT NULL


IF OBJECT_ID('temp.dbo.#EnrollmentVisit') IS NOT NULL BEGIN DROP TABLE #EnrollmentVisit END

SELECT DISTINCT VIS.vID
      ,VIS.SITENUM AS SiteID
	  ,VIS.SUBNUM AS SubjectID
	  ,MD.MD_COD AS ProviderID
	  ,CAST(VIS.VISITDATE AS date) AS EnrollmentDate
	  ,VIS.VISNAME
INTO #EnrollmentVisit 

FROM [MERGE_IBD].[staging].[VISIT] VIS
LEFT JOIN [MERGE_IBD].[staging].[MD_DX] MD ON MD.vID=VIS.vID
WHERE VIS.VISNAME='Enrollment'

--SELECT * FROM #EnrollmentVisit

--39296 = Original
--38904 = Updated

IF OBJECT_ID('temp.dbo.#VisitList') IS NOT NULL BEGIN DROP TABLE #VisitList END

SELECT DISTINCT VIS.vID
	  ,VIS.SITENUM AS SiteID
      ,VIS.SUBNUM AS SubjectID
	  ,MD.MD_COD AS ProviderID
	  ,PTDEM.BIRTHDATE
	  ,VIS.VISNAME AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS  VisitDate
	  ,ROW_NUMBER() OVER (PARTITION BY VIS.SITENUM, VIS.SUBNUM ORDER BY VIS.SITENUM, VIS.SUBNUM, VIS.VISITDATE DESC) AS ROWNUM
INTO #VisitList
FROM [MERGE_IBD].[staging].[VISIT] VIS
LEFT JOIN [MERGE_IBD].[staging].[MD_DX] MD ON MD.vID=VIS.vID
LEFT JOIN [MERGE_IBD].[staging].[PT_DEMOG] PTDEM ON VIS.SUBNUM=PTDEM.SUBNUM
--LEFT JOIN [MERGE_IBD].[staging].[REIMB] RE ON RE.vID=VIS.vID
WHERE VIS.VISNAME IN ('Enrollment', 'Follow-up')
AND ISNULL(VIS.VISITDATE, '')<>''
AND VIS.[vID] NOT IN (SELECT vID FROM [MERGE_IBD].[staging].[REIMB] WHERE [OOW_FU_EXCEPTION_DEC] = 'No' OR [PAY_3_1100] = 'X')

--SELECT * FROM #VisitList


IF OBJECT_ID('temp.dbo.#LastEligVisit') IS NOT NULL BEGIN DROP TABLE #LastEligvisit END

SELECT ROWNUM
      ,VL.vID
      ,VL.SiteID
      ,VL.SubjectID
	  ,VL.ProviderID AS LastVisitProviderID
	  ,VL.Birthdate AS YearofBirth
	  ,EV.EnrollmentDate AS EnrollmentDate
	  ,EV.ProviderID AS EnrollmentProviderID
	  ,VL.VisitDate AS VisitDate
	  ,VL.VisitType

INTO #LastEligVisit
FROM #VisitList VL
LEFT JOIN #EnrollmentVisit EV on VL.SubjectID=EV.SubjectID

WHERE ROWNUM=1 AND ISNULL(VL.VisitDate, '')<>''


--SELECT * FROM #LastEligVisit WHERE VisitDate<>LastEligVisitDate order by SiteID, subjectid, rownum 


IF OBJECT_ID('temp.dbo.#SiteStatus') IS NOT NULL BEGIN DROP TABLE #SiteStatus END

SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
      ,CASE WHEN ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
	  ,RS.currentStatus AS SFSiteStatus
INTO #SiteStatus
FROM [MERGE_IBD].[dbo].[DAT_SITES] S
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=S.SITENUM AND RS.[name]='Inflammatory Bowel Disease (IBD-600)'

--SELECT * FROM #SiteStatus


IF OBJECT_ID('temp.dbo.#VisitPlanner') IS NOT NULL BEGIN DROP TABLE #VisitPlanner END

SELECT 
	   CAST(EL.SiteID AS int) AS [SiteID]
      ,SS.[SiteStatus]
	  ,SS.SFSiteStatus
      ,EL.SubjectID AS [SubjectID]
	  ,EL.YearofBirth AS [YOB]
	  ,EnrollmentProviderID AS [EnrollingProviderID]
	  ,CAST(EL.EnrollmentDate AS date) AS EnrollmentDate
	  ,LastVisitProviderID AS [LastFollowUpProviderID]
	  ,CAST(EL.VisitDate AS date) AS LastVisitDate
	  ,EL.VisitType AS VisitType
	  ,CAST(DATEDIFF(D, EL.VisitDate, GETDATE())/30.00 AS decimal(6,2)) AS [MonthsSinceLastVisit]
	  ,CAST(DATEADD(D, 150, EL.VisitDate) AS date) AS [EarliestEligNextFU]
	  ,CAST(DATEADD(D, 180, EL.VisitDate) AS date) AS [TargetNextFUVisitDate]
INTO #VisitPlanner
FROM #LastEligVisit EL
JOIN #SiteStatus SS ON SS.SiteID=EL.SiteID
WHERE ROWNUM=1
AND EL.SUBJECTID NOT IN (SELECT SUBJECTID FROM #EXITS)

--SELECT * FROM #VisitPlanner

INSERT INTO [Reporting].[IBD600].[t_op_PatientVisitTracker]
(
	[SiteID],
	[SiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[YOB],
	[EnrollingProviderID],
	[EnrollmentDate],
	[LastFollowUpProviderID],
	[LastVisitDate],
	[VisitType],
	[MonthsSinceLastVisit],
	[VisitStatus],
	[EarliestEligNextFU],
	[TargetNextFUVisitDate]
)

SELECT
       [SiteID]
      ,[SiteStatus]
	  ,[SFSiteStatus]
      ,[SubjectID]
	  ,[YOB]
	  ,[EnrollingProviderID]
	  ,EnrollmentDate
	  ,[LastFollowUpProviderID]
	  ,LastVisitDate
	  ,VisitType
	  ,[MonthsSinceLastVisit]
	  ,CASE WHEN MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN MonthsSinceLastVisit >=5 AND MonthsSinceLastVisit < 7 THEN 'Due Now'
	   WHEN MonthsSinceLastVisit >= 7 THEN 'Overdue'
	   ELSE ''
	   END AS VisitStatus
	  ,[EarliestEligNextFU]
	  ,[TargetNextFUVisitDate]

FROM #VisitPlanner VP

--SELECT * FROM [Reporting].[IBD600].[t_op_PatientVisitTracker]

END





GO
