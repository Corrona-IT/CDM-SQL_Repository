USE [Reporting]
GO
/****** Object:  StoredProcedure [GPP510].[usp_pv_TAEQCListing]    Script Date: 11/13/2024 12:16:33 PM ******/
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

CREATE PROCEDURE [GPP510].[usp_pv_TAEQCListing] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [GPP510].[t_pv_TAEQCListing](
	[vID] [bigint] NULL,
	[SITENUM] [nvarchar](10) NOT NULL,
	[SiteStatus] [nvarchar](100) NULL,
	[SUBID] [bigint] NOT NULL,
	[SUBNUM] [nvarchar](25) NOT NULL,
	[PROVID] [bigint] NULL,
	[VISNAME] [nvarchar](75) NULL,
	[VISITSEQ] [bigint] NULL,
	[EventType] [nvarchar](150) NULL,
	[EventTerm] [nvarchar](200) NULL,
	[specifyOtherEvent] [nvarchar](250) NULL,
	[OnsetDate] [date] NULL,
	[EventFirstReported] [nvarchar](150) NULL,
	[RptVisitDate] [date] NULL,
	[confirmationStatus] [nvarchar](75) NULL,
	[notAnEventExplain] [nvarchar](500) NULL,
	[OUTCOME_DEC] [nvarchar](250) NULL,
	[SERIOUS_DEC] [nvarchar](250) NULL,
	[seriousCriteria] [nvarchar](750) NULL,
	[IV_antiInfective] [nvarchar](10) NULL,
	[drugLogTreatments] [nvarchar](750) NULL,
	[otherDrugLogTreatments] [nvarchar](750) NULL,
	[drugExposure] [nvarchar](750) NULL,
	[otherDrugExposure] [nvarchar](750) NULL,
	[gender] [nvarchar](30) NULL,
	[YearOfBirth] [nvarchar](10) NULL,
	[race] [nvarchar](750) NULL,
	[Ethnicity] [nvarchar](50) NULL,
	[suppDocs] [nvarchar](50) NULL,
	[suppdocsUpload] [nvarchar](50) NULL,
	[suppDocsNotSubmReas] [nvarchar](250) NULL,
	[suppDocsApproved] [nvarchar](150) NULL,
	[eventPaid] [nvarchar](20) NULL,
	[suppDocspaid] [nvarchar](20) NULL,
	[HasData] [nvarchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LMDT_confirmationStatus] [datetime] NULL,
	[LMDT_eventInformation] [datetime] NULL,
	[LMDT_eventDetails] [datetime] NULL,
	[LMDT_drugExposure] [datetime] NULL,
	[LMDT_otherConcurrentDrugs] [datetime] NULL,
	[LMDT_flareVisits] [datetime] NULL,
	[LMDT_subjectForm] [datetime] NULL,
	[LMDT_testResults] [datetime] NULL,
	[LMDT_eventCompletion] [datetime] NULL,
	[LMDT_CaseProcessing] [datetime] NULL,
	[eventPaymentEligibility] [nvarchar] (100) NULL,
	[EventDataEntryStatus] [nvarchar] (50) NULL
) ON [PRIMARY]
GO

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
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.NATAMERUS='X'
 
UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Aboriginal person' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.NATAMERCA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Asian' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.ASIAN='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'South Asian' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.SASIA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Southeast Asian' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.SEASIA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'West Asian' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.WASIA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Black/African American' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.BLCKUS='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Black' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.BLCKCA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Native Hawaiian or Other Pacific Islander' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.PACIFIC='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'White' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.WHITEUS='X' or WHITECA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,('Other: ' + RACEOTHSP) AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.RACEOTHUS='X' OR A.RACEOTHCA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Arab' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.ARAB='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Chinese' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.CHINA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Filipino' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.FILIP='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Japanese' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.JAPAN='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Korean' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.KOREA='X'

UNION

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,'Latin American' AS race
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.LATIN='X'
) r


/*Put demographics and stuff race into dataset to pull in final dataset later*/

IF OBJECT_ID('tempdb.dbo.#DEM') IS NOT NULL BEGIN DROP TABLE #DEM END;

SELECT DISTINCT A.SITENUM
	  ,A.SUBNUM
	  ,A.SUBID
	  ,A.VISNAME
	  ,COALESCE((SELECT SEX_DEC FROM [ZELTA_GPP].[dbo].[PII] PII where SUBID=A.SUBID AND PAGENAME='Subject Personal Information' ), A.SEX_DEC)  AS gender
	  ,(SELECT SUBSTRING(CAST(PII.[DOB] AS varchar), 1, 4) FROM [ZELTA_GPP].[dbo].[PII] PII where SUBID=A.SUBID AND PAGENAME='Subject Personal Information' AND isnull([DOB], '')<>'') AS YearOfBirth

	  ,STUFF((
	   SELECT DISTINCT ', ' + race
	   FROM #RACE race
	   WHERE race.SUBID=A.SUBID 
	   FOR XML PATH('')
        )
        ,1,1,'') AS race

	  ,A.ETHNIC_DEC AS Ethnicity

