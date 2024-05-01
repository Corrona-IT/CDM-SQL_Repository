USE [Reporting]
GO
/****** Object:  View [IBD600].[v_DataEntryLag]    Script Date: 5/1/2024 1:26:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [IBD600].[v_DataEntryLag] AS


WITH DE AS
(
SELECT ROW_NUMBER() OVER (PARTITION BY APGS.VID ORDER BY APGS.SITENUM, APGS.SUBNUM, APGS.DATALMDT) AS RowNum
      ,APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,CAST(APGS.DATALMDT AS date) AS FirstEntry
	  ,APGS.DELETED AS Deleted
FROM MERGE_IBD.staging.DAT_APGS APGS
LEFT JOIN MERGE_IBD.staging.VISIT VIS ON APGS.VID=VIS.VID
WHERE APGS.PAGENAME='Visit Date'
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
AND APGS.SUBNUM NOT IN (SELECT SUBNUM FROM MERGE_RA_Japan.dbo.DAT_SUB WHERE DELETED='t')
)


,ACTIVE AS
(
SELECT PAGS.vID
      ,PAGS.SITENUM
	  ,PAGS.SUBNUM
	  ,PAGS.VISNAME
	  ,PAGS.PAGENAME
	  ,PAGS.DELETED 
FROM MERGE_IBD.staging.DAT_PAGS PAGS INNER JOIN DE ON DE.VID=PAGS.VID
WHERE PAGS.PAGENAME='Visit Date'
AND PAGS.DELETED='f'
)


SELECT DE.vID
      ,DE.SiteID
	  ,DE.SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,DE.VisitDate
	  ,DE.FirstEntry
	  ,CAST(DATEDIFF(d,DE.VisitDate, DE.FirstEntry) AS decimal(6,0)) AS DifferenceInDays
FROM DE
WHERE RowNum=1
and DE.VisitDate IS NOT NULL
and DE.SubjectID IN (SELECT ACTIVE.SUBNUM FROM ACTIVE)
---ORDER BY SiteID, SubjectID, VisitDate

GO
