USE [Reporting]
GO
/****** Object:  View [RA100].[v_SiteParameter]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [RA100].[v_SiteParameter] AS 

SELECT DISTINCT LEFT([name], CHARINDEX('-',[name])-1) AS SiteID
--SELECT *
FROM [RCC_RA100].[api].[study_sites]
--WHERE [name] NOT LIKE '1440%'
--ORDER BY SiteID

GO
