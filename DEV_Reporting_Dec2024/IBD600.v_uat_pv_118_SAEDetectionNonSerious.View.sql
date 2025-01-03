USE [Reporting]
GO
/****** Object:  View [IBD600].[v_uat_pv_118_SAEDetectionNonSerious]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [IBD600].[v_uat_pv_118_SAEDetectionNonSerious] AS

WITH NONSERIOUS AS
(
SELECT DISTINCT
       COMOR.vID 
	  ,CAST(COMOR.SITENUM AS int) AS SiteID
	  ,CAST(COMOR.SUBNUM AS bigint) AS SubjectID
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
  	  ,COMOR.PAGESEQ AS PageSequence
	  ,COMOR.NOT_COMOR AS EventType
	  ,COALESCE(COMOR.[COMOR_G__CVD_P__FU___DEC]
	  ,COMOR.[COMOR_G__HEP_P__FU___DEC]
	  ,COMOR.[COMOR_G__NEU_P__FU___DEC]
	  ,COMOR.[COMOR_G__RESP_P___DEC]
	  ,COMOR.[COMOR_G__CAN_P__FU___DEC]
	  ,COMOR.[COMOR_G__AI_P__FU___DEC]
	  ,COMOR.[COMOR_G__GI_P__FU___DEC]
	  ,COMOR.[COMOR_G__DRGRXN_P__FU___DEC]
	  ,COMOR.[COMOR_G__OTHCOND_P___DEC]) AS EventTerm
	  ,COMOR.[COMOR_GX___C__OTH_C__PRE_TXT] AS SpecifiedOther
	  ,NULL AS PathogenCode
	  ,COMOR.COMOR_GX__DT AS OnsetDate
	  ,COMOR.PAGELMDT AS PageLastModificationDate
	  ,COMOR.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD_UAT.staging.MD_COMOR_AE COMOR
LEFT JOIN  MERGE_IBD_UAT.staging.VISIT VIS ON COMOR.vID=VIS.vID
WHERE ([COMOR_G__CVD_P__FU___DEC] IN ('Carotid artery disease', 'Coronary artery disease', 'Hyperlipidemia', 'Hypertension (HTN) (non-serious)', 'Peripheral artery disease')
OR [COMOR_G__HEP_P__FU___DEC] IN ('Cholelithiasis',  'Primary sclerosing cholangitis')
OR [COMOR_G__NEU_P__FU___DEC] in ('Fibromyalgia')
OR [COMOR_G__RESP_P___DEC] IN ('Asthma', 'Chronic obstructive pulmonary disease (COPD)', 'Interstitial lung disease/pulmonary fibrosis') 
OR [COMOR_G__CAN_P__FU___DEC] IN ('Pre-malignancy') 
OR [COMOR_G__AI_P__FU___DEC] IN ('Alopecia areata', 'Alopecia totalis') 
OR [COMOR_G__GI_P__FU___DEC] IN ('Peptic ulcer', 'Small bowel obstruction') 
OR [COMOR_G__DRGRXN_P__FU___DEC] IN ('Drug-induced hypersensitivity reaction (mild/moderare)', 'Drug-induced SLE') 
OR [COMOR_G__OTHCOND_P___DEC] IN ('Anxiety', 'Depression', 'Diabetes mellitus', 'Osteoporosis', 'Other non-serious medical condition'))

UNION

SELECT DISTINCT
       INF.vID
	  ,CAST(INF.SITENUM AS int) AS SiteID
	  ,CAST(INF.SUBNUM AS bigint) AS SubjectID
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
  	  ,INF.PAGESEQ AS PageSequence
	  ,CASE WHEN ISNULL(INF.[P__G__INF_CX__], '')<>'' THEN 'INF'
	   ELSE ''
	   END AS EventType
	  ,INF.[P__G__INF_CX___DEC] AS EventTerm
	  ,INF.G__INF_C__OTHER_SPECIFY AS SpecifiedOther
	  ,CASE WHEN INF.G__INF_CX__CODE='OM' THEN INF.G__INF_CX__CODE_DEC + ISNULL(' - ' + INF.G__INF_CX__OTH_MYCO, '')
	   WHEN INF.G__INF_CX__CODE='OP' THEN INF.G__INF_CX__CODE_DEC + ISNULL(' - ' + INF.G__INF_CX__OTH_OPP, '')
	   ELSE INF.G__INF_CX__CODE_DEC
	   END AS PathogenCode
	  ,INF.G__INF_CX__DT AS OnsetDate
	  ,INF.PAGELMDT AS PageLastModificationDate
	  ,INF.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD_UAT.staging.MD_INFECTION INF
LEFT JOIN MERGE_IBD_UAT.staging.VISIT VIS ON INF.vID=VIS.vID
WHERE INF.VID IN (SELECT INF2.VID FROM MERGE_IBD_UAT.staging.MD_INFECTION INF2 WHERE 
ISNULL(INF.[P__G__INF_CX___DEC], '')<>'' AND INF.[G__INF_SER_CX__]=0 AND INF.[G__INF_IV_CX__]=0)

)

SELECT SiteID
      ,SubjectID
	  ,VisitDate
	  ,PageSequence
	  ,EventType
	  ,EventTerm
	  ,SpecifiedOther
	  ,PathogenCode
	  ,OnsetDate
	  ,PageLastModificationDate
	  ,PageLastModifiedBy
FROM NONSERIOUS NS



GO
