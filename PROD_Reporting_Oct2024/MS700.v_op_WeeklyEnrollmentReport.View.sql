USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_WeeklyEnrollmentReport]    Script Date: 11/13/2024 1:41:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =================================================
-- Author:		Kevin Soe
-- Create date: 8/26/2022
-- Description:	View for MS Enrollment Report for Weekly Operations Meeting
-- =================================================

CREATE VIEW [MS700].[v_op_WeeklyEnrollmentReport] AS


--Get count of total enrollments at each site
WITH SubjectCount AS
(
SELECT  
	   [SiteID]
	  ,COUNT([SiteID]) AS [Subjects]
FROM [MS700].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'
GROUP BY [SiteID]
),

--Get count of total subjects that have had their first follow-up
HasFirstFU AS 
(
SELECT 
	   [SiteID]
	  ,COUNT([SiteID]) AS [HasFirstFU]
FROM [MS700].[v_op_VisitLog]
WHERE [VisitType] = 'Follow-Up' AND [VisitSequence] = '1'
GROUP BY [SiteID]
),

--Get count of total exited subjects at each site
Exits AS
(
SELECT 
	   [SiteID]
	  ,COUNT([SiteID]) AS [Exits]
FROM [MS700].[v_op_VisitLog]
WHERE [VisitType] = 'Exit' 
GROUP BY [SiteID]
),

--Determine when subjects are due for their first follow-up based on their enrollment date + 150 days
FirstFUDueDates AS
(
SELECT 
	   [SiteID]
	  ,[SubjectID]
	  ,CAST(DATEADD(day, 150, [VisitDate]) AS DATE) AS [FirstFUDueDate]
FROM [MS700].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'
),

--Determine how many subjects are already due for their first follow-up at each site
FirstFUDue AS
(
SELECT 
	    [SiteID]
	   ,COUNT([SiteID]) AS [FirstFUDue]
FROM FirstFUDueDates 
WHERE [FirstFUDueDate] < GETDATE()
GROUP BY [SiteID]
),

--Get list of sites from visit log
Sites AS
(
SELECT DISTINCT
	 [SiteID]
	,[SFSiteStatus]
FROM [MS700].[v_op_VisitLog]
)

--Combine all calculations into one table
SELECT 
	 S.[SiteID]
	,S.[SFSiteStatus]
	,CASE 
		WHEN C.[Subjects] IS NULL THEN 0 
		ELSE C.[Subjects]
	 END AS [Subjects]
	,CASE
		WHEN H.[HasFirstFU] IS NULL THEN 0
		ELSE H.[HasFirstFU]
	 END AS [HasFirstFU]
	,CASE
		WHEN E.[Exits] IS NULL THEN 0
		ELSE E.[Exits]
	 END AS [Exits]
	,CASE
		WHEN F.[FirstFUDue] IS NULL THEN 0
		ELSE F.[FirstFUDue]
	 END AS [FirstFUDue]
	,(CAST(H.[HasFirstFU] as decimal)/CAST(F.[FirstFUDue] AS decimal)) AS [PercentFirstFU]

FROM Sites S
LEFT JOIN SubjectCount C ON S.SiteID = C.SiteID
LEFT JOIN HasFirstFU H ON S.SiteID = H.SiteID
LEFT JOIN Exits E ON S.SiteID = E.SiteID
LEFT JOIN FirstFUDue F ON S.SiteID = F.SiteID
WHERE S.[SiteID] <> '7020'  --Per Patrick Brooks: "per reasons that have to do with some sort of site non-compliance or bad practices, Site 7020 should be excluded. Closed sites should continue to show, but that site specifically should be omitted."

GO
