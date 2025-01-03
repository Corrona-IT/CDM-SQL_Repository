USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_PatientVisitTracker]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 01/23/2020
-- Description:	Procedure to create table for page 1 of Patient Visit Tracker Report
-- ===================================================================================================

CREATE PROCEDURE [NMO750].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_op_PatientVisitTracker]
(
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar] (40) NULL,
	[SubjectID] [nvarchar] (12) NOT NULL,
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
	  ,ED.exit_reason_dec AS ExitReason
	  ,ED.exit_reason_specify AS OtherExitReason
	  ,CASE WHEN ISNULL(exit_reason_dec, '')='' AND ISNULL(exit_date, '')='' THEN 'Exited'
	   ELSE 'Current'
	   END AS Exited 

FROM [RCC_NMOSD750].[staging].[exitdate] E
LEFT JOIN [RCC_NMOSD750].[staging].[exitdetails] ED ON ED.[subjectId]=E.[subjectId]
LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.patientId=E.[subjectId]
WHERE S.[status] NOT IN ('Removed', 'Incomplete')
) A
WHERE Exited='Current'

--SELECT * FROM #EXITS ORDER BY SubjectID

IF OBJECT_ID('tempdb..#EnrollmentVisit') IS NOT NULL DROP TABLE dbo.#EnrollmentVisit

SELECT [SiteID]
      ,[SFSiteStatus]
	  ,[EDCSiteStatus]
      ,[SubjectID]
	  ,[PatientID]
	  ,[birthYear]
	  ,[ProviderID]
      ,[VisitType]
      ,[VisitSequence]
      ,[VisitDate] AS EnrollmentDate
INTO #EnrollmentVisit
FROM [NMO750].[t_op_VisitLog]
WHERE VisitType='Enrollment'
AND EligibleVisit='Yes'

--SELECT * FROM #EnrollmentVisit ORDER BY SubjectID


IF OBJECT_ID('tempdb..#VisitList') IS NOT NULL DROP TABLE #VisitList 

  SELECT DISTINCT VL.SiteID
        ,VL.SFSiteStatus
        ,VL.EDCSiteStatus
		,VL.SubjectID
		,VL.patientId
		,VL.ProviderID
		,VL.VisitType
		,VL.VisitSequence
		,VL.VisitDate
		,VL.birthYear
		,VL.EligibleVisit
		,VR.pay_earlyfu_oow AS visitOOW
		,VR.pay_earlyfu_status AS earlyFUReimbRuleSatisfied
		,VR.pay_visit_confirmed_incomplete AS permIncomplete
		,VR.pay_earlyfu_pay_exception AS visitRescheduled
		,VR.pay_earlyfu_pay_exception AS earlyFUPayException
		,ROW_NUMBER() OVER(PARTITION BY VL.SiteID, VL.SubjectID ORDER BY VL.VisitDate DESC) AS ROWNUM

 INTO #VisitList
 FROM [Reporting].[NMO750].[t_op_VisitLog] VL 
 LEFT JOIN [RCC_NMOSD750].[staging].[visitreimbursement] VR ON VR.subNum=VL.SubjectID AND VR.eventId=VL.eventDefinitionId AND VR.eventOccurrence=VL.eventOccurrence
 WHERE ISNULL(VL.VisitDate, '')<>''
 AND VL.EligibleVisit='Yes'
 AND VL.SubjectID IN (SELECT SubjectID FROM #EnrollmentVisit)
 AND ((ISNULL(VR.pay_earlyfu_oow, '')<>1)
 OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')=1)
 OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')<>1 AND ISNULL(VR.pay_earlyfu_pay_exception, '')=1))
  
--SELECT * FROM #VisitList ORDER BY SiteID, SubjectID, ROWNUM


IF OBJECT_ID('tempdb..#LastEligVisit') IS NOT NULL DROP TABLE #LastEligvisit 

SELECT ROWNUM
      ,VL.SiteID
	  ,VL.EDCSiteStatus
	  ,VL.SFSiteStatus
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.birthYear AS YOB
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


--SELECT * FROM #LastEligVisit ORDER BY SiteID, SubjectID, VisitDate



IF OBJECT_ID('tempdb..#VisitPlanner') IS NOT NULL DROP TABLE #VisitPlanner 

SELECT DISTINCT EL.SiteID
	  ,EL.EDCSiteStatus
      ,EL.SFSiteStatus
      ,EL.SubjectID
	  ,(SELECT ProviderID FROM #EnrollmentVisit EV WHERE EV.patientId=EL.PatientID) AS [EnrollingProviderID]
	  ,EL.ProviderID as [LastFollowUpProviderID]
	  ,EL.[YOB]
	  ,CAST(EL.EnrollmentDate AS date) AS EnrollmentDate
	  ,CAST(EL.VisitDate AS date) AS LastVisitDate
	  ,EL.VisitType AS VisitType
	  ,CAST(DATEDIFF(D, EL.VisitDate, GETDATE())/30.00 AS decimal(6,2)) AS [MonthsSinceLastVisit]
	  ,CAST(DATEADD(D, 150, EL.VisitDate) AS date) AS [EarliestEligNextFU]
	  ,CAST(DATEADD(D, 180, EL.VisitDate) AS date) AS [TargetNextFUVisitDate]
INTO #VisitPlanner
FROM #LastEligVisit EL
WHERE ROWNUM=1
AND EL.SubjectID NOT IN (SELECT SubjectID FROM #EXITS)

--SELECT * FROM #VisitPlanner


TRUNCATE TABLE [Reporting].[NMO750].[t_op_PatientVisitTracker];

INSERT INTO [Reporting].[NMO750].[t_op_PatientVisitTracker]
(
	[SiteID],
	[EDCSiteStatus],
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
	  ,[EDCSiteStatus]
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
--WHERE ISNULL(SiteID, '') NOT IN ('', 1440)

--SELECT * FROM [Reporting].[NMO750].[t_op_PatientVisitTracker] ORDER BY SiteID, SubjectID
--SELECT * FROM [Reporting].[NMO750].[t_op_VisitLog] VL WHERE SubjectID IN ('1440-0001', '1440-0002')

END

GO
