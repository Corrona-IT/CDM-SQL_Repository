USE [Reporting]
GO
/****** Object:  View [AD550].[v_SiteStatus]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [AD550].[v_SiteStatus] as 

SELECT DISTINCT CAST(SUBSTRING(A.[name], 1, 4) AS int) AS SiteID
,A.[name] AS SiteIDNotSubstring
,CASE WHEN A.[enabled]='true' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
,RS.[currentStatus] AS SFSiteStatus
,RS.[name] AS RegistryName
FROM [RCC_AD550].[api].[study_sites] A
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=CAST(SUBSTRING(A.[name], 1, 4) AS int) AND RS.[name]='Atopic Dermatitis (AD-550)'
WHERE A.[name] NOT LIKE '1440%'

GO
