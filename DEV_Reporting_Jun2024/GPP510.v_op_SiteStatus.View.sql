USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteStatus]    Script Date: 7/15/2024 11:18:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [GPP510].[v_op_SiteStatus] AS

SELECT DISTINCT  

sitenumber as SiteID, 
[name], 
currentstatus as SiteStatus
      
  FROM [Salesforce].[dbo].[registryStatus]

  where [name] = 'Generalized Pustular Psoriasis (GPP-510)'
  AND [currentStatus] IN ('Approved / Active', 'Pending closeout', 'Closed / Completed')

GO
