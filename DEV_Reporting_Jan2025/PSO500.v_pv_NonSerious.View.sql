USE [Reporting]
GO
/****** Object:  View [PSO500].[v_pv_NonSerious]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE VIEW [PSO500].[v_pv_NonSerious] AS

WITH DOIATVISIT AS
	(
			SELECT DISTINCT
			BIOF.[VisitId],
			BIOF.[Visit Object Caption] AS [VisitName], 
			BIOF.[Patient Object PatientNo] AS [SubjectID], 
			[BIOF2_bio_name_fu] AS [DOI]
			-- SELECT *
			FROM [OMNICOMM_PSO].[inbound].[BIOF] BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE 
			[BIOF2_bio_name_fu] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}','secukinumab {Cosentyx}','ixekizumab {Taltz}') 
			UNION 
			SELECT DISTINCT 
			BIOF.[VisitId],
			BIOF.[Visit Object Caption] AS [VisitName], 
			BIOF.[Patient Object PatientNo] AS [SubjectID], 
			[BIOF3_bio_name_fu2] AS [DOI]
			FROM [OMNICOMM_PSO].[inbound].[BIOF] BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE 
			[BIOF3_bio_name_fu2] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}','secukinumab {Cosentyx}','ixekizumab {Taltz}') 
			UNION 
			SELECT DISTINCT 
			BIOF.[VisitId],
			BIOF.[Visit Object Caption] AS [VisitName], 
			BIOF.[Patient Object PatientNo] AS [SubjectID], 
			[BIOF4_bio_name_fu3] AS [DOI]
			FROM [OMNICOMM_PSO].[inbound].[BIOF] BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE 
			[BIOF4_bio_name_fu3] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}','secukinumab {Cosentyx}','ixekizumab {Taltz}') 
			UNION 
			SELECT DISTINCT 
			CTF.[VisitId],
			CTF.[Visit Object Caption] AS [VisitName], 
			CTF.[Patient Object PatientNo] AS [SubjectID], 
			[CTF2_bionb_name_fu] AS [DOI] --SELECT *
			FROM [OMNICOMM_PSO].[inbound].[BIOF] BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE 
			[CTF2_bionb_name_fu] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}','secukinumab {Cosentyx}','ixekizumab {Taltz}') 
			UNION 
			SELECT DISTINCT
			CTF.[VisitId],
			CTF.[Visit Object Caption] AS [VisitName], 
			CTF.[Patient Object PatientNo] AS [SubjectID], 
			[CTF3_bionb_name_fu2] AS [DOI]
			FROM [OMNICOMM_PSO].[inbound].[BIOF] BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE 
			[CTF3_bionb_name_fu2] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}','secukinumab {Cosentyx}','ixekizumab {Taltz}') 
			UNION 
			SELECT DISTINCT
			CTF.[VisitId], 
			CTF.[Visit Object Caption] AS [VisitName], 
			CTF.[Patient Object PatientNo] AS [SubjectID], 
			[CTF4_bionb_name_fu3] AS [DOI]
			FROM [OMNICOMM_PSO].[inbound].[BIOF] BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE 
			[CTF4_bionb_name_fu3] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}','secukinumab {Cosentyx}','ixekizumab {Taltz}') 
			)



,NSAES AS
(SELECT 
	SIT.[Site Number] AS [SiteNumber],
	PAT.[subject_id]  AS [SubjectID],
	CF2F.[VisitID] AS [VisitID],
	CAST(CF2F.[Visit Object VisitDate] AS date) AS [VisitDate],
	CF2F.[Visit Object Caption] AS [VisitName],
	CF2F.[CF2F_comor_fu] AS [ClinFeatInf],
	CF2F.[CF2F_comor_other_fu] AS [SpecifiedOther],
	CF2F.[CF2F_onset_md_fu] AS [OnsetDate],
	CF2F.[Form Object LastChange] AS [LastModDate],
	CF2F.ItemInstanceNo
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN OMNICOMM_PSO.[inbound].[CF2_CF2F] CF2F ON CF2F.PatientID = PAT.PatientID
LEFT JOIN OMNICOMM_PSO.[inbound].[CF2] CF2 ON CF2.VisitID = CF2F.VisitID
WHERE CF2F.[CF2F_comor_fu] != ''
AND CF2F.[CF2F_comor_fu] NOT LIKE '%TAE%'
AND CF2F.[CF2F_comor_fu] <> 'Biologic infusion/injection reaction' 
AND CF2F.[CF2F_comor_fu] <> 'Neutropenia'
AND CF2F.[CF2F_comor_fu] <> 'Neutropenia'
AND CF2F.[CF2F_comor_fu] <> 'Neutropenia'

UNION

SELECT 
	SIT.[Site Number] AS [SiteNumber],
	PAT.[subject_id]  AS [SubjectID],
	CF2F.[VisitID] AS [VisitID],
	CAST(CF2F.[Visit Object VisitDate] AS date) AS [VisitDate],
	CF2F.[Visit Object Caption] AS [VisitName],
	CF2F.[CF2F_comor_fu] AS [ClinFeatInf],
	CF2F.[CF2F_comor_other_fu] AS [SpecifiedOther],
	CF2F.[CF2F_onset_md_fu] AS [OnsetDate],
	CF2F.[Form Object LastChange] AS [LastModDate],
	CF2F.ItemInstanceNo
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN OMNICOMM_PSO.[inbound].[CF2_CF2F] CF2F ON CF2F.PatientID = PAT.PatientID
LEFT JOIN OMNICOMM_PSO.[inbound].[CF2] CF2 ON CF2.VisitID = CF2F.VisitID
WHERE CF2F.[CF2F_comor_fu] != ''
AND CF2F.[CF2F_comor_fu] = 'Biologic infusion/injection reaction'
AND CF2.[CF3F_onset_bioreaction_type_fu] NOT LIKE '%TAE%'

UNION

SELECT 
	SIT.[Site Number] AS [SiteNumber],
	PAT.[subject_id]  AS [SubjectID],
	CF2F.[VisitID] AS [VisitID],
	CAST(CF2F.[Visit Object VisitDate] AS date) AS [VisitDate],
	CF2F.[Visit Object Caption] AS [VisitName],
	CF2F.[CF2F_comor_fu] AS [ClinFeatInf],
	CF2F.[CF2F_comor_other_fu] AS [SpecifiedOther],
	CF2F.[CF2F_onset_md_fu] AS [OnsetDate],
	CF2F.[Form Object LastChange] AS [LastModDate],
	CF2F.ItemInstanceNo
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [OMNICOMM_PSO].[inbound].[CF2_CF2F] CF2F ON CF2F.PatientID = PAT.PatientID
LEFT JOIN [OMNICOMM_PSO].[inbound].[CF2] CF2 ON CF2.VisitID = CF2F.VisitID
WHERE CF2F.[CF2F_comor_fu] != ''
AND CF2F.[CF2F_comor_fu] = 'Neutropenia'
AND CF2F.[CF2F_comor_neutropenia_fu] NOT LIKE '%TAE%'

UNION

SELECT 
	SIT.[Site Number] AS [SiteNumber],
	PAT.[subject_id]  AS [SubjectID],
	IN2F.[VisitID] AS [VisitID],
	CAST(IN2F.[Visit Object VisitDate] AS date) AS [VisitDate],
	IN2F.[Visit Object Caption] AS [VisitName],
	IN2F.[IN2F_inf_type_fu] AS [ClinFeatInf],
	IN2F.[IN2F_inf_other_specify_fu] AS [SpecifiedOther],
	IN2F.[IN2F_inf_mo] AS [OnsetDate],
	IN2F.[Form Object LastChange] AS [LastModDate],
	IN2F.ItemInstanceNo
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [OMNICOMM_PSO].[inbound].[IN2_IN2F] IN2F ON IN2F.PatientID = PAT.PatientID
WHERE IN2F.[IN2F_inf_type_fu] != ''
--AND IN2F.[IN2F_inf_type_fu] != 'COVID-19 (confirmed)'
--AND IN2F.[IN2F_inf_type_fu] != 'COVID-19 (suspected)'
AND IN2F.[IN2F_ser_inf_fu] IS NULL
AND IN2F.[IN2F_iv_fu] IS NULL
)

SELECT

	CAST(NSAES.[SiteNumber] AS int) AS [SiteNumber],
	CASE WHEN NSAES.[SiteNumber] IN ('999','998') THEN 'Active'
	ELSE SStatus.[SiteStatus]
	END AS [SiteStatus],
	NSAES.[SubjectID],
	NSAES.[VisitDate],
	NSAES.[VisitName],
	NSAES.[ClinFeatInf],
	NSAES.[SpecifiedOther],
	NSAES.[OnsetDate],
	NSAES.ItemInstanceNo,

	 STUFF((SELECT ', ' + DOI FROM DOIATVISIT D WHERE D.[VisitID]=NSAES.[VisitID] AND DOI <> '' FOR XML PATH('')),1,1, '') AS [DOIatVisit],
	 CAST(NSAES.[LastModDate] AS date) AS [LastModDate]
FROM NSAES
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=NSAES.[SiteNumber]








GO
