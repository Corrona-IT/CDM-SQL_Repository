USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_TAEStatus]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [GPP510].[v_op_TAEStatus] AS 

SELECT DISTINCT ConfirmationStatus
FROM [GPP510].[t_pv_TAEQCListing]

GO
