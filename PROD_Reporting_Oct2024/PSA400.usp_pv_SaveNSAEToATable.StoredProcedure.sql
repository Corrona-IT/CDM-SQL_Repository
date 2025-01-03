USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_pv_SaveNSAEToATable]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		J. LING
-- Create date: 2/18/2017
-- Modified 20170718 GF
-- Description:	Reach SSRS time limitation. 
-- Save the report to a table to avoid the problem.
-- =============================================
CREATE PROCEDURE [PSA400].[usp_pv_SaveNSAEToATable]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* this is the old method 
IF OBJECT_ID('[MERGE_SpA].[Jen].[NSAE_Test]') IS NOT NULL DROP TABLE [MERGE_SpA].[Jen].[NSAE_Test]

SELECT
	 *
     INTO [MERGE_SpA].[Jen].[NSAE_Test]
  FROM [MERGE_SpA].[Jen].[xOLD_SAE_DetectionNonSeriousReport]
*/
 
 -- 20170718 THIS IS THE NEW METHOD

 IF OBJECT_ID('tempdb..#SourceCodeValue') IS NOT NULL DROP TABLE #SourceCodeValue

	SELECT DISTINCT
		T.[PAGENAME]
		, T.[REVNUM]
		, T.[REPORTINGT]
		, T.[REPORTINGC]
		, T.[CODELISTNAME]
		, CONVERT(VARCHAR(20),SCV.[CODENAME]) SourceCodeValue
		, CONVERT(VARCHAR(20), EDC_ETL.dbo.udf_StripHTML(SCV.[DISPLAYNAME])) AS [Display]	
	into #SourceCodeValue
	FROM 
		(SELECT DISTINCT 
			  VD.[PAGENAME]
			  , VD.[REVNUM]
			  , PD.[CODELISTNAME]
			  ,[REPORTINGT]
			  ,[REPORTINGC]
		  FROM [MERGE_SPA].[dbo].[DES_PDEF] PD
				INNER JOIN [MERGE_SPA].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
		  WHERE REPORTINGC IN ('COMOR_BIO_SM_REACTION')) T
		  INNER JOIN [MERGE_SPA].[dbo].[DES_CODELIST] SCV 
                    on SCV.[NAME] = T.[CODELISTNAME]



IF OBJECT_ID('tempdb..#DP') IS NOT NULL DROP TABLE #DP
	SELECT DISTINCT
		DP.vID
		, DP.PAGENAME
		, DP.REVNUM
		, DP.SITENUM
		, DP.SUBNUM
		, DP.VISNAME
		 ,CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
	into #DP
	FROM 
	[MERGE_SPA].[staging].[DAT_PAGS] DP
	LEFT JOIN [MERGE_SPA].[staging].[VS_01] VD ON DP.vID = VD.vID
	WHERE DP.VISNAME LIKE 'Follow Up Visit%'


	
IF OBJECT_ID('[Reporting].[PSA400].[t_pv_SAEDetectionNonSerious]') IS NOT NULL DROP TABLE [Reporting].[PSA400].[t_pv_SAEDetectionNonSerious]
SELECT
	N.[vID]
	, N.[Site ID]
	, N.[Subject ID]
	, N.[Visit Date]
	, N.[Event Type] as [Event Type]
	, [Event Term]
	, [Specified Other]
	, [Pathogen Code]   
	, [Day of Onset]
	, [Month of Onset]
	, [Year of Onset]
	, N.[Last Page Updated - User]
	, N.[Last Page Updated - Date]
