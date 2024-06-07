USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_pv_taeqclisting]    Script Date: 6/6/2024 8:58:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 12Sep2023
-- Description:	Procedure for TAE QC Listing
-- =================================================


CREATE PROCEDURE [PSA400].[usp_pv_taeqclisting] AS
	-- Add the parameters for the stored procedure here
	
/*
exec [PSA400].[usp_PV_TAEQC]
select * from [Reporting].[PSA400].[t_pv_taeqclisting]


CREATE TABLE [PSA400].[t_pv_taeqclisting](
	[vID] [bigint] NOT NULL,
	[Site ID] [bigint] NOT NULL,
	[Subject ID] [nvarchar](50) NOT NULL,
	[Provider ID] [smallint] NULL,
	[PAGEDESC] [nvarchar](255) NOT NULL,
	[Event Type] [nvarchar](255) NOT NULL,
	[Event Term] [nvarchar](50) NULL,
	[OtherEventSpecify] [nvarchar](50) NULL,
	[Date of Event Onset] [date] NULL,
	[Visit Date] [date] NULL,
	[Event Outcome] [nvarchar](33) NULL,
	[Serious outcome] [varchar](16) NULL,
	[In Utero or Neonatal Outcomes] [nvarchar](4000) NULL,
	[IV antibiotics_TAE INF] [nvarchar](50) NULL,
	[Event Confirmation Status/Can you confirm the Event?] [nvarchar](68) NULL,
	[Not an Event (explanation)] [nvarchar](301) NULL,
	[Supporting documents] [nvarchar](28) NULL,
	[file attached] [varchar](3) NOT NULL,
	[Supporting documents received by Corrona?] [nvarchar](4000) NULL,
	[Reason if no supporting documents provided] [varchar](46) NOT NULL,
	[Hospital would not fax or release documents because] [nvarchar](150) NULL,
	[Reason if no source provided = Other, specify] [nvarchar](150) NULL,
	[Form status] [varchar](10) NOT NULL,
	[Last Page Updated – Name] [nvarchar](100) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](200) NULL,

*/


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


TRUNCATE TABLE [Reporting].[PSA400].[t_pv_taeqclisting]


IF OBJECT_ID('tempdb..#VDEF') IS NOT NULL DROP TABLE #VDEF
select * into #VDEF from
--WITH VDEF AS 
(
	SELECT 
		*
		, [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) pgnm 
	FROM [MERGE_SpA].[dbo].[DES_VDEF] WHERE POBJNAME LIKE '%TAE%' OR POBJNAME LIKE '%PEQ%'
) t

IF OBJECT_ID('tempdb..#TAEPAGE') IS NOT NULL DROP TABLE #TAEPAGE

SELECT * 
INTO #TAEPAGE from

(
	
	SELECT DISTINCT
			VD.[REVNUM],
			VD.[VISITID],
			VD.[PORDER],
			VD.[PAGENAME], 
			VD.[POBJNAME],
			VD.[PAGEID],
			ET.[EVENTTYPE],
			ET.[PAGEDESC],
			ET.[FirstPage]
			--FP.[PAGEID] AS [FirstPage]
		FROM
			#VDEF VD
			LEFT JOIN [Reporting].[PSA400].[EventType] ET ON  VD.[REVNUM] = ET.[REVNUM] 
														AND ET.[VISITID] =  VD.[VISITID] 
														AND VD.[POBJNAME] = ET.[POBJNAME] 
														AND ET.[PORDER] = VD.[PORDER]
														--AND VD.[PAGEID]=ET.[FirstPage]
			/*LEFT JOIN #VDEF FP ON ET.[REVNUM] = FP.[REVNUM] 
														AND FP.[VISITID] =  ET.[VISITID] 
														AND ET.[FirstPage] = FP.[PAGEID]
														AND FP.[PORDER]=ET.[PORDER]
														AND FP.[VISITID]=ET.[VISITID]*/

) t



