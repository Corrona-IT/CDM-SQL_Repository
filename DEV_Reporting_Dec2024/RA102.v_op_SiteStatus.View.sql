USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_SiteStatus]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [RA102].[v_op_SiteStatus]  AS 

SELECT DISTINCT SITENUM AS [SiteID]
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
FROM MERGE_RA_Japan.DBO.DAT_SITES 
WHERE SITENUM NOT LIKE '9%'
---ORDER BY SITENUM



GO
