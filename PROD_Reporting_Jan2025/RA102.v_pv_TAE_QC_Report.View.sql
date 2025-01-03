USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_TAE_QC_Report]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










/****** TAE QC Report  ******/
--		use [MERGE_RA_Japan]
--		use [Reimbursement]
--		create schema [Jen]
--		create view [Jen].[] as 


CREATE view [RA102].[v_pv_TAE_QC_Report] as
/****** TAE QC Report  ******/


WITH VDEF AS 
(
	SELECT 
		*
		, [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) pgnm 
	FROM [MERGE_RA_Japan].[dbo].[DES_VDEF]
),

LASTPG AS 
(
             SELECT [REVNUM]
					,[VISITID]
					, pgnm
					, min(PORDER) minPORDER
              FROM VDEF
             GROUP BY [REVNUM],[VISITID], pgnm
),

VDwPage1s as 
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
),

TAEPAGE AS
(
	SELECT DISTINCT
		VD.[REVNUM],
		VD.[PAGENAME], 
		VD.[POBJNAME],
		(CASE 
			 WHEN VD.[PAGENAME] LIKE '%INFECTION %' THEN 'INF'
			 WHEN VD.[PAGENAME] LIKE 'CVD-%' OR VD.[PAGENAME] LIKE '%Cardiac%' 
				  OR VD.[PAGENAME] LIKE '% cardiovascular %' THEN 'CVD'
			 WHEN VD.[PAGENAME] LIKE '%Serious Infection%' THEN 'INF'
			 WHEN VD.[PAGENAME] LIKE '%Cancer%' OR VD.[PAGENAME] LIKE '%Malignancy%' THEN 'CM'
			 WHEN VD.[PAGENAME] LIKE '%Severe%' OR VD.[PAGENAME] LIKE '% REACTION %' THEN 'ANA'
			 WHEN VD.[PAGENAME] LIKE '%Serious Bleeding%' OR VD.[PAGENAME] LIKE '%Serious hemorrhage%' THEN 'SSB'
			 WHEN VD.[PAGENAME] LIKE '%Hepatic%' THEN 'HEP'
			 WHEN VD.[PAGENAME] LIKE 'GI%' OR VD.[PAGENAME] LIKE '%Gastro%' THEN 'GI'
			 WHEN VD.[PAGENAME] LIKE '%Neurologic%' THEN 'NEU'
			 WHEN VD.[PAGENAME] LIKE '%General%' OR VD.[PAGENAME] LIKE 'Accident%' 
			   OR VD.[PAGENAME] LIKE 'Inflammatory bowel disease%' 
			   OR VD.[PAGENAME] LIKE 'Other medical diagnosis%' THEN 'GEN'
			 WHEN VD.[PAGENAME] LIKE '%Herpes Zoster%' THEN 'HZ'
			 WHEN VD.[PAGENAME] LIKE '%Preg%' THEN 'PG'
			 ELSE 'UNKNOWN'
		END) AS EVENTYPE,
		LP.[PAGEID] AS [Page1]
	FROM
		VDEF VD
		JOIN VDwPage1s LP ON VD.[REVNUM] = LP.[REVNUM]      
										AND VD.[VISITID] =  LP.[VISITID]
										AND [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](VD.pagename) = LP.[pgnm]
	WHERE 
		POBJNAME IN (
			SELECT DISTINCT
				[POBJNAME]
			FROM 
				[EDC_ETL].[ETLmaps].[MERGE_DES_VDEF]
			WHERE [CorronaRegistryID] = 5 AND ([POBJNAME] LIKE 'pTAE_%' OR [POBJNAME] LIKE 'pPREG_%')
		)
),

