USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_AbbrevPregnancy]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [GPP510].[v_pv_AbbrevPregnancy] AS


SELECT *
FROM (
SELECT *,

	   (SELECT DATAVAL_DEC WHERE ROWNUM=1) AS CURVAL,
	   (SELECT DATAVAL_DEC WHERE ROWNUM=2) AS PREVVAL

FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY S.vID, S.SITENUM, S.SUBID, S.PAGENAME ORDER BY S.SITENUM, S.SUBNUM, S.VisitDate, S.DATALMDT DESC) AS ROWNUM,
      [SITENUM],
	  [SUBID],
	  [SUBNUM],
	  [VISNAME],
	  VisitDate,
	  [VISITSEQ],
	  [PAGENAME],
	  [vID],
	  [COLNAME],
	  QTXT,
	  [DATALMDT],
	  [DATALMBY],
	  [DATAVAL_DEC],
	  [REASON]

FROM (
 SELECT SubAudit.[SITENUM]
      ,SubAudit.[SUBID]
	  ,SubAudit.[SUBNUM]
	  ,SubAudit.[VISNAME]
	  ,COALESCE(V.[VISDAT],V.[FLRVISDAT]) AS VisitDate
	  ,SubAudit.[VISITSEQ]
	  ,SubAudit.[PAGENAME]
	  ,SubAudit.[vID]
	  ,SubAudit.[COLNAME]
	  ,'Are you currently pregnant?' AS QTXT
	  ,SubAudit.[DATALMDT]
	  ,SubAudit.[DATALMBY]
	  ,SubAudit.[DATAVAL_DEC]
	  ,SubAudit.[REASON]

FROM [ZELTA_GPP].[dbo].[SUB_B_AFLD] SubAudit
LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.vID=SubAudit.vID AND V.SUBID=SubAudit.SUBID
WHERE 1=1
AND [COLNAME]='PREGCURR' 
) S
) S1
)s2
WHERE 1=1
AND (ISNULL(CURVAL, '')<>ISNULL(PREVVAL, ''))
OR CURVAL='Yes'



GO