IF OBJECT_ID('tempdb..#SourceCodeValue') IS NOT NULL DROP TABLE #SourceCodeValue
select * into #SourceCodeValue from
--,SourceCodeValue AS
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
		  WHERE REPORTINGC IN ('LM_AE_INTRA','LM_AE_SOURCE_DOCS', 'GENDER', 'RACE_HISPANIC', 'DRUG_NAME')) T
		  INNER JOIN [MERGE_SpA].[dbo].[DES_CODELIST] SCV 
                   ON SCV.[NAME] = T.[CODELISTNAME]
) t

IF OBJECT_ID('tempdb..#D') IS NOT NULL DROP TABLE #D
select * into #D from
--,D AS
(
	SELECT 
		*
		,ROW_NUMBER ()   over (partition by [vID], [PAGEDESC]
											ORDER BY [PAGELMDT] desc) ROWNUM						
	FROM (										
			SELECT 
				DP.*
				,TP.[FirstPage]
				,TP.[PAGEDESC]
				,TP.[EVENTTYPE]
			FROM
				[MERGE_SpA].[staging].[DAT_PAGS] DP
				INNER JOIN #TAEPAGE TP ON DP.PAGENAME = TP.PAGENAME AND DP.REVNUM = TP.REVNUM AND DP.[VISITID] = TP.[VISITID]
		  ) T
) t

IF OBJECT_ID('tempdb..#L') IS NOT NULL DROP TABLE #L
select * into #L from
--,L AS
(
		SELECT 
		  DP.[vID]
		  ,DP.[REVISION]
		  ,DP.[SITENUM]
		  ,DP.[SUBNUM]
		  ,DP.[EVENTTYPE]
		  ,DP.[PAGEDESC]
		  ,DP.[PAGEID]
		  ,DP.[FirstPage] AS [First_page]
		  ,MIN(CONVERT(INT, DP.[STATUSID])) AS [STATUSID]
	 FROM #D DP
	 GROUP BY DP.[vID] , DP.[REVISION], DP.[SITENUM] ,DP.[SUBNUM] ,DP.[EVENTTYPE], DP.[PAGEDESC], DP.[PAGEID], DP.[FirstPage]
			
) t

IF OBJECT_ID('tempdb..#UTAEEVENT') IS NOT NULL DROP TABLE #UTAEEVENT
select * into #UTAEEVENT from
--,UTAEEVENT AS 
(
   SELECT DISTINCT
	  DP.[vID]
	  , DP.[REVNUM]
	  , DP.[REVISION]
	  , CONVERT(INT, DP.[VISITID]) AS [VISITID]
	  , CONVERT(INT, DP.[VISITSEQ]) AS [VISITSEQ]
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,DP.[PAGEID]
	  ,L.[EVENTTYPE]
	  ,MIN(L.[STATUSID]) AS [STATUSID]
  FROM #D DP
	INNER JOIN #L L ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC AND DP.PAGEID = L.First_page
  GROUP BY DP.[vID]
	  , DP.[REVNUM]
	  , DP.[REVISION]
	  , CONVERT(INT, DP.[VISITID])
	  , CONVERT(INT, DP.[VISITSEQ])
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,ISNULL(DP.[PAGEDESC], '')
	  ,DP.PAGEID
	  ,L.[EVENTTYPE]
) t

