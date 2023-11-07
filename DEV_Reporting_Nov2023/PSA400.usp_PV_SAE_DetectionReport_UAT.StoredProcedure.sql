USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_PV_SAE_DetectionReport_UAT]    Script Date: 11/7/2023 12:08:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =================================================
-- Author:		Garth and Kaye
-- Create date: 4/17/2018
-- Updated:		5/9/2020 by Kaye in Staging only
-- Description:	Procedure for SAE_DetectionReport
-- =================================================


CREATE PROCEDURE [PSA400].[usp_PV_SAE_DetectionReport_UAT] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
exec [PSA400].[usp_PV_SAE_DetectionReport]
select * from [Reporting].[PSA400].[t_PV_SAE_DetectionReport]


CREATE TABLE [PSA400].[t_PV_SAE_DetectionReport_UAT](
	[vID] [bigint] NULL,
	[Site ID] [bigint] NOT NULL,
	[Subject ID] [nvarchar](50) NOT NULL,
	[Provider ID] [smallint] NULL,
	[Page Description] [nvarchar](255) NOT NULL,
	[Event Type] [nvarchar](255) NOT NULL,
	[Event Term] [nvarchar](50) NULL,
	[OtherEventSpecify] [nvarchar](50) NULL,
	[Date of Event Onset (TAE)] [date] NULL,
	[Visit Date] [date] NULL,
	[Age] [int] NULL,
	[YOB] [nvarchar](4) NULL,
	[Gender] [nvarchar](6) NULL,
	[Ethnicity] [nvarchar](24) NULL,
	[Race] [nvarchar](157) NULL,
	[SPA Disease Duration] [int] NULL,
	[Event Outcome] [nvarchar](33) NULL,
	[Death] [varchar](3) NOT NULL,
	[Event Confirmation Status/Can you confirm the Event?] [nvarchar](68) NULL,
	[Not an Event (explanation)] [nvarchar](301) NULL,
	[Supporting documents] [nvarchar](28) NULL,
	[Serious outcomes] [varchar](16) NULL,
	[Hospitalized] [varchar](3) NOT NULL,
	[Exposed Bio/Sm Mol - Follow-Up] [nvarchar](max) NULL,
	[Changes made today] [varchar](24) NULL,
	[Attribution to Drug(s) y/n] [varchar](98) NULL,
	[Attributed Drug(s)] [nvarchar](2318) NULL,
	[Additional Comments or Narrative] [nvarchar](4000) NULL,
	[Form status] [varchar](10) NOT NULL,
	[Last Page Updated – Name] [nvarchar](100) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](200) NULL
)

*/


TRUNCATE TABLE [Reporting].[PSA400].[t_PV_SAE_DetectionReport_UAT]	


/***********The CDM.EVENTTYPE Table must be updated via the Table Wizard any time a revision is added to SpA ****************/

 
/****** SAE Detection Report  ******/


IF OBJECT_ID('tempdb..#VDEF') IS NOT NULL DROP TABLE #VDEF
select * into #VDEF from

(
	SELECT 
		*
		, [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) pgnm 
	FROM [MERGE_SpA_UAT].[dbo].[DES_VDEF] WHERE POBJNAME LIKE '%TAE%' OR POBJNAME LIKE '%PEQ%'
) t

--SELECT * FROM #VDEF

IF OBJECT_ID('tempdb..#TAEPAGE') IS NOT NULL DROP TABLE #TAEPAGE
select * into #TAEPAGE from

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
			FP.[PAGEID] AS [FirstPage]
		FROM
			#VDEF VD
			LEFT JOIN [Reporting].[PSA400].[EventType] ET ON  VD.[REVNUM] = ET.[REVNUM] 
														AND ET.[VISITID] =  VD.[VISITID] 
														AND VD.[POBJNAME] = ET.[POBJNAME] 
														AND ET.[PORDER] = VD.[PORDER]
														AND VD.[PAGEID]=ET.[FirstPage]
			LEFT JOIN #VDEF FP ON ET.[REVNUM] = FP.[REVNUM] 
														AND FP.[VISITID] =  ET.[VISITID] 
														AND ET.[FirstPage] = FP.[PAGEID]
														AND FP.[PORDER]=ET.[PORDER]
														AND FP.[VISITID]=ET.[VISITID]

) t


--SELECT * FROM [Reporting].[PSA400].[EventType] order by revnum desc WHERE REVNUM=11 ORDER BY REVNUM DESC, VISITID, pagename, porder, pobjname
--SELECT * FROM #VDEF WHERE REVNUM=12 order by revnum desc, visitid, PAGENAME, PORDER, POBJNAME
--SELECT * FROM #TAEPAGE order by revnum desc, visitid




IF OBJECT_ID('tempdb..#SourceCodeValue') IS NOT NULL DROP TABLE #SourceCodeValue
select * into #SourceCodeValue from

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
		  FROM [MERGE_SpA_UAT].[dbo].[DES_PDEF] PD
				INNER JOIN [MERGE_SpA_UAT].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
		  WHERE REPORTINGC IN ('LM_AE_INTRA','LM_AE_SOURCE_DOCS', 'GENDER', 'RACE_HISPANIC', 'DRUG_NAME')) T
		  INNER JOIN [MERGE_SpA_UAT].[dbo].[DES_CODELIST] SCV 
                   ON SCV.[NAME] = T.[CODELISTNAME]
) t

--SELECT * FROM #SourceCodeValue

IF OBJECT_ID('tempdb..#ASUB') IS NOT NULL DROP TABLE #ASUB
select * into #ASUB from

