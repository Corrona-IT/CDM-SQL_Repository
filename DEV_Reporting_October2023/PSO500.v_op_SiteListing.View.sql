USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_SiteListing]    Script Date: 10/16/2023 4:13:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [PSO500].[v_op_SiteListing] AS

SELECT DISTINCT CAST(SIT.[Site Number] AS int) AS [SiteID]
      ,site_status AS SiteStatus
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
--WHERE SIT.[Site Number] NOT IN (998, 999)
--AND ISNULL(site_status, '')=''
--ORDER BY [Site Number]


GO
