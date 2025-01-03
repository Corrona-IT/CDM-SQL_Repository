USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SiteScorecard_V2]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =================================================
-- Author:		Kevin Soe
-- Create date: 10/7/2019
-- V2 Update date: 4/1/2020
-- Description:	Procedure for RA US Site Scorecard
-- =================================================

CREATE VIEW [RA100].[v_op_SiteScorecard_V2] AS
	-- Add the parameters for the stored procedure here

--DECLARE @TP1StartEntryDate DATETIME
--DECLARE @TP1EndEntryDate DATETIME
--DECLARE @TP2StartEntryDate DATETIME
--DECLARE @TP2EndEntryDate DATETIME

--Exclude Visits with Visit Dates Prior to 3/25/2013, the release date TM 

WITH VL AS 
(
SELECT * 
FROM [Reporting].[RA100].[v_op_VisitLog]
WHERE [VisitDate] >= '3/25/2013'
),

FPI AS

(SELECT * 
FROM [Reporting].[RA100].[t_FPIDates]
),

--Get Months Active

MonthsActive AS

(
SELECT  SS.[SiteID]
	   ,SS.[SiteStatus]
	   ,RS.[currentStatus] AS [SalesforceStatus]
	   ,CASE WHEN FPI.[FPIDate] <> '' THEN ROUND(CAST((DATEDIFF(d,FPI.[FPIDate],(CAST(GETDATE() AS DATE)))/30.0) AS FLOAT),1)
	    ELSE ROUND(CAST((DATEDIFF(d,MIN(VL.[VisitDate]),(CAST(GETDATE() AS DATE)))/30.0) AS FLOAT),1)
		END AS [MonthsActive]
-- SELECT * 
FROM [RA100].[v_op_SiteStatus] SS
LEFT JOIN FPI ON FPI.[SiteID] = SS.[SiteID]
LEFT JOIN VL ON VL.[SiteID] = SS.[SiteID]
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] = SS.[SiteID]
WHERE RS.[name] LIKE 'Rheumatoid Arthritis (RA-100,02-021)'
AND RS.[currentStatus] IN ('Approved / Active', 'On hold (active)', 'Pending closeout', 'Closed / Completed')
GROUP BY SS.[SiteID], SS.[SiteStatus], RS.[currentStatus], FPI.[FPIDate]
),

--Get Total Non-Exited

NonExited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [NonExited]

FROM [Reporting].[RA100].[t_op_PatientVisitTracker]
GROUP BY [SiteID]
),

--Get Total Exited

Exited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [Exited]

--SELECT *
FROM [Reporting].[RA100].[v_op_SubjectLog]
WHERE [ExitDate] IS NOT NULL
GROUP BY [SiteID]
),

--Determine Avg Visits / mo. (12 mo.)

AvgVisitsPerMonth AS

