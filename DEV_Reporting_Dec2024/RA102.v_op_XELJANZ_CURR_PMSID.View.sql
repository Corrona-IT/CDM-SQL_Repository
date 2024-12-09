USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_XELJANZ_CURR_PMSID]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [RA102].[v_op_XELJANZ_CURR_PMSID] as
WITH XELJANZUSE AS
(
SELECT
	 PE4.vID
	,PE4.SITENUM AS SITEID
	,PE4.SUBNUM AS SUBJECTID
	,(SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.staging.PRO_01 A WHERE A.VID=PE4.VID AND A.SUBNUM=PE4.SUBNUM AND A.VISITID=PE4.VISITID) AS PROVIDERID
	,(SELECT VISITDATE FROM MERGE_RA_JAPAN.staging.VIS_DATE B WHERE B.VID=PE4.VID AND B.SUBNUM=PE4.SUBNUM AND B.VISITID=PE4.VISITID) AS VISITDATE
	,(SELECT VISNAME FROM MERGE_RA_JAPAN.staging.VIS_DATE B WHERE B.VID=PE4.VID AND B.SUBNUM=PE4.SUBNUM AND B.VISITID=PE4.VISITID) AS VISITTYPE
	,CASE
	     WHEN PE4.XELJANZ_USE='X' THEN 'tofacitnib (Xeljanz)'
	     ELSE ''
	  END 
	AS DRUGNAME

	,CASE 
	WHEN PE4.XELJANZ_STATUS=1 THEN 'Current'
	WHEN PE4.XELJANZ_STATUS=2 THEN 'Past'
	WHEN PE4.XELJANZ_STATUSFU_NOCHG='X' THEN 'Current - No Change'
	WHEN PE4.XELJANZ_STATUSFU_ST='X' THEN 'Start'
	ELSE ''
	END AS XELJANZSTATUS
	

FROM MERGE_RA_Japan.staging.PE_04 PE4
WHERE (PE4.XELJANZ_STATUS=1 OR PE4.XELJANZ_STATUSFU_NOCHG='X' OR PE4.XELJANZ_STATUSFU_ST='X')

AND PE4.SITENUM NOT IN ('9997','9999')

UNION

SELECT
	 PRO6.vID
	,PRO6.SITENUM AS SITEID
	,PRO6.SUBNUM AS SUBJECTID
	,(SELECT PHYSICIAN_ID FROM MERGE_RA_JAPAN.staging.PRO_01 A WHERE A.VID=PRO6.VID AND A.SUBNUM=PRO6.SUBNUM AND A.VISITID=PRO6.VISITID) AS PROVIDERID
	,(SELECT VISITDATE FROM MERGE_RA_JAPAN.staging.VIS_DATE B WHERE B.VID=PRO6.VID AND B.SUBNUM=PRO6.SUBNUM AND B.VISITID=PRO6.VISITID) AS VISITDATE
	,(SELECT VISNAME FROM MERGE_RA_JAPAN.staging.VIS_DATE B WHERE B.VID=PRO6.VID AND B.SUBNUM=PRO6.SUBNUM AND B.VISITID=PRO6.VISITID) AS VISITTYPE
	,CASE
	     WHEN PRO6.XELJANZ_USETODAY='X' THEN 'tofacitnib (Xeljanz)'
	     ELSE ''
	  END 
	AS DRUGNAME

	,CASE 
	WHEN PRO6.XELJANZ_STATUSTODAY in ('1', '01') THEN 'Prescribed Today'
	WHEN PRO6.XELJANZ_STATUSTODAY IN ('2', '02') THEN 'Modified Today'

	ELSE ''
	END AS XELJANZSTATUS
	

FROM MERGE_RA_Japan.staging.PRO_06 PRO6
WHERE (PRO6.XELJANZ_USETODAY='X')
AND (PRO6.XELJANZ_STATUSTODAY IN ('1', '2', '01', '02'))

AND PRO6.SITENUM NOT IN ('9997','9999')

---ORDER BY SITENUM, SUBNUM, VISITDATE
)

,XELJANZ_PMS_ID AS
(
SELECT PRO1.vID
      ,PRO1.SITENUM
	  ,PRO1.SUBNUM
	  ,PRO1.VISNAME
	  ,VIS.VISITDATE
	  ,PRO1.VISITSEQ
	  ,PRO1.PHYSICIAN_ID

	  ,CASE
	  WHEN PRO1.PMS_TSDMARD IN ('01', '1') THEN 'Yes'
	  WHEN PRO1.PMS_TSDMARD IN ('2', '3') THEN 'No'
	  ELSE ''
	  END AS XELJANZ_PMS_STUDY

	  ,PRO1.PMS_ID_XELJANZ

FROM [MERGE_RA_Japan].[STAGING].[PRO_01] PRO1
LEFT JOIN [MERGE_RA_Japan].[STAGING].VIS_DATE VIS ON VIS.VID=PRO1.VID AND VIS.VISITSEQ=PRO1.VISITSEQ

WHERE ((PRO1.VISNAME='Enrollment' AND PRO1.PMS_TSDMARD IN ('01', '1'))

OR (PRO1.VISNAME='Followup' AND PRO1.PMS_TSDMARD IN ('01', '1'))

OR (PRO1.VISNAME='Enrollment' AND PRO1.PMS_TSDMARD NOT IN ('01', '1') AND EXISTS(SELECT vID
FROM [MERGE_RA_Japan].[STAGING].[PRO_01] A
WHERE A.SITENUM=PRO1.SITENUM AND A.SUBNUM=PRO1.SUBNUM AND A.VISNAME='Followup' AND A.PMS_TSDMARD IN ('01', '1')))

OR (PRO1.VISNAME='Followup' AND PRO1.PMS_TSDMARD NOT IN ('01', '1') AND EXISTS(SELECT vID
FROM [MERGE_RA_Japan].[STAGING].[PRO_01] A
WHERE A.SITENUM=PRO1.SITENUM AND A.SUBNUM=PRO1.SUBNUM AND A.VISNAME='Enrollment' AND A.PMS_TSDMARD IN ('01', '1')))

OR (PRO1.VISNAME='Followup' AND PRO1.PMS_TSDMARD NOT IN ('01', '1') AND EXISTS(SELECT vID
FROM [MERGE_RA_Japan].[STAGING].[PRO_01] A
WHERE A.VID<>PRO1.VID AND A.SITENUM=PRO1.SITENUM AND A.SUBNUM=PRO1.SUBNUM AND A.VISNAME='Followup' AND A.PMS_TSDMARD IN ('01', '1')))
)

AND PRO1.SITENUM NOT IN ('9997', '9999')


---ORDER BY [PRO1].SITENUM, [PRO1].SUBNUM, [VIS].VISITDATE
)

SELECT XU.VID
      ,XU.SITEID AS [Site ID]
	  ,XU.SUBJECTID AS [Subject ID]
	  ,XU.PROVIDERID AS [Provider ID]
	  ,XU.VISITDATE AS [Visit Date]
	  ,XU.VISITTYPE AS [Visit Type]
	  ,XU.DRUGNAME AS [Drug Name]
	  ,XU.XELJANZSTATUS AS [Reported Status]
	  ,XPI.XELJANZ_PMS_STUDY AS [Xeljanz PMS Study]
	  ,XPI.PMS_ID_XELJANZ AS [PMS ID]
FROM XELJANZUSE XU
INNER JOIN XELJANZ_PMS_ID XPI ON XU.VID=XPI.VID

---ORDER BY XU.SITEID, XU.SUBJECTID, XU.VISITDATE




GO
