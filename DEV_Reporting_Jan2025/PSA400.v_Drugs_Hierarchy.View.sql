USE [Reporting]
GO
/****** Object:  View [PSA400].[v_Drugs_Hierarchy]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [PSA400].[v_Drugs_Hierarchy] AS



 SELECT 
	   d.[SourceVisitID]
      ,d.[SUBNUM]
      ,d.[PAGEDISPLAY]
      ,d.[VISITID]
      ,d.[SourceVisitSeq]
      ,d.[PAGEID]
      ,d.[PAGESEQ]
      ,d.[DRUG_NAME_DEC]
      ,d.[DRUG_NO_PRIOR_USE]
      ,d.[DrugReqSatisfied]
      ,d.[Diagnosed_DATA]
      ,d.[IncidentUse_LOGIC]
      ,d.[IncidentUse_DATA]
      ,d.[CurrentUse_LOGIC]
      ,d.[CurrentUse_DATA]
      ,d.[VisitDate]
	  ,h.[Cohort] [Cohort_LOGIC]
	  ,h.[CohortHierarchy] [CohortHierarchy_LOGIC]
	  ,h.[IntraCohortHierarchy] [IntraCohortHierarchy_LOGIC]
	  ,ROW_NUMBER() OVER(PARTITION BY d.SourceVisitID 
			ORDER BY 
				  d.[DrugReqSatisfied] DESC
				, d.[IncidentUse_DATA] DESC
				, d.[DRUG_NO_PRIOR_USE] DESC
				, d.[CurrentUse_DATA] DESC
				, CASE WHEN h.[CohortHierarchy] IS NULL THEN 9999 
				  ELSE h.[CohortHierarchy] 
				  END ASC 
				, CASE WHEN ISNUMERIC(h.[IntraCohortHierarchy]) = 1 THEN h.[IntraCohortHierarchy] 
				  ELSE CAST(NULL AS int)
				  END ASC 
				, h.[Drug] 
		) [Hierarchy_DATA]
      ,h.[StartDate] AS [hStartDate]
      ,h.[EndDate] AS [hEndDate]
FROM [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] d 
LEFT JOIN [Reimbursement].[Reference].[t_DrugHierarchy] h ON  h.[CorronaRegistryID] = 3 AND h.[Drug] = d.[DRUG_NAME_DEC] AND d.visitdate between h.StartDate AND	h.EndDate
WHERE FormTypeName = 'MDEN' 





GO
