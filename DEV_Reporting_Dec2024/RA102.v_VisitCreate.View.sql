USE [Reporting]
GO
/****** Object:  View [RA102].[v_VisitCreate]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/

CREATE view [RA102].[v_VisitCreate] as
SELECT
       av.[VISNAME]
      ,av.[VISITID]
      ,av.[VISITSEQ]
      ,av.[SUBNUM]
	  ,v.[VISITDATE]
      ,min(av.[DATALMDT]) [minDATALMDT]
  FROM [MERGE_RA_Japan].[dbo].[VIS_DATE_AFLD] av
  join [MERGE_RA_Japan].[dbo].[VIS_DATE] v
	on  v.visitid	= av.visitid
	and v.visitseq 	= av.visitseq
	and v.subid 	= av.subid 
    and v.[PAGEID]	= av.[PAGEID]
    and v.[PAGESEQ]	= av.[PAGESEQ]
  where av.COLNAME = 'VISITDATE' and v.[VISITDATE] is not null
  group by  av.[VISNAME]
      ,av.[VISITID]
      ,av.[VISITSEQ]
      ,av.[SUBNUM]
	  ,v.[VISITDATE]




GO
