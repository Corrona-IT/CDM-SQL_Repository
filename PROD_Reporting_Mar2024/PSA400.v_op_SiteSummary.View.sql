USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_SiteSummary]    Script Date: 4/2/2024 11:30:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [PSA400].[v_op_SiteSummary] AS


SELECT DISTINCT SiteID
      ,SiteStatus
	  ,COUNT(Distinct SubjectID) AS SubjectsEnrolled
	  ,SUM(CASE WHEN VisitStatus='Not Yet Due' THEN 1 ELSE 0 END) AS NotDueCount
	  ,SUM(CASE WHEN VisitStatus='Due Now' THEN 1 ELSE 0 END) AS NowDueCount
	  ,SUM(CASE WHEN VisitStatus='Overdue' THEN 1 ELSE 0 END) AS OVERDUECount

FROM [Reporting].[PSA400].[t_op_PatientVisitTracker]
WHERE ISNULL([EnrollmentDate], '')<>''

GROUP BY SiteID, SiteStatus
---ORDER BY SiteID, SubjectID, rownum



GO
