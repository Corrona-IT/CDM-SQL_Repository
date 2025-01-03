USE [Reporting]
GO
/****** Object:  View [NMO750].[v_SiteStatus]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [NMO750].[v_SiteStatus] as 

SELECT DISTINCT CAST(SUBSTRING(A.[name], 1, 4) AS int) AS SiteID
,A.[name] AS SiteIDNotSubstring
,CASE WHEN A.[enabled]='true' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
,CASE WHEN CAST(SUBSTRING(A.[name], 1, 4) AS int) = 1440 THEN 'Approved / Active'
 ELSE RS.currentStatus 
 END AS SFSiteStatus
FROM [RCC_NMOSD750].[api].[study_sites] A
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=CAST(SUBSTRING(A.[name], 1, 4) AS int) AND RS.[name]='Neuromyelitis Optica Spectrum Disorder (NMOSD-750)'
--WHERE [name] NOT LIKE '1440%'


GO
