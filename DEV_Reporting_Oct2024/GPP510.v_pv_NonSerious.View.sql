USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_NonSerious]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [GPP510].[v_pv_NonSerious] AS

WITH DRUGS AS (

SELECT SITENUM,
		SUBNUM,
		SUBID,
		VID,
		PAGENAME,
		VISNAME,
		VISITSEQ,
		PAGESEQ,
		drug,
		drugoth,
		RXDAT as prescribeddate,
		CAST(COALESCE(fstdat, pstdat) AS DATE) as startdate,
		CAST(COALESCE(fendat, pendat) AS DATE) as enddate

FROM
(
SELECT d.SITENUM,
	   d.SUBNUM,
	   d.SUBID,
	   d.vID,
	   d.PAGENAME,
	   d.VISNAME,
	   d.VISITSEQ,
	   d.PAGESEQ,
	   replace(d.DRUG_DEC, ' (specify)', '') AS drug,
	   d.DRUGOTH,
	   case WHEN D.PSTDAT LIKE 'UNK-%' THEN ''
	   when d.pstdat like '%-UNK%' THEN replace(d.PSTDAT, '-UNK', '-01') 
	   else d.pstdat
	   end as pstdat,
	   case WHEN d.pendat LIKE 'UNK-%' THEN ''
	   when d.pendat like '%-UNK%' THEN replace(d.pendat, '-UNK', '-01') 
	   else d.pendat
	   end as pendat,
	   CAST(d.RXDAT AS date) AS RXDAT,
	   CAST(d.FSTDAT AS date) AS FSTDAT,
	   cast(d.FENDAT as date) AS FENDAT

FROM [ZELTA_GPP].[dbo].[DRUG] d
where pagename in ('Drug Log', 'Medication History')

) A
)


,PATHOGENS AS (

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	  'CA' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE CA='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'CL' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE CL='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'EC' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE EC='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'HIV' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE HIV='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'HPV' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE HPV='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'IN' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE [IN]='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'MRSA' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE MRSA='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'MSSA' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE MSSA='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'MCV' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE MCV='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'NM' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE NM='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'PM' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE PM='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'SP' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE SP='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'COV' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE COV='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'SC' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE SC='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'OP' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE OP='X'

UNION

SELECT SITENUM,
       SUBNUM,
	   SUBID,
	   vID,
	   VISNAME,
	   PAGENAME,
	   PAGESEQ,
	   COALESCE([INF_EN_DEC], [INF_FU_DEC]) AS NonSeriousEvent,
	   'UK' AS Pathogen
FROM [ZELTA_GPP].[dbo].[MD_INF] INF
WHERE UK='X'

)

