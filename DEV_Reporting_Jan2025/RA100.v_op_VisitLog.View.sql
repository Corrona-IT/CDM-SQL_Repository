USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_VisitLog]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW  [RA100].[v_op_VisitLog]  AS



WITH VLOG AS 
(
SELECT VisitID
	  ,SiteID
      ,SubjectID
	  ,PatientId
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
	  ,VLOG.SiteID
	  ,SS.SiteStatus
	  ,RS.currentStatus AS SFSiteStatus
      ,SubjectID
	  ,PatientId
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
	,'Rheumatoid Arthritis (RA-100,02-021)' AS RegistryName
FROM VLOG
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] SS ON SS.SiteID=VLOG.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]='Rheumatoid Arthritis (RA-100,02-021)' AND CAST(RS.[siteNumber] AS int)=CAST(VLOG.SiteID AS int)
WHERE SubjectID IN (SELECT DISTINCT SubjectID FROM VLOG WHERE VisitType = 'Enrollment')

UNION

SELECT
	   VisitID  
	  ,VLOG.SiteID
	  ,SS.SiteStatus
	  ,RS.currentStatus AS SFSiteStatus
      ,SubjectID
	  ,PatientId
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
	,'Rheumatoid Arthritis (RA-100,02-021)' AS RegistryName
FROM VLOG
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] SS ON SS.SiteID=VLOG.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]='Rheumatoid Arthritis (RA-100,02-021)' AND CAST(RS.[siteNumber] AS int)=CAST(VLOG.SiteID AS int)
WHERE SubjectID NOT IN (SELECT DISTINCT SubjectID FROM VLOG WHERE VisitType = 'Enrollment')
AND ISNULL(VisitDate, '')<>''



GO
