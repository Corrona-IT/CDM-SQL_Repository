USE [Reporting]
GO
/****** Object:  View [AD550].[v_SiteParameter]    Script Date: 8/1/2024 11:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [AD550].[v_SiteParameter] AS 

SELECT DISTINCT CAST(SUBSTRING([name], 1, 4) AS int) AS SiteID

FROM [RCC_AD550].[api].[study_sites]
--WHERE [name] NOT LIKE '1440%'
--ORDER BY SiteID

GO
