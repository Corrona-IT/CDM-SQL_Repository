USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_CorronaDB_Logs]    Script Date: 12/22/2023 12:56:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [AD550].[v_op_CorronaDB_Logs] AS

SELECT MAX(LoadFinished) AS DataAsOf --select * 
FROM [RCC_Logs].[dbo].[loadLog] WHERE StagingDataBase = 'RCC_AD550'





GO