INTO #DEM
FROM [ZELTA_GPP].[dbo].[SUB_A] A
WHERE A.VISNAME = 'Enrollment'
AND PAGENAME='Subject Form A'

--SELECT * FROM #DEM ORDER BY SITENUM, SUBNUM, VISNAME


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
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE HOSP='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Immediately life threatening' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE LFTHREAT='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Death' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE DTH='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Persistent/significant disability or incapacity' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE DISABL='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Congential anomaly/birth defect' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE BRTHDEF='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Provider deems serious' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE MDSER='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Post-natal serious infection' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE PNINF='X'

UNION

SELECT vID
      ,SUBID
	  ,VISNAME
	  ,VISITSEQ
	  ,'Serious post-partum infection' AS SeriousReason
FROM [ZELTA_GPP].[dbo].[TAE]
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
FROM [ZELTA_GPP].[dbo].[DRUG] d
where pagename in ('Drug Exposure')
) A

--SELECT * FROM #DRUGEXP ORDER BY SUBNUM, DRUG


/*Get TAE events and confirmation/Information status*/

IF OBJECT_ID('tempdb.dbo.#TAEINFO') IS NOT NULL BEGIN DROP TABLE #TAEINFO END;

SELECT DISTINCT t1.vID
	 ,t1.SITENUM
	 ,CASE WHEN t1.SITENUM IN (1440, 9900, 9998, 9999) THEN 'Approved / Active'
	  ELSE ss.currentStatus 
	  END AS SiteStatus
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
	 ,CASE WHEN ISNULL(t1.[EVENT_TYPE_DEC], '')<>'' THEN t1.[EVENT_TYPE_DEC]
	  WHEN t1.VISNAME='Anaphylaxis/Severe Rxn TAE' THEN 'Anaphylaxis-severe reaction'
	  ELSE REPLACE(t1.VISNAME, ' TAE', '')
	  END AS EventType
	 ,CASE WHEN t1.VISNAME LIKE 'Pregnancy Event%' THEN 'Pregnancy'
	  WHEN t1.VISNAME LIKE 'GPP Flare%' THEN 'GPP Flare'
	  ELSE COALESCE(t1.[TERM_ANA_TAE_DEC], t1.[TERM_CVD_TAE_DEC], t1.[TERM_C19_TAE_DEC], t1.[TERM_GEN_TAE_DEC], t1.[TERM_HEP_TAE_DEC], t1.[TERM_CAN_TAE_DEC], t1.[TERM_NEU_TAE_DEC], t1.[TERM_INF_TAE_DEC], t1.[TERM_VTE_TAE_DEC]) 
	  END AS EventTerm
	 ,COALESCE(t1.TERM_OTH, CASE WHEN t1.FRA_LOC_DEC='Other fracture location (specify)' THEN 'Other fracture location: ' + t1.FRA_LOCSP ELSE t1.FRA_LOC_DEC END) AS specifyOtherEvent

	 ,CASE WHEN t1.VISNAME LIKE 'Pregnancy Event%' THEN  (SELECT [LASTPERIODDAT] FROM [ZELTA_GPP].[dbo].[PEQ] p WHERE p.vID=t1.vID and p.SUBID=t1.SUBID)
	  WHEN t1.VISNAME LIKE 'GPP Flare%' THEN (SELECT REPLACE([FLRSTDAT], '-UNK', '-01') FROM [ZELTA_GPP].[dbo].[FLR] v WHERE v.vID=t1.vID AND v.SUBID=t1.SUBID AND PAGENAME='Flare Details') 
	  ELSE t1.STDAT
	  END AS OnsetDate
	 
	 ,es.EVNTSTAT_DEC AS confirmationStatus
	 ,es.NOTEVNT as notAnEventExplain
	 ,(SELECT ABXIVYN_DEC FROM [ZELTA_GPP].[dbo].[TAE_INF] inf WHERE inf.SUBID=t1.SUBID AND inf.vID=t1.vID) AS IV_antiInfective
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
	  ,(SELECT STATUSID_DEC FROM [ZELTA_GPP].[dbo].[VISIT_COMP] ec WHERE ec.vID=t1.vID AND ec.SUBID=t1.SUBID) AS EventDataEntryStatus
	  ,(SELECT TAECOMPL FROM [ZELTA_GPP].[dbo].[VISIT_COMP] ec WHERE ec.vID=t1.vID AND ec.SUBID=t1.SUBID) AS eventPaymentEligibility

