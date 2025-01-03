USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortMonitoring_V2]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [PSA400].[v_op_CohortMonitoring_V2]  AS

WITH ENPROVID AS
(
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EP_01
union
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EPRO_01
)

SELECT DISTINCT
      CAST(R.SourceVisitID AS bigint) AS VisitId,
      CAST(V.SITENUM AS int) AS SiteID,
	  CAST(R.[SUBNUM] AS bigint) AS SubjectID,
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
	  THEN 'PSA, AS, nr-AxSpA'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
	  THEN 'PSA, AxSpA(Unspecified)'
	  WHEN R.[Diagnosed_DATA] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
	  THEN 'PSA, AS, AxSpA(Unspecified)'
	  ELSE NULL
	  END AS Diagnosis,
	  --R.[Diagnosed_DATA] AS Diagnosis,
	  R.[DRUG_NAME_DEC] AS EligibleDrug,
	  CASE 
	  WHEN R.[Cohort_LOGIC] IN ('IL-17 or JAKi', 'Otezla') THEN 'IL-17, JAK, or PDE4 Inhibitors'
	  WHEN R.[DRUG_NAME_DEC]='guselkumab (Tremfya)' THEN 'IL-17, JAK, or PDE4 Inhibitors'
	  ELSE R.[Cohort_LOGIC]
	  END AS Cohort,
	  1 as NbrEnrolled,
	  ENPROVID.MD_COD AS ProviderID
FROM [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] P ON P.SUBNUM = R.SUBNUM AND P.SourceVisitID = R.SourceVisitID
LEFT JOIN ENPROVID ON ENPROVID.vID=R.SourceVisitID and ENPROVID.SUBNUM=R.SUBNUM
WHERE V.SITENUM NOT IN (99997, 99998, 99999) AND
R.[Diagnosed_DATA] IN ('PSA', 'PSA, AS', 'PSA, AxSpA', 'PSA, AS, AxSpA')
AND R.[Hierarchy_DATA] = '1'
AND R.[Cohort_LOGIC] IN ('IL-17 or JAKi', 'Otezla', 'Comparator Biologics') --OR R.DRUG_NAME_DEC='guselkumab (Tremfya)')
AND R.[VisitDate] >= '2018-10-01'
AND R.[DrugReqSatisfied]=1
--AND R.[VisitDate] < '2021-03-26'
---ORDER BY SiteID









GO
