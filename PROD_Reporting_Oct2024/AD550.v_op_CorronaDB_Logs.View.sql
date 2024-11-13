USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_CorronaDB_Logs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [AD550].[v_op_CorronaDB_Logs] AS

SELECT MAX(LoadFinished) AS DataAsOf --select * 
FROM [RCC_Logs].[dbo].[loadLog] WHERE StagingDataBase = 'RCC_AD550'





GO