ETERM AS
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
SourceCodeValue AS
(
	SELECT DISTINCT
		T.[PAGENAME]
		, T.[REVNUM]
		, T.[REPORTINGT]
		, T.[REPORTINGC]
		, T.[CODELISTNAME]
		, CONVERT(VARCHAR(250),SCV.[CODENAME]) SourceCodeValue
		, CONVERT(VARCHAR(250), EDC_ETL.dbo.udf_StripHTML(SCV.[DISPLAYNAME])) AS [Display]	
	FROM 
		(SELECT DISTINCT 
			  VD.[PAGENAME]
			  , VD.[REVNUM]
			  , PD.[CODELISTNAME]
			  ,[REPORTINGT]
			  ,[REPORTINGC]
		  FROM [MERGE_RA_Japan].[dbo].[DES_PDEF] PD
				INNER JOIN [MERGE_RA_Japan].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
		  WHERE REPORTINGC IN ('AE_OUTCOME', 'REPORT_TYPE','LM_AE_SOURCE_DOCS','LM_AE_SERIOUS', 'PRESC_MEDS_IV', 'REASON_REFUSED', 'AE_DOCS')) T
		  INNER JOIN [MERGE_RA_Japan].[dbo].[DES_CODELIST] SCV 
                   ON SCV.[NAME] = T.[CODELISTNAME]

)
*/
,D AS
(
	SELECT 
		*
		,ROW_NUMBER ()   over (partition by [vID], [PAGEDESC]
											ORDER BY [PAGELMDT] desc) ROWNUM
											
	FROM (										
			SELECT 
				DP.*
				---,TP.Page1
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
		  ) T

)

,L AS
(
		SELECT 
		  DP.[vID]
		  ,DP.[SITENUM]
		  ,DP.[SUBNUM]
		  ,DP.[EVENTYPE]
		  ,DP.[PAGEDESC]
		  ,DP.[Page1] AS [First_page]
		  ,MIN(CONVERT(INT, DP.[STATUSID])) AS [STATUSID]
	 FROM	
			D DP
	 GROUP BY DP.[vID] ,DP.[SITENUM] ,DP.[SUBNUM] ,DP.[EVENTYPE], DP.[PAGEDESC], DP.[Page1]
			
),

/*** Keep the joins within 9 tables to improve the scripts performace****/
UTAEEVENT AS 
(
   SELECT DISTINCT
	  DP.[vID]
	  , CONVERT(INT, DP.[VISITID]) AS [VISITID]
	  , CONVERT(INT, DP.[VISITSEQ]) AS [VISITSEQ]
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,L.[EVENTYPE]
	  ,L.[STATUSID]
  FROM D DP
	INNER JOIN L L ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC AND DP.PAGEID = L.First_page
)

