USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_127_DataEntryCompletion]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- ======================================================
-- Author:		Kaye Mowrey
-- Create date: 5/3/2018
-- Description:	Procedure for Data Entry Completion Table
-- ======================================================

CREATE PROCEDURE [PSA400].[usp_op_127_DataEntryCompletion] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSA400].[t_DataEntryCompletion]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[PageName] [varchar] (500) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NOT NULL,
	[CompletionInMinutes] [Dec] (20,2) NULL,
	[CompletionInHours] [dec] (20,2) NULL,

);

*/


TRUNCATE TABLE [Reporting].[PSA400].[t_DataEntryCompletion]

/************GET Created Date************/
IF OBJECT_ID('tempdb..#DE1') IS NOT NULL BEGIN DROP TABLE #DE1 end


SELECT APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,CASE WHEN APGS.VISNAME LIKE 'Enroll%' THEN 'Enrollment Visit'
	   WHEN APGS.VISNAME LIKE '%Follow%' THEN 'Follow Up Visit'
	   ELSE APGS.VISNAME
	   END AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,MIN(APGS.PAGELMDT) AS CreatedDate

INTO #DE1

FROM MERGE_SPA.staging.DAT_APGS APGS
LEFT JOIN MERGE_SPA.staging.VS_01 VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (99997, 99998, 99999)
AND APGS.PAGENAME='Date of Visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.PAGELMDT IS NOT NULL
AND APGS.STATUSID=0
GROUP BY APGS.vID, APGS.SITENUM, APGS.SUBNUM, APGS.SUBID, APGS.PAGENAME, APGS.VISNAME, VIS.VISITDATE



/************GET Completed Date************/

IF OBJECT_ID('tempdb..#DE2') IS NOT NULL BEGIN DROP TABLE #DE2 end


SELECT APGS.vID
      ,APGS.SITENUM AS SiteID
	  ,APGS.SUBNUM AS SubjectID
	  ,APGS.SUBID
	  ,APGS.PAGENAME AS PageName
	  ,CASE WHEN APGS.VISNAME LIKE 'Enroll%' THEN 'Enrollment Visit'
	   WHEN APGS.VISNAME LIKE '%Follow%' THEN 'Follow Up Visit'
	   ELSE APGS.VISNAME
	   END AS VisitType
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,MIN(APGS.PAGELMDT) AS CompletionDate

INTO #DE2

FROM MERGE_SPA.staging.DAT_APGS APGS
LEFT JOIN MERGE_SPA.staging.VS_01 VIS ON APGS.VID=VIS.VID
WHERE APGS.SITENUM NOT IN (99997, 99998, 99999)
AND APGS.PAGENAME='Date of Visit'
AND VIS.VISITDATE IS NOT NULL
AND APGS.PAGELMDT IS NOT NULL
AND APGS.STATUSID=10
GROUP BY APGS.vID, APGS.SITENUM, APGS.SUBNUM, APGS.SUBID, APGS.PAGENAME, APGS.VISNAME, VIS.VISITDATE


/************GET SubjectIDs of Active Subjects************/
IF OBJECT_ID('tempdb..#ACTIVE') IS NOT NULL BEGIN DROP TABLE #ACTIVE end

SELECT PAGS.vID
      ,PAGS.SITENUM
	  ,PAGS.SUBNUM AS SubjectID
	  ,PAGS.SUBID
	  ,PAGS.VISNAME
	  ,PAGS.PAGENAME
	  ,PAGS.DELETED 

INTO #ACTIVE

FROM MERGE_SPA.staging.DAT_PAGS PAGS INNER JOIN #DE1 DE ON DE.VID=PAGS.VID
WHERE PAGS.PAGENAME='Date of Visit'
AND PAGS.DELETED='f'
AND PAGS.SITENUM NOT IN (99997, 99998, 99999)


/************GET CompletionInMinutes************/
IF OBJECT_ID('tempdb.dbo.#compmin') IS NOT NULL BEGIN DROP TABLE #compmin end

SELECT DISTINCT
       CAST(DE1.vID AS bigint) as vID
      ,CAST(DE1.SiteID AS int) AS SiteID
	  ,DE1.SubjectID AS SubjectID
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
AND DE1.CreatedDate IS NOT NULL
AND DE2.CompletionDate IS NOT NULL
AND ISNUMERIC(DE1.SubjectID)=1
AND DE1.SUBID IN (SELECT ACTIVE.SUBID FROM #ACTIVE ACTIVE)


/*****Group the results so the first entry prior to change of subjectid are returned*****/

IF OBJECT_ID('tempdb.dbo.#DECompletion') IS NOT NULL BEGIN DROP TABLE #DECompletion end

SELECT DISTINCT
       CAST(C.vID AS bigint) as vID
      ,CAST(C.SiteID AS int) AS SiteID
	  ,CAST(A.SubjectID AS bigint) AS SubjectID
	  ,C.PageName
	  ,C.VisitType
	  ,CAST(C.VisitDate AS date) AS VisitDate
	  ,CAST(C.CreatedDate AS datetime) AS CreatedDate
	  ,CAST(C.CompletionDate AS datetime) AS CompletionDate
	  ,C.[CompletionInMinutes] AS [CompletionInMinutes]
	  ,CAST(C.[CompletionInMinutes] AS decimal(20,2))/60 AS [CompletionInHours]
	  ,ROW_NUMBER() OVER(PARTITION BY C.vID ORDER BY C.SiteID, A.SubjectID, C.VisitDate, C.CreatedDate, C.CompletionDate) AS RowNum

INTO #DECompletion

FROM #ACTIVE A 
INNER JOIN #compmin C ON A.SUBID=C.SUBID

--SELECT * FROM #DECompletion  order by siteid, subjectid, visitdate, rownum

INSERT INTO [Reporting].[PSA400].[t_DataEntryCompletion] 
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

--SELECT * FROM [Reporting].[PSA400].[t_DataEntryCompletion]


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

FROM #DECompletion
WHERE RowNum=1
AND ISNUMERIC(SubjectID)=1

---ORDER BY SiteID, SubjectID, VisitDate


END


GO
