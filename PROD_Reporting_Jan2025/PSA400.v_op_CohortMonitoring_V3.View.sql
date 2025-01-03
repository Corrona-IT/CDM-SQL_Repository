USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortMonitoring_V3]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




















CREATE view [PSA400].[v_op_CohortMonitoring_V3]  AS


/***Get Subject, Enrollment, Eligible Drug and Cohort from CAT***/

WITH SubjectListing AS
(
SELECT SiteID,
       SiteStatus,
	   SubjectID,
	   VisitDate AS EnrollmentDate,
	   Diagnosis AS CATDiagnosis,
	   DrugOfInterest AS EligibleDrug,
	   Cohort,
	   1 AS NbrEnrolled,
	   ProviderID,
	   CASE WHEN Cohort IN ('IL-17, JAKi or PDE4 Inhibitor', 'IL-17, JAK or IL-23 Inhibitor') THEN 'Group 1'
	   WHEN Cohort='Comparator Biologic' THEN 'Group 2'
	   ELSE ''
	   END AS CohortGroup,
	   RegistryEnrollmentStatus
FROM [Reporting].[PSA400].[t_op_DOI_Enroll_FirstFU]
WHERE VisitDate  >= '2018-10-01'
)

/***Determine Diagnosis***/

,ReimbDiagnosis AS (

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
	  END AS Diagnosis
FROM [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] P ON P.SUBNUM = R.SUBNUM AND P.SourceVisitID = R.SourceVisitID
WHERE V.SITENUM NOT IN (99997, 99998, 99999) AND
R.[Diagnosed_DATA] IN ('PSA', 'PSA, AS', 'PSA, AxSpA', 'PSA, AS, AxSpA')
AND R.[Hierarchy_DATA] = '1'
AND R.[VisitDate] >= '2018-10-01'
)

SELECT SL.SiteID,
       SL.SiteStatus,
	   SL.SubjectID,
	   SL.EnrollmentDate,
	   SL.CATDiagnosis,
	   RD.Diagnosis,
	   SL.EligibleDrug,
	   SL.Cohort,
	   SL.NbrEnrolled,
	   SL.ProviderID,
	   SL.CohortGroup,
	   RegistryEnrollmentStatus
FROM SubjectListing SL
LEFT JOIN ReimbDiagnosis RD ON RD.SubjectID=SL.SubjectID AND RD.EnrollmentDate=SL.EnrollmentDate
WHERE RD.Diagnosis IN ('PSA', 'PSA, AS', 'PSA, AxSpA', 'PSA, AS, AxSpA')
AND (UPPER(RegistryEnrollmentStatus) LIKE 'ELIGIBLE%'
OR RegistryEnrollmentStatus='Not Eligible - Exception Granted')



--ORDER BY EnrollmentDate DESC
--SELECT DISTINCT RegistryEnrollmentStatus FROM PSA400.t_op_DOI_Enroll_FirstFU








GO
