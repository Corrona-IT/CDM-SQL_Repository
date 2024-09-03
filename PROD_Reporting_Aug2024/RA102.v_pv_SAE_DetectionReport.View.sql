USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_SAE_DetectionReport]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













/****** SAE Detection Report  ******/


CREATE view [RA102].[v_pv_SAE_DetectionReport] as 



WITH VDEF AS 
(
	SELECT 
		*
		, [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) pgnm 
	FROM [MERGE_RA_Japan].[dbo].[DES_VDEF]
)

,LASTPG AS 
(
             SELECT  [REVNUM]
					,[VISITID]
					, pgnm
					, min(PORDER) minPORDER
              FROM VDEF
             GROUP BY [REVNUM],[VISITID], pgnm

)

,VDwPage1s as 
(
	SELECT 
		lp.*
		, vd.PAGEID
		, vd.PAGENAME 
	FROM lastpg lp
	INNER JOIN VDEF VD ON VD.PORDER = LP.minPORDER
							AND VD.[REVNUM] = LP.[REVNUM]      
							AND VD.[VISITID] = LP.[VISITID]
							AND VD.[pgnm] = LP.[pgnm]

)

,AllTAEPAGE AS
(
	SELECT DISTINCT
		VD.[REVNUM],
		VD.[PAGENAME], 
		VD.[POBJNAME],
		LTRIM(RTRIM(
			CASE 
			WHEN VD.[PAGENAME] LIKE 'Cancer-Skin cancer%'
				 THEN SUBSTRING(VD.[PAGENAME], 1,CHARINDEX(')',VD.[PAGENAME])) 
			WHEN CHARINDEX('(',VD.[PAGENAME]) > 0
				 THEN SUBSTRING(VD.[PAGENAME], 1,CHARINDEX('(',VD.[PAGENAME])-1) 
			ELSE VD.[PAGENAME] 
			END)) AS [PAGEDESC],
		LP.[PAGEID] AS [Page1],
		VD.PAGEID
	FROM
		VDEF VD
		JOIN VDwPage1s LP ON VD.[REVNUM] = LP.[REVNUM]      
										AND VD.[VISITID] =  LP.[VISITID]
										AND [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](VD.pagename) = LP.[pgnm]
	WHERE 
		VD.[POBJNAME] IN (
			SELECT DISTINCT
				[POBJNAME]
			FROM 
				[EDC_ETL].[ETLmaps].[MERGE_DES_VDEF]
			WHERE [CorronaRegistryID] = 5 AND ([POBJNAME] LIKE 'pTAE_%' OR [POBJNAME] LIKE 'pPREG_%')
		)

)

,TAEPAGE AS
(
	SELECT DISTINCT
		REVNUM,
		PAGEID,
		PAGENAME, 
		POBJNAME,
		CASE 
			 WHEN PAGENAME LIKE '%INFECTION %' OR PAGENAME LIKE 'Serious Infection-%' THEN 'INF'
			 WHEN PAGENAME LIKE 'CVD-%' OR PAGENAME LIKE '%Cardiac%' 
				  OR PAGENAME LIKE '% cardiovascular %' THEN 'CVD'
			 --WHEN PAGENAME LIKE '%Serious Infection%' THEN 'INF'
			 WHEN PAGENAME LIKE '%Cancer%' OR PAGENAME LIKE '%Malignancy%' THEN 'CM'
			 WHEN PAGENAME LIKE '%Severe%' OR PAGENAME LIKE '% REACTION %' THEN 'ANA'
			 WHEN PAGENAME LIKE '%Serious Bleeding%' OR PAGENAME LIKE '%Serious hemorrhage%' THEN 'SSB'
			 WHEN PAGENAME LIKE '%Hepatic%' THEN 'HEP'
			 WHEN PAGENAME LIKE 'GI%' OR PAGENAME LIKE '%Gastro%' THEN 'GI'
			 WHEN PAGENAME LIKE '%Neurologic%' THEN 'NEU'
			 WHEN PAGENAME LIKE '%General%' OR PAGENAME LIKE 'Accident%' 
			   OR PAGENAME LIKE 'Inflammatory bowel disease%' 
			   OR PAGENAME LIKE 'Other medical diagnosis%' THEN 'GEN'
			 WHEN PAGENAME LIKE '%Herpes Zoster%' THEN 'HZ'
			 WHEN PAGENAME LIKE '%Pregnancy%' THEN 'PG'
			 ELSE 'UNKNOWN'
		END AS EVENTYPE
	FROM
		AllTAEPAGE
	WHERE 
		POBJNAME IN (
			SELECT DISTINCT
				[POBJNAME]
			FROM 
				[EDC_ETL].[ETLmaps].[MERGE_DES_VDEF]
			WHERE [CorronaRegistryID] = 5 AND ([POBJNAME] LIKE 'pTAE_%' OR [POBJNAME] LIKE 'pPREG_%') --- AND Page1 = PAGEID
		)

)

