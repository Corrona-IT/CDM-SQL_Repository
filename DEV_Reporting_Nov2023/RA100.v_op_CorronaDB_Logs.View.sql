USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_CorronaDB_Logs]    Script Date: 11/7/2023 12:08:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [RA100].[v_op_CorronaDB_Logs] AS

SELECT MAX(LoadFinished) AS DataAsOf --select * 
FROM [RCC_Logs].[dbo].[loadLog] WHERE StagingDataBase = 'RCC_RA100'





GO
