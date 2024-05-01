USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_OtherDrugs_AllVisits]    Script Date: 5/1/2024 1:26:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/*
Fixed By: Kevin Soe
Fix Date: 6/2/2021
Fix Description: Status column values cut off portions of responses due to export being updated to remove html in decoded value fields.
Fix updated the character number from which data value extraction from begin from.
*/


CREATE view [RA102].[v_op_OtherDrugs_AllVisits] as

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


,OD as 
(
SELECT
	 PE4.VID
	,PE4.SITENUM AS SITEID
	,PE4.SUBNUM AS SUBJECTID
	,PE4.VISNAME AS VISITTYPE
	,PE4.PAGENAME AS PAGENAME
	,'Biologic & Targeted Synthetic DMARDs as of Yesterday' AS SECTIONNAME

	,(SELECT VISITDATE FROM MERGE_RA_JAPAN.STAGING.VIS_DATE B WHERE B.VID=PE4.VID AND B.SUBNUM=PE4.SUBNUM AND B.VISITID=PE4.VISITID) AS VISITDATE

	,CAST((SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.STAGING.PRO_01 A WHERE A.VID=PE4.VID AND A.SUBNUM=PE4.SUBNUM AND A.VISITID=PE4.VISITID) AS INT) AS PROVIDERID

	,PE4.OTH_BIOTS_TEXT AS DRUGNAME
	
	,CASE WHEN PE4.OTH_BIOTS_STATUS=1 THEN 'Current'
	WHEN PE4.OTH_BIOTS_STATUS=2 THEN 'Past'
	WHEN PE4.OTH_BIOTS_STATUSFU_NOCHG='X' THEN 'No Change'
	WHEN PE4.OTH_BIOTS_STATUSFU_ST='X' THEN 'Start'
	WHEN PE4.OTH_BIOTS_STATUSFU_DCHG='X' THEN 'Dose Change'
	WHEN PE4.OTH_BIOTS_STATUSFU_STP='X' THEN 'Stop'
	ELSE ''
	END	AS DRUGSTATUS

	,CASE PE4.OTH_BIOTS_FIRSTEVER
	 WHEN 1 THEN 'Yes'
	 WHEN 0 THEN 'No'
	 ELSE ''
	 END AS FIRSTEVERUSE

	 ,PE4.OTH_BIOTS_DT_ST_DY AS STARTDAY
	 ,PE4.OTH_BIOTS_DT_ST_MO AS STARTMONTH
	 ,PE4.OTH_BIOTS_DT_ST_YR AS STARTYEAR

	 ,PE4.RSNSTART1_OTH_BIOTS_DEC AS STARTREASON1

     ,PE4.RSNSTART2_OTH_BIOTS_DEC AS STARTREASON2

     ,PE4.RSNSTART3_OTH_BIOTS_DEC AS STARTREASON3

    ,NULL AS TODAYREASON1
	,NULL AS TODAYREASON2
	,NULL AS TODAYREASON3

     ,PE4.OTH_BIOTS_DOSE AS DRUGDOSE

     ,PE4.OTH_BIOTS_DOSE_UNITS AS DRUGUNITS

      ,PE4.OTH_BIOTS_ROUTE_DEC AS DRUGROUTE

     ,CAST(PE4.OTH_BIOTS_FREQ AS VARCHAR) AS DRUGFREQ
	 ,CAST(PE4.OTH_BIOTS_FREQ_UNITS AS VARCHAR) AS DRUGFREQUNITS

	 ,PE4.OTH_BIOTS_DT_STP_DY AS STOPDAY
	 ,PE4.OTH_BIOTS_DT_STP_MO  AS STOPMONTH
	 ,PE4.OTH_BIOTS_DT_STP_YR AS STOPYEAR

 	 ,PE4.RSNSTOP1_OTH_BIOTS_DEC AS STOPREASON1
     ,PE4.RSNSTOP2_OTH_BIOTS_DEC AS STOPREASON2
     ,PE4.RSNSTOP3_OTH_BIOTS_DEC AS STOPREASON3


FROM MERGE_RA_Japan.staging.PE_04 PE4
WHERE PE4.OTH_BIOTS_USE='X'

UNION

SELECT PRO5.vID
      ,PRO5.SITENUM AS SITEID
	  ,PRO5.SUBNUM AS SUBJECTID
	  ,PRO5.VISNAME AS VISITTYPE
	  ,PRO5.PAGENAME AS PAGENAME
	  ,'Conventional Synthetic DMARDs as of Yesterday' AS SECTIONNAME

	  ,VIS.VISITDATE AS VISITDATE 
	  ,CAST((SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.STAGING.PRO_01 A WHERE A.VID=PRO5.VID AND A.SUBNUM=PRO5.SUBNUM AND A.VISITID=PRO5.VISITID) AS INT) AS PROVIDERID

	,OTH_CSDMARD_TEXT AS DRUGNAME

	,CASE WHEN PRO5.CSDMARD_STATUS=1 THEN 'Current'
	      WHEN PRO5.CSDMARD_STATUS=2 THEN 'Past'
		  WHEN PRO5.OTH_CSDMARD_STATUSFU_NOCHG='X' THEN 'No Change'
		  WHEN PRO5.OTH_CSDMARD_STATUSFU_ST='X' THEN 'Start'
		  WHEN PRO5.OTH_CSDMARD_STATUSFU_DCHG='X' THEN 'Dose Change'
		  WHEN PRO5.OTH_CSDMARD_STATUSFU_STP='X' THEN 'Stop'
		  ELSE ''
	END AS DRUGSTATUS

     ,SUBSTRING(PRO5.OTH_CSDMARD_FIRST_DEC, 14, 18) AS FIRSTEVERUSE

	 ,PRO5.OTH_CSDMARD_DT_ST_DY AS STARTDAY
	 ,PRO5.OTH_CSDMARD_DT_ST_MO  AS STARTMONTH
	 ,PRO5.OTH_CSDMARD_DT_ST_YR AS STARTYEAR

	 ,PRO5.RSNSTART1_OTH_CSDMARD_DEC AS STARTREASON1
     ,PRO5.RSNSTART2_OTH_CSDMARD_DEC AS STARTREASON2
     ,PRO5.RSNSTART3_OTH_CSDMARD_DEC AS STARTREASON3

     ,NULL AS TODAYREASON1
	 ,NULL AS TODAYREASON2
	 ,NULL AS TODAYREASON3

     ,CONVERT(VARCHAR(25),PRO5.OTH_CSDMARD_DOSE) AS DRUGDOSE
	 ,OTH_CSDMARD_DOSE_UNITS AS DRUGUNITS

      ,PRO5.OTH_CSDMARD_ROUTE_DEC AS DRUGROUTE
	 
     ,CONVERT(VARCHAR(25), PRO5.OTH_CSDMARD_FREQ) AS DRUGFREQ
     ,CONVERT(VARCHAR(25), PRO5.OTH_CSDMARD_FREQ_UNITS) AS DRUGFREQUNIT
	 
	 ,PRO5.OTH_CSDMARD_DT_STP_DY AS STOPDAY
	 ,PRO5.OTH_CSDMARD_DT_STP_MO  AS STOPMONTH
	 ,PRO5.OTH_CSDMARD_DT_STP_YR AS STOPYEAR

 	 ,PRO5.RSNSTOP1_OTHCSDMARD_DEC AS STOPREASON1
     ,PRO5.RSNSTOP2_OTHCSDMARD_DEC AS STOPREASON2
     ,PRO5.RSNSTOP3_OTHCSDMARD_DEC AS STOPREASON3

FROM MERGE_RA_Japan.STAGING.PRO_05 PRO5
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PRO5.vID=VIS.VID
WHERE PRO5.OTH_CSDMARD_USE='X'


UNION

SELECT PRO6.vID
      ,PRO6.SITENUM AS SITEID
	  ,PRO6.SUBNUM AS SUBJECTID
	  ,PRO6.VISNAME AS VISITTYPE
	  ,PRO6.PAGENAME AS PAGENAME
	  ,'Changes Made Today' AS SECTIONNAME

	  ,VIS.VISITDATE AS VISITDATE 
	  ,CAST((SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.STAGING.PRO_01 A WHERE A.VID=PRO6.VID AND A.SUBNUM=PRO6.SUBNUM AND A.VISITID=PRO6.VISITID) AS INT) AS PROVIDERID

	  ,OTHER_BIONB_SPECIFY AS DRUGNAME

	 ,SUBSTRING(PRO6.OTHER_BIONB_STATUSTODAY_DEC, 3, 25) AS DRUGSTATUS

     ,NULL AS FIRSTEVERUSE

	 ,NULL AS STARTDAY
	 ,NULL AS STARTMONTH
	 ,NULL AS STARTYEAR

	 ,NULL AS STARTREASON1
     ,NULL AS STARTREASON2
     ,NULL AS STARTREASON3

	 ,PRO6.RSNTODAY1_OTHER_BIONB_DEC AS TODAYREASON1
	 ,PRO6.RSNTODAY2_OTHER_BIONB_DEC AS TODAYREASON2
	 ,PRO6.RSNTODAY3_OTHER_BIONB_DEC AS TODAYREASON3
	 ,CONVERT(VARCHAR(25),PRO6.OTHER_BIONB_PRESDOSE) AS DRUGDOSE
	 ,PRO6.OTHER_BIONB_PRESDOSEUNITS AS DRUGUNITS

	 ,ISNULL(PRO6.OTH_BIONB_PRESROUTE_DEC, '') + ' ' +  isnull(PRO6.OTH_BIONB_PRESROUTE_OTHER, '') AS DRUGROUTE

     ,CAST(PRO6.OTHER_BIONB_PRESFREQ AS VARCHAR) AS DRUGFREQ
	 ,CAST(PRO6.OTHER_BIONB_PRESFREQUNITS AS VARCHAR) AS DRUGFREQUNIT
	 ,NULL AS STOPDAY
	 ,NULL AS STOPMONTH
	 ,NULL AS STOPYEAR
	 ,NULL AS STOPREASON1
	 ,NULL AS STOPREASON2
	 ,NULL AS STOPREASON3

FROM MERGE_RA_Japan.STAGING.PRO_06 PRO6
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PRO6.vID=VIS.VID

WHERE PRO6.OTHER_BIONB_USETODAY='X'


---ORDER BY SITEID, SUBJECTID, VISITDATE
)

