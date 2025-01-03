USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_DeathRptWithAEs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [PSO500].[v_op_DeathRptWithAEs] AS

SELECT 
		SIT.[Sys. SiteNo] AS [SiteID],
		PAT.[Caption] AS [SubjectID],
		CAST(VIS.[Visit Object VisitDate] AS date) AS [VisitDate],
		VIS.[Visit Object Procaption] AS [VisitType],
		E.[EXIT2_exit_reason] AS [ExitReason],
		CAST(E.[EXIT2_death_dt] AS date) AS [DateofDeath],
		TAES.[EventType] AS [EventType],
		TAES.[EventName] AS [EventName],
		TAES.[EventSpecify] AS [EventSpecify],
		CASE WHEN TAES.[PrimaryCause] = '1' THEN 'Yes'
	    ELSE 'No' END AS [PrimaryCauseofDeath]
FROM [OMNICOMM_PSO].[inbound].[VISIT] VIS
INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.[SiteId] = PAT.SiteId
INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT] E ON E.VisitId = VIS.VisitId
LEFT JOIN 
	(
		SELECT EventType, EventName, EventSpecify, PrimaryCause, VisitId FROM
		(
			SELECT 
				'Cardiovascular Events' AS EventType, 
				[EXIT3_death_seriouscv] AS EventName, 
				[EXIT3_death_other_cv_specify] AS EventSpecify, 
				[EXIT3_cv_primary] AS PrimaryCause, 
				VisitId 
				FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT3]
			UNION
				SELECT 'Malignancies' AS EventType, 
				[EXIT5_death_seriouscancer] AS EventName, 
				[EXIT5_death_other_cancer_specify] AS EventSpecify, 
				[EXIT5_cancer_primary] AS PrimaryCause,
				VisitId 
				FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT5]
			UNION
				SELECT 'Other Targeted Events' AS EventType, 
				[EXIT6_death_seriousother_target] AS EventName, 
				'' AS EventSpecify, 
				[EXIT6_other_target_primary] AS PrimaryCause,
				VisitId 
				FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT6]
			UNION
				SELECT 'Serious Infection' AS EventType, 
				[EXIT4_death_seriousinf] AS EventName, 
				'' AS EventSpecify, 
				[EXIT4_inf_primary] AS PrimaryCause,
				VisitId 
				FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT4]
			UNION
				SELECT 'Other Serious Events (not listed above)' AS EventType, 
				[EXIT7_death_seriousother] AS EventName, 
				[EXIT7_death_accident_exp] AS EventSpecify, 
				[EXIT7_other_primary] AS PrimaryCause,
				VisitId 
				FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT7]
			) AS AES 
			WHERE EventName <> ''
			) AS TAES ON TAES.VisitId = VIS.VisitId
WHERE E.[EXIT2_exit_reason] = 'Death'
---AND SIT.[Sys. SiteNo] NOT IN (998, 999)
---ORDER BY SIT.[Sys. SiteNo], PAT.[Caption]

GO
