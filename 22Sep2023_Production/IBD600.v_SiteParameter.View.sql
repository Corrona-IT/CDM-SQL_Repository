USE [Reporting]
GO
/****** Object:  View [IBD600].[v_SiteParameter]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [IBD600].[v_SiteParameter] as 

select DISTINCT(CAST(SITENUM AS int)) AS SiteID
FROM MERGE_IBD.dbo.DAT_SITES

GO
