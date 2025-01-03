USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SiteStatus]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE VIEW [RA100].[v_op_SiteStatus] AS

SELECT [Site Number] AS SiteID
      ,CASE WHEN UPPER([Address 3])='X' THEN 'Inactive'
	   ELSE 'Active'
	   END AS SiteStatus
	  ,CASE WHEN [Site Number] LIKE '99%' THEN 'Approved / Active'
	   ELSE RS.currentStatus 
	   END AS SFSiteStatus
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information] SI
    LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.SiteNumber=SI.[Site Number] AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
--WHERE [Site Number] NOT IN (998, 999) 


GO
