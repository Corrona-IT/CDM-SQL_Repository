USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteStatus]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [GPP510].[v_op_SiteStatus] AS
SELECT DISTINCT[currentStatus]
      
  FROM [Salesforce].[dbo].[registryStatus]
  where [name] = 'Generalized Pustular Psoriasis (GPP-510)'
  AND [currentStatus] IN ('Approved / Active', 'Pending closeout', 'Closed / Completed')
GO