INTO #TAEINFO
FROM [ZELTA_GPP].[dbo].[TAE] t1 
LEFT JOIN [ZELTA_GPP].[dbo].[EVNTSTAT] es ON es.SUBID=t1.SUBID AND es.vID=t1.vID
LEFT JOIN #DEM DEM on DEM.SUBID=T1.SUBID
LEFT JOIN [Salesforce].[dbo].[registryStatus] ss on ss.siteNumber=t1.sitenum    
--WHERE t1.SUBNUM='GPP-9998-0025'
where 1=1 
and t1.PAGENAME='Confirmation Status'
and ISNULL(ss.[name], '') IN ('', 'Generalized Pustular Psoriasis (GPP-510)')
--select * from [ZELTA_GPP].[dbo].[TAE] where subnum='GPP-1440-0002'

--SELECT * FROM  #TAEINFO where EventTerm LIKE '%Fra%'


/*Get outcomes of events */

IF OBJECT_ID('tempdb.dbo.#TAEOUTCOMES') IS NOT NULL BEGIN DROP TABLE #TAEOUTCOMES END;

SELECT DISTINCT t2.vID
	 ,t2.SITENUM
	 ,t2.SUBID
	 ,t2.SUBNUM
	 ,t2.VISNAME
	 ,t2.VISITSEQ
	 ,t2.PAGENAME
	 ,t2.STATUSID_DEC
	 ,t2.PROVID
	 ,COALESCE(t2.EVENT_RPT_DEC, f.FLRREPORT_DEC) AS EventFirstReported

	 ,t2.RPT_DT AS RptVisitDate
	 ,CASE WHEN t2.VISNAME LIKE 'GPP Flare%' THEN (SELECT FLROUTCOME_DEC FROM [ZELTA_GPP].[dbo].[FLR] f WHERE f.vID=t2.vID AND f.SUBID=t2.SUBID and f.PAGENAME='Flare Details')
	  ELSE t2.OUTCOME_DEC
	  END AS OUTCOME_DEC

	 ,t2.SERIOUS_DEC

	 ,STUFF((
	   SELECT DISTINCT ', ' + SeriousReason
	   FROM #SeriousReason SR
	   WHERE SR.SUBID=t2.SUBID 
	   AND SR.vID=t2.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS seriousCriteria

	 ,CASE WHEN ISNULL(SUPDOCS_ATTCH, '')<>'' AND  t2.SUPDOCS_DEC IS NULL
	       THEN 'Are attached'
	  ELSE t2.SUPDOCS_DEC 
	  END AS suppDocs
	 ,t2.SUPDOCS_ATTCH 
	 ,CASE WHEN ISNULL(t2.SUPDOCS_ATTCH, '')<>'' THEN 'Yes'
	  ELSE 'No'
	  END AS suppdocsUpload

	 ,CASE WHEN ISNULL(t2.SUPDOCSNASP, '')<>'' THEN CONCAT(t2.SUPDOCSNA_DEC, ', ', t2.SUPDOCSNASP)
	   ELSE t2.SUPDOCSNA_DEC
	   END as suppDocsNotSubmReas

	 ,t2.PVREVSTAT_DEC AS suppDocsApproved

	 ,CASE WHEN ISNULL(r.VISIT_PAID, '')='X' THEN 'Yes'
	  ELSE r.VISIT_PAID
	  END AS eventPaid

	 ,CASE WHEN ISNULL(r.SOURCE_DOCS_PAID, '')='X' THEN 'Yes'
	  ELSE r.SOURCE_DOCS_PAID
	  END AS suppDocsPaid

INTO #TAEOUTCOMES
FROM [ZELTA_GPP].[dbo].[TAE] t2 
LEFT JOIN  [ZELTA_GPP].[dbo].[REIMB] r ON r.vID=t2.vID 
LEFT JOIN [ZELTA_GPP].[dbo].[FLR] f ON f.SUBID=t2.SUBID AND f.vID=t2.vID
where 1=1 and
t2.PAGENAME<>'Confirmation Status' AND
f.PAGENAME='Confirmation Status'

--SELECT * FROM #TAEOUTCOMES WHERE SUBNUM='GPP-9900-0007' ORDER BY SITENUM, SUBNUM, VISNAME, VISITSEQ



IF OBJECT_ID('tempdb.dbo.#LMDT') IS NOT NULL BEGIN DROP TABLE #LMDT END;

/*Get list of events with associated pages and and last modified date*/

SELECT DISTINCT ROWNUM
      ,vID
	  ,SITENUM
	  ,SiteStatus
	  ,SUBID
	  ,SUBNUM
	  ,VISNAME
	  ,PAGENAME
	  ,VISITSEQ
	  ,PAGESEQ
	  ,EventType
	  ,EventTerm
	  ,CreatedDate
	  ,LastModifiedBy
	  ,LastModifiedDate
	  ,REASON

INTO #LMDT
FROM
(
SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY SITENUM, lm.SUBID, VISNAME, PAGENAME, PAGESEQ, EventType, EventTerm, vID ORDER BY SITENUM, SUBNUM, EventType, EventTerm, VISITSEQ, PAGENAME, PAGESEQ, LastModifiedDate DESC) AS ROWNUM
      ,vID
	  ,SITENUM
	  ,SiteStatus
	  ,SUBID
	  ,SUBNUM
	  ,VISNAME
	  ,PAGENAME
	  ,VISITSEQ
	  ,PAGESEQ
	  ,EventType
	  ,EventTerm
	  ,CreatedDate
	  ,LastModifiedBy
	  ,LastModifiedDate
	  ,REASON

FROM 
(
SELECT DISTINCT APGS.vID
      ,APGS.[SITENUM]
	  ,CASE WHEN APGS.SITENUM IN (1440, 9900, 9998, 9999) THEN 'Approved / Active'
	   ELSE ss.currentStatus 
	   END AS SiteStatus
	  ,APGS.[SUBID]
      ,APGS.[SUBNUM]
      ,APGS.[VISNAME]
      ,APGS.[VISITSEQ]
      ,APGS.[PAGESEQ]
      ,CASE WHEN APGS.[STATUSID]=10 THEN 'Complete'
	   WHEN APGS.[STATUSID]=5 THEN 'Data Entered'
	   WHEN APGS.[STATUSID]=0 THEN 'No Data'
	   ELSE ''
	   END AS STATUSID_DEC

     ,CASE WHEN ISNULL(ET.EventType, '')='' THEN REPLACE(APGS.VISNAME, ' TAE', '')
	  ELSE ET.EventType
	  END AS EventType

	  ,CASE WHEN APGS.VISNAME LIKE '%Preg%' THEN 'Pregnancy'
	   WHEN APGS.VISNAME LIKE '%Flare%' THEN 'GPP Flare'
	   ELSE ET.[EventTerm] 
	   END AS EventTerm
      ,CASE WHEN APGS.[PAGENAME] LIKE '%Information' THEN 'Event Information'
	   WHEN APGS.[PAGENAME] LIKE '%Details%' THEN 'Event Details'
	   WHEN APGS.[PAGENAME] LIKE 'Subject%' THEN 'Subject Form'
	   ELSE APGS.[PAGENAME]
	   END AS [PAGENAME]

	  ,(SELECT MIN([PAGELMDT]) FROM [ZELTA_GPP].[dbo].[DAT_APGS] APGS1 WHERE APGS1.vID=APGS.vID AND APGS1.PAGENAME='Confirmation Status') AS CreatedDate
      ,APGS.[PAGELMBY] AS LastModifiedBy
      ,APGS.[PAGELMDT] AS LastModifiedDate
	  ,APGS.[REASON]

--SELECT *
FROM [ZELTA_GPP].[dbo].[DAT_APGS] APGS --WHERE SUBNUM='GPP-9998-0025' AND pagename like '%Confirmation%'
LEFT JOIN #TAEINFO ET ON APGS.vID=ET.vID AND APGS.SUBID=ET.SUBID 
LEFT JOIN [Salesforce].[dbo].[registryStatus] ss on ss.siteNumber=APGS.sitenum and ss.[name]='Generalized Pustular Psoriasis (GPP-510)'
WHERE 1=1
AND ((APGS.VISNAME LIKE '%TAE%' OR APGS.VISNAME LIKE '%Preg%' OR APGS.VISNAME LIKE '%Flare%') OR (APGS.PAGENAME LIKE '%Flare%'))
AND (APGS.PAGENAME LIKE '%Confirmation%' OR APGS.PAGENAME LIKE 'Subject Form%' OR APGS.PAGENAME LIKE '%Details%' OR APGS.PAGENAME LIKE '%Information%' OR APGS.PAGENAME LIKE 'Event Completion' OR APGS.PAGENAME LIKE '%Drug Exposure' OR APGS.PAGENAME LIKE '%Results%' OR APGS.PAGENAME LIKE '%Flare%' OR APGS.PAGENAME LIKE 'Other Concurr%' OR APGS.PAGENAME LIKE 'Case Proc%')
AND (APGS.PAGENAME <> 'Lab and Imaging Results')
) lm
) lmdt
WHERE ROWNUM=1


--SELECT distinct pagename FROM #LMDT WHERE ROWNUM = 1 ORDER BY SITENUM, SUBNUM, VISNAME, VISITSEQ, PAGENAME, PAGESEQ, EventTerm, ROWNUM
--SELECT * FROM #lmdt where subnum='GPP-9900-0007' ORDER BY SiteNUM, SUBNUM, VISNAME,EVENTTYPE, VISITSEQ
--SELECT distinct statusid_dec from #lmdt


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
		RXDAT AS prescribeddate,
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
	   CAST(d.RXDAT AS date) AS RXDAT,
	   CAST(d.FSTDAT AS date) AS FSTDAT,
	   cast(d.FENDAT as date) AS FENDAT

--SELECT *
FROM [ZELTA_GPP].[dbo].[DRUG] d
where pagename in ('Drug Log', 'Medication History')
) A

