USE [Reporting]
GO
/****** Object:  View [PSA400].[v_DataEntryLag]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [PSA400].[v_DataEntryLag] AS


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
FROM MERGE_SPA.staging.DAT_APGS APGS
LEFT JOIN MERGE_SPA.staging.VS_01 VIS ON APGS.VID=VIS.VID
INNER JOIN MERGE_SPA.staging.DAT_PAGS PAGS ON PAGS.VID=APGS.VID
WHERE APGS.PAGENAME='Date of visit'
AND PAGS.PAGENAME='Date of visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
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





GO
