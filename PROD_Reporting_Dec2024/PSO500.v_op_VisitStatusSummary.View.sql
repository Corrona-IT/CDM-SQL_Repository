USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_VisitStatusSummary]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [PSO500].[v_op_VisitStatusSummary] AS

SELECT VPLL.SiteID
      ,CASE WHEN ISNULL(SL.SiteStatus, '')='' THEN 'Active'
	   ELSE SL.SiteStatus
	   END AS SiteStatus
      ,COUNT(Distinct SubjectID) AS SubjectsEnrolled
      ,SUM(CASE WHEN VPLL.VisitStatus='Not Yet Due' THEN 1 ELSE 0 END) AS NotDueCount
	  ,SUM(CASE WHEN VPLL.VisitStatus='Due Now' THEN 1 ELSE 0 END) AS NowDueCount
	  ,SUM(CASE WHEN VPLL.VisitStatus='Overdue' THEN 1 ELSE 0 END) AS OVERDUECount
FROM [PSO500].[v_op_VisitPlanningLineListing_v2] VPLL
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SL ON SL.SiteID=VPLL.SiteID

GROUP BY VPLL.SiteID, sl.SiteStatus



GO
