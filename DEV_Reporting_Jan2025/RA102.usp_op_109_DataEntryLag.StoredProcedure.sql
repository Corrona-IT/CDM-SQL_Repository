USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_109_DataEntryLag]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 3/9/2018
-- Description:	Procedure for Data Entry Lag Table
-- =================================================

CREATE PROCEDURE [RA102].[usp_op_109_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA102].[t_op_109_DataEntryLag]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
);

*/


TRUNCATE TABLE [RA102].[t_op_109_DataEntryLag]

if object_id('tempdb..#Subjects') is not null begin drop table #Subjects end

SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,SUBID

INTO #Subjects

FROM [MERGE_RA_Japan].[dbo].[DAT_SUB]
WHERE SITENUM NOT IN (9997, 9998, 9999)

--SELECT * FROM Subjects


if object_id('tempdb..#DE') is not null begin drop table #DE end

SELECT Rownum
      ,vID
	  ,SiteID
	  ,SubjectID
	  ,SUBID
	  ,PageName
	  ,VisitType
	  ,VisitDate
	  ,FirstEntry
	  ,Deleted

INTO #DE

FROM
(
SELECT ROW_NUMBER() OVER (PARTITION BY APGS.VID ORDER BY APGS.SITENUM, APGS.SUBNUM, APGS.DATALMDT) AS RowNum
      ,APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,CAST(APGS.DATALMDT AS date) AS FirstEntry
	  ,APGS.DELETED AS Deleted

FROM MERGE_RA_Japan.staging.DAT_APGS APGS
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (9997, 9998, 9999)
AND APGS.PAGENAME='Date of visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
AND APGS.subid NOT IN (SELECT SUBID FROM MERGE_RA_Japan.dbo.DAT_SUB WHERE DELETED='t')
) A WHERE Rownum=1

		
if object_id('tempdb..#ACTIVE') is not null begin drop table #ACTIVE end

SELECT PAGS.vID
      ,PAGS.SITENUM AS SiteID
	  ,PAGS.SUBNUM AS SubjectID
	  ,PAGS.SUBID
	  ,PAGS.VISNAME AS VisitType
	  ,PAGS.PAGENAME AS PageName
	  ,PAGS.DELETED 

INTO #ACTIVE

FROM MERGE_RA_Japan.staging.DAT_PAGS PAGS 
INNER JOIN #DE DE ON DE.VID=PAGS.VID
WHERE PAGS.PAGENAME='Date of visit'
AND PAGS.DELETED='f'



/*****Add Row Number to remove duplicates caused by change of SubjectID*****/

IF OBJECT_ID('tempdb.dbo.#DataEntryLag') IS NOT NULL BEGIN DROP TABLE #DataEntryLag END

SELECT DISTINCT CAST(ACTIVE.vID AS bigint) as vID
      ,CAST(S.SiteID AS int) AS SiteID
	  ,CAST(S.SubjectID AS bigint) AS SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,CAST(DE.VisitDate AS date) AS VisitDate
	  ,CAST(DE.FirstEntry AS date) AS FirstEntry
	  ,CAST(DATEDIFF(d,DE.VisitDate, DE.FirstEntry) AS decimal(6,0)) AS DifferenceInDays
	  ,(SELECT MIN(VisitDate) FROM #DE) AS EarliestVisitDate
	  ,(SELECT MIN(FirstEntry) FROM #DE) AS EarliestEntryDate
	  ,ROW_NUMBER() OVER(PARTITION BY ACTIVE.vID ORDER BY S.SiteID, S.SubjectID, DE.VisitDate, DE.FirstEntry) AS RowNum

INTO #DataEntryLag

FROM #ACTIVE ACTIVE
LEFT JOIN #DE DE ON DE.vID=ACTIVE.vID 
LEFT JOIN #Subjects S ON S.SUBID=ACTIVE.SUBID
AND DE.VisitDate IS NOT NULL



insert into [RA102].[t_op_109_DataEntryLag] 
(
    [vID],
	[SiteID],
	[SubjectID],
	[PageName],
	[VisitType],
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
	  ,VisitDate
	  ,FirstEntry
	  ,DifferenceInDays
	  ,EarliestVisitDate
	  ,EarliestEntryDate

FROM #DataEntryLag
WHERE RowNum=1


END



GO
