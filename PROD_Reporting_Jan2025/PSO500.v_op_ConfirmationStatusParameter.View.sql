USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_ConfirmationStatusParameter]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [PSO500].[v_op_ConfirmationStatusParameter] AS



SELECT DISTINCT [ReportType]
FROM [PSO500].[v_pv_TAEQCListing]

GO