,D AS
(
	SELECT 
		DP.*
		,LTRIM(RTRIM(
			CASE
			WHEN DP.[PAGENAME] LIKE 'Cancer-Skin cancer%'
				 THEN SUBSTRING(DP.[PAGENAME], 1,CHARINDEX(')',DP.[PAGENAME])) 
			WHEN CHARINDEX('(',DP.[PAGENAME]) > 0
				 THEN SUBSTRING(DP.[PAGENAME], 1,CHARINDEX('(',DP.[PAGENAME])-1) 
			ELSE DP.[PAGENAME] 
			END)) AS [PAGEDESC]
		,TP.[EVENTYPE]
	FROM
		[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
		INNER JOIN TAEPAGE TP ON DP.PAGENAME = TP.PAGENAME AND DP.REVNUM = TP.REVNUM

)

,LastPage AS
(
   SELECT 
	* 
	,ROW_NUMBER ()   over (partition by [vID], [PAGEDESC]
											ORDER BY [Last edit date Pg] desc) ROWNUM
   FROM (
	   SELECT DISTINCT
		  DP.[vID]
		  , CONVERT(INT, DP.[VISITID]) AS [VISITID]
		  , CONVERT(INT, DP.[VISITSEQ]) AS [VISITSEQ]
		  ,DP.[SITENUM] 
		  ,DP.[SUBNUM]
		  ,DP.[PAGENAME]
		  ,DP.[STATUSID]
		  ,ISNULL(TP.[PAGEDESC], '') AS [PAGEDESC]
		  ,DATEADD(HH,3,CONVERT(DATETIME,  DP.PAGELMDT)) AS [Last edit date Pg]
		  ,ISNULL(DP.PAGELMBY, '') AS [Pg Last edit by]
		FROM
			[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
		INNER JOIN AllTAEPAGE TP ON DP.PAGENAME = TP.PAGENAME AND DP.REVNUM = TP.REVNUM
		) T
 
 )

,ETERM AS
(
	  SELECT DISTINCT
		(CASE 
		   WHEN PD.[CODELISTNAME] LIKE '%_ANA' THEN 'ANA'
		   WHEN PD.[CODELISTNAME] LIKE '%_ANA_%' THEN 'ANA'
		   WHEN PD.[CODELISTNAME] LIKE '%_CM' THEN 'CM'
		   WHEN PD.[CODELISTNAME] LIKE '%_CM_%' THEN 'CM'
		   WHEN PD.[CODELISTNAME] LIKE '%_CVD' THEN 'CVD'
		   WHEN PD.[CODELISTNAME] LIKE '%_CVD_%' THEN 'CVD'
		   WHEN PD.[CODELISTNAME] LIKE '%_GEN' THEN 'GEN'
		   WHEN PD.[CODELISTNAME] LIKE '%_GEN_%' THEN 'GEN'
		   WHEN PD.[CODELISTNAME] LIKE '%_GIPerforation' THEN 'GI'
		   WHEN PD.[CODELISTNAME] LIKE '%_GIPerforation_%' THEN 'GI'
		   WHEN PD.[CODELISTNAME] LIKE '%_Hepatic' THEN 'HEP'
		   WHEN PD.[CODELISTNAME] LIKE '%_Hepatic_%' THEN 'HEP'
		   WHEN PD.[CODELISTNAME] LIKE '%_HZ' THEN 'HZ'
		   WHEN PD.[CODELISTNAME] LIKE '%_HZ_%' THEN 'HZ'
		   WHEN PD.[CODELISTNAME] LIKE '%_INF' THEN 'INF'
		   WHEN PD.[CODELISTNAME] LIKE '%_INF_%' THEN 'INF'
		   WHEN PD.[CODELISTNAME] LIKE '%_NEU' THEN 'NEU'
		   WHEN PD.[CODELISTNAME] LIKE '%_NEU_%' THEN 'NEU'
		   WHEN PD.[CODELISTNAME] LIKE '%_SeriousHemorrhage' THEN 'SSB'
		   WHEN PD.[CODELISTNAME] LIKE '%_SeriousHemorrhage_%' THEN 'SSB'
		   ELSE 'UNKNOWN'
	   END)	AS [CODE]
		, SCV.[CODENAME] AS [SourceCodeValue]
		, CONVERT(VARCHAR(200), EDC_ETL.dbo.udf_StripHTML(SCV.[DISPLAYNAME])) AS [Display]	
	FROM 
		[MERGE_RA_Japan].[dbo].[DES_PDEF] PD
		INNER JOIN [MERGE_RA_Japan].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
		INNER JOIN [MERGE_RA_Japan].[dbo].[DES_CODELIST] SCV ON SCV.[NAME] = PD.[CODELISTNAME]
	WHERE PD.[CODELISTNAME] LIKE '%_EVENT_%'

)
/*
,SourceCodeValue AS
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
		  WHERE REPORTINGC IN ('AE_OUTCOME', 'REPORT_TYPE','LM_AE_SOURCE_DOCS', 'GENDER')) T
		  INNER JOIN [MERGE_RA_Japan].[dbo].[DES_CODELIST] SCV 
                   ON SCV.[NAME] = T.[CODELISTNAME]
	 	
)
*/
,ASUB AS
(
	SELECT
		A.[SITENUM]
		, A.[SUBID]
		, A.[SUBNUM]
		, SUBSTRING(S.[GENDER_DEC], 2, 25) AS [GENDER_DEC]
		, S.[Ethnicity]
		, A.[REVNUM]
		, T.[IDENT2]		
	FROM
		[MERGE_RA_Japan].[dbo].[DAT_SUB] A
		LEFT JOIN 
		(SELECT
			*
			, row_number() over(partition by [SUBID] order by [LASTMDT] desc) AS ROWNUM
		FROM 
			[MERGE_RA_Japan].[dbo].[DAT_ASUB]
		) T ON ROWNUM = 1 AND A.[SITENUM] = T.[SITENUM] AND A.[SUBNUM] = T.[SUBNUM]
		LEFT JOIN
			(SELECT DISTINCT 
				 [SITENUM]
				 , [SUBNUM]
				 , [GENDER_DEC]
				 ,CASE WHEN [ETH_OTHER] IS NULL AND [ETH_JAPANESE] IS NULL AND
				    [ETH_KOREAN] IS NULL AND [ETH_CHINESE] IS NULL THEN ''
					   WHEN [ETH_OTHER] = 'X' THEN 'Other'
					   WHEN [ETH_CHINESE] = 'X' THEN 'Chinese'
					   WHEN [ETH_JAPANESE] = 'X' THEN 'Japanese'
					   WHEN [ETH_KOREAN] = 'X' THEN 'Korean'
				  ELSE 'Unknown' END AS [Ethnicity]
			 FROM [MERGE_RA_Japan].[dbo].[SUB_01]
			 WHERE [VISNAME] = 'Enrollment'-- AND [SITENUM] NOT IN (9999)
			 ) S ON A.[SITENUM] = S.[SITENUM] AND A.[SUBNUM] = S.[SUBNUM]

)

/*** Keep the joins within 9 tables to improve the scripts performace****/

,UTAEEVENT AS 
(
   SELECT DISTINCT
	  DP.[vID]
	  , CONVERT(INT, DP.[VISITID]) AS [VISITID]
	  , CONVERT(INT, DP.[VISITSEQ]) AS [VISITSEQ]
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,DP.[EVENTYPE]
	  ,DP.[STATUSID]
	  ,DATEADD(HH,3,CONVERT(DATETIME, DP.PAGELMDT)) AS [Last edit date Pg]
	  ,ISNULL(DP.PAGELMBY, '') AS [Pg Last edit by]
  FROM D DP

)

,TAEMAIN AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , TM.[MD_COD]
	   ,ISNULL(CASE 
		   WHEN DP.[EVENTYPE] = 'ANA' THEN TM.[ANA_EVENT_DEC] 
		   WHEN DP.[EVENTYPE] = 'CM' THEN TM.[CM_EVENT_DEC] 
		   WHEN DP.[EVENTYPE] = 'CVD' THEN TM.[CVD_EVENT_DEC]
		   WHEN DP.[EVENTYPE] = 'GEN' THEN TM.[GEN_EVENT]
		   WHEN DP.[EVENTYPE] = 'GI' THEN TM.[GI_EVENT_DEC]
		   WHEN DP.[EVENTYPE] = 'HEP' THEN TM.[HEP_EVENT_DEC]
		   WHEN DP.[EVENTYPE] = 'HZ' THEN TM.[HZ_EVENT]
		   WHEN DP.[EVENTYPE] = 'INF' THEN TM.[INF_EVENT_DEC]
		   WHEN DP.[EVENTYPE] = 'NEU' THEN TM.[NEU_EVENT_DEC]
		   WHEN DP.[EVENTYPE] = 'PG' THEN 'Pregnancy'
		   WHEN DP.[EVENTYPE] = 'SSB' THEN TM.[SSB_EVENT_DEC]
		   ELSE 'UNKNOWN'
	   END, '')	AS [Event Term]
	   ,ISNULL(CASE
		   WHEN DP.[EVENTYPE] = 'CM' THEN TM.[CM_EVENT_OTHER]
		   WHEN DP.[EVENTYPE] = 'PG' THEN ''
		   ELSE TM.[LM_AE_EVENT_SPECIFY]
	   END, '') AS [Event Specify]
	  ,CONVERT(DATE,TM.[LM_AE_DT_EVENT]) AS [Date of Event Onset]
	  ,SUBSTRING(TM.[AE_OUTCOME_DEC], 2, 40) AS [Outcome]
	  ,CASE WHEN SUBSTRING(TM.[AE_OUTCOME_DEC], 2, 40) LIKE '%DEATH%' THEN 'Yes' ELSE 'No' END AS [Death]
	  ,SUBSTRING(TM.[REPORT_TYPE_DEC], 2, 40) AS [Report Type]
	  ,ISNULL(TM.[REPORT_NOEVENT_EXP], '') AS [No Event(specify)]
	  ,SUBSTRING(TM.[LM_AE_SOURCE_DOCS_DEC], 2, 40) AS [S Docs status]
	  ,ISNULL(REPLACE(TM.[LM_AE_HOSP], 'X', 'Yes'), '') AS [Hospitalized]
	
  FROM D DP
	INNER JOIN [MERGE_RA_Japan].[staging].[TAE_MAIN1] TM ON DP.vID = TM.vID AND DP.PAGEID = TM.PAGEID AND DP.PAGESEQ = TM.PAGESEQ AND DP.[PAGENAME] LIKE '%(1 OF%'


)

,TAEPRE AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , PRE01.[MD_COD]
  FROM UTAEEVENT L
	LEFT JOIN D DP ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC
	INNER JOIN [MERGE_RA_Japan].[staging].[PRE_01] PRE01 ON DP.vID = PRE01.vID-- AND DP.PAGEID = PRE01.PAGEID AND DP.PAGESEQ = PRE01.PAGESEQ AND DP.[PAGENAME] LIKE '%(1 OF%'

)


