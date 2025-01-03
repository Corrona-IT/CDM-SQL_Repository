USE [Reporting]
GO
/****** Object:  View [PSA400].[v_pv_SAE_DetectionPregnancyReport]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [PSA400].[v_pv_SAE_DetectionPregnancyReport] as 
/****** SAE Detection Pregnancy Report  ******/
WITH SourceCodeValue AS 
(
	SELECT DISTINCT
		T.[PAGENAME]
		, T.[REVNUM]
		, T.[REPORTINGT]
		, T.[REPORTINGC]
		, T.[CODELISTNAME]
		, CONVERT(VARCHAR(20),SCV.[CODENAME]) SourceCodeValue
		, CONVERT(VARCHAR(20), EDC_ETL.dbo.udf_StripHTML(SCV.[DISPLAYNAME])) AS [Display]	
	FROM 
		(SELECT DISTINCT 
			  VD.[PAGENAME]
			  , VD.[REVNUM]
			  , PD.[CODELISTNAME]
			  ,[REPORTINGT]
			  ,[REPORTINGC]
		  FROM [MERGE_SpA].[dbo].[DES_PDEF] PD
				INNER JOIN [MERGE_SpA].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
		  WHERE REPORTINGC IN ('PREGNANT_SINCE','PREGNANT_CURRENT')) T
		  INNER JOIN [MERGE_SpA].[dbo].[DES_CODELIST] SCV 
                    on SCV.[NAME] = T.[CODELISTNAME]
)

SELECT DISTINCT
  [vID]
  ,ISNULL([SITENUM], '') AS [Site ID] 
  ,ISNULL([SUBNUM], '') AS [Subject ID]
  ,CONVERT(DATE,[VISITDATE]) AS [Visit Date]
  ,[VISNAME]
  ,ISNULL([Pregnant Since], '') AS [Pregnant Since ]
  ,ISNULL([Currently Pregnant?], '') AS [Currently Pregnant?]
  ,ISNULL([PAGENAME], '') AS [Last Page Updated – Name]
  ,CONVERT(DATETIME, DATEADD(HH,3,[PAGELMDT])) AS [Last Page Updated – Date]
  ,ISNULL([PAGELMBY], '') AS [Last Page Updated – User]
