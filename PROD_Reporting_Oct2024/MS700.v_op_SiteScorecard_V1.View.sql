USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_SiteScorecard_V1]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















-- =================================================
-- Author:		Kevin Soe
-- Create date: 2/1/2019
-- Description:	Procedure for MS Site Scorecard used for V2 of Site Scorecard
-- =================================================

CREATE VIEW [MS700].[v_op_SiteScorecard_V1] AS
	-- Add the parameters for the stored procedure here


--Get Months Active

WITH MonthsActive AS

(
SELECT  SS.[SiteID]
	   ,SS.[SiteStatus]
	   ,RS.[currentStatus] AS [SalesforceStatus]
	   ,CAST((DATEDIFF(d,MIN(VL.[VisitDate]),(CAST(GETDATE() AS DATE)))/30.0) AS decimal(3,1)) AS [MonthsActive]
-- SELECT * 
FROM [MS700].[v_SiteStatus] SS
LEFT JOIN [Reporting].[MS700].[v_op_VisitLog]  VL ON VL.[SiteID] = SS.[SiteID]
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] = SS.[SiteID]
WHERE RS.[name] LIKE 'Multiple Sclerosis (MS-700)'
AND RS.[currentStatus] IN ('Approved / Active', 'On hold (active)', 'Pending closeout', 'Closed / Completed')
GROUP BY SS.[SiteID], SS.[SiteStatus], RS.[currentStatus]
),

--Get Total Non-Exited

NonExited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [NonExited]

FROM [Reporting].[MS700].[t_op_PatientVisitTracker]
GROUP BY [SiteID]
),

--Get Total Exited

Exited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [Exited]

FROM [Reporting].[MS700].[t_op_SubjectLog]
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

FROM [MS700].[v_SiteStatus] SS
LEFT JOIN [Reporting].[MS700].[v_op_VisitLog] VL ON VL.[SiteID] = SS.[SiteID]
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

FROM [Reporting].[MS700].[t_op_PatientVisitTracker]
WHERE [MonthsSinceLastVisit] <= 9
GROUP BY [SiteID]
),

--Determine Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

ConfirmedEvents AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [ConfirmedEvents]

FROM [Reporting].[MS700].[t_pv_TAEQCListing]
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [OnsetDate] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [OnsetDate] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [SiteID]
),

--Determine All Time Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

AllTimeConfirmedEvents AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [AllTimeConfirmedEvents]

FROM [Reporting].[MS700].[t_pv_TAEQCListing]
WHERE [ConfirmationStatus] = 'Confirmed event'
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

FROM [Reporting].[MS700].[t_pv_TAEQCListing]
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [SupportingDocsApproved] = 'Yes'
AND [OnsetDate] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [OnsetDate] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [SiteID]
),

--Determine Docs that have been retrieved for Confirmed TAEs All Time

AllTimeRetrievedDocs AS

(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [AllTimeRetrievedDocs]

FROM [Reporting].[MS700].[t_pv_TAEQCListing]
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [SupportingDocsApproved] = 'Yes'
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

--Determine Doc Retrieval %

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
