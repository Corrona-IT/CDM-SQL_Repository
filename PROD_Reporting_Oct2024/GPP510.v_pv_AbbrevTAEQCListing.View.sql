USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_AbbrevTAEQCListing]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW  [GPP510].[v_pv_AbbrevTAEQCListing] AS


WITH EVENTTERM AS (
SELECT vID,
       SITENUM,
	   SUBID,
	   SUBNUM,
	   VISNAME, 
	   VISITSEQ, 
	   PAGEID, 
	   PAGESEQ, 
	   PAGENAME,
	   STATUSID, 
	   COALESCE(TAE.[TERM_ANA_TAE_DEC], TAE.[TERM_CVD_TAE_DEC], TAE.[TERM_C19_TAE_DEC], TAE.[TERM_GEN_TAE_DEC], TAE.[TERM_HEP_TAE_DEC], TAE.[TERM_CAN_TAE_DEC], TAE.[TERM_NEU_TAE_DEC], TAE.[TERM_INF_TAE_DEC], TAE.[TERM_VTE_TAE_DEC], TAE.[EVENT_TYPE_DEC]) AS EventTerm
FROM [ZELTA_GPP].[dbo].[TAE]
WHERE PAGENAME='Confirmation Status'
)

SELECT ROW_NUMBER() OVER (PARTITION BY DPAGS.vID, DPAGS.SITENUM, DPAGS.SUBNUM ORDER BY DPAGS.SITENUM, DPAGS.SUBNUM, DPAGS.vID, DPAGS.[PAGELMDT] DESC) AS ROWNUM
      ,DPAGS.[SITENUM] AS SiteID
      ,DPAGS.[VISNAME] AS EventType
	  ,CASE WHEN DPAGS.VISNAME LIKE '%Preg%' THEN 'Pregnancy'
	   WHEN DPAGS.VISNAME LIKE '%Flare%' THEN 'GPP Flare'
	   ELSE ET.[EventTerm] 
	   END AS EventTerm
      ,DPAGS.[PAGENAME]
      ,DPAGS.[REVNUM]
      ,DPAGS.[SUBID]
      ,DPAGS.[SUBNUM] AS SubjectID
      ,DPAGS.[VISITID]
      ,DPAGS.[VISITSEQ]
      ,DPAGS.[PAGEID]
      ,DPAGS.[PAGESEQ]
      ,DPAGS.[STATUSID]
      ,DPAGS.[STATUSID_DEC]
      ,DPAGS.[DELETED]
      ,DPAGS.[REVISION]
	  ,(SELECT MIN([PAGELMDT]) FROM [ZELTA_GPP].[dbo].[DAT_APGS] APGS WHERE APGS.vID=DPAGS.vID AND APGS.PAGENAME=DPAGS.PAGENAME) AS CreatedDate
      ,DPAGS.[PAGELMBY] AS LastModifiedBy
      ,DPAGS.[PAGELMDT] AS LastModifiedDate
      ,DPAGS.[DATALMBY]
      ,DPAGS.[DATALMDT]
	  ,DPAGS.[vID]
	  ,DPAGS.[ORPHANED]
	  ,ET.vID taevid

FROM [ZELTA_GPP].[dbo].[DAT_PAGS] DPAGS
LEFT JOIN EVENTTERM ET ON DPAGS.vID=ET.vID AND DPAGS.SUBID=ET.SUBID 
WHERE 1=1
AND ((DPAGS.VISNAME LIKE '%TAE%' OR DPAGS.VISNAME LIKE '%Preg%' OR DPAGS.VISNAME LIKE '%Flare%') OR (DPAGS.PAGENAME LIKE '%Flare%'))
AND (DPAGS.PAGENAME NOT LIKE '%Subject Gift%')




GO
