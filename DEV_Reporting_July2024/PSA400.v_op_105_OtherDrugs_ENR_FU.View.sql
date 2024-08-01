USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_105_OtherDrugs_ENR_FU]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [PSA400].[v_op_105_OtherDrugs_ENR_FU] AS

SELECT d.vID
     , d.SITENUM AS SITEID
	 , d.SUBNUM AS SUBJECTID
	 , d.VISNAME AS VISITTYPE
	 , COALESCE(v.VISITDATE, (SELECT LM_AE_DT_EVENT FROM MERGE_SPA.STAGING.TAE_TOP TT where TT.vid=d.vid),(SELECT LM_AE_DT_EVENT FROM MERGE_SPA.STAGING.TAE_PAGE_1 TP1 where tp1.vid=d.vid)) AS VISITDT_ONSETDT
	 ---, v.VISITDATE AS VISITDATE
	 ---, (SELECT LM_AE_DT_EVENT FROM MERGE_SPA.STAGING.TAE_TOP TT where TT.vid=d.vid) AS ONSETDATE1
	 ---, (SELECT LM_AE_DT_EVENT FROM MERGE_SPA.STAGING.TAE_PAGE_1 TP1 where tp1.vid=d.vid) AS ONSETDATE2
	 , d.PAGENAME AS PAGENAME
	 , d.DRUG_NAME_DEC AS DRUGNAME
	 , d.DRUG_NAME_OTHER AS OTHERSPECIFY
FROM MERGE_SPA.staging.DRUG d
LEFT JOIN MERGE_SPA.staging.VS_01 v on v.vID=d.vID
WHERE D.DRUG_NAME_DEC = 'Other'
---ORDER BY D.SITENUM, D.SUBNUM, V.VISITDATE



GO
