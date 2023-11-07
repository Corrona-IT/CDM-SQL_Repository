USE [Reporting]
GO
/****** Object:  View [IBD600].[v_SiteParameter]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [IBD600].[v_SiteParameter] as 

select DISTINCT(CAST(SITENUM AS int)) AS SiteID
FROM MERGE_IBD.dbo.DAT_SITES

GO
