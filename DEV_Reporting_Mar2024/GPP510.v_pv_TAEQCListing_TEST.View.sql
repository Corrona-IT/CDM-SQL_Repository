USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_TAEQCListing_TEST]    Script Date: 4/2/2024 11:07:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW  [GPP510].[v_pv_TAEQCListing_TEST] AS


WITH RACE AS (

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'American Indian or Alaskan Native' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.NATAMERUS='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Aboriginal person' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.NATAMERCA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Asian' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.ASIAN='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'South Asian' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.SASIA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Southeast Asian' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.SEASIA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'West Asian' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.WASIA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Black/African American' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.BLCKUS='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Black' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.BLCKCA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Native Hawaiian or Other Pacific Islander' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.PACIFIC='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'White' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.WHITEUS='X' or WHITECA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,('Other: ' + RACEOTHSP) AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.RACEOTHUS='X' OR A.RACEOTHCA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Arab' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.ARAB='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Chinese' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.CHINA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Filipino' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.FILIP='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Japanese' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.JAPAN='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Korean' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.KOREA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Latin American' AS race
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.LATIN='X'
) 


,DEM AS (
SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,A.VISNAME
      ,A.SEX_DEC AS gender
	  ,SUBSTRING(CAST(PII.[DOB] AS varchar), 1, 4) AS YearOfBirth

	  ,STUFF((
	   SELECT DISTINCT ', ' + race
	   FROM RACE  
	   WHERE race.SUBID=A.SUBID 
	   FOR XML PATH('')
        )
        ,1,1,'') AS race

	  ,A.ETHNIC_DEC AS Ethnicity

FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[PII] PII ON PII.SUBNUM=A.SUBNUM 
	AND PII.VISNAME='Administrative' AND PII.PAGENAME='Subject Personal Information'

WHERE A.VISNAME = 'Enrollment'
)

,DRUGS AS (

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
	   CAST(d.FSTDAT AS date) AS FSTDAT,
	   cast(d.FENDAT as date) AS FENDAT
--SELECT *
FROM [ZELTA_GPP_TEST].[dbo].[DRUG] d
where pagename in ('Drug Log', 'Medication History', 'Drug Exposure')

) A
)


,EVENTTERM AS (
SELECT DISTINCT TAE.vID,
       TAE.SITENUM,
	   TAE.SUBID,
	   TAE.SUBNUM,
	   TAE.VISNAME, 
	   TAE.VISITSEQ, 
	   TAE.PAGEID, 
	   TAE.PAGESEQ, 
	   TAE.PAGENAME,
	   TAE.STATUSID, 
	   COALESCE(TAE.[TERM_ANA_TAE_DEC], TAE.[TERM_CVD_TAE_DEC], TAE.[TERM_C19_TAE_DEC], TAE.[TERM_GEN_TAE_DEC], TAE.[TERM_HEP_TAE_DEC], TAE.[TERM_CAN_TAE_DEC], TAE.[TERM_NEU_TAE_DEC], TAE.[TERM_INF_TAE_DEC], TAE.[TERM_VTE_TAE_DEC], TAE.[EVENT_TYPE_DEC]) AS EventTerm

FROM [ZELTA_GPP_TEST].[dbo].[TAE] TAE
WHERE PAGENAME='Confirmation Status'
)


,EVENTS AS (
SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY SiteID, lmdt.SUBID, EventType, EventTerm, vID ORDER BY SiteID, SubjectID, EventType, EventTerm, VISITSEQ, PAGENAME, PAGESEQ, LastModifiedDate DESC) AS ROWNUM
      ,vID
	  ,SiteID
	  ,SubjectID
	  ,lmdt.SUBID
	  ,gender
	  ,YearOfBirth
	  ,race
	  ,Ethnicity
	  ,EventType
	  ,EventTerm
	  ,PAGENAME
	  ,VISITSEQ
	  ,PAGESEQ
	  ,STATUSID_DEC
	  ,CreatedDate
	  ,LastModifiedBy
	  ,LastModifiedDate
