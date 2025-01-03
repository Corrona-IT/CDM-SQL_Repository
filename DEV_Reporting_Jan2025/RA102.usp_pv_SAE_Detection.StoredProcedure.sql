USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_pv_SAE_Detection]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [RA102].[usp_pv_SAE_Detection] AS

/*
	CREATE TABLE [Reporting].[RA102].[t_pv_SAE_Detection]
(
	[vID] [bigint] NOT NULL,
	[Site ID] [int] NOT NULL,
	[Subject ID] [bigint] NOT NULL,
	[Provider ID] [int] NULL,
	[Page Description] [nvarchar](255) NOT NULL,
	[Event Type] [nvarchar](255) NOT NULL,
	[Event Term] [nvarchar](50) NULL,
	[Event Specify] [nvarchar](50) NULL,
	[Date of Event Onset] [date] NULL,
	[Visit Date] [date] NULL,
	[Age] [int] NULL,
	[Gender] [nvarchar] (33) NULL,
	[Ethnicity] [nvarchar] (30) NULL,
	[RA Disease Duration] [int] NULL,
	[Outcome] [nvarchar](33) NULL,
	[Death] [varchar](16) NULL,
	[Report Type] [nvarchar] (250) NULL,
	[No Event(specify)] [nvarchar] (250) NULL,
	[S Docs] [nvarchar](100) NULL,
	[Hospitalized] [nvarchar] (4000) NULL,
	[Bio/Sm Mol - Change Today] [nvarchar] (4000) NULL,
	[Bio/Sm Mol - As of Yesterday] [nvarchar] (4000) NULL,
	[Attribution to Drug(s) y/n] [nvarchar] (2000) NULL,
    [Attributed Drug(s)] [nvarchar] (4000) NULL,
	[Form status] [varchar](10) NOT NULL,
	[Last Page Updated – Name] [nvarchar](100) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](200) NULL
)
*/

BEGIN
SET NOCOUNT ON;


 
 

IF OBJECT_ID('tempdb..#TAEQC') IS NOT NULL DROP TABLE #TAEQC

SELECT DISTINCT TAEQC.[vID]
      ,CAST(DATEPART(YEAR, VD.VISITDATE) AS bigint) AS VisitYear
      ,TAEQC.[Site ID]
      ,TAEQC.[Subject ID]
      ,TAEQC.[Provider ID]
      ,TAEQC.[PAGEDESC] AS [Page Description]
      ,TAEQC.[Event Type]
      ,TAEQC.[Event Term]
      ,TAEQC.[Event Specify]
      ,TAEQC.[Date of Event Onset]
      ,TAEQC.[Visit Date]
      ,TAEQC.[Event Outcome] AS [Outcome]
	  ,CASE WHEN UPPER(TAEQC.[Event Outcome]) LIKE '%DEATH%' THEN 'Yes' ELSE 'No' END AS [Death]
      ,TAEQC.[Serious outcome]
      ,TAEQC.[Report Type]
      ,TAEQC.[No Event(specify)]
	  ,TAEQC.[Supporting documents] AS [S Docs]
	  ,TM.[Hospitalized]
      ,TAEQC.[Form status]
      ,TAEQC.[Last Page Updated – Name]
      ,TAEQC.[Last Page Updated – Date]
      ,TAEQC.[Last Page Updated – User]

INTO #TAEQC 

FROM [Reporting].[RA102].[t_pv_TAEQC] TAEQC
LEFT JOIN 
(SELECT DISTINCT vID
       ,SITENUM AS [Site ID]
	   ,SUBNUM AS [Subject ID]
	   ,ISNULL(REPLACE(TM.[LM_AE_HOSP], 'X', 'Yes'), '') AS [Hospitalized]
	   ,ROW_NUMBER() OVER(PARTITION BY [vID], [SITENUM], [SUBNUM] ORDER BY [LM_AE_SOURCE_DOCS_DEC] DESC, [LM_AE_HOSP] DESC) AS ROWNUM
FROM [MERGE_RA_Japan].[staging].[TAE_MAIN1] TM 
) TM ON TM.vID=TAEQC.vID AND TM.ROWNUM=1
LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON VD.vID=TAEQC.vID
WHERE ISNUMERIC(TAEQC.[Subject ID])=1

