USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_DuplicateDrugs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [PSA400].[v_op_DuplicateDrugs] AS

WITH DRUGS AS
(
SELECT DRUG.vID
      ,DRUG.SITENUM AS SiteID
      ,DRUG.SUBNUM AS SubjectID
	  ,DRUG.VISNAME AS VisitType
	  ,DRUG.VISITID
	  ,VIS.VISITDATE AS VisitDate
	  ,DRUG.PAGENAME AS PageName
	  ,DRUG.DRUG_NAME_DEC + ISNULL(', ' + DRUG.DRUG_NAME_OTHER, '') AS DrugName
	  ,CAST(DRUG.PAGELMDT AS date) AS PageLastModifiedDate
	  ,DRUG.PAGELMBY AS PageLastModifiedBy


FROM MERGE_SPA.STAGING.DRUG DRUG
LEFT JOIN MERGE_SPA.STAGING.VS_01 VIS ON VIS.VID=DRUG.VID
WHERE ISNULL(DRUG_NAME_DEC, '')<>''
AND (DRUG.VISITID IN (10, 11, 25, 26))

)

,CREATEDDATE AS
(
SELECT vID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID 
	  ,VISNAME AS VisitType
	  ,VISITID
	  ,PAGENAME AS PageName
	  ,MIN(CAST(PAGELMDT AS date)) AS PageCreatedDate
FROM MERGE_SPA.staging.DAT_PAGS
WHERE (VISITID IN (10, 11, 25, 26)
AND (PAGENAME LIKE '%Biologics%' OR PAGENAME LIKE '%DMARDS%'))
GROUP BY SITENUM, SUBNUM, vID, VISNAME, VISITID, PAGENAME
---ORDER BY sitenum, subnum, vID, visname, pagename
)

,DRUGGROUP AS
(
 SELECT D.vID
	   ,D.SiteID
	   ,D.SubjectID
	   ,D.VisitType
	   ,D.VisitDate
	   ,D.PageName
	   ,D.DrugName
	   ,CD.PageCreatedDate
	   ,D.PageLastModifiedDate
	   ,D.PageLastModifiedBy
	   ,(SELECT COUNT(*) FROM DRUGS D2 WHERE D2.vID=D.vID AND D2.SiteID=D.SiteID 
	     AND D2.SubjectID=D.SubjectID AND D2.DrugName=D.DrugName AND D2.PageName=D.PageName) AS NbrReported

FROM DRUGS D
LEFT JOIN CREATEDDATE CD ON CD.vID=D.vID and CD.PageName=D.PageName
)

SELECT CAST(vID as bigint) AS vID
      ,CAST(SiteID as int) AS SiteID
      ,SubjectID AS SubjectID
	  ,VisitType
	  ,CAST(VisitDate AS date) AS VisitDate
	  ,PageName
	  ,DrugName
	  ,PageCreatedDate
	  ,PageLastModifiedDate
	  ,PageLastModifiedBy
	  ,NbrReported
FROM DRUGGROUP D
WHERE NbrReported>1
AND SiteID NOT IN (99997, 99998, 99999)
---ORDER BY SiteID, SubjectID, DrugName, ROWNUM




GO
