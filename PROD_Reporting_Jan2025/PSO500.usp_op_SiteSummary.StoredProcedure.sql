USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_SiteSummary]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- Description:	Procedure to create table for SiteSummary page 2 of new Visit Planning SMR Report
-- ===================================================================================================

CREATE PROCEDURE [PSO500].[usp_op_SiteSummary] AS


/*
*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSO500].[t_op_SiteSummary]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NOT NULL,
	[SubjectsEnrolled] [bigint] NOT NULL,
	[NotDueCount] [bigint] NULL,
	[NowDueCount] [bigint] NULL,
	[OVERDUE1Count] [bigint] NULL,
	[OVERDUE2Count] [bigint] NULL,
	[OVERDUE3Count] [bigint] NULL

);


*/


TRUNCATE TABLE [Reporting].[PSO500].[t_op_SiteSummary];


IF OBJECT_ID('tempdb..#SiteSummary') IS NOT NULL BEGIN DROP TABLE #SiteSummary END


SELECT VPLL.SiteID
      ,CASE WHEN ISNULL(SL.SiteStatus, '')='' THEN 'Active'
	   ELSE SL.SiteStatus
	   END AS SiteStatus
      ,COUNT(Distinct SubjectID) AS SubjectsEnrolled
      ,SUM(CASE WHEN VPLL.VisitStatus='Not Yet Due' THEN 1 ELSE 0 END) AS NotDueCount
	  ,SUM(CASE WHEN VPLL.VisitStatus='Due Now' THEN 1 ELSE 0 END) AS NowDueCount
	  ,SUM(CASE WHEN VPLL.VisitStatus='Overdue1' THEN 1 ELSE 0 END) AS OVERDUE1Count
	  ,SUM(CASE WHEN VPLL.VisitStatus='Overdue2' THEN 1 ELSE 0 END) AS OVERDUE2Count
	  ,SUM(CASE WHEN VPLL.[VisitStatusforSites]='Overdue3' THEN 1 ELSE 0 END) AS OVERDUE3Count

INTO #SiteSummary

FROM [PSO500].[v_op_VisitPlanningLineListing_v2] VPLL
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SL ON SL.SiteID=VPLL.SiteID
GROUP BY VPLL.SiteID, sl.SiteStatus


INSERT INTO [Reporting].[PSO500].[t_op_SiteSummary]
(
	[SiteID],
	[SiteStatus],
	[SubjectsEnrolled],
	[NotDueCount],
	[NowDueCount],
	[OVERDUE1Count],
	[OVERDUE2Count],
	[OVERDUE3Count]

)

SELECT CAST(SiteID AS int) AS SiteID
      ,SiteStatus
	  ,SubjectsEnrolled
	  ,NotDueCount
	  ,NowDueCount
	  ,OVERDUE1Count
	  ,OVERDUE2Count
	  ,OVERDUE3Count
FROM #SiteSummary SS



END










GO
