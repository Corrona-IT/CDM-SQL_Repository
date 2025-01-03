USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_VisitLog_V2]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [IBD600].[v_op_VisitLog_V2] AS

WITH VISITLOG AS
(
SELECT CAST(DP.SITENUM AS bigint) AS [SiteID]
      ,DP.SUBNUM AS [SubjectID]
	  ,CAST(MD.MD_COD AS int) AS [ProviderID]
	  ,CAST(VIS.VISITSEQ AS int) AS [VisitSequence]
	  ,CAST(VIS.VISITDATE AS date) AS [VisitDate]
	  ,SUBSTRING(DATENAME(MONTH, VISITDATE), 1, 3) AS [Month]
	  ,DATEPART(YYYY, VIS.VISITDATE) AS [Year]
	  ,DP.VISNAME AS [VisitType]
	  ,VIS.VIR_3_1000_DEC AS DataCollectionType
FROM MERGE_IBD.staging.DAT_PAGS AS DP 
LEFT OUTER JOIN MERGE_IBD.staging.VISIT AS VIS ON VIS.SUBID = DP.SUBID AND VIS.vid = DP.vid AND VIS.VISITSEQ = DP.VISITSEQ 
LEFT OUTER JOIN MERGE_IBD.staging.MD_DX AS MD ON MD.SUBID = DP.SUBID AND MD.vid = DP.vid AND MD.VISITSEQ = DP.VISITSEQ
WHERE  (DP.PAGENAME = 'Visit Date')

UNION

SELECT CAST(DP.SITENUM AS bigint) AS [SiteID]
      ,DP.SUBNUM AS [SubjectID]
	  ,CAST(EXT.MD_COD AS int) AS [ProviderID]
	  ,CAST(EXT.VISITSEQ AS int) AS [VisitSequence]
	  ,CAST(EXT.DISCONTINUE_DT AS date) AS [VisitDate]
	  ,SUBSTRING(DATENAME(M, EXT.DISCONTINUE_DT), 1, 3) AS [Month]
	  ,DATEPART(YYYY, EXT.DISCONTINUE_DT) AS [Year]
	  ,DP.VISNAME AS [VisitType]
	  ,'' AS DataCollectionType
FROM MERGE_IBD.staging.DAT_PAGS AS DP LEFT OUTER JOIN
MERGE_IBD.staging.[EXIT] AS EXT ON EXT.SUBID = DP.SUBID AND EXT.vid = DP.vid AND EXT.VISITSEQ = DP.VISITSEQ
WHERE (EXT.STATUSID >= 0) AND (DP.PAGENAME like 'Exit Status')
)

SELECT V.[SiteID]
      ,V.[SubjectID]
	  ,V.[ProviderID]
	  ,V.[VisitSequence]
	  ,V.[VisitDate]
	  ,V.[Month]
	  ,V.[Year]
	  ,V.[VisitType]
	  ,V.DataCollectionType
FROM VISITLOG V
WHERE ISNULL(V.[VisitDate],'')<>''







GO
