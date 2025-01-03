USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_DAYSBETWEENVISIT]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 01/23/2020
-- Description:	Procedure to create table for page 1 of Patient Visit Tracker Report
-- ===================================================================================================

CREATE PROCEDURE [NMO750].[usp_op_DAYSBETWEENVISIT] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_op_DAYSBETWEENVISIT]
(
	[ROWNUM] [int] NOT NULL,
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar] (40) NULL,
	[SubjectID] [nvarchar] (12) NOT NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[VisitType] [nvarchar] (30) NULL,
	[Visit] [nvarchar] (10) NULL,
	[VisitDate] [date] NULL,
	[PriorvisitDate] [date] NULL,
	[Dayssincelastvisit] [int] NULL,
	[MonthsSinceLastVisit] [float] NULL,

);
*/

--IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 
--SELECT SiteID
--      ,SubjectID
--	  ,patientId
--	  ,ProviderID
--	  ,ExitDate
--	  ,VisitType
--	  ,ExitReason
--	  ,OtherExitReason
--	  ,Exited
--INTO #EXITS
--FROM
--(
--SELECT S.SiteID
--      ,E.subNum AS SubjectID
--	  ,E.subjectId as patientId
--	  ,E.exit_md_cod AS ProviderID
--	  ,E.exit_date AS ExitDate
--	  ,E.eventName AS VisitType
--	  ,ED.exit_reason_dec AS ExitReason
--	  ,ED.exit_reason_specify AS OtherExitReason
--	  ,CASE WHEN ISNULL(exit_reason_dec, '')='' AND ISNULL(exit_date, '')='' THEN 'Exited'
--	   ELSE 'Current'
--	   END AS Exited 

--FROM [RCC_NMOSD750].[staging].[exitdate] E
--LEFT JOIN [RCC_NMOSD750].[staging].[exitdetails] ED ON ED.[subjectId]=E.[subjectId]
--LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.patientId=E.[subjectId]
--WHERE S.[status] NOT IN ('Removed', 'Incomplete')
--) A
--WHERE Exited='Current'

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
		,ROW_NUMBER() OVER(PARTITION BY VL.SiteID, VL.SubjectID ORDER BY VL.VisitDate) AS ROWNUM

 INTO #VisitList
 FROM [Reporting].[NMO750].[t_op_VisitLog] VL 
 LEFT JOIN [RCC_NMOSD750].[staging].[visitreimbursement] VR ON VR.subNum=VL.SubjectID AND VR.eventId=VL.eventDefinitionId AND VR.eventOccurrence=VL.eventOccurrence
 WHERE ISNULL(VL.VisitDate, '')<>''
 AND VL.EligibleVisit='Yes'
 AND VL.SubjectID IN (SELECT SubjectID FROM #EnrollmentVisit)
 AND ((ISNULL(VR.pay_earlyfu_oow, '')<>1)
 OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')=1)
 OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')<>1 AND ISNULL(VR.pay_earlyfu_pay_exception, '')=1))
 AND SiteID <> 1440
  
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
WHERE 1=1 
AND VL.VisitType IN ('Enrollment', 'Follow-up')
AND ISNULL(VL.VisitDate, '')<>''
AND ISNULL(EV.EnrollmentDate, '')<>''


--SELECT * FROM #LastEligVisit ORDER BY SiteID, SubjectID, VisitDate



IF OBJECT_ID('tempdb..#VisitPlanner') IS NOT NULL DROP TABLE #VisitPlanner 

SELECT DISTINCT ROWNUM
      ,SiteID
	  ,EDCSiteStatus
	  ,SFSiteStatus
	  ,SubjectID
	  ,LastFollowUpProviderID AS ProviderID
	  ,EnrollmentDate
	  ,VisitType
	  ,Visit
	  ,VisitDate
	  ,PriorVisitDate
	  ,CAST(DATEDIFF(D, PriorVisitDate, VisitDate) AS int) AS DaysSinceLastVisit
	  ,CAST(DATEDIFF(D, PriorVisitDate, VisitDate)/30.00 AS decimal(6,2)) AS [MonthsSinceLastVisit]

INTO #VisitPlanner
FROM
(
SELECT DISTINCT ROWNUM
      ,EL.SiteID
	  ,EL.EDCSiteStatus
      ,EL.SFSiteStatus
      ,EL.SubjectID
	  ,(SELECT ProviderID FROM #EnrollmentVisit EV WHERE EV.patientId=EL.PatientID) AS [EnrollingProviderID]
	  ,EL.ProviderID as [LastFollowUpProviderID]
	  ,CAST(EL.EnrollmentDate AS date) AS EnrollmentDate
	  ,CAST(EL.VisitDate AS date) AS VisitDate
	  ,('V' + CAST(ROWNUM AS nvarchar)) AS Visit
	  ,EL.VisitType AS VisitType
	  ,CASE WHEN ROWNUM=1 THEN NULL
	   WHEN ROWNUM>1 THEN (SELECT VisitDate FROM #LastEligVisit EL2 WHERE EL2.SubjectID=EL.SubjectID AND ROWNUM=EL.ROWNUM-EL2.ROWNUM)
	   END AS PriorVisitDate

FROM #LastEligVisit EL
WHERE 1=1
--AND ROWNUM=1
--AND EL.SubjectID NOT IN (SELECT SubjectID FROM #EXITS)
AND SiteID <> 1440
) LEV

--SELECT * FROM #VisitPlanner ORDER BY SiteID, SubjectID, VisitDate


TRUNCATE TABLE [Reporting].[NMO750].[t_op_DAYSBETWEENVISIT];

INSERT INTO [Reporting].[NMO750].[t_op_DAYSBETWEENVISIT]
(
	[ROWNUM],
	[SiteID],
	[EDCSiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[ProviderID],
	[EnrollmentDate],
	[VisitType],
	[Visit],
	[VisitDate],
	[PriorVisitDate],
	[Dayssincelastvisit],
	[MonthsSinceLastVisit]
)

SELECT 	[ROWNUM],
	[SiteID],
	[EDCSiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[ProviderID],
	[EnrollmentDate],
	[VisitType],
	[Visit],
	[VisitDate],
	[PriorvisitDate],
	[Dayssincelastvisit],
	[MonthsSinceLastVisit]

FROM #VisitPlanner VP
WHERE ISNULL(SiteID, '') NOT IN ('', 1440)

--SELECT * FROM [Reporting].[NMO750].[t_op_DAYSBETWEENVISIT] ORDER BY SiteID, SubjectID, VisitDate
--SELECT * FROM [Reporting].[NMO750].[t_op_VisitLog] VL WHERE SubjectID IN ('1440-0001', '1440-0002')

END

GO
