USE [Reporting]
GO
/****** Object:  StoredProcedure [GPP510].[usp_op_TAEQCListing]    Script Date: 4/2/2024 11:07:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04Apr2024
-- Author: Kaye Mowrey
-- Description:	Procedure to create table for GPP-510 TAE QC Listing
-- ===================================================================================================


CREATE PROCEDURE [GPP510].[usp_op_TAEQCListing] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [GPP510].[t_op_TAEQCListing]
(
	[SiteID] [nvarchar] (10) NOT NULL,
	[SiteStatus] [nvarchar] (75) NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,

);
*/


/*Put race into dataset to stuff into one column later*/

IF OBJECT_ID('tempdb.dbo.#RACE') IS NOT NULL BEGIN DROP TABLE #RACE END;

SELECT *
INTO #RACE
FROM
(
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
) r


/*Put demographics and stuff race into dataset to pull in final dataset later*/

IF OBJECT_ID('tempdb.dbo.#DEM') IS NOT NULL BEGIN DROP TABLE #DEM END;

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,A.VISNAME
	  ,COALESCE((SELECT SEX_DEC FROM [ZELTA_GPP_TEST].[dbo].[PII] PII where SUBID=A.SUBID AND PAGENAME='Subject Personal Information' ), A.SEX_DEC)  AS gender
	  ,(SELECT SUBSTRING(CAST(PII.[DOB] AS varchar), 1, 4) FROM [ZELTA_GPP_TEST].[dbo].[PII] PII where SUBID=A.SUBID AND PAGENAME='Subject Personal Information' AND isnull([DOB], '')<>'') AS YearOfBirth

	  ,STUFF((
	   SELECT DISTINCT ', ' + race
	   FROM #RACE race
	   WHERE race.SUBID=A.SUBID 
	   FOR XML PATH('')
        )
        ,1,1,'') AS race

	  ,A.ETHNIC_DEC AS Ethnicity

INTO #DEM
FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
WHERE A.VISNAME = 'Enrollment'
AND PAGENAME='Subject Form A'

--SELECT * FROM #DEM ORDER BY SITENUM, SUBNUM, VISNAME
--select * from [ZELTA_GPP_TEST].[dbo].[PII] PII ORDER BY SITENUM, SUBNUM, VISNAME
--select * from [ZELTA_GPP_TEST].[dbo].[SUB_A] A where VISNAME='Enrollment' ORDER BY SITENUM, SUBNUM, VISNAME



/*Put all serious reasons into a dataset to be stuffed into a single column later*/

IF OBJECT_ID('tempdb.dbo.#SeriousReason') IS NOT NULL BEGIN DROP TABLE #SeriousReason END;

SELECT distinct vID,
       SUBID,
	   VISNAME,
	   VISITSEQ,
	   SeriousReason
INTO #SeriousReason
FROM
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

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Post-natal serious infection' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE PNINF='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Serious post-partum infection' AS SeriousReason
FROM [ZELTA_GPP_TEST].[dbo].[TAE]
WHERE PPINF='X'


) SR


/*Put Drug Exposure drugs into a dataset to stuff into a single column later*/

IF OBJECT_ID('tempdb.dbo.#DRUGEXP') IS NOT NULL BEGIN DROP TABLE #DRUGEXP END

SELECT SITENUM,
		SUBNUM,
		SUBID,
		vID,
		PAGENAME,
		VISNAME,
		VISITSEQ,
		PAGESEQ,
		drug,
		drugoth,
		CAST(COALESCE(fstdat, pstdat) AS DATE) as startdate,
		CAST(COALESCE(fendat, pendat) AS DATE) as enddate
INTO #DRUGEXP
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
	   case WHEN D.PSTDAT LIKE 'UNK-%' THEN NULL
	   when d.pstdat like '%-UNK%' THEN replace(d.PSTDAT, '-UNK', '-01') 
	   else d.pstdat
	   end as pstdat,
	   case WHEN d.pendat LIKE 'UNK-%' THEN NULL
	   when d.pendat like '%-UNK%' THEN replace(d.pendat, '-UNK', '-01') 
	   else d.pendat
	   end as pendat,
	   CAST(d.FSTDAT AS date) AS FSTDAT,
	   cast(d.FENDAT as date) AS FENDAT

--SELECT *
FROM [ZELTA_GPP_TEST].[dbo].[DRUG] d
where pagename in ('Drug Exposure')
) A

--SELECT * FROM #DRUGEXP ORDER BY SUBNUM, DRUG


/*Get TAE events and confirmation/Information status*/

IF OBJECT_ID('tempdb.dbo.#TAEINFO') IS NOT NULL BEGIN DROP TABLE #TAEINFO END;

