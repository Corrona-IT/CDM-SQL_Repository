USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_VisitPlanningLineListing]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [PSO500].[v_op_VisitPlanningLineListing] AS

SELECT
      CAST(AdSite.[TrlSiteId] AS bigint) AS [TrlSiteId],
      CAST(SIT.[Site Number] AS int) AS [SiteNumber],
      CAST(PAT.[subject_id] AS bigint) AS SubjectID,
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
FROM [OMNICOMM_PSO].[inbound].[VISIT] VIS
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteId = VIS.SiteId
INNER JOIN [OMNICOMM_PSO].[inbound].[Adhoc_Sites] AdSite ON AdSite.SiteId = SIT.SiteId
WHERE 
    VIS.[Visit Object ProCaption] in ('Enrollment','Follow-up') -- selecting 'Enrollment' and 'Follow-up' visits
    AND ISNULL(vis.[Visit Object VisitDate], '') <> '' -- excluding empty (no visit date)
    AND vis.[PatientId] not in 
    (
            -- excluding patients which have valid exit visit, but only if there is no any other visit after the 'Exit' visit ('Exist' visit is the last of all visits)
            SELECT ep.[PatientId] 
            FROM [OMNICOMM_PSO].[inbound].[Visits] ep
            WHERE ep.[ProCaption] = 'Exit' AND ISNULL(ep.[VisitDate], '') <> ''
            AND ep.[PatientId] NOT IN (
                  SELECT pfe.[PatientId] 
                   FROM [OMNICOMM_PSO].[inbound].[Visits] pfe
                 WHERE ISNULL(pfe.[VisitDate], '') <> '' AND pfe.[ProCaption] <> 'Exit'
                  AND ep.[PatientId] = pfe.[PatientId]
                  AND pfe.[VisitDate] > ep.[VisitDate]
            )
    )
GROUP BY AdSite.[TrlSiteId], vis.[PatientId], sit.[TrlObjectId], sit.[Site Number], pat.[subject_id], PAT.[pat_md_cod], PAT.[Enroll Date]
---ORDER BY SiteNumber Desc


GO
