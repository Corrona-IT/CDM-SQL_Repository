USE [Reporting]
GO
/****** Object:  View [AA560].[v_op_TAEStatus]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [AA560].[v_op_TAEStatus] AS 

SELECT DISTINCT ConfirmationStatus
FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing]

GO
