USE [Reporting]
GO
/****** Object:  View [PSA400].[v_Nameless_Drugs]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [PSA400].[v_Nameless_Drugs] as 
SELECT st.[vID]
      ,s.[SITENUM]
      ,st.[SUBID]
      ,st.[VISITID]
      ,st.[VISITSEQ]
      ,st.[POBJNAME]
      ,st.[PAGEID]
      ,st.[PAGESEQ]
      ,st.[SourceTable]
      ,st.[Attribute]
      ,st.[NamedPivotCodeName]
      ,st.[NamedPivotSeq]
	  ,vd.EnforceRelationship
FROM --		select * from 
	[MERGE_SPA].[staging].[Staged_Responses] st
left join [EDC_ETL].[ETLmaps].[MERGE_IBD_DES_vDEF] vd
on  vd.[REVNUM] = st.[REVNUM]
and vd.[VISITID] = st.[VISITID]
and vd.[PAGEID] = st.[PAGEID]
left join [EDC_ETL].[ETLmaps].[MERGE_SPA_DES_pDEF] pd
on  pd.[PAGENAME]   = vd.[POBJNAME]
and pd.[REPORTINGT] = st.[SourceTable]
and pd.[REPORTINGC] = st.[Attribute]
join [MERGE_SPA].[dbo].[DAT_SUB] s
on s.[SUBID] = st.[SUBID]
where 1=1
and nullif(pd.[Ignore],0) is null
and vd.[EnforceRelationship] = 1
--and s.sitenum not like '99%'
and st.[Exception] = 1
and NamedPivotCodeName is null
GO