IF OBJECT_ID('tempdb..#TAED') IS NOT NULL DROP TABLE #TAED
select * into #TAED from
--,TAED AS
(
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , ANA.[LM_EVENT_CONFIRM_DEC]
	  , ANA.[NO_EVENT_EXP_INF] AS [NO_EVENT_EXP]
	  , ANA.[AE_SOURCE_DOCS_DEC]
	  , ANA.[REASON_HOSP_NOT_FAX]
	  , ANA.[REASON_HOSP_NOT_FAX_Y]
	  , ANA.[REASON_REFUSED]
	  , ANA.[REASON_OTHER]
	  , ANA.[REASON_OTHER_EXP]
	  , ANA.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_ANA] ANA ON DP.[vID] = ANA.[vID] AND DP.[PAGEID] = ANA.[PAGEID]-- AND DP.[PAGESEQ] = ANA.[PAGESEQ]
		
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , SSB.LM_EVENT_CONFIRM_DEC
	  , SSB.NO_EVENT_EXP AS [NO_EVENT_EXP]
	  , SSB.AE_SOURCE_DOCS_DEC
	  , SSB.REASON_HOSP_NOT_FAX
	  , SSB.REASON_HOSP_NOT_FAX_Y
	  , SSB.REASON_REFUSED
	  , SSB.REASON_OTHER
	  , SSB.REASON_OTHER_EXP
	  , SSB.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_SSB] SSB ON DP.[vID] = SSB.[vID] AND DP.[PAGEID] = SSB.[PAGEID]	
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , CAN.LM_EVENT_CONFIRM_CAN_DEC
	  , CAN.LM_EVENT_CONFIRM_NO_CAN AS [NO_EVENT_EXP]
	  , CAN.AE_SOURCE_DOCS_DEC
	  , CAN.REASON_HOSP_NOT_FAX_CAN
	  , CAN.REASON_HOSP_NOT_FAX_CAN_Y
	  , CAN.REASON_REFUSED_CAN
	  , CAN.REASON_OTHER_CAN
	  , CAN.REASON_OTHER_CAN_EXP
	  , CAN.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_CAN] CAN ON DP.[vID] = CAN.[vID] AND DP.[PAGEID] = CAN.[PAGEID]	
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , CAR.LM_EVENT_CONFIRM_CVD_DEC
	  , CAR.LM_EVENT_CONFIRM_NO_CAR AS [NO_EVENT_EXP]
	  , CAR.AE_SOURCE_DOCS_DEC
	  , CAR.REASON_HOSP_NOT_FAX_CVD
	  , CAR.REASON_HOSP_NOT_FAX_CVD_Y
	  , CAR.REASON_REFUSED_CVD
	  , CAR.REASON_OTHER_CVD
	  , CAR.REASON_OTHER_CVD_EXP
	  , CAR.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_CAR] CAR ON DP.[vID] = CAR.[vID] AND DP.[PAGEID] = CAR.[PAGEID]	
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , GEN.LM_EVENT_CONFIRM_DEC
	  , GEN.NO_EVENT_EXP+''+GEN.NO_EVENT_EXP_INF AS [NO_EVENT_EXP]
	  , GEN.AE_SOURCE_DOCS_DEC
	  , GEN.REASON_HOSP_NOT_FAX
	  , GEN.REASON_HOSP_NOT_FAX_Y
	  , GEN.REASON_REFUSED
	  , GEN.REASON_OTHER
	  , GEN.REASON_OTHER_EXP
	  , GEN.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_GEN] GEN ON DP.[vID] = GEN.[vID] AND DP.[PAGEID] = GEN.[PAGEID]	
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , HEP.LM_EVENT_CONFIRM_DEC
	  , HEP.NO_EVENT_EXP AS [NO_EVENT_EXP]
	  , HEP.AE_SOURCE_DOCS_DEC
	  , HEP.REASON_HOSP_NOT_FAX
	  , HEP.REASON_HOSP_NOT_FAX_Y
	  , HEP.REASON_REFUSED
	  , HEP.REASON_OTHER
	  , HEP.REASON_OTHER_EXP
	  , HEP.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_HEP] HEP ON DP.[vID] = HEP.[vID] AND DP.[PAGEID] = HEP.[PAGEID]	
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , INF.LM_EVENT_CONFIRM_DEC
	  , INF.NO_EVENT_EXP_INF AS [NO_EVENT_EXP]
	  , INF.AE_SOURCE_DOCS_DEC
	  , INF.REASON_HOSP_NOT_FAX_INF
	  , INF.REASON_HOSP_NOT_FAX_Y
	  , INF.REASON_REFUSED_INF
	  , INF.REASON_OTHER_INF
	  , INF.REASON_OTHER_INF_EXP
	  , INF.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_INF] INF ON DP.[vID] = INF.[vID] AND DP.[PAGEID] = INF.[PAGEID]	
	
	UNION
	
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , NEU.LM_EVENT_CONFIRM_DEC
	  , NEU.NO_EVENT_EXP AS [NO_EVENT_EXP]
	  , NEU.AE_SOURCE_DOCS_DEC
	  , NEU.REASON_HOSP_NOT_FAX
	  , NEU.REASON_HOSP_NOT_FAX_Y
	  , NEU.REASON_REFUSED
	  , NEU.REASON_OTHER
	  , NEU.REASON_OTHER_EXP
	  , NEU.AE_PT_HOSP AS [Hospitalized]
	FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_CONFIRM_NEU] NEU ON DP.[vID] = NEU.[vID] AND DP.[PAGEID] = NEU.[PAGEID]
) t

