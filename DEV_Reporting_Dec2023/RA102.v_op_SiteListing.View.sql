USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_SiteListing]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [RA102].[v_op_SiteListing]  AS 

SELECT DISTINCT SITENUM AS [SiteID]
FROM MERGE_RA_Japan.DBO.DAT_SITES 
WHERE SITENUM NOT IN (9997, 9998, 9999)
---ORDER BY SITENUM



GO
