USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_PatientVisitTracker]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



















-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 01/23/2020
-- Description:	Procedure to create table for page 1 of Patient Visit Tracker Report
-- ===================================================================================================

CREATE PROCEDURE [AD550].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_op_PatientVisitTracker]
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

IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 
SELECT SiteID
      ,SubjectID
	  ,patientId
	  ,ProviderID
	  ,ExitDate
	  ,VisitType
	  ,ExitReason
	  ,OtherExitReason
	  ,Exited
INTO #EXITS
FROM
(
SELECT S.SiteID
      ,E.subNum AS SubjectID
	  ,E.subjectId as patientId
	  ,E.exit_md_cod AS ProviderID
	  ,E.exit_date AS ExitDate
	  ,E.eventName AS VisitType
	  ,E.exit_reason_dec AS ExitReason
	  ,E.exit_reason_specify AS OtherExitReason
	  ,CASE WHEN ISNULL(exit_reason_dec, '')='' AND ISNULL(exit_date, '')='' THEN 'Exited'
	   ELSE 'Current'
	   END AS Exited 

FROM [RCC_AD550].[staging].[exitdetails] E
LEFT JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=E.[subjectId]
WHERE S.[status] NOT IN ('Removed', 'Incomplete')
AND LEN(E.subNum)<20
) A
WHERE Exited='Current'

--SELECT * FROM #EXITS

/*****Sites*****/

IF OBJECT_ID('tempdb.dbo.#StudySites') IS NOT NULL DROP TABLE #StudySites

SELECT [jsonId]
      ,[name]
	  ,SUBSTRING([name], 1, CHARINDEX('-', [name])-1) AS SiteID
	  ,SUBSTRING([name], CHARINDEX('-', [name])+1, LEN([name])) AS SiteName
      ,[siteType]
      ,[principalInvestigator]
      ,[studyId]
      ,[siteId] AS InternalSiteNumber
      ,[facilityName]
      ,[id]
      ,[enabled]

  INTO #StudySites
  FROM [RCC_AD550].[api].[study_sites]

  --SELECT * FROM #StudySites ORDER BY SiteID

IF OBJECT_ID('tempdb..#EnrollmentVisit') IS NOT NULL DROP TABLE dbo.#EnrollmentVisit

SELECT [SiteID]
      ,[SubjectID]
	  ,[PatientID]
	  ,[ProviderID]
      ,[VisitType]
      ,[VisitSequence]
      ,[VisitDate] AS EnrollmentDate

INTO #EnrollmentVisit
FROM [AD550].[t_op_VisitLog] VL
WHERE VisitType='Enrollment'
AND EligibleVisit='Yes'
AND LEN(VL.SubjectID)<20

--SELECT * FROM #EnrollmentVisit
--SELECT * FROM [AD550].[t_op_VisitLog] WHERE eventId=8034


