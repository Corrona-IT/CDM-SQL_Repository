USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_Sulfasalazine_AllVisits]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [RA102].[v_op_Sulfasalazine_AllVisits] as

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

,Sulf as
(
SELECT PRO5.vID
      ,PRO5.SITENUM AS SITEID
	  ,PRO5.SUBNUM AS SUBJECTID
	  ,PRO5.VISNAME AS VISITTYPE
	  ,VIS.VISITDATE AS VISITDATE 
	  ,'Conventional Synthetic DMARD Therapy as of Yesterday' AS PAGENAME
	  ,(SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.STAGING.PRO_01 A WHERE A.VID=PRO5.VID AND A.SUBNUM=PRO5.SUBNUM AND A.VISITID=PRO5.VISITID) AS PROVIDERID

	,CASE
	     WHEN (PRO5.AZULFIDINE_USE='X') THEN 'Sulfasalazine'
	     ELSE ''
	  END AS DRUGNAME

	,CASE WHEN PRO5.AZULFIDINE_STATUS=1 THEN 'Current'
	      WHEN PRO5.AZULFIDINE_STATUS=2 THEN 'Past'
	      WHEN PRO5.AZULFIDINE_STATUSFU_NOCHG='X' THEN 'No Change'
		  WHEN PRO5.AZULFIDINE_STATUSFU_ST='X' THEN 'Start'
		  WHEN PRO5.AZULFIDINE_STATUSFU_DCHG='X' THEN 'Dose Change'
		  WHEN PRO5.AZULFIDINE_STATUSFU_STP='X' THEN 'Stop'
		  ELSE ''
	END AS SULF_STATUS

     ,CASE PRO5.AZULFIDINE_FIRSTEVER
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
		ELSE ''
		END AS FIRSTEVERUSE

	 ,COALESCE(PRO5.AZULFIDINE_DT_ST_DY, PRO5.AZULFIDINE_DT_CHG_DY)  AS SULFDAY
	 ,COALESCE(PRO5.AZULFIDINE_DT_ST_MO, PRO5.AZULFIDINE_DT_CHG_MO)  AS SULFMONTH
	 ,COALESCE(PRO5.AZULFIDINE_DT_ST_YR, PRO5.AZULFIDINE_DT_CHG_YR) AS SULFYEAR

	 ,COALESCE(PRO5.RSNSTART1_AZULFIDINE_DEC, PRO5.RSNCHANGE1_AZULFIDINE_DEC) AS REASON1
     ,COALESCE(PRO5.RSNSTART2_AZULFIDINE_DEC, PRO5.RSNCHANGE2_AZULFIDINE_DEC) AS REASON2
     ,COALESCE(PRO5.RSNSTART3_AZULFIDINE_DEC, PRO5.RSNCHANGE3_AZULFIDINE_DEC) AS REASON3

     ,COALESCE((CONVERT(VARCHAR(25),PRO5.AZULFIDINE_DOSE) + ' mg'), (CONVERT(VARCHAR(25),PRO5.AZULFIDINE_CHGDOSE) + ' mg')) AS SULF_DOSE
	 
	 ,COALESCE(SUBSTRING(PRO5.AZULFIDINE_FREQ_DEC, 14, 34), SUBSTRING(PRO5.AZULFIDINE_CHGFREQ_DEC, 14, 34)) AS SULF_FREQ

FROM MERGE_RA_Japan.STAGING.PRO_05 PRO5
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PRO5.vID=VIS.VID
WHERE (PRO5.AZULFIDINE_USE='X')
AND (PRO5.AZULFIDINE_STATUS<>2)

UNION

SELECT PRO6.vID
      ,PRO6.SITENUM AS SITEID
	  ,PRO6.SUBNUM AS SUBJECTID
	  ,PRO6.VISNAME AS VISITTYPE
	  ,VIS.VISITDATE AS VISITDATE 
	  ,'Changes Made Today' AS PAGENAME
	  ,(SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.STAGING.PRO_01 A WHERE A.VID=PRO6.VID AND A.SUBNUM=PRO6.SUBNUM AND A.VISITID=PRO6.VISITID) AS PROVIDERID

	,CASE
	     WHEN (PRO6.AZULFIDINE_USETODAY='X') THEN 'Sulfasalazine'
	     ELSE ''
	  END AS DRUGNAME

	 ,SUBSTRING(PRO6.AZULFIDINE_STATUSTODAY_DEC, 14, 34) AS SULF_STATUS

	 ,NULL AS FIRSTEVERUSE
	 ,NULL AS SULFDAY
	 ,NULL AS SULFMONTH
	 ,NULL AS SULFYEAR

	 ,PRO6.RSNTODAY1_AZULFIDINE_DEC AS REASON1

	 ,PRO6.RSNTODAY2_AZULFIDINE_DEC AS REASON2

	 ,PRO6.RSNTODAY3_AZULFIDINE_DEC AS REASON3

	 ,(CONVERT(VARCHAR(25),PRO6.AZULFIDINE_PRESDOSE) + ' mg') AS SULF_DOSE

	 ,SUBSTRING(PRO6.AZULFIDINE_PRESFREQ_DEC, 14, 50) AS SULF_FREQ


FROM MERGE_RA_Japan.STAGING.PRO_06 PRO6
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PRO6.vID=VIS.VID
WHERE (PRO6.AZULFIDINE_USETODAY='X')
AND (PRO6.AZULFIDINE_STATUSTODAY NOT IN ('03', '3')) 


---ORDER BY SITEID, SUBJECTID, VISITDATE
)

SELECT d.vID
     , d.[SITEID] AS [Site ID]
	 , d.[SUBJECTID] AS [Subject ID]
	 , d.[VISITTYPE] AS [Visit Type]
	 , d.[VISITDATE] AS [Visit Date]
	 , d.[PAGENAME] AS [Page Name]
	 , d.[PROVIDERID] AS [Provider ID]
	 , d.[DRUGNAME] AS [Drug Name]
	 , d.[SULF_STATUS] AS [Status]
	 , d.[FIRSTEVERUSE] AS [First Ever Use]
	 , CAST(d.[SULFDAY] AS nvarchar) + '-' + CAST(st.[MonthString] AS nvarchar) + '-' + CAST(d.[SULFYEAR] AS nvarchar) AS [Start or Modify Date]
	 , (ISNULL(d.[REASON1], '') + ISNULL(', ' + d.[REASON2], '') + ISNULL(', ' + d.[REASON3], '')) AS [Reason Code]
	 , d.[SULF_DOSE] AS [Prescribed Dose]
	 , d.[SULF_FREQ] AS [Prescribed Frequency]

FROM Sulf d 
left join months st on st.MonthCode = d.SULFMONTH


---ORDER BY SITEID, SUBJECTID, VISITDATE






GO