IF OBJECT_ID('tempdb..#TAEOUTCOME') IS NOT NULL DROP TABLE #TAEOUTCOME
select * into #TAEOUTCOME from
--,TAEOUTCOME AS
(
	SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , TOC.[AE_OUTCOME_DEC]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_OUTCOME] TOC ON DP.[vID] = TOC.[vID] AND DP.[PAGEID] = TOC.[PAGEID] AND DP.[PAGESEQ] = TOC.[PAGESEQ]
) t

IF OBJECT_ID('tempdb..#TAEMAINV1') IS NOT NULL DROP TABLE #TAEMAINV1
select * into #TAEMAINV1 from
--,TAEMAINV1 AS 
(
SELECT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE] AS [EVENTTYPE]
	  , MAX(TT.[EVENT]) AS [Event Term]
	  , MAX(CONVERT(DATE,TT.[LM_AE_DT_EVENT])) AS [Date of Event Onset]
	  , MAX(TOC.[AE_OUTCOME_DEC]) AS [AE_OUTCOME_DEC]
	  , MAX(CONVERT(VARCHAR(5), NULL)) AS [LM_AE_SERIOUS_DEC]
	  , CONVERT(VARCHAR(5), NULL) AS [In Utero or Neonatal Outcomes]
	  --, TIA.[LM_AE_INTRA_DEC]
	  , MAX(TAED.[LM_EVENT_CONFIRM_DEC]) AS [LM_EVENT_CONFIRM_DEC]
	  , MAX(TAED.[NO_EVENT_EXP]) AS [NO_EVENT_EXP]
	  , MAX(TAED.[AE_SOURCE_DOCS_DEC]) AS [AE_SOURCE_DOCS_DEC]
	  , CONVERT(VARCHAR(5), NULL) AS [LM_AE_SOURCE_DOCS_ATTACH]
	  , CONVERT(VARCHAR(5), NULL) AS [DOCUMENTS_RECEIVED]
	  , MAX(TAED.[REASON_HOSP_NOT_FAX]) AS [REASON_HOSP_NOT_FAX]
	  , MAX(TAED.[REASON_HOSP_NOT_FAX_Y]) AS [REASON_HOSP_NOT_FAX_Y]
	  , MAX(TAED.[REASON_REFUSED]) AS [REASON_REFUSED]
	  , MAX(TAED.[REASON_OTHER]) AS [REASON_OTHER]
	  , MAX(TAED.[REASON_OTHER_EXP]) AS [REASON_OTHER_EXP]
	  , MAX(TAED.[Hospitalized]) AS [Hospitalized]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	LEFT JOIN [MERGE_SpA].[staging].[TAE_TOP] TT ON DP.[vID] = TT.[vID] AND DP.[PAGEID] = TT.[PAGEID] AND DP.[PAGESEQ] = TT.[PAGESEQ]
	LEFT JOIN #TAEOUTCOME TOC ON DP.[vID] = TOC.[vID] AND DP.[PAGEDESC] = TOC.[PAGEDESC]
	LEFT JOIN #TAED TAED ON DP.[vID] = TAED.[vID] AND DP.[PAGEDESC] = TAED.[PAGEDESC]
  WHERE NOT EXISTS (SELECT 1 FROM [MERGE_SpA].[staging].[TAE_PAGE_1] WHERE DP.vID = vID AND DP.PAGEID = PAGEID AND DP.PAGESEQ = PAGESEQ)
  GROUP BY DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '')
	  , L.[EVENTTYPE]
) t

