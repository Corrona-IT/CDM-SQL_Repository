USE [Reporting]
GO
/****** Object:  View [PSO500].[v_pv_Pregnancy_5.1Test]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE view [PSO500].[v_pv_Pregnancy_5.1Test]  as

SELECT
	SIT.[Site Information_Site Number] AS [SiteNumber],
	SStatus.[SiteStatus],
	PAT.[Subject Information_subject_id] AS [SubjectID],
	CAST(DM8_CRF.[Sys. VisitDate] AS date) AS [VisitDate],
	DM8_CRF.[Sys. VisitCaption] AS [VisitType],
	DM8_CRF.[pregnant_current] AS [PregnantCurrent],
	'' AS [PregnantSince],
	CAST(DM8_CRF.[LastModified] AS date) AS [LastModified]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_MSC012_UAT].[dbo].[PAT] PAT
INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_MSC012_UAT].[dbo].[SITE] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_MSC012_UAT].[dbo].[G_DM8] DM8_CRF ON DM8_CRF.PatientID = PAT.PatientId
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=SIT.[Site Information_Site Number]
WHERE (DM8_CRF.[pregnant_current] != '' AND DM8_CRF.[pregnant_current] != 'NO')

UNION

SELECT
	SIT.[Site Information_Site Number] AS [SiteNumber],
	SStatus.[SiteStatus],
	PAT.[Subject Information_subject_id] AS [SubjectID],
	CAST(DMF3_CRF.[Sys. VisitDate] AS date) AS [VisitDate],
	DMF3_CRF.[Sys. VisitCaption] [VisitType],
	DMF3_CRF.[pregnant_current_fu] AS [PregnantCurrent],
	DMF3_CRF.[pregnant_ever_fu] AS [PregnantSince],
	CAST(DMF3_CRF.[LastModified] AS date) AS [LastModified]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_MSC012_UAT].[dbo].[PAT] PAT
INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_MSC012_UAT].[dbo].[SITE] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_MSC012_UAT].[dbo].[G_DMF3] DMF3_CRF ON DMF3_CRF.PatientID = PAT.PatientId
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=SIT.[Site Information_Site Number]
WHERE (DMF3_CRF.[pregnant_ever_fu] != '' AND DMF3_CRF.[pregnant_ever_fu] != 'NO')
	OR (DMF3_CRF.[pregnant_current_fu] != '' AND DMF3_CRF.[pregnant_current_fu] != 'NO')




GO