--SELECT * FROM #TAEQC


IF OBJECT_ID('tempdb..#DEM') IS NOT NULL DROP TABLE #DEM

   SELECT DISTINCT A.[SITENUM] AS [Site ID]
		,A.[SUBID] AS [SUBID]
		,A.[SUBNUM] AS [Subject ID]
		,VD.VISITDATE AS [EnrollDate]
		,SUBSTRING(S.[GENDER_DEC], 2, 25) AS [Gender]
		,S.[Ethnicity]
		,A2.[IDENT2] AS [BirthYear]
		,P.YR_ONSET_RA AS [OnsetYear]
		,(YEAR(GETDATE()) - P.[YR_ONSET_RA]) AS [RA Disease Duration]
	INTO #DEM		
	FROM [MERGE_RA_Japan].[dbo].[DAT_SUB] A
		LEFT JOIN 
		(SELECT CAST(SITENUM AS int) AS SITENUM, CAST(SUBID AS bigint) AS SUBID, SUBNUM AS SUBNUM, CAST(IDENT2 AS int) AS IDENT2, [LASTMDT]
			   ,ROW_NUMBER() OVER(PARTITION BY CAST([SUBID] AS bigint) ORDER BY [LASTMDT] DESC) AS ROWNUM
		FROM [MERGE_RA_Japan].[dbo].[DAT_ASUB]
		) A2 ON ROWNUM = 1 AND A.[SITENUM] = A2.[SITENUM] AND A.[SUBNUM] = A2.[SUBNUM]
		LEFT JOIN
			(SELECT DISTINCT CAST(SUB.[SITENUM] AS int) AS [SITENUM]
			     , CAST(SUB.SUBID AS bigint) AS SUBID
				 , SUB.[SUBNUM] AS [SUBNUM]
				 ,SUB.[GENDER_DEC]
				 ,CASE WHEN SUB.[ETH_OTHER] IS NULL AND SUB.[ETH_JAPANESE] IS NULL AND
				    SUB.[ETH_KOREAN] IS NULL AND SUB.[ETH_CHINESE] IS NULL THEN ''
					   WHEN SUB.[ETH_OTHER] = 'X' THEN 'Other'
					   WHEN SUB.[ETH_CHINESE] = 'X' THEN 'Chinese'
					   WHEN SUB.[ETH_JAPANESE] = 'X' THEN 'Japanese'
					   WHEN SUB.[ETH_KOREAN] = 'X' THEN 'Korean'
				  ELSE 'Unknown' END AS [Ethnicity]
				,SUB.[YR_RA_BEGIN] AS [RAStartYear]
			 FROM [MERGE_RA_Japan].[dbo].[SUB_01] SUB
			 WHERE [VISNAME] = 'Enrollment'
			 ) S ON A.[SITENUM] = S.[SITENUM] AND A.[SUBNUM] = S.[SUBNUM]
		LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON VD.SITENUM=S.SITENUM AND VD.SUBID=S.SUBID AND VD.[VISNAME]='Enrollment'
		LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] P ON P.SITENUM=S.SITENUM AND P.SUBID=S.SUBID AND P.[VISNAME]='Enrollment'
		WHERE ISNUMERIC(A.SUBNUM)=1

--SELECT * FROM #DEM order by [Site ID], [Subject ID]

IF OBJECT_ID('tempdb..#TAEQCListing') IS NOT NULL DROP TABLE #TAEQCListing

SELECT DISTINCT TAE.[vID]
      ,TAE.[Site ID]
      ,TAE.[Subject ID]
      ,TAE.[Provider ID]
      ,TAE.[Page Description]
      ,TAE.[Event Type]
      ,TAE.[Event Term]
      ,TAE.[Event Specify]
      ,TAE.[Date of Event Onset]
      ,TAE.[Visit Date]
	  ,(DATEPART(YEAR, TAE.[Visit Date]) - DEM.[BirthYear]) AS Age
	  ,DEM.Gender
	  ,DEM.Ethnicity
	  ,(YEAR(GETDATE()) - DEM.OnsetYear) AS [RA Disease Duration]
      ,TAE.[Outcome]
	  ,TAE.[Death]
      ,TAE.[Report Type]
      ,TAE.[No Event(specify)]
	  ,TAE.[S Docs]
	  ,TAE.[Hospitalized]

      ,TAE.[Form status]
      ,TAE.[Last Page Updated – Name]
      ,TAE.[Last Page Updated – Date]
      ,TAE.[Last Page Updated – User]

