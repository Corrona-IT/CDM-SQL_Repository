USE [Reporting]
GO
/****** Object:  View [AD550].[v_pv_SiteParameter]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [AD550].[v_pv_SiteParameter] AS 

SELECT DISTINCT CAST(SUBSTRING([name], 1, 4) AS int) AS SiteID

FROM [RCC_AD550].[api].[study_sites]
--WHERE [name] NOT LIKE '1440%'
--ORDER BY SiteID

GO