,TAEMAIN AS 
(
       SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,TM.[MD_COD]
	   ,ISNULL(CASE 
		   WHEN L.[EVENTYPE] = 'ANA' THEN TM.[ANA_EVENT_DEC] 
		   WHEN L.[EVENTYPE] = 'CM' THEN TM.[CM_EVENT_DEC] 
		   WHEN L.[EVENTYPE] = 'CVD' THEN TM.[CVD_EVENT_DEC]
		   WHEN L.[EVENTYPE] = 'GEN' THEN TM.[GEN_EVENT]
		   WHEN L.[EVENTYPE] = 'GI' THEN TM.[GI_EVENT_DEC]
		   WHEN L.[EVENTYPE] = 'HEP' THEN TM.[HEP_EVENT_DEC]
		   WHEN L.[EVENTYPE] = 'HZ' THEN TM.[HZ_EVENT]
		   WHEN L.[EVENTYPE] = 'INF' THEN TM.[INF_EVENT_DEC]
		   WHEN L.[EVENTYPE] = 'NEU' THEN TM.[NEU_EVENT_DEC]
		   WHEN L.[EVENTYPE] = 'PG' THEN 'Pregnancy'
		   WHEN L.[EVENTYPE] = 'SSB' THEN TM.[SSB_EVENT_DEC]
		   ELSE 'UNKNOWN'
	   END, '')	AS [Event Term]
	   ,ISNULL(CASE
		   WHEN L.[EVENTYPE] = 'CM' THEN TM.[CM_EVENT_OTHER]
		   WHEN L.[EVENTYPE] = 'PG' THEN ''
		   ELSE TM.[LM_AE_EVENT_SPECIFY]
	   END, '') AS [Event Specify]
	  ,CONVERT(DATE,TM.[LM_AE_DT_EVENT]) AS [Date of Event Onset]
	  ,SUBSTRING(TM.[AE_OUTCOME_DEC], 14, 40) AS [Event Outcome]
	  ,SUBSTRING(TM.[LM_AE_SERIOUS_DEC], 14, 18) AS [Serious outcome]
	  ,SUBSTRING(TM.[PRESC_MEDS_IV_DEC], 14, 18) AS [IV antibiotics_TAE INF]
	  ,SUBSTRING(TM.[REPORT_TYPE_DEC], 14, 40) AS [Report Type]
	  ,ISNULL(TM.[REPORT_NOEVENT_EXP], '') AS [No Event(specify)]
	  ,SUBSTRING(TM.[LM_AE_SOURCE_DOCS_DEC], 14, 40) AS [Supporting documents]
	  ,TM.[LM_AE_SOURCE_DOCS_ATTACH]
	  ,ISNULL(REPLACE(TM.[DOCUMENTS_RECEIVED], 'X', 'YES'), '') AS [Supporting documents received by Corrona?]
	  ,SUBSTRING(TM.[REASON_REFUSED_DEC], 14, 60) AS [Reason if no source provided]
	  ,ISNULL(TM.[REASON_OTHER_TEXT], '') AS [Reason if no source provided = Other, specify]
	  ,TM.[REASON_HOSP_NOT_FAX_Y]
	
  FROM L L
	INNER JOIN D DP ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC
	INNER JOIN [MERGE_RA_Japan].[staging].[TAE_MAIN1] TM ON DP.vID = TM.vID AND DP.PAGEID = TM.PAGEID AND DP.PAGESEQ = TM.PAGESEQ AND DP.[PAGENAME] LIKE '%(1 OF%'

)

,TAEPRE AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , PRE01.[MD_COD]
	  ,SUBSTRING(PRE01.AE_DOCS_DEC, 14, 75) AS [Supporting documents]
	  , CAST(PRE01.[AE_DOCS_ATTACH] AS nvarchar) as [AE_DOCS_ATTACH]
	  , SUBSTRING(PRE01.[REPORT_TYPE_DEC], 14, 75) AS [Report Type]
	  ,REPLACE(DOCUMENTS_RECEIVED, 'X', 'YES') AS [Documents received]
  FROM UTAEEVENT L
	LEFT JOIN D DP ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC
	INNER JOIN [MERGE_RA_Japan].[staging].[PRE_01] PRE01 ON DP.vID = PRE01.vID AND DP.PAGEID = PRE01.PAGEID AND DP.PAGESEQ = PRE01.PAGESEQ AND DP.[PAGENAME] LIKE '%(1 OF%'

)