(
    			SELECT DISTINCT 
				 ES01.[SITENUM]
				 , ES01.[SUBNUM]
				 , ES01.[GENDER_DEC] AS [Gender]
				 , CONVERT(NVARCHAR(4), ES01.[BIRTHDATE]) AS [BIRTHDATE]
				 , ES01.[RACE_HISPANIC_DEC] AS [Ethnicity]
				 , (CASE WHEN ES01.[RACE_OTHER] = 'X' THEN 'Other: '+ ISNULL(ES01.[RACE_OTHER_SPEC] + ', ', '') ELSE '' END
				   + 
				CASE WHEN ES01.[RACE_PACIFIC] = 'X' THEN 'Native Hawaiian or Other Pacific Islander, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_ASIAN] = 'X' THEN 'Asian, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_BLACK] = 'X' THEN 'Black, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_WHITE] = 'X' THEN 'White, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_NATIVE_AM] = 'X' THEN 'American Indian or Alaska Native' ELSE '' END) AS [Race]
				 , EPRO01.[YR_ONSET_PA]
			 FROM 
				[MERGE_SpA_UAT].[dbo].[ES_01] ES01
				LEFT JOIN 
					(SELECT DISTINCT 
						[SITENUM], 
						[SUBNUM], 
						MAX([YR_ONSET_PA]) AS [YR_ONSET_PA]
					 FROM
					 (
						SELECT [SITENUM], [SUBNUM], [YR_ONSET_PA]
						FROM [MERGE_SpA].[dbo].[EPRO_01]
						
						UNION
						
						SELECT [SITENUM], [SUBNUM], [YR_ONSET_PA]
						FROM [MERGE_SpA_UAT].[dbo].[EP_01] EP01
					 ) EP01
					 GROUP BY [SITENUM], [SUBNUM]
					 ) EPRO01 ON ES01.[SUBNUM] = EPRO01.[SUBNUM] AND EPRO01.[SITENUM] = ES01.[SITENUM]
			 WHERE ES01.[VISNAME] LIKE '%Enrollment%'-- AND ES01.[SITENUM] NOT IN (9999)
			 
			 UNION
			 
			 SELECT DISTINCT 
				 ES01.[SITENUM]
				 , ES01.[SUBNUM]
				 , ES01.[GENDER_DEC] AS [Gender]
				 , CONVERT(NVARCHAR(4), ES01.[BIRTHDATE]) AS [BIRTHDATE]
				 , ES01.[RACE_HISPANIC_DEC] AS [Ethnicity]
				 , (CASE WHEN ES01.[RACE_OTHER] = 'X' THEN 'Other: '+ ISNULL(ES01.[RACE_OTHER_SPEC] + ', ', '') ELSE '' END
				   + 
				CASE WHEN ES01.[RACE_PACIFIC] = 'X' THEN 'Native Hawaiian or Other Pacific Islander, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_ASIAN] = 'X' THEN 'Asian, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_BLACK] = 'X' THEN 'Black, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_WHITE] = 'X' THEN 'White, ' ELSE '' END
				   +
				CASE WHEN ES01.[RACE_NATIVE_AM] = 'X' THEN 'American Indian or Alaska Native, ' ELSE '' END) AS [Race]
				 , EPRO01.[YR_ONSET_PA]
			 FROM 
				[MERGE_SpA_UAT].[dbo].[ESUB_01] ES01
				LEFT JOIN 
					(SELECT DISTINCT 
						[SITENUM], 
						[SUBNUM], 
						MAX([YR_ONSET_PA]) AS [YR_ONSET_PA]
					 FROM
					 (
						SELECT [SITENUM], [SUBNUM], [YR_ONSET_PA]
						FROM [MERGE_SpA_UAT].[dbo].[EPRO_01]
						
						UNION
						
						SELECT [SITENUM], [SUBNUM], [YR_ONSET_PA]
						FROM [MERGE_SpA_UAT].[dbo].[EP_01] EP01
					 ) EP01
					 GROUP BY [SITENUM], [SUBNUM]
					 ) EPRO01 ON ES01.[SUBNUM] = EPRO01.[SUBNUM] AND EPRO01.[SITENUM] = ES01.[SITENUM]
			 WHERE ES01.[VISNAME] LIKE '%Enrollment%'
) t

--SELECT * FROM #ASUB


IF OBJECT_ID('tempdb..#D') IS NOT NULL DROP TABLE #D
select * into #D from

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
				[MERGE_SpA_UAT].[staging].[DAT_PAGS] DP
				INNER JOIN #TAEPAGE TP ON DP.PAGENAME = TP.PAGENAME AND DP.REVNUM = TP.REVNUM AND DP.[VISITID] = TP.[VISITID]
		  ) T
) t

--SELECT * FROM #D

IF OBJECT_ID('tempdb..#L') IS NOT NULL DROP TABLE #L
select * into #L from

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


--SELECT * FROM #L

IF OBJECT_ID('tempdb..#UTAEEVENT') IS NOT NULL DROP TABLE #UTAEEVENT
select * into #UTAEEVENT from

(
   SELECT DISTINCT
	  DP.[vID]
	  , DP.[REVNUM]
	  , DP.[REVISION]
	  , CONVERT(INT, DP.[VISITID]) AS [VISITID]
	  , CONVERT(INT, DP.[VISITSEQ]) AS [VISITSEQ]
	  , CONVERT(INT, DP.[PAGEID]) AS [PAGEID]
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  ,L.[EVENTTYPE]
	  ,MIN(L.[STATUSID]) AS [STATUSID]
  FROM #D DP
	INNER JOIN #L L ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC AND DP.PAGEID = L.First_page
  GROUP BY DP.[vID]
	  , DP.[REVNUM]
	  , DP.[REVISION]
	  , CONVERT(INT, DP.[VISITID])
	  , CONVERT(INT, DP.[VISITSEQ])
	  , CONVERT(INT, DP.[PAGEID]) 
	  ,DP.[SITENUM] 
	  ,DP.[SUBNUM]
	  ,ISNULL(DP.[PAGEDESC], '')
	  ,L.[EVENTTYPE]

) t

IF OBJECT_ID('tempdb..#TAED') IS NOT NULL DROP TABLE #TAED
select * into #TAED from

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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_ANA] ANA 
	ON DP.[vID] = ANA.[vID] AND DP.[PAGEID] = ANA.[PAGEID]-- AND DP.[PAGESEQ] = ANA.[PAGESEQ]
		
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_SSB] SSB ON DP.[vID] = SSB.[vID] AND DP.[PAGEID] = SSB.[PAGEID]	
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_CAN] CAN ON DP.[vID] = CAN.[vID] AND DP.[PAGEID] = CAN.[PAGEID]	
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_CAR] CAR ON DP.[vID] = CAR.[vID] AND DP.[PAGEID] = CAR.[PAGEID]	
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_GEN] GEN ON DP.[vID] = GEN.[vID] AND DP.[PAGEID] = GEN.[PAGEID]	
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_HEP] HEP ON DP.[vID] = HEP.[vID] AND DP.[PAGEID] = HEP.[PAGEID]	
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_INF] INF ON DP.[vID] = INF.[vID] AND DP.[PAGEID] = INF.[PAGEID]	
	
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_CONFIRM_NEU] NEU ON DP.[vID] = NEU.[vID] AND DP.[PAGEID] = NEU.[PAGEID]
) t

