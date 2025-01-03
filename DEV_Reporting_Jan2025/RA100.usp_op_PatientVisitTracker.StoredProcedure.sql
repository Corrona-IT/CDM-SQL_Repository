USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_PatientVisitTracker]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- ===========================================================================================
-- Author:		Kaye Mowrey
-- Create date: 05/10/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Date: 11/4/2020
-- Description:	Procedure to create table for Patient Visit Tracker for page 1 of new Patient FU Tracker SMR Report
-- ===========================================================================================

CREATE PROCEDURE [RA100].[usp_op_PatientVisitTracker] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA100].[t_op_PatientVisitTracker]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NOT NULL,
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


TRUNCATE TABLE [Reporting].[RA100].[t_op_PatientVisitTracker];

IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL BEGIN DROP TABLE #EXITS END

 SELECT DISTINCT 
		sv2.SiteID,
        sv2.SubjectID,
		sv2.VisitDate, 
		sv2.VisitType

INTO #EXITS
FROM [Reporting].[RA100].[t_op_SubjectVisits] sv2
LEFT JOIN [RA100].[v_op_SubjectLog] sl ON sv2.SiteID = sl.SiteID  
AND sv2.SubjectID = sl.SubjectID
WHERE sv2.VisitType='Exit' 
      AND ISNULL(sv2.VisitDate, '')<>''
	  AND sl.ExitReason IS NOT NULL


IF OBJECT_ID('tempdb..#EnrollDate') IS NOT NULL BEGIN DROP TABLE #EnrollDate END

SELECT SiteID
      ,SubjectID
	  ,VisitDate AS EnrollmentDate
INTO #EnrollDate
FROM [Reporting].[RA100].[t_op_SubjectVisits] SV
WHERE ISNULL(VisitDate,'')<>''
AND VisitType='Enrollment'
AND SubjectID NOT IN (SELECT SubjectID FROM #EXITS E WHERE E.SiteID=sv.SiteID
			       AND E.SubjectID=SV.SubjectID AND E.VisitDate >= SV.VisitDate) 


IF OBJECT_ID('tempdb..#VisitListing') IS NOT NULL BEGIN DROP TABLE #VisitListing END

SELECT  ROW_NUMBER() OVER(PARTITION BY SV.SiteID, SV.SubjectID ORDER BY SV.VisitDate DESC, SV.VisitType DESC) as ROWNUM
	    ,SV.SiteID
		,SV.SiteStatus
		,SubjectID
		,YOB
		,VisitType
		,VisitDate
		,EnrollingProviderID
		,VisitProviderID

INTO #VisitListing
FROM [Reporting].[RA100].[t_op_SubjectVisits] SV
WHERE ISNULL(VisitDate,'')<>''
AND VisitType IN ('Enrollment', 'Follow-up')
AND SubjectID NOT IN (SELECT SubjectID FROM #EXITS E WHERE E.SiteID=sv.SiteID
			       AND E.SubjectID=SV.SubjectID AND E.VisitDate >= SV.VisitDate)

/*
SELECT * FROM #VisitListing WHERE SubjectID IN (19101107, 19302088) ORDER BY SiteID, SubjectID, ROWNUM
*/


IF OBJECT_ID('tempdb..#VisitPlanner') IS NOT NULL BEGIN DROP TABLE #VisitPlanner END

SELECT VL.SiteID
      ,VL.SiteStatus
	  ,VL.SubjectID
	  ,VL.[YOB]
	  ,VL.EnrollingProviderID
	  ,ED.EnrollmentDate
	  ,VL.VisitProviderID AS [LastFollowUpProviderID]
	  ,VL.VisitDate AS LastVisitDate
	  ,VL.VisitType
	  ,CAST(DATEDIFF(DD, VL.VisitDate, GetDate())/30.0 AS DEC(8,2)) AS MonthsSinceLastVisit
	  ,DATEADD(DD, 150, VL.VisitDate) AS [EarliestEligNextFU]
	  ,DATEADD(DD, 180, VL.VisitDate) AS [TargetNextFUVisitDate]
INTO #VisitPlanner
FROM #VisitListing VL
LEFT JOIN #EnrollDate ED ON ED.SubjectID=VL.SubjectID
WHERE VL.ROWNUM=1

--SELECT * FROM #VisitPlanner ORDER BY SiteID, SubjectID

INSERT INTO [RA100].[t_op_PatientVisitTracker]
(
	[SiteID],
	[SiteStatus],
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

SELECT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,[YOB]
	  ,EnrollingProviderID
	  ,EnrollmentDate
	  ,LastFollowUpProviderID
	  ,LastVisitDate
	  ,VisitType
	  ,MonthsSinceLastVisit
	  ,CASE WHEN MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN MonthsSinceLastVisit >=5 AND MonthsSinceLastVisit < 7 THEN 'Due Now'
	   WHEN MonthsSinceLastVisit >= 7 THEN 'Overdue'
	   ELSE ''
	   END AS VisitStatus
	  ,EarliestEligNextFU
	  ,TargetNextFUVisitDate
FROM #VisitPlanner VP








END


GO
