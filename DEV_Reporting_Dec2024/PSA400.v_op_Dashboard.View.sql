USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_Dashboard]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSA400].[v_op_Dashboard] as


SELECT [vID]
      ,[SiteID]
      ,[SubjectID]
      ,[ProviderID]
      ,[EnrollmentDate]
      ,[Diagnosis]
	  ,CASE
		WHEN [Diagnosis] LIKE '%PSA%' THEN 'X'
		ELSE NULL
		END AS [PSADiagnosis]
	  ,CASE
		WHEN [Diagnosis] LIKE '%AS%' THEN 'X'
		ELSE NULL
		END AS [ASDiagnosis]
      ,[EligibilityVersion]
      ,[EligibilityStatus]
      ,CASE
		WHEN [EligibleDrug] LIKE 'tofacitinib%' THEN 'tofacitinib (Xeljanz/Xeljanz XR)'
		ELSE [EligibleDrug]
		END AS [EligibleDrug]
      ,[DrugOfInterest]
      ,[Cohort]
	  ,CASE
		WHEN [Cohort] LIKE 'IL-17%' AND [EligibleDrug] LIKE 'tofacitinib%'  THEN 'tofacitinib (Xeljanz/Xeljanz XR)'
		WHEN [Cohort] LIKE 'IL-17%' AND [EligibleDrug] NOT LIKE 'tofacitinib%' THEN [EligibleDrug]
		WHEN [Cohort] LIKE '%Otezla%' THEN [EligibleDrug]
		ELSE [Cohort]
		END AS [PieCohort]
	  ,CASE
		WHEN [Cohort] IN ('IL-17 or JAKi','Otezla') THEN 'IL-17/JAK/PDE inhibitors'
		ELSE [Cohort]
		END AS [TableCohort]
	  ,CASE 
	    WHEN [DRUG_NO_PRIOR_USE] = 'X' THEN 'No Prior Use'
	    ELSE NULL 
		END AS [NoPriorUse]
	  ,CASE 
		WHEN REIMB.[IncidentUse_DATA] IS NOT NULL THEN 'Incident'
		WHEN REIMB.[CurrentUse_DATA] IS NOT NULL THEN 'Prevalent'
		WHEN REIMB.[IncidentUse_DATA] IS NOT NULL AND REIMB.[CurrentUse_DATA] IS NOT NULL THEN NULL
		ELSE NULL 
		END AS [UseStatus]
      ,[ReviewOutcome]
      ,EE.[Hierarchy_DATA]
FROM [PSA400].[t_op_EnrollmentEligibility] EE
  LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] REIMB ON REIMB.[SourceVisitId] = EE.[vID] AND REIMB.[DRUG_NAME_DEC] = EE.[EligibleDrug] AND REIMB.[Hierarchy_DATA] = EE.[Hierarchy_DATA]
  WHERE
  ([EligibilityStatus] = 'Eligible' OR [ReviewOutcome] = 'Confirmed Eligible')
  AND [EligibleDrug] <> ''
  AND [Cohort] <> ''
  AND [Diagnosis] <> ''



GO