IF OBJECT_ID('tempdb..#TAEOUTCOME') IS NOT NULL DROP TABLE #TAEOUTCOME
select * into #TAEOUTCOME from

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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_OUTCOME] TOC ON DP.[vID] = TOC.[vID] AND DP.[PAGEID] = TOC.[PAGEID] AND DP.[PAGESEQ] = TOC.[PAGESEQ]
) t

IF OBJECT_ID('tempdb..#TAEMAINV1') IS NOT NULL DROP TABLE #TAEMAINV1
select * into #TAEMAINV1 from

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
	  , NULL AS [In Utero or Neonatal Outcomes]
	  --, TIA.[LM_AE_INTRA_DEC]
	  , MAX(TAED.[LM_EVENT_CONFIRM_DEC]) AS [LM_EVENT_CONFIRM_DEC]
	  , MAX(TAED.[NO_EVENT_EXP]) AS [NO_EVENT_EXP]
	  , MAX(TAED.[AE_SOURCE_DOCS_DEC]) AS [AE_SOURCE_DOCS_DEC]
	  , NULL AS [LM_AE_SOURCE_DOCS_ATTACH]
	  , NULL AS [DOCUMENTS_RECEIVED]
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
	  , NULL AS [In Utero or Neonatal Outcomes]
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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_1] TP1 ON DP.vID = TP1.vID AND DP.PAGEID = TP1.PAGEID AND DP.PAGESEQ = TP1.PAGESEQ
) t

IF OBJECT_ID('tempdb..#TAEPEQ') IS NOT NULL DROP TABLE #TAEPEQ
select * into #TAEPEQ from

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
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_1_PEQ] PEQ01 ON DP.vID = PEQ01.vID AND DP.PAGEID = PEQ01.PAGEID AND DP.PAGESEQ = PEQ01.PAGESEQ
) t

IF OBJECT_ID('tempdb..#TAEDRUG1') IS NOT NULL DROP TABLE #TAEDRUG1
select * into #TAEDRUG1 from

(	
	SELECT 
		[vID]
	  , [SUBNUM]
	  , [VISITID]
	  , [VISITSEQ]
	  , [PAGEDESC]
	  , (CASE WHEN [BIOLOGIC_STATUS] = 1 
			 THEN 'Yes-Biologic'
			 ELSE 'No' END)[BIOLOGIC_STATUS]
	  , (CASE WHEN [BIOSIM_STATUS] = 1 
			 THEN 'Yes-Biosim'
			 ELSE 'No' END)[BIOSIM_STATUS]
	FROM
	(
		SELECT DISTINCT
				DP.[vID]
			  , DP.[SUBNUM]
			  , DP.[VISITID]
			  , DP.[VISITSEQ]
			  , DP.[PAGEDESC]
			  , MAX(DRUG.[BIOLOGIC_STATUS]) AS [BIOLOGIC_STATUS]
			  , MAX(DRUG.[BIOSIM_STATUS]) AS [BIOSIM_STATUS]
		  FROM [MERGE_SpA_UAT].[staging].[DRUG] DRUG
				INNER JOIN #D DP ON DP.vID = DRUG.vID AND DP.PAGEID = DRUG.PAGEID AND DP.VISITID = DRUG.VISITID
		  GROUP BY   DP.[vID]
			  , DP.[SUBNUM]
			  , DP.[VISITID]
			  , DP.[VISITSEQ]
			  , DP.[PAGEDESC]
	  ) T
) t

IF OBJECT_ID('tempdb..#TAEDRUG2A') IS NOT NULL DROP TABLE #TAEDRUG2A
select * into #TAEDRUG2A from

(
	SELECT
		vID
		, VISITID
		, VISITSEQ
		, SITENUM
		, SUBNUM
		, ISNULL([1],'')+ISNULL(', '+[2],'')+ISNULL(', '+[4] ,'')
		 +ISNULL(', '+[3],'') +ISNULL(', '+[5],'')+ISNULL(', '+[6],'')
		 +ISNULL(', '+[7],'') +ISNULL(', '+[8],'')+ISNULL(', '+[9],'')
		 +ISNULL(', '+[10],'')+ISNULL(', '+[11],'')+ISNULL(', '+[12],'')
		 +ISNULL(', '+[13],'')+ISNULL(', '+[14],'')+ISNULL(', '+[15],'')
		 +ISNULL(', '+[16],'')+ISNULL(', '+[17],'')+ISNULL(', '+[18],'')
		 +ISNULL(', '+[19],'')+ISNULL(', '+[20],'') AS [DRUG_NAME]
	FROM
		(SELECT
			 vID
			, VISITID
			, VISITSEQ
			, SITENUM
			, SUBNUM
			, MAX([1])AS [1]
			, MAX([2])AS [2]
			, MAX([3])AS [3]
			, MAX([4])AS [4]
			, MAX([5])AS [5]
			, MAX([6])AS [6]
			, MAX([7])AS [7]
			, MAX([8])AS [8]
			, MAX([9])AS [9]
			, MAX([10])AS [10]
			, MAX([11])AS [11]
			, MAX([12])AS [12]
			, MAX([13])AS [13]
			, MAX([14])AS [14]
			, MAX([15])AS [15]
			, MAX([16])AS [16]
			, MAX([17])AS [17]
			, MAX([18])AS [18]
			, MAX([19])AS [19]
			, MAX([20])AS [20]
		FROM
		(
			SELECT
			 vID
			, VISITID
			, VISITSEQ
			, SITENUM
			, SUBNUM
			, PVT.[1]
			, PVT.[2]
			, PVT.[3]
			, PVT.[4]
			, PVT.[5]
			, PVT.[6]
			, PVT.[7]
			, PVT.[8]
			, PVT.[9]
			, PVT.[10]
			, PVT.[11]
			, PVT.[12]
			, PVT.[13]
			, PVT.[14]
			, PVT.[15]
			, PVT.[16]
			, PVT.[17]
			, PVT.[18]
			, PVT.[19]	
			, PVT.[20]
			FROM
				(SELECT 
					  DP.[vID]
					, DRUG.[SITENUM]
					, DRUG.[SUBNUM]
					, DRUG.[VISITID]
					, DRUG.[VISITSEQ]
					, DRUG.[PAGEID]
					, DRUG.[PAGENAME]
					, DRUG.[PAGESEQ]
					, DRUG.[DRUG_NAME]
					, (CASE WHEN DRUG.[DRUG_NAME] = 999 
								THEN DRUG.[DRUG_NAME_DEC] + ' - ' + ISNULL(DRUG.[DRUG_NAME_OTHER], '')
							ELSE DRUG.[DRUG_NAME_DEC]
					  END) AS [DRUG_NAME_DEC]
				FROM [MERGE_SpA_UAT].[staging].[DRUG] DRUG
					  INNER JOIN #D DP ON DP.vID = DRUG.vID
				WHERE DRUG.VISNAME LIKE '%FOLLOW%' AND DRUG.[PAGENAME] LIKE '%BIOLOGIC%' AND DRUG.[DRUG_NAME] IN (129,121,140,114,116,350,520,715,914,924,195,139
									 ,131,201,211,189,998,999,1,2,3,4,99,14,53,52,92,91)
			) AS T
			PIVOT (MAX([DRUG_NAME_DEC]) FOR [PAGESEQ] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20])) AS PVT
		) A
	GROUP BY vID, VISITID, VISITSEQ, SITENUM, SUBNUM
			) D
) t