,TAEDRUG AS 
(
  SELECT
	    TDRUG.[vID]
	  , TDRUG.[SUBNUM]
	  , TDRUG.[VISITID]
	  , TDRUG.[VISITSEQ]
	  , DP.[PAGEDESC]
	  --, TDRUG.PAGEID
	  --, TDRUG.PAGENAME
	  ,MAX([AEMED_ORENCIA_ATTRIBUTED]) AS [AEMED_ORENCIA_ATTRIBUTED]
      ,MAX([AEMED_HUMIRA_ATTRIBUTED]) AS [AEMED_HUMIRA_ATTRIBUTED]
      ,MAX([AEMED_CIMZIA_ATTRIBUTED]) AS [AEMED_CIMZIA_ATTRIBUTED]
      ,MAX([AEMED_ENBREL_ATTRIBUTED]) AS [AEMED_ENBREL_ATTRIBUTED]
      ,MAX([AEMED_SIMPONI_ATTRIBUTED]) AS [AEMED_SIMPONI_ATTRIBUTED]
      ,MAX([AEMED_REMICADE_ATTRIBUTED]) AS [AEMED_REMICADE_ATTRIBUTED]
      ,MAX([AEMED_INFXBIOSIM_ATTRIBUTED]) AS [AEMED_INFXBIOSIM_ATTRIBUTED]
      ,MAX([AEMED_ACTEMRA_ATTRIBUTED]) AS [AEMED_ACTEMRA_ATTRIBUTED]
      ,MAX([AEMED_XELJANZ_ATTRIBUTED]) AS [AEMED_XELJANZ_ATTRIBUTED]
      ,MAX([AEMED_BUCILLAMINE_ATTRIBUTED]) AS [AEMED_BUCILLAMINE_ATTRIBUTED]
      ,MAX([AEMED_KEARAMU_ATTRIBUTED]) AS [AEMED_KEARAMU_ATTRIBUTED]
      ,MAX([AEMED_ARAVA_ATTRIBUTED]) AS [AEMED_ARAVA_ATTRIBUTED]
      ,MAX([AEMED_MTX_ATTRIBUTED]) AS [AEMED_MTX_ATTRIBUTED]
      ,MAX([AEMED_PREDNISONE_ATTRIBUTED]) AS [AEMED_PREDNISONE_ATTRIBUTED]
      ,MAX([AEMED_PREDNISOLONE_ATTRIBUTED]) AS [AEMED_PREDNISOLONE_ATTRIBUTED]
      ,MAX([AEMED_SSZ_ATTRIBUTED]) AS [AEMED_SSZ_ATTRIBUTED]
      ,MAX([AEMED_PROGRAF_ATTRIBUTED]) AS [AEMED_PROGRAF_ATTRIBUTED]
      ,MAX([AEMED_DRUGOTHER_ATTRIBUTED]) AS [AEMED_DRUGOTHER_ATTRIBUTED]
	  ,MAX([AEMED_HUMIRA_BIOSIM_ATTRIBUTED]) AS [AEMED_HUMIRA_BIOSIM_ATTRIBUTED]
	  ,MAX([AEMED_HUMIRA_BIOSIM_SPECIFY]) AS [AEMED_HUMIRA_BIOSIM_SPECIFY]
	  ,MAX([AEMED_OLUMIANT_ATTRIBUTED]) AS [AEMED_OLUMIANT_ATTRIBUTED]
	  ,MAX([AEMED_ENBREL_BIOSIM_ATTRIBUTED]) AS [AEMED_ENBREL_BIOSIM_ATTRIBUTED]
	  ,MAX([AEMED_ENBREL_BIOSIM_SPECIFY]) AS [AEMED_ENBREL_BIOSIM_SPECIFY]
	  ,MAX([AEMED_KEVZARA_ATTRIBUTED]) AS [AEMED_KEVZARA_ATTRIBUTED]
	  ,MAX([AEMED_XELJANZ_XR_ATTRIBUTED]) AS [AEMED_XELJANZ_XR_ATTRIBUTED]
	  ,MAX([AEMED_INVEST_AGENT_ATTRIBUTED]) AS [AEMED_INVEST_AGENT_ATTRIBUTED]
	  
  FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] TDRUG
		INNER JOIN AllTAEPAGE ATP ON TDRUG.PAGENAME = ATP.PAGENAME AND TDRUG.PAGEID = ATP.PAGEID
	    INNER JOIN D DP ON DP.vID = TDRUG.vID AND DP.PAGEDESC = ATP.PAGEDESC
  WHERE TDRUG.[DELETED] <> 't'
  GROUP BY      
		TDRUG.[vID]
	  , TDRUG.[SUBNUM]
	  , TDRUG.[VISITID]
	  , TDRUG.[VISITSEQ]
	  , DP.[PAGEDESC] 

)

