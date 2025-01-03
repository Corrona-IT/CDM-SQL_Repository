USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_058_EnrollmentEligibilitySummary_V2]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [RA102].[v_op_058_EnrollmentEligibilitySummary_V2] as SELECT 
       e1.[SiteID]
      ,e1.[ProviderID]
      ,e.[SubjectID]
      ,e.[VisitDate]
      ,dbl.[VisitType]
	  ,e.[AGE]
	  ,case when e.[Age] >= 18 then 1 else NULL end as [AtLeast18]
	  ,e.[Yr_Onset_RA]
	  ,CASE WHEN e.[Diagnosed]='RA' THEN 1 ELSE NULL END AS [Diagnosed]
      ,d.[Drug]
      ,CASE 
	   WHEN d.[EligibleDrug] = '1' THEN 'Yes'
	   ELSE ''
	   END AS  [EligibleDrug]
      ,CASE
	   WHEN d.[PrescAtVisit] = '1' THEN 'Yes'
	   ELSE ''
	   END AS [PrescAtVisit]
      ,CASE
	   WHEN d.[PriorUse] = '1' THEN 'Yes'
	   ELSE ''
	   END AS [PriorUse]
      ,CASE
	   WHEN d.[DrugReqSatisfied] = '1' THEN 'Yes'
	   ELSE ''
	   END AS [EligPresc_woPriorUse]



  --		select *
  FROM [Reimbursement].[cdb_rajp].[v_EnrollmentEligibility] e
  join [Reimbursement].[cdb].[v_EnrollmentEligibility_wEFE] e1 on e.[SourceVisitID] = e1.[SourceVisitID]
  and e.[CorronaRegistryID] = e1.[CorronaRegistryID]

  join [CorronaDB_Load].[dbo].[edcvisittype] dbl on e.visittypeid=dbl.visittypeid

  join --		select * from
		[Reimbursement].[cdb_rajp].[v_Drugs_PrescAtVisit_PriorUse] d
  on e.[SourceVisitID] = d.[SourceVisitID] 
  and e.[CorronaRegistryID] = d.[CorronaRegistryID]

  WHERE e.[CorronaRegistryID] = 5
  --AND d.[DrugReqSatisfied]=1
  AND e1.[SiteID] NOT LIKE '9%'

  ---ORDER BY SiteID, SubjectID, VisitDate



GO
