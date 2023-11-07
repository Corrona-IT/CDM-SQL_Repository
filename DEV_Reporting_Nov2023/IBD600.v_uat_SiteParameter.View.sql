USE [Reporting]
GO
/****** Object:  View [IBD600].[v_uat_SiteParameter]    Script Date: 11/7/2023 12:08:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [IBD600].[v_uat_SiteParameter] as 

select DISTINCT(CAST(SITENUM AS int)) AS SiteID
from MERGE_IBD_UAT.staging.VISIT

GO
