USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_VisitLog_V3]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/*		and [VIS].SITENUM <> '9999'*/
CREATE VIEW [RA102].[v_op_VisitLog_V3] AS



SELECT 
	   VIS.vID,
	   dp.SITENUM AS SiteID, 
       dp.SUBNUM AS SubjectID, 
	   CASE WHEN dp.VISNAME LIKE 'Follow%' THEN 'Follow-Up'
	   ELSE dp.VISNAME
	   END AS VisitType, 
	   dp.VISITSEQ AS VisitSequence, 
	   VIS.VISITDATE AS VisitDate, 
	   PRO.PHYSICIAN_ID AS ProviderID,
	   'RA-102' AS Registry
FROM     [MERGE_RA_Japan].dbo.DAT_PAGS AS dp LEFT OUTER JOIN
         [MERGE_RA_Japan].staging.VIS_DATE AS VIS ON VIS.SUBID = dp.SUBID AND VIS.VISITID = dp.VISITID AND VIS.VISITSEQ = dp.VISITSEQ LEFT OUTER JOIN
         [MERGE_RA_Japan].staging.PRO_01 AS PRO ON PRO.SUBID = dp.SUBID AND PRO.VISITID = dp.VISITID AND PRO.VISITSEQ = dp.VISITSEQ
WHERE  (dp.PAGENAME = 'Date of visit')
		and [VIS].SITENUM NOT LIKE '99%'

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
	   EXT.MD_COD AS ProviderID,
	   'RA-102' AS Registry
FROM     [MERGE_RA_Japan].dbo.DAT_PAGS AS dp LEFT OUTER JOIN
         [MERGE_RA_Japan].staging.EXIT_01 AS EXT ON EXT.SUBID = dp.SUBID AND EXT.VISITID = dp.VISITID AND EXT.VISITSEQ = dp.VISITSEQ
--WHERE (EXT.STATUSID >= '10') AND (dp.PAGENAME = 'Exit (1 of 3)')
--just a thought on the where clause. Still not perfect, but this could help if we add a page in future revisions:
WHERE (EXT.STATUSID >= 0) AND (dp.PAGENAME like 'Exit (1 of %')
		and dp.SITENUM NOT LIKE '99%'


/*
-- Here's a cross registry report from CorronaDB

select erh.CorronaRegistryID, r.RegistryName, erh.SiteID, erh.SubjectID, evt.VisitType, erh.VisitDate, erh.ProviderID, ers.[EDCResponseStatus]
from [CorronaDB_Load].[dbo].[EDCResponseHeader] erh
join --		select * from
	[CorronaDB_Load].[dbo].[EDCResponseStatus] ers
		on ers.[EDCResponseStatusID] = erh.[EDCResponseStatusID]
join --		select * from
	[CorronaDB_Load].[dbo].[EDCVisitType] evt
		on evt.[VisitTypeID] = erh.[VisitTypeID]
join --		select * from
	[CorronaDB_Load].[dbo].[Registry] r
		on r.[CorronaRegistryID] = erh.[CorronaRegistryID]
where evt.[VisitTypeID] in (2,3,7) -- Enrollment, FollowUp, Exit

*/







GO
