USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteStatusView]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GPP510].[v_op_SiteStatusView] as 
select  *
,CASE WHEN rs.[CurrentStatus]='Approved / Active' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
from [Salesforce].[dbo].[registryStatus] rs
where rs.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
and rs.siteNumber is not NULL
--order by rs.[name]
GO