,TAECONMED AS
(
SELECT
	  DP.[vID]
	  , DP.[SUBNUM]
	  , DP.[VISITID]
	  , DP.[VISITSEQ]
	  , DP.[PAGEDESC]
	  , MAX(CONMED1.[AE_OTHMED1_ATTRIBUTED]) AS [AE_OTHMED1_ATTRIBUTED]
	  , MAX(CONMED2.[AE_OTHMED1_ATTRIBUTED]) AS [AE_OTHMED2_ATTRIBUTED] 
	  , MAX(CONMED3.[AE_OTHMED1_ATTRIBUTED]) AS [AE_OTHMED3_ATTRIBUTED] 
	  , MAX(CONMED1.[AE_OTHMED1_NAME]) AS [AE_OTHMED1_NAME]
	  , MAX(CONMED2.[AE_OTHMED1_NAME]) AS [AE_OTHMED2_NAME]
	  , MAX(CONMED3.[AE_OTHMED1_NAME]) AS [AE_OTHMED3_NAME]
 FROM
	D DP
	INNER JOIN [MERGE_RA_Japan].[staging].[CONMED] CONMED1 ON DP.vID = CONMED1.vID AND DP.PAGEID = CONMED1.PAGEID AND CONMED1.PAGESEQ = 1
	LEFT JOIN [MERGE_RA_Japan].[staging].[CONMED] CONMED2 ON DP.vID = CONMED2.vID AND DP.PAGEID = CONMED2.PAGEID AND CONMED2.PAGESEQ = 2
	LEFT JOIN [MERGE_RA_Japan].[staging].[CONMED] CONMED3 ON DP.vID = CONMED3.vID AND DP.PAGEID = CONMED3.PAGEID AND CONMED3.PAGESEQ = 3
 GROUP BY
	DP.[vID]
	  , DP.[SUBNUM]
	  , DP.[VISITID]
	  , DP.[VISITSEQ]
	  , DP.[PAGEDESC]

)