IF OBJECT_ID('tempdb..#TAEMAINV2') IS NOT NULL DROP TABLE #TAEMAINV2
select * into #TAEMAINV2 from
--,TAEMAINV2 AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , TP1.MD_COD
	  , L.[EVENTTYPE]
	  , COALESCE(TP1.EVENT_ANA_DEC, TP1.EVENT_CAN_DEC, TP1.EVENT_CVD_DEC, TP1.EVENT_GI_DEC, TP1.EVENT_HEP_DEC, TP1.EVENT_INF_DEC, TP1.EVENT_NEU_DEC, TP1.EVENT_SSB_DEC, TP1.EVENT) AS [Event Term]
  	  , TP1.EVENT_OTH_TXT AS [OtherEventSpecify]
      , CONVERT(DATE,TP1.[LM_AE_DT_EVENT]) AS [Date of Event Onset]
	  , TP1.[AE_OUTCOME_DEC]
	  , (CASE WHEN TP1.[LM_AE_LIFETHREAT] IS NOT NULL THEN 'Life Threatening'
			  WHEN TP1.[LM_AE_DEATH] IS NOT NULL THEN 'Death'
			  WHEN TP1.[LM_AE_DISABILITY] IS NOT NULL THEN 'Disability'
			  WHEN TP1.[LM_AE_BIRTHDEFECT] IS NOT NULL THEN 'Birth Defect'
			  WHEN TP1.[LM_AE_INVEST] IS NOT NULL THEN 'Medical Event'
			  ELSE NULL
		 END) AS [LM_AE_SERIOUS_DEC]
	  , CONVERT(VARCHAR(5), NULL) AS [In Utero or Neonatal Outcomes]
	  --, TIA.[LM_AE_INTRA_DEC]
	  , TP1.[LM_EVENT_CONFIRM_DEC]
	  , TP1.[NO_EVENT_EXP]
	  , TP1.[AE_SOURCE_DOCS_DEC]
	  , TP1.[LM_AE_SOURCE_DOCS_ATTACH]
	  , TP1.[DOCUMENTS_RECEIVED]
	  , TP1.[REASON_HOSP_NOT_FAX]
	  , TP1.[REASON_HOSP_NOT_FAX_Y]
	  , TP1.[REASON_REFUSED]
	  , TP1.[REASON_OTHER]
	  , TP1.[REASON_OTHER_EXP]
	  , DP.[REVISION]
	  , TP1.[LM_AE_HOSP] AS [Hospitalized]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA].[staging].[TAE_PAGE_1] TP1 ON DP.vID = TP1.vID AND DP.PAGEID = TP1.PAGEID AND DP.PAGESEQ = TP1.PAGESEQ
) t

