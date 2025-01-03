USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_SiteSummary]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [IBD600].[v_op_SiteSummary] AS


SELECT DISTINCT SiteID
      ,SiteStatus
	  ,COUNT(Distinct SubjectID) AS SubjectsEnrolled
	  ,SUM(CASE WHEN VisitStatus='Not Yet Due' THEN 1 ELSE 0 END) AS NotDueCount
	  ,SUM(CASE WHEN VisitStatus='Due Now' THEN 1 ELSE 0 END) AS NowDueCount
	  ,SUM(CASE WHEN VisitStatus='Overdue' THEN 1 ELSE 0 END) AS OVERDUECount

FROM [Reporting].[IBD600].[t_op_PatientVisitTracker]
WHERE ISNULL([EnrollmentDate], '')<>''

GROUP BY SiteID, SiteStatus
---ORDER BY SiteID, SubjectID, rownum



GO
