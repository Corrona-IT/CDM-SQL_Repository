USE [Reporting]
GO
/****** Object:  View [IBD600].[v_Nameless_Drugs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [IBD600].[v_Nameless_Drugs] as 
SELECT distinct st.[vID]
      ,s.[SITENUM]
      ,st.[SUBID]
      ,st.[VISITID]
      ,st.[VISITSEQ]
      ,st.[POBJNAME]
      ,st.[PAGEID]
      ,st.[PAGESEQ]
      ,st.[SourceTable]
      ,st.[NamedPivotCodeName]
      ,st.[NamedPivotSeq]
FROM [MERGE_IBD].[staging].[Staged_Responses] st
left join [EDC_ETL].[ETLmaps].[MERGE_IBD_DES_vDEF] vd
on  vd.[REVNUM] = st.[REVNUM]
and vd.[VISITID] = st.[VISITID]
and vd.[PAGEID] = st.[PAGEID]
left join [EDC_ETL].[ETLmaps].[MERGE_IBD_DES_pDEF] pd
on  pd.[PAGENAME]   = vd.[POBJNAME]
and pd.[REPORTINGT] = st.[SourceTable]
and pd.[REPORTINGC] = st.[Attribute]
join [MERGE_IBD].[dbo].[DAT_SUB] s
on s.[SUBID] = st.[SUBID]
where 1=1
and nullif(pd.[Ignore],0) is null
and vd.[EnforceRelationship] = 1
--and s.sitenum not like '99%'
and st.[Exception] = 1
and NamedPivotCodeName is null
GO
