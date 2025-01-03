USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[t_pv_TAEQCLoop]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		J. LING
-- Create date: 2/18/2017
-- Description:	Reach SSRS time limitation. 
-- Save the report to a table to avoid the problem.
-- =============================================
CREATE PROCEDURE [PSA400].[t_pv_TAEQCLoop]
AS
BEGIN
	DECLARE @TypeList varchar(8000);
	DECLARE @CFMFieldList varchar(8000);
	DECLARE @EXPFieldList varchar(8000);
	DECLARE @DOCFieldList varchar(8000);
	DECLARE @HOSPFieldList varchar(8000);
	DECLARE @FUSFieldList varchar(8000);
	DECLARE @OTHERFieldList varchar(8000);
	DECLARE @FAXYFieldList varchar(8000);
	DECLARE @OEXPFieldList varchar(8000);
	DECLARE @Tpos INT;
	DECLARE @Tlen INT;
	DECLARE @Tvalue varchar(8000);
	DECLARE @Cpos INT;
	DECLARE @Clen INT;
	DECLARE @Cvalue varchar(8000);
	DECLARE @Epos INT;
	DECLARE @Elen INT;
	DECLARE @Evalue varchar(8000);
	DECLARE @Dpos INT;
	DECLARE @Dlen INT;
	DECLARE @Dvalue varchar(8000);
	DECLARE @Hpos INT;
	DECLARE @Hlen INT;
	DECLARE @Hvalue varchar(8000);
	DECLARE @Fpos INT;
	DECLARE @Flen INT;
	DECLARE @Fvalue varchar(8000);
	DECLARE @Opos INT;
	DECLARE @Olen INT;
	DECLARE @Ovalue varchar(8000);
	DECLARE @FYpos INT;
	DECLARE @FYlen INT;
	DECLARE @FYvalue varchar(8000);
	DECLARE @OEpos INT;
	DECLARE @OElen INT;
	DECLARE @OEvalue varchar(8000);
	/****** TAE QC Report with loop ******/


	SET @TypeList = 'SSB,CAN,CAR,GEN,HEP,INF,NEU,';
	SET @CFMFieldList = 'LM_EVENT_CONFIRM_DEC,LM_EVENT_CONFIRM_CAN_DEC,LM_EVENT_CONFIRM_CVD_DEC,LM_EVENT_CONFIRM_DEC,LM_EVENT_CONFIRM_DEC,LM_EVENT_CONFIRM_DEC,LM_EVENT_CONFIRM_DEC,LM_EVENT_CONFIRM_DEC,';
	SET @EXPFieldList = 'NO_EVENT_EXP,LM_EVENT_CONFIRM_NO_CAN,LM_EVENT_CONFIRM_NO_CAR,NO_EVENT_EXP+''''+GEN.NO_EVENT_EXP_INF,NO_EVENT_EXP,NO_EVENT_EXP_INF,NO_EVENT_EXP,';
	SET @DOCFieldList = 'AE_SOURCE_DOCS_DEC,AE_SOURCE_DOCS_DEC,AE_SOURCE_DOCS_DEC,AE_SOURCE_DOCS_DEC,AE_SOURCE_DOCS_DEC,AE_SOURCE_DOCS_DEC,AE_SOURCE_DOCS_DEC,';
	SET @HOSPFieldList = 'REASON_HOSP_NOT_FAX,REASON_HOSP_NOT_FAX_CAN,REASON_HOSP_NOT_FAX_CVD,REASON_HOSP_NOT_FAX,REASON_HOSP_NOT_FAX,REASON_HOSP_NOT_FAX_INF,REASON_HOSP_NOT_FAX,';
	SET @FUSFieldList = 'REASON_REFUSED,REASON_REFUSED_CAN,REASON_REFUSED_CVD,REASON_REFUSED,REASON_REFUSED,REASON_REFUSED_INF,REASON_REFUSED,';
	SET @OTHERFieldList = 'REASON_OTHER,REASON_OTHER_CAN,REASON_OTHER_CVD,REASON_OTHER,REASON_OTHER,REASON_OTHER_INF,REASON_OTHER,';
	SET @FAXYFieldList = 'REASON_HOSP_NOT_FAX_Y,REASON_HOSP_NOT_FAX_CAN_Y,REASON_HOSP_NOT_FAX_CVD_Y,REASON_HOSP_NOT_FAX_Y,REASON_HOSP_NOT_FAX_Y,REASON_HOSP_NOT_FAX_Y,REASON_HOSP_NOT_FAX_Y,';
	SET @OEXPFieldList = 'REASON_OTHER_EXP,REASON_OTHER_CAN_EXP,REASON_OTHER_CVD_EXP,REASON_OTHER_EXP,REASON_OTHER_EXP,REASON_OTHER_INF_EXP,REASON_OTHER_EXP,';



	--IF OBJECT_ID('tempdb..#SourceCodeValue') IS NOT NULL DROP TABLE #SourceCodeValue
	--IF OBJECT_ID('tempdb..#DP') IS NOT NULL DROP TABLE #DP

	/****** SAE_Detection Non Serious Report  ******/
	--DECLARE @SourceRegistry VARCHAR(50) = '5';
	--DECLARE @SourceSystem INT = 10;
	--------------------------------

	DECLARE @DynamicQuery AS VARCHAR(MAX);
	set @Tpos = 0;
	set @Tlen = 0;
	set @Cpos = 0;
	set @Clen = 0;
	set @Epos = 0;
	set @Elen = 0;
	set @Dpos = 0;
	set @Dlen = 0;
	set @Hpos = 0;
	set @Hlen = 0;
	set @Opos = 0;
	set @Olen = 0;
	set @Fpos = 0;
	set @Flen = 0;
	set @FYpos = 0;
	set @FYlen = 0;
	set @OEpos = 0;
	set @OElen = 0;

	Set @DynamicQuery = N'
	WITH VDEF AS 
	(
		SELECT 
			*
			, [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) pgnm 
		FROM [MERGE_SPA].[dbo].[DES_VDEF] WHERE PAGENAME LIKE ''%TAE%'' OR POBJNAME LIKE ''%PEQ%''
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
		--SELECT DISTINCT
		--	[REVNUM],
		--	[PAGENAME], 
		--	[POBJNAME],
		--	EVENTYPE,
		--	[Page1]
		--FROM
		--	[MERGE_SPA].[Jen].[EventType]
		SELECT
		T.*
		, ET.EVENTYPE
	FROM
	(
		SELECT DISTINCT
			VD.[REVNUM],
			VD.[PAGENAME], 
			VD.[POBJNAME],
		
			LP.[PAGEID] AS [Page1]
		FROM
			VDEF VD
			JOIN VDwPage1s LP ON VD.[REVNUM] = LP.[REVNUM]      
											AND VD.[VISITID] =  LP.[VISITID]
											AND [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](VD.pagename) = LP.[pgnm]
	) T
	LEFT JOIN [MERGE_SPA].[Jen].[EventType] ET ON T.[REVNUM] = ET.[REVNUM] AND T.[POBJNAME] = ET.[POBJNAME] AND T.[PAGENAME] = ET.[PAGENAME]
	),

	SourceCodeValue AS
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
			  FROM [MERGE_SPA].[dbo].[DES_PDEF] PD
					INNER JOIN [MERGE_SPA].[dbo].[DES_VDEF] VD ON PD.[PAGENAME] = VD.POBJNAME
			  WHERE REPORTINGC IN (''LM_AE_INTRA'',''LM_AE_SERIOUS'')) T
			  INNER JOIN [MERGE_SpA].[dbo].[DES_CODELIST] SCV 
					   ON SCV.[NAME] = T.[CODELISTNAME]
	),

	D AS
	(
		SELECT 
			*
			,ROW_NUMBER ()   over (partition by [vID], [PAGEDESC]
												ORDER BY [PAGELMDT] desc) ROWNUM
												
		FROM (										
				SELECT 
					DP.*
					,TP.Page1
					,LTRIM(RTRIM(
						CASE 
						WHEN CHARINDEX(''('',DP.[PAGENAME]) > 0
							 THEN SUBSTRING(DP.[PAGENAME], 1,CHARINDEX(''('',DP.[PAGENAME])-1) 
						ELSE DP.[PAGENAME] 
						END)) AS [PAGEDESC]
					,TP.[EVENTYPE]
				FROM
					[MERGE_SPA].[staging].[DAT_PAGS] DP
					INNER JOIN TAEPAGE TP ON DP.PAGENAME = TP.PAGENAME AND DP.REVNUM = TP.REVNUM
			  ) T
	),

	L AS
	(
			SELECT 
			  DP.[vID]
			  ,DP.[REVISION]
			  ,DP.[SITENUM]
			  ,DP.[SUBNUM]
			  ,DP.[EVENTYPE]
			  ,DP.[PAGEDESC]
			  ,DP.[Page1] AS [First_page]
			  ,MIN(CONVERT(INT, DP.[STATUSID])) AS [STATUSID]
		 FROM	
				D DP
		 GROUP BY DP.[vID] , DP.[REVISION], DP.[SITENUM] ,DP.[SUBNUM] ,DP.[EVENTYPE], DP.[PAGEDESC], DP.[Page1]
				
	),

	UTAEEVENT AS 
	(
	   SELECT DISTINCT
		  DP.[vID]
		  , DP.[REVNUM]
		  , DP.[REVISION]
		  , CONVERT(INT, DP.[VISITID]) AS [VISITID]
		  , CONVERT(INT, DP.[VISITSEQ]) AS [VISITSEQ]
		  ,DP.[SITENUM] 
		  ,DP.[SUBNUM]
		  ,ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  ,L.[EVENTYPE]
		  ,MIN(L.[STATUSID]) AS [STATUSID]
	  FROM D DP
		INNER JOIN L L ON DP.vID = L.vID AND L.PAGEDESC = DP.PAGEDESC AND DP.PAGEID = L.First_page
	  GROUP BY DP.[vID]
		  , DP.[REVNUM]
		  , DP.[REVISION]
		  , CONVERT(INT, DP.[VISITID])
		  , CONVERT(INT, DP.[VISITSEQ])
		  ,DP.[SITENUM] 
		  ,DP.[SUBNUM]
		  ,ISNULL(DP.[PAGEDESC], '''')
		  ,L.[EVENTYPE]
	),

	TAED AS
	  (
		SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE] AS [EVENTYPE]
		  , ANA.[LM_EVENT_CONFIRM_DEC]
		  , ANA.[NO_EVENT_EXP_INF] AS [NO_EVENT_EXP]
		  , ANA.[AE_SOURCE_DOCS_DEC]
		  , ANA.[REASON_HOSP_NOT_FAX]
		  , ANA.[REASON_HOSP_NOT_FAX_Y]
		  , ANA.[REASON_REFUSED]
		  , ANA.[REASON_OTHER]
		  , ANA.[REASON_OTHER_EXP]
		FROM UTAEEVENT L
		INNER JOIN D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC] AND L.[EVENTYPE] = ''ANA''
		INNER JOIN [MERGE_SPA].[staging].[TAE_CONFIRM_ANA] ANA ON DP.[vID] = ANA.[vID] AND DP.[PAGEID] = ANA.[PAGEID]-- AND DP.[PAGESEQ] = ANA.[PAGESEQ]
		'
	WHILE CHARINDEX(',', @TypeList, @Tpos+1)>0
	BEGIN
		set @Tlen = CHARINDEX(',', @TypeList, @Tpos+1) - @Tpos
		set @Tvalue = SUBSTRING(@TypeList, @Tpos, @Tlen)
		set @Clen = CHARINDEX(',', @CFMFieldList, @Cpos+1) - @Cpos
		set @Cvalue = SUBSTRING(@CFMFieldList, @Cpos, @Clen)
		set @Elen = CHARINDEX(',', @EXPFieldList, @Epos+1) - @Epos
		set @Evalue = SUBSTRING(@EXPFieldList, @Epos, @Elen)
		set @Dlen = CHARINDEX(',', @DOCFieldList, @Dpos+1) - @Dpos
		set @Dvalue = SUBSTRING(@DOCFieldList, @Dpos, @Dlen)
		set @Hlen = CHARINDEX(',', @HOSPFieldList, @Hpos+1) - @Hpos
		set @Hvalue = SUBSTRING(@HOSPFieldList, @Hpos, @Hlen)
		set @Olen = CHARINDEX(',', @OTHERFieldList, @Opos+1) - @Opos
		set @Ovalue = SUBSTRING(@OTHERFieldList, @Opos, @Olen)
		set @Flen = CHARINDEX(',', @FUSFieldList, @Fpos+1) - @Fpos
		set @Fvalue = SUBSTRING(@FUSFieldList, @Fpos, @Flen)
		set @FYlen = CHARINDEX(',', @FAXYFieldList, @FYpos+1) - @FYpos
		set @FYvalue = SUBSTRING(@FAXYFieldList, @FYpos, @FYlen)
		set @OElen = CHARINDEX(',', @OEXPFieldList, @OEpos+1) - @OEpos
		set @OEvalue = SUBSTRING(@OEXPFieldList, @OEpos, @OElen)
		--PRINT @value @pos @len, @value /*this is here for debugging*/
		SET @DynamicQuery = @DynamicQuery +     
	   '	
		
		UNION
		
		SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE] AS [EVENTYPE]
		  , '+@Tvalue+'.'+ @CValue+'
		  , '+@Tvalue+'.'+ @Evalue +' AS [NO_EVENT_EXP]
		  , '+@Tvalue+'.'+ @Dvalue +'
		  , '+@Tvalue+'.'+ @Hvalue +'
		  , '+@Tvalue+'.'+ @FYvalue +'
		  , '+@Tvalue+'.'+ @Fvalue +'
		  , '+@Tvalue+'.'+ @Ovalue +'
		  , '+@Tvalue+'.'+ @OEvalue+'
		FROM UTAEEVENT L
		INNER JOIN D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC] AND L.[EVENTYPE] = ''ANA''
		INNER JOIN [MERGE_SPA].[staging].[TAE_CONFIRM_'+@Tvalue+'] '+@Tvalue+' ON DP.[vID] = '+@Tvalue+'.[vID] AND DP.[PAGEID] = '+@Tvalue+'.[PAGEID]'
		
	 
		set @Tpos = CHARINDEX(',', @TypeList, @Tpos+@Tlen) +1
		set @Cpos = CHARINDEX(',', @CFMFieldList, @Cpos+@Clen) +1
		set @Epos = CHARINDEX(',', @EXPFieldList, @Epos+@Elen) +1
		set @Dpos = CHARINDEX(',', @DOCFieldList, @Dpos+@Dlen) +1
		set @Hpos = CHARINDEX(',', @HOSPFieldList, @Hpos+@Hlen) +1
		set @Opos = CHARINDEX(',', @OTHERFieldList, @Opos+@Olen) +1
		set @Fpos = CHARINDEX(',', @FUSFieldList, @Fpos+@Flen) +1
		set @FYpos = CHARINDEX(',', @FAXYFieldList, @FYpos+@FYlen) +1
		set @OEpos = CHARINDEX(',', @OEXPFieldList, @OEpos+@OElen) +1

	END
	SET @DynamicQuery = @DynamicQuery +
	'),

	TAEOUTCOME AS
	  (
		SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE] AS [EVENTYPE]
		  , TOC.[AE_OUTCOME_DEC]
	  FROM UTAEEVENT L
		INNER JOIN D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC] AND L.[EVENTYPE] = ''ANA''
		INNER JOIN [MERGE_SPA].[staging].[TAE_OUTCOME] TOC ON DP.[vID] = TOC.[vID] AND DP.[PAGEID] = TOC.[PAGEID] AND DP.[PAGESEQ] = TOC.[PAGESEQ]
	),

	TAEMAINV1 AS 
	(
  		SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE] AS [EVENTYPE]
		  , TT.[EVENT] AS [Event Term]
		  , CONVERT(DATE,TT.[LM_AE_DT_EVENT]) AS [Date of Event Onset]
		  , TOC.[AE_OUTCOME_DEC]
		  , CONVERT(VARCHAR(5), NULL) AS [LM_AE_SERIOUS_DEC]
		  , NULL AS [In Utero or Neonatal Outcomes]
		  --, TIA.[LM_AE_INTRA_DEC]
		  , TAED.[LM_EVENT_CONFIRM_DEC]
		  , TAED.[NO_EVENT_EXP]
		  , TAED.[AE_SOURCE_DOCS_DEC]
		  , NULL AS [LM_AE_SOURCE_DOCS_ATTACH]
		  , NULL AS [DOCUMENTS_RECEIVED]
		  , TAED.[REASON_HOSP_NOT_FAX]
		  , TAED.[REASON_HOSP_NOT_FAX_Y]
		  , TAED.[REASON_REFUSED]
		  , TAED.[REASON_OTHER]
		  , TAED.[REASON_OTHER_EXP]
	  FROM UTAEEVENT L
		INNER JOIN D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC] AND L.[EVENTYPE] = ''ANA''
		LEFT JOIN [MERGE_SPA].[staging].[TAE_TOP] TT ON DP.[vID] = TT.[vID] AND DP.[PAGEID] = TT.[PAGEID] AND DP.[PAGESEQ] = TT.[PAGESEQ]
		LEFT JOIN TAEOUTCOME TOC ON DP.[vID] = TOC.[vID] AND DP.[PAGEDESC] = TOC.[PAGEDESC]
		LEFT JOIN TAED TAED ON DP.[vID] = TAED.[vID] AND DP.[PAGEDESC] = TAED.[PAGEDESC]
	  WHERE NOT EXISTS (SELECT 1 FROM [MERGE_SPA].[staging].[TAE_PAGE_1] WHERE DP.vID = vID AND DP.PAGEID = PAGEID AND DP.PAGESEQ = PAGESEQ)
	),

	TAEMAINV2 AS 
	(
	  SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE]
		  , TP1.[EVENT] AS [Event Term]
		  , CONVERT(DATE,TP1.[LM_AE_DT_EVENT]) AS [Date of Event Onset]
		  , TP1.[AE_OUTCOME_DEC]
		  , TP1.[LM_AE_SERIOUS_DEC]
		  , NULL AS [In Utero or Neonatal Outcomes]
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
	  FROM UTAEEVENT L
		INNER JOIN D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC]
		INNER JOIN [MERGE_SPA].[staging].[TAE_PAGE_1] TP1 ON DP.vID = TP1.vID AND DP.PAGEID = TP1.PAGEID AND DP.PAGESEQ = TP1.PAGESEQ
	),

	TAEPEQ AS 
	(
	  SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE]
		  , CONVERT(VARCHAR(50),NULL) AS [Event Term]
		  , CONVERT(DATE,NULL) AS [Date of Event Onset]
		  , CONVERT(VARCHAR(23), NULL) AS [AE_OUTCOME_DEC]
		  , CONVERT(VARCHAR(5), NULL) AS [LM_AE_SERIOUS_DEC]
		  , LTRIM(ISNULL(REPLACE(PEQ01.[PREG_NEO_MISCARRIAGE], ''X'', ''Spontaneous abortion/miscarriage''), '''')
				+ISNULL(REPLACE(PEQ01.[PREG_NEO_ELECTIVE_TERMINATION], ''X'', ''Elective Termination''), '''')
				 +ISNULL(REPLACE(PEQ01.[PREG_NEO_BIRTH_DEFECT], ''X'', ''Congenital anomaly/birth defect''), '''')
				 +ISNULL(REPLACE(PEQ01.[PREG_NEO_DEATH], ''X'', ''Death''), '''')) AS [In Utero or Neonatal Outcomes]
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
	  FROM UTAEEVENT L
		INNER JOIN D DP ON DP.[vID] = L.vID AND L.PAGEDESC = DP.PAGEDESC --AND L.EVENTYPE = ''PEQ''
		INNER JOIN [MERGE_SPA].[staging].[TAE_PAGE_1_PEQ] PEQ01 ON DP.vID = PEQ01.vID AND DP.PAGEID = PEQ01.PAGEID AND DP.PAGESEQ = PEQ01.PAGESEQ
	),

	TIA AS 
	(
	  SELECT DISTINCT
			DP.[vID]
		  , DP.SUBNUM
		  , DP.VISITID
		  , DP.VISITSEQ
		  , ISNULL(DP.[PAGEDESC], '''') AS [PAGEDESC]
		  , L.[EVENTYPE]
		  , TIA.[LM_AE_INTRA_DEC]
		  , DP.[REVISION]
	  FROM L L
		INNER JOIN D DP ON DP.[vID] = L.[vID] AND L.[PAGEDESC] = DP.[PAGEDESC] AND L.EVENTYPE <> ''PEQ'' 
		INNER JOIN [MERGE_SPA].[staging].[TAE_INF_A] TIA ON DP.[vID] = TIA.[vID] AND DP.[PAGEID] = TIA.[PAGEID] AND DP.[PAGESEQ] = TIA.[PAGESEQ]
	),

	TAEEVENT AS
	  (
		SELECT DISTINCT
		  L.[vID]
		  , ISNULL(L.[SITENUM], '''') AS [Site ID] 
		  , ISNULL(L.[SUBNUM], '''') AS [Subject ID]
		  , COALESCE(EPRO01.[MD_COD], EP01A.[MD_COD], EP01.[MD_COD],'''') AS [Provider ID]
		  , ISNULL(L.[PAGEDESC], '''') AS [PAGEDESC]
		  , ISNULL(L.[EVENTYPE], '''') AS [Event Type]
		  , COALESCE(TM1.[Event Term], TM2.[Event Term], PEQ.[Event Term] ) AS [Event Term]
		  , COALESCE(TM1.[Date of Event Onset], TM2.[Date of Event Onset], PEQ.[Date of Event Onset]) AS [Date of Event Onset]
		  , CONVERT(DATE,VD.[VISITDATE]) AS [Visit Date]
		  , COALESCE(TM1.[AE_OUTCOME_DEC], TM2.[AE_OUTCOME_DEC], PEQ.[AE_OUTCOME_DEC], '''') AS [Event Outcome]
		  , COALESCE(TM1.[LM_AE_SERIOUS_DEC], TM2.[LM_AE_SERIOUS_DEC], PEQ.[LM_AE_SERIOUS_DEC], '''') AS [Seious outcome]
		  , PEQ.[In Utero or Neonatal Outcomes] AS [In Utero or Neonatal Outcomes]
		  , COALESCE(TIA.[LM_AE_INTRA_DEC], PEQ.[LM_AE_INTRA_DEC], '''') AS [IV antibiotics_TAE INF]
		  , COALESCE(TM1.[LM_EVENT_CONFIRM_DEC], TM2.[LM_EVENT_CONFIRM_DEC], PEQ.[LM_EVENT_CONFIRM_DEC]) AS [Event Confirmation Status/Can you confirm the Event?]
		  , COALESCE(TM1.[NO_EVENT_EXP], TM2.[NO_EVENT_EXP], PEQ.[NO_EVENT_EXP], '''') AS [Not an Event (explanation)]
		  , COALESCE(TM1.[AE_SOURCE_DOCS_DEC], TM2.[AE_SOURCE_DOCS_DEC], PEQ.[AE_SOURCE_DOCS_DEC], '''') AS [Supporting documents]
		  , (CASE WHEN COALESCE(TM1.[LM_AE_SOURCE_DOCS_ATTACH], TM2.[LM_AE_SOURCE_DOCS_ATTACH], PEQ.[LM_AE_SOURCE_DOCS_ATTACH]) IS NOT NULL
					 THEN ''YES''
				ELSE ''NO''
			 END) AS [file attached]
		  , REPLACE(COALESCE(TM1.[DOCUMENTS_RECEIVED], TM2.[DOCUMENTS_RECEIVED], PEQ.[DOCUMENTS_RECEIVED]), ''X'', ''YES'') AS [Supporting documents received by Corrona?]
		  ,(CASE WHEN COALESCE(TM1.[REASON_HOSP_NOT_FAX], TM2.[REASON_HOSP_NOT_FAX], PEQ.[REASON_HOSP_NOT_FAX]) = ''X''
				 THEN ''Hospital would not fax or release documents''
				 WHEN COALESCE(TM1.[REASON_REFUSED], TM2.[REASON_REFUSED], PEQ.[REASON_REFUSED]) = ''X''
				 THEN ''Patient would not authorize release of records''
				 WHEN COALESCE(TM1.[REASON_OTHER], TM2.[REASON_OTHER], PEQ.[REASON_OTHER]) = ''X''
				 THEN ''"Other''
			ELSE ''''
			END) AS [Reason if no supporting documents provided]
		  , COALESCE(TM1.[REASON_HOSP_NOT_FAX_Y], TM2.[REASON_HOSP_NOT_FAX_Y], PEQ.[REASON_HOSP_NOT_FAX_Y]) AS [Hospital would not fax or release documents because]
		  , COALESCE(TM1.[REASON_OTHER_EXP], TM2.[REASON_OTHER_EXP], PEQ.[REASON_OTHER_EXP],'''') AS [Reason if no source provided = Other, specify]
		  , ISNULL(CASE WHEN L.[STATUSID] < 10 THEN ''Incomplete''
				ELSE ''Complete''
		   END, '''') AS [Form status]
	  FROM UTAEEVENT L
		LEFT JOIN [MERGE_SPA].[staging].[VS_01] VD ON L.[vID] = VD.[vID]
		LEFT JOIN TAEMAINV1 TM1 ON L.[vID] = TM1.[vID] AND L.[PAGEDESC] = TM1.[PAGEDESC]
		LEFT JOIN TAEMAINV2 TM2 ON L.[vID] = TM2.[vID] AND L.[PAGEDESC] = TM2.[PAGEDESC]
		LEFT JOIN TAEPEQ PEQ ON L.[vID] = PEQ.[vID] AND L.[PAGEDESC] = PEQ.[PAGEDESC]
		LEFT JOIN TIA TIA ON L.[vID] = TIA.[vID] AND L.[PAGEDESC] = TIA.[PAGEDESC]
		LEFT JOIN [MERGE_SPA].[staging].[EPRO_01] EPRO01 ON L.[vID] = EPRO01.[vID]
		LEFT JOIN [MERGE_SPA].[staging].[EP_01A] EP01A ON L.[vID] = EP01A.[vID]
		LEFT JOIN [MERGE_SPA].[staging].[EP_01] EP01 ON L.[vID] = EP01.[vID]
	)

	SELECT
		  TAE.[vID]
		  ,TAE.[Site ID] 
		  ,TAE.[Subject ID]
		  ,TAE.[Provider ID]
		  ,TAE.[PAGEDESC]
		  ,TAE.[Event Type]
		  ,TAE.[Event Term]
		  ,TAE.[Date of Event Onset]
		  ,TAE.[Visit Date] AS [Follow-up Visit Date]
		  ,TAE.[Event Outcome]
		  ,TAE.[Seious outcome]
		  ,TAE.[In Utero or Neonatal Outcomes]
		  ,TAE.[IV antibiotics_TAE INF]
		  ,TAE.[Event Confirmation Status/Can you confirm the Event?]
		  ,TAE.[Not an Event (explanation)]
		  ,TAE.[Supporting documents]
		  ,TAE.[file attached]
		  ,TAE.[Supporting documents received by Corrona?]
		  ,TAE.[Reason if no supporting documents provided]
		  ,TAE.[Reason if no source provided = Other, specify]
		  ,TAE.[Hospital would not fax or release documents because]
		  ,TAE.[Reason if no source provided = Other, specify]
		  ,TAE.[Form status]
		  ,L.[PAGENAME] AS [Last Page Updated – Name]
		  ,DATEADD(HH,3,ISNULL(L.[DATALMDT], L.[PAGELMDT])) AS [Last Page Updated – Date]
		  ,ISNULL(L.[DATALMBY], L.[PAGELMBY]) AS [Last Page Updated – User]
	FROM 
		TAEEVENT TAE
		LEFT JOIN D L ON L.ROWNUM = 1 AND TAE.vID = L.vID AND L.PAGEDESC = TAE.[PAGEDESC]
	ORDER BY TAE.[Subject ID] ,TAE.[Date of Event Onset],TAE.[Visit Date]'

	--PRINT @DynamicQuery
	EXEC (@DynamicQuery)


END



GO
