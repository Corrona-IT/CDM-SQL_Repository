USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_SiteListing]    Script Date: 11/7/2023 11:31:36 AM ******/
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
