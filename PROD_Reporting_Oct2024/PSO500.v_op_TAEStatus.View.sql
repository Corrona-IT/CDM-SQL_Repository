USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_TAEStatus]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [PSO500].[v_op_TAEStatus] AS 

SELECT DISTINCT ReportType
FROM [PSO500].[v_pv_TAEQCListing]

GO
