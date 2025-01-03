USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_126_DataEntryCompletion]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- ======================================================
-- Author:		Kaye Mowrey
-- Create date: 5/3/2018
-- Description:	Procedure for Data Entry Completion Table
-- ======================================================

CREATE PROCEDURE [IBD600].[usp_op_126_DataEntryCompletion] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_DataEntryCompletion]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar] (10) NULL,
	[SubjectID] bigint NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletedDate] [datetime] NOT NULL,
	[CompletionInMinutes] [Dec] (20,2) NULL,
	[CompletionInHours] [dec] (20,2) NULL,

);

*/


TRUNCATE TABLE [Reporting].[IBD600].[t_DataEntryCompletion]

/************GET Created Date************/
IF OBJECT_ID('tempdb..#DE1') IS NOT NULL BEGIN DROP TABLE #DE1 END


SELECT ROW_NUMBER() OVER (PARTITION BY DP.VID, DP.VISNAME, VISIT.VISITDATE 
                          ORDER BY DP.SITENUM, DP.SUBNUM, VISIT.VISITDATE, DP.DATALMDT) AS ROWNUM
      ,DP.vID
      ,CAST(DP.SITENUM AS int) AS SiteID
	  ,SS.SiteStatus
	  ,DP.SUBNUM AS SubjectID
	  ,DP.SUBID
	  ,DP.VISNAME AS VisitType
	  ,DP.PAGENAME
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,DP.PAGELMDT AS CreatedDate

INTO #DE1

FROM [MERGE_IBD].[staging].[DAT_APGS] DP
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=DP.SITENUM
LEFT JOIN [MERGE_IBD].[staging].[VISIT] ON VISIT.vID=DP.vID
WHERE DP.VISNAME IN ('Enrollment', 'Follow-Up')
AND DP.PAGENAME = 'Visit Date'
AND DP.DELETED='f'
and DP.PAGELMDT IS NOT NULL



/************GET Completed Date************/

if object_id('tempdb..#DE2') is not null begin drop table #DE2 end

SELECT ROW_NUMBER() OVER (PARTITION BY DP.VID, DP.VISNAME, VISIT.VISITDATE 
                          ORDER BY DP.SITENUM, DP.SUBNUM, VISIT.VISITDATE, DP.DATALMDT) AS ROWNUM
      ,DP.vID
      ,CAST(DP.SITENUM AS int) AS SiteID
	  ,SS.SiteStatus
	  ,DP.SUBNUM AS SubjectID
	  ,DP.SUBID
	  ,DP.VISNAME AS VisitType
	  ,DP.PAGENAME
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,DP.PAGELMDT AS CompletedDate

INTO #DE2

FROM [MERGE_IBD].[staging].[DAT_APGS] DP
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=DP.SITENUM
LEFT JOIN [MERGE_IBD].[staging].[VISIT] ON VISIT.vID=DP.vID
WHERE DP.VISNAME IN ('Enrollment', 'Follow-Up')
AND DP.PAGENAME = 'Visit Completion'
AND DP.DELETED='f'
and DP.PAGELMDT IS NOT NULL


/************GET SubjectIDs of Active Subjects************/
if object_id('tempdb..#ACTIVE') is not null begin drop table #ACTIVE end

SELECT vID
      ,CAST(SITENUM AS int) as SiteID
	  ,SS.SiteStatus
	  ,SUBNUM AS SubjectID
	  ,SUBID

INTO #ACTIVE

FROM [MERGE_IBD].[staging].[DAT_PAGS] DP
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=DP.SITENUM WHERE DP.DELETED='f'


/************GET CompletionInMinutes************/
if OBJECT_ID('tempdb..#compmin') is not null begin drop table #compmin end

SELECT DISTINCT
       CAST(DE1.vID AS bigint) as vID
      ,CAST(DE1.SiteID AS int) AS SiteID
	  ,DE1.SiteStatus
	  ,DE1.SubjectID AS SubjectID
	  ,DE1.SUBID
	  ,DE1.VisitType
	  ,CAST(DE1.VisitDate AS date) AS VisitDate
	  ,CAST(DE1.CreatedDate AS datetime) AS CreatedDate
	  ,CAST(DE2.CompletedDate AS datetime) AS CompletionDate
	  ,DATEDIFF(MI,DE1.CreatedDate, DE2.CompletedDate) AS CompletionInMinutes

INTO #compmin

FROM #DE1 DE1
LEFT JOIN #DE2 DE2 ON DE2.VID=DE1.VID
WHERE DE1.VisitDate IS NOT NULL
AND DE2.CompletedDate IS NOT NULL
AND DE1.SUBID IN (SELECT SUBID FROM #ACTIVE ACTIVE)
AND DE1.ROWNUM=1 AND DE2.ROWNUM=1

/*****Add Row Number to eliminate duplicates caused by changed SubjectIDs*****/

IF OBJECT_ID('tempdb..#DataEntryLag') IS NOT NULL BEGIN DROP TABLE #DataEntryLag END

SELECT DISTINCT
       CAST(C.vID AS bigint) as vID
      ,CAST(C.SiteID AS int) AS SiteID
	  ,A.SiteStatus
	  ,A.SubjectID AS SubjectID
	  ,C.VisitType
	  ,CAST(C.VisitDate AS date) AS VisitDate
	  ,CAST(C.CreatedDate AS datetime) AS CreatedDate
	  ,CAST(C.CompletionDate AS datetime) AS CompletionDate
	  ,C.[CompletionInMinutes]
	  ,CAST(C.[CompletionInMinutes] as decimal(20,2))/60 AS [CompletionInHours]
	  ,ROW_NUMBER() OVER(PARTITION BY C.vID ORDER BY C.SiteID, A.SubjectID, C.VisitDate, C.CreatedDate) AS RowNum

INTO #DataEntryLag

FROM #ACTIVE A
INNER JOIN #compmin C ON A.SUBID=C.SUBID
--SELECT * FROM #DataEntryLag

INSERT INTO [Reporting].[IBD600].[t_DataEntryCompletion] 
(
    [vID],
	[SiteID],
	[SiteStatus],
	[SubjectID],
	[VisitType],
	[VisitDate],
	[CreatedDate],
	[CompletedDate],
	[CompletionInMinutes],
	[CompletionInHours]

)


SELECT DISTINCT
       vID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,CreatedDate
	  ,CompletionDate
	  ,[CompletionInMinutes]
	  ,[CompletionInHours]

FROM #DataEntryLag
WHERE RowNum=1



END





GO
