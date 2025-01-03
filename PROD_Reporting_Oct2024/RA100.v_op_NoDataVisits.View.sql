USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_NoDataVisits]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =================================================
-- Author:		Kevin Soe
-- Create date: 5/13/2022
-- Description:	View to obtain list of all visits in the RA EDC that have a status of 'No Data' for all associated CRFs.
-- =================================================

		  --SELECT * FROM
CREATE VIEW [RA100].[v_op_NoDataVisits] AS

SELECT [Trial Object Caption]
      ,[Trial Object TrialNo]
      ,[Site Object Caption]
      ,[Site Object SiteNo]
      ,[Site Object SiteName]
      ,[Patient Object Caption]
      ,[Patient Object Status]
      ,[Patient Object PatientNo] 
      ,[Visit Object ProCaption]
      ,[Visit Object Caption]
      ,[Visit Object Description]
      ,[Visit Object Status]
      ,[Visit Object OrderNo]
      ,[Visit Object InstanceNo]
      ,[Visit Object VisitDate]
      ,[Visit Object ExpectedVisitDate]
      ,[Visit Object LastChange]
      ,[InstanceNo]
      ,[ItemInstanceNo]
      ,[Visit_Visit Name]
      ,[Visit_VIPHID]
      ,[Visit_Visit Date]
      ,[Visit_Visit Number]
      ,[Visit_Visit Caption]
      ,[Visit_Upcoming Visit Offset]
      ,[Visit_Upcoming Visit Offset__R]
      ,[Visit_Expected Visit Date]
      ,[Visit_Earliest Expected Visit Date]
      ,[Visit_Latest Expected Visit Date]
      ,[Visit_EarliestDataChange] 
      ,[Visit_LatestDataChange]
      ,[Visit_EarliestStatusChange]
      ,[Visit_LatestStatusChange]
      ,[TrlTrialId]
      ,[TrlSiteId]
      ,[TrialId]
      ,[SiteId]
      ,[PatientId]
      ,[VisitId]
      ,[FormId]
      ,[FormParentId]
      ,[FormParentTypeId]
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[VISIT]

  WHERE 
  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ1]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')

  AND 

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ2]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')

  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ3]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ4]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')

  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ4_PEQ17B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ4_PEQ17C]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ4_PEQ17D]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PEQ5]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')

  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ1]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ2]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ2_PHE7B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
    
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ2_PHE7C]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
      
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ3]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
      
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ3_PHE8B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
        
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ4]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
          
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ5]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
            
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ5_PHE11B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
              
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ5_PHE12B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
              
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ6]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')

  UNION

  SELECT [Trial Object Caption]
      ,[Trial Object TrialNo]
      ,[Site Object Caption]
      ,[Site Object SiteNo]
      ,[Site Object SiteName]
      ,[Patient Object Caption]
      ,[Patient Object Status]
      ,[Patient Object PatientNo]
      ,[Visit Object ProCaption]
      ,[Visit Object Caption]
      ,[Visit Object Description]
      ,[Visit Object Status]
      ,[Visit Object OrderNo]
      ,[Visit Object InstanceNo]
      ,[Visit Object VisitDate]
      ,[Visit Object ExpectedVisitDate]
      ,[Visit Object LastChange]
      ,[InstanceNo]
      ,[ItemInstanceNo]
      ,[Visit_Visit Name]
      ,[Visit_VIPHID]
      ,[Visit_Visit Date]
      ,[Visit_Visit Number]
      ,[Visit_Visit Caption]
      ,[Visit_Upcoming Visit Offset]
      ,[Visit_Upcoming Visit Offset__R]
      ,[Visit_Expected Visit Date]
      ,[Visit_Earliest Expected Visit Date]
      ,[Visit_Latest Expected Visit Date]
      ,[Visit_EarliestDataChange]
      ,[Visit_LatestDataChange]
      ,[Visit_EarliestStatusChange]
      ,[Visit_LatestStatusChange]
      ,[TrlTrialId]
      ,[TrlSiteId]
      ,[TrialId]
      ,[SiteId]
      ,[PatientId]
      ,[VisitId]
      ,[FormId]
      ,[FormParentId]
      ,[FormParentTypeId]
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[VISIT]

  WHERE 
  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PFQ1]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')

  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PFQ2]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PFQ3]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PFQ4]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ1]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ2]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ2_PHF6B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ2_PHF6C]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ3]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ3_PHF7B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ4]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ4_PHF8B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ4_PHF9B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ5]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ5_PHF10B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ5_PHF11B]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')
  
  AND

  [VisitID] IN (SELECT [VisitId] 
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ6]
  WHERE [Form Object Status] = 'No Data'
  AND [Site Object SiteNo] NOT LIKE '99%')


GO
