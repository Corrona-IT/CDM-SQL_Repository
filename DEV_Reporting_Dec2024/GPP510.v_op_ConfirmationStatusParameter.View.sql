USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_ConfirmationStatusParameter]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [GPP510].[v_op_ConfirmationStatusParameter] AS



SELECT DISTINCT [confirmationStatus]
FROM [GPP510].[t_pv_TAEQCListing]

GO
