USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortMonitoring_AS]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











		 --SELECT * FROM
CREATE view [PSA400].[v_op_CohortMonitoring_AS]  AS

WITH ENPROVID AS
(
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EP_01
union
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EPRO_01
)

SELECT DISTINCT
      CAST(R.SourceVisitID AS bigint) AS VisitId,
      CAST(V.SITENUM AS int) AS SiteID,
	  R.[SUBNUM] AS SubjectID,
	  CAST(R.[VisitDate] AS date) AS EnrollmentDate,
	  CASE
	  WHEN R.[Diagnosed_DATA] = 'PSA'
	  THEN 'PSA'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AS'
	  THEN 'PSA, AS/r-AxSpA'
	  WHEN (R.[Diagnosed_DATA] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic') 
	  OR (R.[Diagnosed_DATA] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic')
	  THEN 'PSA, AS/r-AxSpA'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
	  THEN 'PSA, nr-AxSpA'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
	  THEN 'PSA, AS/r-AxSpA, nr-AxSpA'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
	  THEN 'PSA, AxSpA(Unspecified)'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
	  THEN 'PSA, AS/r-AxSpA, AxSpA(Unspecified)'
	  WHEN (R.[Diagnosed_DATA] = 'AS') OR
	  (R.[Diagnosed_DATA] = 'AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic') 
	  OR (R.[Diagnosed_DATA] = 'AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic')
	  THEN 'AS/r-AxSpA'
	  WHEN R.[Diagnosed_DATA] = 'AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
	  THEN 'AS/r-AxSpA, nr-AxSpA'
	  WHEN R.[Diagnosed_DATA] = 'AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
	  THEN 'AS/r-AxSpA, AxSpA(Unspecified)'
	  WHEN R.[Diagnosed_DATA] = 'AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
	  THEN 'AxSpA(Unspecified)'
	  WHEN R.[Diagnosed_DATA] = 'AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
	  THEN 'nr-AxSpA'
	  ELSE R.[Diagnosed_DATA]
	  END AS Diagnosis,
	  --R.[Diagnosed_DATA] AS Diagnosis,
	  R.[DRUG_NAME_DEC] AS EligibleDrug,
	  CASE 
	  WHEN R.[Cohort_LOGIC] IN ('IL-17 or JAKi', 'Otezla') THEN 'IL-17, JAK, or PDE4 Inhibitors'
	  ELSE R.[Cohort_LOGIC]
	  END AS Cohort,
	  1 as NbrEnrolled,
	  ENPROVID.MD_COD AS ProviderID
FROM [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] P ON P.SUBNUM = R.SUBNUM AND P.SourceVisitID = R.SourceVisitID
LEFT JOIN ENPROVID ON ENPROVID.vID=R.SourceVisitID and ENPROVID.SUBNUM=R.SUBNUM
WHERE V.SITENUM NOT IN (99997, 99998, 99999)
--AND R.[Diagnosed_DATA] IN ('PSA', 'PSA, AS', 'PSA, AxSpA', 'PSA, AS, AxSpA')
AND ((R.[Diagnosed_DATA] IN ('AS', 'PSA, AS', 'AS, AxSpA', 'PSA, AS, AxSpa')) 
OR (R.[Diagnosed_DATA] IN ('AxSpA', 'PSA, AxSpA') AND [DX_AXIAL_TYPE_DEC] = 'Radiographic'))
AND R.[Hierarchy_DATA] = '1'
AND R.[Cohort_LOGIC] IN ('IL-17 or JAKi', 'Otezla', 'Comparator Biologics')
AND R.[VisitDate] >= '2018-10-01'
---ORDER BY SiteID










GO
