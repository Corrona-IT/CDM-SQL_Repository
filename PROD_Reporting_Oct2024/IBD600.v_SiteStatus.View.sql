USE [Reporting]
GO
/****** Object:  View [IBD600].[v_SiteStatus]    Script Date: 11/13/2024 1:41:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [IBD600].[v_SiteStatus] as 

SELECT DISTINCT(CAST(SITENUM AS INT)) AS SiteID
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
,RS.currentStatus AS SFSiteStatus
FROM [MERGE_IBD].[dbo].[DAT_SITES] S
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=S.SITENUM AND RS.[name]='Inflammatory Bowel Disease (IBD-600)'

GO