IF OBJECT_ID('tempdb..#TAEDRUG2B') IS NOT NULL DROP TABLE #TAEDRUG2B
select * into #TAEDRUG2B from

(
	SELECT
		vID
		, VISITID
		, VISITSEQ
		, SITENUM
		, SUBNUM
		, ISNULL([1],'')+ISNULL(', '+[2],'')+ISNULL(', '+[4] ,'')
		 +ISNULL(', '+[3],'') +ISNULL(', '+[5],'')+ISNULL(', '+[6],'')
		 +ISNULL(', '+[7],'') +ISNULL(', '+[8],'')+ISNULL(', '+[9],'')
		 +ISNULL(', '+[10],'')+ISNULL(', '+[11],'')+ISNULL(', '+[12],'')
		 +ISNULL(', '+[13],'')+ISNULL(', '+[14],'')+ISNULL(', '+[15],'')
		 +ISNULL(', '+[16],'')+ISNULL(', '+[17],'')+ISNULL(', '+[18],'')
		 +ISNULL(', '+[19],'')+ISNULL(', '+[20],'') AS [DRUG_NAME]
	FROM
		(SELECT
			 vID
			, VISITID
			, VISITSEQ
			, SITENUM
			, SUBNUM
			, MAX([1])AS [1]
			, MAX([2])AS [2]
			, MAX([3])AS [3]
			, MAX([4])AS [4]
			, MAX([5])AS [5]
			, MAX([6])AS [6]
			, MAX([7])AS [7]
			, MAX([8])AS [8]
			, MAX([9])AS [9]
			, MAX([10])AS [10]
			, MAX([11])AS [11]
			, MAX([12])AS [12]
			, MAX([13])AS [13]
			, MAX([14])AS [14]
			, MAX([15])AS [15]
			, MAX([16])AS [16]
			, MAX([17])AS [17]
			, MAX([18])AS [18]
			, MAX([19])AS [19]
			, MAX([20])AS [20]
		FROM
		(
			SELECT
			 vID
			, VISITID
			, VISITSEQ
			, SITENUM
			, SUBNUM
			, PVT.[1]
			, PVT.[2]
			, PVT.[3]
			, PVT.[4]
			, PVT.[5]
			, PVT.[6]
			, PVT.[7]
			, PVT.[8]
			, PVT.[9]
			, PVT.[10]
			, PVT.[11]
			, PVT.[12]
			, PVT.[13]
			, PVT.[14]
			, PVT.[15]
			, PVT.[16]
			, PVT.[17]
			, PVT.[18]
			, PVT.[19]	
			, PVT.[20]
			FROM
				(SELECT 
					  DP.[vID]
					, DRUG.[SITENUM]
					, DRUG.[SUBNUM]
					, DRUG.[VISITID]
					, DRUG.[VISITSEQ]
					, DRUG.[PAGEID]
					, DRUG.[PAGENAME]
					, DRUG.[PAGESEQ]
					, DRUG.[DRUG_NAME]
					, (CASE WHEN DRUG.[DRUG_NAME] = 999 
								THEN DRUG.[DRUG_NAME_DEC] + ' - ' + ISNULL(DRUG.[DRUG_NAME_OTHER], '')
							ELSE DRUG.[DRUG_NAME_DEC]
					  END) AS [DRUG_NAME_DEC]
				FROM [MERGE_SpA_UAT].[staging].[DRUG] DRUG
					  INNER JOIN #D DP ON DP.vID = DRUG.vID
				WHERE DRUG.VISNAME LIKE '%FOLLOW%' AND DRUG.[PAGENAME] LIKE '%BIOSIM%' AND DRUG.[DRUG_NAME] IN (129,121,140,114,116,350,520,715,914,924,195,139
									 ,131,201,211,189,998,999,1,2,3,4,99,14,53,52,92,91)
			) AS T
			PIVOT (MAX([DRUG_NAME_DEC]) FOR [PAGESEQ] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20])) AS PVT
		) A
	GROUP BY vID, VISITID, VISITSEQ, SITENUM, SUBNUM
			) D
) t

IF OBJECT_ID('tempdb..#TAEDRUG2') IS NOT NULL DROP TABLE #TAEDRUG2
select * into #TAEDRUG2 from

(
SELECT TD2A.VID
     , TD2A.VISITID
	 , TD2A.VISITSEQ
	 , TD2A.SITENUM
	 , TD2A.SUBNUM
	 , (ISNULL(TD2A.DRUG_NAME, '') + ISNULL(', ' + TD2B.DRUG_NAME, '')) AS DRUG_NAME
FROM #TAEDRUG2A TD2A INNER JOIN #TAEDRUG2B TD2B ON TD2A.VID=TD2B.VID
) t

IF OBJECT_ID('tempdb..#TAEDRUG3') IS NOT NULL DROP TABLE #TAEDRUG3
select * into #TAEDRUG3 from

