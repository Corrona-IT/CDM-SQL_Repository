USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_PatientVisitTracker]    Script Date: 1/3/2025 4:53:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- ===================================================================================================
-- Author:		Kevin Soe
-- Create date: 10/07/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Date: 11/4/2020
-- Description:	Procedure to create table for Patient Visit Tracker for page 1 of Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [RA102].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA102].[t_op_PatientVisitTracker]
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

TRUNCATE TABLE [Reporting].[RA102].[t_op_PatientVisitTracker];

IF OBJECT_ID('temp..#EX_RAJ') IS NOT NULL BEGIN DROP TABLE #EX_RAJ END

SELECT A.[SITENUM] AS [SiteID]
      ,A.[SUBNUM] AS [SubjectID]
	  ,A.[DISCONTINUE_DATE] AS [ExitDate]
	  ,A.[EXIT_REASON_DIS] AS [ExitReason]
	  ,A.[OTHER_SPECIFY] AS [ExitReasonOther]
INTO #EX_RAJ
FROM Reporting.RA102.v_op_083_ExitReport A
WHERE SITENUM NOT LIKE '999%'
AND [DISCONTINUE_DATE] <> '' 
OR [EXIT_REASON_DIS] IS NOT NULL



IF OBJECT_ID('temp..#EnrollmentVisit_RAJ') IS NOT NULL BEGIN DROP TABLE #EnrollmentVisit_RAJ END

SELECT V.SITENUM As SiteID
      ,V.SUBNUM AS SubjectID
	  ,SUB.BIRTHDATE AS YOB
	  ,V.VISNAME AS VisitType
	  ,V.VISITID AS VisitID
	  ,V.VISITDATE AS EnrollmentDate
INTO #EnrollmentVisit_RAJ
FROM MERGE_RA_JAPAN.staging.VIS_DATE V
LEFT JOIN [MERGE_RA_Japan].[staging].[SUB_01] SUB ON SUB.vID=V.vID
WHERE V.SUBNUM NOT IN (SELECT SubjectID from #EX_RAJ)
AND V.VISITID=10
AND V.SITENUM NOT LIKE '999%'

--SELECT * FROM #EnrollmentVisit


IF OBJECT_ID('temp..#Visits_RAJ') IS NOT NULL BEGIN DROP TABLE #Visits_RAJ END

SELECT ROW_NUMBER() OVER (PARTITION BY V.SITENUM, V.SUBNUM ORDER BY V.SITENUM, V.SUBNUM, V.VISITDATE DESC) AS ROWNUM
      ,V.SITENUM As SiteID
      ,V.SUBNUM AS SubjectID
	  ,V.VISITDATE AS LastVisitDate
	  ,CASE WHEN V.VISNAME LIKE '%Followup%' THEN 'Follow Up'
	   ELSE V.VISNAME 
	   END AS LastVisitType

INTO #Visits_RAJ
FROM MERGE_RA_JAPAN.staging.VIS_DATE V
WHERE V.SITENUM NOT LIKE '999%'
AND V.SUBNUM NOT IN (SELECT SubjectID FROM #EX_RAJ)


IF OBJECT_ID('temp..#LastVisit_RAJ') IS NOT NULL BEGIN DROP TABLE #LastVisit_RAJ END

SELECT ROWNUM
      ,SiteID
	  ,SubjectID
	  ,LastVisitDate
	  ,LastVisitType

INTO #LastVisit_RAJ
FROM #Visits_RAJ
WHERE ROWNUM=1

---SELECT * FROM #LastVisit


IF OBJECT_ID('temp..#SiteStatus_RAJ') IS NOT NULL BEGIN DROP TABLE #SiteStatus_RAJ END

SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
      ,CASE WHEN ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
INTO #SiteStatus_RAJ
FROM [MERGE_RA_JAPAN].[dbo].[DAT_SITES]
WHERE SITENUM NOT LIKE '999%'

---SELECT * FROM #SiteStatus


IF OBJECT_ID('temp..#VisitPlanner_RAJ') IS NOT NULL BEGIN DROP TABLE #VisitPlanner_RAJ END

SELECT DISTINCT CAST(A.SiteID as int) AS SiteID
      ,SiteStatus
      ,CAST(A.SubjectID AS bigint) AS SubjectID
	  ,A.YOB
	  ,A.EnrollmentDate
	  ,C.LastVisitDate
	  ,C.LastVisitType

	  ----,(DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) AS MonthsSinceLastVisit
	  ,CAST((DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) as decimal(8,2)) AS MonthsSinceLastVisit
	  ,DATEADD(DAY, 180, C.LastVisitDate) AS TargetedNextFU
	  ,DATEADD(DAY, 150, C.LastVisitDate)  AS EarliestEligNextFU
INTO #VisitPlanner_RAJ
FROM #EnrollmentVisit_RAJ A
LEFT JOIN #SiteStatus_RAJ SS ON SS.SiteID=A.SiteID
LEFT JOIN #LastVisit_RAJ C ON A.SiteID=C.SiteID AND A.SubjectID=C.SubjectID
WHERE A.SubjectID NOT IN (Select SubjectID from #EX_RAJ)
AND A.SiteID NOT IN (9999, 9998, 9997)
AND ISNULL(C.LastVisitDate, '') <>''

---SELECT * FROM #VisitPlanner

INSERT INTO [Reporting].[RA102].[t_op_PatientVisitTracker]
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
	  ,CASE WHEN LastVisitType='Enrollment Visit' THEN 'Enrollment'
	   WHEN LastVisitType='Follow Up' THEN 'Follow-Up'
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
FROM #VisitPlanner_RAJ

--ORDER BY A.SiteID, A.SubjectID


END



GO
