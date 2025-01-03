USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_DataEntryLag]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 3/9/2018
-- Description:	Procedure for Data Entry Lag Table
-- =================================================

CREATE PROCEDURE [IBD600].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_DataEntryLag]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [VARCHAR] (15) NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[DataCollectionType] [varchar] (300) NULL,
	[VisitDate] [date] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
);

*/


TRUNCATE TABLE [Reporting].[IBD600].[t_DataEntryLag]


if object_id('tempdb..#DE') is not null begin drop table #DE end

SELECT RowNum
      ,vID
	  ,SiteID
	  ,SubjectID
	  ,SUBID
	  ,PageName
	  ,VisitType
	  ,DataCollectionType
	  ,VisitDate
	  ,FirstEntry
	  ,Deleted

INTO #DE

FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY APGS.VID ORDER BY APGS.SITENUM, APGS.SUBNUM, APGS.DATALMDT) AS RowNum
      ,APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,VIS.VIR_3_1000_DEC AS DataCollectionType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,CAST(APGS.DATALMDT AS date) AS FirstEntry
	  ,APGS.DELETED AS Deleted
FROM MERGE_IBD.staging.DAT_APGS APGS
LEFT JOIN MERGE_IBD.staging.VISIT VIS ON APGS.VID=VIS.VID
WHERE APGS.PAGENAME='Visit Date'
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
AND APGS.SUBID NOT IN (SELECT SUBID FROM MERGE_RA_Japan.dbo.DAT_SUB WHERE DELETED='t')

) A WHERE RowNum=1

--SELECT * FROM #DE
		
if object_id('tempdb..#ACTIVE') is not null begin drop table #ACTIVE end

SELECT PAGS.vID
      ,PAGS.SITENUM AS SiteID
	  ,PAGS.SUBNUM AS SubjectID
	  ,SUBID
	  ,PAGS.VISNAME AS VisitType
	  ,PAGS.PAGENAME AS PageName
	  ,PAGS.DELETED AS Deleted

INTO #ACTIVE

FROM MERGE_IBD.staging.DAT_PAGS PAGS
WHERE PAGS.PAGENAME='Visit Date'
AND PAGS.DELETED='f'

/*****Add row number to remove duplicates caused by change of SubjectID)*****/
if object_id('tempdb.dbo.#DataEntryLag') is not null begin drop table #DataEntryLag end

SELECT DISTINCT 
       CAST(DE.vID AS bigint) as vID
      ,CAST(DE.SiteID AS int) AS SiteID
	  ,A.SubjectID AS SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,DE.DataCollectionType
	  ,CAST(DE.VisitDate AS date) AS VisitDate
	  ,CAST(DE.FirstEntry AS date) AS FirstEntry
	  ,CAST(DATEDIFF(d,DE.VisitDate, DE.FirstEntry) AS decimal(6,0)) AS DifferenceInDays
	  ,(SELECT MIN(VisitDate) FROM #DE WHERE VisitDate>'2012-09-01') AS EarliestVisitDate
	  ,(SELECT MIN(FirstEntry) FROM #DE) AS EarliestEntryDate
	  ,ROW_NUMBER() OVER(PARTITION BY DE.vID ORDER BY DE.SiteID, A.SubjectID, DE.VisitDate, DE.FirstEntry) AS RowNum

INTO #DataEntryLag
FROM #DE DE
INNER JOIN #ACTIVE A ON A.SUBID=DE.SUBID
WHERE DE.VisitDate IS NOT NULL
AND de.FIRSTENTRY is not null
AND DE.SUBID IN (SELECT SUBID FROM #ACTIVE A)
--select * from #DataENtryLag Order by SiteID, SubjectID, VisitDate


INSERT INTO [Reporting].[IBD600].[t_DataEntryLag] 
(
    [vID],
	[SiteID],
	[SubjectID],
	[PageName],
	[VisitType],
	[DataCollectionType],
	[VisitDate],
	[FirstEntry],
	[DifferenceInDays],
	[EarliestVisitDate],
	[EarliestEntryDate]
)


SELECT DISTINCT 
       vID
      ,SiteID
	  ,SubjectID
	  ,PageName
	  ,VisitType
	  ,DataCollectionType
	  ,VisitDate
	  ,FirstEntry
	  ,DifferenceInDays
	  ,EarliestVisitDate
	  ,EarliestEntryDate

FROM #DataEntryLag
ORDER BY SiteID, SubjectID, VisitDate



END







GO
