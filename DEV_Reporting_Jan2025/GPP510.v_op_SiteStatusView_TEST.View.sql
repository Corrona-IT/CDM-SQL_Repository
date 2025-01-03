USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteStatusView_TEST]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GPP510].[v_op_SiteStatusView_TEST] as 
--select  * from [Salesforce].[dbo].[registryStatus] rs
select  distinct  SiteID as SiteNumber, 
SiteStatus, 
SFSiteStatus as CurrentStatus
from [Reporting].GPP510.v_op_VisitLog_TEST rs
--where rs.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
--and rs.siteNumber is not NULL
--order by rs.[name]
GO
