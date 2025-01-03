USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_TAEDetectionPregnancyReport]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/****** SAE Detection Pregnancy Report  ******/


CREATE view [RA102].[v_pv_TAEDetectionPregnancyReport] as 
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
		  FROM [MERGE_RA_Japan].[dbo].[DES_PDEF] PD
				INNER JOIN [MERGE_RA_Japan].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
		  WHERE REPORTINGC IN ('PREGNANT_SINCE_LAST','PREGNANT_CURRENT','PREGNANT_EVER')) T
		  INNER JOIN [MERGE_RA_Japan].[dbo].[DES_CODELIST] SCV 
                    on SCV.[NAME] = T.[CODELISTNAME]
)

SELECT DISTINCT
  DP.[vID]
  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
  ,CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
  ,DP.VISNAME
  --,ISNULL(CASE WHEN PRE01.[STATUSID] < 10 THEN 'Incomplete'
		--ELSE 'Complete'
		-- END, '') AS [Form status]
  ,ISNULL(PRL.[Display], '') AS [Pregnant Since ]
  ,ISNULL(PC.[Display], '') AS [Currently Pregnant?]
  ,ISNULL(SUB03.PAGENAME, '') AS [Last Page Updated – Name]
  ,CONVERT(DATETIME, DATEADD(HH,3,SUB03.[PAGELMDT])) AS [Last Page Updated – Date]
  ,ISNULL(SUB03.PAGELMBY, '') AS [Last Page Updated – User]
FROM 
  [MERGE_RA_Japan].[staging].[DAT_PAGS] DP
  INNER JOIN [MERGE_RA_Japan].[staging].[SUB_03] SUB03 ON DP.vID = SUB03.vID AND DP.PAGEID = SUB03.PAGEID AND DP.PAGESEQ = SUB03.PAGESEQ
  LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON DP.vID = VD.vID
  LEFT JOIN [SourceCodeValue] PRL ON  SUB03.[PAGENAME] = PRL.[PAGENAME] AND DP.[REVNUM] = PRL.[REVNUM] AND PRL.[REPORTINGC] = 'PREGNANT_SINCE_LAST' 
										AND CONVERT(VARCHAR(20),SUB03.[PREGNANT_CURRENT]) = PRL.[SourceCodeValue] AND DP.VISNAME = 'FOLLOWUP'
  LEFT JOIN [SourceCodeValue] PC ON SUB03.[PAGENAME] = PC.[PAGENAME] AND DP.[REVNUM] = PC.[REVNUM] AND PC.[REPORTINGC] = 'PREGNANT_CURRENT' 
										AND CONVERT(VARCHAR(20),SUB03.[PREGNANT_CURRENT]) = PC.[SourceCodeValue]
WHERE 
	(SUB03.[PREGNANT_CURRENT] = 1 
			OR SUB03.[PREGNANT_SINCE_LAST] = 1)


GO
