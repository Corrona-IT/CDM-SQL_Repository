USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_OtherDrugs_ENR]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [PSA400].[v_op_OtherDrugs_ENR]  AS

SELECT d.vID
     , d.SITENUM
	 , d.SUBNUM
	 , d.VISNAME
	 , d.VISITID
	 , v.VISITDATE
	 , d.PAGENAME
	 , d.DRUG_NAME_DEC
	 , d.DRUG_NAME_OTHER
FROM MERGE_SpA.staging.DRUG d
LEFT JOIN MERGE_SPA.staging.VS_01 v on v.vID=d.vID
WHERE D.VISITID IN (10, 11)
AND D.DRUG_NAME_DEC = 'Other'
---ORDER BY D.SITENUM, D.SUBNUM




GO
