USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SiteIDParameter]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [RA100].[v_op_SiteIDParameter]  as

SELECT DISTINCT [Site Number] AS SiteID
      ,CASE WHEN [Address 3]='x' THEN 'Inactive'
	   ELSE 'Active'
	   END AS SiteStatus
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information]
WHERE [Site Number] NOT IN (998, 999)

---ORDER BY SiteID, SubjectID
GO
