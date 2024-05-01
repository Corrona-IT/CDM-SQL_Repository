USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_AbbrevNonSerious]    Script Date: 5/1/2024 1:26:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [GPP510].[v_pv_AbbrevNonSerious] AS

SELECT DISTINCT *
FROM (
SELECT DISTINCT COMORB.[SITENUM]
      ,COMORB.[SUBID]
      ,COMORB.[SUBNUM]
      ,COMORB.[VISNAME]
	  ,V.VISDAT
      ,COMORB.[PAGENAME]
      ,COMORB.[VISITID]
      ,COMORB.[VISITSEQ]
      ,COMORB.[PAGEID]
      ,COMORB.[PAGESEQ]
	  ,COMORB.[AECAT]
      ,COALESCE([TERM_ANA_EN_DEC],[TERM_CVD_EN_DEC],[TERM_HEP_EN_DEC],[TERM_CAN_EN_DEC], [TERM_NEU_EN_DEC], [TERM_VTE_EN_DEC], [TERM_GEN_EN_DEC], [TERM_ANA_FU_DEC], [TERM_CVD_FU_DEC],[TERM_HEP_FU_DEC], [TERM_CAN_FU_DEC], [TERM_NEU_FU_DEC], [TERM_VTE_FU_DEC], [TERM_GEN_FU_DEC]) AS NonSeriousEvent
      ,COMORB.[PAGELMBY]
      ,COMORB.[PAGELMDT]
      ,COMORB.[DATALMBY]
      ,COMORB.[DATALMDT]

  FROM [ZELTA_GPP].[dbo].[MD_AE] COMORB
  LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.SUBID=COMORB.SUBID AND V.vID=COMORB.vID 
  WHERE V.PAGENAME='Visit Information'
  AND COMORB.VISNAME<>'Enrollment'

  UNION

  SELECT DISTINCT INF.[SITENUM]
      ,INF.[SUBID]
      ,INF.[SUBNUM]
      ,INF.[VISNAME]
	  ,V.VISDAT
      ,INF.[PAGENAME]
      ,INF.[VISITID]
      ,INF.[VISITSEQ]
      ,INF.[PAGEID]
      ,INF.[PAGESEQ]
	  ,'Infection' AS AECAT
	  ,COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent
	  ,INF.[PAGELMBY]
      ,INF.[PAGELMDT]
      ,INF.[DATALMBY]
      ,INF.[DATALMDT]

  FROM [ZELTA_GPP].[dbo].[MD_INF] INF
  LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.SUBID=INF.SUBID AND V.vID=INF.vID
  WHERE 1=1
  AND V.PAGENAME='Visit Information'
  AND INF.VISNAME<>'Enrollment'
  AND ISNULL([SERIOUS_DEC], '') <> 'Yes'
  AND ISNULL([IVANINFEC_DEC], '') <> 'Yes'
  AND (ISNULL(ASP, '')<>'X' AND ISNULL(BAR, '')<>'X' AND ISNULL(BKV, '')<>'X' AND ISNULL(BLAST, '')<>'X' AND ISNULL(CAMP, '')<>'X' AND ISNULL(CD, '')<>'X' AND ISNULL(CRYP, '')<>'X' AND ISNULL(CYTO, '')<>'X' AND ISNULL(EBV, '')<>'X' AND ISNULL(FUS, '')<>'X' AND ISNULL(HBV, '')<>'X' AND ISNULL(HCV, '')<>'X' AND ISNULL(HSV, '')<>'X' AND ISNULL(HP, '')<>'X' AND ISNULL(JC, '')<>'X' AND ISNULL(LEG, '')<>'X' AND ISNULL(LEIS, '')<>'X' AND ISNULL(LICH, '')<>'X' AND ISNULL(LI, '')<>'X' AND ISNULL(MICRO, '')<>'X' AND ISNULL(MUCR, '')<>'X' AND ISNULL(MYCE, '')<>'X' AND ISNULL(TB, '')<>'X' AND ISNULL(NOCAR, '')<>'X' AND ISNULL(PCM, '')<>'X' AND ISNULL(PN, '')<>'X' AND ISNULL(PBOY, '')<>'X' AND ISNULL(RHZ, '')<>'X' AND ISNULL(SL, '')<>'X' AND ISNULL(SCED, '')<>'X' AND ISNULL(SHIG, '')<>'X' AND ISNULL(SPOR, '')<>'X' AND ISNULL(STRO, '')<>'X' AND ISNULL(TALA, '')<>'X' AND ISNULL(TOXO, '')<>'X' AND ISNULL(CHAG, '')<>'X' AND ISNULL(VZV, '')<>'X' AND ISNULL(VIBR, '')<>'X' AND ISNULL([OF], '')<>'X' AND ISNULL(OM, '')<>'X')
  ) EVENTS
  WHERE 1=1
  AND NonSeriousEvent NOT LIKE '%{TAE}%'

GO
