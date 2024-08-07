USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SiteStatus_rcc]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [RA100].[v_op_SiteStatus_rcc] as 

SELECT DISTINCT CAST(SUBSTRING(A.[name], 1, CHARINDEX('-',A.[name])-1) AS int) AS SiteID
,A.[name] AS SiteIDNotSubstring
,CASE WHEN A.[enabled]='true' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
,CASE WHEN CAST(SUBSTRING(A.[name], 1, CHARINDEX('-',A.[name])-1) AS int)=1440 THEN 'Not participating'
 ELSE RS.[currentStatus] 
 END AS SFSiteStatus
,CASE WHEN CAST(SUBSTRING(A.[name], 1, CHARINDEX('-',A.[name])-1) AS int)=1440 THEN 'Rheumatoid Arthritis (RA-100)'
 ELSE RS.[name] 
 END AS RegistryName --SELECT *
FROM [RCC_RA100].[api].[study_sites] A
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=CAST(SUBSTRING(A.[name], 1, CHARINDEX('-',A.[name])-1) AS int) AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
--WHERE A.[name] NOT LIKE '1440%'

GO