SELECT DISTINCT t1.vID
	 ,t1.SITENUM
	 ,t1.SUBID
	 ,t1.SUBNUM
	 ,t1.VISNAME
	 ,t1.VISITSEQ
	 ,t1.PAGENAME
	 ,t1.PAGESEQ
	 ,t1.STATUSID_DEC
	 ,dem.gender
	 ,dem.YearOfBirth
	 ,dem.race
	 ,dem.Ethnicity
	 ,CASE WHEN t1.VISNAME LIKE 'Pregnancy Event%' THEN 'Pregnancy'
	  WHEN t1.VISNAME like 'GPP Flare%' THEN 'GPP Flare'
	  ELSE REPLACE(t1.VISNAME, ' TAE', '')
	  END AS EventType
	 ,CASE WHEN t1.VISNAME LIKE 'Pregnancy Event%' THEN 'Pregnancy'
	  WHEN t1.VISNAME LIKE 'GPP Flare%' THEN 'GPP Flare'
	  ELSE COALESCE(t1.[TERM_ANA_TAE_DEC], t1.[TERM_CVD_TAE_DEC], t1.[TERM_C19_TAE_DEC], t1.[TERM_GEN_TAE_DEC], t1.[TERM_HEP_TAE_DEC], t1.[TERM_CAN_TAE_DEC], t1.[TERM_NEU_TAE_DEC], t1.[TERM_INF_TAE_DEC], t1.[TERM_VTE_TAE_DEC], t1.[EVENT_TYPE_DEC]) 
	  END AS EventTerm
	 ,t1.TERM_OTH as specifyOtherEvent
	 ,CASE WHEN t1.VISNAME LIKE 'Pregnancy Event%' THEN  (SELECT [LASTPERIODDAT] FROM [ZELTA_GPP_TEST].[dbo].[PEQ] p WHERE p.vID=t1.vID and p.SUBID=t1.SUBID)
	  ELSE t1.STDAT
	  END AS OnsetDate
	 ,es.EVNTSTAT_DEC as confirmationStatus
	 ,es.NOTEVNT as notAnEventExplain
	 ,(SELECT ABXIVYN_DEC FROM [ZELTA_GPP_TEST].[dbo].[TAE_INF] inf WHERE inf.SUBID=t1.SUBID AND inf.vID=t1.vID) AS IV_antiInfective
	 ,STUFF((
	   SELECT DISTINCT ', ' + drug
	   FROM #DRUGEXP drugex
	   WHERE drugex.SUBID=t1.SUBID 
	   AND drugex.vID=t1.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS drugExposure
	 ,STUFF((
	   SELECT DISTINCT ', ' + DRUGOTH
	   FROM #DRUGEXP drugex
	   WHERE drugex.SUBID=t1.SUBID 
	   AND drugex.vID=t1.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS otherDrugExposure

INTO #TAEINFO
FROM [ZELTA_GPP_TEST].[dbo].[TAE] t1 
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[EVNTSTAT] es ON es.SUBID=t1.SUBID AND es.vID=t1.vID 
LEFT JOIN #DEM DEM on DEM.SUBID=T1.SUBID  --WHERE t1.SUBNUM='GPP-9998-0025'
where 1=1 and
t1.PAGENAME='Confirmation Status' 

--t1.SUBNUM='GPP-9998-0025'
--select * from #taeinfo order by sitenum, subnum, visname, visitseq
--where visname like 'Preg%' 

/*Get outcomes of events */

IF OBJECT_ID('tempdb.dbo.#TAEOUTCOMES') IS NOT NULL BEGIN DROP TABLE #TAEOUTCOMES END;

SELECT DISTINCT t2.vID
	 ,t2.SITENUM
	 ,t2.SUBID
	 ,t2.SUBNUM
	 ,t2.VISNAME
	 ,t2.VISITSEQ
	 ,t2.PAGENAME
	 ,t2.PROVID
	 ,t2.EVENT_RPT_DEC AS EventFirstReported
	 ,t2.RPT_DT AS VisitDate
	 ,t2.OUTCOME_DEC
	 ,t2.SERIOUS_DEC
	 ,STUFF((
	   SELECT DISTINCT ', ' + SeriousReason
	   FROM #SeriousReason SR
	   WHERE SR.SUBID=t2.SUBID 
	   AND SR.vID=t2.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS seriousCriteria

	 ,t2.SUPDOCS_DEC as suppDocs
	 ,t2.SUPDOCS_ATTCH as suppdocsUpload
	 ,CASE WHEN ISNULL(t2.SUPDOCSNASP, '')<>'' THEN CONCAT(t2.SUPDOCSNA_DEC, ', ', t2.SUPDOCSNASP)
	   ELSE t2.SUPDOCSNA_DEC
	   END as suppDocsNotSubmReas
	 ,t2.PVREVSTAT_DEC AS suppDocsApproved

INTO #TAEOUTCOMES
FROM [ZELTA_GPP_TEST].[dbo].[TAE] t2 
where 1=1 and
t2.PAGENAME<>'Confirmation Status' 

--SELECT * FROM #TAEOUTCOMES ORDER BY SITENUM, SUBNUM, VISNAME, VISITSEQ


/*Get list of events with associated pages and and last modified date*/

IF OBJECT_ID('tempdb.dbo.#LMDT') IS NOT NULL BEGIN DROP TABLE #LMDT END;

SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY SITENUM, lmdt.SUBID, EventType, EventTerm, vID ORDER BY SITENUM, SUBNUM, EventType, EventTerm, VISITSEQ, PAGENAME, PAGESEQ, LastModifiedDate DESC) AS ROWNUM
      ,vID
	  ,SITENUM
	  ,SUBID
	  ,SUBNUM
	  ,VISNAME
	  ,PAGENAME
	  ,VISITSEQ
	  ,PAGESEQ
	  ,STATUSID_DEC
	  ,EventType
	  ,EventTerm
	  ,CreatedDate
	  ,LastModifiedBy
	  ,LastModifiedDate
INTO #LMDT
FROM 
(
SELECT DISTINCT DPAGS.vID
      ,DPAGS.[SITENUM]
	  ,DPAGS.[SUBID]
      ,DPAGS.[SUBNUM]
      ,DPAGS.[VISNAME]
      ,DPAGS.[VISITSEQ]
      ,DPAGS.[PAGESEQ]
      ,DPAGS.[STATUSID_DEC]
	  ,ET.EventType
	  ,CASE WHEN DPAGS.VISNAME LIKE '%Preg%' THEN 'Pregnancy'
	   WHEN DPAGS.VISNAME LIKE '%Flare%' THEN 'GPP Flare'
	   ELSE ET.[EventTerm] 
	   END AS EventTerm
      ,CASE WHEN DPAGS.[PAGENAME] LIKE '%Information' THEN 'Event Information'
	   WHEN DPAGS.[PAGENAME] LIKE '%Details%' THEN 'Event Details'
	   ELSE DPAGS.[PAGENAME]
	   END AS [PAGENAME]

	  ,(SELECT MIN([PAGELMDT]) FROM [ZELTA_GPP_TEST].[dbo].[DAT_APGS] APGS WHERE APGS.vID=DPAGS.vID AND APGS.PAGENAME=DPAGS.PAGENAME) AS CreatedDate
      ,DPAGS.[PAGELMBY] AS LastModifiedBy
      ,DPAGS.[PAGELMDT] AS LastModifiedDate

--SELECT *
FROM [ZELTA_GPP_TEST].[dbo].[DAT_PAGS] DPAGS --WHERE SUBNUM='GPP-9998-0025' AND pagename like '%Confirmation%'
LEFT JOIN #TAEINFO ET ON DPAGS.vID=ET.vID AND DPAGS.SUBID=ET.SUBID 
WHERE 1=1
AND ((DPAGS.VISNAME LIKE '%TAE%' OR DPAGS.VISNAME LIKE '%Preg%' OR DPAGS.VISNAME LIKE '%Flare%') OR (DPAGS.PAGENAME LIKE '%Flare%'))
AND (DPAGS.PAGENAME LIKE '%Confirmation%' OR DPAGS.PAGENAME LIKE 'Subject Form%' OR DPAGS.PAGENAME LIKE '%Details%' OR DPAGS.PAGENAME LIKE '%Information%' OR DPAGS.PAGENAME LIKE 'Event Completion' OR DPAGS.PAGENAME LIKE '%Drug Exposure' OR DPAGS.PAGENAME LIKE '%Results%' OR DPAGS.PAGENAME LIKE '%Flare%')
) lmdt

--SELECT * FROM #LMDT ORDER BY SITENUM, SUBNUM, VISNAME, EventType, PAGENAME, VISITSEQ
--SELECT * FROM #lmdt where subjectid='GPP-9998-0025'
--SELECT * FROM [ZELTA_GPP_TEST].[dbo].[TAE] TAE where subnum='GPP-9998-0025'


/*Put historical and drug log drugs into a dataset to stuff into a single column later*/

IF OBJECT_ID('tempdb.dbo.#DRUGS') IS NOT NULL BEGIN DROP TABLE #DRUGS END

SELECT SITENUM,
		SUBNUM,
		SUBID,
		vID,
		PAGENAME,
		VISNAME,
		VISITSEQ,
		PAGESEQ,
		drug,
		drugoth,
		CAST(COALESCE(fstdat, pstdat) AS DATE) as startdate,
		CAST(COALESCE(fendat, pendat) AS DATE) as enddate
INTO #DRUGS
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
	   case WHEN D.PSTDAT LIKE 'UNK-%' THEN NULL
	   when d.pstdat like '%-UNK%' THEN replace(d.PSTDAT, '-UNK', '-01') 
	   else d.pstdat
	   end as pstdat,
	   case WHEN d.pendat LIKE 'UNK-%' THEN NULL
	   when d.pendat like '%-UNK%' THEN replace(d.pendat, '-UNK', '-01') 
	   else d.pendat
	   end as pendat,
	   CAST(d.FSTDAT AS date) AS FSTDAT,
	   cast(d.FENDAT as date) AS FENDAT

--SELECT *
FROM [ZELTA_GPP_TEST].[dbo].[DRUG] d
where pagename in ('Drug Log', 'Medication History')
) A

--SELECT * FROM #DRUGS ORDER BY SUBNUM, DRUG



END

GO
