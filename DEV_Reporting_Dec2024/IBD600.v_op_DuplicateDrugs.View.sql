USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_DuplicateDrugs]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [IBD600].[v_op_DuplicateDrugs] AS

WITH DRUGS AS
(

SELECT DRUG.vID
      ,CAST(DRUG.SITENUM AS int) AS SiteID
	  ,DRUG.SUBNUM AS SubjectID
	  ,DRUG.VISNAME AS VisitType
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,DRUG.PAGENAME AS PageName
	  ,DRUG.NOT_DRUG_CLASS123_DEC AS DrugClass
	  ,COALESCE(DRUG.P__G__10_USE_DEC, DRUG.P__G__20_USE_DEC, DRUG.P__G__30_USE_DEC) + ISNULL(', ' + DRUG.GX___C__OTH_NAME_TXT, '') AS DrugName
	  ,CAST(DRUG.PAGELMDT AS date) AS PageLastModifiedDate
	  ,DRUG.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD.staging.DRUG
LEFT JOIN MERGE_IBD.staging.VISIT ON VISIT.vID=DRUG.vID
WHERE (DRUG.P__G__10_USE_DEC IS NOT NULL
OR DRUG.P__G__20_USE_DEC IS NOT NULL
OR DRUG.P__G__30_USE_DEC IS NOT NULL)

UNION

SELECT DRUG.vID
      ,CAST(DRUG.SITENUM AS int) AS SiteID
	  ,DRUG.SUBNUM AS SubjectID
	  ,DRUG.VISNAME AS VisitType
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,DRUG.PAGENAME AS PageName
	  ,DRUG.NOT_DRUG_CLASS123_DEC AS DrugClass
	  ,COALESCE(DRUG.G___30_C__MESAL_PO_TYPE_DEC, DRUG.G___30_C__BALSALAZID_TYPE_DEC) + ISNULL(', ' + DRUG.GX___C__OTH_NAME_TXT, '') AS DrugName
	  ,CAST(DRUG.PAGELMDT AS date) AS PageLastModifiedDate
	  ,DRUG.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD.staging.DRUG
LEFT JOIN MERGE_IBD.staging.VISIT ON VISIT.vID=DRUG.vID
WHERE (DRUG.G___30_C__MESAL_PO_TYPE_DEC IS NOT NULL
OR DRUG.G___30_C__BALSALAZID_TYPE_DEC IS NOT NULL)

UNION

SELECT DRUG.vID
	  ,CAST(DRUG.SITENUM AS int) AS SiteID
	  ,DRUG.SUBNUM AS SubjectID
	  ,DRUG.VISNAME AS VisitType
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,DRUG.PAGENAME AS PageName
	  ,DRUG.NOT_DRUG_CLASS45_DEC AS DrugClass
	  ,COALESCE(DRUG.P__G__40_USE_DEC, DRUG.P__G__50_USE_DEC) + ISNULL(', ' + DRUG.GX__OTH_NAME_TXT, '') AS DrugName
	  ,CAST(DRUG.PAGELMDT AS date) AS PageLastModifiedDate
	  ,DRUG.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD.staging.DRUG_ABX_STEROIDS DRUG
LEFT JOIN MERGE_IBD.staging.VISIT ON VISIT.vID=DRUG.vID
WHERE (DRUG.P__G__40_USE_DEC IS NOT NULL
OR DRUG.P__G__50_USE_DEC IS NOT NULL)

UNION

SELECT DRUG.vID
      ,CAST(DRUG.SITENUM AS int) AS SiteID
	  ,DRUG.SUBNUM AS SubjectID
	  ,DRUG.VISNAME AS VisitType
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,DRUG.PAGENAME AS PageName
	  ,DRUG.NOT_DRUG_CLASS45_DEC AS DrugClass
	  ,DRUG.G___50_C__TAPER_6MO_TYPE_DEC + ISNULL(', ' + DRUG.GX__OTH_NAME_TXT, '') AS DrugName
	  ,CAST(DRUG.PAGELMDT AS date) AS PageLastModifiedDate
	  ,DRUG.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD.staging.DRUG_ABX_STEROIDS DRUG
LEFT JOIN MERGE_IBD.staging.VISIT ON VISIT.vID=DRUG.vID
WHERE (DRUG.G___50_C__TAPER_6MO_TYPE_DEC IS NOT NULL)

)


,CREATEDDATE AS
(
SELECT vID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID 
	  ,VISNAME AS VisitType
	  ,PAGENAME AS PageName
	  ,MIN(CAST(PAGELMDT AS date)) AS PageCreatedDate
FROM MERGE_IBD.staging.DAT_PAGS
WHERE VISNAME IN ('Enrollment', 'Follow-Up')
AND PAGENAME LIKE '%Provider-IBD Meds%'
GROUP BY SITENUM, SUBNUM, vID, VISNAME, PAGENAME

)

,DRUGGROUP AS
(
SELECT D.vID
      ,D.SiteID
	  ,D.SubjectID
	  ,D.VisitType
	  ,D.VisitDate
	  ,D.PageName
	  ,D.DrugClass
	  ,D.DrugName
	  ,CD.PageCreatedDate
	  ,D.PageLastModifiedDate
	  ,D.PageLastModifiedBy
      ,(SELECT COUNT(*) FROM DRUGS D2 WHERE D2.vID=D.vID AND D2.SiteID=D.SiteID 
	     AND D2.SubjectID=D.SubjectID AND D2.DrugName=D.DrugName AND D2.PageName=D.PageName) AS NbrReported

FROM DRUGS D
LEFT JOIN CREATEDDATE CD ON CD.SiteID=D.SiteID AND CD.SubjectID=D.SubjectID
          AND CD.vID=D.vID AND CD.PageName=D.PageName
)

SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,PageName
	  ,DrugClass
	  ,DrugName
	  ,PageCreatedDate
	  ,PageLastModifiedDate
	  ,PageLastModifiedBy
	  ,NbrReported 
FROM DRUGGROUP
WHERE NbrReported>1
GO