--SELECT PRESCRIBEDDATE FROM #DRUGS WHERE ISDATE(prescribeddate)=0 ORDER BY SUBNUM, DRUG


/*Get list of drugs from treatment history and drug log to stuff into 'Treatments Listed on Drug Log column*/

IF OBJECT_ID('tempdb.dbo.#TAEDRUGS') IS NOT NULL BEGIN DROP TABLE #TAEDRUGS END;

SELECT SITENUM,
       SUBNUM,
       SUBID,
	   vID,
	   EventType,
	   EventTerm,
	   OnsetDate,
	   RptVisitDate,
	   PAGENAME,
	   drug,
	   drugoth,
	   prescribeddate,
	   startDate,
	   endDate,
	   daysStartedPriortoOnset,
	   monthsStartedAfterOnset,
	   daysEndedPriortoOnset

INTO #TAEDRUGS
FROM 
(
/*For all events (EXCEPT CANCER), Pull in all drugs from drug log, except if the drug has been stopped/discontinued for greater than 120 days.*/

SELECT DISTINCT TAE.SITENUM,
       TAE.SUBNUM,
       TAE.SUBID,
	   TAE.vID,
	   TAE.EventType,
	   TAE.EventTerm,
	   TAE.OnsetDate,
	   TAEOUT.RptVisitDate,
	   D.PAGENAME,
	   D.drug,
	   D.drugoth,
	   D.prescribeddate,
	   D.startDate,
	   D.endDate,
	   DATEDIFF(D, COALESCE(startDate, prescribeddate), OnsetDate) AS daysStartedPriortoOnset,
	   DATEDIFF(M, OnsetDate, COALESCE(startDate, prescribeddate)) AS monthsStartedAfterOnset,
	   DATEDIFF(d, endDate, OnsetDate) AS daysEndedPriortoOnset
	   
FROM #TAEINFO TAE  
LEFT JOIN #TAEOUTCOMES TAEOUT ON TAEOUT.vID=TAE.vID AND TAEOUT.VISNAME=TAE.VISNAME AND TAEOUT.VISITSEQ=TAE.VISITSEQ
LEFT JOIN #DRUGS D ON D.SUBID=TAE.SUBID 
WHERE (ISNULL(EventType, '')<>'Malignancy'
AND ISNULL(TAE.EventTerm, '') NOT IN ('Pregnancy', 'Breast cancer', 'Cervical cancer', 'Colon cancer', 'Leukemia', 'Lung cancer', 'Lymphoma', 'Melanoma skin cancer', 'Non-melanoma skin cancer basal cell', 'Non-melanoma skin cancer squamous cell', 'Prostate cancer', 'Uterine cancer', 'Other malignancy (specify)'))
AND ISNULL(TAE.OnsetDate, '')<>''
AND (((D.startDate<=TAE.OnsetDate OR D.prescribeddate<=TAE.OnsetDate) AND (ISNULL(D.endDate,'')='' OR DATEDIFF(D, D.endDate, TAE.OnsetDate)<=120))
OR (ISNULL(D.startDate, '')='' AND ISNULL(D.prescribeddate, '')='' AND ISNULL(D.enddate, '')=''))

UNION

/*For Cancer Events, pull in all drugs from drug log started prior or at the Onset Date or have no start or end date.*/

SELECT DISTINCT TAE.SITENUM,
       TAE.SUBNUM,
       TAE.SUBID,
	   TAE.vID,
	   TAE.EventType,
	   TAE.EventTerm,
	   TAE.OnsetDate,
	   TAEOUT.RptVisitDate,
	   D.PAGENAME,
	   D.drug,
	   D.drugoth,
	   D.prescribeddate,
	   D.startDate,
	   D.endDate,
	   DATEDIFF(D, COALESCE(startDate, prescribeddate), OnsetDate) AS daysStartedPriortoOnset,
	   DATEDIFF(M, OnsetDate, COALESCE(startDate, prescribeddate)) AS monthsStartedAfterOnset,
	   DATEDIFF(d, endDate, OnsetDate) AS daysEndedPriortoOnset
	   
FROM #TAEINFO TAE  
LEFT JOIN #TAEOUTCOMES TAEOUT ON TAEOUT.vID=TAE.vID AND TAEOUT.VISNAME=TAE.VISNAME AND TAEOUT.VISITSEQ=TAE.VISITSEQ
LEFT JOIN #DRUGS D ON D.SUBID=TAE.SUBID 
WHERE ((EventType='Malignancy')
OR (ISNULL(TAE.EventTerm, '') IN ('Breast cancer', 'Cervical cancer', 'Colon cancer', 'Leukemia', 'Lung cancer', 'Lymphoma', 'Melanoma skin cancer', 'Non-melanoma skin cancer basal cell', 'Non-melanoma skin cancer squamous cell', 'Prostate cancer', 'Uterine cancer', 'Other malignancy (specify)')))
AND ISNULL(TAE.OnsetDate, '')<>''
AND ((D.startDate<=TAE.OnsetDate OR D.prescribeddate<=TAE.OnsetDate)
OR (ISNULL(D.startDate, '')='' AND ISNULL(D.prescribeddate, '')='' AND ISNULL(D.enddate, '')=''))

UNION

/*For pregnancy events, if the drug is started > 10 months from the onset date, exclude. If drug has been stopped for greater than 120 days, exclude.*/

SELECT DISTINCT TAE.SITENUM,
       TAE.SUBNUM,
       TAE.SUBID,
	   TAE.vID,
	   TAE.EventType,
	   TAE.EventTerm,
	   TAE.OnsetDate,
	   TAEOUT.RptVisitDate,
	   D.PAGENAME,
	   D.drug,
	   D.drugoth,
	   D.prescribeddate,
	   D.startDate,
	   D.endDate,
	   DATEDIFF(D, COALESCE(startDate, prescribeddate), OnsetDate) AS daysStartedPriortoOnset,
	   DATEDIFF(M, OnsetDate, COALESCE(startDate, prescribeddate)) AS monthsStartedAfterOnset,
	   DATEDIFF(d, endDate, OnsetDate) AS daysEndedPriortoOnset
	   
FROM #TAEINFO TAE  
LEFT JOIN #TAEOUTCOMES TAEOUT ON TAEOUT.vID=TAE.vID AND TAEOUT.VISNAME=TAE.VISNAME AND TAEOUT.VISITSEQ=TAE.VISITSEQ
LEFT JOIN #DRUGS D ON D.SUBID=TAE.SUBID 
WHERE ISNULL(TAE.EventTerm, '') = 'Pregnancy'
AND ISNULL(TAE.OnsetDate, '')<>''
AND (((D.startDate<=TAE.OnsetDate OR D.prescribeddate<=OnsetDate) AND (ISNULL(D.endDate,'')='' OR DATEDIFF(D, D.endDate, TAE.OnsetDate)<=120)
OR DATEDIFF(M, OnsetDate, COALESCE(startDate, prescribeddate))<=10)
OR (ISNULL(D.startDate, '')='' AND ISNULL(D.prescribeddate, '')='' AND ISNULL(D.enddate, '')=''))

UNION

SELECT DISTINCT TAE.SITENUM,
       TAE.SUBNUM,
       TAE.SUBID,
	   TAE.vID,
	   TAE.EventType,
	   TAE.EventTerm,
	   TAE.OnsetDate,
	   TAEOUT.RptVisitDate,
	   D.PAGENAME,
	   D.drug,
	   D.drugoth,
	   D.prescribeddate,
	   D.startDate,
	   D.endDate,
	   DATEDIFF(D, COALESCE(startDate, prescribeddate), OnsetDate) AS daysStartedPriortoOnset,
	   DATEDIFF(M, OnsetDate, COALESCE(startDate, prescribeddate)) AS monthsStartedAfterOnset,
	   DATEDIFF(d, endDate, OnsetDate) AS daysEndedPriortoOnset
	   
FROM #TAEINFO TAE  
LEFT JOIN #TAEOUTCOMES TAEOUT ON TAEOUT.vID=TAE.vID AND TAEOUT.VISNAME=TAE.VISNAME AND TAEOUT.VISITSEQ=TAE.VISITSEQ
LEFT JOIN #DRUGS D ON D.SUBID=TAE.SUBID 
WHERE ISNULL(TAE.OnsetDate, '')=''

) d2

