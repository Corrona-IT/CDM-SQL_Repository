USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_VisitLog_V5]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE view [RA100].[v_op_VisitLog_V5]  as



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
	  ,CASE 
	   WHEN VisitType = 'Enrollment' THEN 1
	   WHEN VisitType = 'Follow-up' THEN 2
	   WHEN VisitType = 'Exit' THEN 3
	   ELSE NULL
	   END AS VisitHierarchy
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
		WHEN VisitType = 'Enrollment' THEN 0
		ELSE ROW_NUMBER() OVER (PARTITION BY SubjectID ORDER BY VisitHierarchy, VisitDate) - 1
		END AS CalcVisitSequence
	  ,'RA-100' AS Registry
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
		WHEN VisitType = 'Enrollment' THEN 0
		ELSE ROW_NUMBER() OVER (PARTITION BY SubjectID ORDER BY VisitHierarchy, VisitDate) 
		END AS CalcVisitSequence
	 ,'RA-100' AS Registry
FROM VLOG
WHERE SubjectID NOT IN (SELECT DISTINCT SubjectID FROM VLOG WHERE VisitType = 'Enrollment')




GO