FROM 
(
SELECT DISTINCT DPAGS.vID
      ,DPAGS.[SITENUM] AS SiteID
      ,DPAGS.[VISNAME] AS EventType
	  ,CASE WHEN DPAGS.VISNAME LIKE '%Preg%' THEN 'Pregnancy'
	   WHEN DPAGS.VISNAME LIKE '%Flare%' THEN 'GPP Flare'
	   ELSE ET.[EventTerm] 
	   END AS EventTerm
      ,CASE WHEN DPAGS.[PAGENAME] LIKE '%Information' THEN 'Event Information'
	   WHEN DPAGS.[PAGENAME] LIKE '%Details%' THEN 'Event Details'
	   ELSE DPAGS.[PAGENAME]
	   END AS [PAGENAME]
      ,DPAGS.[SUBID]
      ,DPAGS.[SUBNUM] AS SubjectID
      ,DPAGS.[VISITSEQ]
      ,DPAGS.[PAGESEQ]
      ,DPAGS.[STATUSID_DEC]
	  ,(SELECT MIN([PAGELMDT]) FROM [ZELTA_GPP_TEST].[dbo].[DAT_APGS] APGS WHERE APGS.vID=DPAGS.vID AND APGS.PAGENAME=DPAGS.PAGENAME) AS CreatedDate
      ,DPAGS.[PAGELMBY] AS LastModifiedBy
      ,DPAGS.[PAGELMDT] AS LastModifiedDate

FROM [ZELTA_GPP_TEST].[dbo].[DAT_PAGS] DPAGS 
JOIN EVENTTERM ET ON DPAGS.vID=ET.vID AND DPAGS.SUBID=ET.SUBID 
LEFT JOIN DEM ON DEM.SUBID=DPAGS.SUBID
WHERE 1=1
AND ((DPAGS.VISNAME LIKE '%TAE%' OR DPAGS.VISNAME LIKE '%Preg%' OR DPAGS.VISNAME LIKE '%Flare%') OR (DPAGS.PAGENAME LIKE '%Flare%'))
AND (DPAGS.PAGENAME LIKE '%Confirmation%' OR DPAGS.PAGENAME LIKE 'Subject Form%' OR DPAGS.PAGENAME LIKE '%Details%' OR DPAGS.PAGENAME LIKE '%Information%' OR DPAGS.PAGENAME LIKE 'Event Completion' OR DPAGS.PAGENAME LIKE '%Drug Exposure' OR DPAGS.PAGENAME LIKE '%Results%')
) lmdt
LEFT JOIN DEM ON DEM.SUBID=lmdt.SUBID
--ORDER BY SiteID, SubjectID, EventType, EventTerm, VISITSEQ, PAGENAME, ROWNUM
)



,SeriousReason AS
(
SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Hospitalization' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE HOSP='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Immediately life threatening' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE LFTHREAT='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Death' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE DTH='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Persistent/significant disability or incapacity' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE DISABL='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Congential anomaly/birth defect' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE BRTHDEF='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Provider deems serious' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE MDSER='X'
)

SELECT DISTINCT t1.vID
	 ,t1.SITENUM
	 ,t1.SUBID
	 ,t1.SUBNUM
	 ,t1.VISNAME
	 ,t1.VISITSEQ
	 ,t2.PROVID
	 ,EVENTS.gender
	 ,EVENTS.YearOfBirth
	 ,EVENTS.race
	 ,EVENTS.Ethnicity
	 ,CASE WHEN t1.VISNAME='Serious Infection TAE' THEN 'Serious Infection'
	  WHEN t1.VISNAME='Anaphylaxis/Severe Rxn TAE' THEN 'Anaphylaxis/Severe Rxn'
	  WHEN t1.VISNAME='Malignancy TAE' THEN 'Malignancy'
	  WHEN t1.VISNAME='Cardiovascular TAE' THEN 'Cardiovascular'
	  WHEN t1.VISNAME='Venous Thromboembolism TAE' THEN 'Venous Thromboembolism'
	  WHEN t1.VISNAME='General Serious TAE' THEN 'General Serious'
	  WHEN t1.VISNAME='Hepatic TAE' THEN 'Hepatic'
	  WHEN t1.VISNAME='Neurologic TAE' THEN 'Neurologic'
	  WHEN t1.VISNAME='COVID-19 TAE' THEN 'COVID-19'
	  ELSE t1.EVENT_TYPE_DEC
	  END AS EventType
	 ,COALESCE(t1.TERM_ANA_TAE_DEC, t1.TERM_CVD_TAE_DEC, t1.TERM_C19_TAE_DEC, t1.TERM_GEN_TAE_DEC, t1.TERM_HEP_TAE_DEC, t1.TERM_CAN_TAE_DEC, t1.TERM_NEU_TAE_DEC, t1.TERM_INF_TAE_DEC, t1.TERM_VTE_TAE_DEC) as EventTerm
	 , t1.TERM_OTH as specifyOtherEvent
	 ,t1.STDAT AS OnsetDate
	 ,t2.EVENT_RPT_DEC AS EventFirstReported
	 ,t2.RPT_DT AS VisitDate
	 ,es.EVNTSTAT_DEC as confirmationStatus
	 ,es.NOTEVNT as notAnEventExplain

	 --outcome

	 ,t2.SERIOUS_DEC

	  ,STUFF((
	   SELECT DISTINCT ', ' + SeriousReason
	   FROM SeriousReason  
	   WHERE SeriousReason.SUBID=t2.SUBID 
	   AND SeriousReason.vID=t2.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS seriousCriteria

		--IV anit-infective yes/no

	 ,t2.SUPDOCS_DEC as suppDocs
	 ,t2.SUPDOCS_ATTCH as suppdocsUpload
	 ,CASE WHEN ISNULL(t2.SUPDOCSNASP, '')<>'' THEN CONCAT(t2.SUPDOCSNA_DEC, ', ', t2.SUPDOCSNASP)
	   ELSE t2.SUPDOCSNA_DEC
	   END as suppDocsNotSubmReas
	 ,t2.PVREVSTAT_DEC AS suppDocsApproved

	 --created date
	 --last modified date each page type

FROM [ZELTA_GPP_TEST].[dbo].[TAE] t1
join [ZELTA_GPP_TEST].[dbo].[TAE] t2 on t2.SUBID=t1.SUBID and t2.vID=t1.vID
join [ZELTA_GPP_TEST].[dbo].[EVNTSTAT] es on es.SUBID=t1.SUBID and es.vID=t1.vID
join EVENTS ON t1.SUBNUM=EVENTS.SubjectId

where t1.PAGENAME='Confirmation Status'
and t2.PAGENAME='Event Information'





GO
