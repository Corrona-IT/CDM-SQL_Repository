USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_083_ExitReport]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*

SELECT dp.SITENUM, dp.SUBNUM, dp.VISNAME, EXT.DISCONTINUE_DATE, EXT.MD_COD, EXT.EXIT_REASON, EXT.STATUSID
FROM --		select * from 
	[MERGE_RA_Japan].dbo.DAT_PAGS AS dp 
left join --		select * from 
	[MERGE_RA_Japan].dbo.EXIT_01 AS EXT 
ON EXT.SUBID = dp.SUBID AND EXT.VISITID = dp.VISITID AND EXT.VISITSEQ = dp.VISITSEQ
WHERE (EXT.STATUSID >= '10') AND (dp.PAGENAME = 'Exit (1 of 3)')
ORDER BY dp.SITENUM, dp.SUBNUM, dp.VISNAME

*/


CREATE view [RA102].[v_op_083_ExitReport] as 

select dp.SITENUM, 
		dp.SUBNUM, 
		dp.VISNAME, 
		EXT.DISCONTINUE_DATE, 
		EXT.MD_COD, 
		EXT.EXIT_REASON, 
		exreas.[DISPLAYNAME] as [EXIT_REASON_DIS], 
		EXT.OTHER_SPECIFY, 
		EXT.STATUSID, 
		stat.DISPTEXT as [STATUS_DISPTEXT]
FROM (		
		select SITENUM, VISNAME, PAGENAME, REVNUM, SUBID, SUBNUM, VISITID, VISITSEQ, PAGEID, PAGESEQ, STATUSID, DELETED, REVISION, PAGELMBY, PAGELMDT, DATALMBY, DATALMDT, REASON, ORPHANED, ORPHANEDINFO
			, cast([STATUSID] as nvarchar(255))	as [nvarcharSTATUSID]
		from
			[MERGE_RA_Japan].dbo.DAT_PAGS
		where STATUSID <> 0 and PAGENAME like 'Exit (1 of %'
	) dp 
left join --		select * from 
	[MERGE_RA_Japan].dbo.EXIT_01 AS EXT 
		ON EXT.SUBID = dp.SUBID AND EXT.VISITID = dp.VISITID AND EXT.VISITSEQ = dp.VISITSEQ
left join --		select * from
	[MERGE_RA_Japan].dbo.DES_VDEF vd
		on  vd.VISITID = ext.VISITID
		and vd.PAGEID = ext.PAGEID
		and vd.REVNUM = dp.REVNUM
left join (
			select pd.[PAGENAME], cl.[CODENAME], [EDC_ETL].[dbo].[udf_StripHTML] (cl.[DISPLAYNAME]) as [DISPLAYNAME]
			from --		select * from				
				[MERGE_RA_Japan].dbo.DES_PDEF pd
			left join --		select * from
				[MERGE_RA_Japan].dbo.DES_CODELIST cl
					on cl.NAME = pd.CODELISTNAME
			where pd.REPORTINGC = 'EXIT_REASON'
	) exreas
		on  exreas.[PAGENAME] = vd.POBJNAME
		and exreas.[CODENAME] = ext.[EXIT_REASON]
left join (
			select CODENAME, DISPTEXT
			from --		select * from
				[MERGE_RA_Japan].dbo.DES_FORMATS cl
			where cl.CLNAME = 'DESPGST'
	) stat
		on  stat.[CODENAME] = dp.[nvarcharSTATUSID]	
			WHERE dp.SITENUM NOT IN (9997, 9998, 9999)
---ORDER BY dp.SITENUM, dp.SUBNUM, dp.VISNAME

/*
-- 2 are missing from the CorronaDB version since the exits are incomplete. 
-- I can make the adjustment if we only care about the status of the first page, but
-- is it better to return records from completed visits? Or would it be better to return 
-- all records where exit_reason is populared regardless of any completion status?
-- Subjects with incomplete pages 2/3 returned below:

select * from 
	[MERGE_RA_Japan].dbo.DAT_PAGS AS dp 
where subnum in ('20000000001', '99999999996')
and STATUSID < '10' AND dp.PAGENAME like 'Exit (%'


-- CorronaDB version is multi registry

select erh.CorronaRegistryID, r.RegistryName, erh.SiteID, erh.SubjectID, evt.VisitType, erh.VisitDate, erh.ProviderID, ers.[EDCResponseStatus], ecv.[EDCCodeValue] as [EXIT_REASON]
from [CorronaDB_Load].[dbo].[EDCResponseHeader] erh
join --		select * from
	[CorronaDB_Load].[dbo].[EDCResponseStatus] ers
		on ers.[EDCResponseStatusID] = erh.[EDCResponseStatusID]
join --		select * from
	[CorronaDB_Load].[dbo].[EDCVisitType] evt
		on evt.[VisitTypeID] = erh.[VisitTypeID]
left join--		select * from
	[CorronaDB_Load].[dbo].[EDCResponse] er
		on  er.[CorronaRegistryID] = erh.[CorronaRegistryID]
		and er.[SourceVisitID] = erh.[SourceVisitID]
		and er.[PageID] = erh.[PageID]
left join --		select * from
	[CorronaDB_Load].[dbo].[EDCQuestion] eq
		on eq.questionid = er.questionid
left join --		select * from
	[CorronaDB_Load].[dbo].[EDCCodeValue]	ecv
		on  ecv.[EDCCodeID] = eq.[EDCCodeID]
		and ecv.[StoredValue] = er.[SourceValue]
join --		select * from
	[CorronaDB_Load].[dbo].[Registry] r
		on r.[CorronaRegistryID] = erh.[CorronaRegistryID]
where BSNAME = 'EXIT_REASON'
and erh.[VisitTypeId] = 7 and ers.[EDCResponseStatusID] = 0
order by erh.SiteID, erh.SubjectID, erh.VisitDate

*/


GO
