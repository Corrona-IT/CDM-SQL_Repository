USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_SiteStatus2]    Script Date: 11/13/2024 1:41:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [PSO500].[v_op_SiteStatus2] AS

SELECT DISTINCT SIT.[Site Number] AS SiteID
               ,(CASE WHEN ISNULL(site_status, '')='' THEN 'Active'
			    ELSE site_status
				END) AS SiteStatus
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
WHERE SIT.[Site Number] NOT IN (998, 999)
--AND ISNULL(site_status, '')=''
--ORDER BY [Site Number]



GO