INTO #TAEQCListing

FROM #TAEQC TAE
LEFT JOIN #DEM DEM ON DEM.[Site ID]=TAE.[Site ID] AND DEM.[Subject ID]=TAE.[Subject ID]


--Get biologics attributed to TAE

IF OBJECT_ID('tempdb..#BioAttributed') IS NOT NULL DROP TABLE #BioAttributed

SELECT DISTINCT vID
      ,[Site ID]
	  ,[Subject ID]
	  ,Attributed
	  ,AttributedDrug
INTO #BioAttributed
FROM
(
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_ORENCIA_ATTRIBUTED], '')=1 THEN 'ORENCIA' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_ORENCIA_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_HUMIRA_ATTRIBUTED], '')=1 THEN 'HUMIRA' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_HUMIRA_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_CIMZIA_ATTRIBUTED], '')=1 THEN 'CIMZIA' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_CIMZIA_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_ENBREL_ATTRIBUTED], '')=1 THEN 'ENBREL' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_ENBREL_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_SIMPONI_ATTRIBUTED], '')=1 THEN 'SIMPONI' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_SIMPONI_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_REMICADE_ATTRIBUTED], '')=1 THEN 'REMICASE' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_REMICADE_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_INFXBIOSIM_ATTRIBUTED], '')=1 THEN 'INFXBIOSIM' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_INFXBIOSIM_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_ACTEMRA_ATTRIBUTED], '')=1 THEN 'ACTEMRA' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_ACTEMRA_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_XELJANZ_ATTRIBUTED], '')=1 THEN 'XELJANZ' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_XELJANZ_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_BUCILLAMINE_ATTRIBUTED], '')=1 THEN 'BUCILLAMINE' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_BUCILLAMINE_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_KEARAMU_ATTRIBUTED], '')=1 THEN 'KEARAMU' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_KEARAMU_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_ARAVA_ATTRIBUTED], '')=1 THEN 'ARAVA' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_ARAVA_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_MTX_ATTRIBUTED], '')=1 THEN 'MTX' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_MTX_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_PREDNISONE_ATTRIBUTED], '')=1 THEN 'PREDNISONE' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_PREDNISONE_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_PREDNISOLONE_ATTRIBUTED], '')=1 THEN 'PREDNISOLONE' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_PREDNISOLONE_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_SSZ_ATTRIBUTED], '')=1 THEN 'SULFASALAZINE' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_SSZ_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_PROGRAF_ATTRIBUTED], '')=1 THEN 'PROGRAF' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_PROGRAF_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_DRUGOTHER_ATTRIBUTED], '')=1 THEN 'OTHER DRUG' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_DRUGOTHER_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_HUMIRA_BIOSIM_ATTRIBUTED], '')=1 THEN 'ADALIMUMAB BIOSIMILAR' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_HUMIRA_BIOSIM_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_ENBREL_BIOSIM_ATTRIBUTED], '')=1 THEN 'ETANERCEPT BIOSIMILAR' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_ENBREL_BIOSIM_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_ENBREL_BIOSIM_ATTRIBUTED], '')=1 THEN 'ETANERCEPT BIOSIMILAR' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_OLUMIANT_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_XELJANZ_XR_ATTRIBUTED], '')=1 THEN 'XELJANZ XR' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_XELJANZ_XR_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_KEVZARA_ATTRIBUTED], '')=1 THEN 'KEVZARA' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_KEVZARA_ATTRIBUTED], '')=1
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL([AEMED_INVEST_AGENT_ATTRIBUTED], '')=1 THEN 'INVESTIGATIONAL AGENT' ELSE '' END AS AttributedDrug
	  ,'Yes' AS Attributed
