USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_SiteScorecard_V3]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =================================================
-- Author:		Kevin Soe
-- Create date: 10/3/2019
-- V2 Update date: 4/1/2020
-- V3 Update date: 10/6/2020
-- Description:	Procedure for RA-102 Site Scorecard
-- =================================================

CREATE VIEW [RA102].[v_op_SiteScorecard_V3] AS
	-- Add the parameters for the stored procedure here

--DECLARE @TP1StartEntryDate DATETIME
--DECLARE @TP1EndEntryDate DATETIME
--DECLARE @TP2StartEntryDate DATETIME
--DECLARE @TP2EndEntryDate DATETIME

--Get Months Active

WITH MonthsActive AS

(
SELECT  SS.[SiteID]
	   ,SS.[SiteStatus]
	   ,RS.[currentStatus] AS [SalesforceStatus]
	   ,CASE WHEN RS.[TopEnrollingSite] = 'Yes' THEN 'Yes'
	    ELSE 'No'
		END AS [TopEnrollingSite]
	   ,ROUND(CAST((DATEDIFF(d,MIN(VL.[VisitDate]),(CAST(GETDATE() AS DATE)))/30.0) AS FLOAT),1) AS [MonthsActive]
-- SELECT * 
FROM [RA102].[v_op_SiteStatus] SS
LEFT JOIN [Reporting].[RA102].[v_op_VisitLog]  VL ON VL.[SiteID] = SS.[SiteID]
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] = SS.[SiteID]
WHERE RS.[name] LIKE 'Japan RA Registry (RA-102)'
AND RS.[currentStatus] IN ('Approved / Active', 'On hold (active)', 'Pending closeout', 'Closed / Completed')
GROUP BY SS.[SiteID], SS.[SiteStatus], RS.[currentStatus], RS.[TopEnrollingSite]
),

--Get Total Non-Exited

NonExited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [NonExited]

FROM [Reporting].[RA102].[t_op_PatientVisitTracker]
GROUP BY [SiteID]
),

--Get Total Exited

Exited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [Exited]

FROM [Reporting].[RA102].[t_op_SubjectLog]
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

FROM [RA102].[v_op_SiteStatus] SS
LEFT JOIN [Reporting].[RA102].[v_op_VisitLog] VL ON VL.[SiteID] = SS.[SiteID]
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

FROM [Reporting].[RA102].[t_op_PatientVisitTracker]
WHERE [MonthsSinceLastVisit] <= 9
GROUP BY [SiteID]
),

--Determine Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

ConfirmedEvents AS

(
SELECT
		[Site ID]
	   ,COUNT([Site ID]) AS [ConfirmedEvents]

FROM [Reporting].[RA102].[t_PV_TAEQC]
WHERE LTRIM([Report Type]) = 'Confirmed event'
AND [Date of Event Onset] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [Date of Event Onset] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [Site ID]
),

--Determine All Time Confirmed Events. Excludes Pregnancies. Only TAEs can have Report Type = 'Confirmed event'.

AllTimeConfirmedEvents AS

(
SELECT
		[Site ID]
	   ,COUNT([Site ID]) AS [AllTimeConfirmedEvents]

FROM [Reporting].[RA102].[t_PV_TAEQC]
WHERE LTRIM([Report Type]) = 'Confirmed event'
GROUP BY [Site ID]
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
		[Site ID]
	   ,COUNT([Site ID]) AS [RetrievedDocs]

FROM [Reporting].[RA102].[t_PV_TAEQC]
WHERE LTRIM([Report Type]) = 'Confirmed event'
AND [Supporting documents received by Corrona?] = 'YES'
AND [Date of Event Onset] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [Date of Event Onset] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [Site ID]
),

--Determine Docs that have been retrieved for Confirmed TAEs All Time

AllTimeRetrievedDocs AS

(
SELECT
		[Site ID]
	   ,COUNT([Site ID]) AS [AllTimeRetrievedDocs]

FROM [Reporting].[RA102].[t_PV_TAEQC]
WHERE LTRIM([Report Type]) = 'Confirmed event'
AND [Supporting documents received by Corrona?] = 'YES'
GROUP BY [Site ID]
),

--Determine Doc Retrieval %

DocsRetrievalPercent AS

(
SELECT
		CE.[Site ID]
	   ,CASE 
			WHEN ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) IS NULL THEN CAST(0 AS FLOAT)
			ELSE ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) 
			END AS [DocRetrievalPercent]
FROM ConfirmedEvents CE
LEFT JOIN RetrievedDocs RD ON RD.[Site ID] = CE.[Site ID]
),

--Determine Doc Retrieval % All Time

AllTimeDocsRetrievalPercent AS

(
SELECT
		ATCE.[Site ID]
	   ,CASE 
			WHEN ROUND(CAST(ATRD.[AllTimeRetrievedDocs] AS FLOAT)/CAST(ATCE.[AllTimeConfirmedEvents] AS FLOAT),2) IS NULL THEN CAST(0 AS FLOAT)
			ELSE ROUND(CAST(ATRD.[AllTimeRetrievedDocs] AS FLOAT)/CAST(ATCE.[AllTimeConfirmedEvents] AS FLOAT),2) 
			END AS [AllTimeDocRetrievalPercent]
FROM AllTimeConfirmedEvents ATCE
LEFT JOIN AllTimeRetrievedDocs ATRD ON ATRD.[Site ID] = ATCE.[Site ID]
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
	   ,MA.[TopEnrollingSite]
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
LEFT JOIN ConfirmedEvents CE ON CE.[Site ID] = MA.[SiteID]
LEFT JOIN ExpectedEvents EE ON EE.[SiteID] = MA.[SiteID]
LEFT JOIN RetrievedDocs RD ON RD.[Site ID] = MA.[SiteID]
LEFT JOIN DocsRetrievalPercent DRP ON DRP.[Site ID] = MA.[SiteID]
LEFT JOIN AllTimeConfirmedEvents ATCE ON ATCE.[Site ID] = MA.[SiteID]
LEFT JOIN AllTimeRetrievedDocs ATRD ON ATRD.[Site ID] = MA.[SiteID]
LEFT JOIN AllTimeDocsRetrievalPercent ATDRP ON ATDRP.[Site ID] = MA.[SiteID]
LEFT JOIN ActivePercent AP ON AP.[SiteID] = MA.[SiteID]
LEFT JOIN ConsistencyRating CR ON CR.[SiteID] = MA.[SiteID]


















GO