IF OBJECT_ID('tempdb..#VisitList') IS NOT NULL DROP TABLE #VisitList 

  SELECT DISTINCT VL.SiteID
        ,VL.SubjectID
		,VL.patientId
		,VL.ProviderID
		,VL.VisitType
		,VL.VisitSequence
		,VL.VisitDate
		,(SELECT DISTINCT birthdate FROM [RCC_AD550].[staging].[subject] S WHERE LEN(S.subjectId)<20 AND S.subjectId=VL.patientId AND S.eventName='Enrollment Visit') AS BirthDate
		,ROW_NUMBER() OVER(PARTITION BY VL.SiteID, VL.SubjectID ORDER BY VL.VisitDate DESC) AS ROWNUM

 INTO #VisitList
 FROM [Reporting].[AD550].[t_op_VisitLog] VL 
 LEFT JOIN [RCC_AD550].[staging].[visitreimbursement] VR ON VR.subNum=VL.SubjectID AND VR.eventId=VL.eventId AND VR.eventOccurrence=vl.eventOccurrence AND LEN(VR.subNum)<20
 WHERE LEN(VL.SubjectID)<20
 AND (ISNULL(VL.VisitDate, '')<>'')
 AND (VL.EligibleVisit='Yes')
 AND (VL.SubjectID IN (SELECT SubjectID FROM #EnrollmentVisit WHERE LEN(VL.SubjectID)<20))
 AND ((ISNULL(VR.pay_earlyfu_oow, '')<>1)
 OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')<>1 AND ISNULL(VR.pay_earlyfu_pay_exception, '')=1) 
 OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')=1)
 )

--SELECT * FROM #VisitList WHERE SubjectID= 57778800001 ORDER BY SiteID, SubjectID, ROWNUM
--select * from [RCC_AD550].[staging].[visitreimbursement] where (ISNULL(pay_earlyfu_oow, '')=1 AND ISNULL(pay_earlyfu_status, '')<>1 AND ISNULL(pay_earlyfu_pay_exception, '')=1)

IF OBJECT_ID('tempdb..#LastEligVisit') IS NOT NULL DROP TABLE #LastEligvisit 

SELECT ROWNUM
      ,VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.Birthdate AS YearofBirth
	  ,EV.EnrollmentDate AS EnrollmentDate
	  ,VL.VisitDate AS VisitDate
	  ,VL.VisitType

INTO #LastEligVisit
FROM #VisitList VL
LEFT JOIN #EnrollmentVisit EV on VL.SubjectID=EV.SubjectID
WHERE ROWNUM=1 
AND VL.VisitType IN ('Enrollment', 'Follow-up')
AND ISNULL(VL.VisitDate, '')<>''
AND ISNULL(EV.EnrollmentDate, '')<>''


--SELECT * FROM #LastEligVisit WHERE SUBJECTID= 57778800001 ORDER BY SiteID, SubjectID, VisitDate


IF OBJECT_ID('tempdb..#SiteStatus') IS NOT NULL  DROP TABLE #SiteStatus 

SELECT DISTINCT SS.SiteID
      ,SS.[SiteStatus]
	  ,RS.currentStatus AS SFSiteStatus
INTO #SiteStatus
FROM [AD550].[v_SiteStatus] SS
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=SS.SiteID AND RS.[name]='Atopic Dermatitis (AD-550)'

--SELECT * FROM #SiteStatus


IF OBJECT_ID('tempdb..#VisitPlanner') IS NOT NULL DROP TABLE #VisitPlanner 

SELECT EL.SiteID
      ,SS.[SiteStatus]
	  ,SS.SFSiteStatus
      ,EL.SubjectID
	  ,(SELECT ProviderID FROM #EnrollmentVisit EV WHERE EV.patientId=EL.PatientID) AS [EnrollingProviderID]
	  ,EL.ProviderID as [LastFollowUpProviderID]
	  ,EL.YearofBirth AS [YOB]
	  ,CAST(EL.EnrollmentDate AS date) AS EnrollmentDate
	  ,CAST(EL.VisitDate AS date) AS LastVisitDate
	  ,EL.VisitType AS VisitType
	  ,CAST(DATEDIFF(D, EL.VisitDate, GETDATE())/30.00 AS decimal(6,2)) AS [MonthsSinceLastVisit]
	  ,CAST(DATEADD(D, 150, EL.VisitDate) AS date) AS [EarliestEligNextFU]
	  ,CAST(DATEADD(D, 180, EL.VisitDate) AS date) AS [TargetNextFUVisitDate]
INTO #VisitPlanner
FROM #LastEligVisit EL
LEFT JOIN #SiteStatus SS ON SS.SiteID=EL.SiteID
WHERE ROWNUM=1
AND EL.SubjectID NOT IN (SELECT SubjectID FROM #EXITS)

--SELECT * FROM #VisitPlanner


TRUNCATE TABLE [Reporting].[AD550].[t_op_PatientVisitTracker];

INSERT INTO [Reporting].[AD550].[t_op_PatientVisitTracker]
(
	[SiteID],
	[SiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[YOB],
	[EnrollmentDate],
	[EnrollingProviderID],
	[LastVisitDate],
	[VisitType],
	[LastFollowUpProviderID],
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
	  ,EnrollmentDate
	  ,[EnrollingProviderID]
	  ,LastVisitDate
	  ,VisitType
	  ,[LastFollowUpProviderID]
	  ,[MonthsSinceLastVisit]
	  ,CASE WHEN MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN MonthsSinceLastVisit >=5 AND MonthsSinceLastVisit < 7 THEN 'Due Now'
	   WHEN MonthsSinceLastVisit >= 7 THEN 'Overdue'
	   ELSE ''
	   END AS VisitStatus
	  ,[EarliestEligNextFU]
	  ,[TargetNextFUVisitDate]

FROM #VisitPlanner VP
WHERE ISNULL(SiteID, '') NOT IN ('', 1440)

--SELECT * FROM #VISITPLANNER ORDER BY SiteID, SubjectID
--SELECT * FROM [Reporting].[AD550].[t_op_PatientVisitTracker] ORDER BY SiteID, SubjectID


END

GO
