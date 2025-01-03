USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_115_VisitLog]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [IBD600].[v_op_115_VisitLog] as

WITH VISITLOG AS
(
SELECT DP.vID
      ,CAST(DP.SITENUM AS bigint) AS [Site ID]
      ,DP.SUBNUM AS [Subject ID]
	  ,CAST(MD.MD_COD AS int) AS [Provider ID]
	  ,CAST(VIS.VISITSEQ AS int) AS [Visit Sequence]
	  ,CAST(VIS.VISITDATE AS date) AS [Visit Date]
	  ,DATENAME(M, VIS.VISITDATE) AS [Visit Month]
	  ,DATEPART(YYYY, VIS.VISITDATE) AS [Visit Year]
	  ,DP.VISNAME AS [Visit Type]
	  ,VIS.VIR_3_1000_DEC AS DataCollection
	  ,VIS.VISIT_ASSOC_BIO_COLL_DEC AS BioRepositoryAssoc
	  ,VIS.VISIT_TYPE_BIO_COLL AS BioRepositoryVisitType
FROM MERGE_IBD.staging.DAT_PAGS AS DP 
LEFT OUTER JOIN MERGE_IBD.staging.VISIT AS VIS ON VIS.SUBID = DP.SUBID AND VIS.vid = DP.vid AND VIS.VISITSEQ = DP.VISITSEQ 
LEFT OUTER JOIN MERGE_IBD.staging.MD_DX AS MD ON MD.SUBID = DP.SUBID AND MD.vid = DP.vid AND MD.VISITSEQ = DP.VISITSEQ
WHERE  (DP.PAGENAME = 'Visit Date')

UNION

SELECT DP.vID
      ,CAST(DP.SITENUM AS bigint) AS [Site ID]
      ,DP.SUBNUM AS [Subject ID]
	  ,CAST(EXT.MD_COD AS int) AS [Provider ID]
	  ,CAST(EXT.VISITSEQ AS int) AS [Visit Sequence]
	  ,CAST(EXT.DISCONTINUE_DT AS date) AS [Visit Date]
	  ,DATENAME(M, EXT.DISCONTINUE_DT) AS [Visit Month]
	  ,DATEPART(YYYY, EXT.DISCONTINUE_DT) AS [Visit Year]
	  ,DP.VISNAME AS [Visit Type]
	  ,NULL AS DataCollection
	  ,NULL AS BioRepositoryAssoc
	  ,NULL AS BioRepositoryVisitType
FROM MERGE_IBD.staging.DAT_PAGS AS DP 
LEFT OUTER JOIN MERGE_IBD.staging.[EXIT] AS EXT ON EXT.SUBID = DP.SUBID AND EXT.vid = DP.vid AND EXT.VISITSEQ = DP.VISITSEQ
WHERE (EXT.STATUSID >= 0) AND (DP.PAGENAME like 'Exit Status')
)

SELECT V.vID
      ,V.[Site ID]
      ,CASE WHEN S.ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
      ,V.[Subject ID]
	  ,V.[Provider ID]
	  ,V.[Visit Sequence]
	  ,V.[Visit Date]
	  ,Substring(V.[Visit Month], 1, 3) AS [Visit Month]
	  ,V.[Visit Year]
	  ,V.[Visit Type]
	  ,V.DataCollection
	  ,V.BioRepositoryAssoc
	  ,V.BioRepositoryVisitType
FROM VISITLOG V
LEFT JOIN [MERGE_IBD].[dbo].[DAT_SITES] S ON S.SITENUM=V.[Site ID]
WHERE ISNULL(V.[Visit Date],'')<>''






GO
