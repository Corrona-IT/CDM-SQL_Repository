USE [Reporting]
GO
/****** Object:  View [PSO500].[v_pv_Test]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [PSO500].[v_pv_Test] AS

WITH DOI AS
(
			SELECT --DISTINCT 
			BIOF.[Visit Object Caption], 
			BIOF.[Patient Object PatientNo], 
			[BIOF2_bio_name_fu] AS BioName,
			BIOF.VisitID 
			FROM [OMNICOMM_PSO].[inbound].BIOF BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].CTF CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE [BIOF2_bio_name_fu] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}')

	UNION
			SELECT --DISTINCT 
			BIOF.[Visit Object Caption], 
			BIOF.[Patient Object PatientNo], 
			[BIOF3_bio_name_fu2] AS BioName,
			BIOF.VisitID 
			FROM [OMNICOMM_PSO].[inbound].BIOF BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].CTF CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE [BIOF3_bio_name_fu2]  IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}')

	UNION
			SELECT --DISTINCT 
			BIOF.[Visit Object Caption], 
			BIOF.[Patient Object PatientNo], 
			[BIOF4_bio_name_fu3] AS BioName,
			BIOF.VisitID 
			FROM [OMNICOMM_PSO].[inbound].BIOF BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].CTF CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE [BIOF4_bio_name_fu3]  IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}')

UNION
			SELECT --DISTINCT 
			BIOF.[Visit Object Caption], 
			BIOF.[Patient Object PatientNo], 
			[CTF2_bionb_name_fu] AS BioName,
			BIOF.VisitID 
			FROM [OMNICOMM_PSO].[inbound].BIOF BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].CTF CTF ON CTF.[VisitID]=BIOF.[VisitID]										 		
			WHERE [CTF2_bionb_name_fu] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}')		 
		
UNION
			SELECT --DISTINCT 
			BIOF.[Visit Object Caption], 
			BIOF.[Patient Object PatientNo], 
			[CTF3_bionb_name_fu2] AS BioName,
			BIOF.VisitID 
			FROM [OMNICOMM_PSO].[inbound].BIOF BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].CTF CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE [CTF3_bionb_name_fu2] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}') 

UNION
			SELECT --DISTINCT 
			BIOF.[Visit Object Caption], 
			BIOF.[Patient Object PatientNo], 
			[CTF4_bionb_name_fu3] AS BioName,
			BIOF.VisitID 
			FROM [OMNICOMM_PSO].[inbound].BIOF BIOF
			LEFT JOIN [OMNICOMM_PSO].[inbound].CTF CTF ON CTF.[VisitID]=BIOF.[VisitID]										 
			WHERE [CTF4_bionb_name_fu3] IN ('tildrakizumab {Ilumya}','brodalumab {Siliq}') 
)

,DOI2 AS
(
SELECT VisitID, 
       [dbo].[GetDOIByVisitID](VisitID) AS BioName
FROM DOI
GROUP BY VisitID
)

,NSAES AS
(SELECT 
	SIT.[Site Number] AS [SiteNumber],
	PAT.[Subject Information_subject_id]  AS [SubjectID],
	CF2F.[VisitID] AS [VisitID],
	CAST(CF2F.[Visit Object VisitDate] AS date) AS [VisitDate],
	CF2F.[Visit Object Caption] AS [VisitName],
	CF2F.[CF2F_comor_fu] AS [ClinFeatInf],
	CF2F.[CF2F_comor_other_fu] AS [SpecifiedOther],
	CF2F.[CF2F_onset_md_fu] AS [OnsetDate],
	CF2F.[Form Object LastChange] AS [LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[PAT] PAT
INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF2_CF2F] CF2F ON CF2F.PatientID = PAT.PatientID
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF2] CF2 ON CF2.VisitID = CF2F.VisitID
WHERE CF2F.[CF2F_comor_fu] != ''
AND CF2F.[CF2F_comor_fu] NOT LIKE '%TAE%' 
AND CF2.[CF3F_onset_bioreaction_type_fu] NOT LIKE '%TAE%'

UNION

Select 
	SIT.[Site Number] AS [SiteNumber],
	PAT.[Subject Information_subject_id]  AS [SubjectID],
	IN2F.[VisitID] AS [VisitID],
	CAST(IN2F.[Visit Object VisitDate] AS date) AS [VisitDate],
	IN2F.[Visit Object Caption] AS [VisitName],
	IN2F.[IN2F_inf_type_fu] AS [ClinFeatInf],
	IN2F.[IN2F_inf_other_specify_fu] AS [SpecifiedOther],
	IN2F.[IN2F_inf_mo] AS [OnsetDate],
	IN2F.[Form Object LastChange] AS [LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[PAT] PAT
INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT ON SIT.SiteID = PAT.SiteID
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[IN2_IN2F] IN2F ON IN2F.PatientID = PAT.PatientID
WHERE IN2F.[IN2F_inf_type_fu] != ''
AND IN2F.[IN2F_ser_inf_fu] IS NULL
AND IN2F.[IN2F_iv_fu] IS NULL
)

SELECT

	NSAES.[SiteNumber],
	SStatus.[SiteStatus],
	NSAES.[SubjectID],
	NSAES.[VisitDate],
	NSAES.[VisitName],
	NSAES.[ClinFeatInf],
	NSAES.[SpecifiedOther],
	NSAES.[OnsetDate],
    DOI2.BioName AS [DOIAtVisit],
	CAST(NSAES.[LastModDate] AS date) AS [LastModDate]
FROM NSAES
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=NSAES.[SiteNumber]
LEFT JOIN DOI2 ON DOI2.[VisitID]=NSAES.[VisitID]
WHERE SubjectID='45031070247'

--ORDER BY SiteNumber, SubjectID, VisitDate





GO
