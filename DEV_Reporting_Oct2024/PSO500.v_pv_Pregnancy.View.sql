USE [Reporting]
GO
/****** Object:  View [PSO500].[v_pv_Pregnancy]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [PSO500].[v_pv_Pregnancy]  as

SELECT
	SIT.[Site Number] AS [SiteNumber],
	SStatus.[SiteStatus],
	PAT.[subject_id] AS [SubjectID],
	CAST(DM8_CRF.[Visit Object VisitDate] AS date) AS [VisitDate],
	DM8_CRF.[Visit Object ProCaption] AS [VisitType],
	DM8_CRF.[DM8_pregnant_current] AS [PregnantCurrent],
	'' AS [PregnantSince],
	CAST(DM8_CRF.[Form Object LastChange] AS date) AS [LastModified]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [OMNICOMM_PSO].[inbound].[DM] DM8_CRF ON DM8_CRF.PatientID = PAT.PatientId
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=SIT.[Site Number]
WHERE (DM8_CRF.[DM8_pregnant_current] != '' AND DM8_CRF.[DM8_pregnant_current] != 'NO')

UNION

SELECT
	SIT.[Site Number] AS [SiteNumber],
	SStatus.[SiteStatus],
	PAT.[subject_id] AS [SubjectID],
	CAST(DMF3_CRF.[Visit Object VisitDate] AS date) AS [VisitDate],
	DMF3_CRF.[Visit Object ProCaption] [VisitType],
	DMF3_CRF.[DMF3_pregnant_current_fu] AS [PregnantCurrent],
	DMF3_CRF.[DMF3_pregnant_ever_fu] AS [PregnantSince],
	CAST(DMF3_CRF.[Form Object LastChange] AS date) AS [LastModified]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [OMNICOMM_PSO].[inbound].[DMF] DMF3_CRF ON DMF3_CRF.PatientID = PAT.PatientId
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=SIT.[Site Number]
WHERE (DMF3_CRF.[DMF3_pregnant_ever_fu] != '' AND DMF3_CRF.[DMF3_pregnant_ever_fu] != 'NO')
	OR (DMF3_CRF.[DMF3_pregnant_current_fu] != '' AND DMF3_CRF.[DMF3_pregnant_current_fu] != 'NO')
GO