FROM 
 (
	/* Version 1-2 OR 2 ENROLLMENT Subject table */
	SELECT DISTINCT
	  DP.[vID]
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,VD.[VISITDATE]
	  ,DP.[VISNAME]
	  ,CONVERT(VARCHAR(20), '') AS [Pregnant Since]
	  ,CONVERT(VARCHAR(20),ISNULL(PC.[Display], '')) AS [Currently Pregnant?]
	  ,SUB01.[PAGENAME]
	  ,SUB01.[PAGELMDT]
	  ,SUB01.[PAGELMBY]
	FROM 
	  [MERGE_SpA].[staging].[DAT_PAGS] DP
	  INNER JOIN [MERGE_SpA].[staging].[ESUB_01] SUB01 ON DP.[vID] = SUB01.[vID] AND DP.[PAGEID] = SUB01.[PAGEID] AND DP.[PAGESEQ] = SUB01.[PAGESEQ]
	  LEFT JOIN [MERGE_SpA].[staging].[VS_01] VD ON DP.[vID] = VD.[vID]
	 LEFT JOIN [SourceCodeValue] PC ON SUB01.[PAGENAME] = PC.[PAGENAME] AND DP.[REVNUM] = PC.[REVNUM] AND PC.[REPORTINGC] = 'PREGNANT_CURRENT' AND CONVERT(VARCHAR(20),SUB01.[PREGNANT_CURRENT]) = PC.[SourceCodeValue]
	WHERE PC.[Display] LIKE 'YES%'
	
	UNION
	
	/* Version 1-2 FOLLOWUP Subject table */
	SELECT DISTINCT
	  DP.[vID]
	  ,DP.[SITENUM]
	  ,DP.[SUBNUM]
	  ,VD.[VISITDATE]
	  ,DP.[VISNAME]
	  ,CONVERT(VARCHAR(20),ISNULL(PRL.[Display], '')) AS [Pregnant Since ]
	  ,CONVERT(VARCHAR(20),ISNULL(PC.[Display], '')) AS [Currently Pregnant?]
	  ,ES01.[PAGENAME]
	  ,ES01.[PAGELMDT]
	  ,ES01.[PAGELMBY]
	FROM 
	  [MERGE_SpA].[staging].[DAT_PAGS] DP
	  INNER JOIN [MERGE_SpA].[staging].[ES_01] ES01 ON DP.[vID] = ES01.[vID] AND DP.[PAGEID] = ES01.[PAGEID] AND DP.[PAGESEQ] = ES01.[PAGESEQ]
	  LEFT JOIN [MERGE_SpA].[staging].[VS_01] VD ON DP.[vID] = VD.[vID]
	  LEFT JOIN [SourceCodeValue] PRL ON ES01.[PAGENAME] = PRL.[PAGENAME] AND DP.[REVNUM] = PRL.[REVNUM] AND PRL.[REPORTINGC] = 'PREGNANT_SINCE' AND CONVERT(VARCHAR(20),ES01.[PREGNANT_SINCE]) = PRL.[SourceCodeValue]
	  LEFT JOIN [SourceCodeValue] PC ON ES01.[PAGENAME] = PC.[PAGENAME] AND DP.[REVNUM] = PC.[REVNUM] AND PC.[REPORTINGC] = 'PREGNANT_CURRENT' AND CONVERT(VARCHAR(20),ES01.[PREGNANT_CURRENT]) = PC.[SourceCodeValue]
	WHERE PRL.[Display] LIKE 'YES%' OR PC.[Display] LIKE 'YES%'
	
	UNION
	
	/* Version 2 FOLLOWUP Subject table */
	
	SELECT DISTINCT
	  DP.[vID]
	  ,DP.[SITENUM]
	  ,DP.[SUBNUM]
	  ,VD.[VISITDATE]
	  ,DP.[VISNAME]
	  ,CONVERT(VARCHAR(20),ISNULL(PRL.[Display], '')) AS [Pregnant Since ]
	  ,CONVERT(VARCHAR(20),ISNULL(PC.[Display], '')) AS [Currently Pregnant?]
	  ,SUB01.[PAGENAME]
	  ,SUB01.[PAGELMDT]
	  ,SUB01.[PAGELMBY]
	FROM 
	  [MERGE_SpA].[staging].[DAT_PAGS] DP
	  INNER JOIN [MERGE_SpA].[staging].[FSUB_01] SUB01 ON DP.[vID] = SUB01.[vID] AND DP.[PAGEID] = SUB01.[PAGEID] AND DP.[PAGESEQ] = SUB01.[PAGESEQ]
	  LEFT JOIN [MERGE_SpA].[staging].[VS_01] VD ON DP.[vID] = VD.[vID]
	  LEFT JOIN [SourceCodeValue] PRL ON SUB01.[PAGENAME] = PRL.[PAGENAME] AND DP.[REVNUM] = PRL.[REVNUM] AND PRL.[REPORTINGC] = 'PREGNANT_SINCE' AND CONVERT(VARCHAR(20),SUB01.[PREGNANT_SINCE]) = PRL.[SourceCodeValue]
	  LEFT JOIN [SourceCodeValue] PC ON SUB01.[PAGENAME] = PC.[PAGENAME] AND DP.[REVNUM] = PC.[REVNUM] AND PC.[REPORTINGC] = 'PREGNANT_CURRENT' AND CONVERT(VARCHAR(20),SUB01.[PREGNANT_CURRENT]) = PC.[SourceCodeValue]
	WHERE PRL.[Display] LIKE 'YES%' OR PC.[Display] LIKE 'YES%'
) AS T



GO