SELECT d.[SITEID]
	 , d.[SUBJECTID]
	 , d.[VISITTYPE]
	 , d.[VISITDATE]
	 , d.[PAGENAME]
	 , d.[SECTIONNAME]
	 , d.[PROVIDERID]
	 , d.[DRUGNAME]
	 , d.[DRUGSTATUS]
	 , d.[FIRSTEVERUSE]
	 , isnull((CAST(d.[STARTDAY] AS VARCHAR) + '-'), '') + ISNULL((st.[MonthString] + '-'), '') + ISNULL(CAST(d.[STARTYEAR] AS VARCHAR), '') AS STARTDATE
	 , CASE WHEN d.[STARTREASON2] IS NULL THEN ISNULL(d.[STARTREASON1], '') 
	   WHEN d.[STARTREASON2] IS NOT NULL AND d.[STARTREASON3] IS NULL THEN d.[STARTREASON1] + ', ' + d.[STARTREASON2]
	   WHEN d.[STARTREASON2] is not null and d.[STARTREASON3] is not null THEN d.[STARTREASON1] + ', ' + d.[STARTREASON2] + ', ' + d.[STARTREASON3]
       ELSE '' END AS STARTREASON
	 , CASE WHEN d.[TODAYREASON2] IS NULL THEN ISNULL(d.[TODAYREASON1], '') 
	   WHEN d.[TODAYREASON2] IS NOT NULL AND d.[TODAYREASON3] IS NULL THEN d.[TODAYREASON1] + ', ' + d.[TODAYREASON2]
	   WHEN d.[TODAYREASON2] is not null and d.[TODAYREASON3] is not null THEN d.[TODAYREASON1] + ', ' + d.[TODAYREASON2] + ', ' + d.[TODAYREASON3]
       ELSE '' END AS TODAYREASON
	 , d.[DRUGDOSE]
	 , d.[DRUGUNITS]
	 , d.[DRUGROUTE]
	 , ISNULL(d.[DRUGFREQ], '') + ' ' + ISNULL(d.DRUGFREQUNITS, '') AS DRUGFREQ
	 , isnull((CAST(d.[STOPDAY] AS VARCHAR) + '-'), '') + isnull((stp.[MonthString] + '-'), '') + isnull(CAST(d.[STOPYEAR] AS VARCHAR), '') AS STOPDATE
	 , CASE WHEN d.[STOPREASON2] IS NULL THEN ISNULL(d.[STOPREASON1], '') 
	   WHEN d.[STOPREASON2] IS NOT NULL AND d.[STOPREASON3] IS NULL THEN d.[STOPREASON1] + ', ' + d.[STOPREASON2]
	   WHEN d.[STOPREASON2] is not null and d.[STOPREASON3] is not null THEN d.[STOPREASON1] + ', ' + d.[STOPREASON2] + ', ' + d.[STOPREASON3]
       ELSE '' END AS STOPREASON


FROM OD d 
left join months st on st.MonthCode = d.STARTMONTH
left join months stp on stp.MonthCode = d.STOPMONTH

---ORDER BY SITEID, SUBJECTID, VISITDATE






GO
