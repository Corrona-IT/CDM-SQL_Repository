USE [Reporting]
GO
/****** Object:  View [IBD600].[v_uat_SiteParameter]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [IBD600].[v_uat_SiteParameter] as 

select DISTINCT(CAST(SITENUM AS int)) AS SiteID
from MERGE_IBD_UAT.staging.VISIT

GO
