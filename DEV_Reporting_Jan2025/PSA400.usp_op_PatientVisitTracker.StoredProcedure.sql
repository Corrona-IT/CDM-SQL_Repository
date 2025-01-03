USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_PatientVisitTracker]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/27/2020
-- Description:	Procedure to create table for Patient Visit Tracker for page 1 of Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [PSA400].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSA400].[t_op_PatientVisitTracker]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NOT NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[YOB] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[LastVisitDate] [date] NULL,
	[VisitType] [nvarchar] (30) NULL,
	[MonthsSinceLastVisit] [float] NULL,
	[VisitStatus] [nvarchar] (15) NULL,
	[EarliestEligNextFU] [date] NULL,
	[TargetNextFUVisitDate] [date] NULL

);
*/

TRUNCATE TABLE [Reporting].[PSA400].[t_op_PatientVisitTracker];

IF OBJECT_ID('temp..#EX') IS NOT NULL BEGIN DROP TABLE #EX END

SELECT A.SiteID
      ,A.SubjectID
	  ,A.DateQuestionnaireCompleted AS ExitDate
	  ,A.ExitReason
	  ,A.ExitReasonOther
INTO #EX	  
FROM Reporting.PSA400.v_op_085_ExitReport A
WHERE SiteID NOT LIKE '9999%'
AND DateQuestionnaireCompleted <> '' OR ExitReason IS NOT NULL


IF OBJECT_ID('temp..#EnrollmentVisit') IS NOT NULL BEGIN DROP TABLE #EnrollmentVisit END

SELECT V.SITENUM As SiteID
      ,V.SUBNUM AS SubjectID
	  ,COALESCE(ES_01.BIRTHDATE, ESUB_01.BIRTHDATE) AS YOB
	  ,V.VISNAME AS VisitType
	  ,V.VISITID AS VisitID
	  ,V.VISITDATE AS EnrollmentDate
INTO #EnrollmentVisit
FROM MERGE_SPA.staging.VS_01 V
LEFT JOIN MERGE_SPA.staging.ES_01 ON ES_01.vID=V.vID
LEFT JOIN MERGE_SPA.staging.ESUB_01 ON ESUB_01.vID=v.vID
WHERE V.SUBNUM NOT IN (SELECT SubjectID from #EX)
AND V.VISITID IN (10, 11)
AND V.SITENUM NOT LIKE '9999%'

--SELECT * FROM #EnrollmentVisit


IF OBJECT_ID('temp..#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT ROW_NUMBER() OVER (PARTITION BY V.SITENUM, V.SUBNUM ORDER BY V.SITENUM, V.SUBNUM, V.VISITDATE DESC) AS ROWNUM
      ,V.SITENUM As SiteID
      ,V.SUBNUM AS SubjectID
	  ,V.VISITDATE AS LastVisitDate
	  ,CASE WHEN V.VISNAME LIKE 'Follow%' THEN 'Follow Up'
	   WHEN V.VISNAME LIKE 'Enroll%' THEN 'Enrollment'
	   ELSE V.VISNAME 
	   END AS LastVisitType

INTO #Visits
FROM MERGE_SpA.staging.VS_01 V
WHERE V.SITENUM NOT LIKE '9999%'
AND V.SUBNUM NOT IN (SELECT SubjectID FROM #EX)


IF OBJECT_ID('temp..#LastVisit') IS NOT NULL BEGIN DROP TABLE #LastVisit END

SELECT ROWNUM
      ,SiteID
	  ,SubjectID
	  ,LastVisitDate
	  ,LastVisitType

INTO #LastVisit
FROM #Visits
WHERE ROWNUM=1

---SELECT * FROM #LastVisit


IF OBJECT_ID('temp..#SiteStatus') IS NOT NULL BEGIN DROP TABLE #SiteStatus END

SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
      ,CASE WHEN ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
INTO #SiteStatus
FROM [MERGE_SPA].[dbo].[DAT_SITES]
WHERE SITENUM NOT LIKE '9999%'

---SELECT * FROM #SiteStatus


IF OBJECT_ID('temp..#VisitPlanner') IS NOT NULL BEGIN DROP TABLE #VisitPlanner END

SELECT DISTINCT CAST(A.SiteID as int) AS SiteID
      ,SiteStatus
      ,A.SubjectID
	  ,A.YOB
	  ,A.EnrollmentDate
	  ,C.LastVisitDate
	  ,C.LastVisitType

	  ----,(DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) AS MonthsSinceLastVisit
	  ,CAST((DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) as decimal(8,2)) AS MonthsSinceLastVisit
	  ,DATEADD(DAY, 180, C.LastVisitDate) AS TargetedNextFU
	  ,DATEADD(DAY, 150, C.LastVisitDate)  AS EarliestEligNextFU
INTO #VisitPlanner
FROM #EnrollmentVisit A
LEFT JOIN #SiteStatus SS ON SS.SiteID=A.SiteID
LEFT JOIN #LastVisit C ON A.SiteID=C.SiteID AND A.SubjectID=C.SubjectID
WHERE A.SubjectID NOT IN (Select SubjectID from #EX)
AND A.SiteID NOT IN (99999, 99998, 99997)
AND ISNULL(C.LastVisitDate, '') <>''

---SELECT * FROM #VisitPlanner

INSERT INTO [Reporting].[PSA400].[t_op_PatientVisitTracker]
(
	[SiteID],
	[SiteStatus],
	[SubjectID],
	[YOB],
	[EnrollmentDate],
	[LastVisitDate],
	[VisitType],
	[MonthsSinceLastVisit],
	[VisitStatus],
	[EarliestEligNextFU],
	[TargetNextFUVisitDate]
)
SELECT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,YOB
	  ,EnrollmentDate
	  ,LastVisitDate
	  ,CASE WHEN LastVisitType LIKE 'Enroll%' THEN 'Enrollment'
	   WHEN LastVisitType LIKE 'Follow%' THEN 'Follow-Up'
	   ELSE LastVisitType
	   END AS VisitType
	  ,MonthsSinceLastVisit
	  ,CASE WHEN MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN MonthsSinceLastVisit >= 5 and MonthsSinceLastVisit < 7 THEN 'Due Now'
	   WHEN MonthsSinceLastVisit >= 7 THEN 'Overdue'
	   ELSE ''
	   END AS VisitStatus
	  ,EarliestEligNextFU AS EarliestEligNextFU
	  ,TargetedNextFU AS TargetNextFUVisitDate
FROM #VisitPlanner

--ORDER BY A.SiteID, A.SubjectID


END





GO
