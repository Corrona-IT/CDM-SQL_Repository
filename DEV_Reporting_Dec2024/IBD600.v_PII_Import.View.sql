USE [Reporting]
GO
/****** Object:  View [IBD600].[v_PII_Import]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [IBD600].[v_PII_Import] as

WITH PTS AS
(
SELECT 
	   R.[vID]
      ,R.[SITENUM]
      ,R.[SUBID]
      ,R.[SUBNUM]
      ,R.[VISNAME]
	  ,V.[VISITDATE]
	  ,R.[PII_HB] 
FROM [MERGE_IBD].[staging].[REIMB] R
INNER JOIN [MERGE_IBD].[staging].[VISIT] V ON V.[vID] = R.[vID] AND V.[SITENUM] = R.[SITENUM] AND V.[SUBNUM] = R.[SUBNUM]
WHERE R.[PII_HB] IS NULL
AND R.[VISNAME] = 'Enrollment' AND R.[PAGENAME] = 'Visit Date'
),

PTSPHI AS
(
SELECT
	 PTS.[SITENUM] AS [SiteID]
	,PTS.[SUBNUM] AS [Subject]
	,PTS.[VISITDATE] AS [Visit Date]
	,CASE WHEN PTS.[SUBNUM] IN (SELECT SUBJID FROM [Reporting].[IBD600].[t_HB]) THEN 'X'
	 ELSE NULL 
	 END AS [PII_HB]
FROM PTS
)

SELECT DISTINCT
	 [SiteID]
	,[Subject]
	,CAST([Visit Date] AS DATE) AS [Visit Date]
	,[PII_HB]
FROM PTSPHI
WHERE [PII_HB] = 'X'





GO
