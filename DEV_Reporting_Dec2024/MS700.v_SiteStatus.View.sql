USE [Reporting]
GO
/****** Object:  View [MS700].[v_SiteStatus]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [MS700].[v_SiteStatus] as 

SELECT DISTINCT CAST(SUBSTRING(A.[name], 1, 4) AS int) AS SiteID
,CASE WHEN A.[enabled]='true' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
,rs.currentStatus AS SFSiteStatus
FROM [RCC_MS700].[api].[study_sites] A  --SELECT * FROM [Salesforce].[dbo].[registryStatus]
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=SUBSTRING(A.[name], 1, 4) AND  RS.[name] = 'Multiple Sclerosis (MS-700)'
WHERE A.[name] NOT LIKE '1440%'

GO
