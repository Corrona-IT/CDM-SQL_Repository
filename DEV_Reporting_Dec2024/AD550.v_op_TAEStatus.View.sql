USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_TAEStatus]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [AD550].[v_op_TAEStatus] AS 

SELECT DISTINCT ConfirmationStatus
FROM [AD550].[t_pv_TAEQCListing]

GO
