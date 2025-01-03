USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_EnrollmentEligibility_V2]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [PSA400].[v_op_EnrollmentEligibility_V2] as

SELECT DISTINCT
	   EE.[vID]
      ,EE.[SiteID]
      ,EE.[SubjectID]
      ,EE.[ProviderID]
      ,EE.[EnrollmentDate]
      ,CASE
		WHEN EE.[Diagnosis] = 'PSA'
		THEN 'PSA'
		WHEN EE.[Diagnosis] = 'PSA, AS'
		THEN 'PSA, AS/r-AxSpA'
		WHEN (EE.[Diagnosis] = 'AS') OR (EE.[Diagnosis] = 'AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic')
		THEN 'AS/r-AxSpA'
		WHEN EE.[Diagnosis] = 'AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
		THEN 'nr-AxSpA'
		WHEN EE.[Diagnosis] = 'AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
		THEN 'AxSpA(Unspecified)'
		WHEN EE.[Diagnosis] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
		THEN 'PSA, AxSpA(Unspecified)'
		WHEN EE.[Diagnosis] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
		THEN 'PSA, AS, AxSpA(Unspecified)'
		WHEN EE.[Diagnosis] = 'AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] IS NULL
		THEN 'AS, AxSpA(Unspecified)'
		WHEN (EE.[Diagnosis] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic') OR (EE.[Diagnosis] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic')
		THEN 'PSA, AS/r-AxSpA'
		WHEN EE.[Diagnosis] = 'PSA, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
		THEN 'PSA, nr-AxSpA'
		WHEN EE.[Diagnosis] = 'PSA, AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
		THEN 'PSA, AS, nr-AxSpA'
		WHEN EE.[Diagnosis] = 'AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Radiographic'
		THEN 'AS/r-AxSpA'
		WHEN EE.[Diagnosis] = 'AS, AxSpA' AND P.[DX_AXIAL_TYPE_DEC] = 'Non-radiographic'
		THEN 'AS, nr-AxSpA'
	   ELSE EE.[Diagnosis]
	   END AS [Diagnosis]
      ,EE.[EligibilityVersion]
      ,EE.[EligibilityStatus]
	  ,DH.[DRUG_NO_PRIOR_USE] AS [NoPriorUse]
      ,EE.[EligibleDrug]
      ,CASE 
			WHEN EE.[EligibilityStatus] IN ('Eligible', 'Eligible-Status Update') THEN EE.[DrugOfInterest]
			ELSE ''
	   END AS [DrugOfInterest]
      ,CASE
			WHEN EE.[EligibleDrug] IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'apremilast (Otezla)', 'tofacitinib (Xeljanz XR)', 'tofacitinib (Xeljanz)' ) THEN 'IL-17, JAK, or PDE4 Inhibitors'
			WHEN EE.[EligibleDrug] IN ('methotrexate', 'sulfasalazine (Azulfidine)', 'leflunomide (Arava)') THEN 'csDMARDs'
			WHEN EE.[EligibleDrug] IN ('abatacept IV (Orencia)', 'abatacept SC (Orencia)', 'adalimumab (BIOSIMILAR)', 'adalimumab (Humira)', 
			'certolizumab pegol (Cimzia)', 'Erelzi (etanercept-szzs)', 'etanercept (BIOSIMILAR)', 'etanercept (Enbrel)', 'golimumab (Simponi Aria)', 'golimumab (Simponi)', 'Inflectra (infliximab-dyyb)', 
			'infliximab (BIOSIMILAR)', 'infliximab (Remicade)', 'ustekinumab (Stelara)') THEN 'Comparator Biologics'
			ELSE ''
	   END AS [Cohort]
      ,EE.[ReviewOutcome]
      ,DH.[Hierarchy_DATA]
  FROM [Reporting].[PSA400].[t_op_EnrollmentEligibility] EE
  LEFT JOIN  [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] DH ON DH.[SourceVisitID] = EE.[vID] AND DH.[DRUG_NAME_DEC] = EE.[EligibleDrug] AND DH.[Hierarchy_DATA] = EE.[Hierarchy_DATA]
  LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] P ON P.SUBNUM = EE.SubjectID AND P.SourceVisitID = EE.vID




GO
