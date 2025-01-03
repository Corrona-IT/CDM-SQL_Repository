USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_DurationBetweenSubVisits]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [NMO750].[v_op_DurationBetweenSubVisits] AS


SELECT SiteID,
       SFSiteStatus,
	   SubjectID,
	   VisitType,
	   VisitSequence,
	   VisitDate,
	   DATEDIFF(DAY, PrevVisitDate, VisitDate) AS DaysSincePrevVisit
FROM
(
SELECT SiteID, 
       SFSiteStatus,
	   SubjectID,
	   CASE WHEN VisitType='Follow-up' THEN CONCAT('FUV', '-', VisitSequence)
	   ELSE VisitType
	   END AS VisitType,
	   VisitSequence,
	   VisitDate,
	   LAG (VisitDate) OVER (PARTITION BY SiteID, SubjectID ORDER BY VisitDate) AS PrevVisitDate

FROM [NMO750].[t_op_VisitLog] VL
WHERE SiteID NOT IN (1440, 9999, 9998, 9997)
) P


--ORDER BY SiteID, SubjectID, VisitDate



GO