(
	SELECT
		vID
		, VISITID
		, VISITSEQ
		, SITENUM
		, SUBNUM
		, PAGEDESC
		, ISNULL([101],'')+ISNULL(', '+[102],'')+ISNULL(', '+[104],'')
		 +ISNULL(', '+[103],'') +ISNULL(', '+[105],'')+ISNULL(', '+[106],'')
		 +ISNULL(', '+[107],'') +ISNULL(', '+[108],'')+ISNULL(', '+[109],'')
		 +ISNULL(', '+[110],'')+ISNULL(', '+[111],'')+ISNULL(', '+[112],'')
		 +ISNULL(', '+[113],'')+ISNULL(', '+[114],'')+ISNULL(', '+[115],'')
		 +ISNULL(', '+[116],'')+ISNULL(', '+[117],'')+ISNULL(', '+[118],'')
		 +ISNULL(', '+[119],'')+ISNULL(', '+[120],'') AS [TAE_ATTRIBUTED]
		, ISNULL([1],'')+ISNULL(', '+[2],'')+ISNULL(', '+[4] ,'')
		 +ISNULL(', '+[3],'') +ISNULL(', '+[5],'')+ISNULL(', '+[6],'')
		 +ISNULL(', '+[7],'') +ISNULL(', '+[8],'')+ISNULL(', '+[9],'')
		 +ISNULL(', '+[10],'')+ISNULL(', '+[11],'')+ISNULL(', '+[12],'')
		 +ISNULL(', '+[13],'')+ISNULL(', '+[14],'')+ISNULL(', '+[15],'')
		 +ISNULL(', '+[16],'')+ISNULL(', '+[17],'')+ISNULL(', '+[18],'')
		 +ISNULL(', '+[19],'')+ISNULL(', '+[20],'') AS [DRUG_NAME]
	FROM
		(SELECT
			vID
			, VISITID
			, VISITSEQ
			, SITENUM
			, SUBNUM
			, PAGEDESC
			, MAX([1])AS [1]
			, MAX([2])AS [2]
			, MAX([3])AS [3]
			, MAX([4])AS [4]
			, MAX([5])AS [5]
			, MAX([6])AS [6]
			, MAX([7])AS [7]
			, MAX([8])AS [8]
			, MAX([9])AS [9]
			, MAX([10])AS [10]
			, MAX([11])AS [11]
			, MAX([12])AS [12]
			, MAX([13])AS [13]
			, MAX([14])AS [14]
			, MAX([15])AS [15]
			, MAX([16])AS [16]
			, MAX([17])AS [17]
			, MAX([18])AS [18]
			, MAX([19])AS [19]
			, MAX([20])AS [20]
			, MAX([101])AS [101]
			, MAX([102])AS [102]
			, MAX([103])AS [103]
			, MAX([104])AS [104]
			, MAX([105])AS [105]
			, MAX([106])AS [106]
			, MAX([107])AS [107]
			, MAX([108])AS [108]
			, MAX([109])AS [109]
			, MAX([110])AS [110]
			, MAX([111])AS [111]
			, MAX([112])AS [112]
			, MAX([113])AS [113]
			, MAX([114])AS [114]
			, MAX([115])AS [115]
			, MAX([116])AS [116]
			, MAX([117])AS [117]
			, MAX([118])AS [118]
			, MAX([119])AS [119]
			, MAX([120])AS [120]
		FROM
		(
			SELECT
			 vID
			, VISITID
			, VISITSEQ
			, SITENUM
			, SUBNUM
			, PAGEDESC
			, PAGENAME
			, PVT2.[1]
			, PVT2.[2]
			, PVT2.[3]
			, PVT2.[4]
			, PVT2.[5]
			, PVT2.[6]
			, PVT2.[7]
			, PVT2.[8]
			, PVT2.[9]
			, PVT2.[10]
			, PVT2.[11]
			, PVT2.[12]
			, PVT2.[13]
			, PVT2.[14]
			, PVT2.[15]
			, PVT2.[16]
			, PVT2.[17]
			, PVT2.[18]
			, PVT2.[19]	
			, PVT2.[20]
			, PVT2.[101]
			, PVT2.[102]
			, PVT2.[103]
			, PVT2.[104]
			, PVT2.[105]
			, PVT2.[106]
			, PVT2.[107]
			, PVT2.[108]
			, PVT2.[109]
			, PVT2.[110]
			, PVT2.[111]
			, PVT2.[112]
			, PVT2.[113]
			, PVT2.[114]
			, PVT2.[115]
			, PVT2.[116]
			, PVT2.[117]
			, PVT2.[118]
			, PVT2.[119]
			, PVT2.[120]
			FROM
				(SELECT 
					DP.[vID]
					, DP.[SITENUM]
					, DP.[SUBNUM]
					, DP.[VISITID]
					, DP.[VISITSEQ]
					, DP.[PAGEDESC]
					, DRUG.[PAGEID]
					, DRUG.[PAGENAME]
					, DRUG.[PAGESEQ]
					, DRUG.[PAGESEQ]+100 AS [DASEQ]
					, (CASE WHEN DRUG.[DMARD_TAE_ATTRIBUTED] = 1 OR DRUG.[CONMED_TAE_ATTRIBUTED] = 1
							THEN 'Yes'
							WHEN DRUG.[DMARD_TAE_ATTRIBUTED] = 0 OR DRUG.[CONMED_TAE_ATTRIBUTED] = 0
							THEN 'No'
						ELSE NULL END) AS [TAE_ATTRIBUTED]
					, (CASE WHEN DRUG.[DMARD_TAE_ATTRIBUTED] = 1 OR DRUG.[CONMED_TAE_ATTRIBUTED] = 1
							THEN ISNULL(DRUG.[CONMED_NAME]+ ',','')+ (CASE WHEN DRUG.[DRUG_NAME] = 999 
									   THEN DRUG.[DRUG_NAME_DEC] + ' - ' + DRUG.[DRUG_NAME_OTHER]
									   ELSE DRUG.[DRUG_NAME_DEC]
									END)
						ELSE '' END) AS [DRUG_NAME_DEC]
				FROM [MERGE_SpA_UAT].[staging].[DRUG] DRUG
					INNER JOIN #D DP ON DP.vID = DRUG.vID AND DP.PAGEID = DRUG.PAGEID AND DP.VISITID = DRUG.VISITID
				WHERE DRUG.[DRUG_NAME] IN (14,52,53,91,92,114,116,121,125,129,131,135,139,140,161,
									  189,192,195,201,211,350,520,715,825,914,924,998,999)
 					  AND (DRUG.[DMARD_TAE_ATTRIBUTED] IS NOT NULL OR DRUG.[CONMED_TAE_ATTRIBUTED] IS NOT NULL)
			) AS T
			PIVOT (MAX(DRUG_NAME_DEC) FOR PAGESEQ IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20])) AS PVT
			PIVOT (MAX(TAE_ATTRIBUTED) FOR DASEQ IN ([101],[102],[103],[104],[105],[106],[107],[108],[109],[110],[111],[112],[113],[114],[115],[116],[117],[118],[119],[120])) AS PVT2
	) A
