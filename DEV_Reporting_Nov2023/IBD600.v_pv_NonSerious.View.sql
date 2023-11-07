USE [Reporting]
GO
/****** Object:  View [IBD600].[v_pv_NonSerious]    Script Date: 11/7/2023 12:08:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [IBD600].[v_pv_NonSerious] AS

WITH NONSERIOUS AS
(
SELECT DISTINCT
       COMOR.vID 
	  ,CAST(COMOR.SITENUM AS int) AS SiteID
	  ,COMOR.SUBNUM AS SubjectID
	  ,VIS.VISNAME AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
  	  ,COMOR.PAGESEQ AS PageSequence
	  ,COMOR.NOT_COMOR AS EventType
	  ,COALESCE(COMOR.[COMOR_G__CVD_P__FU___DEC], COMOR.[COMOR_G__HEP_P__FU___DEC], COMOR.[COMOR_G__NEU_P__FU___DEC], COMOR.[COMOR_G__RESP_P___DEC], COMOR.[COMOR_G__CAN_P__FU___DEC], COMOR.[COMOR_G__AI_P__FU___DEC], COMOR.[COMOR_G__GI_P__FU___DEC], COMOR.[COMOR_G__DRGRXN_P__FU___DEC], COMOR.[COMOR_G__OTHCOND_P___DEC]) AS EventTerm
	  ,COMOR.[COMOR_GX___C__OTH_C__PRE_TXT] AS SpecifiedOther
	  ,NULL AS PathogenCode
	  ,COMOR.COMOR_GX__DT AS OnsetDate
	  ,COMOR.PAGELMDT AS PageLastModificationDate
	  ,COMOR.PAGELMBY AS PageLastModifiedBy

FROM MERGE_IBD.staging.MD_COMOR_AE COMOR
LEFT JOIN  MERGE_IBD.staging.VISIT VIS ON COMOR.vID=VIS.vID
WHERE ([COMOR_G__CVD_P__FU___DEC] IN ('Carotid artery disease', 'Coronary artery disease', 'Hyperlipidemia', 'Hypertension (HTN) (non-serious)', 'Peripheral artery disease')
OR [COMOR_G__HEP_P__FU___DEC] IN ('Cholelithiasis',  'Primary sclerosing cholangitis')
OR [COMOR_G__NEU_P__FU___DEC] in ('Fibromyalgia')
OR [COMOR_G__RESP_P___DEC] IN ('Asthma', 'Chronic obstructive pulmonary disease (COPD)', 'Interstitial lung disease/pulmonary fibrosis') 
OR [COMOR_G__CAN_P__FU___DEC] IN ('Pre-malignancy') 
OR [COMOR_G__AI_P__FU___DEC] IN ('Alopecia areata', 'Alopecia totalis', 'Ankylosing spondylitis', 'Psoriatic arthritis', 'Reactive arthritis', 'Reactive arthritis', 'Rheumatoid arthritis') 
OR [COMOR_G__GI_P__FU___DEC] IN ('Peptic ulcer', 'Small bowel obstruction') 
OR [COMOR_G__DRGRXN_P__FU___DEC] IN ('Drug-induced hypersensitivity reaction (mild/moderare)', 'Drug-induced SLE') 
OR [COMOR_G__OTHCOND_P___DEC] IN ('Anxiety', 'Depression', 'Diabetes mellitus', 'Osteoporosis', 'Other non-serious medical condition')
OR [COMOR_G__FRA_P__FU___DEC] IN ('Fracture - non-serious (specify)'))
AND (CAST(COMOR.PAGELMDT AS date) NOT IN ('2023-07-13', '2023-07-14') AND COMOR.PAGELMBY<>'Rowe, Andrea')



UNION

SELECT DISTINCT
       INF.vID
	  ,CAST(INF.SITENUM AS int) AS SiteID
	  ,INF.SUBNUM AS SubjectID
	  ,VIS.VISNAME AS VisitType
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

FROM MERGE_IBD.staging.MD_INFECTION INF
LEFT JOIN MERGE_IBD.staging.VISIT VIS ON INF.vID=VIS.vID
WHERE INF.VID IN (SELECT INF2.VID FROM MERGE_IBD.staging.MD_INFECTION INF2 WHERE 
ISNULL(INF.[P__G__INF_CX___DEC], '')<>'' AND INF.[G__INF_SER_CX__]=0 AND INF.[G__INF_IV_CX__]=0)
AND (CAST(INF.PAGELMDT AS date) NOT IN ('2023-07-13', '2023-07-14') AND INF.PAGELMBY<>'Rowe, Andrea')
)

SELECT SiteID
      ,SubjectID
	  ,VisitType
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