,TAEMED AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,ISNULL(REPLACE(PRO06.ORENCIA_USETODAY, 'X', 'ORENCIA'), '')
			+ISNULL(REPLACE(PRO06.HUMIRA_USETODAY, 'X', ', HUMIRA'), '')
			+ISNULL(REPLACE(PRO06.HUMIRA_BIOSIM_USETODAY, 'X', ', ADALIMUMAB BIOSIMILAR' + ISNULL(' - ' + PRO06.HUMIRA_BIOSIM_SPECIFY, '')), '')
			+ISNULL(REPLACE(PRO06.CIMZIA_USETODAY, 'X', ', CIMZIA'), '')
			+ISNULL(REPLACE(PRO06.ENBREL_USETODAY, 'X', ', ENBREL'), '')
			+ISNULL(REPLACE(PRO06.ENBREL_BIOSIM_USETODAY, 'X', ', ENTANERCEPT BIOSIMILAR' + ISNULL(' - ' + PRO06.ENBREL_BIOSIM_SPECIFY, '')), '')
			+ISNULL(REPLACE(PRO06.SIMPONI_USETODAY, 'X', ', SIMPONI'), '')
			+ISNULL(REPLACE(PRO06.REMICADE_USETODAY, 'X', ', REMICADE'), '')
			+ISNULL(REPLACE(PRO06.REMICADE_BIOSIM_USETODAY, 'X', ', REMICADE BS'), '')
			+ISNULL(REPLACE(PRO06.ACTEMRA_USETODAY, 'X', ', ACTEMRA'), '')
			+ISNULL(REPLACE(PRO06.XELJANZ_USETODAY, 'X', ', XELJANZ'), '')
			+ISNULL(REPLACE(PRO06.XELJANZ_XR_USETODAY, 'X', ', XELJANZ XR'), '')
			+ISNULL(REPLACE(PRO06.BUC_USETODAY, 'X', ', BUCILLAMINE'), '')
			+ISNULL(REPLACE(PRO06.KEARAMU_USETODAY, 'X', ', KEARAMU'), '')
			+ISNULL(REPLACE(PRO06.ARAVA_USETODAY, 'X', ', ARAVA'), '')
			+ISNULL(REPLACE(PRO06.MTX_USETODAY, 'X', ', MTX'), '')
			+ISNULL(REPLACE(PRO06.PRED_USETODAY, 'X', ', PREDNISONE'), '')
			+ISNULL(REPLACE(PRO06.AZULFIDINE_USETODAY, 'X', ', AZULFIDINE'), '')
			+ISNULL(REPLACE(PRO06.PROGRAF_USETODAY, 'X', ', PROGRAF'), '')
			+ISNULL(REPLACE(PRO06.OLUMIANT_USETODAY, 'X', ', BARICITINIB (OLUMIANT)'), '')
			+ISNULL(REPLACE(PRO06.KEVZARA_USETODAY, 'X', ', SARILUMAB (KEVZARA)'), '')
			+ISNULL(REPLACE(PRO06.OTHER_BIONB_USETODAY, 'X', ', ' + PRO06.OTHER_BIONB_SPECIFY), '') AS [Bio/Sm Mol - Change Today]
	  ,ISNULL(REPLACE(PE4.ORENCIA_USE, 'X', 'ORENCIA'), '')
			+ISNULL(REPLACE(PE4.HUMIRA_USE, 'X', ', HUMIRA'), '')
			+ISNULL(REPLACE(PE4.HUMIRA_BIOSIM_USE, 'X', ', ADALIMUMAB BIOSIMILAR' + ISNULL(' - ' + PE4.HUMIRA_BIOSIM_SPECIFY, '')), '')
			+ISNULL(REPLACE(PE4.CIMZIA_USE, 'X', ', CIMZIA'), '')
			+ISNULL(REPLACE(PE4.ENBREL_USE, 'X', ', ENBREL'), '')
			+ISNULL(REPLACE(PE4.ENBREL_BIOSIM_USE, 'X', ', ENTANERCEPT BIOSIMILAR' + ISNULL(' - ' + PE4.ENBREL_BIOSIM_SPECIFY, '')), '')
			+ISNULL(REPLACE(PE4.SIMPONI_USE, 'X', ', SIMPONI'), '')
			+ISNULL(REPLACE(PE4.REMICADE_USE, 'X', ', REMICADE'), '')
			+ISNULL(REPLACE(PE4.REMICADE_BIOSIM_USE, 'X', ', REMICADE BS'), '')
			+ISNULL(REPLACE(PE4.ACTEMRA_USE, 'X', ', ACTEMRA'), '')
			+ISNULL(REPLACE(PE4.XELJANZ_USE, 'X', ', XELJANZ'), '')
			+ISNULL(REPLACE(PE4.XELJANZ_XR_USE, 'X', ', XELJANZ XR'), '')
			+ISNULL(REPLACE(PE4.OLUMIANT_USE, 'X', ', BARICITINIB (OLUMIANT)'), '')
			+ISNULL(REPLACE(PE4.KEVZARA_USE, 'X', ', SARILUMAB (KEVZARA)'), '')
			+ISNULL(REPLACE(PE4.INVEST_AGENT_USE, 'X', ', INVESTIGATIONAL AGENT'), '')
			+ISNULL(REPLACE(PE4.OTH_BIOTS_USE, 'X', ', ' + PE4.OTH_BIOTS_TEXT), '') AS [Bio/Sm Mol - As of Yesterday]
		, LTRIM(ISNULL(REPLACE(PRO03.[SAE_LIFE_THREAT], 'X', 'Life threatening'), '')
			+ISNULL(REPLACE(PRO03.[SAE_HOSP], 'X', ', Hospitalization'), '')
			+ISNULL(REPLACE(PRO03.[SAE_DISABILITY], 'X', ', Disability or incapacity'), '')
			+ISNULL(REPLACE(PRO03.[SAE_BIRTH_DEFECT], 'X', ', Congenital anomaly or birth defect'), '')
			+ISNULL(REPLACE(PRO03.[SAE_MED_IMPORTANT], 'X', ', A serious, important medical event'), '')) AS [No Event(criteria)]
		, LTRIM(ISNULL(PRO03.[SAE_EVENT1_SPECIFY], '')
			+ISNULL(', ' + PRO03.[SAE_EVENT2_SPECIFY], '')) AS [No Event(specify)]
		 ,ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ORENCIA_ATTRIBUTED], '0'), '1', 'Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_HUMIRA_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_CIMZIA_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ENBREL_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_SIMPONI_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_REMICADE_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_INFXBIOSIM_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ACTEMRA_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_XELJANZ_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_BUCILLAMINE_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_KEARAMU_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ARAVA_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_MTX_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_PREDNISONE_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_PREDNISOLONE_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_SSZ_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_PROGRAF_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_DRUGOTHER_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_HUMIRA_BIOSIM_ATTRIBUTED], '0'), '1', ', Yes'), '') 
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ENBREL_BIOSIM_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_OLUMIANT_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_XELJANZ_XR_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_KEVZARA_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_INVEST_AGENT_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(CONMED.[AE_OTHMED1_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(CONMED.[AE_OTHMED2_ATTRIBUTED], '0'), '1', ', Yes'), '')
			+ISNULL(REPLACE(NULLIF(CONMED.[AE_OTHMED3_ATTRIBUTED], '0'), '1', ', Yes'), '') 
			+ISNULL(REPLACE(NULLIF(CONMED.[AE_OTHMED3_ATTRIBUTED], '0'), '1', ', Yes'), '')
			AS [Attribution to Drug(s) y/n]
		 ,ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ORENCIA_ATTRIBUTED], '0'), '1', 'ORENCIA'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_HUMIRA_ATTRIBUTED], '0'), '1', ', HUMIRA'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_HUMIRA_BIOSIM_ATTRIBUTED], '0'), '1', ', ADALIMUMAB BIOSIMILAR' + ' - ' + ISNULL(TDRUG.AEMED_HUMIRA_BIOSIM_SPECIFY, '')), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_CIMZIA_ATTRIBUTED], '0'), '1', ', CIMZIA'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ENBREL_ATTRIBUTED], '0'), '1', ', ENBREL'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ENBREL_BIOSIM_ATTRIBUTED], '0'), '1', ', ETANERCEPT BIOSIMILAR' + ' - ' + ISNULL(TDRUG.AEMED_ENBREL_BIOSIM_SPECIFY, '')), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_SIMPONI_ATTRIBUTED], '0'), '1', ', SIMPONI'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_REMICADE_ATTRIBUTED], '0'), '1', ', REMICADE'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_INFXBIOSIM_ATTRIBUTED], '0'), '1', ', INFXBIOSIM'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ACTEMRA_ATTRIBUTED], '0'), '1', ', ACTEMRA'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_XELJANZ_ATTRIBUTED], '0'), '1', ', XELJANZ'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_XELJANZ_XR_ATTRIBUTED], '0'), '1', ', XELJANZ XR'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_OLUMIANT_ATTRIBUTED], '0'), '1', ', BARICITINIB (OLUMIANT)'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_KEVZARA_ATTRIBUTED], '0'), '1', ', SARILUMAB (KEVZARA)'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_INVEST_AGENT_ATTRIBUTED], '0'), '1', ', INVESTIGATIONAL AGENT'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_BUCILLAMINE_ATTRIBUTED], '0'), '1', ', BUC'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_KEARAMU_ATTRIBUTED], '0'), '1', ', KEARAMU'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_ARAVA_ATTRIBUTED], '0'), '1', ', ARAVA'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_MTX_ATTRIBUTED], '0'), '1', ', MTX'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_PREDNISONE_ATTRIBUTED], '0'), '1', ', PREDNISONE'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_PREDNISOLONE_ATTRIBUTED], '0'), '1', ', PREDNISOLONE'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_SSZ_ATTRIBUTED], '0'), '1', ', SULFASALAZINE'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_PROGRAF_ATTRIBUTED], '0'), '1', ', PROGRAF'), '')
			+ISNULL(REPLACE(NULLIF(TDRUG.[AEMED_DRUGOTHER_ATTRIBUTED], '0'), '1', ', OTHER DRUG'), '')
			+ISNULL(LTRIM(RTRIM(', ' + CONMED.[AE_OTHMED1_NAME])), '')
			+ISNULL(LTRIM(RTRIM(', ' + CONMED.[AE_OTHMED2_NAME])), '')
			+ISNULL(LTRIM(RTRIM(', ' + CONMED.[AE_OTHMED3_NAME])), '') 
			AS [Attributed drug(s)]
  FROM UTAEEVENT L
	LEFT JOIN D DP ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC
	LEFT JOIN [MERGE_RA_Japan].[staging].[PE_04] PE4 ON DP.vID = PE4.vID
	LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_06] PRO06 ON DP.vID = PRO06.vID
	LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_03] PRO03 ON DP.vID = PRO03.vID
	LEFT JOIN TAEDRUG TDRUG ON DP.vID = TDRUG.vID AND DP.PAGEDESC = TDRUG.PAGEDESC
	LEFT JOIN TAECONMED CONMED ON DP.vID = CONMED.vID AND DP.PAGEDESC = CONMED.PAGEDESC

)

