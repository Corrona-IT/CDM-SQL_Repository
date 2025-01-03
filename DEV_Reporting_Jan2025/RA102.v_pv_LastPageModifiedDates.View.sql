USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_LastPageModifiedDates]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Garth Fitzsimmons
-- Create date: 12/01/2016
-- Description:	Returns min and max modified dates for the "last" page of each page group
-- eg. "Provider Enrollment (7 of 7)" is last page of "Provider Enrollment" page group
-- Original purpose to audit data entry group. Data entry for questionnaires must be complete within X time of receipt.
-- =============================================

CREATE view [RA102].[v_pv_LastPageModifiedDates] as 

/*

select 
			 ap.[SUBNUM]
			--,ap.[REVNUM]
			,ap.[VISITID]
			,ap.[VISITSEQ]
			,ap.[PAGEID]
			,ap.[PAGESEQ]
			,ap.STATUS
			,count(*)
from  [MERGE_RA_Japan].[reports].[LastPageModifiedDates_v3] ap
group by 			 ap.[SUBNUM]
			--,ap.[REVNUM]
			,ap.[VISITID]
			,ap.[VISITSEQ]
			,ap.[PAGEID]
			,ap.[PAGESEQ]
			,ap.STATUS
having count(*) > 1
*/

with lastpg as (
		select [REVNUM],[VISITID],[EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) pgnm, max(PORDER) maxPORDER
		--		select *
		  FROM [MERGE_RA_Japan].[dbo].[DES_VDEF] 
		  where pagename like 'Provider %'
	--				 where [EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename) = 'Enrollment Lab'  order by [REVNUM],[VISITID],[PAGENAME]
		group by [REVNUM],[VISITID],[EDC_ETL].[dbo].[udf_MERGE_Strip_PageNumbers](pagename)

)

, revision as (
		select 
		 min(ap.[Revision]) [minREVISION]
			,ap.[SUBNUM]
			,ap.[REVNUM]
			,ap.[VISITID]
			,ap.[VISITSEQ]
			,ap.[PAGEID]
			,ap.[PAGESEQ]
			,ap.[STATUSID]
		--		select count(*)
		--		select *
		  FROM [MERGE_RA_Japan].[dbo].[DAT_APGS] ap
		  join [MERGE_RA_Japan].[dbo].[DES_VDEF] vd
		  on  vd.[REVNUM]		= ap.[REVNUM]		
		  and vd.[VISITID]		= ap.[VISITID]		
		  and vd.[PAGEID]		= ap.[PAGEID]		
		  join lastpg lp 
		  on  lp.[REVNUM]		= ap.[REVNUM]		
		  and lp.[VISITID]		= ap.[VISITID]	
		  and lp.[maxPORDER]	= vd.[PORDER]	
		group by
			 ap.[SUBNUM]
			,ap.[REVNUM]
			,ap.[VISITID]
			,ap.[VISITSEQ]
			,ap.[PAGEID]
			,ap.[PAGESEQ]
			,ap.[STATUSID]
)

--		select * from revision order by [SUBNUM],[REVNUM],[VISITID],[VISITSEQ],[PAGEID],[PAGESEQ],[STATUSID]

select
	 apgs.[SUBNUM]
	,apgs.[SITENUM]
	,apgs.[VISNAME]
	,apgs.[VISITSEQ]
	,apgs.[PAGENAME]
	,apgs.[PAGESEQ]
	,apgs.[STATUSID]
	,  df.[DISPTEXT] [STATUS]
	,apgs.[PAGELMBY]
	,apgs.[PAGELMDT]
	,apgs.[DATALMBY]
	,apgs.[DATALMDT]
	,apgs.[REASON]
	,apgs.[ORPHANED]
	,apgs.[ORPHANEDINFO]
	,apgs.[SUBID]
	,apgs.[REVNUM]
	,apgs.[VISITID]
	,apgs.[PAGEID]
	,apgs.[DELETED]
--		select apgs.*, df.[DISPTEXT] [STATUS]
FROM --		select * from
	[MERGE_RA_Japan].[dbo].[DAT_APGS] apgs
join revision rev
on  rev.[minREVISION]  = apgs.[REVISION]
and rev.[SUBNUM]	   = apgs.[SUBNUM]	 
and rev.[REVNUM]	   = apgs.[REVNUM]	 
and rev.[VISITID]	   = apgs.[VISITID]	 
and rev.[VISITSEQ]	   = apgs.[VISITSEQ]	 
and rev.[PAGEID]	   = apgs.[PAGEID]	 
and rev.[PAGESEQ]	   = apgs.[PAGESEQ]	 
and rev.[STATUSID]	   = apgs.[STATUSID]	 
left join --		select * from
	[MERGE_RA_Japan].[dbo].[DES_FORMATS] df
  on  df.[CODENAME] = apgs.[STATUSID]
  and df.[CLNAME] = 'DESPGST'
where apgs.[STATUSID] in (0,5)
/*
order by 
	 apgs.[SUBNUM]
	,apgs.[REVNUM]
	,apgs.[VISITID]
	,apgs.[VISITSEQ]
	,apgs.[PAGEID]
	,apgs.[PAGESEQ]
	,apgs.[STATUSID]
*/



GO
