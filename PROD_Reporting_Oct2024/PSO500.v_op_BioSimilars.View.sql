USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_BioSimilars]    Script Date: 11/13/2024 1:41:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [PSO500].[v_op_BioSimilars] AS

SELECT
       'PSO-500' AS [Registry]
      ,C.[SiteID]
      ,C.[SiteStatus]
      ,C.[SubjectID]
      ,C.[ProviderID]
      ,C.[BirthYear]
      ,C.[EnrollDate]
	  ,CAST(DEL.[CompletionDate] AS DATE) AS [EnteredDate]
	  ,YEAR(C.[EnrollDate]) AS [EnrollYear]
	  ,CASE 
		WHEN YEAR(C.[EnrollDate])/2 <> 0 THEN CONCAT(YEAR([EnrollDate]),'-',(YEAR([EnrollDate])+1))
		WHEN YEAR(C.[EnrollDate])/2 = 0 THEN CONCAT(YEAR([EnrollDate])-1,'-', YEAR([EnrollDate]))
		ELSE NULL
		END AS [YearGroup]

      ,[TreatmentName]
	  ,ROW_NUMBER() OVER(Partition BY [TreatmentName], YEAR(C.[EnrollDate]) ORDER BY C.[EnrollDate], DEL.[CompletionDate]) AS [DOINum]
	  ,ROW_NUMBER() OVER(Partition BY C.[DrugCohort] ORDER BY C.[EnrollDate]) AS [TTypeNum]
      ,C.[DrugCohort]
      ,CASE 
       WHEN C.[RegistryEnrollmentStatus] = 'Eligible-not started' 
       THEN 'Eligible'
       WHEN C.[RegistryEnrollmentStatus] = 'Eligible - Review decision' 
       THEN 'Eligible'
       WHEN C.[RegistryEnrollmentStatus] = 'Not eligible' AND [EligibilityReview] = 'Eligible' 
       THEN 'Eligible'
       WHEN C.[RegistryEnrollmentStatus] = 'Not eligible' AND [EligibilityReview] = 'Not eligible - Exception granted' 
       THEN 'Eligible'
       ELSE C.[RegistryEnrollmentStatus]
       END AS [RegistryEnrollmentStatus]
      ,[EligibilityReview]
	  ,ROW_NUMBER () OVER (PARTITION BY C.[TreatmentName] ORDER BY C.[EnrollDate]) [OrderEnrolled] --SELECT TOP 10 * FROM 
  FROM [Reporting].[PSO500].[t_op_EER] C
  LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] DEL ON DEL.SubjectID = C.SubjectID AND DEL.VisitDate = C.EnrollDate
  WHERE 1=1
  AND [TreatmentName] LIKE '%-%' 
  AND [TreatmentName] NOT LIKE '%Other%'
  AND [SiteID] NOT in (999, 998, 997, 1440)

GO
