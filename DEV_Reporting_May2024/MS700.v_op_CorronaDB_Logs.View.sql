USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_CorronaDB_Logs]    Script Date: 6/6/2024 8:58:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [MS700].[v_op_CorronaDB_Logs] AS

SELECT MAX(LoadFinished) AS DataAsOf --select * 
FROM [RCC_Logs].[dbo].[loadLog] WHERE StagingDataBase = 'RCC_MS700'





GO
