USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteParameter_TEST]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







create VIEW [GPP510].[v_op_SiteParameter_TEST] AS


SELECT DISTINCT SITENUM
FROM [ZELTA_GPP_TEST].[dbo].[DAT_SITES]

GO
