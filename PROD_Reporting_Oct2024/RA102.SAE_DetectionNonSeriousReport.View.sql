USE [Reporting]
GO
/****** Object:  View [RA102].[SAE_DetectionNonSeriousReport]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





















/****** SAE_Detection Non Serious Report  ******/
--		use [MERGE_RA_Japan]
--		use [Reimbursement]
--		create schema [Jen]
--		create view [Jen].[] as 
CREATE view [RA102].[SAE_DetectionNonSeriousReport] as 
/****** SAE_Detection Non Serious Report  ******/
--EXEC [MERGE_RA_Japan].[dbo].[ModifyPRO_02ADataForTAEReportToATable];

WITH DP AS
(
	SELECT DISTINCT
		DP.vID
		, DP.SITENUM
		, DP.SUBNUM
		 ,CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
	FROM 
	[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
	LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON DP.vID = VD.vID AND VD.VISNAME = 'FOLLOWUP'
	WHERE DP.VISNAME = 'FOLLOWUP'
),

NSAE AS
(
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,'Other' AS [Event Term]
		,LTRIM(ISNULL(PCLI.[COMOR_OTH_COND_SPECIFY_1], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_COND_MD_1_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_COND_MD_1_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_COND_SPECIFY_1] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,'Other' AS [Event Term]
		,LTRIM(ISNULL(PCLI.[COMOR_OTH_COND_SPECIFY_2], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_COND_MD_2_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_COND_MD_2_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_COND_SPECIFY_2] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,'Other' AS [Event Term]
		,LTRIM(ISNULL(PCLI.[COMOR_OTH_COND_SPECIFY_3], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_COND_MD_3_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_COND_MD_3_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_COND_SPECIFY_3] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,'Other' AS [Event Term]
		,LTRIM(ISNULL(PCLI.[COMOR_OTH_COND_SPECIFY_4], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_COND_MD_4_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_COND_MD_4_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_COND_SPECIFY_4] IS NOT NULL
		
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		 ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_PSORIASIS], 'X', 'Psoriasis without Psoriatic Arthritis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_PSORIASIS_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_PSORIASIS_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_PSORIASIS] IS NOT NULL
			
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		 ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_FIB], 'X', 'Interstitial lungdisease/pulmonary fibrosis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_FIB_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_FIB_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_FIB] IS NOT NULL
			
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		 ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_COPD], 'X', 'Chronic obstructive pulmonary disorder(COPD)'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_COPD_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_COPD_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_COPD] IS NOT NULL
			
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		 ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_ASTHMA], 'X', 'Asthma'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_ASTHMA_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_ASTHMA_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_ASTHMA] IS NOT NULL
			
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		 ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_DIABETES], 'X', 'Diabetes mellitus'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_DIABETES_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_DIABETES_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_DIABETES] IS NOT NULL
			
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		 ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_OSTEOPOROSIS], 'X', 'Osteoporosis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OSTEOPOROSIS_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OSTEOPOROSIS_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OSTEOPOROSIS] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cardio' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_HTN], 'X', 'Hypertension'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_HTN_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_HTN_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_HTN] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cardio' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_HLD], 'X', 'Hyperlipidemia'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_HLD_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_HLD_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_HLD] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cardio' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_COR_ART_DIS], 'X', 'Coronary artery disease'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_COR_ART_DIS_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_COR_ART_DIS_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_COR_ART_DIS] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cardio' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_PEF_ART_DIS], 'X', 'Peripheral arterial disease'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_PEF_ART_DIS_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_PEF_ART_DIS_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_PEF_ART_DIS] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cardio' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_CAROTID], 'X', 'Carotid artery disease'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_CAROTID_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_CAROTID_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_CAROTID] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cardio' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_PEF_VAS_DIS], 'X', 'Peripheral Vascular disease'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_PEF_VAS_DIS_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_PEF_VAS_DIS_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_PEF_VAS_DIS] IS NOT NULL
		
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cancer' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_PREMALIGNANCY], 'X', PCLI.[COMOR_PREMALIGNANCY_SPECIFY]), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_PREMALIGNANCY_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_PREMALIGNANCY_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_PREMALIGNANCY] IS NOT NULL
		
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cancer' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_OTHER_CV], 'X', PCLI.[COMOR_OTHER_CV_SPECIFY]), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTHER_CV_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTHER_CV_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTHER_CV] IS NOT NULL 
				
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cancer' AS [Event Type]
	  ,'Other' AS [Event Term]
	  ,LTRIM(ISNULL(PCLI.[COMOR_OTH_CANCER_SPECIFY_1], '')) AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_CANCER_MD_1_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_CANCER_MD_1_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_CANCER_SPECIFY1] = 'X'
				
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cancer' AS [Event Type]
	  ,'Other' AS [Event Term]
	  ,LTRIM(ISNULL(PCLI.[COMOR_OTH_CANCER_SPECIFY_2], '')) AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_CANCER_MD_2_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_CANCER_MD_2_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_CANCER_SPECIFY2] = 'X'
					
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Cancer' AS [Event Type]
	  ,'Other' AS [Event Term]
	  ,LTRIM(ISNULL(PCLI.[COMOR_OTH_CANCER_SPECIFY_3], '')) AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_OTH_CANCER_MD_3_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_OTH_CANCER_MD_3_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_OTH_CANCER_SPECIFY3] = 'X'
			
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Gastro' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_IBD], 'X', 'Inflammatory bowel disease'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_IBD_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_IBD_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_IBD] IS NOT NULL 
				
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Gastro' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_ULCER], 'X', 'Peptic ulcer'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_ULCER_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_ULCER_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_ULCER] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Neuro' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_FM], 'X', 'Fibromyalgia'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_FM_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_FM_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_FM] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Neuro' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_DEPRESSION], 'X', 'Depression'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_DEPRESSION_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_DEPRESSION_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
	  PCLI.[COMOR_DEPRESSION] IS NOT NULL
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Hyper' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_DRUG_IND_SLE], 'X', 'Drug-induced Lupus SLE'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_DRUG_IND_SLE_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_DRUG_IND_SLE_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_DRUG_IND_SLE] IS NOT NULL AND PCLI.[BIO_REACTION_DEGREE] = 1
	
	UNION

	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Hyper' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PCLI.[COMOR_BIO_REACTION], 'X', 'Drug-induced hypersensitivity reaction'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PCLI.[ONSET_BIO_REACTION_MD_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PCLI.[ONSET_BIO_REACTION_MD_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PCLI.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH,3,CONVERT(DATETIME, PCLI.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
	  DP DP
	  INNER JOIN [MERGE_RA_Japan].[staging].[PRO_CLI] PCLI ON DP.vID = PCLI.vID
	WHERE
		PCLI.[COMOR_BIO_REACTION] IS NOT NULL AND PCLI.[BIO_REACTION_DEGREE] = 1
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_JOINT_BURSA], 'X', 'Joint/bursa'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_JOINT_BURSA_CODE_1]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),PRO02A.[INF_JOINT_BURSA_CODE_2]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),PRO02A.[INF_JOINT_BURSA_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_JOINT_BURSA_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_JOINT_BURSA_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_JOINT_BURSA] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_CELLULITIS], 'X', 'Cellulitis/skin'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_CELLULITIS_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_CELLULITIS_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_CELLULITIS_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_CELLULITIS_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(', ' +CONVERT(VARCHAR(4),PRO02A.[INF_CELLULITIS_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_CELLULITIS] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_SINUSITIS], 'X', 'Sinusitis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_SINUSITIS_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_SINUSITIS_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_SINUSITIS_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_SINUSITIS_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_SINUSITIS_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_SINUSITIS] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_DIV], 'X', 'Diverticulitis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_DIV_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_DIV_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_DIV_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_DIV_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_DIV_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_DIV] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_SEPSIS], 'X', 'Sepsis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_SEPSIS_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_SEPSIS_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_SEPSIS_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_SEPSIS_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_SEPSIS_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_SEPSIS] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_PNEUMONIA] , 'X', 'Pneumonia'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_PNEUMONIA_CODE_1]),'')
	  		+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_PNEUMONIA_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_PNEUMONIA_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_PNEUMONIA_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_PNEUMONIA_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_PNEUMONIA] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_BRONCH], 'X', 'Bronchitis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_BRONCH_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A. INF_BRONCH_CODE_2),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A. INF_BRONCH_CODE_3),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_BRONCH_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_BRONCH_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_BRONCH] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_GASTRO], 'X', 'Gastroenteritis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_GASTRO_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_GASTRO_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_GASTRO_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_GASTRO_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_GASTRO_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_GASTRO] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_MENING], 'X', 'Meningitis/encephalitis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_MENING_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_MENING_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_MENING_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_MENING_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_MENING_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_MENING] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_UTI], 'X', 'Urinary tract infection'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_UTI_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_UTI_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_UTI_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_MENING_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_UTI_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_UTI] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_URI], 'X', 'Upper Respiratory Infection'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_URI_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_URI_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_URI_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_URI_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_URI_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_URI] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_TB], 'X', 'Tuberculosis (TB)'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_TB_CODE_1]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_TB_CODE_2]),'')
			+ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_TB_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(', ' +CONVERT(VARCHAR(2),PRO02A.[INF_TB_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(', ' +CONVERT(VARCHAR(4),PRO02A.[INF_TB_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE
		PRO02A.[INF_TB] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Inf' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO02A.[INF_OTHER] , 'X', 'Other'), '')) AS [Event Term]
	  ,PRO02A.[INF_OTHER_SPECIFY] AS [Specified Other]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_OTHER_CODE_1]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),PRO02A.[INF_OTHER_CODE_2]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),PRO02A.[INF_OTHER_CODE_3]),'')) AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO02A.[INF_OTHER_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO02A.[INF_OTHER_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO02A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[Jen].[PRO_02A_SAE] PRO02A ON DP.vID = PRO02A.vID
	WHERE PRO02A.[INF_OTHER] = 'X'
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Fractures' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO01A.[FRACTURES_WRIST], 'X', 'Wrist'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO01A.[FRACTURES_WRIST_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO01A.[FRACTURES_WRIST_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO01A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO01A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_01A] PRO01A ON DP.vID = PRO01A.vID
	WHERE
		PRO01A.[FRACTURES_WRIST] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Fractures' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO01A.[FRACTURES_HIP], 'X', 'Hip'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO01A.[FRACTURES_HIP_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO01A.[FRACTURES_HIP_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO01A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO01A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_01A] PRO01A ON DP.vID = PRO01A.vID
	WHERE
		PRO01A.[FRACTURES_HIP] IS NOT NULL
		
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Fractures' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO01A.[FRACTURES_SPINE], 'X', 'Spine'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO01A.[FRACTURES_SPINE_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO01A.[FRACTURES_SPINE_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO01A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO01A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_01A] PRO01A ON DP.vID = PRO01A.vID
	WHERE
		PRO01A.[FRACTURES_SPINE] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Fractures' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO01A.[FRACTURES_RIB], 'X', 'Rib'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO01A.[FRACTURES_RIB_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO01A.[FRACTURES_RIB_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO01A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO01A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_01A] PRO01A ON DP.vID = PRO01A.vID
	WHERE
		PRO01A.[FRACTURES_RIB] IS NOT NULL
		
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Fractures' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO01A.[FRACTURES_PELVIS], 'X', 'Pelvis'), '')) AS [Event Term]
	  ,'' AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO01A.[FRACTURES_PELVIS_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO01A.[FRACTURES_PELVIS_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO01A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO01A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_01A] PRO01A ON DP.vID = PRO01A.vID
	WHERE
		PRO01A.[FRACTURES_PELVIS] IS NOT NULL
	
	UNION
	
	SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,DP.[Visit Date]
	  ,'Fractures' AS [Event Type]
	  ,LTRIM(ISNULL(REPLACE(PRO01A.[FRACTURES_OTHER] , 'X', 'Other'), '')) AS [Event Term]
	  ,PRO01A.[FRACTURES_OTHER_SPECIFY] AS [Specified Other]
	  ,'' AS [Pathogen Code]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(2),PRO01A.[FRACTURES_OTHER_DT_MO]), '')) AS [Month of Onset]
	  ,LTRIM(ISNULL(CONVERT(VARCHAR(4),PRO01A.[FRACTURES_OTHER_DT_YR]), '')) AS [Year of Onset]
	  ,ISNULL(PRO01A.[DATALMBY], '') AS [Last Page Updated - User]
	  ,DATEADD(HH, 3, CONVERT(DATETIME, PRO01A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		DP DP
		INNER JOIN [MERGE_RA_Japan].[staging].[PRO_01A] PRO01A ON DP.vID = PRO01A.vID
	WHERE
		PRO01A.[FRACTURES_OTHER] = 'X'

)

SELECT
	N.[vID]
	, N.[Site ID]
	, N.[Subject ID]
	, N.[Visit Date]
	, N.[Event Type] as [Event Type]
	, CASE WHEN N.[Event Term] IS NULL THEN ''
			WHEN LEFT(N.[Event Term],1) = ',' THEN LTRIM(RIGHT(N.[Event Term], LEN(N.[Event Term])-1))
			ELSE N.[Event Term]
	  END AS [Event Term]
	, CASE WHEN N.[Specified Other] IS NULL THEN ''
			WHEN LEFT(N.[Specified Other],1) = ',' THEN LTRIM(RIGHT(N.[Specified Other], LEN(N.[Specified Other])-1))
			ELSE N.[Specified Other]
	   END AS [Specified Other]
	,   CASE WHEN N.[Pathogen Code] IS NULL THEN ''
			WHEN LEFT(N.[Pathogen Code],1) = ',' THEN LTRIM(RIGHT(N.[Pathogen Code], LEN(N.[Pathogen Code])-1))
			ELSE N.[Pathogen Code]
	   END AS [Pathogen Code]   
	,  CASE WHEN N.[Month of Onset] IS NULL THEN ''
			WHEN LEFT(N.[Month of Onset],1) = ',' THEN LTRIM(RIGHT(N.[Month of Onset], LEN(N.[Month of Onset])-1))
			ELSE N.[Month of Onset]
	   END AS [Month of Onset]
	,  CASE WHEN N.[Year of Onset] IS NULL THEN ''
			WHEN LEFT(N.[Year of Onset],1) = ',' THEN LTRIM(RIGHT(N.[Year of Onset], LEN(N.[Year of Onset])-1))
			ELSE N.[Year of Onset]
	   END AS [Year of Onset]
	, N.[Last Page Updated - User]
	, N.[Last Page Updated - Date]
FROM
NSAE N







GO
