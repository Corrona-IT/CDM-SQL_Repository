USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_TAEStatus]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [AD550].[v_op_TAEStatus] AS 

SELECT DISTINCT ConfirmationStatus
FROM [AD550].[t_pv_TAEQCListing]

GO