into [Reporting].[PSA400].[t_pv_SAEDetectionNonSerious]
FROM (
/*** Other COMOR other events from version 1 ***/

	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,CONVERT(VARCHAR(255),'Other') AS [Event Term]
		,LTRIM(ISNULL(EP03C.[COMOR_OTH_COND_SPECIFY], '')) AS [Specified Other]
		,CONVERT(VARCHAR(255), '') AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03C.[ONSET_OTH_COND_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03C.[ONSET_OTH_COND_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP03C.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_OTH_COND] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_DEPRESSION], 'X', 'Depression'), '')) AS [Event Term]
	    ,'' AS [Specified Other]
	    ,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03C.[ONSET_DEPRESSION_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03C.[ONSET_DEPRESSION_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP03C.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_DEPRESSION] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_DIABETES], 'X', 'Diabetes mellitus'), '')) AS [Event Term]
	    ,'' AS [Specified Other]
	    ,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03C.[ONSET_DIABETES_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03C.[ONSET_DIABETES_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP03C.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_DIABETES] = 'X'


	UNION
	
	/*** Other COMOR other events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,'Other' AS [Event Term]
		,LTRIM(ISNULL(FPRO02.[COMOR_OTH_COND_SPECIFY], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH_COND_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH_COND_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_OTH_COND_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_OTH_COND] IS NOT NULL

	UNION
	--ADD by JL
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,'Other' AS [Event Term]
		,LTRIM(ISNULL(FPRO02.[COMOR_OTH1_COND_SPECIFY], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH1_COND_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH1_COND_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_OTH1_COND_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_OTH1_COND] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_DIABETES], 'X', 'Diabetes mellitus'), ''))  AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DIABETES_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DIABETES_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_DIABETES_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_DIABETES] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_PROSTATITIS], 'X', 'Prostatitis'), ''))  AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PROSTATITIS_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PROSTATITIS_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_PROSTATITIS_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_PROSTATITIS] IS NOT NULL
	
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_IRITIS], 'X', 'Iritis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_IRITIS_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_IRITIS_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_IRITIS_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_IRITIS] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_PERIOD_DZ], 'X', 'Periodontal disease'), ''))  AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PERIOD_DZ_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PERIOD_DZ_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_PERIOD_DZ_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_PERIOD_DZ] IS NOT NULL
	--Cannot be found - JL
	--UNION
	
	--SELECT 
	--	DP.[vID]
	--	,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	--	,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	--	,DP.[Visit Date]
	--	,'Other' AS [Event Type]
	--	,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_METAB_SYN], 'X', 'Metabolic syndrome'), ''))  AS [Event Term]
	--	,'' AS [Specified Other]
	--	,'' AS [Pathogen Code]
	--	,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_METAB_SYN_MD_DY]), '')) AS [Day of Onset]
	--	,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_METAB_SYN_MD_MO]), '')) AS [Month of Onset]
	--	,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_METAB_SYN_MD_YR]), '')) AS [Year of Onset]
	--	,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
	--	,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	--FROM 
	--	#DP DP
	--	INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	--WHERE
	--	FPRO02.[COMOR_METAB_SYN] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_DEPRESSION], 'X', 'Depression'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DEPRESSION_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DEPRESSION_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_DEPRESSION_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_DEPRESSION] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Other' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_ANXIETY], 'X', 'Anxiety'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ANXIETY_MD_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ANXIETY_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_ANXIETY_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_ANXIETY] IS NOT NULL
	
	UNION
	
	/*** Fracture events from version 1 ***/
		SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02A.[FRACTURES_WRIST], 'X', 'Wrist'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,CONVERT(VARCHAR(2),'') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP02A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02A] EP02A ON DP.vID = EP02A.vID
	WHERE
		EP02A.[FRACTURES_WRIST] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02A.[FRACTURES_HIP], 'X', 'Hip'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,CONVERT(VARCHAR(2),'') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP02A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02A] EP02A ON DP.vID = EP02A.vID
	WHERE
		EP02A.[FRACTURES_HIP] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02A.[FRACTURES_SPINE], 'X', 'Spine'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,CONVERT(VARCHAR(2),'') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP02A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02A] EP02A ON DP.vID = EP02A.vID
	WHERE
		EP02A.[FRACTURES_SPINE] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02A.[FRACTURES_RIB], 'X', 'Rib'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,CONVERT(VARCHAR(2),'') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP02A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02A] EP02A ON DP.vID = EP02A.vID
	WHERE
		EP02A.[FRACTURES_RIB] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02A.[FRACTURES_PELVIS], 'X', 'Pelvis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,CONVERT(VARCHAR(2),'') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP02A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02A] EP02A ON DP.vID = EP02A.vID
	WHERE
		EP02A.[FRACTURES_PELVIS] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02A.[FRACTURES_OTHER], 'X', 'Other'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,CONVERT(VARCHAR(2),'') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP02A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02A] EP02A ON DP.vID = EP02A.vID
	WHERE
		EP02A.[FRACTURES_OTHER] IS NOT NULL
	
	UNION
	
	/*** Fracture events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_WRIST], 'X', 'Wrist'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_WRIST_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_WRIST_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_WRIST_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_WRIST] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_HIP], 'X', 'Hip'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_HIP_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_HIP_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_HIP_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_HIP] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_SPINE], 'X', 'Spine'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_SPINE_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_SPINE_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_SPINE_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_SPINE] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_RIB], 'X', 'Rib'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_RIB_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_RIB_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_RIB_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_RIB] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_PELVIS], 'X', 'Pelvis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_PELVIS_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_PELVIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_PELVIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_PELVIS] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_HIP], 'X', 'Hip'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_HIP_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_HIP_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_HIP_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_HIP] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Fracture' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO04.[FRACTURES_OTHER], 'X', 'Other'), '')) AS [Event Term]
		,LTRIM(ISNULL(FPRO04.[FRACTURES_OTHER_SPECIFY], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_OTHER_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO04.[FRACTURES_OTHER_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO04.[FRACTURES_OTHER_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_04] FPRO04 ON DP.vID = FPRO04.vID
	WHERE
		FPRO04.[FRACTURES_OTHER] IS NOT NULL
		
	UNION
	
	/*** PSA-SPA Specific Clinical Feature events from version 1 ***/
		SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_IRITIS], 'X', 'Iritis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_IRITIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_IRITIS_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_IRITIS] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_UVEITIS], 'X', 'Uveitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_UVEITIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_UVEITIS_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_UVEITIS] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_CROHN], 'X', 'Crohn''s disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_CROHN_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_CROHN_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_CROHN] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_COLITIS], 'X', 'Ulcerative colitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_COLITIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_COLITIS_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_COLITIS] IS NOT NULL			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_POS_IBD], 'X', 'Possible IBD'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_POS_IBD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_POS_IBD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_POS_IBD] IS NOT NULL
				
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_OTHER_IBD], 'X', 'Other IBD'), '')) AS [Event Term]
		,LTRIM(ISNULL(EP02B.[CLIN_FEAT_OTHER_IBD_SPEC], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_OTHER_IBD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_OTHER_IBD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_OTHER_IBD] IS NOT NULL
				
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_FIBROSIS], 'X', 'Apical fibrosis of lung'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSEST_CLIN_FEAT_FIBROSIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSEST_CLIN_FEAT_FIBROSIS_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_FIBROSIS] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_AORTIC_DX], 'X', 'Aortic valve disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_AORTIC_DX_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_AORTIC_DX_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_AORTIC_DX] IS NOT NULL
				
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_OTH_CARD], 'X', 'Other cardiac'), '')) AS [Event Term]
		,LTRIM(ISNULL(EP02B.[CLIN_FEAT_OTH_CARD_SPEC], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_OTH_CARD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_OTH_CARD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_OTH_CARD] IS NOT NULL
	--Added by JL					
	--UNION
	
	--SELECT 
	--	DP.[vID]
	--	,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	--	,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	--	,DP.[Visit Date]
	--	,'PSA-SPA Specific Clinical Feature' AS [Event Type]
	--	,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_INF], 'X', 'Aortic valve disease'), '')) AS [Event Term]
	--	,'' AS [Specified Other]
	--	,'' AS [Pathogen Code]
	--	,CONVERT(VARCHAR(2),'') AS [Day of Onset]
	--	,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_INF_MO]), '')) AS [Month of Onset]
	--	,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_INF_YR]), '')) AS [Year of Onset]
	--	,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
	--	,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	--FROM 
	--	#DP DP
	--	INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	--WHERE
	--	EP02B.[CLIN_FEAT_INF] IS NOT NULL
				
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_INF_UNKN], 'X', 'Antecedent infection'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_INF_UNKN_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_INF_UNKN_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_INF_UNKN] IS NOT NULL
				
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_SALMON], 'X', 'Salmonella'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_SALMON_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_SALMON_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_SALMON] IS NOT NULL
				
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_YERSINIA], 'X', 'Yersinia pestis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_YERSINIA_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_YERSINIA_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_YERSINIA] IS NOT NULL
						
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_CAMPY], 'X', 'Campylobacter'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_CAMPY_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_CAMPY_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_CAMPY] IS NOT NULL
						
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_SHIGELLA], 'X', 'Shigella'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_SHIGELLA_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_SHIGELLA_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_SHIGELLA] IS NOT NULL
						
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_CHLAMYDIA], 'X', 'Chlamydia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_CHLAMYDIA_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_CHLAMYDIA_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_CHLAMYDIA] IS NOT NULL
						
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_OSTEO], 'X', 'Osteoporosis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_OSTEO_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_OSTEO_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_OSTEO] IS NOT NULL
						
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP02B.[CLIN_FEAT_PSORIASIS], 'X', 'Psoriasis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP02B.[ONSET_CLIN_FEAT_PSORIASIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP02B.[ONSET_CLIN_FEAT_PSORIASIS_YR]), '')) AS [Year of Onset]
		,ISNULL(EP02B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP02B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_02B] EP02B ON DP.vID = EP02B.vID
	WHERE
		EP02B.[CLIN_FEAT_PSORIASIS] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_FM], 'X', 'Fibromyalgia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03C.[ONSET_FM_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03C.[ONSET_FM_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(EP03C.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_FM] IS NOT NULL
	
	UNION
	
	/*** OtherPSA-SPA Specific Clinical Feature events from version 2 ***/
	--- JL question no IBD, Other IBD and etc.?
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_UVEITIS], 'X', 'Uveitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_UVEITIS_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_UVEITIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_UVEITIS_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_UVEITIS] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_FIBROSIS], 'X', 'Apical fibrosis of lung'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_FIBROSIS_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_FIBROSIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_FIBROSIS_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_FIBROSIS] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_AORTIC_DX], 'X', 'Aortic valve disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_AORTIC_DX_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_AORTIC_DX_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_AORTIC_DX_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_AORTIC_DX] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_OTHER_CARDIAC], 'X', 'Other cardiac condition'), '')) AS [Event Term]
		,LTRIM(ISNULL(FPRO01.[CLIN_FEAT_OTHER_CARDIAC_SPECIFY], '')) AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_OTHER_CARDIAC_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_OTHER_CARDIAC_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_OTHER_CARDIAC_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_OTHER_CARDIAC] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_PSORIASIS], 'X', 'Psoriasis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_PSORIASIS_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_PSORIASIS_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_PSORIASIS_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_PSORIASIS] IS NOT NULL
		
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_FM], 'X', 'Fibromyalgia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_FM_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_FM_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_FM_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_FM] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'PSA-SPA Specific Clinical Feature' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO01.[CLIN_FEAT_OSTEO], 'X', 'Osteoporosis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_OSTEO_DY]), '')) AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO01.[ONSET_CLIN_FEAT_OSTEO_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO01.[ONSET_CLIN_FEAT_OSTEO_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO01.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO01.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_01] FPRO01 ON DP.vID = FPRO01.vID
	WHERE
		FPRO01.[CLIN_FEAT_OSTEO] IS NOT NULL
	
	UNION
	
	/*** Cardio events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03A.[COMOR_HTN], 'X', 'Hypertension (HTN) (non-serious)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03A.[ONSET_HTN_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03A.[ONSET_HTN_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03A] EP03A ON DP.vID = EP03A.vID
	WHERE
		EP03A.[COMOR_HTN] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03A.[COMOR_HLD], 'X', 'Hyperlipidemia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03A.[ONSET_HLD_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03A.[ONSET_HLD_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03A] EP03A ON DP.vID = EP03A.vID
	WHERE
		EP03A.[COMOR_HLD] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03A.[COMOR_COR_ART_DIS], 'X', 'Coronary artery disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03A.[ONSET_COR_ART_DIS_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03A.[ONSET_COR_ART_DIS_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03A] EP03A ON DP.vID = EP03A.vID
	WHERE
		EP03A.[COMOR_COR_ART_DIS] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03A.[COMOR_CHF_NOHOSP], 'X', 'Congestive Heart Failure (CHF)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03A.[ONSET_CHF_NOHOSP_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03A.[ONSET_CHF_NOHOSP_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03A] EP03A ON DP.vID = EP03A.vID
	WHERE
		EP03A.[COMOR_CHF_NOHOSP] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03B.[COMOR_CAROTID], 'X', 'Carotid artery disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03B.[COMOR_CAROTID_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03B.[COMOR_CAROTID_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03B] EP03B ON DP.vID = EP03B.vID
	WHERE
		EP03B.[COMOR_CAROTID] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03A.[COMOR_OTHER_CV], 'X', 'Other'), '')) AS [Event Term]
		,EP03A.[COMOR_OTHER_CV_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03A.[ONSET_OTHER_CV_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03A.[ONSET_OTHER_CV_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03A.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03A.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03A] EP03A ON DP.vID = EP03A.vID
	WHERE
		EP03A.[COMOR_OTHER_CV_SPECIFY] IS NOT NULL
		
	UNION
	
	/*** Cardio events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_HTN], 'X', 'Hypertension (HTN) (non-serious)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HTN_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HTN_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_HTN_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_HTN] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_HLD], 'X', 'Hyperlipidemia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HLD_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HLD_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_HLD_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_HLD] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_COR_ART_DIS], 'X', 'Coronary artery disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_COR_ART_DIS_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_COR_ART_DIS_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_COR_ART_DIS_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_COR_ART_DIS] IS NOT NULL
		
	UNION
	-- Cannnot find CHF_NOSERIOUS used CHF_NOHOSP instead
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_CHF_NOHOSP], 'X', 'Congestive heart failure (CHF) (non-serious)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_CHF_NOHOSP_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_CHF_NOHOSP_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_CHF_NOHOSP_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_CHF_NOHOSP] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_PEF_ART_DIS] , 'X', 'Peripheral artery disease (stable)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PEF_ART_DIS_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PEF_ART_DIS_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_PEF_ART_DIS_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_PEF_ART_DIS] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_CAROTID], 'X', 'Carotid artery disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_CAROTID_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_CAROTID_MD_MO] ), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_CAROTID_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_CAROTID] IS NOT NULL
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cardio' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_OTHER_CV], 'X', 'Other'), '')) AS [Event Term]
		,FPRO02.[COMOR_OTHER_CV_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTHER_CV_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTHER_CV_MD_MO] ), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_OTHER_CV_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_OTHER_CV_SPECIFY] IS NOT NULL
			
	UNION
	
	/*** Cancer events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cancer' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03B.[COMOR_OTH_CANCER], 'X', 'Other'), '')) AS [Event Term]
		,EP03B.[COMOR_OTH_CANCER_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2),'') AS [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP03B.[ONSET_OTH_CANCER_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP03B.[ONSET_OTH_CANCER_MD_YR]), ''))  AS [Year of Onset]
		,ISNULL(EP03B.[PAGELMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03B] EP03B ON DP.vID = EP03B.vID
	WHERE
		EP03B.[COMOR_OTH_CANCER_SPECIFY] IS NOT NULL
		
	UNION
	
	/*** Cancer events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cancer' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_PRE_MALIG], 'X', 'Pre-malignancy'), '')) AS [Event Term]
		,FPRO02.[COMOR_PRE_MALIG_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PRE_MALIG_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_PRE_MALIG_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_PRE_MALIG_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_PRE_MALIG] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Cancer' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_OTH_CANCER], 'X', 'Other'), '')) AS [Event Term]
		,FPRO02.[COMOR_OTH_CANCER_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH_CANCER_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH_CANCER_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_OTH_CANCER_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_OTH_CANCER_SPECIFY] IS NOT NULL
		
	UNION
	
	/*** Hep events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hep' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_HEPATIC_NOBIOP] , 'X', 'Hepatic event (without biopsy)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_HEPATIC_NOBIOP] IS NOT NULL	
	
	UNION
	
	/*** Hep events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hep' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_HEPATIC_NOBIOP] , 'X', 'Hepatic event (without biopsy)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HEPATIC_NOBIOP_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HEPATIC_NOBIOP_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_HEPATIC_NOBIOP_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_HEPATIC_NOBIOP] IS NOT NULL
			
	UNION
	
	/*** Hemato events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hemato' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03B.[COMOR_HEMORG_NOHOSP] , 'X', 'Hepatic event (without biopsy'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03B.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03B.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03B] EP03B ON DP.vID = EP03B.vID
	WHERE
		EP03B.[COMOR_HEMORG_NOHOSP] IS NOT NULL	
	
	UNION
	
	/*** Hemato events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hemato' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_HEMORG_NOHOSP], 'X', 'Hemorrhage (non-serious bleed)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HEMORG_NOHOSP_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_HEMORG_NOHOSP_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_HEMORG_NOHOSP_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_HEMORG_NOHOSP] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hemato' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_ANEMIA], 'X', 'Anemia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ANEMIA_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ANEMIA_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_ANEMIA_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_ANEMIA] IS NOT NULL
		
	UNION
	
	/*** Neuro events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Neuro' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_DEMYELIN] , 'X', 'Neurologic/demyelinating disease'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), EP03C.[ONSET_DEMYELIN_MD_MO] ) AS [Month of Onset]
		,CONVERT(VARCHAR(4), EP03C.[ONSET_DEMYELIN_MD_YR] ) AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_DEMYELIN] IS NOT NULL	
		
	UNION
	
	/*** Neuro events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Neuro' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_NEU_DISORDER] , 'X', 'Other'), '')) AS [Event Term]
		,FPRO02.[COMOR_NEU_DISORDER_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_NEU_DISORDER_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_NEU_DISORDER_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_NEU_DISORDER_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_NEU_DISORDER_SPECIFY] IS NOT NULL
				
	UNION
	
	/*** Gastro events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Gastro' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_ULCER] , 'X', 'Peptic ulcer'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_ULCER] IS NOT NULL	
	
	UNION
	
	/*** Gastro events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Gastro' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_ULCER], 'X', 'Peptic ulcer'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ULCER_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ULCER_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_ULCER_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_ULCER] IS NOT NULL
		
	UNION
	-- No OTHER_GI_DISORDER use OTH_GI_DISORDER instead - JL
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Gastro' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_OTH_GI_DISORDER], 'X', 'Other Gi event'), '')) AS [Event Term]
		,FPRO02.[COMOR_OTH_GI_DISORDER_SPECIFY] AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH_GI_DISORDER_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_OTH_GI_DISORDER_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_OTH_GI_DISORDER_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_OTH_GI_DISORDER] IS NOT NULL
			
	UNION
	
	/*** Hyper & Autoimmune events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hyper & Autoimmune' AS [Event Type]
		,'Drug-induced hypersensitivity reaction-Mild/Moderate' AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
		LEFT JOIN #SourceCodeValue PC ON DP.[PAGENAME] = PC.[PAGENAME] AND DP.[REVNUM] = PC.[REVNUM] AND PC.[REPORTINGC] = 'COMOR_BIO_SM_REACTION' AND CONVERT(VARCHAR(20),EP03C.[COMOR_BIO_SM_REACTION]) = PC.[SourceCodeValue]
	WHERE
		PC.[Display] = 'Mild/Moderate'
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hyper & Autoimmune' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_DRUG_IND_SLE] , 'X', 'Drug-induced systemic lupus erythematosus'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_DRUG_IND_SLE] IS NOT NULL	
	
	UNION
	
	/*** Hyper & Autoimmune events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hyper & Autoimmune' AS [Event Type]
		,'Drug-induced hypersensitivity reaction-Mild/Moderate' AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_BIO_SM_REACTION_MD_DY] ), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_BIO_SM_REACTION_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_BIO_SM_REACTION_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
		LEFT JOIN #SourceCodeValue PC ON DP.[PAGENAME] = PC.[PAGENAME] AND DP.[REVNUM] = PC.[REVNUM] AND PC.[REPORTINGC] = 'COMOR_BIO_SM_REACTION' AND CONVERT(VARCHAR(20),FPRO02.[COMOR_BIO_SM_REACTION]) = PC.[SourceCodeValue]
	WHERE
		PC.[Display] = 'Mild/Moderate'
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hyper & Autoimmune' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_DRUG_IND_SLE], 'X', 'Drug-induced systemic lupus erythematosus'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DRUG_IND_SLE_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DRUG_IND_SLE_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_DRUG_IND_SLE_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_DRUG_IND_SLE] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Hyper & Autoimmune' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_DRUG_IND_PSO], 'X', 'Drug-induced psoriasis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DRUG_IND_PSO_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_DRUG_IND_PSO_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_DRUG_IND_PSO_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_DRUG_IND_PSO] IS NOT NULL
	
	UNION
	
	/*** Respiratory events from version 1 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Respiratory' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_FIB] , 'X', 'Interstitial lung disease/pulmonary fibrosis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), EP03C.[ONSET_FIB_MO]) AS [Month of Onset]
		,CONVERT(VARCHAR(4), EP03C.[ONSET_FIB_YR]) AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_FIB] IS NOT NULL	
	
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Respiratory' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_ASTHMA] , 'X', 'Asthma'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_ASTHMA] IS NOT NULL	
			
	UNION
		
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Respiratory' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP03C.[COMOR_COPD] , 'X', 'Chronic obstructive pulmonary disease (COPD)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,CONVERT(VARCHAR(2), '') AS [Month of Onset]
		,CONVERT(VARCHAR(4), '') AS [Year of Onset]
		,ISNULL(EP03C.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP03C.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[EP_03C] EP03C ON DP.vID = EP03C.vID
	WHERE
		EP03C.[COMOR_COPD] IS NOT NULL
	
	UNION
	
	/*** Respiratory events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Respiratory' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_FIB], 'X', 'Interstitial lung disease/pulmonary fibrosis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_FIB_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_FIB_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_FIB_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_FIB] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Respiratory' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_ASTHMA], 'X', 'Asthma'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ASTHMA_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_ASTHMA_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_ASTHMA_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_ASTHMA] IS NOT NULL
							
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Respiratory' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO02.[COMOR_COPD], 'X', 'Chronic obstructive pulmonary disease (COPD)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,'' AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_COPD_MD_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO02.[ONSET_COPD_MD_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO02.[ONSET_COPD_MD_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO02.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO02.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[staging].[FPRO_02] FPRO02 ON DP.vID = FPRO02.vID
	WHERE
		FPRO02.[COMOR_COPD] IS NOT NULL
	
	UNION
	
	/*** Inf events from version 1 ***/
	--Missing from Spec? -JL
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_JOINT_BURSA] , 'X', 'Joint/Bursa'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_JOINT_BURSA_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_JOINT_BURSA_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_JOINT_BURSA_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_JOINT_BURSA] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_CELLULITIS] , 'X', 'Cellulitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_CELLULITIS_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_CELLULITIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_CELLULITIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_CELLULITIS] IS NOT NULL	
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_SINUSITIS] , 'X', 'Sinusitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_SINUSITIS_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_SINUSITIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_SINUSITIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_SINUSITIS] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_DIV] , 'X', 'Diverticulitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_DIV_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_DIV_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_DIV_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_DIV] IS NOT NULL	
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_SEPSIS] , 'X', 'Sepsis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_SEPSIS_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_SEPSIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_SEPSIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_SEPSIS] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_PNEUMONIA] , 'X', 'Pneumonia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_PNEUMONIA_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_PNEUMONIA_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_PNEUMONIA_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_PNEUMONIA] IS NOT NULL	
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_BRONCH] , 'X', 'Bronchitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_BRONCH_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_BRONCH_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_BRONCH_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_BRONCH] IS NOT NULL
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_GASTRO] , 'X', 'Gastroenteritis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_GASTRO_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_GASTRO_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_GASTRO_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_GASTRO] IS NOT NULL	
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_MENING] , 'X', 'Meningitis/encephalitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_MENING_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_MENING_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_MENING_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_MENING] IS NOT NULL
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_UTI] , 'X', 'Urinary tract infection (UTI)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_UTI_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_UTI_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_UTI_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_UTI] IS NOT NULL	
		
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_URI] , 'X', 'Upper respiratory infection (URI)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_URI_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_URI_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_URI_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_URI] IS NOT NULL	
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_TB] , 'X', 'Tuberculosis (TB)'), '')) AS [Event Term]
		,EP04.[INF_TB_SPECIFY] AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_TB_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_TB_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_TB_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_TB] IS NOT NULL	
	
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(EP04.[INF_OTHER] , 'X', 'Other infection'), '')) AS [Event Term]
		,LTRIM(ISNULL(EP04.[INF_OTHER_SPECIFY], '')) AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),EP04.[INF_OTHER_CODE_DEC]),'')) AS [Pathogen Code]
		,CONVERT(VARCHAR(2), '') [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),EP04.[INF_OTHER_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),EP04.[INF_OTHER_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(EP04.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, EP04.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[EP_04_SAE] EP04 ON DP.vID = EP04.vID
	WHERE
		EP04.[INF_OTHER] IS NOT NULL	
				
	UNION
	
	/*** INF events from version 2 ***/
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_JOINT_BURSA], 'X', 'Joint/Bursa'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_JOINT_BURSA_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_JOINT_BURSA_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_JOINT_BURSA_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_JOINT_BURSA_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_JOINT_BURSA_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_JOINT_BURSA_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_JOINT_BURSA] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_CELLULITIS], 'X', 'Cellulitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_CELLULITIS_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_CELLULITIS_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_CELLULITIS_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_CELLULITIS_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_CELLULITIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_CELLULITIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_CELLULITIS] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_SINUSITIS], 'X', 'Sinusitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_SINUSITIS_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_SINUSITIS_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_SINUSITIS_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_SINUSITIS_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_SINUSITIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_SINUSITIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_SINUSITIS] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_CANDIDA], 'X', 'Candida'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_CANDIDA_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_CANDIDA_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_CANDIDA_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_CANDIDA_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_CANDIDA_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_CANDIDA_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_CANDIDA] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_DIV], 'X', 'Diveticulitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_DIV_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_DIV_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_DIV_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_DIV_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_DIV_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_DIV_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_DIV] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_SEPSIS], 'X', 'Sepsis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_SEPSIS_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_SEPSIS_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_SEPSIS_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_SEPSIS_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_SEPSIS_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_SEPSIS_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_SEPSIS] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_PNEUMONIA], 'X', 'Pneumonia'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_PNEUMONIA_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_PNEUMONIA_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_PNEUMONIA_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_PNEUMONIA_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_PNEUMONIA_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_PNEUMONIA_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_PNEUMONIA] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_BRONCH], 'X', 'Bronchitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_BRONCH_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_BRONCH_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_BRONCH_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_BRONCH_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_BRONCH_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_BRONCH_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_BRONCH] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_GASTRO], 'X', 'Gastroenteritis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_GASTRO_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_GASTRO_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_GASTRO_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_GASTRO_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_GASTRO_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_GASTRO_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_GASTRO] IS NOT NULL
			
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_MENING], 'X', 'Meningitis/encephalitis'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_MENING_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_MENING_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_MENING_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_MENING_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_MENING_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_MENING_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_MENING] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_UTI], 'X', 'Urinary tract infection (UTI)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_UTI_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_UTI_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_UTI_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_UTI_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_UTI_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_UTI_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_UTI] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_URI], 'X', 'Upper respiratory infection (URI)'), '')) AS [Event Term]
		,'' AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_URI_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_URI_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_URI_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_URI_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_URI_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_URI_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_URI] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_TB], 'X', 'Tuberculosis (TB)'), '')) AS [Event Term]
		,FPRO03.[INF_TB_SPECIFY] AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_TB_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_TB_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_TB_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_TB_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_TB_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_TB_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_TB] IS NOT NULL
					
	UNION
	
	SELECT 
		DP.[vID]
		,ISNULL(DP.[SITENUM], '') AS [Site ID] 
		,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
		,DP.[Visit Date]
		,'Inf' AS [Event Type]
		,LTRIM(ISNULL(REPLACE(FPRO03.[INF_OTHER], 'X', 'Other infection'), '')) AS [Event Term]
		,LTRIM(ISNULL(FPRO03.[INF_OTHER_SPECIFY], '')) AS [Specified Other]
		,LTRIM(ISNULL(CONVERT(VARCHAR(50),FPRO03.[INF_OTHER_CODE_1_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_OTHER_CODE_2_DEC]),'')
			+ISNULL(', '+CONVERT(VARCHAR(2),FPRO03.[INF_OTHER_CODE_3_DEC]),'')) AS [Pathogen Code]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_OTHER_DT_DY]), '')) [Day of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(2),FPRO03.[INF_OTHER_DT_MO]), '')) AS [Month of Onset]
		,LTRIM(ISNULL(CONVERT(VARCHAR(4),FPRO03.[INF_OTHER_DT_YR]), '')) AS [Year of Onset]
		,ISNULL(FPRO03.[DATALMBY], '') AS [Last Page Updated - User]
		,DATEADD(HH,3,CONVERT(DATETIME, FPRO03.[PAGELMDT])) AS [Last Page Updated - Date]
	FROM 
		#DP DP
		INNER JOIN [MERGE_SPA].[Jen].[FPRO_03_SAE] FPRO03 ON DP.vID = FPRO03.vID
	WHERE
		FPRO03.[INF_OTHER] IS NOT NULL
) n
  
END


GO