GROUP BY vID, VISITID, VISITSEQ, SITENUM, SUBNUM, PAGEDESC, PAGENAME) D
) t

IF OBJECT_ID('tempdb..#TAE_PAGE_4') IS NOT NULL DROP TABLE #TAE_PAGE_4
select * into #TAE_PAGE_4 from

( 
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TC.[AE_ADDITIONAL_NARRATIVE]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_COMMENTS] TC ON DP.vID = TC.vID AND DP.PAGEID = TC.PAGEID AND DP.PAGESEQ = TC.PAGESEQ
  
  UNION
  
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TP4.[AE_ADDITIONAL_NARRATIVE]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_4_CAN] TP4 ON DP.vID = TP4.vID AND DP.PAGEID = TP4.PAGEID AND DP.PAGESEQ = TP4.PAGESEQ
  
  UNION
  
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TP4.[AE_ADDITIONAL_NARRATIVE]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_4_INF] TP4 ON DP.vID = TP4.vID AND DP.PAGEID = TP4.PAGEID AND DP.PAGESEQ = TP4.PAGESEQ
		
  UNION
  
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TP4.[AE_ADDITIONAL_NARRATIVE]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_4_NEU] TP4 ON DP.vID = TP4.vID AND DP.PAGEID = TP4.PAGEID AND DP.PAGESEQ = TP4.PAGESEQ

  UNION
  
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TP4.[AE_ADDITIONAL_NARRATIVE]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_5_ANA] TP4 ON DP.vID = TP4.vID AND DP.PAGEID = TP4.PAGEID AND DP.PAGESEQ = TP4.PAGESEQ
  
  UNION
  
  SELECT DISTINCT
	    DP.[vID]
	  , DP.SUBNUM
	  , DP.VISITID
	  , DP.VISITSEQ
	  , ISNULL(DP.[PAGEDESC], '') AS [PAGEDESC]
	  , L.[EVENTTYPE]
	  , TP4.[AE_ADDITIONAL_NARRATIVE]
  FROM #UTAEEVENT L
	INNER JOIN #D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
	INNER JOIN [MERGE_SpA_UAT].[staging].[TAE_PAGE_5_SSB] TP4 ON DP.vID = TP4.vID AND DP.PAGEID = TP4.PAGEID AND DP.PAGESEQ = TP4.PAGESEQ

) t

IF OBJECT_ID('tempdb..#TAEMED') IS NOT NULL DROP TABLE #TAEMED
select * into #TAEMED from
 
(
	SELECT
		[vID]
		, [SITENUM]
		, [SUBNUM]
		, ISNULL(REPLACE(MED.ORENCIA_USE, 'X', 'ORENCIA'), '')
			+ISNULL(REPLACE(MED.HUMIRA_USE, 'X', ', HUMIRA'), '')
			+ISNULL(REPLACE(MED.CIMZIA_USE, 'X', ', CIMZIA'), '')
			+ISNULL(REPLACE(MED.ENBREL_USE, 'X', ', ENBREL'), '')
			+ISNULL(REPLACE(MED.SIMPONI_USE, 'X', ', SIMPONI'), '')
			+ISNULL(REPLACE(MED.REMICADE_USE, 'X', ', REMICADE'), '')
			+ISNULL(REPLACE(MED.ACTEMRA_USE, 'X', ', ACTEMRA'), '')
			+ISNULL(REPLACE(MED.XELJANZ_USE, 'X', ', XELJANZ'), '')
			+ISNULL(REPLACE(MED.INVEST_AGENT_USE, 'X', ', INVESTIGATIONAL AGENT'), '')
			+ISNULL(REPLACE(MED.KINERET_USE, 'X', ', KINERET'), '')
			+ISNULL(REPLACE(MED.OTEZLA_USE, 'X', ', OTEZLA'), '')
			+ISNULL(REPLACE(MED.COSENTYX_USE, 'X', ', COSENTYX'), '')
			+ISNULL(REPLACE(MED.STELARA_USE, 'X', ',  STELARA'), '')
			+ISNULL(REPLACE(MED.RITUXAN_USE, 'X', ', RITUXAN'), '')
			+ISNULL(REPLACE(MED.OTH_BIO_USE, 'X', ', OTHER - '+MED.OTH_BIO_DESC), '') AS MEDICATIONS
	FROM
	  (SELECT 
			DP.[vID]
		  , DP.[VISITID]
		  , DP.[VISITSEQ]
		  , DP.[SITENUM]
		  , DP.[SUBNUM]
		  , MAX(EP06.[ACTEMRA_USE]) AS [ACTEMRA_USE]
		  , MAX(EP06.[INVEST_AGENT_USE]) AS [INVEST_AGENT_USE]
		  , MAX(EP06.[ORENCIA_USE]) AS [ORENCIA_USE]
		  , MAX(EP06.[HUMIRA_USE]) AS [HUMIRA_USE]
		  , MAX(EP06.[KINERET_USE]) AS [KINERET_USE]
		  , MAX(EP06.[OTEZLA_USE]) AS [OTEZLA_USE]
		  , MAX(EP06.[CIMZIA_USE]) AS [CIMZIA_USE]
		  , MAX(EP06.[ENBREL_USE]) AS [ENBREL_USE]
		  , MAX(EP06.[SIMPONI_USE]) AS [SIMPONI_USE]
		  , MAX(EP06.[REMICADE_USE]) AS [REMICADE_USE]
		  , MAX(EP06.[COSENTYX_USE]) AS [COSENTYX_USE]
		  , MAX(EP06.[XELJANZ_USE]) AS [XELJANZ_USE]
		  , MAX(EP06.[STELARA_USE]) AS [STELARA_USE]
		  , MAX(EP06.[RITUXAN_USE]) AS [RITUXAN_USE]
		  , MAX(EP06.[OTH_BIO_USE]) AS [OTH_BIO_USE]
		  , MAX(EP06.[OTH_BIO_DESC]) AS [OTH_BIO_DESC]
	  FROM #UTAEEVENT L
		LEFT JOIN #D DP ON DP.vID = L.vID-- AND L.PAGEDESC = DP.PAGEDESC
		LEFT JOIN [MERGE_SpA_UAT].[staging].[EP_06] EP06 ON DP.vID = EP06.vID
	  WHERE EP06.[VISNAME] LIKE '%FOLLOW%'
	  GROUP BY DP.[vID]
			  , DP.[VISITID]
			  , DP.[VISITSEQ]
			  , DP.[SITENUM]
			  , DP.[SUBNUM]) MED
) t

