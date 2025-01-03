USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_VisitLog_V4]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE view [RA100].[v_op_VisitLog_V4]  as



WITH 

VLOG AS 
(
SELECT VisitID
	  ,SiteID
      ,SubjectID
	  ,VisitDate
	  ,CASE WHEN VisitType LIKE 'Follow%' THEN 'Follow-Up'
	   ELSE VisitType
	   END AS VisitType
	  ,VisitProviderID AS ProviderID
	  ,VisitSequence
FROM Reporting.RA100.t_op_SubjectVisits
)

SELECT  
	   VisitID
	  ,SiteID
      ,SubjectID
	  ,VisitDate
	  ,VisitType
	  ,ProviderID
	  ,VisitSequence
	  ,CASE 
		WHEN VisitType = 'Exit' THEN 99
		ELSE ROW_NUMBER() OVER (PARTITION BY SubjectID ORDER BY VisitDate) - 1
		END AS CalcVisitSequence
FROM VLOG
WHERE SubjectID IN (SELECT DISTINCT SubjectID FROM VLOG WHERE VisitType = 'Enrollment')
UNION
SELECT
	   VisitID  
	  ,SiteID
      ,SubjectID
	  ,VisitDate
	  ,VisitType
	  ,ProviderID
	  ,VisitSequence
	  ,CASE 
		WHEN VisitType = 'Exit' THEN 99
		ELSE ROW_NUMBER() OVER (PARTITION BY SubjectID ORDER BY VisitDate) 
		END AS CalcVisitSequence
FROM VLOG
WHERE SubjectID NOT IN (SELECT DISTINCT SubjectID FROM VLOG WHERE VisitType = 'Enrollment')



GO