IF OBJECT_ID('tempdb..#TAEPEQ') IS NOT NULL DROP TABLE #TAEPEQ
select * into #TAEPEQ from
--,TAEPEQ AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , CONVERT(VARCHAR(50),NULL) AS [Event Term]
	  , CONVERT(DATE,NULL) AS [Date of Event Onset]
	  , CONVERT(VARCHAR(23), NULL) AS [AE_OUTCOME_DEC]
	  , (CASE WHEN PEQ01.[PO_LIFETHREATENING] IS NOT NULL THEN 'Life Threatening'
			  WHEN PEQ01.[PO_DEATH] IS NOT NULL THEN 'Death'
			  WHEN PEQ01.[PO_DISABILITY] IS NOT NULL THEN 'Disability'
			  WHEN PEQ01.[PO_MEDICAL_EVENT] IS NOT NULL THEN 'Medical Event'
			  ELSE NULL
		 END) AS [LM_AE_SERIOUS_DEC]
	  , LTRIM(ISNULL(REPLACE(PEQ01.[PREG_NEO_MISCARRIAGE], 'X', 'Spontaneous abortion/miscarriage'), '')
			+ISNULL(REPLACE(PEQ01.[PREG_NEO_ELECTIVE_TERMINATION], 'X', ', Elective Termination'), '')
			 +ISNULL(REPLACE(PEQ01.[PREG_NEO_BIRTH_DEFECT], 'X', ', Congenital anomaly/birth defect'), '')
			 +ISNULL(REPLACE(PEQ01.[PREG_NEO_DEATH], 'X', ', Death'), '')) AS [In Utero or Neonatal Outcomes]
	  , CONVERT(VARCHAR(50),NULL) AS [LM_AE_INTRA_DEC]
	  , PEQ01.[PEQ_EVENT_CONFIRM_DEC] AS [LM_EVENT_CONFIRM_DEC]
	  , PEQ01.[PEQ_NO_EVENT_TEXT] AS [NO_EVENT_EXP]
	  , PEQ01.[PEQ_SOURCE_DOCS_DEC] AS [AE_SOURCE_DOCS_DEC]
	  , PEQ01.[LM_AE_SOURCE_DOCS_ATTACH]
	  , PEQ01.[DOCUMENTS_RECEIVED]
	  , PEQ01.[PEQ_REASON_HOSP_NOT_FAX] AS [REASON_HOSP_NOT_FAX]
	  , PEQ01.[PEQ_REASON_HOSP_NOT_FAX_TXT] AS [REASON_HOSP_NOT_FAX_Y]
	  , PEQ01.[PEQ_REASON_REFUSED] AS [REASON_REFUSED]
	  , PEQ01.[PEQ_REASON_OTHER] AS [REASON_OTHER]
	  , PEQ01.[PEQ_REASON_OTHER_EXP] AS [REASON_OTHER_EXP]
	  , PEQ01.[PO_HOSPITALIZATION] AS [Hospitalized]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.vID AND L.PAGEDESC = DP.PAGEDESC --AND L.EVENTTYPE = 'PEQ'
	INNER JOIN [MERGE_SpA].[staging].[TAE_PAGE_1_PEQ] PEQ01 ON DP.vID = PEQ01.vID AND DP.PAGEID = PEQ01.PAGEID AND DP.PAGESEQ = PEQ01.PAGESEQ
) t

IF OBJECT_ID('tempdb..#TIA') IS NOT NULL DROP TABLE #TIA
select * into #TIA from
--,TIA AS 
(
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TIA.[LM_AE_INTRA_DEC]
	  , DP.[REVISION]
  FROM #L L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC] AND L.EVENTTYPE <> 'PEQ' 
	INNER JOIN [MERGE_SpA].[staging].[TAE_INF_A] TIA ON DP.[vID] = TIA.[vID] AND DP.[PAGEID] = TIA.[PAGEID] AND DP.[PAGESEQ] = TIA.[PAGESEQ]
) t

