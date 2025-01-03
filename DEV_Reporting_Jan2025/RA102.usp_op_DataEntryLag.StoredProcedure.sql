USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_DataEntryLag]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =======================================================
-- Author:		Kaye Mowrey
-- Create date: 3/9/2018
-- Description:	Procedure for RA 102 Data Entry Lag Table
-- =======================================================

CREATE PROCEDURE [RA102].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA102].[t_DataEntryLag]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,

);

*/


TRUNCATE TABLE [Reporting].[RA102].[t_DataEntryLag]


if object_id('tempdb..#DE') is not null begin drop table #DE end


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
	  
INTO #DE

FROM MERGE_RA_Japan.staging.DAT_APGS APGS
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (9997, 9998, 9999)
AND APGS.PAGENAME='Date of visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.DATALMDT IS NOT NULL
AND APGS.SUBID NOT IN (SELECT SUBID FROM MERGE_RA_Japan.dbo.DAT_SUB WHERE DELETED='t')


		
if object_id('tempdb..#ACTIVE') is not null begin drop table #ACTIVE end

SELECT PAGS.vID
      ,PAGS.SITENUM
	  ,PAGS.SUBNUM AS SubjectID
	  ,PAGS.SUBID
	  ,PAGS.VISNAME
	  ,PAGS.PAGENAME
	  ,PAGS.DELETED 

INTO #ACTIVE

FROM MERGE_RA_Japan.staging.DAT_PAGS PAGS INNER JOIN #DE DE ON DE.VID=PAGS.VID
WHERE PAGS.PAGENAME='Date of visit'
AND PAGS.DELETED='f'




insert into [Reporting].[RA102].[t_DataEntryLag] 
(
    [vID],
	[SiteID],
	[SubjectID],
	[PageName],
	[VisitType],
	[VisitDate],
	[FirstEntry],
	[DifferenceInDays]

)

SELECT DISTINCT
       CAST(DE.vID AS bigint) as vID
      ,CAST(DE.SiteID AS int) AS SiteID
	  ,CAST(A.SubjectID AS bigint) AS SubjectID
	  ,DE.PageName
	  ,DE.VisitType
	  ,CAST(DE.VisitDate AS date) AS VisitDate
	  ,CAST(DE.FirstEntry AS date) AS FirstEntry
	  ,CAST(DATEDIFF(d,DE.VisitDate, DE.FirstEntry) AS decimal(6,0)) AS DifferenceInDays

FROM #DE DE
LEFT JOIN #ACTIVE A ON A.SUBID=DE.SUBID
WHERE RowNum=1
AND DE.VisitDate IS NOT NULL
AND DE.SUBID IN (SELECT SUBID FROM #ACTIVE ACTIVE)

END



GO