,TAEEVENT AS 
(
  SELECT DISTINCT
	   DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,ISNULL(L.[EVENTYPE], '') AS [Event Type]
	  ,TM.[Event Term]
	  ,TM.[Event Specify]
	  ,TM.[Date of Event Onset]
	  ,TM.[Outcome]
	  ,TM.[Death]
	  ,TM.[Report Type]
	  ,TM.[No Event(specify)]
	  ,TM.[S Docs status]
	  ,TM.[Hospitalized]
	  ,COALESCE(TM.[MD_COD], PRE01.[MD_COD], NULL) AS [Provider ID]
	  ,CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
	  ,DATEDIFF(YEAR, CONVERT(DATE, ISNULL(ASUB.[IDENT2],VD.[VISITDATE])), CONVERT(DATE,VD.[VISITDATE]))AS [Age]
	  ,ISNULL(ASUB.[GENDER_DEC], '') AS [Gender]
	  ,ASUB.[Ethnicity]
	  ,(YEAR(GETDATE()) - PRO01.[YR_ONSET_RA]) AS [RA Disease Duration]
  FROM UTAEEVENT L
	LEFT JOIN D DP ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC
	LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON DP.vID = VD.vID
	LEFT JOIN TAEMAIN TM ON L.vID = TM.vID AND L.PAGEDESC = TM.PAGEDESC
	LEFT JOIN TAEPRE PRE01 ON L.vID = PRE01.vID AND L.PAGEDESC = PRE01.PAGEDESC
	LEFT JOIN ASUB ASUB ON DP.[SITENUM] = ASUB.[SITENUM] AND DP.[SUBNUM] = ASUB.[SUBNUM] AND ASUB.[REVNUM] = DP.[REVNUM]
	LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] PRO01 ON DP.vID = PRO01.vID

)

