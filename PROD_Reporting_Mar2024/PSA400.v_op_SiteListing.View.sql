USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_SiteListing]    Script Date: 4/2/2024 11:30:01 AM ******/
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
