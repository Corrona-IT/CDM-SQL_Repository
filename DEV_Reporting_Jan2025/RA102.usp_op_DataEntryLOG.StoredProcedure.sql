USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_DataEntryLOG]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 3/9/2018
-- Description:	Procedure for Data Entry Lag Table
-- =================================================

CREATE PROCEDURE [RA102].[usp_op_DataEntryLOG] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


/**First entry page, date and entered by**/

IF OBJECT_ID('tempdb..#DE') IS NOT NULL BEGIN DROP TABLE #DE END

SELECT APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,VIS.VISITDATE
	  ,CAST(APGS.DATALMDT AS date) AS FirstEntry
	  ,APGS.PAGELMBY AS ModifiedBy
INTO #DE
FROM MERGE_RA_Japan.staging.DAT_APGS APGS
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (9997, 9998, 9999)
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
AND APGS.SUBID NOT IN (SELECT SUBID FROM MERGE_RA_Japan.dbo.DAT_SUB WHERE DELETED='t')
AND APGS.PAGELMBY='Sanchez, Andy'
AND APGS.DATALMDT >= '2023-01-01'

--SELECT * FROM #DE ORDER BY SiteID, SubjectID, VisitDate, VisitType, PageName

/**Get active pages**/

IF OBJECT_ID('tempdb..#ACTIVE') IS NOT NULL BEGIN DROP TABLE #ACTIVE END

SELECT PAGS.vID
      ,PAGS.SITENUM AS SiteID
	  ,PAGS.SUBNUM AS SubjectID
	  ,PAGS.SUBID
	  ,PAGS.VISNAME AS VisitType
	  ,PAGS.PAGENAME AS PageName
	  ,PAGS.PAGELMBY AS ModifiedBy

INTO #ACTIVE
FROM MERGE_RA_Japan.staging.DAT_PAGS PAGS 
INNER JOIN #DE DE ON DE.vID=PAGS.vID
AND PAGS.DELETED='f'
AND ModifiedBy='Sanchez, Andy'
AND DATALMDT >= '2023-01-01'

--SELECT * FROM #ACTIVE ORDER BY SiteID, SubjectID, VisitDate, VisitType, PageName


/*****Add Row Number to remove duplicates caused by change of SubjectID*****/

IF OBJECT_ID('tempdb.dbo.#Listing') IS NOT NULL BEGIN DROP TABLE #Listing END

SELECT DISTINCT DE.vID
      ,DE.SiteID
	  ,DE.SUBID
	  ,DE.SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,DE.VisitDate
	  ,DE.FirstEntry
	  ,DE.ModifiedBy

INTO #Listing
FROM #DE DE 
WHERE DE.VisitDate IS NOT NULL
AND DE.ModifiedBy='Sanchez, Andy'
AND DE.PageName IN (SELECT PageName FROM #ACTIVE A WHERE A.vID=DE.vID and A.PageName=DE.PageName)
AND DE.FirstEntry BETWEEN '2023-01-01' AND '2023-03-31'
--select * from #Listing order by SiteID, SubjectID, VisitDate, PageName

IF OBJECT_ID('tempdb.dbo.#PagesEntered') IS NOT NULL BEGIN DROP TABLE #DataEntryLag END

SELECT DISTINCT SiteID
	  ,SubjectID
	  ,PageName
	  ,VisitType
	  ,VisitDate
	  ,FirstEntry
	  ,ModifiedBy

INTO #PagesEntered
FROM #Listing
WHERE FirstEntry BETWEEN '2023-01-01' AND '2023-03-31'
ORDER BY SiteID, SubjectID, VISITDATE, PageName



SELECT DISTINCT PageName,
	   COUNT(PageName) AS NbrofPages,
	   ModifiedBy
FROM #Listing
GROUP BY PageName, ModifiedBy


END



GO
