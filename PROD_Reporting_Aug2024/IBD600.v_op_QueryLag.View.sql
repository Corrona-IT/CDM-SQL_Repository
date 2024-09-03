USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_QueryLag]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--ALTER VIEW [staging].[DAT_AQU] AS (
Create VIEW [IBD600].[v_op_QueryLag] as (
SELECT CONVERT(BIGINT,CONVERT(VARCHAR,SUBID)+RIGHT('00000'+ CONVERT(VARCHAR,VISITID),6)+RIGHT('00'+ CONVERT(VARCHAR,VISITSEQ),3)) AS [vID]
-- old vID method		,CONVERT(BIGINT,CONVERT(VARCHAR,VISITSEQ)+RIGHT('0000'+ CONVERT(VARCHAR,VISITID),5)+RIGHT('0000'+ CONVERT(VARCHAR,SITENUM),5)+RIGHT('0000'+ CONVERT(VARCHAR,SUBID),5)) as [vID_old]
	, * 
	, MIN(LASTMDT) OVER (PARTITION BY QueryID) AS FirstDate
	, MIN(CASE WHEN CLOSED = 't' THEN LASTMDT END) OVER (PARTITION BY QueryID) AS ClosedDate
FROM [MERGE_IBD].[dbo].[DAT_AQU])
GO
