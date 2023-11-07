USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_Xeljanz_Switches]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [RA102].[v_op_Xeljanz_Switches] as

with months as (
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

,BiologicsStartedYest as (
SELECT PE4.vID
      ,PE4.SITENUM AS SITEID
	  ,PE4.SUBNUM AS SUBJECTID
	  ,PE4.VISNAME AS VISITTYPE
      ,CASE WHEN PE4.ORENCIA_STATUSFU_ST='X' THEN 'Orencia' ELSE NULL END AS ORENCIA
	  ,CASE WHEN PE4.HUMIRA_STATUSFU_ST='X' THEN 'Humira' ELSE NULL END AS HUMIRA
	  ,CASE WHEN PE4.CIMZIA_STATUSFU_ST='X' THEN 'Cimzia' ELSE NULL END AS CIMZIA
	  ,CASE WHEN PE4.ENBREL_STATUSFU_ST='X' THEN 'Enbrel' ELSE NULL END AS ENBREL
	  ,CASE WHEN PE4.SIMPONI_STATUSFU_ST='X' THEN 'Simponi' ELSE NULL END AS SIMPONI
	  ,CASE WHEN PE4.REMICADE_STATUSFU_ST='X' THEN 'Remicade' ELSE NULL END AS REMICADE
	  ,CASE WHEN REMICADE_BIOSIM_STATUSFU_ST='X' THEN 'Remicade Biosimilar' ELSE NULL END AS REMICADE_BIOSIM
	  ,CASE WHEN ACTEMRA_STATUSFU_ST='X' THEN 'Actemra' ELSE NULL END AS ACTEMRA
	  ,CASE WHEN PE4.OTH_BIOTS_STATUSFU_ST='X' THEN 'Other Biologic' ELSE NULL END AS OTHER_BIOTS

FROM MERGE_RA_Japan.STAGING.PE_04 AS PE4
)

,BSY AS (
SELECT A.vID
      ,A.SITEID
	  ,A.SUBJECTID
	  ,A.VISITTYPE
	  ,ISNULL(A.ORENCIA + ', ', '') + ISNULL(A.HUMIRA + ', ', '') + ISNULL(A.CIMZIA + ', ', '') +
	  ISNULL(A.ENBREL +', ', '') + ISNULL(A.SIMPONI + ', ', '') + ISNULL(A.REMICADE + ', ', '') +
	  ISNULL(A.REMICADE_BIOSIM + ', ', '') + ISNULL(ACTEMRA + ', ', '') + ISNULL(OTHER_BIOTS, '') AS [Biologics Started Yesterday]
FROM BiologicsStartedYest as A
)


,DmardsStartedYest as (
SELECT PRO5.vID
      ,PRO5.SITENUM AS SITEID
	  ,PRO5.SUBNUM AS SUBJECTID
	  ,PRO5.VISNAME AS VISITTYPE
      ,CASE WHEN PRO5.BUC_STATUSFU_ST='X' THEN 'bucillamine' ELSE NULL END AS BUCILLAMINE
      ,CASE WHEN PRO5.KEARAMU_STATUSFU_ST='X' THEN 'Careram' ELSE NULL END AS CARERAM
	  ,CASE WHEN PRO5.ARAVA_STATUSFU_ST='X' THEN 'Arava' ELSE NULL END AS ARAVA
	  ,CASE WHEN PRO5.MTX_STATUSFU_ST='X' THEN 'methotrexate' ELSE NULL END AS MTX
	  ,CASE WHEN PRO5.PRED_STATUSFU_ST='X' THEN 'prednisone' ELSE NULL END AS PREDNISONE
	  ,CASE WHEN PRO5.AZULFIDINE_STATUSFU_ST='X' THEN 'sulfasalazine' ELSE NULL END AS SULFASALAZINE
	  ,CASE WHEN PRO5.PROGRAF_STATUSFU_ST='X' THEN 'Prograf' ELSE NULL END AS PROGRAF
	  ,CASE WHEN PRO5.OTH_CSDMARD_STATUSFU_ST='X' THEN 'other' ELSE NULL END AS OTHERDMARD

FROM MERGE_RA_Japan.STAGING.PRO_05 AS PRO5
)


,DSY as (
SELECT A.vID
      ,A.SITEID
	  ,A.SUBJECTID
	  ,A.VISITTYPE
	  ,ISNULL(A.BUCILLAMINE + ', ', '') + ISNULL(A.CARERAM + ', ', '') + ISNULL(A.ARAVA + ', ', '') +
	  ISNULL(A.MTX +', ', '') + ISNULL(A.PREDNISONE + ', ', '') + ISNULL(A.SULFASALAZINE + ', ', '') +
	  ISNULL(A.PROGRAF + ', ', '') + ISNULL(A.OTHERDMARD, '') AS [Dmards Started Yesterday]

FROM DmardsStartedYest as A
)

,BiologicsStoppedYest as (
SELECT PE4.vID
      ,PE4.SITENUM AS SITEID
	  ,PE4.SUBNUM AS SUBJECTID
	  ,PE4.VISNAME AS VISITTYPE
      ,CASE WHEN PE4.ORENCIA_STATUSFU_STP='X' THEN 'Orencia' ELSE NULL END AS ORENCIA
	  ,CASE WHEN PE4.HUMIRA_STATUSFU_STP='X' THEN 'Humira' ELSE NULL END AS HUMIRA
	  ,CASE WHEN PE4.CIMZIA_STATUSFU_STP='X' THEN 'Cimzia' ELSE NULL END AS CIMZIA
	  ,CASE WHEN PE4.ENBREL_STATUSFU_STP='X' THEN 'Enbrel' ELSE NULL END AS ENBREL
	  ,CASE WHEN PE4.SIMPONI_STATUSFU_STP='X' THEN 'Simponi' ELSE NULL END AS SIMPONI
	  ,CASE WHEN PE4.REMICADE_STATUSFU_STP='X' THEN 'Remicade' ELSE NULL END AS REMICADE
	  ,CASE WHEN REMICADE_BIOSIM_STATUSFU_STP='X' THEN 'Remicade Biosimilar' ELSE NULL END AS REMICADE_BIOSIM
	  ,CASE WHEN ACTEMRA_STATUSFU_STP='X' THEN 'Actemra' ELSE NULL END AS ACTEMRA
	  ,CASE WHEN PE4.OTH_BIOTS_STATUSFU_STP='X' THEN 'Other Biologic' ELSE NULL END AS OTHER_BIOTS

FROM MERGE_RA_Japan.STAGING.PE_04 AS PE4
)

,BSTPY AS (
SELECT A.vID
      ,A.SITEID
	  ,A.SUBJECTID
	  ,A.VISITTYPE
	  ,ISNULL(A.ORENCIA + ', ', '') + ISNULL(A.HUMIRA + ', ', '') + ISNULL(A.CIMZIA + ', ', '') +
	  ISNULL(A.ENBREL +', ', '') + ISNULL(A.SIMPONI + ', ', '') + ISNULL(A.REMICADE + ', ', '') +
	  ISNULL(A.REMICADE_BIOSIM + ', ', '') + ISNULL(ACTEMRA + ', ', '') + ISNULL(OTHER_BIOTS, '') AS [Biologics Stopped Yesterday]
FROM BiologicsStoppedYest as A
)

,DmardsStoppedYest as (
SELECT PRO5.vID
      ,PRO5.SITENUM AS SITEID
	  ,PRO5.SUBNUM AS SUBJECTID
	  ,PRO5.VISNAME AS VISITTYPE
      ,CASE WHEN PRO5.BUC_STATUSFU_STP='X' THEN 'bucillamine' ELSE NULL END AS BUCILLAMINE
      ,CASE WHEN PRO5.KEARAMU_STATUSFU_STP='X' THEN 'Careram' ELSE NULL END AS CARERAM
	  ,CASE WHEN PRO5.ARAVA_STATUSFU_STP='X' THEN 'Arava' ELSE NULL END AS ARAVA
	  ,CASE WHEN PRO5.MTX_STATUSFU_STP='X' THEN 'methotrexate' ELSE NULL END AS MTX
	  ,CASE WHEN PRO5.PRED_STATUSFU_STP='X' THEN 'prednisone' ELSE NULL END AS PREDNISONE
	  ,CASE WHEN PRO5.AZULFIDINE_STATUSFU_STP='X' THEN 'sulfasalazine' ELSE NULL END AS SULFASALAZINE
	  ,CASE WHEN PRO5.PROGRAF_STATUSFU_STP='X' THEN 'Prograf' ELSE NULL END AS PROGRAF
	  ,CASE WHEN PRO5.OTH_CSDMARD_STATUSFU_STP='X' THEN 'other' ELSE NULL END AS OTHERDMARD

FROM MERGE_RA_Japan.STAGING.PRO_05 AS PRO5
)


,DSTPY as (
SELECT B.vID
      ,B.SITEID
	  ,B.SUBJECTID
	  ,B.VISITTYPE
	  ,ISNULL(B.BUCILLAMINE + ', ', '') + ISNULL(B.CARERAM + ', ', '') + ISNULL(B.ARAVA + ', ', '') +
	  ISNULL(B.MTX +', ', '') + ISNULL(B.PREDNISONE + ', ', '') + ISNULL(B.SULFASALAZINE + ', ', '') +
	  ISNULL(B.PROGRAF + ', ', '') + ISNULL(B.OTHERDMARD, '') AS [Dmards Stopped Yesterday]

FROM DmardsStoppedYest as B
)


,DrugsStartedToday AS (

SELECT PRO6.vID
      ,PRO6.SITENUM AS SITEID
	  ,PRO6.SUBNUM AS SUBJECTID
	  ,PRO6.VISNAME AS VISITTYPE
	  ,CASE WHEN PRO6.ORENCIA_STATUSTODAY IN ('01', '1') THEN 'Orencia' ELSE NULL END AS ORENCIA
	  ,CASE WHEN PRO6.HUMIRA_STATUSTODAY IN ('01', '1') THEN 'Humira' ELSE NULL END AS HUMIRA
	  ,CASE WHEN PRO6.CIMZIA_STATUSTODAY IN ('01', '1') THEN 'Cimzia' ELSE NULL END AS CIMZIA
	  ,CASE WHEN PRO6.ENBREL_STATUSTODAY IN ('01', '1') THEN 'Enbrel' ELSE NULL END AS ENBREL
	  ,CASE WHEN PRO6.SIMPONI_STATUSTODAY IN ('01', '1') THEN 'Simponi' ELSE NULL END AS SIMPONI
	  ,CASE WHEN PRO6.REMICADE_STATUSTODAY IN ('01', '1') THEN 'Remicade' ELSE NULL END AS REMICADE
	  ,CASE WHEN PRO6.REMICADE_BIOSIM_STATUSTODAY IN ('01', '1') THEN 'Remicade BioSimilar' ELSE NULL END AS REMICADE_BIOSIM
	  ,CASE WHEN PRO6.ACTEMRA_STATUSTODAY IN ('01', '1') THEN 'Actemra' ELSE NULL END AS ACTEMRA
	  ,CASE WHEN PRO6.BUC_STATUSTODAY IN ('01', '1') THEN 'bucillamine' ELSE NULL END AS BUCILLAMINE
	  ,CASE WHEN PRO6.KEARAMU_STATUSTODAY IN ('01', '1') THEN 'Careram' ELSE NULL END AS CARERAM
	  ,CASE WHEN PRO6.ARAVA_STATUSTODAY IN ('01', '1') THEN 'Arava' ELSE NULL END AS ARAVA
	  ,CASE WHEN PRO6.MTX_STATUSTODAY IN ('01', '1') THEN 'methotrexate' ELSE NULL END AS MTX
	  ,CASE WHEN PRO6.PRED_STATUSTODAY IN ('01', '1') THEN 'prednisone' ELSE NULL END AS PREDNISONE
	  ,CASE WHEN PRO6.AZULFIDINE_STATUSTODAY IN ('01', '1') THEN 'sulfasalazine' ELSE NULL END AS SULFASALAZINE
	  ,CASE WHEN PRO6.PROGRAF_STATUSTODAY IN ('01', '1') THEN 'Prograf' ELSE NULL END AS PROGRAF
	  ,CASE WHEN PRO6.OTHER_BIONB_STATUSTODAY IN ('01', '1') THEN 'Other Drug' ELSE NULL END AS OTHER_DRUG

FROM MERGE_RA_Japan.STAGING.PRO_06 AS PRO6
)

,DST as (
SELECT C.vID
      ,C.SITEID
	  ,C.SUBJECTID
	  ,C.VISITTYPE
	  ,ISNULL(C.ORENCIA + ', ', '') + ISNULL(C.HUMIRA + ', ', '') + ISNULL(C.CIMZIA + ', ', '') + 
	  ISNULL(C.ENBREL +', ', '') + ISNULL(C.SIMPONI + ', ', '') + ISNULL(C.REMICADE + ', ', '') + 
	  ISNULL(C.REMICADE_BIOSIM + ', ', '') + ISNULL(ACTEMRA + ', ', '') + 
	  ISNULL(C.BUCILLAMINE + ', ', '') + ISNULL(C.CARERAM + ', ', '') + ISNULL(C.ARAVA + ', ', '') + 
	  ISNULL(C.MTX +', ', '') + ISNULL(C.PREDNISONE + ', ', '') + ISNULL(C.SULFASALAZINE + ', ', '') +
	  ISNULL(C.PROGRAF + ', ', '') + ISNULL(C.OTHER_DRUG, '') AS [Drugs Started Today]

FROM DrugsStartedToday as C
)



,DrugsStoppedToday AS (

SELECT PRO6.vID
      ,PRO6.SITENUM AS SITEID
	  ,PRO6.SUBNUM AS SUBJECTID
	  ,PRO6.VISNAME AS VISITTYPE
	  ,CASE WHEN PRO6.ORENCIA_STATUSTODAY IN ('03', '3') THEN 'Orencia' ELSE NULL END AS ORENCIA
	  ,CASE WHEN PRO6.HUMIRA_STATUSTODAY IN ('03', '3') THEN 'Humira' ELSE NULL END AS HUMIRA
	  ,CASE WHEN PRO6.CIMZIA_STATUSTODAY IN ('03', '3') THEN 'Cimzia' ELSE NULL END AS CIMZIA
	  ,CASE WHEN PRO6.ENBREL_STATUSTODAY IN ('03', '3') THEN 'Enbrel' ELSE NULL END AS ENBREL
	  ,CASE WHEN PRO6.SIMPONI_STATUSTODAY IN ('03', '3') THEN 'Simponi' ELSE NULL END AS SIMPONI
	  ,CASE WHEN PRO6.REMICADE_STATUSTODAY IN ('03', '3') THEN 'Remicade' ELSE NULL END AS REMICADE
	  ,CASE WHEN PRO6.REMICADE_BIOSIM_STATUSTODAY IN ('03', '3') THEN 'Remicade BioSimilar' ELSE NULL END AS REMICADE_BIOSIM
	  ,CASE WHEN ACTEMRA_STATUSTODAY IN ('03', '3') THEN 'Actemra' ELSE NULL END AS ACTEMRA
	  ,CASE WHEN BUC_STATUSTODAY IN ('03', '3') THEN 'bucillamine' ELSE NULL END AS BUCILLAMINE
	  ,CASE WHEN KEARAMU_STATUSTODAY IN ('03', '3') THEN 'Careram' ELSE NULL END AS CARERAM
	  ,CASE WHEN ARAVA_STATUSTODAY IN ('03', '3') THEN 'Arava' ELSE NULL END AS ARAVA
	  ,CASE WHEN MTX_STATUSTODAY IN ('03', '3') THEN 'methotrexate' ELSE NULL END AS MTX
	  ,CASE WHEN PRED_STATUSTODAY IN ('03', '3') THEN 'prednisone' ELSE NULL END AS PREDNISONE
	  ,CASE WHEN AZULFIDINE_STATUSTODAY IN ('03', '3') THEN 'sulfasalazine' ELSE NULL END AS SULFASALAZINE
	  ,CASE WHEN PROGRAF_STATUSTODAY IN ('03', '3') THEN 'Prograf' ELSE NULL END AS PROGRAF
	  ,CASE WHEN OTHER_BIONB_STATUSTODAY IN ('03', '3') THEN 'Other Drug' ELSE NULL END AS OTHER_DRUG

FROM MERGE_RA_Japan.STAGING.PRO_06 AS PRO6
)

, DSTPT AS (
SELECT D.vID
      ,D.SITEID
	  ,D.SUBJECTID
	  ,D.VISITTYPE
	  ,ISNULL(D.ORENCIA + ', ', '') + ISNULL(D.HUMIRA + ', ', '') + ISNULL(D.CIMZIA + ', ', '') + 
	  ISNULL(D.ENBREL +', ', '') + ISNULL(D.SIMPONI + ', ', '') + ISNULL(D.REMICADE + ', ', '') + 
	  ISNULL(D.REMICADE_BIOSIM + ', ', '') + ISNULL(D.ACTEMRA + ', ', '') + 
	  ISNULL(D.BUCILLAMINE + ', ', '') + ISNULL(D.CARERAM + ', ', '') + ISNULL(D.ARAVA + ', ', '') + 
	  ISNULL(D.MTX +', ', '') + ISNULL(D.PREDNISONE + ', ', '') + ISNULL(D.SULFASALAZINE + ', ', '') +
	  ISNULL(D.PROGRAF + ', ', '') + ISNULL(D.OTHER_DRUG, '') AS [Drugs Stopped Today]

FROM DrugsStoppedToday as D
)

,Xeljanz as
(
SELECT PE4.vID
      ,PE4.SITENUM AS SITEID
	  ,PE4.SUBNUM AS SUBJECTID
	  ,PE4.VISNAME AS VISITTYPE
	  ,VIS.VISITDATE AS VISITDATE 
	  ,(SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.STAGING.PRO_01 A WHERE A.VID=PE4.VID AND A.SUBNUM=PE4.SUBNUM AND A.VISITID=PE4.VISITID) AS PROVIDERID

	,CASE
	     WHEN (PE4.XELJANZ_USE='X' OR PRO6.XELJANZ_USETODAY='X') THEN 'Xeljanz'
	     ELSE ''
	  END AS DRUGNAME

	,CASE WHEN PE4.XELJANZ_STATUS=1 THEN 'Xeljanz Current'
	      WHEN PE4.XELJANZ_STATUS=2 THEN 'Xeljanz Past'
		  ELSE ''
     END AS EnrollStatus

	 ,CASE WHEN PE4.XELJANZ_STATUSFU_ST='X' THEN 'Xeljanz Start' ELSE '' END AS STARTYEST
	 ,CASE WHEN PE4.XELJANZ_STATUSFU_STP='X' THEN 'Xeljanz Stop' ELSE '' END AS STOPYEST


	 ,SUBSTRING(PRO6.XELJANZ_STATUSTODAY_DEC, 14, 25) AS STATUS_TODAY

	 ,PE4.XELJANZ_DT_ST_DY AS STARTDAY
	 ,PE4.XELJANZ_DT_ST_MO  AS STARTMONTH
	 ,PE4.XELJANZ_DT_ST_YR AS STARTYEAR

	 ,PE4.RSNSTART1_XELJANZ_DEC AS STARTREASON1
	 ,PE4.RSNSTART2_XELJANZ_DEC AS STARTREASON2
	 ,PE4.RSNSTART3_XELJANZ_DEC AS STARTREASON3

	 ,PE4.XELJANZ_DOSE_DEC AS STARTDOSE

     ,PE4.XELJANZ_DOSE_OTH AS STARTDOSE_OTH
	 
	 ,SUBSTRING(PE4.XELJANZ_FREQ_DEC, 14, 25) AS STARTFREQ

---	 ,(SELECT DISTINCT SUBSTRING(CL.DISPLAYNAME, 14, 50) FROM MERGE_RA_Japan.dbo.DES_PDEF PDEF INNER JOIN MERGE_RA_Japan.dbo.DES_CODELIST CL ON 
---PDEF.CODELISTNAME=CL.NAME AND PDEF.REPORTINGT IN ('PE_04') AND PDEF.REPORTINGC='XELJANZ_FREQ' AND CL.CODENAME=convert(varchar(4), PE4.XELJANZ_FREQ)) AS STARTFREQ

     ,PE4.XELJANZ_FREQ_OTH AS STARTFREQ_OTH

	 ,PE4.XELJANZ_DT_STP_DY AS STOPDAY
	 ,PE4.XELJANZ_DT_STP_MO  AS STOPMONTH
	 ,PE4.XELJANZ_DT_STP_YR AS STOPYEAR

	 ,PE4.RSNSTOP1_XELJANZ_DEC AS STOPREASON1
	 ,PE4.RSNSTOP2_XELJANZ_DEC AS STOPREASON2
	 ,PE4.RSNSTOP3_XELJANZ_DEC AS STOPREASON3

	 ,PRO6.RSNTODAY1_XELJANZ_DEC AS REASON1_TODAY
	 ,PRO6.RSNTODAY2_XELJANZ_DEC AS REASON2_TODAY
	 ,PRO6.RSNTODAY3_XELJANZ_DEC AS REASON3_TODAY

	 ,PRO6.XELJANZ_PRESDOSE_DEC AS DOSE_TODAY
	 ,PRO6.XELJANZ_PRESDOSEOTHER AS DOSE_TODAY_OTHER
	 ,SUBSTRING(PRO6.XELJANZ_PRESFREQ_DEC, 14, 25) AS FREQ_TODAY
     ,PRO6.XELJANZ_PRESFREQHRS AS FREQ_TODAY_OTHER

FROM MERGE_RA_Japan.STAGING.PE_04 PE4
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PE4.vID=VIS.VID
LEFT JOIN MERGE_RA_Japan.staging.PRO_06 PRO6 on PRO6.vID=PE4.vID
WHERE ((PE4.XELJANZ_USE='X' AND (PE4.XELJANZ_STATUS=1 OR PE4.XELJANZ_STATUSFU_ST='X' OR PE4.XELJANZ_STATUSFU_STP='X'))
 OR (PRO6.XELJANZ_USETODAY='X' AND PRO6.XELJANZ_STATUSTODAY IN ('1', '3', '01', '03')))
---AND (PE4.SITENUM not in (9999, 9997) AND PRO6.SITENUM NOT IN (9999, 9997))

)

SELECT d.vID
     , d.[SITEID] AS [Site ID]
	 , d.[SUBJECTID] AS [Subject ID]
	 , d.[VISITTYPE] AS [Visit Type]
	 , d.[VISITDATE] AS [Visit Date]
	 , ISNULL(d.[PROVIDERID], '') AS [Provider ID]
	 , d.[EnrollStatus] AS [Xeljanz Current at Enrollment]
 	 , isnull(d.[STATUS_TODAY], '') AS [Xeljanz New or Stopped Today]
	 , d.STARTYEST as [Xeljanz Started as of Yesterday]
	 , isnull(cast(d.[STARTDAY] as nvarchar), '') + ISNULL('-' + st.[MonthString], '') + ISNULL('-' + cast(d.[STARTYEAR] as nvarchar), '') AS [Xeljanz As of Yesterday Start Date]
	 , d.STOPYEST AS [Xeljanz Stopped as of Yesterday]
	 , isnull(cast(d.[STOPDAY] as nvarchar), '') + ISNULL('-' + cast(stp.[MonthString] as nvarchar), '') + ISNULL('-' + cast(d.[STOPYEAR] as nvarchar), '') AS [Xeljanz As of Yesterday Stop Date]
	 , isnull(d.[STARTREASON1], '') + ISNULL(', ' + d.[STARTREASON2], '') + ISNULL(', ' + d.[STARTREASON3], '') AS [Xeljanz Start Reason]
	 , ISNULL(d.[STARTDOSE], '') AS [Xeljanz Start Dose]
	 , d.STARTDOSE_OTH as [Other Start Dose]
	 , ISNULL(d.[STARTFREQ], '') AS [Xeljanz Start Frequency]
	 , d.STARTFREQ_OTH AS [Other Start Frequency]
	 , isnull(d.[STOPREASON1], '') + ISNULL(', ' + d.[STOPREASON2], '') + ISNULL(', ' + d.[STOPREASON3], '') AS [Xeljanz Stop Reason]
     , CASE WHEN d.[STATUS_TODAY] <>'' THEN convert(date, d.[VISITDATE], 101) ELSE NULL END AS [Xeljanz Today's Start or Stop Date]
	 , ISNULL(d.[REASON1_TODAY], '') + ISNULL(', ' + d.[REASON2_TODAY], '') + isnull(', ' + d.[REASON3_TODAY], '') AS [Xeljanz Reason Today]
	 , ISNULL(d.[DOSE_TODAY], '') AS [Xeljanz Dose Today]
	 , d.DOSE_TODAY_OTHER
	 , ISNULL(d.[FREQ_TODAY], '') AS [Xeljanz Frequency Today]
	 , d.FREQ_TODAY_OTHER
	 , CASE WHEN d.[STATUS_TODAY] IN ('Stop drug','Stopped today') THEN ISNULL(DST.[Drugs Started Today], '') ELSE '' END AS [Drugs Started Today]
	 , CASE WHEN d.[STATUS_TODAY] IN ('New Prescription','Prescribed today') THEN ISNULL(DSTPT.[Drugs Stopped Today], '') ELSE '' END AS [Drugs Stopped Today]
	 , CASE WHEN d.STARTYEST='Xeljanz Start' THEN ISNULL(BSTPY.[Biologics Stopped Yesterday], '') ELSE '' END AS [Biologics Stopped Yesterday]
	 , CASE WHEN D.STOPYEST='Xeljanz Stop' THEN ISNULL(BSY.[Biologics Started Yesterday], '') ELSE '' END AS [Biologics Started Yesterday]
	 , CASE WHEN d.STARTYEST='Xeljanz Start' THEN ISNULL(DSTPY.[Dmards Stopped Yesterday], '') ELSE '' END AS [Dmards Stopped Yesterday]
	 , CASE WHEN D.STOPYEST='Xeljanz Stop' THEN ISNULL(DSY.[Dmards Started Yesterday], '') ELSE '' END AS [Dmards Started Yesterday]

FROM Xeljanz d 
left join months st on st.MonthCode = d.STARTMONTH
left join months stp on stp.MonthCode = d.STOPMONTH
LEFT JOIN BSY ON BSY.VID=D.VID
LEFT JOIN DSY ON DSY.VID=D.VID
LEFT JOIN DSTPY ON DSTPY.VID=D.VID
LEFT JOIN BSTPY ON BSTPY.VID=D.VID
LEFT JOIN DST ON DST.VID=D.VID
LEFT JOIN DSTPT ON DSTPT.VID=D.VID

---ORDER BY D.SITEID, D.SUBJECTID, D.VISITDATE








GO
