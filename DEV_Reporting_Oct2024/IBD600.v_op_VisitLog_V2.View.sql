USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_VisitLog_V2]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE view [IBD600].[v_op_VisitLog_V2] as

with months as (
      select cast(1  as int) as MonthCode, 'Jan' as MonthString
union select cast(2  as int) as MonthCode, 'Feb' as MonthString
union select cast(3  as int) as MonthCode, 'Mar' as MonthString
union select cast(4  as int) as MonthCode, 'Apr' as MonthString
union select cast(5  as int) as MonthCode, 'May' as MonthString
union select cast(6  as int) as MonthCode, 'Jun' as MonthString
union select cast(7  as int) as MonthCode, 'Jul' as MonthString
union select cast(8  as int) as MonthCode, 'Aug' as MonthString
union select cast(9  as int) as MonthCode, 'Sep' as MonthString
union select cast(10 as int) as MonthCode, 'Oct' as MonthString
union select cast(11 as int) as MonthCode, 'Nov' as MonthString
union select cast(12 as int) as MonthCode, 'Dec' as MonthString
)



,VISITLOG AS
(
SELECT CAST(DP.SITENUM AS bigint) AS [SiteID]
      ,DP.SUBNUM AS [SubjectID]
	  ,CAST(MD.MD_COD AS int) AS [ProviderID]
	  ,CAST(VIS.VISITSEQ AS int) AS [VisitSequence]
	  ,CAST(VIS.VISITDATE AS date) AS [VisitDate]
	  ,DATEPART(M, VIS.VISITDATE) AS [Month]
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
	  ,DATEPART(M, EXT.DISCONTINUE_DT) AS [Month]
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
	  ,ST.MonthString as [Month]
	  ,V.[Year]
	  ,V.[VisitType]
	  ,V.DataCollectionType
FROM VISITLOG V
LEFT join months st on st.MonthCode = V.[Month]
WHERE ISNULL(V.[VisitDate],'')<>''







GO