(
SELECT
	    SS.[SiteID]
	   ,CAST((COUNT(VL.[SiteID])/12.0) AS DECIMAL(5,1)) AS [AvgVisitsPerMonth]
	   ,COUNT(VL.[SiteID]) AS [TotalVisits]
	  --,[VisitDate]
	  --,CAST(DATEADD(MONTH,-14,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [14MonthsBack]
	  --,CAST(DATEADD(MONTH,-2,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [2MonthsBack]
	  --,CAST(DATEADD(MONTH,-16,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [16MonthsBack]
	  --,CAST(DATEADD(MONTH,-4,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [4MonthsBack]

FROM [RA100].[v_op_SiteStatus] SS
LEFT JOIN [Reporting].[RA100].[v_op_VisitLog] VL ON VL.[SiteID] = SS.[SiteID]
WHERE [VisitType] IN ('Enrollment', 'Follow-up')
AND [VisitDate] >= CAST(DATEADD(MONTH,-14,GETDATE()) AS DATE) 
AND [VisitDate] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
GROUP BY SS.[SiteID]
), 

--Determine 9 mo. active count

NineMonthActive AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) [NineMonthActiveCount]

FROM [Reporting].[RA100].[t_op_PatientVisitTracker]
WHERE [MonthsSinceLastVisit] <= 9
GROUP BY [SiteID]
),

--Determine Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

ConfirmedEvents AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [ConfirmedEvents]
--SELECT *
FROM [Reporting].[RA100].[v_pv_TAEQCListing]
WHERE [ConfirmedEvent] = 'Yes'
AND [Event] NOT LIKE '%preg%' 
AND [Event] NOT LIKE '%bir%' 
AND [Event] NOT LIKE '%birth%' 
AND [Event] NOT LIKE '%carriage%' 
AND [Event] NOT LIKE '%misca%' 
AND [Event] NOT LIKE '%abor%'
AND [Event] NOT LIKE '%baby%' 
AND [Event] NOT LIKE '%deliver%' 
AND [Event] NOT LIKE '%C-section%'
AND [EventOnsetDate] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [EventOnsetDate] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [SiteID]
),

--Determine All Time Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

AllTimeConfirmedEvents AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [AllTimeConfirmedEvents]
--SELECT *
FROM [Reporting].[RA100].[v_pv_TAEQCListing]
WHERE [ConfirmedEvent] = 'Yes'
AND [Event] NOT LIKE '%preg%' 
AND [Event] NOT LIKE '%bir%' 
AND [Event] NOT LIKE '%birth%' 
AND [Event] NOT LIKE '%carriage%' 
AND [Event] NOT LIKE '%misca%' 
AND [Event] NOT LIKE '%abor%'
AND [Event] NOT LIKE '%baby%' 
AND [Event] NOT LIKE '%deliver%' 
AND [Event] NOT LIKE '%C-section%'
AND [EventOnsetDate] >= '3/25/2013' 
GROUP BY [SiteID]
),

--Determine Expected Events NineMonthActive *.075

ExpectedEvents AS

(
SELECT
		[SiteID]
	   ,CAST(ROUND((NMA.[NineMonthActiveCount] * .075),0) AS INT) AS [ExpectedEvents]

FROM NineMonthActive NMA
),

--Determine Docs that have been retrieved for Confirmed TAEs

RetrievedDocs AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [RetrievedDocs]

FROM [Reporting].[RA100].[v_pv_TAEQCListing]
WHERE [ConfirmedEvent] = 'Yes'
AND [AcknowledgementofReceipt] = '1'
AND [EventOnsetDate] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [EventOnsetDate] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
AND [Event] NOT LIKE '%preg%' 
AND [Event] NOT LIKE '%bir%' 
AND [Event] NOT LIKE '%birth%' 
AND [Event] NOT LIKE '%carriage%' 
AND [Event] NOT LIKE '%misca%' 
AND [Event] NOT LIKE '%abor%'
AND [Event] NOT LIKE '%baby%' 
AND [Event] NOT LIKE '%deliver%' 
AND [Event] NOT LIKE '%C-section%'
GROUP BY [SiteID]
),

--Determine Docs that have been retrieved for Confirmed TAEs All Time

AllTimeRetrievedDocs AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [AllTimeRetrievedDocs]

FROM [Reporting].[RA100].[v_pv_TAEQCListing]
WHERE [ConfirmedEvent] = 'Yes'
AND [AcknowledgementofReceipt] = '1'
AND [Event] NOT LIKE '%preg%' 
AND [Event] NOT LIKE '%bir%' 
AND [Event] NOT LIKE '%birth%' 
AND [Event] NOT LIKE '%carriage%' 
AND [Event] NOT LIKE '%misca%' 
AND [Event] NOT LIKE '%abor%'
AND [Event] NOT LIKE '%baby%' 
AND [Event] NOT LIKE '%deliver%' 
AND [Event] NOT LIKE '%C-section%'
AND [EventOnsetDate] >= '3/25/2013' 
GROUP BY [SiteID]
),

--Determine Doc Retrieval %

DocsRetrievalPercent AS

(
SELECT
		CE.[SiteID]
	   ,CASE 
			WHEN ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) IS NULL THEN CAST(0 AS FLOAT)
			ELSE ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) 
			END AS [DocRetrievalPercent]
FROM ConfirmedEvents CE
LEFT JOIN RetrievedDocs RD ON RD.[SiteID] = CE.[SiteID]
),

