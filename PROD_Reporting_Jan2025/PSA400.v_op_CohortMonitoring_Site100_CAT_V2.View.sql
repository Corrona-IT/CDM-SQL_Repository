USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortMonitoring_Site100_CAT_V2]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE view [PSA400].[v_op_CohortMonitoring_Site100_CAT_V2]  AS

SELECT DISTINCT
      CAST(R.SourceVisitID AS bigint) AS VisitId
      ,C.SiteID
	  ,C.SubjectID
	  ,c.[VisitDate] AS EnrollmentDate
	  ,CASE
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
		END AS Diagnosis
	  ,C.DrugOfInterest AS EligibleDrug
	  ,C.Cohort AS CohortOriginal
	  ,CASE 
		WHEN R.[DRUG_NAME_DEC] IN 
		('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)', 'guselkumab (Tremfya)')
		THEN 'Drug of Interest'
		ELSE 'Comparator'
		END AS Cohort,
	  1 as NbrEnrolled
	  ,C.ProviderID
	  ,C.RegistryEnrollmentStatus 
FROM [Reporting].[PSA400].[t_op_DOI_Enroll_FirstFU] C
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R ON R.SUBNUM = C.SubjectID
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] P ON P.SUBNUM = R.SUBNUM AND P.SourceVisitID = R.SourceVisitID


WHERE V.SITENUM NOT IN (99997, 99998, 99999)
AND (UPPER(RegistryEnrollmentStatus) LIKE 'ELIGIBLE%'
OR RegistryEnrollmentStatus='Not Eligible - Exception Granted')
AND (R.IncidentUse_DATA = '1' OR R.CurrentUse_DATA = '1')
AND R.[Hierarchy_DATA] = '1'















GO
