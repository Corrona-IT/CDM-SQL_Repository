USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteStatusView_TEST]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [GPP510].[v_op_SiteStatusView_TEST] as 
select  * from [Salesforce].[dbo].[registryStatus] rs
where rs.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
and rs.siteNumber is not NULL
--order by rs.[name]
GO