IF OBJECT_ID('tempdb..#TAEEVENT') IS NOT NULL DROP TABLE #TAEEVENT
select * into #TAEEVENT from
--,TAEEVENT AS
  (
	SELECT DISTINCT
	  L.[vID]
	  , ISNULL(L.[SITENUM], '') AS [Site ID] 
	  , ISNULL(L.[SUBNUM], '') AS [Subject ID]
	  , COALESCE(TM2.MD_COD, TT.MD_COD, EPRO01.[MD_COD], EP01A.[MD_COD], EP01.[MD_COD]) AS [Provider ID]
	  , ISNULL(L.[PAGEDESC], '') AS [PAGEDESC]
	  , ISNULL(L.[EVENTTYPE], '') AS [Event Type]
	  , COALESCE(TM1.[Event Term], TM2.[Event Term], PEQ.[Event Term] ) AS [Event Term]
	  , TM2.[OtherEventSpecify]
	  , COALESCE(TM1.[Date of Event Onset], TM2.[Date of Event Onset], PEQ.[Date of Event Onset]) AS [Date of Event Onset]
	  , CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
	  , COALESCE(TM1.[AE_OUTCOME_DEC], TM2.[AE_OUTCOME_DEC], PEQ.[AE_OUTCOME_DEC]) AS [Event Outcome]
	  , COALESCE(TM1.[LM_AE_SERIOUS_DEC], TM2.[LM_AE_SERIOUS_DEC], PEQ.[LM_AE_SERIOUS_DEC]) AS [Seious outcome]
	  , (CASE WHEN PEQ.[In Utero or Neonatal Outcomes] IS NULL THEN ''
			WHEN LEFT(PEQ.[In Utero or Neonatal Outcomes],1) = ',' THEN LTRIM(RIGHT(PEQ.[In Utero or Neonatal Outcomes], LEN(PEQ.[In Utero or Neonatal Outcomes])-2))
			ELSE PEQ.[In Utero or Neonatal Outcomes] 
		END) AS [In Utero or Neonatal Outcomes]
	  , COALESCE(TIA.[LM_AE_INTRA_DEC], PEQ.[LM_AE_INTRA_DEC]) AS [IV antibiotics_TAE INF]
	  , COALESCE(TM1.[LM_EVENT_CONFIRM_DEC], TM2.[LM_EVENT_CONFIRM_DEC], PEQ.[LM_EVENT_CONFIRM_DEC]) AS [Event Confirmation Status/Can you confirm the Event?]
	  , COALESCE(TM1.[NO_EVENT_EXP], TM2.[NO_EVENT_EXP], PEQ.[NO_EVENT_EXP]) AS [Not an Event (explanation)]
	  , COALESCE(TM1.[AE_SOURCE_DOCS_DEC], TM2.[AE_SOURCE_DOCS_DEC], PEQ.[AE_SOURCE_DOCS_DEC]) AS [Supporting documents]
	  , (CASE WHEN COALESCE(TM1.[LM_AE_SOURCE_DOCS_ATTACH], TM2.[LM_AE_SOURCE_DOCS_ATTACH], PEQ.[LM_AE_SOURCE_DOCS_ATTACH]) IS NOT NULL
			     THEN 'YES'
			ELSE 'NO'
		 END) AS [file attached]
	  , REPLACE(COALESCE(TM1.[DOCUMENTS_RECEIVED],TM2.[DOCUMENTS_RECEIVED], PEQ.[DOCUMENTS_RECEIVED]), 'X', 'YES') AS [Supporting documents received by Corrona?]
	  ,(CASE WHEN COALESCE(TM1.[REASON_HOSP_NOT_FAX], TM2.[REASON_HOSP_NOT_FAX], PEQ.[REASON_HOSP_NOT_FAX]) = 'X'
			 THEN 'Hospital would not fax or release documents'
			 WHEN COALESCE(TM1.[REASON_REFUSED], TM2.[REASON_REFUSED], PEQ.[REASON_REFUSED]) = 'X'
			 THEN 'Patient would not authorize release of records'
			 WHEN COALESCE(TM1.[REASON_OTHER], TM2.[REASON_OTHER], PEQ.[REASON_OTHER]) = 'X'
			 THEN 'Other'
		ELSE ''
		END) AS [Reason if no supporting documents provided]
	  , COALESCE(TM1.[REASON_HOSP_NOT_FAX_Y], TM2.[REASON_HOSP_NOT_FAX_Y], PEQ.[REASON_HOSP_NOT_FAX_Y]) AS [Hospital would not fax or release documents because]
	  , COALESCE(TM1.[REASON_OTHER_EXP], TM2.[REASON_OTHER_EXP], PEQ.[REASON_OTHER_EXP],'') AS [Reason if no source provided = Other, specify]
	  , ISNULL(CASE WHEN L.[STATUSID] < 10 THEN 'Incomplete'
			ELSE 'Complete'
	   END, '') AS [Form status]
  FROM #UTAEEVENT L
	LEFT JOIN [MERGE_SpA].[staging].[VS_01] VD ON L.[vID] = VD.[vID]
	LEFT JOIN #TAEMAINV1 TM1 ON L.[vID] = TM1.[vID] AND L.[PAGEDESC] = TM1.[PAGEDESC]
	LEFT JOIN #TAEMAINV2 TM2 ON L.[vID] = TM2.[vID] AND L.[PAGEDESC] = TM2.[PAGEDESC]
	LEFT JOIN #TAEPEQ PEQ ON L.[vID] = PEQ.[vID] AND L.[PAGEDESC] = PEQ.[PAGEDESC]
	LEFT JOIN #TIA TIA ON L.[vID] = TIA.[vID] AND L.[PAGEDESC] = TIA.[PAGEDESC]
	LEFT JOIN [MERGE_SpA].[staging].[EPRO_01] EPRO01 ON L.[vID] = EPRO01.[vID] AND L.PAGEID=EPRO01.PAGEID
	LEFT JOIN [MERGE_SpA].[staging].[EP_01A] EP01A ON L.[vID] = EP01A.[vID] AND L.PAGEID=EP01A.PAGEID
	LEFT JOIN [MERGE_SpA].[staging].[EP_01] EP01 ON L.[vID] = EP01.[vID] AND L.PAGEID=EP01.PAGEID
	LEFT JOIN [MERGE_SpA].[staging].[TAE_TOP] TT ON L.VID=TT.VID AND L.PAGEID=TT.PAGEID
) t