FROM [MERGE_RA_Japan].[staging].[TAE_DRUG] DRUG WHERE ISNULL([AEMED_INVEST_AGENT_ATTRIBUTED], '')=1

) BA
WHERE vID IN (SELECT vID FROM #TAEQCListing TQC)
AND ISNULL(AttributedDrug, '')<>''
ORDER BY [Site ID], [Subject ID], [vID], AttributedDrug

--SELECT * FROM #BioAttributed


--Get medications Change Today

IF OBJECT_ID('tempdb..#ChangeToday') IS NOT NULL DROP TABLE #ChangeToday

SELECT DISTINCT vID
      ,[Site ID]
	  ,[Subject ID]
	  ,ChangeToday

INTO #ChangeToday
FROM
(
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.ORENCIA_USETODAY, '')='X' THEN 'ORENCIA' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.ORENCIA_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.HUMIRA_USETODAY, '')='X' THEN 'HUMIRA' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.HUMIRA_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.HUMIRA_BIOSIM_USETODAY, '')='X' THEN 'ADALIMUMAB BIOSIMILAR' + ISNULL(' - ' + PRO06.HUMIRA_BIOSIM_SPECIFY, '') ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.HUMIRA_BIOSIM_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.CIMZIA_USETODAY, '')='X' THEN 'CIMZIA' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.CIMZIA_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.ENBREL_USETODAY, '')='X' THEN 'ENBREL' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.ENBREL_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.ENBREL_BIOSIM_USETODAY, '')='X' THEN 'ENTANERCEPT BIOSIMILAR' + ISNULL(' - ' + PRO06.ENBREL_BIOSIM_SPECIFY, '') ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.ENBREL_BIOSIM_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.SIMPONI_USETODAY, '')='X' THEN 'SIMPONI' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.SIMPONI_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.REMICADE_USETODAY, '')='X' THEN 'REMICADE' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.REMICADE_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.REMICADE_BIOSIM_USETODAY, '')='X' THEN 'REMICADE BS' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.REMICADE_BIOSIM_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.ACTEMRA_USETODAY, '')='X' THEN 'ACTEMRA' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.ACTEMRA_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.XELJANZ_USETODAY, '')='X' THEN 'XELJANZ' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.XELJANZ_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.XELJANZ_XR_USETODAY, '')='X' THEN 'XELJANZ XR' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.XELJANZ_XR_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.BUC_USETODAY, '')='X' THEN 'BUCILLAMINE' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.BUC_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.KEARAMU_USETODAY, '')='X' THEN 'KEARAMU' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.KEARAMU_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.ARAVA_USETODAY, '')='X' THEN 'ARAVA' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.ARAVA_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.MTX_USETODAY, '')='X' THEN 'MTX' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.MTX_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.PRED_USETODAY, '')='X' THEN 'PREDNISONE' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.PRED_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.AZULFIDINE_USETODAY, '')='X' THEN 'AZULFIDINE' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.AZULFIDINE_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.PROGRAF_USETODAY, '')='X' THEN 'PROGRAF' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.PROGRAF_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.OLUMIANT_USETODAY, '')='X' THEN 'BARICITINIB (OLUMIANT)' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.OLUMIANT_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.KEVZARA_USETODAY, '')='X' THEN 'SARILUMAB (KEVZARA)' ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.KEVZARA_USETODAY, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PRO06.OTHER_BIONB_USETODAY, '')='X' THEN ISNULL(PRO06.OTHER_BIONB_SPECIFY, '') ELSE '' END AS ChangeToday
FROM [MERGE_RA_Japan].[staging].[PRO_06] PRO06 WHERE ISNULL(PRO06.OTHER_BIONB_USETODAY, '')='X'
) CT
WHERE vID IN (SELECT vID FROM #TAEQCListing TQC)
AND ISNULL(ChangeToday, '')<>''
ORDER BY [Site ID], [Subject ID], [vID], ChangeToday

--SELECT * FROM #ChangeToday


--Get medications as of Yesterday

IF OBJECT_ID('tempdb..#AsofYesterday') IS NOT NULL DROP TABLE #AsofYesterday

SELECT DISTINCT vID
      ,[Site ID]
	  ,[Subject ID]
	  ,Yesterday

INTO #AsofYesterday
FROM
(
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.ORENCIA_USE, '')='X' THEN 'ORENCIA' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.ORENCIA_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.HUMIRA_USE, '')='X' THEN 'HUMIRA' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.HUMIRA_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.HUMIRA_BIOSIM_USE, '')='X' THEN 'ADALIMUMAB BIOSIMILAR' + ISNULL(' - ' + PE4.HUMIRA_BIOSIM_SPECIFY, '') ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.HUMIRA_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.CIMZIA_USE, '')='X' THEN 'CIMZIA' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.CIMZIA_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.ENBREL_USE, '')='X' THEN 'ENBREL' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.ENBREL_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.ENBREL_BIOSIM_USE, '')='X' THEN 'ENTANERCEPT BIOSIMILAR' + ISNULL(' - ' + PE4.ENBREL_BIOSIM_SPECIFY, '') ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.ENBREL_BIOSIM_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.SIMPONI_USE, '')='X' THEN 'SIMPONI' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.SIMPONI_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.REMICADE_USE, '')='X' THEN 'REMICADE' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.REMICADE_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.REMICADE_BIOSIM_USE, '')='X' THEN 'REMICADE BS' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.REMICADE_BIOSIM_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.ACTEMRA_USE, '')='X' THEN 'ACTEMRA' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.ACTEMRA_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.XELJANZ_USE, '')='X' THEN 'XELJANZ' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.XELJANZ_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.XELJANZ_XR_USE, '')='X' THEN 'XELJANZ XR' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.XELJANZ_XR_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.OLUMIANT_USE, '')='X' THEN 'BARICITINIB (OLUMIANT)' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.OLUMIANT_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.KEVZARA_USE, '')='X' THEN 'SARILUMAB (KEVZARA)' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.KEVZARA_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.INVEST_AGENT_USE, '')='X' THEN 'INVESTIGATIONAL AGENT' ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.INVEST_AGENT_USE, '')='X'
UNION
SELECT DISTINCT vID, SITENUM AS [Site ID], SUBNUM AS [Subject ID]
	  ,CASE WHEN ISNULL(PE4.OTH_BIOTS_USE, '')='X' THEN  PE4.OTH_BIOTS_TEXT ELSE '' END AS Yesterday