IF OBJECT_ID('tempdb..#TAEEVENT') IS NOT NULL DROP TABLE #TAEEVENT
select * into #TAEEVENT from

(
	SELECT DISTINCT L.[vID]
	  , ISNULL(L.[SITENUM], '') AS [Site ID] 
	  , ISNULL(L.[SUBNUM], '') AS [Subject ID]
	  , COALESCE(TT.MD_COD, TM2.MD_COD, EPRO01.[MD_COD], EP01A.[MD_COD], EP01.[MD_COD]) AS [Provider ID]
	  , ISNULL(L.[PAGEDESC], '') AS [PAGEDESC]
	  , ISNULL(L.[EVENTTYPE], '') AS [Event Type]
	  , COALESCE(TM1.[Event Term], TM2.[Event Term], PEQ.[Event Term] ) AS [Event Term]
	  , TM2.[OtherEventSpecify]
	  , COALESCE(TM1.[Date of Event Onset], TM2.[Date of Event Onset], PEQ.[Date of Event Onset]) AS [Date of Event Onset (TAE)]
	  , CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
	  , DATEDIFF(YEAR
				, CONVERT(DATE, ISNULL(ASUB.[BIRTHDATE],VD.[VISITDATE]))
				, CONVERT(DATE,ISNULL(VD.[VISITDATE],
				(COALESCE(TM1.[Date of Event Onset], TM2.[Date of Event Onset], PEQ.[Date of Event Onset]))
				))) AS [Age]
	  , ASUB.[BIRTHDATE] AS [YOB]
	  , ASUB.[Gender]
	  , ASUB.[Ethnicity]
	  , ASUB.[Race]
	  , (YEAR(GETDATE()) - ASUB.[YR_ONSET_PA]) AS [SPA Disease Duration]
	  , COALESCE(TM1.[AE_OUTCOME_DEC], TM2.[AE_OUTCOME_DEC], PEQ.[AE_OUTCOME_DEC], '') AS [Event Outcome]
  	  , (CASE WHEN TM1.[AE_OUTCOME_DEC] = 'Patient Deceased'
  				   OR TM2.[AE_OUTCOME_DEC] = ' Death'
  			  THEN 'YES'
  			  ELSE 'NO'
  	      END) AS [Death]
	  , COALESCE(TM1.[LM_EVENT_CONFIRM_DEC], TM2.[LM_EVENT_CONFIRM_DEC], PEQ.[LM_EVENT_CONFIRM_DEC]) AS [Event Confirmation Status/Can you confirm the Event?]
	  , COALESCE(TM1.[NO_EVENT_EXP], TM2.[NO_EVENT_EXP], PEQ.[NO_EVENT_EXP]) AS [Not an Event (explanation)]
	  , COALESCE(TM1.[AE_SOURCE_DOCS_DEC], TM2.[AE_SOURCE_DOCS_DEC], PEQ.[AE_SOURCE_DOCS_DEC]) AS [Supporting documents]
  	  , COALESCE(TM1.[LM_AE_SERIOUS_DEC], TM2.[LM_AE_SERIOUS_DEC], PEQ.[LM_AE_SERIOUS_DEC]) AS [Serious outcomes]
  	  ,(CASE WHEN TM1.[Hospitalized] = 1 OR TM2.[Hospitalized] IS NOT NULL OR PEQ.[Hospitalized] IS NOT NULL
  			THEN 'Yes'
  			ELSE 'No'
  		END) AS [Hospitalized]
  	  ,CAST(ISNULL(MED.MEDICATIONS, '')
			+ ISNULL(', '+ DRUG.DRUG_NAME, '') as nvarchar(max)) AS [Exposed Bio/Sm Mol - Follow-Up]
	  , (CASE WHEN DRUG1.[BIOLOGIC_STATUS] IS NOT NULL AND DRUG1.[BIOSIM_STATUS] IS NOT NULL
			  THEN DRUG1.[BIOLOGIC_STATUS] + ', '+ DRUG1.[BIOSIM_STATUS] 
			  WHEN DRUG1.[BIOLOGIC_STATUS] IS NOT NULL THEN DRUG1.[BIOLOGIC_STATUS]
			  WHEN DRUG1.[BIOSIM_STATUS] IS NOT NULL THEN DRUG1.[BIOSIM_STATUS]
			  ELSE ''
		 END) AS [Changes made today]
	  ,(CASE WHEN DRUG3.[TAE_ATTRIBUTED] IS NULL THEN ''
			WHEN LEFT(DRUG3.[TAE_ATTRIBUTED],1) = ',' THEN LTRIM(RIGHT(DRUG3.[TAE_ATTRIBUTED], LEN(DRUG3.[TAE_ATTRIBUTED])-1))
			ELSE DRUG3.[TAE_ATTRIBUTED] 
		END) AS [Attribution to Drug(s) y/n]
	  ,(CASE WHEN DRUG3.[DRUG_NAME] IS NULL THEN ''
			WHEN LEFT(DRUG3.[DRUG_NAME],1) = ',' THEN LTRIM(RIGHT(DRUG3.[DRUG_NAME], LEN(DRUG3.[DRUG_NAME])-1))
			ELSE DRUG3.[DRUG_NAME] 
		END) AS [Attributed Drug(s)]
	  , TAEPAGE4.[AE_ADDITIONAL_NARRATIVE] AS [Additional Comments or Narrative]
	  , ISNULL(CASE WHEN L.[STATUSID] < 10 THEN 'Incomplete'
			ELSE 'Complete'
	   END, '') AS [Form status]
  FROM #UTAEEVENT L
	LEFT JOIN [MERGE_SpA_UAT].[staging].[VS_01] VD ON L.[vID] = VD.[vID]
	LEFT JOIN #ASUB ASUB ON L.[SITENUM] = ASUB.[SITENUM] AND L.[SUBNUM] = ASUB.[SUBNUM]
	LEFT JOIN #TAEMAINV1 TM1 ON L.[vID] = TM1.[vID] AND L.[PAGEDESC] = TM1.[PAGEDESC]
	LEFT JOIN #TAEMAINV2 TM2 ON L.[vID] = TM2.[vID] AND L.[PAGEDESC] = TM2.[PAGEDESC]
	LEFT JOIN #TAEPEQ PEQ ON L.[vID] = PEQ.[vID] AND L.[PAGEDESC] = PEQ.[PAGEDESC]
	LEFT JOIN #TAEMED MED ON L.[vID] = MED.[vID]-- AND L.[PAGEDESC] = MED.[PAGEDESC]
	LEFT JOIN #TAEDRUG2 DRUG ON L.[vID] = DRUG.[vID] ---AND L.[PAGEDESC] = DRUG.[PAGEDESC]
	LEFT JOIN #TAEDRUG1 DRUG1 ON L.[vID] = DRUG1.[vID] AND L.[PAGEDESC] = DRUG1.[PAGEDESC] 
	LEFT JOIN #TAEDRUG3 DRUG3 ON L.[vID] = DRUG3.[vID] AND L.[PAGEDESC] = DRUG3.[PAGEDESC]
	LEFT JOIN #TAE_PAGE_4 TAEPAGE4 ON L.[vID] = TAEPAGE4.[vID] AND L.[PAGEDESC] = TAEPAGE4.[PAGEDESC]
	LEFT JOIN [MERGE_SpA_UAT].[staging].[EPRO_01] EPRO01 ON L.[vID] = EPRO01.[vID] AND L.PAGEID = EPRO01.PAGEID
	LEFT JOIN [MERGE_SpA_UAT].[staging].[EP_01A] EP01A ON L.[vID] = EP01A.[vID] AND L.PAGEID = EP01A.PAGEID
	LEFT JOIN [MERGE_SpA_UAT].[staging].[EP_01] EP01 ON L.[vID] = EP01.[vID] AND L.PAGEID = EP01.PAGEID
	LEFT JOIN [MERGE_SpA_UAT].[staging].[TAE_TOP] TT ON L.[vID]=TT.[vID] AND L.PAGEID = TT.PAGEID

) t


