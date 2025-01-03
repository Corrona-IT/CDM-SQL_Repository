USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_VisitLog]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [RA102].[v_op_VisitLog] AS


WITH VLOG AS
(
SELECT 
	   VIS.vID,
	   dp.SITENUM AS SiteID, 
       dp.SUBNUM AS SubjectID, 
	   CASE WHEN dp.VISNAME LIKE 'Follow%' THEN 'Follow-Up'
	   ELSE dp.VISNAME
	   END AS VisitType, 
	   dp.VISITSEQ AS VisitSequence, 
	   VIS.VISITDATE AS VisitDate, 
	   PRO.PHYSICIAN_ID AS ProviderID
FROM     [MERGE_RA_Japan].dbo.DAT_PAGS AS dp LEFT OUTER JOIN
         [MERGE_RA_Japan].staging.VIS_DATE AS VIS ON VIS.SUBID = dp.SUBID AND VIS.VISITID = dp.VISITID AND VIS.VISITSEQ = dp.VISITSEQ LEFT OUTER JOIN
         [MERGE_RA_Japan].staging.PRO_01 AS PRO ON PRO.SUBID = dp.SUBID AND PRO.VISITID = dp.VISITID AND PRO.VISITSEQ = dp.VISITSEQ
WHERE  (dp.PAGENAME = 'Date of visit')
		and [VIS].SITENUM NOT LIKE '99%'
		AND dp.DELETED='f'

UNION

SELECT 
	   EXT.vID,
	   dp.SITENUM AS SiteID, 
       dp.SUBNUM AS SubjectID, 
	   CASE WHEN dp.VISNAME LIKE 'Follow%' THEN 'Follow-Up'
	   ELSE dp.VISNAME
	   END AS VisitType, 
	   dp.VISITSEQ AS VisitSequence, 
	   EXT.DISCONTINUE_DATE AS VisitDate, 
	   EXT.MD_COD AS ProviderID
FROM     [MERGE_RA_Japan].dbo.DAT_PAGS AS dp LEFT OUTER JOIN
         [MERGE_RA_Japan].staging.EXIT_01 AS EXT ON EXT.SUBID = dp.SUBID AND EXT.VISITID = dp.VISITID AND EXT.VISITSEQ = dp.VISITSEQ
--WHERE (EXT.STATUSID >= '10') AND (dp.PAGENAME = 'Exit (1 of 3)')
--just a thought on the where clause. Still not perfect, but this could help if we add a page in future revisions:
WHERE (EXT.STATUSID >= 0) AND (dp.PAGENAME like 'Exit (1 of %')
		and dp.SITENUM NOT LIKE '99%'
		AND dp.DELETED='f'
)


SELECT
	 vID,
	 VLOG.SiteID, 
	 VLOG.SubjectID, 
	 SS.SiteStatus,
	 RS.currentStatus AS SFSiteStatus,
	 VLOG.VisitType, 
	 VisitSequence,
	 CASE 
		WHEN VisitType = 'Exit' THEN 99
		ELSE ROW_NUMBER() OVER (PARTITION BY SubjectID ORDER BY VisitDate) - 1 
		END AS CalcVisitSequence, 
	 VisitDate, 
	 ProviderID,
	 'RA-102' AS Registry
	 ,'Japan RA Registry (RA-102)' AS RegistryName
FROM VLOG
LEFT JOIN [Reporting].[RA102].[v_op_SiteStatus] SS ON SS.SiteID=VLOG.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]='Japan RA Registry (RA-102)' AND CAST(RS.[siteNumber] AS int)=CAST(VLOG.SiteID AS int)
WHERE ISNULL(VisitDate, '')<>''

GO
