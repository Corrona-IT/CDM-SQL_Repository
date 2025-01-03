USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_ModifiedIDs]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [PSA400].[v_op_ModifiedIDs] AS

SELECT new.[SITENUM]
      ,new.[REVNUM]
      ,new.[SUBID]
      ,old.[SUBNUM] [old_SUBNUM]
      ,new.[SUBNUM] [new_SUBNUM]
      ,new.[IDENT2]
      ,new.[IDENT3]
      ,new.[STATUSID]
      ,new.[STATUSID_DEC]
      ,new.[REVISION]
      ,new.[DELETED]
      ,new.[REASON]
      ,new.[LASTMBY]
      ,new.[LASTMDT]
  FROM [MERGE_SPA].[dbo].[DAT_ASUB] new
  join [MERGE_SPA].[dbo].[DAT_ASUB] old
  on  old.SUBID = new.SUBID
  and old.REVNUM = new.REVNUM - 1
  where coalesce(old.SUBNUM,'') <> coalesce(new.SUBNUM,'')
GO
