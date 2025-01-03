USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_128_DataEntryCompletion]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- ============================================================
-- Author:		Kaye Mowrey
-- Create date: 5/3/2018
-- Description:	Procedure for RA102 Data Entry Completion Table
-- ============================================================

CREATE PROCEDURE [RA102].[usp_op_128_DataEntryCompletion] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA102].[t_DataEntryCompletion]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[PageName] [varchar](500) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NOT NULL,
	[CompletionInMinutes] [int] NULL,
	[CompletionInHours] [dec] (20,2) NULL

);

*/


TRUNCATE TABLE [Reporting].[RA102].[t_DataEntryCompletion]


/************GET Created Date************/
if object_id('tempdb.dbo.#DE1') is not null begin drop table #DE1 end


SELECT APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,MIN(APGS.PAGELMDT) AS CreatedDate

INTO #DE1

FROM [MERGE_RA_Japan].[staging].[DAT_APGS] APGS
LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (9997, 9998, 9999)
AND ISNUMERIC(APGS.SUBNUM)=1
AND APGS.PAGENAME='Date of visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.PAGELMDT IS NOT NULL
AND APGS.STATUSID=0
GROUP BY APGS.vID, APGS.SITENUM, APGS.SUBNUM, APGS.SUBID, APGS.PAGENAME, APGS.VISNAME, VIS.VISITDATE


/************GET Completed Date************/

if object_id('tempdb.dbo.#DE2') is not null begin drop table #DE2 end


SELECT APGS.vID AS vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,APGS.VISNAME AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,MIN(APGS.PAGELMDT) AS CompletionDate

INTO #DE2

FROM [MERGE_RA_Japan].[staging].[DAT_APGS] APGS
LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (9997, 9998, 9999)
AND ISNUMERIC(APGS.SUBNUM)=1
AND APGS.PAGENAME='Date of visit'
AND APGS.STATUSID=10
AND VIS.VISITDATE IS NOT NULL
AND APGS.PAGELMDT IS NOT NULL
GROUP BY APGS.vID, APGS.SITENUM, APGS.SUBNUM, APGS.SUBID, APGS.PAGENAME, APGS.VISNAME, VIS.VISITDATE


/************GET SubjectIDs of Active Subjects************/
if object_id('tempdb.dbo.#ACTIVE') is not null begin drop table #ACTIVE end

SELECT CONVERT(bigint, PAGS.vID) AS vID
      ,PAGS.SITENUM
	  ,CONVERT(bigint, PAGS.SUBNUM) AS SubjectID
	  ,PAGS.SUBID
	  ,PAGS.VISNAME
	  ,PAGS.PAGENAME
	  ,PAGS.DELETED 

INTO #ACTIVE

FROM [MERGE_RA_Japan].[staging].[DAT_PAGS] PAGS INNER JOIN #DE1 DE1 ON DE1.VID=PAGS.VID
WHERE PAGS.PAGENAME='Date of visit'
AND PAGS.DELETED='f'
AND PAGS.SITENUM NOT IN (9997, 9998, 9999)
AND ISNUMERIC(PAGS.SUBNUM)=1

/************GET CompletionInMinutes************/
if OBJECT_ID('tempdb.dbo.#compmin') is not null begin drop table #compmin end

SELECT DISTINCT
       CAST(DE1.vID AS bigint) as vID
      ,CAST(DE1.SiteID AS int) AS SiteID
	  ,CAST(DE1.SubjectID AS bigint) AS SubjectID
	  ,DE1.SUBID
	  ,DE1.PageName
	  ,DE1.VisitType
	  ,CAST(DE1.VisitDate AS date) AS VisitDate
	  ,CAST(DE1.CreatedDate AS datetime) AS CreatedDate
	  ,CAST(DE2.CompletionDate AS datetime) AS CompletionDate
	  ,DATEDIFF(MI,DE1.CreatedDate, DE2.CompletionDate) AS CompletionInMinutes

INTO #compmin

FROM #DE1 DE1
LEFT JOIN #DE2 DE2 ON DE2.VID=DE1.VID
WHERE DE1.VisitDate IS NOT NULL
AND DE1.SUBID IN (SELECT SUBID FROM #ACTIVE ACTIVE)


/*****Add Row Number to remove duplicates caused by changed SubjectIDs*****/
IF OBJECT_ID('tempdb.dbo.#DataEntryCompletion') IS NOT NULL BEGIN DROP TABLE #DataEntryCompletion END 

SELECT DISTINCT
       CAST(C.vID AS bigint) as vID
      ,CAST(C.SiteID AS int) AS SiteID
	  ,CAST(A.SubjectID AS bigint) AS SubjectID
	  ,C.PageName
	  ,C.VisitType
	  ,CAST(C.VisitDate AS date) AS VisitDate
	  ,CAST(C.CreatedDate AS datetime) AS CreatedDate
	  ,CAST(C.CompletionDate AS datetime) AS CompletionDate
	  ,C.[CompletionInMinutes]
	  ,CAST(C.[CompletionInMinutes] as decimal(20,2))/60 AS [CompletionInHours]
	  ,ROW_NUMBER() OVER(PARTITION BY C.vID ORDER BY C.SiteID, A.SubjectID, C.VisitDate, C.CreatedDate, C.CompletionDate) AS RowNum

INTO #DataEntryCompletion

FROM #compmin C 
LEFT JOIN #ACTIVE A ON A.SUBID=C.SUBID
WHERE (CreatedDate IS NOT NULL AND CompletionDate IS NOT NULL)



INSERT INTO [Reporting].[RA102].[t_DataEntryCompletion] 
(
    [vID],
	[SiteID],
	[SubjectID],
	[PageName],
	[VisitType],
	[VisitDate],
	[CreatedDate],
	[CompletionDate],
	[CompletionInMinutes],
	[CompletionInHours]

)


SELECT DISTINCT
       vID
      ,SiteID
	  ,SubjectID
	  ,PageName
	  ,VisitType
	  ,VisitDate
	  ,CreatedDate
	  ,CompletionDate
	  ,[CompletionInMinutes]
	  ,[CompletionInHours]

FROM #DataEntryCompletion
WHERE RowNum=1


END










GO