--Determine Doc Retrieval % All Time

AllTimeDocsRetrievalPercent AS

(
SELECT
		ATCE.[SiteID]
	   ,CASE 
			WHEN ROUND(CAST(ATRD.[AllTimeRetrievedDocs] AS FLOAT)/CAST(ATCE.[AllTimeConfirmedEvents] AS FLOAT),2) IS NULL THEN CAST(0 AS FLOAT)
			ELSE ROUND(CAST(ATRD.[AllTimeRetrievedDocs] AS FLOAT)/CAST(ATCE.[AllTimeConfirmedEvents] AS FLOAT),2) 
			END AS [AllTimeDocRetrievalPercent]
FROM AllTimeConfirmedEvents ATCE
LEFT JOIN AllTimeRetrievedDocs ATRD ON ATRD.[SiteID] = ATCE.[SiteID]
),

--Determine Active %

ActivePercent AS

(
SELECT
		NE.[SiteID]
	   ,ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) AS [ActivePercent]

FROM NonExited NE
JOIN NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]
),

--Determine Consistency Rating

ConsistencyRating AS

(
SELECT
		NE.[SiteID]
	   ,CASE 
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .91 AND 1 THEN 'very high'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .86 AND .90 THEN 'high'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .81 AND .85 THEN 'above average'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .71 AND .80 THEN 'average'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .61 AND .70 THEN 'below average'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .41 AND .60 THEN 'low'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .31 AND .40 THEN 'very low'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) <= .30 THEN 'at risk'
			ELSE NULL
		END AS [ConsistencyRating]

FROM NonExited NE
JOIN NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]
)

SELECT 
		MA.[SiteID]
	   ,MA.[SiteStatus]
	   ,MA.[SalesforceStatus]
	   ,MA.[MonthsActive]
	   ,NE.[NonExited]
	   ,E.[Exited]
	   ,AVM.[TotalVisits]
	   ,AVM.[AvgVisitsPerMonth]
	   ,NMA.[NineMonthActiveCount]
	   ,CE.[ConfirmedEvents]
	   ,EE.[ExpectedEvents]
	   ,RD.[RetrievedDocs]
	   ,DRP.[DocRetrievalPercent]
	   ,ATCE.[AllTimeConfirmedEvents]
	   ,ATRD.[AllTimeRetrievedDocs]
	   ,ATDRP.[AllTimeDocRetrievalPercent]
	   ,AP.[ActivePercent]
	   ,CR.[ConsistencyRating]

FROM MonthsActive MA
LEFT JOIN NonExited NE ON NE.[SiteID] = MA.[SiteID]
LEFT JOIN Exited E ON E.[SiteID] = MA.[SiteID]
LEFT JOIN AvgVisitsPerMonth AVM ON AVM.[SiteID] = MA.[SiteID]
LEFT JOIN NineMonthActive NMA ON NMA.[SiteID] = MA.[SiteID]
LEFT JOIN ConfirmedEvents CE ON CE.[SiteID] = MA.[SiteID]
LEFT JOIN ExpectedEvents EE ON EE.[SiteID] = MA.[SiteID]
LEFT JOIN RetrievedDocs RD ON RD.[SiteID] = MA.[SiteID]
LEFT JOIN DocsRetrievalPercent DRP ON DRP.[SiteID] = MA.[SiteID]
LEFT JOIN AllTimeConfirmedEvents ATCE ON ATCE.[SiteID] = MA.[SiteID]
LEFT JOIN AllTimeRetrievedDocs ATRD ON ATRD.[SiteID] = MA.[SiteID]
LEFT JOIN AllTimeDocsRetrievalPercent ATDRP ON ATDRP.[SiteID] = MA.[SiteID]
LEFT JOIN ActivePercent AP ON AP.[SiteID] = MA.[SiteID]
LEFT JOIN ConsistencyRating CR ON CR.[SiteID] = MA.[SiteID]




















GO
