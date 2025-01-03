USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SiteSummary]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [RA100].[v_op_SiteSummary] AS


SELECT DISTINCT SiteID
      ,SiteStatus
	  ,COUNT(Distinct SubjectID) AS SubjectsEnrolled
	  ,SUM(CASE WHEN VisitStatus='Not Yet Due' THEN 1 ELSE 0 END) AS NotDueCount
	  ,SUM(CASE WHEN VisitStatus='Due Now' THEN 1 ELSE 0 END) AS NowDueCount
	  ,SUM(CASE WHEN VisitStatus='Overdue' THEN 1 ELSE 0 END) AS OVERDUECount

FROM [RA100].[t_op_PatientVisitTracker]


GROUP BY SiteID, SiteStatus
---ORDER BY SiteID, SubjectID, rownum



GO
