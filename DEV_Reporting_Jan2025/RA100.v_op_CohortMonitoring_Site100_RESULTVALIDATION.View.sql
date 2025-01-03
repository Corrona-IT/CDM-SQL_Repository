USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_CohortMonitoring_Site100_RESULTVALIDATION]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [RA100].[v_op_CohortMonitoring_Site100_RESULTVALIDATION]  AS

SELECT 
       C.[SiteID]
      ,C.[SubjectID]
      ,C.[ProviderID]
      ,C.[VisitType]
      ,C.[VisitDate] AS [EnrollmentDate]
      ,C.[OnsetYear]
	  ,DATEPART(YEAR, C.[VisitDate]) - OnsetYear AS YrsSinceOnset
	  ,CASE WHEN (DATEPART(YY, C.[VisitDate])-C.[OnsetYear])<2 THEN 'None - Disease Activity'
	   ELSE NULL
	   END AS DiseaseActivity

 --Updated March 2021 that anytime RA onset is within the past year ((visityear-onsetyear) < 2) Cohort is None-Recent RA diagnosis but show the eligible drug if on one. Not counted in cohort.
	  ,CASE 
			WHEN C.[DrugOfInterest] 
			IN ('upadacitinib (Rinvoq)', 'baricitinib (Olumiant)')
			OR C.[DrugOfInterest] LIKE '%upadacitinib%'
			OR C.[DrugOfInterest] LIKE '%Rinvoq%'
			OR C.[DrugOfInterest] LIKE '%baricitinib%'
			OR C.[DrugOfInterest] LIKE '%Olumiant%'
			THEN 'Drug of Interest'
			WHEN C.[DrugOfInterest] 
			IN ('abatacept (Orencia)', 'adalimumab (Humira)', 'Amjevita (adalimumab-atto)',
			'anakinra (Kineret)', 'certolizumab (Cimzia)', 'Erelzi (etanercept-szzs)',
			'etanercept (Enbrel)', 'golimumab (Simponi Aria)', 'golimumab (Simponi)',
			'Inflectra (infliximab-dyyb)', 'infliximab (Remicade)', 'Renflexis (infliximab-abda)',
			'rituximab (Rituxan)', 'sarilumab (Kevzara)', 'tocilizumab (Actemra)',
			'tofacitinib (Xeljanz XR)', 'tofacitinib (Xeljanz)') 
			OR C.[DrugOfInterest] LIKE '%biosimilar (other)%'
			OR C.[DrugOfInterest] LIKE '%Orencia%'
			OR C.[DrugOfInterest] LIKE '%abatacept%'
			OR C.[DrugOfInterest] LIKE '%adalimumab%'
			OR C.[DrugOfInterest] LIKE '%Humira%'
			OR C.[DrugOfInterest] LIKE '%Amjevita%'
			OR C.[DrugOfInterest] LIKE '%anakinra%'
			OR C.[DrugOfInterest] LIKE '%Kineret%'
			OR C.[DrugOfInterest] LIKE '%certolizumab%'
			OR C.[DrugOfInterest] LIKE '%Cimzia%'
			OR C.[DrugOfInterest] LIKE '%etanercept%'
			OR C.[DrugOfInterest] LIKE '%Enbrel%'
			OR C.[DrugOfInterest] LIKE '%Erelzi%'
			OR C.[DrugOfInterest] LIKE '%golimumab%'
			OR C.[DrugOfInterest] LIKE '%Simponi%'
			OR C.[DrugOfInterest] LIKE '%Aria%'
			OR C.[DrugOfInterest] LIKE '%infliximab%'
			OR C.[DrugOfInterest] LIKE '%Remicade%'
			OR C.[DrugOfInterest] LIKE '%Inflectra%'
			OR C.[DrugOfInterest] LIKE '%Reflenxis%'
			OR C.[DrugOfInterest] LIKE '%rituximab%'
			OR C.[DrugOfInterest] LIKE '%Rituxan%'
			OR C.[DrugOfInterest] LIKE '%sarilumab%'
			OR C.[DrugOfInterest] LIKE '%Kevzara%'
			OR C.[DrugOfInterest] LIKE '%tocilizumab%'
			OR C.[DrugOfInterest] LIKE '%Actemra%'
			OR C.[DrugOfInterest] LIKE '%tofacitinib%'
			OR C.[DrugOfInterest] LIKE '%Xeljanz%'
			THEN 'Comparator'
			WHEN C.[RegistryEnrollmentStatus] LIKE '%Eligible - Disease Activity%'
			THEN 'None - Recent RA diagnosis'
			ELSE NULL
		    END AS [OriginalCohort]
	  ,CASE 
			WHEN (DATEPART(YY, C.[VisitDate])-C.[OnsetYear])<2
			THEN 'None - Disease Activity'
			WHEN C.[DrugOfInterest] 
			IN ('upadacitinib (Rinvoq)', 'baricitinib (Olumiant)')
			OR C.[DrugOfInterest] LIKE '%upadacitinib%'
			OR C.[DrugOfInterest] LIKE '%Rinvoq%'
			OR C.[DrugOfInterest] LIKE '%baricitinib%'
			OR C.[DrugOfInterest] LIKE '%Olumiant%'
			THEN 'Drug of Interest'
			WHEN C.[DrugOfInterest] 
			IN ('abatacept (Orencia)', 'adalimumab (Humira)', 'Amjevita (adalimumab-atto)',
			'anakinra (Kineret)', 'certolizumab (Cimzia)', 'Erelzi (etanercept-szzs)',
			'etanercept (Enbrel)', 'golimumab (Simponi Aria)', 'golimumab (Simponi)',
			'Inflectra (infliximab-dyyb)', 'infliximab (Remicade)', 'Renflexis (infliximab-abda)',
			'rituximab (Rituxan)', 'sarilumab (Kevzara)', 'tocilizumab (Actemra)',
			'tofacitinib (Xeljanz XR)', 'tofacitinib (Xeljanz)') 
			OR C.[DrugOfInterest] LIKE '%biosimilar (other)%'
			OR C.[DrugOfInterest] LIKE '%Orencia%'
			OR C.[DrugOfInterest] LIKE '%abatacept%'
			OR C.[DrugOfInterest] LIKE '%adalimumab%'
			OR C.[DrugOfInterest] LIKE '%Humira%'
			OR C.[DrugOfInterest] LIKE '%Amjevita%'
			OR C.[DrugOfInterest] LIKE '%anakinra%'
			OR C.[DrugOfInterest] LIKE '%Kineret%'
			OR C.[DrugOfInterest] LIKE '%certolizumab%'
			OR C.[DrugOfInterest] LIKE '%Cimzia%'
			OR C.[DrugOfInterest] LIKE '%etanercept%'
			OR C.[DrugOfInterest] LIKE '%Enbrel%'
			OR C.[DrugOfInterest] LIKE '%Erelzi%'
			OR C.[DrugOfInterest] LIKE '%golimumab%'
			OR C.[DrugOfInterest] LIKE '%Simponi%'
			OR C.[DrugOfInterest] LIKE '%Aria%'
			OR C.[DrugOfInterest] LIKE '%infliximab%'
			OR C.[DrugOfInterest] LIKE '%Remicade%'
			OR C.[DrugOfInterest] LIKE '%Inflectra%'
			OR C.[DrugOfInterest] LIKE '%Reflenxis%'
			OR C.[DrugOfInterest] LIKE '%rituximab%'
			OR C.[DrugOfInterest] LIKE '%Rituxan%'
			OR C.[DrugOfInterest] LIKE '%sarilumab%'
			OR C.[DrugOfInterest] LIKE '%Kevzara%'
			OR C.[DrugOfInterest] LIKE '%tocilizumab%'
			OR C.[DrugOfInterest] LIKE '%Actemra%'
			OR C.[DrugOfInterest] LIKE '%tofacitinib%'
			OR C.[DrugOfInterest] LIKE '%Xeljanz%'
			THEN 'Comparator'
			ELSE NULL
		    END AS [Cohort]
	  ,1 AS [NbrEnrolled]
 --Only NULL when subject is eligible by RA diagnosis otherwise display DOI
 --Updated March 2021 that anytime RA onset is within the past year ((visityear-onsetyear) < 2) Cohort is None-Recent RA diagnosis but show the eligible drug if on one. Not counted in cohort.
      ,C.[DrugOfInterest]
	  ,C.[RegistryEnrollmentStatus]
	  ,EL.[ExceptionGranted] --SELECT * 
FROM [RA100].[v_op_CAT] C
LEFT JOIN [Reporting].[RA100].[t_op_RAExceptionsList] EL ON C.SubjectID = EL.SubjectID
WHERE UPPER(RegistryEnrollmentStatus) LIKE 'ELIGIBLE%'
AND C.SiteID=100
AND C.VisitDate >= '2020-07-01'






GO
