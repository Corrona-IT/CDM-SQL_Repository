USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CorronaDB_Logs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [PSA400].[v_op_CorronaDB_Logs] AS


/*********This view gives last database update date***********/

select DataAsOf from (
  SELECT [OldestFileDate] AS DataAsOf, row_number() over(order by [LoadDate] desc, [LoadSeq] desc) RN
  FROM [EDC_ETL_Logs].[logs].[EDC_Extract_DateStamps] where [SourceRegistryID] = 3 --3 for SPA, 5 Japan, 6 IBD
) t
where t.RN = 1

--
GO