,TAEEVENT AS
  (SELECT DISTINCT
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,COALESCE(TM.[MD_COD], PRE01.[MD_COD], NULL) AS [Provider ID]
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,ISNULL(L.[EVENTYPE], '') AS [Event Type]
	  ,ISNULL(TM.[Event Term], '')	AS [Event Term]
	  ,ISNULL(TM.[Event Specify], '') AS [Event Specify]
	  ,TM.[Date of Event Onset] AS [Date of Event Onset]
	  ,CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
	  ,ISNULL(TM.[Event Outcome], '') AS [Event Outcome]
	  ,ISNULL(TM.[Serious outcome], '') AS [Serious outcome]
	  ,ISNULL(TM.[IV antibiotics_TAE INF], '') AS [IV antibiotics_TAE INF]
	  ,COALESCE(TM.[Report Type], PRE01.[Report Type],'') AS [Report Type]
	  ,ISNULL(TM.[No Event(specify)], '') AS [No Event(specify)]
	  ,COALESCE(TM.[Supporting documents], PRE01.[Supporting documents]) AS [Supporting documents]
	  ,CASE WHEN ISNULL(PRE01.[AE_DOCS_ATTACH], '')<>'' OR ISNULL(TM.[LM_AE_SOURCE_DOCS_ATTACH], '')<>''
			     THEN 'YES'
			ELSE 'NO'
		END AS [file attached]
	  ,COALESCE(PRE01.[Documents received], TM.[Supporting documents received by Corrona?]) AS [Supporting documents received by Corrona?]
	  ,ISNULL(TM.[Reason if no source provided], '') AS [Reason if no source provided]
	  ,ISNULL(TM.[Reason if no source provided = Other, specify], '') AS [Reason if no source provided = Other, specify]
	  ,ISNULL(TM.[REASON_HOSP_NOT_FAX_Y], '') AS [Hospital would not fax or release documents because]
	  ,ISNULL(CASE WHEN L.[STATUSID] < 10 THEN 'Incomplete'
			ELSE 'Complete'
	   END, '') AS [Form status]

  FROM UTAEEVENT L
	LEFT JOIN D DP ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC
	LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON DP.vID = VD.vID
	LEFT JOIN TAEMAIN TM ON L.vID = TM.vID AND L.PAGEDESC = TM.PAGEDESC
	LEFT JOIN TAEPRE PRE01 ON L.vID = PRE01.vID AND L.PAGEDESC = PRE01.PAGEDESC
	
)

SELECT
	   CAST(TAE.[vID] AS bigint) AS vID
	  ,CAST(TAE.[Site ID] AS int) as [Site ID]
	  ,CAST(TAE.[Provider ID] AS int) AS [Provider ID]
	  ,CAST(TAE.[Subject ID] as bigint) AS [Subject ID]
	  ,TAE.[PAGEDESC]
	  ,TAE.[Event Type]
	  ,CASE WHEN TAE.[Event Type] = 'PG' THEN 'Pregnancy'
	   ELSE COALESCE(TAE.[Event Term], ET.[Display])
	   END AS [Event Term]
	  ,TAE.[Event Specify]
	  ,TAE.[Date of Event Onset]
	  ,TAE.[Visit Date]
	  ,TAE.[Event Outcome]
	  ,TAE.[Serious outcome]
	  ,TAE.[IV antibiotics_TAE INF]
	  ,TAE.[Report Type]
	  ,TAE.[No Event(specify)]
	  ,TAE.[Supporting documents]
	  ,TAE.[file attached]
	  ,TAE.[Supporting documents received by Corrona?]
	  ,TAE.[Reason if no source provided]
	  ,TAE.[Reason if no source provided = Other, specify]
	  ,TAE.[Hospital would not fax or release documents because]
	  ,TAE.[Form status]
	  ,L.[PAGENAME] AS [Last Page Updated – Name]
	  ,DATEADD(HH,3,ISNULL(L.[DATALMDT], L.[PAGELMDT])) AS [Last Page Updated – Date]
	  ,ISNULL(L.[DATALMBY], L.[PAGELMBY]) AS [Last Page Updated – User]
FROM 
	TAEEVENT TAE
    LEFT JOIN ETERM ET ON TAE.[Event Type] = ET.CODE 
---AND CAST(TAE.[Event Term] AS VARCHAR(1500))COLLATE SQL_Latin1_General_CP1_CI_AS= CAST(ET.SourceCodeValue as VARCHAR(1500))COLLATE SQL_Latin1_General_CP1_CI_AS
   LEFT JOIN D L ON L.ROWNUM = 1 AND TAE.vID = L.vID AND L.PAGEDESC = TAE.[PAGEDESC]

---WHERE [Site ID] NOT IN (9997, 9998, 9999)
---ORDER BY [Site ID], [Subject ID]






GO
