USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_058_EnrollmentEligibilitySummary_V3]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [RA102].[v_op_058_EnrollmentEligibilitySummary_V3] as 

    SELECT 
       e1.[SiteID]
      ,e1.[ProviderID]
      ,e.[SubjectID]
      ,e.[VisitDate]
      ,dbl.[VisitType]
	  ,e.[AGE]
	  ,case when e.[Age] >= 18 then 1 else NULL end as [AtLeast18]
	  ,e.[Yr_Onset_RA]
	  ,CASE WHEN e.[Diagnosed]='RA' THEN 1 ELSE NULL END AS [Diagnosed]
      ,CASE WHEN d.[DrugNameOther] = 'upadacitinib (Rinvoq)' THEN 'RINVOQ'
			WHEN d.[DrugNameOther] = 'peficitinib (Smyraf)' THEN 'SMYRAF' 
			ELSE d.[Drug]
	   END AS [Drug]
	  ,CASE WHEN d.[Drug] =	'OTH_BIOTS'	  THEN p4.[OTH_BIOTS_TEXT]
			WHEN d.[Drug] = 'OTH_CSDMARD' THEN p5.[OTH_CSDMARD_TEXT]
			WHEN d.[Drug] =	'OTHER_BIONB' THEN p6.[OTHER_BIONB_SPECIFY]
		ELSE NULL
		END AS [OtherDrugName]
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
  FROM [10.0.1.83].[Reimbursement].[cdb_rajp].[v_EnrollmentEligibility] e
  join [10.0.1.83].[Reimbursement].[cdb].[v_EnrollmentEligibility_wEFE] e1 on e.[SourceVisitID] = e1.[SourceVisitID]
  and e.[CorronaRegistryID] = e1.[CorronaRegistryID]

  join [10.0.1.83].[CorronaDB_Load].[dbo].[edcvisittype] dbl on e.visittypeid=dbl.visittypeid

  join --		select * from
		[10.0.1.83].[Reimbursement].[cdb_rajp].[v_Drugs_PrescAtVisit_PriorUse] d
  on e.[SourceVisitID] = d.[SourceVisitID] 
  and e.[CorronaRegistryID] = d.[CorronaRegistryID]
  join [10.0.1.83].[MERGE_RA_Japan].[staging].[PE_04] p4 ON p4.vID = e.[SourceVisitID]
  join [10.0.1.83].[MERGE_RA_Japan].[staging].[PRO_05] p5 ON p5.vID = e.[SourceVisitID]
  join [10.0.1.83].[MERGE_RA_Japan].[staging].[PRO_06] p6 ON p6.vID = e.[SourceVisitID]
  WHERE e.[CorronaRegistryID] = 5
  --AND d.[DrugReqSatisfied]=1
  AND e1.[SiteID] NOT LIKE '9%'

  ---ORDER BY SiteID, SubjectID, VisitDate






GO
