USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_PatientVisitTracker]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



















-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 01/23/2020
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/27/2020
-- Description:	Procedure to create table for page 1 of Patient Visit Tracker Report
-- ===================================================================================================

CREATE PROCEDURE [MS700].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [MS700].[t_op_PatientVisitTracker]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar] (50) NULL,
	[SubjectID] [nvarchar] (25) NOT NULL,
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


TRUNCATE TABLE [Reporting].[MS700].[t_op_PatientVisitTracker];

IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 

SELECT S.SiteID
      ,E.subNum AS SubjectID
	  ,E.exit_date AS ExitDate
	  ,E.eventName AS VisitType
	  ,E.exit_reason_dec AS ExitReason
	  ,e.exit_reason_specify AS OtherExitReason

INTO #EXITS

FROM [RCC_MS700].[staging].[exitstatus] E
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON S.patientId=E.[subjectId] AND S.SiteID<>1440
WHERE S.SubjectStatus NOT IN ('Removed', 'Incomplete')
AND E.exit_date IS NOT NULL OR E.exit_reason_dec IS NOT NULL

--SELECT * FROM [RCC_MS700].[api].[subjects] ORDER BY studySiteName



IF OBJECT_ID('tempdb..#EnrollmentVisit') IS NOT NULL DROP TABLE dbo.#EnrollmentVisit

SELECT [SiteID]
      ,[SubjectID]
	  ,[PatientID]
      ,[VisitType]
      ,[VisitSequence]
	  ,[ProviderID] AS EnrollingProviderID
      ,[VisitDate] AS EnrollmentDate
	  ,EligibleVisit
INTO #EnrollmentVisit
FROM [MS700].[v_op_VisitLog]
WHERE VisitType='Enrollment'
AND EligibleVisit='Yes'

--SELECT * FROM #EnrollmentVisit


IF OBJECT_ID('tempdb..#VisitList') IS NOT NULL DROP TABLE #VisitList 

SELECT VL.SiteID
      ,VL.SubjectID
	  ,VL.patientId
	  ,VL.VisitType
	  ,VL.ProviderID AS LastFollowUpProviderID
	  ,VL.VisitDate
	  ,D.birthdate AS Birthdate
	  ,VL.EligibleVisit
	  ,ROW_NUMBER() OVER(PARTITION BY VL.SiteID, VL.SubjectID ORDER BY VL.VisitDate DESC) AS ROWNUM
INTO #VisitList
FROM [MS700].[v_op_VisitLog] VL
LEFT JOIN [RCC_MS700].[staging].[subjectdemography] D ON D.subjectId=VL.patientId AND D.eventId=VL.eventId AND D.eventOccurrence=VL.eventOccurrence
WHERE SiteID<>1440
AND ISNULL(VL.VisitDate, '')<>''
AND VL.eventId IN (3042, 3043)
AND EligibleVisit='Yes'
AND VL.SubjectID NOT IN (SELECT SubjectID FROM [MS700].[v_op_VisitLog] VL2 WHERE VL2.eventId=3042 AND VL2.EligibleVisit='No')

--SELECT * FROM #VisitList WHERE EligibleVisit='No' ORDER BY SiteID, SubjectID, ROWNUM


IF OBJECT_ID('tempdb..#LastEligVisit') IS NOT NULL DROP TABLE #LastEligvisit 

SELECT ROWNUM
      ,VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.Birthdate AS YearofBirth
	  ,EV.EnrollingProviderID
	  ,EV.EnrollmentDate AS EnrollmentDate
	  ,VL.LastFollowUpProviderID
	  ,VL.VisitDate AS VisitDate
	  ,VL.VisitType
INTO #LastEligVisit
FROM #VisitList VL
LEFT JOIN #EnrollmentVisit EV on VL.SubjectID=EV.SubjectID
WHERE ROWNUM=1 AND 
VL.EligibleVisit='Yes' AND
ISNULL(VL.VisitDate, '')<>''

--SELECT * FROM #LastEligVisit WHERE VisitDate<>LastEligVisitDate order by SiteID, subjectid, rownum 


IF OBJECT_ID('tempdb..#VisitPlanner') IS NOT NULL DROP TABLE #VisitPlanner 

SELECT CAST(EL.SiteID AS int) AS [SiteID]
      ,SS.[SiteStatus]
	  ,SS.SFSiteStatus
      ,EL.SubjectID AS [SubjectID]
	  ,EL.YearofBirth AS [YOB]
	  ,EL.EnrollingProviderID
	  ,CAST(EL.EnrollmentDate AS date) AS EnrollmentDate
	  ,EL.LastFollowUpProviderID
	  ,CAST(EL.VisitDate AS date) AS LastVisitDate
	  ,EL.VisitType AS VisitType
	  ,CAST(DATEDIFF(D, EL.VisitDate, GETDATE())/30.00 AS decimal(6,2)) AS [MonthsSinceLastVisit]
	  ,CAST(DATEADD(D, 150, EL.VisitDate) AS date) AS [EarliestEligNextFU]
	  ,CAST(DATEADD(D, 180, EL.VisitDate) AS date) AS [TargetNextFUVisitDate]
INTO #VisitPlanner
FROM #LastEligVisit EL
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=EL.SiteID
WHERE EL.ROWNUM=1
AND EL.SUBJECTID NOT IN (SELECT SUBJECTID FROM #EXITS)

--SELECT * FROM #VisitPlanner

INSERT INTO [Reporting].[MS700].[t_op_PatientVisitTracker]
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

SELECT [SiteID]
      ,[SiteStatus]
	  ,[SFSiteStatus]
      ,[SubjectID]
	  ,[YOB]
	  ,[EnrollingProviderID]
	  ,[EnrollmentDate]
	  ,[LastFollowUpProviderID]
	  ,[LastVisitDate]
	  ,[VisitType]
	  ,[MonthsSinceLastVisit]
	  ,CASE WHEN MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN MonthsSinceLastVisit >=5 AND MonthsSinceLastVisit < 7 THEN 'Due Now'
	   WHEN MonthsSinceLastVisit >= 7 THEN 'Overdue'
	   ELSE ''
	   END AS [VisitStatus]
	  ,[EarliestEligNextFU]
	  ,[TargetNextFUVisitDate]

FROM #VisitPlanner VP

--SELECT * FROM [Reporting].[MS700].[t_op_PatientVisitTracker] ORDER BY SiteID, SubjectID

END





GO
