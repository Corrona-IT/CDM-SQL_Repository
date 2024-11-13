USE [Reporting]
GO
/****** Object:  View [MS700].[v_SiteParameter]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [MS700].[v_SiteParameter] AS 

SELECT DISTINCT CAST(SUBSTRING([name], 1, 4) AS int) AS SiteID

FROM [RCC_MS700].[api].[study_sites]
WHERE [name] NOT LIKE '1440%'
--ORDER BY SiteID

GO