,TAE AS
(
	SELECT
	  TAE.[vID]
	  ,TAE.[Site ID] 
	  ,TAE.[Subject ID]
	  ,ISNULL(TAE.[Provider ID], '') AS [Provider ID]
	  ,TAE.[PAGEDESC] AS [Page Description]
	  ,TAE.[Event Type]
	  ,COALESCE(ET.[Display], TAE.[Event Term], '')	AS [Event Term]
	  ,ISNULL(TAE.[Event Specify], '' ) AS [Event Specify]
	  ,TAE.[Date of Event Onset]
	  ,TAE.[Visit Date]
	  ,TAE.[Age]
	  ,TAE.[Gender]
	  ,TAE.[Ethnicity]
	  ,TAE.[RA Disease Duration]
	  ,ISNULL(TAE.[Outcome], '') AS [Outcome]
	  ,ISNULL(TAE.[Death], '') AS [Death]
	  ,ISNULL(TAE.[Report Type], '') AS [Report Type]
	  --,CASE WHEN MED.[No Event(criteria)] IS NULL THEN ''
			--WHEN LEFT(MED.[No Event(criteria)],1) = ',' THEN LTRIM(RIGHT(MED.[No Event(criteria)], LEN(MED.[No Event(criteria)])-1))
			--ELSE MED.[No Event(criteria)]
	  -- END AS [No Event(criteria)]
	  ,CASE WHEN MED.[No Event(specify)] IS NULL THEN ''
			WHEN LEFT(MED.[No Event(specify)],1) = ',' THEN LTRIM(RIGHT(MED.[No Event(specify)], LEN(MED.[No Event(specify)])-1))
			ELSE MED.[No Event(specify)]
	   END AS [No Event(specify)]
	  ,ISNULL(TAE.[S Docs status], '') AS [S Docs status]
	  ,ISNULL(TAE.[Hospitalized], '') AS [Hospitalized]
	  ,CASE WHEN MED.[Bio/Sm Mol - Change Today] IS NULL THEN ''
			WHEN LEFT(MED.[Bio/Sm Mol - Change Today],1) = ',' THEN LTRIM(RIGHT(MED.[Bio/Sm Mol - Change Today], LEN(MED.[Bio/Sm Mol - Change Today])-1))
			ELSE MED.[Bio/Sm Mol - Change Today]
	   END AS [Bio/Sm Mol - Change Today]
	  ,CASE WHEN MED.[Bio/Sm Mol - As of Yesterday] IS NULL THEN ''
			WHEN LEFT(MED.[Bio/Sm Mol - As of Yesterday],1) = ',' THEN LTRIM(RIGHT(MED.[Bio/Sm Mol - As of Yesterday], LEN(MED.[Bio/Sm Mol - As of Yesterday])-1))
			ELSE MED.[Bio/Sm Mol - As of Yesterday]
	   END AS [Bio/Sm Mol - As of Yesterday]
	   	  ,CASE WHEN MED.[Attribution to Drug(s) y/n] IS NULL THEN ''
			WHEN LEFT(MED.[Attribution to Drug(s) y/n],1) = ',' THEN LTRIM(RIGHT(MED.[Attribution to Drug(s) y/n], LEN(MED.[Attribution to Drug(s) y/n])-1))
			ELSE MED.[Attribution to Drug(s) y/n]
	   END AS [Attribution to Drug(s) y/n]
	  ,CASE WHEN MED.[Attributed drug(s)] IS NULL THEN ''
			WHEN LEFT(MED.[Attributed drug(s)],1) = ',' THEN LTRIM(RIGHT(MED.[Attributed drug(s)], LEN(MED.[Attributed drug(s)])-1))
			ELSE MED.[Attributed drug(s)]
	   END AS [Attributed drug(s)]
FROM 
	TAEEVENT TAE
	LEFT JOIN ETERM ET ON TAE.[Event Type] = ET.CODE COLLATE Latin1_General_CS_AS AND TAE.[Event Term] = ET.SourceCodeValue COLLATE Latin1_General_CS_AS
	LEFT JOIN TAEMED MED ON TAE.vID = MED.vID AND TAE.[PAGEDESC] = MED.PAGEDESC
)

SELECT
	 TAE.*
	 ,(CASE WHEN S.[STATUSID] IS NULL THEN ''
			 WHEN S.[STATUSID] < 10 THEN 'Incomplete'
			 WHEN S.[STATUSID] = 0 THEN 'No Data'
		ELSE 'Complete'
	    END) AS [Form status]
	,L.[PAGENAME]  AS [Last Page Updated – Name]
	,L.[Last edit date Pg] AS [Last Page Updated – Date]
	,L.[Pg Last edit by] AS [Last Page Updated – User]
FROM 
	TAE TAE
	LEFT JOIN LastPage L ON L.ROWNUM = 1 AND TAE.vID = L.vID AND L.PAGEDESC = TAE.[Page Description]
	LEFT JOIN (SELECT vID, PAGEDESC, MIN(CONVERT(INT, [STATUSID])) AS [STATUSID] 
			   FROM LastPage
			   GROUP BY vID, PAGEDESC) S ON TAE.vID = S.vID AND S.PAGEDESC = TAE.[Page Description]









GO
