USE [Reporting]
GO
/****** Object:  View [IBD600].[v_uat_SiteParameter]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [IBD600].[v_uat_SiteParameter] as 

select DISTINCT(CAST(SITENUM AS int)) AS SiteID
from MERGE_IBD_UAT.staging.VISIT

GO
