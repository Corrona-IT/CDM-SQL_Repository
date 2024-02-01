USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_CorronaDB_Logs]    Script Date: 1/31/2024 10:27:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [MS700].[v_op_CorronaDB_Logs] AS

SELECT MAX(LoadFinished) AS DataAsOf --select * 
FROM [RCC_Logs].[dbo].[loadLog] WHERE StagingDataBase = 'RCC_MS700'





GO
