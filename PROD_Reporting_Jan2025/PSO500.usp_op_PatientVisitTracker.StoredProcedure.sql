USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_PatientVisitTracker]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/27/2020
-- Description:	Procedure to create table for Patient Visit Tracker for page 1 of new Visit Planning SMR Report
-- ===================================================================================================

CREATE PROCEDURE [PSO500].[usp_op_PatientVisitTracker] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSO500].[t_op_PatientVisitTracker]
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


TRUNCATE TABLE [Reporting].[PSO500].[t_op_PatientVisitTracker];


IF OBJECT_ID('tempdb..#VISITPLANNER') IS NOT NULL BEGIN DROP TABLE #VISITPLANNER END

--select * from #VISITPLANNER

SELECT
      CAST(AdSite.[TrlSiteId] AS bigint) AS [TrlSiteId],
      CAST(SIT.[Site Number] AS int) AS SiteID,
      PAT.[subject_id] AS SubjectID,
	  CAST((
			SELECT TOP 1 vn.[Visit_birthdate_visit]
			FROM [OMNICOMM_PSO].[inbound].[VISIT] vn 
            WHERE vn.[PatientId] = vis.[PatientId] 
                   AND vn.[Visit Object VisitDate] = MAX(vis.[Visit Object VisitDate]) 
      ) AS int) AS [YOB],
	  CAST(PAT.[pat_md_cod] AS int) AS [Enrolling Provider ID],
	  CAST(PAT.[Enroll Date] AS date) AS [Enrollment Date],
	  CAST((
      SELECT TOP 1 PE2.[PE1F_md_cod_fu] 
      FROM [OMNICOMM_PSO].[inbound].[PE2] PE2
      WHERE PE2.[PatientId] = vis.[PatientId] 
             AND PE2.[Visit Object VisitDate] = MAX(vis.[Visit Object VisitDate]) 
             AND PE2.[Visit Object ProCaption] in ('Follow-up') 
      ) AS int)  AS [Last Follow-Up Provider ID],
      CAST(MAX(VIS.[Visit Object VisitDate]) AS date) AS [LastVisitDate],
      (
            SELECT TOP 1 vn.[Visit Object ProCaption] 
            FROM [OMNICOMM_PSO].[inbound].[VISIT] vn 
            WHERE vn.[PatientId] = vis.[PatientId] 
                   AND vn.[Visit Object VisitDate] = MAX(vis.[Visit Object VisitDate]) 
      ) AS [VisitType],
	  (DATEDIFF(DAY, MAX(VIS.[Visit Object VisitDate]), GETDATE())/30.0) AS MonthsSinceLastVisit,
      -- EligibleSince = Today - LastVisitDate = 150days(5m)
      CAST(CONVERT(nvarchar, DATEADD(DAY, 150, MAX(VIS.[Visit Object VisitDate])) , 111) AS date) AS [EarliestNextFUVisitDate],
	  CAST(CONVERT(nvarchar, DATEADD(DAY, 180, MAX(VIS.[Visit Object VisitDate])) , 111) AS date) AS [TargetNextFUVisitDate]

INTO #VISITPLANNER

FROM [OMNICOMM_PSO].[inbound].[VISIT] VIS
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteId = VIS.SiteId
INNER JOIN [OMNICOMM_PSO].[inbound].[Adhoc_Sites] AdSite ON AdSite.SiteId = SIT.SiteId
WHERE 
    SIT.[Site Number] NOT IN (997, 998, 999) -- remove test site data
	AND VIS.[Visit Object ProCaption] in ('Enrollment','Follow-up') -- selecting 'Enrollment' and 'Follow-up' visits
    AND ISNULL(vis.[Visit Object VisitDate], '') <> '' -- excluding empty (no visit date)
    AND vis.[PatientId] not in 
    (
            -- excluding patients which have valid exit visit, but only if there is no any other visit after the 'Exit' visit ('Exist' visit is the last of all visits)
            SELECT ep.[PatientId] --SELECT *
            FROM [OMNICOMM_PSO].[inbound].[Visits] ep
					--SELECT * FROM 
			LEFT JOIN [OMNICOMM_PSO].[inbound].[EXIT] ex
			ON ep.PatientId = ex.PatientId AND ep.VisitId = ex.VisitId AND ep.OrderNo = ex.[Visit Object OrderNo] AND ep.InstanceNo = ex.[Visit Object InstanceNo]
            WHERE ep.[ProCaption] = 'Exit' AND (ISNULL(ep.[VisitDate], '') <> '' OR ex.EXIT2_exit_reason IS NOT NULL)
            AND ep.[PatientId] NOT IN (
                  SELECT pfe.[PatientId] 
                   FROM [OMNICOMM_PSO].[inbound].[Visits] pfe
                 WHERE ISNULL(pfe.[VisitDate], '') <> ''  AND pfe.[ProCaption] <> 'Exit'
                  AND ep.[PatientId] = pfe.[PatientId]
                  AND pfe.[VisitDate] > ep.[VisitDate]
            )
    )
GROUP BY AdSite.[TrlSiteId], vis.[PatientId], sit.[TrlObjectId], sit.[Site Number], pat.[subject_id], PAT.[pat_md_cod], PAT.[Enroll Date]
---ORDER BY SiteNumber Desc


		 



insert into [Reporting].[PSO500].[t_op_PatientVisitTracker]
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

SELECT CAST(VP.SiteID AS int) AS SiteID
      ,CASE WHEN ISNULL(SL.SiteStatus, '')='' THEN 'Active'
	   ELSE SL.SiteStatus
	   END AS SiteStatus
      ,VP.SubjectID AS SubjectID
	  ,CAST(YOB AS int) AS YOB
	  ,CAST([Enrolling Provider ID] AS int) AS EnrollingProviderID
	  ,CAST([Enrollment Date] AS date) AS EnrollmentDate
	  ,CAST([Last Follow-Up Provider ID] AS int) AS LastFollowUpProviderID
	  ,CAST(LastVisitDate AS date) AS LastVisitDate
	  ,VisitType
	  ,MonthsSinceLastVisit
	  ,CASE WHEN MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN MonthsSinceLastVisit >=5 AND MonthsSinceLastVisit < 9 THEN 'Due Now'
	   WHEN MonthsSinceLastVisit >= 9 THEN 'Overdue'
	   ELSE ''
	   END AS VisitStatus
	  ,CAST(EarliestNextFUVisitDate AS date) AS EarliestNextFUVisitDate
	  ,CAST(TargetNextFUVisitDate AS date) AS TargetNextFUVisitDate
FROM #VISITPLANNER VP
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SL ON SL.SiteID=VP.SiteID



END











GO
