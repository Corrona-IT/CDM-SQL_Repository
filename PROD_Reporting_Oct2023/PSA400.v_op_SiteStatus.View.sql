USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_SiteStatus]    Script Date: 10/16/2023 4:13:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [PSA400].[v_op_SiteStatus]  AS 

SELECT DISTINCT SITENUM AS [SiteID]
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
FROM MERGE_SPA.DBO.DAT_SITES 
WHERE SITENUM NOT IN (99997, 99998, 99999)
---ORDER BY SITENUM



GO
