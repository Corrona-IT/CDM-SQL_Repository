USE [Reporting]
GO
/****** Object:  View [AD550].[v_SiteParameter_DEV]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [AD550].[v_SiteParameter_DEV] AS 

SELECT DISTINCT CAST(SUBSTRING([name], 1, 4) AS int) AS SiteID

FROM [RCC_AD550_DEV].[api].[study_sites]
--WHERE [name] NOT LIKE '1440%'
--ORDER BY SiteID

GO