SELECT DISTINCT SITENUM
		,SUBID
		,SUBNUM
		,VISNAME
		,VISDAT
		,PAGENAME
		,VISITID
		,VISITSEQ
		,PAGEID
		,PAGESEQ
		,AECAT
		,NonSeriousEvent
		,SpecifyOther
		,OnsetDate

		,STUFF((
	   SELECT DISTINCT ', ' + Pathogen
	   FROM PATHOGENS P
	   WHERE P.SUBID=NSEVENTS.SUBID 
	   AND P.vID=NSEVENTS.vID
	   AND P.PAGENAME=NSEVENTS.PAGENAME
	   AND P.PAGESEQ=NSEVENTS.PAGESEQ
	   AND P.NonSeriousEvent=NSEVENTS.NonSeriousEvent
 	   FOR XML PATH('')
        )
        ,1,1,'') AS Pathogens

	   ,STUFF((
	   SELECT DISTINCT ', ' + drug
	   FROM DRUGS  
	   WHERE (DRUGS.SUBID=NSEVENTS.SUBID 
	   AND ISNULL(OnsetDate, '')=''
	   AND DRUGS.PAGENAME='Drug Log')
	   OR
	   (DRUGS.SUBID=NSEVENTS.SUBID 
	   AND ISNULL(OnsetDate, '')<>''
	   AND ((ISNULL(DRUGS.enddate, '')='')
	   OR (DATEDIFF(D, DRUGS.enddate, NSEVENTS.OnsetDate) between 0 and 120)
	   OR (DRUGS.enddate>NSEVENTS.VISDAT)))
	   FOR XML PATH('')
        )
        ,1,1,'') AS Treatments

	  ,STUFF((
	   SELECT DISTINCT ', ' + drugOTH
	   FROM DRUGS  
	   WHERE (DRUGS.SUBID=NSEVENTS.SUBID 
	   AND ISNULL(OnsetDate, '')=''
	   AND DRUGS.PAGENAME='Drug Log')
	   OR
	   (DRUGS.SUBID=NSEVENTS.SUBID 
	   AND ISNULL(OnsetDate, '')<>''
	   AND ((ISNULL(DRUGS.enddate, '')='')
	   OR (DATEDIFF(D, DRUGS.enddate, NSEVENTS.OnsetDate) between 0 and 120)
	   OR (DRUGS.enddate>NSEVENTS.VISDAT))) 
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherTreatments

		,[PAGELMBY]
		,[PAGELMDT]
		,[DATALMBY]
		,[DATALMDT]
		,[vID]
	
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
	  ,COALESCE([TERM_OTH], [FRA_LOC_DEC])  AS SpecifyOther

	  ,case WHEN STDAT LIKE 'UNK-%' THEN ''
	   when stdat like '%-UNK%' THEN replace(STDAT, '-UNK', '-01') 
	   else stdat
	   end as OnsetDate

	  ,'' AS Pathogens
      ,COMORB.[PAGELMBY]
      ,COMORB.[PAGELMDT]
      ,COMORB.[DATALMBY]
      ,COMORB.[DATALMDT]
	  ,COMORB.[vID]

  FROM [ZELTA_GPP].[dbo].[MD_AE] COMORB
  LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.SUBID=COMORB.SUBID AND V.vID=COMORB.vID 
  WHERE 1=1
  AND COMORB.VISNAME<>'Enrollment'
  AND V.PAGENAME='Visit Information'

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
	  ,COALESCE(OTHSP, LOCSP) AS SpecifyOther

	  ,case WHEN STDAT LIKE 'UNK-%' THEN ''
	   when stdat like '%-UNK%' THEN replace(STDAT, '-UNK', '-01') 
	   else stdat
	   end as OnsetDate

	  ,'' AS Pathogens
	  ,INF.[PAGELMBY]
      ,INF.[PAGELMDT]
      ,INF.[DATALMBY]
      ,INF.[DATALMDT]
	  ,INF.[vID]

  FROM [ZELTA_GPP].[dbo].[MD_INF] INF
  LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.SUBID=INF.SUBID AND V.vID=INF.vID
  WHERE 1=1
  AND INF.[VISNAME]<>'Enrollment'
  AND V.PAGENAME='Visit Information'

  AND ISNULL([SERIOUS_DEC], '') <> 'Yes'
  AND ISNULL([IVANINFEC_DEC], '') <> 'Yes'
  AND (ISNULL(ASP, '')<>'X' AND ISNULL(BAR, '')<>'X' AND ISNULL(BKV, '')<>'X' AND ISNULL(BLAST, '')<>'X' AND ISNULL(CAMP, '')<>'X' AND ISNULL(CD, '')<>'X' AND ISNULL(CRYP, '')<>'X' AND ISNULL(CYTO, '')<>'X' AND ISNULL(EBV, '')<>'X' AND ISNULL(FUS, '')<>'X' AND ISNULL(HBV, '')<>'X' AND ISNULL(HCV, '')<>'X' AND ISNULL(HSV, '')<>'X' AND ISNULL(HP, '')<>'X' AND ISNULL(JC, '')<>'X' AND ISNULL(LEG, '')<>'X' AND ISNULL(LEIS, '')<>'X' AND ISNULL(LICH, '')<>'X' AND ISNULL(LI, '')<>'X' AND ISNULL(MICRO, '')<>'X' AND ISNULL(MUCR, '')<>'X' AND ISNULL(MYCE, '')<>'X' AND ISNULL(TB, '')<>'X' AND ISNULL(NOCAR, '')<>'X' AND ISNULL(PCM, '')<>'X' AND ISNULL(PN, '')<>'X' AND ISNULL(PBOY, '')<>'X' AND ISNULL(RHZ, '')<>'X' AND ISNULL(SL, '')<>'X' AND ISNULL(SCED, '')<>'X' AND ISNULL(SHIG, '')<>'X' AND ISNULL(SPOR, '')<>'X' AND ISNULL(STRO, '')<>'X' AND ISNULL(TALA, '')<>'X' AND ISNULL(TOXO, '')<>'X' AND ISNULL(CHAG, '')<>'X' AND ISNULL(VZV, '')<>'X' AND ISNULL(VIBR, '')<>'X' AND ISNULL([OF], '')<>'X' AND ISNULL(OM, '')<>'X')
  ) NSEVENTS
  WHERE 1=1
  AND NonSeriousEvent NOT LIKE '%{TAE}%'



GO
