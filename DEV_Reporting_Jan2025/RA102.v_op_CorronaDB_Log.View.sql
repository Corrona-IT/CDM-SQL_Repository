USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_CorronaDB_Log]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











/****** CorronaDB_Log (Database lastupdated timestamp)  ******/

CREATE view [RA102].[v_op_CorronaDB_Log] as 


select DataAsOf from (
  SELECT [OldestFileDate] AS DataAsOf, row_number() over(order by [LoadDate] desc, [LoadSeq] desc) RN
  FROM [EDC_ETL_Logs].[logs].[EDC_Extract_DateStamps] where [SourceRegistryID] = 5 --3 for SPA, 5 Japan, 6 IBD
) t
where t.RN = 1






GO
