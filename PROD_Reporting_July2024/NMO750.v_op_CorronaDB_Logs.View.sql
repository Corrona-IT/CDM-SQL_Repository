USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_CorronaDB_Logs]    Script Date: 8/1/2024 11:24:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [NMO750].[v_op_CorronaDB_Logs] AS

SELECT MAX(LoadFinished) AS DataAsOf --select * 
FROM [RCC_Logs].[dbo].[loadLog] WHERE StagingDataBase = 'RCC_NMOSD750'





GO