FROM [MERGE_RA_Japan].[staging].[PE_04] PE4 WHERE ISNULL(PE4.OTH_BIOTS_USE, '')='X'
) AOF
WHERE vID IN (SELECT vID FROM #TAEQCListing TQC)
AND ISNULL(Yesterday, '')<>''
ORDER BY [Site ID], [Subject ID], [vID], Yesterday

--SELECT * FROM #AsofYesterday


--Get Conmeds attributed to TAE 

IF OBJECT_ID('tempdb..#ConMed') IS NOT NULL DROP TABLE #ConMed

SELECT DISTINCT vID
      ,SITENUM AS [Site ID]
	  ,SUBNUM AS [Subject ID]
      ,CASE WHEN ISNULL([AE_OTHMED1_ATTRIBUTED], '')=0 THEN 'No'
	   WHEN ISNULL([AE_OTHMED1_ATTRIBUTED], '')=1 THEN 'Yes'
	   ELSE ''
	   END AS Attributed
	  ,[AE_OTHMED1_NAME] AS AttributedDrug
INTO #ConMed
FROM [MERGE_RA_Japan].[staging].[CONMED]
WHERE vID IN (SELECT vID FROM #TAEQCListing TQC)
AND ISNULL([AE_OTHMED1_ATTRIBUTED], '')=1
ORDER BY SITENUM, SUBNUM, vID, [AE_OTHMED1_NAME]
--SELECT * FROM #ConMed


--Get attributed biologics and conmeds

IF OBJECT_ID('tempdb..#DrugAttribution') IS NOT NULL DROP TABLE #DrugAttribution

SELECT [vID]
      ,[Site ID]
	  ,[Subject ID]
	  ,[Attributed]
	  ,[AttributedDrug]

INTO #DrugAttribution
FROM
(SELECT * FROM #ConMed
UNION
SELECT * FROM #BioAttributed) ADA

--SELECT * FROM #DrugAttribution 


--Stuff attributed meds, changes today meds, as of yesterday meds

IF OBJECT_ID('tempdb..#MedAttributed') IS NOT NULL DROP TABLE #MedAttributed

SELECT DISTINCT TQC.[vID]
      ,TQC.[Site ID]
	  ,TQC.[Subject ID]

  	  ,STUFF((
        SELECT ', ' + Attributed 
        FROM #DrugAttribution DA
		WHERE DA.vID=TQC.vID
		FOR XML PATH('')
        )
        ,1,1,'') AS [Attribution to Drug(s) y/n]

  	  ,STUFF((
        SELECT ', ' + AttributedDrug 
        FROM #DrugAttribution DA
		WHERE DA.vID=TQC.vID
		FOR XML PATH('')
        )
        ,1,1,'') AS [Attributed Drug(s)]

  	  ,STUFF((
        SELECT ', '+ ChangeToday 
        FROM #ChangeToday CT
		WHERE CT.vID=TQC.vID
		FOR XML PATH('')
        )
        ,1,1,'') AS [Bio/Sm Mol - Change Today]

  	  ,STUFF((
        SELECT ', '+ Yesterday 
        FROM #AsofYesterday AY
		WHERE AY.vID=TQC.vID
		FOR XML PATH('')
        )
        ,1,1,'') AS [Bio/Sm Mol - As of Yesterday]

 INTO #MedAttributed
 FROM #TAEQCListing TQC
 
 --SELECT * FROM #MedAttributed WHERE [Site ID] NOT IN (9999, 9998, 9997)

 TRUNCATE TABLE [Reporting].[RA102].[t_pv_SAE_Detection] 

INSERT INTO [RA102].[t_pv_SAE_Detection]

(
	   [vID]
      ,[Site ID]
      ,[Subject ID]
      ,[Provider ID]
      ,[Page Description]
      ,[Event Type]
      ,[Event Term]
      ,[Event Specify]
      ,[Date of Event Onset]
      ,[Visit Date]
      ,[Age]
      ,[Gender]
      ,[Ethnicity]
      ,[RA Disease Duration]
      ,[Outcome]
      ,[Death]
      ,[Report Type]
      ,[No Event(specify)]
      ,[S Docs]
      ,[Hospitalized]
      ,[Bio/Sm Mol - Change Today]
      ,[Bio/Sm Mol - As of Yesterday]
	  ,[Attribution to Drug(s) y/n]
	  ,[Attributed Drug(s)]
      ,[Form status]
      ,[Last Page Updated – Name]
      ,[Last Page Updated – Date]
      ,[Last Page Updated – User]
)

  SELECT DISTINCT TAE.[vID]
        ,TAE.[Site ID]
		,TAE.[Subject ID]
		,TAE.[Provider ID]
		,TAE.[Page Description]
		,TAE.[Event Type]
		,TAE.[Event Term]
		,TAE.[Event Specify]
		,TAE.[Date of Event Onset]
		,TAE.[Visit Date]
		,TAE.Age
		,LTRIM(TAE.Gender) AS Gender
		,TAE.Ethnicity
		,TAE.[RA Disease Duration]
		,LTRIM(TAE.Outcome) AS OUTCOME
		,LTRIM(TAE.Death) AS Death
		,LTRIM(TAE.[Report Type]) AS [Report Type]
		,LTRIM(TAE.[No Event(specify)]) AS [No Event(specify)]
		,LTRIM(TAE.[S Docs]) AS [S Docs]
		,LTRIM(TAE.Hospitalized) AS Hospitalized
  	    ,MA.[Bio/Sm Mol - Change Today]
  	    ,MA.[Bio/Sm Mol - As of Yesterday]
		,CASE WHEN MA.[Attribution to Drug(s) y/n] LIKE '%Yes%' THEN 'Yes'
		 ELSE ''
		 END AS [Attribution to Drug(s) y/n]
		,MA.[Attributed Drug(s)]
		,TAE.[Form status]
		,TAE.[Last Page Updated – Name]
		,TAE.[Last Page Updated – Date]
		,TAE.[Last Page Updated – User]
  FROM #TAEQCListing TAE
  LEFT JOIN #MedAttributed MA ON MA.vID=TAE.vID




END


--SELECT * FROM [Reporting].[RA102].[t_pv_SAE_Detection] ORDER BY [Site ID], [Subject ID], [Event Type], [Date of Event Onset]
GO
