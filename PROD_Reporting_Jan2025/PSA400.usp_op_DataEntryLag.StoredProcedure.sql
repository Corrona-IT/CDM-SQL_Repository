USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_DataEntryLag]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 3/9/2018
-- Description:	Procedure for Data Entry Lag Table
-- =================================================

CREATE PROCEDURE [PSA400].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSA400].[t_DataEntryLag]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](25) NULL,
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


IF OBJECT_ID('tempdb..#Subjects') IS NOT NULL BEGIN DROP TABLE #Subjects END

SELECT SITENUM AS SiteID
      ,CAST(SUBNUM AS nvarchar) AS SubjectID
	  ,SUBID

INTO #Subjects

FROM [MERGE_SPA].[dbo].[DAT_SUB]
WHERE SITENUM NOT IN (99997, 99998, 99999)

--SELECT * FROM #Subjects ORDER BY SiteID DESC


IF OBJECT_ID('tempdb..#DE') IS NOT NULL BEGIN DROP TABLE #DE END

SELECT RowNum
      ,vID
	  ,SiteID
	  ,SubjectID
	  ,CAST(SUBID AS nvarchar) AS SUBID
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
	  ,VIS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,VIS.VIR_3_1000_DEC AS DataCollectionType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,CAST(APGS.DATALMDT AS date) AS FirstEntry
	  ,APGS.DELETED AS Deleted

FROM MERGE_SPA.staging.DAT_APGS APGS
LEFT JOIN MERGE_SPA.staging.VS_01 VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (99997, 99998, 99999)
AND APGS.PAGENAME='Date of visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
AND APGS.SUBID NOT IN (SELECT SUBID FROM MERGE_SPA.dbo.DAT_SUB WHERE DELETED='t')
) A WHERE RowNum=1

--SELECT * FROM #DE ORDER BY SiteID DESC


IF OBJECT_ID('tempdb..#ACTIVE') IS NOT NULL BEGIN DROP TABLE #ACTIVE END

SELECT PAGS.vID
      ,PAGS.SITENUM AS SiteID
	  ,S.SubjectID
	  ,PAGS.SUBID
	  ,PAGS.VISNAME AS VisitType
	  ,PAGS.PAGENAME AS PageName
	  ,PAGS.DELETED AS Deleted

INTO #ACTIVE

FROM MERGE_SPA.staging.DAT_PAGS PAGS
JOIN #Subjects S ON cast(S.SUBID AS nvarchar)=CAST(PAGS.SUBID AS nvarchar)
WHERE PAGS.PAGENAME='Date of visit'
AND PAGS.DELETED='f'
AND PAGS.SITENUM NOT IN (99997, 99998, 99999)



IF OBJECT_ID('tempdb..#DataEntryLag') IS NOT NULL BEGIN DROP TABLE #DataEntryLag END

SELECT DISTINCT CAST(ACTIVE.vID AS bigint) as vID
      ,CAST(S.SiteID AS int) AS SiteID
	  ,S.SubjectID AS SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,DE.DataCollectionType
	  ,CAST(DE.VisitDate AS date) AS VisitDate
	  ,CAST(DE.FirstEntry AS date) AS FirstEntry
	  ,CAST(DATEDIFF(d,DE.VisitDate, DE.FirstEntry) AS decimal(6,0)) AS DifferenceInDays
	  ,(SELECT MIN(VisitDate) FROM #DE WHERE VisitDate>'2012-09-01') AS EarliestVisitDate
	  ,(SELECT MIN(FirstEntry) FROM #DE) AS EarliestEntryDate
	  ,ROW_NUMBER() OVER(PARTITION BY ACTIVE.vID ORDER BY S.SiteID, S.SubjectID, DE.VisitDate, DE.FirstEntry) AS RowNum

INTO #DataEntryLag

FROM #ACTIVE ACTIVE
JOIN #DE DE ON DE.vID=ACTIVE.vID
LEFT JOIN #Subjects S ON CAST(S.SUBID AS nvarchar)=CAST(ACTIVE.SUBID AS nvarchar)
WHERE DE.VisitDate IS NOT NULL

TRUNCATE TABLE [Reporting].[PSA400].[t_DataEntryLag]

INSERT INTO [Reporting].[PSA400].[t_DataEntryLag] 
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

SELECT vID
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

FROM #DataEntryLag DEL
WHERE RowNum=1
ORDER BY SiteID, SubjectID, VisitDate


END

--SELECT * FROM [Reporting].[PSA400].[t_DataEntryLag]

GO
