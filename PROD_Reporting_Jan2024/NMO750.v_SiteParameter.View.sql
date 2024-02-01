USE [Reporting]
GO
/****** Object:  View [NMO750].[v_SiteParameter]    Script Date: 1/31/2024 10:27:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [NMO750].[v_SiteParameter] AS 

SELECT DISTINCT CAST(SUBSTRING([name], 1, 4) AS int) AS SiteID

FROM [RCC_NMOSD750].[api].[study_sites]
--WHERE [name] NOT LIKE '1440%'
--ORDER BY SiteID

GO
