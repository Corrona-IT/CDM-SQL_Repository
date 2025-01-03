USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_LabResults]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [RA102].[v_op_LabResults] as



WITH months as 
(
          select cast(1  as int) as MonthCode, 'Jan' as MonthString
	union select cast(2  as int) as MonthCode, 'Feb' as MonthString
	union select cast(3  as int) as MonthCode, 'Mar' as MonthString
	union select cast(4  as int) as MonthCode, 'Apr' as MonthString
	union select cast(5  as int) as MonthCode, 'May' as MonthString
	union select cast(6  as int) as MonthCode, 'Jun' as MonthString
	union select cast(7  as int) as MonthCode, 'Jul' as MonthString
	union select cast(8  as int) as MonthCode, 'Aug' as MonthString
	union select cast(9  as int) as MonthCode, 'Sep' as MonthString
	union select cast(10 as int) as MonthCode, 'Oct' as MonthString
	union select cast(11 as int) as MonthCode, 'Nov' as MonthString
	union select cast(12 as int) as MonthCode, 'Dec' as MonthString
)


,LAB_RESULTS AS 
(
       SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
      ,CASE WHEN L.LAB_TESTS_DT_DY <> '' 
			THEN L.LAB_TESTS_DT_DY
			ELSE L.CREATININE_DATE_DY
	     END AS [Collection Day]
      ,CASE WHEN L.LAB_TESTS_DT_MO <> '' 
			THEN L.LAB_TESTS_DT_MO
			ELSE L.CREATININE_DATE_MO 
	     END AS [Collection Month]
      ,CASE WHEN L.LAB_TESTS_DT_YR <> '' 
			THEN L.LAB_TESTS_DT_YR
			ELSE L.CREATININE_DATE_YR 
	    END AS [Collection Year]	  
	  ,'WBC (10^3^/mL)' AS [Lab test name]
      ,CAST([WBC] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	   ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CBC_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CBC_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CBC_DATE_YR] END AS [Collection Year]
	  ,'Neutrophils (%)' AS [Lab test name]
      ,CAST([NEUTROPHILS] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CBC_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CBC_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CBC_DATE_YR] END AS [Collection Year]
	  ,'Hematocrit (%)' AS [Lab test name]
      ,CAST([HCT] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CBC_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CBC_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CBC_DATE_YR] END AS [Collection Year]
	  ,'Hemoglobin (g/dL)' AS [Lab test name]
      ,CAST([HGB] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CBC_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CBC_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CBC_DATE_YR] END AS [Collection Year]
	  ,'Platelets (10^3^/mL)' AS [Lab test name]
      ,CAST([PLATELETS] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [LFT_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [LFT_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [LFT_DATE_YR] END AS [Collection Year]
	  ,'AST (SGOT) (IU/L)' AS [Lab test name]
      ,CAST([AST] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [LFT_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [LFT_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [LFT_DATE_YR] END AS [Collection Year]
	  ,'ALT (SGPT) (IU/L)' AS [Lab test name]
      ,CAST([ALT] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [LFT_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [LFT_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [LFT_DATE_YR] END AS [Collection Year]
	  ,'Total Bilirubin(mg/dL)' AS [Lab test name]
      ,CAST([TOT_BILIRUBIN] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [LFT_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [LFT_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [LFT_DATE_YR] END AS [Collection Year]
	  ,'Albumin(g/dL)' AS [Lab test name]
      ,CAST([ALBUMIN] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CREATININE_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CREATININE_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CREATININE_DATE_YR] END AS [Collection Year]
	  ,'Creatinine (mg/dL)' AS [Lab test name]
      ,CAST([CREATININE] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [ESR_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [ESR_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [ESR_DATE_YR] END AS [Collection Year]
	  ,'ESR (mm/hr)' AS [Lab test name]
      ,CAST([ESR] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CRP_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CRP_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CRP_DATE_YR] END AS [Collection Year]
	  ,'CRP' AS [Lab test name]
      ,CAST([CRP] AS varchar) AS [Lab result value]
	  ,CASE WHEN [CRP_TYPE] = '1'
			THEN 'mg/L'
			WHEN [CRP_TYPE] = '2'
			THEN 'mg/dL' END AS [CRP Units]
	  ,[UL_CRP] AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,CASE WHEN [LAB_TESTS_DT_DY] <> '' 
			THEN [LAB_TESTS_DT_DY]
			ELSE [CPK_DATE_DY] END AS [Collection Day]
      ,CASE WHEN [LAB_TESTS_DT_MO] <> '' 
			THEN [LAB_TESTS_DT_MO]
			ELSE [CPK_DATE_MO] END AS [Collection Month]
      ,CASE WHEN [LAB_TESTS_DT_YR] <> '' 
			THEN [LAB_TESTS_DT_YR]
			ELSE [CPK_DATE_YR] END AS [Collection Year]
	  ,'CPK (IU/L)' AS [Lab test name]
      ,CAST([CPK] as varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[CCP_DATE_DY] AS [Collection Day]
      ,[CCP_DATE_MO] AS [Collection Month]
      ,[CCP_DATE_YR] AS [Collection Year]
	  ,'CCP Abs (U/mL)' AS [Lab test name]
      ,CAST([CCP] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,[UL_CCP] AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[RF_DATE_DY] AS [Collection Day]
      ,[RF_DATE_MO] AS [Collection Month]
      ,[RF_DATE_YR] AS [Collection Year]
	  ,'RF (IU/mL)' AS [Lab test name]
      ,CAST([RF] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,[UL_RF] AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[VITAMIND_DATE_DY] AS [Collection Day]
      ,[VITAMIND_DATE_MO] AS [Collection Month]
      ,[VITAMIND_DATE_YR] AS [Collection Year]
	  ,'25-OH Vitamin D (ng/ml)' AS [Lab test name]
      ,CAST([VITAMIND_RES] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'HDL (mg/dL)' AS [Lab test name]
      ,CAST([HDL] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'LDL (mg/dL)' AS [Lab test name]
      ,CAST([LDL] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'Total cholesterol (mg/dL)' AS [Lab test name]
      ,CAST([CHOLESTEROL] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'Triglycerides (mg/dL)' AS [Lab test name]
      ,CAST([TRIGLYCERIDES] AS varchar) AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'Erosions' AS [Lab test name]
      ,CASE WHEN [EROSIONS_PRES] = '0'
			THEN 'not present'
			WHEN [EROSIONS_PRES] = '1'
			THEN 'present'
			WHEN [EROSIONS_PRES] = '2'
			THEN 'new' END AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'Joint space narrowing' AS [Lab test name]
      ,CASE WHEN [JT_SP_NARROW_PRES] = '0'
			THEN 'not present'
			WHEN [JT_SP_NARROW_PRES] = '1'
			THEN 'present'
			WHEN [JT_SP_NARROW_PRES] = '2'
			THEN 'new' END AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID

  UNION

  SELECT  L.vID
	  ,L.[SITENUM] AS [Site ID]
      ,L.[SUBNUM] AS [Subject ID]
      ,L.[VISNAME] AS [Visit Name]
      ,L.[PAGENAME] AS [Page Name]
	  ,L.[VISITSEQ] AS [Visit Sequence]
	  ,V.[VISITDATE] AS [Visit Date]
	  ,[LIPID_DATE_DY] AS [Collection Day]
      ,[LIPID_DATE_MO] AS [Collection Month]
      ,[LIPID_DATE_YR] AS [Collection Year]
	  ,'Deformity' AS [Lab test name]
      ,CASE WHEN [JT_DEFORM_PRES] = '0'
			THEN 'not present'
			WHEN [JT_DEFORM_PRES] = '1'
			THEN 'present'
			WHEN [JT_DEFORM_PRES] = '2'
			THEN 'new' END AS [Lab result value]
	  ,NULL AS [CRP Units]
	  ,NULL AS [Upper Limit Normal (CRP & RF Only)]
  FROM [MERGE_RA_Japan].[staging].[LAB] AS L
  INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] V ON L.vid = V.vid AND L.SUBID = V.SUBID
  )

  SELECT vID
        ,[Site ID]
		,[Subject ID]
		,[Visit Name]
		,[Page Name]
		,[Visit Date]
		,(ISNULL(CAST([Collection Day] AS NVARCHAR), '') + ISNULL('-' + MonthString, '') + ISNULL('-' + CAST([Collection Year] AS NVARCHAR),'')) as [Collection Date]
		,[Lab test name]
		,[Lab result value]
		,[CRP Units]
		,[Upper Limit Normal (CRP & RF Only)]

  FROM LAB_RESULTS
  LEFT JOIN months M on M.MonthCode=LAB_RESULTS.[Collection Month]
  ---ORDER BY LAB_RESULTS.[Site ID], LAB_RESULTS.[Subject ID], LAB_RESULTS.[Visit Date]


GO