--select * from #TAEEVENT

insert into [Reporting].[PSA400].[t_pv_taeqclisting] (
	   [vID]
      ,[Site ID]
      ,[Subject ID]
      ,[Provider ID]
      ,[PAGEDESC]
      ,[Event Type]
      ,[Event Term]
      ,[OtherEventSpecify]
      ,[Date of Event Onset]
      ,[Visit Date]
      ,[Event Outcome]
      ,[Seious outcome]
      ,[In Utero or Neonatal Outcomes]
      ,[IV antibiotics_TAE INF]
      ,[Event Confirmation Status/Can you confirm the Event?]
      ,[Not an Event (explanation)]
      ,[Supporting documents]
      ,[file attached]
      ,[Supporting documents received by Corrona?]
      ,[Reason if no supporting documents provided]
      ,[Hospital would not fax or release documents because]
      ,[Reason if no source provided = Other, specify]
      ,[Form status]
      ,[Last Page Updated – Name]
      ,[Last Page Updated – Date]
      ,[Last Page Updated – User]
)

SELECT DISTINCT -- 
	  TAE.[vID],TAE.[Site ID],TAE.[Subject ID],TAE.[Provider ID],TAE.[PAGEDESC],TAE.[Event Type],TAE.[Event Term],TAE.[OtherEventSpecify]
	  ,TAE.[Date of Event Onset],TAE.[Visit Date],TAE.[Event Outcome],TAE.[Seious outcome],TAE.[In Utero or Neonatal Outcomes]
	  ,TAE.[IV antibiotics_TAE INF],TAE.[Event Confirmation Status/Can you confirm the Event?],TAE.[Not an Event (explanation)]
	  ,TAE.[Supporting documents],TAE.[file attached],TAE.[Supporting documents received by Corrona?]
	  ,TAE.[Reason if no supporting documents provided],TAE.[Hospital would not fax or release documents because]
	  ,TAE.[Reason if no source provided = Other, specify],TAE.[Form status]
	  ,L.[PAGENAME] AS [Last Page Updated – Name]
	  ,DATEADD(HH,3,ISNULL(L.[DATALMDT], L.[PAGELMDT])) AS [Last Page Updated – Date]
	  ,ISNULL(L.[DATALMBY], L.[PAGELMBY]) AS [Last Page Updated – User]
--into [Reporting].[PSA400].[t_PV_TAEQC]
FROM --		select * from
	#TAEEVENT TAE
LEFT JOIN #D L ON L.ROWNUM = 1 AND TAE.vID = L.vID AND L.PAGEDESC = TAE.[PAGEDESC]

/*
SELECT * FROM [Reporting].[PSA400].[t_PV_TAEQC] ORDER BY [Last Page Updated – Date] DESC
*/

END



GO
