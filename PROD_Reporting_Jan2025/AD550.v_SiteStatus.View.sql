USE [Reporting]
GO
/****** Object:  View [AD550].[v_SiteStatus]    Script Date: 1/3/2025 4:53:49 PM ******/
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
,CASE WHEN CAST(SUBSTRING(A.[name], 1, 4) AS int)=1440 THEN 'Not participating'
 ELSE RS.[currentStatus] 
 END AS SFSiteStatus
,CASE WHEN CAST(SUBSTRING(A.[name], 1, 4) AS int)=1440 THEN 'Atopic Dermatitis (AD-550)'
 ELSE RS.[name] 
 END AS RegistryName
FROM [RCC_AD550].[api].[study_sites] A
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=CAST(SUBSTRING(A.[name], 1, 4) AS int) AND RS.[name]='Atopic Dermatitis (AD-550)'
--WHERE A.[name] NOT LIKE '1440%'

GO
