USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_DataEntryLag_TEST]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [GPP510].[v_op_DataEntryLag_TEST] AS


WITH DE AS
(
SELECT ROW_NUMBER() OVER (PARTITION BY APGS.VID ORDER BY APGS.SITENUM, APGS.SUBNUM, APGS.REVISION, APGS.DATALMDT, APGS.VISITSEQ) AS RowNum
      ,APGS.vID
	  ,APGS.REVISION
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,APGS.VISITSEQ AS VisitSeq
	  ,CASE WHEN (APGS.VISNAME = 'GPP Flare (Populated)' OR APGS.VISNAME = 'GPP Flare (Manual)') THEN CAST(VIS.FLRVISDAT AS date) 
	  WHEN (APGS.VISNAME = 'Enrollment' OR APGS.VISNAME = 'Follow-Up (Non-flaring)') THEN CAST(VIS.VISDAT AS date)
	  END AS VisitDate
	  ,CAST(APGS.DATALMDT AS date) AS DEcompletion
	  ,APGS.DELETED AS Deleted
FROM ZELTA_GPP_TEST.dbo.DAT_APGS APGS 
LEFT JOIN ZELTA_GPP_TEST.dbo.VISIT VIS ON APGS.VID=VIS.VID
WHERE (APGS.PAGENAME='Visit Information' OR ((APGS.VISNAME='GPP Flare (Populated)' OR APGS.VISNAME='GPP Flare (Manual)')
AND APGS.PAGENAME='Confirmation Status'))
AND APGS.STATUSID = 10
AND (VIS.VISDAT IS NOT NULL OR VIS.FLRVISDAT IS NOT NULL)
AND APGS.DATALMDT IS NOT NULL
AND APGS.SUBNUM NOT IN (SELECT SUBNUM FROM ZELTA_GPP_TEST.dbo.DAT_SUB WHERE DELETED='t')
)


,ACTIVE AS
(
SELECT PAGS.vID
      ,PAGS.SITENUM
	  ,PAGS.SUBNUM
	  ,PAGS.VISNAME
	  ,PAGS.PAGENAME
	  ,PAGS.DELETED 
FROM ZELTA_GPP_TEST.dbo.DAT_PAGS PAGS INNER JOIN DE ON DE.VID=PAGS.VID
WHERE PAGS.PAGENAME='Visit Information' AND
PAGS.DELETED='f'
)


SELECT DE.vID
      ,DE.SiteID
	  ,DE.SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,DE.VisitSeq
	  ,DE.VisitDate
	  ,DE.DEcompletion
	  ,CAST(DATEDIFF(d,DE.VisitDate, DE.DEcompletion) AS decimal(6,0)) AS DifferenceInDays
FROM DE
WHERE RowNum=1
and DE.VisitDate IS NOT NULL
and DE.SubjectID IN (SELECT ACTIVE.SUBNUM FROM ACTIVE)
--ORDER BY SiteID, SubjectID, VisitDate

GO