--SELECT * FROM #TAEDRUGS

IF OBJECT_ID('tempdb.dbo.#TAEPIVOT') IS NOT NULL BEGIN DROP TABLE #TAEPIVOT END;

/*Put together all information for TAE QC Listing from previous tables with last modified date and pivot*/

SELECT DISTINCT vID
      ,SITENUM
	  ,SiteStatus
	  ,SUBID
	  ,SUBNUM
	  ,PROVID
	  ,VISNAME
	  ,VISITSEQ
	  ,EventType
	  ,EventTerm
	  ,specifyOtherEvent
	  ,OnsetDate
	  ,EventFirstReported
	  ,RptVisitDate
	  ,confirmationStatus
	  ,notAnEventExplain
	  ,OUTCOME_DEC
	  ,SERIOUS_DEC
	  ,seriousCriteria
	  ,IV_antiInfective
	  ,drugLogTreatments
	  ,otherDrugLogTreatments
	  ,drugExposure
	  ,otherDrugExposure
	  ,gender
	  ,YearOfBirth
	  ,race
	  ,Ethnicity
	  ,suppDocs
	  ,suppdocsUpload
	  ,suppDocsNotSubmReas
	  ,suppDocsApproved
	  ,eventPaid
	  ,suppDocsPaid
	  ,HasData
	  ,CreatedDate
	  ,[Confirmation Status] AS LMDT_confirmationStatus
	  ,[Event Information] AS LMDT_eventInformation
	  ,[Event Details] AS LMDT_eventDetails
	  ,[Drug Exposure] AS LMDT_drugExposure
	  ,[Other Concurrent Drugs] AS LMDT_otherConcurrentDrugs
	  ,[Flare Visits] AS LMDT_flareVisits
	  ,[Subject Form] AS LMDT_subjectForm
	  ,[TAE Test Results] AS LMDT_testResults
	  ,[Event Completion] AS LMDT_eventCompletion
	  ,[Case Processing] AS [LMDT_CaseProcessing]
	  ,EventDataEntryStatus
	  ,eventPaymentEligibility
	 
