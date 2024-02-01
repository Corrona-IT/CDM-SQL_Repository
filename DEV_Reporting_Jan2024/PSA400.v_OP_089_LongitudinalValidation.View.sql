USE [Reporting]
GO
/****** Object:  View [PSA400].[v_OP_089_LongitudinalValidation]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [PSA400].[v_OP_089_LongitudinalValidation]  AS


------------GET PHYSICIAN ID FROM ENROLLMENT AND FU TABLES

WITH PHYS_ID AS
(
---enr
SELECT EPRO.VID AS VID
     , EPRO.SITENUM AS SITENUM
	 , EPRO.SUBID AS SUBID
	 , EPRO.SUBNUM AS SUBNUM
	 , EPRO.MD_COD AS PHYSICIAN_ID
FROM MERGE_SPA.STAGING.EPRO_01 AS EPRO
WHERE PAGENAME LIKE '%V1.2%'

UNION

---fu
SELECT EPA.VID AS VID
      , EPA.SITENUM AS SITENUM
      , EPA.SUBID AS SUBID
      , EPA.SUBNUM AS SUBNUM
      , EPA.MD_COD AS PHYSICIAN_ID
FROM MERGE_SPA.STAGING.EP_01A AS EPA
WHERE PAGENAME LIKE '%V1.2%'

UNION

----FU
SELECT FPRO.VID AS VID
      , FPRO.SITENUM AS SITENUM
	  , FPRO.SUBID AS SUBID
	  , FPRO.SUBNUM AS SUBNUM
	  , FPRO.MD_COD AS PHYSICIAN_ID
FROM MERGE_SPA.STAGING.FPRO_01 AS FPRO
WHERE PAGENAME LIKE '%V1.2%'

UNION 

---ENR
SELECT EP.VID
     , EP.SITENUM
	 , EP.SUBID
	 , EP.SUBNUM
	 , EP.MD_COD AS PHYSICIAN_ID
FROM MERGE_SPA.STAGING.EP_01 AS EP
WHERE PAGENAME LIKE '%V1.2%'

)

,STUDY_SUBJ_BIRTHDATE AS
(
SELECT SITENUM
     , SUBNUM
	 , IDENT2 AS SUB_INFO_BIRTHDATE
	 , REVNUM 
FROM MERGE_SPA.DBO.DAT_SUB 
WHERE DELETED='f' 

)

,SUBJ_INFO AS
(
SELECT vID
       ,SITENUM
	   ,SUBID
	   ,SUBNUM
	   ,BIRTHDATE AS ENROLL_BIRTHDATE
	   ,WORK_STATUS_DEC
	   ,CASE
	   WHEN INSURANCE_PRIVATE='X' THEN 'Private Insurance' + ', ' + INSURANCE_PRIVATE_COM
	   ELSE NULL
	   END AS INSURANCE_PRIVATE
	   ,CASE
	   WHEN MEDICAID='X' THEN 'Medicaid'
	   ELSE NULL
	   END AS MEDICAID
	   ,CASE
	   WHEN MEDICARE='X' THEN 'Medicare' + ', ' + INSURANCE_MEDICARE2_DEC
	   ELSE NULL
	   END AS MEDICARE
	   ,CASE
	   WHEN INSURANCE_NONE='X' THEN 'None'
	   ELSE NULL
	   END AS INSURANCE_NONE
FROM MERGE_SPA.STAGING.ES_01
WHERE PAGENAME LIKE '%V1.2%' 

)

,PROVIDER_INFO AS
(
SELECT vID
      ,SITENUM
	  ,SUBID
	  ,SUBNUM
	  ,[WEIGHT]
FROM MERGE_SPA.STAGING.EPRO_01
WHERE PAGENAME LIKE '%V1.2%'

UNION

SELECT vID
      ,SITENUM
	  ,SUBID
	  ,SUBNUM
	  ,[WEIGHT]
FROM MERGE_SPA.STAGING.FPRO_01
WHERE PAGENAME LIKE '%V1.2%'

UNION

SELECT vID
      ,SITENUM
	  ,SUBID
	  ,SUBNUM
	  ,[WEIGHT]
FROM MERGE_SPA.STAGING.EP_09
WHERE PAGENAME LIKE '%V1.2%'

)

---JOIN VISITS FROM VISIT TABLE WITH PHYSICIAN ID AND EXIT VISITS
,VISITS_PID AS
(
SELECT VS.VID AS VID
      ,VS.SITENUM AS SITENUM
	  ,VS.SUBID AS SUBID
	  ,VS.SUBNUM AS SUBNUM
	  ,VS.VISITID AS VISITID
	  ,VS.VISITSEQ AS VISITSEQ
	  ,VS.VISNAME AS VISNAME
	  ,CAST(VS.VISITDATE AS DATE) AS VISITDATE
	  ,PHYS_ID.PHYSICIAN_ID
FROM MERGE_SPA.STAGING.VS_01 AS VS
LEFT OUTER JOIN PHYS_ID ON PHYS_ID.VID=VS.VID
WHERE VS.VID IN (
   SELECT VID FROM PHYS_ID
   UNION
   SELECT VID FROM SUBJ_INFO
   UNION
   SELECT VID FROM PROVIDER_INFO
                 )

UNION

SELECT EX1.VID
     , EX1.SITENUM
	 , EX1.SUBID
	 , EX1.SUBNUM
	 , EX1.VISITID
	 , EX1.VISITSEQ
	 , 'Exit Visit' AS VISNAME
	 , CAST (EX1.DISCONTINUE_DATE AS DATE) AS VISITDATE
	 , EX1.PHYSICIAN_COD AS PHYSICIAN_ID 
FROM MERGE_SPA.STAGING.EX_01 AS EX1 
WHERE EX1.STATUSID>0
AND PAGENAME LIKE '%V1.2%'
AND (EX1.DISCONTINUE_DATE <> '')

)


SELECT VPID.VID
      ,VPID.SITENUM AS [Site ID]
	  ,VPID.SUBID
	  ,VPID.SUBNUM AS [Subject ID]
	  ,VPID.VISITID
	  ,VPID.VISITSEQ
	  ,VPID.VISNAME AS [Visit Type]
	  ,CAST(VPID.VISITDATE AS DATE) AS [Visit Date]
	  ,VPID.PHYSICIAN_ID AS [Provider ID]
	  , SSBD.SUB_INFO_BIRTHDATE AS [Birth Year - Subject Information]
	   ,SUBINF.ENROLL_BIRTHDATE AS [Birth Year - Enrollment]
	   ,SUBINF.WORK_STATUS_DEC AS [Work Status]
	   ,ISNULL(SUBINF.INSURANCE_PRIVATE + '; ', '') + ISNULL(SUBINF.MEDICAID + '; ', '')  
	   + ISNULL(SUBINF.MEDICARE + '; ', '') + ISNULL(SUBINF.INSURANCE_NONE, '') AS [Insurance]
	   ,PINF.[WEIGHT] AS [Weight]
FROM VISITS_PID AS VPID
LEFT OUTER JOIN SUBJ_INFO AS SUBINF ON SUBINF.vID=VPID.VID
LEFT OUTER JOIN PROVIDER_INFO AS PINF ON PINF.VID=VPID.VID
LEFT OUTER JOIN STUDY_SUBJ_BIRTHDATE AS SSBD ON SSBD.SITENUM=VPID.SITENUM AND SSBD.SUBNUM=VPID.SUBNUM

---ORDER BY VPID.SITENUM, VPID.SUBNUM, VPID.VISITDATE


GO