--IF OBJECT_ID('[Reporting].[PSA400].[]') IS NOT NULL DROP TABLE #VDEF
	
insert into [Reporting].[PSA400].[t_PV_SAE_DetectionReport_UAT]	(
	[vID]
      ,[Site ID]
      ,[Subject ID]
      ,[Provider ID]
      ,[Page Description]
      ,[Event Type]
      ,[Event Term]
      ,[OtherEventSpecify]
      ,[Date of Event Onset (TAE)]
      ,[Visit Date]
      ,[Age]
      ,[YOB]
      ,[Gender]
      ,[Ethnicity]
      ,[Race]
      ,[SPA Disease Duration]
      ,[Event Outcome]
      ,[Death]
      ,[Event Confirmation Status/Can you confirm the Event?]
      ,[Not an Event (explanation)]
      ,[Supporting documents]
      ,[Serious outcomes]
      ,[Hospitalized]
      ,[Exposed Bio/Sm Mol - Follow-Up]
      ,[Changes made today]
      ,[Attribution to Drug(s) y/n]
      ,[Attributed Drug(s)]
      ,[Additional Comments or Narrative]
      ,[Form status]
      ,[Last Page Updated – Name]
      ,[Last Page Updated – Date]
      ,[Last Page Updated – User]
)

SELECT DISTINCT
	  TAE.[vID]
	  , TAE.[Site ID]
	  , TAE.[Subject ID]
	  , TAE.[Provider ID]
	  , TAE.[PAGEDESC] AS [Page Description]
	  , TAE.[Event Type]
	  , TAE.[Event Term]
	  , TAE.[OtherEventSpecify]
	  , TAE.[Date of Event Onset (TAE)]
	  , TAE.[Visit Date]
	  , TAE.[Age]
	  , TAE.[YOB]
	  , TAE.[Gender]
	  , TAE.[Ethnicity]
	  , TAE.[Race]
	  , TAE.[SPA Disease Duration]
	  , TAE.[Event Outcome]
	  , TAE.[Death]
	  , TAE.[Event Confirmation Status/Can you confirm the Event?]
	  , TAE.[Not an Event (explanation)]
	  , TAE.[Supporting documents]
	  , TAE.[Serious outcomes]
	  , TAE.[Hospitalized]
	  , (CASE WHEN TAE.[Exposed Bio/Sm Mol - Follow-Up] IS NULL THEN ''
			WHEN LEFT(TAE.[Exposed Bio/Sm Mol - Follow-Up],1) = ',' THEN LTRIM(RIGHT(TAE.[Exposed Bio/Sm Mol - Follow-Up], LEN(TAE.[Exposed Bio/Sm Mol - Follow-Up])-1))
			ELSE TAE.[Exposed Bio/Sm Mol - Follow-Up] 
		END) AS [Exposed Bio/Sm Mol - Follow-Up]
	  , TAE.[Changes made today]
	  , TAE.[Attribution to Drug(s) y/n]
	  , TAE.[Attributed Drug(s)]
	  , TAE.[Additional Comments or Narrative]
	  , TAE.[Form status]
	  ,L.[PAGENAME] AS [Last Page Updated – Name]
	  ,DATEADD(HH,3,ISNULL(L.[DATALMDT], L.[PAGELMDT])) AS [Last Page Updated – Date]
	  ,ISNULL(L.[DATALMBY], L.[PAGELMBY]) AS [Last Page Updated – User]
--into [Reporting].[PSA400].[t_PV_SAE_DetectionReport]
FROM #TAEEVENT TAE
	LEFT JOIN #D L ON L.ROWNUM = 1 AND TAE.vID = L.vID AND L.PAGEDESC = TAE.[PAGEDESC]


--SELECT * FROM [Reporting].[PSA400].[t_PV_SAE_DetectionReport]



END








GO