INTO #TAEPIVOT
FROM 
(
SELECT DISTINCT lm.vID,
       lm.SITENUM,
	   lm.SiteStatus,
	   lm.SUBID,
	   lm.SUBNUM,
	   T2.PROVID,
	   lm.VISNAME,
	   lm.PAGENAME,
	   lm.VISITSEQ,
	   lm.EventType,
	   T.EventTerm,
	   T.specifyOtherEvent,
	   T.OnsetDate,
	   T2.EventFirstReported,
	   T2.RptVisitDate,
	   T.confirmationStatus,
	   T.notAnEventExplain,
	   T2.OUTCOME_DEC,
	   T2.SERIOUS_DEC,
	   T2.seriousCriteria,
	   T.IV_antiInfective, 

	   STUFF((
	   SELECT DISTINCT ', ' + drug
	   FROM #TAEDRUGS drugs
	   WHERE drugs.SUBID=t.SUBID 
	   AND drugs.vID=t.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS drugLogTreatments,

	   STUFF((
	   SELECT DISTINCT ', ' + DRUGOTH
	   FROM #TAEDRUGS drugs
	   WHERE drugs.SUBID=t.SUBID 
	   AND drugs.vID=t.vID
	   FOR XML PATH('')
        )
        ,1,1,'') AS otherDrugLogTreatments,

	   T.drugExposure,
	   T.otherDrugExposure,
	   T.gender,
	   T.YearOfBirth,
	   T.race,
	   T.Ethnicity,
	   T2.suppDocs,
	   t2.suppdocsUpload,
	   T2.suppDocsNotSubmReas,
	   T2.suppDocsApproved,
	   T2.eventPaid,
	   T2.suppDocsPaid,

	   CASE WHEN T.STATUSID_DEC='No Data' THEN 'No'
	   ELSE 'Yes'
	   END AS HasData,

	   LM.CreatedDate,
	   LM.LastModifiedDate,
	   T.EventDataEntryStatus,
	   CASE WHEN T.eventPaymentEligibility='X' and T.EventDataEntryStatus='Complete' THEN 'Eligible'
	   ELSE 'Not eligible'
	   END AS eventPaymentEligibility

FROM #LMDT LM 
LEFT JOIN #TAEINFO T ON LM.vID=T.vID
LEFT JOIN #TAEOUTCOMES T2 ON T.vID=T2.vID
 ) AS SourceTable PIVOT(MAX(LastModifiedDate) FOR PAGENAME IN ([Confirmation Status], [Event Information], [Event Details], [Drug Exposure], [Other Concurrent Drugs], [Flare Visits], [Subject Form], [TAE Test Results], [Event Completion], [Case Processing])
 ) AS PivotTable  

 --SELECT * FROM #TAEPIVOT WHERE SUBNUM='GPP-9900-0007' ORDER BY SITENUM, SUBNUM, VISNAME, VISITSEQ, EVENTTYPE, EVENTTERM

 TRUNCATE TABLE [GPP510].[t_pv_TAEQCListing];

 INSERT INTO [GPP510].[t_pv_TAEQCListing]
 (
       vID
      ,SITENUM
	  ,SiteStatus
	  ,SUBID
	  ,SUBNUM
	  ,PROVID
	  ,VISNAME
	  ,VISITSEQ
	  ,EventType
	  ,EventTerm
	  ,specifyOtherEvent
	  ,OnsetDate
	  ,EventFirstReported
	  ,RptVisitDate
	  ,confirmationStatus
	  ,notAnEventExplain
	  ,OUTCOME_DEC
	  ,SERIOUS_DEC
	  ,seriousCriteria
	  ,IV_antiInfective
	  ,drugLogTreatments
	  ,otherDrugLogTreatments
	  ,drugExposure
	  ,otherDrugExposure
	  ,gender
	  ,YearOfBirth
	  ,race
	  ,Ethnicity
	  ,suppDocs
	  ,suppdocsUpload
	  ,suppDocsNotSubmReas
	  ,suppDocsApproved
	  ,eventPaid
	  ,suppDocsPaid
	  ,HasData
	  ,CreatedDate
	  ,LMDT_confirmationStatus
	  ,LMDT_eventInformation
	  ,LMDT_eventDetails
	  ,LMDT_drugExposure
	  ,LMDT_otherConcurrentDrugs
	  ,LMDT_flareVisits
	  ,LMDT_subjectForm
	  ,LMDT_testResults
	  ,LMDT_eventCompletion
	  ,LMDT_CaseProcessing
	  ,EventDataEntryStatus
	  ,eventPaymentEligibility
 )

 SELECT DISTINCT vID
      ,SITENUM
	  ,SiteStatus
	  ,SUBID
	  ,SUBNUM
	  ,PROVID
	  ,VISNAME
	  ,VISITSEQ
	  ,EventType
	  ,EventTerm
	  ,specifyOtherEvent
	  ,OnsetDate
	  ,EventFirstReported
	  ,RptVisitDate
	  ,confirmationStatus
	  ,notAnEventExplain
	  ,OUTCOME_DEC
	  ,SERIOUS_DEC
	  ,ltrim(seriousCriteria) AS seriousCriteria
	  ,IV_antiInfective
	  ,ltrim(drugLogTreatments) AS drugLogTreatments
	  ,ltrim(otherDrugLogTreatments) AS otherDrugLogTreatments
	  ,ltrim(drugExposure) AS drugExposure
	  ,ltrim(otherDrugExposure) AS otherDrugExposure
	  ,gender
	  ,YearOfBirth
	  ,race
	  ,Ethnicity
	  ,suppDocs
	  ,suppdocsUpload
	  ,suppDocsNotSubmReas
	  ,suppDocsApproved
	  ,eventPaid
	  ,suppDocsPaid
	  ,HasData
	  ,tp.CreatedDate
	  ,LMDT_confirmationStatus
	  ,LMDT_eventInformation
	  ,LMDT_eventDetails
	  ,LMDT_drugExposure
	  ,LMDT_otherConcurrentDrugs
	  ,LMDT_flareVisits
	  ,LMDT_subjectForm
	  ,LMDT_testResults
	  ,LMDT_eventCompletion
	  ,LMDT_CaseProcessing
	  ,CASE WHEN ISNULL(EventDataEntryStatus, '')='' THEN 'Incomplete'
	   ELSE EventDataEntryStatus
	   END AS EventDataEntryStatus
	  ,eventPaymentEligibility

FROM #TAEPIVOT tp

 --SELECT * FROM GPP510.t_pv_TAEQCListing where subnum='GPP-9900-0007' ORDER BY SITENUM, SUBNUM, VISNAME, VISITSEQ, EVENTTYPE, EVENTTERM





END

GO
