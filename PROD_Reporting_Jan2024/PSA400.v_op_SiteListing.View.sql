USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_SiteListing]    Script Date: 1/31/2024 10:27:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSA400].[v_op_SiteListing]  AS 

SELECT DISTINCT SITENUM AS [SiteID]
FROM MERGE_SPA.DBO.DAT_SITES 
WHERE SITENUM NOT IN (99997, 99998, 99999)
---ORDER BY SITENUM



GO
