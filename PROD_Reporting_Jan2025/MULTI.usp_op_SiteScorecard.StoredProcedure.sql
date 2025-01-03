USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_SiteScorecard]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =================================================
-- Author:		Kevin Soe
-- Create date: 9/30/2019
-- Description:	Procedure for PSO Site Scorecard
-- =================================================

CREATE PROCEDURE [MULTI].[usp_op_SiteScorecard] AS
	-- Add the parameters for the stored procedure here

--DECLARE @TP1StartEntryDate DATETIME
--DECLARE @TP1EndEntryDate DATETIME
--DECLARE @TP2StartEntryDate DATETIME
--DECLARE @TP2EndEntryDate DATETIME

--Get Months Active

if object_id('tempdb..#MonthsActive') is not null begin drop table #MonthsActive end

SELECT  VL.[SiteID]
	   ,CAST((DATEDIFF(d,MIN(VL.[VisitDate]),(CAST(GETDATE() AS DATE)))/30.0) AS decimal(5,1)) AS [MonthsActive]
INTO #MonthsActive

FROM [Reporting].[PSO500].[t_VisitLog]  VL
GROUP BY VL.[SiteID]

--Get Total Non-Exited

if object_id('tempdb..#NonExited') is not null begin drop table #NonExited end

SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [NonExited]

INTO #NonExited

FROM [Reporting].[PSO500].[t_op_PatientVisitTracker]
GROUP BY [SiteID]

--Get Total Exited

if object_id('tempdb..#Exited') is not null begin drop table #Exited end

SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [Exited]

INTO #Exited

FROM [Reporting].[PSO500].[t_op_SubjectLog]
WHERE [ExitDate] IS NOT NULL
GROUP BY [SiteID]
	
--Determine Avg Visits / mo. (12 mo.)

if object_id('tempdb..#AvgVisitsPerMonth') is not null begin drop table #AvgVisitsPerMonth end

SELECT
	    [SiteID]
	   ,CAST((COUNT([SiteID])/12.0) AS DECIMAL(5,1)) AS [AvgVisitsPerMonth]
	   ,COUNT([SiteID]) AS [TotalVisits]
	  --,[VisitDate]
	  --,CAST(DATEADD(MONTH,-14,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [14MonthsBack]
	  --,CAST(DATEADD(MONTH,-2,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [2MonthsBack]
	  --,CAST(DATEADD(MONTH,-16,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [16MonthsBack]
	  --,CAST(DATEADD(MONTH,-4,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [4MonthsBack]

INTO #AvgVisitsPerMonth

FROM [Reporting].[PSO500].[t_VisitLog] 
WHERE [VisitType] IN ('Enrollment', 'Follow-up')
AND [VisitDate] >= CAST(DATEADD(MONTH,-14,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) 
AND [VisitDate] < CAST(DATEADD(MONTH,-2,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE)
GROUP BY [SiteID]

--Determine 9 mo. active count

if object_id('tempdb..#NineMonthActive') is not null begin drop table #NineMonthActive end

SELECT
		[SiteID]
	   ,COUNT([SiteID]) [NineMonthActiveCount]

INTO #NineMonthActive

FROM [Reporting].[PSO500].[t_op_PatientVisitTracker]
WHERE [MonthsSinceLastVisit] <= 9
GROUP BY [SiteID]




--Determine Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event report'.

--if object_id('tempdb..#ConfirmedEvents') is not null begin drop table #ConfirmedEvents end

--SELECT
--		[SiteID]
--	   ,COUNT([SiteID]) AS [ConfirmedEvents]

--INTO #ConfirmedEvents

--FROM [Reporting].[PSO500].[v_pv_TAEQCListing]
--WHERE [ReportType] = 'Confirmed event report'
--AND [EventOnset] >= CAST(DATEADD(MONTH,-16,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE)
--AND [EventOnset] < CAST(DATEADD(MONTH,-4,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE)
--GROUP BY [SiteID]

--Determine Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event report'.

if object_id('tempdb..#ConfEvent') is not null begin drop table #ConfEvent end

SELECT *
INTO #ConfEvent
FROM
(
SELECT [SiteID]
	   ,SubjectID
       ,CAST(EventOnset AS date) as EventOnset
	   ,CAST(GETDATE() AS date) AS c_getdate
	   ,CASE WHEN ISDATE(EventOnset)=1 THEN DATEDIFF(m, EventOnset, GETDATE()) 
	    ELSE CAST(NULL as INT)
		END AS monthsdiff

FROM [Reporting].[PSO500].[v_pv_TAEQCListing]
WHERE [ReportType] = 'Confirmed event report'
AND SubjectID<>'47618390198'
AND ISNULL(EventOnset, '')<>''
) A


if object_id('tempdb..#ConfirmedEvents') is not null begin drop table #ConfirmedEvents end

SELECT SiteID,
       COUNT([SiteID]) AS [ConfirmedEvents]
INTO #ConfirmedEvents
FROM #ConfEvent
WHERE 1=1
AND monthsdiff between 4 and 6
GROUP BY [SiteID]



--Determine Docs that have been retrieved for Confirmed TAEs

if object_id('tempdb..#RetrievedDocs') is not null begin drop table #RetrievedDocs end

SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [RetrievedDocs]

INTO #RetrievedDocs

FROM [Reporting].[PSO500].[v_pv_TAEQCListing]
WHERE [ReportType] = 'Confirmed event report'
AND [DocsReceivedByCorrona] = '1'
AND [EventOnset] >= CAST(DATEADD(MONTH,-16,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE)
AND [EventOnset] < CAST(DATEADD(MONTH,-4,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE)
GROUP BY [SiteID]

--Determine Doc Retrieval %

if object_id('tempdb..#DocsRetrievalPercent') is not null begin drop table #DocsRetrievalPercent end

SELECT
		CE.[SiteID]
	   ,ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) AS [DocRetrievalPercent]

INTO #DocsRetrievalPercent

FROM #ConfirmedEvents CE
JOIN #RetrievedDocs RD ON RD.[SiteID] = CE.[SiteID]

--Determine Active %

if object_id('tempdb..#ActivePercent') is not null begin drop table #ActivePercent end

SELECT
		NE.[SiteID]
	   ,ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) AS [ActivePercent]

INTO #ActivePercent

FROM #NonExited NE
JOIN #NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]

--Determine Consistency Rating

if object_id('tempdb..#ConsistencyRating') is not null begin drop table #ConsistencyRating end

SELECT
		NE.[SiteID]
	   ,CASE 
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .91 AND 1 THEN 'Very High'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .96 AND .90 THEN 'High'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .81 AND .85 THEN 'Above Average'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .71 AND .80 THEN 'Average'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .61 AND .70 THEN 'Below Average'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .41 AND .60 THEN 'Low'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) BETWEEN .31 AND .40 THEN 'Very Low'
			WHEN ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) <= .30 THEN 'At risk'
			ELSE NULL
		END AS [ConsistencyRating]

INTO #ConsistencyRating

FROM #NonExited NE
JOIN #NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]

--Determine List of Visits Entered One

if object_id('tempdb..#VisitsEnteredListOne') is not null begin drop table #VisitsEnteredListOne end

SELECT
		VEO.[SiteNumber]
	   ,VEO.[SubjectId]
	   ,CAST(VEO.[VisitDate] AS DATETIME) AS [VisitDate]
	   ,VEO.[VisitType]
	   ,CAST(VEO.[CompletionDate] AS DATETIME) AS [CompletionDate]
	   ,VEO.[DifferenceInDays]

INTO #VisitsEnteredListOne

FROM [Reporting].[PSO500].[v_op_DataEntryLag] VEO
WHERE CAST([CompletionDate] AS DATETIME) >= ('2018-01-01')--SELECT MIN([CompletionDate]) FROM [Reporting].[PSO500].[v_op_DataEntryLag])
  AND CAST([CompletionDate] AS DATETIME) <= ('2018-12-31')

--Determine Total Visits Entered One

if object_id('tempdb..#VisitsEnteredOne') is not null begin drop table #VisitsEnteredOne end

SELECT
		VEO.[SiteNumber]
	   ,COUNT(VEO.[SiteNumber]) AS [VisitsEnteredOne]
	   ,SUM(VEO.[DifferenceInDays]) AS [TotalDifferenceInDays]

INTO #VisitsEnteredOne

FROM #VisitsEnteredListOne VEO
GROUP BY VEO.[SiteNumber]

--Determine Average Lag for Visits Entered One

if object_id('tempdb..#AvgLagOne') is not null begin drop table #AvgLagOne end

SELECT
		MA.[SiteID]
	   ,ROUND(AVG(ALO.[DifferenceInDays]),2) AS [AvgLagOne]
	   ,CASE
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) <=5 THEN 'Very Fast'
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 6 AND 10 THEN 'Fast'
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 11 AND 20 THEN 'Above Average'
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 21 AND 30 THEN 'Average'
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 31 AND 40 THEN 'Below Average'
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 61 AND 90 THEN 'Slow'
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) >91 THEN 'Very Slow'
		 	ELSE 'No Visits'
		 END AS [SpeedRatingOne]
	    ,CASE
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) <=5 THEN CAST('7' AS SMALLINT)
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 6 AND 10 THEN CAST('6' AS SMALLINT)
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 11 AND 20 THEN CAST('5' AS SMALLINT)
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 21 AND 30 THEN CAST('4' AS SMALLINT)
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 31 AND 40 THEN CAST('3' AS SMALLINT)
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) BETWEEN 61 AND 90 THEN CAST('2' AS SMALLINT)
		 	WHEN ROUND(AVG(ALO.[DifferenceInDays]),2) >91 THEN CAST('1' AS SMALLINT)
		 	ELSE CAST('-1' AS SMALLINT)
		 END AS [SpeedScoreOne]

INTO #AvgLagOne

FROM #MonthsActive MA
LEFT JOIN #VisitsEnteredListOne ALO ON ALO.[SiteNumber] = MA.[SiteID]
GROUP BY MA.[SIteID]

--Determine List of Visits Entered Two

if object_id('tempdb..#VisitsEnteredListTwo') is not null begin drop table #VisitsEnteredListTwo end

SELECT
		VEO.[SiteNumber]
	   ,VEO.[SubjectId]
	   ,CAST(VEO.[VisitDate] AS DATETIME) AS [VisitDate]
	   ,VEO.[VisitType]
	   ,CAST(VEO.[CompletionDate] AS DATETIME) AS [CompletionDate]
	   ,VEO.[DifferenceInDays]

INTO #VisitsEnteredListTwo

FROM [Reporting].[PSO500].[v_op_DataEntryLag] VEO
WHERE CAST([CompletionDate] AS DATETIME) >= ('2019-01-01')--SELECT MIN([CompletionDate]) FROM [Reporting].[PSO500].[v_op_DataEntryLag])
  AND CAST([CompletionDate] AS DATETIME) <= (GETDATE())

--Determine Total Visits Entered Two

if object_id('tempdb..#VisitsEnteredTwo') is not null begin drop table #VisitsEnteredTwo end

SELECT
		VET.[SiteNumber]
	   ,COUNT(VET.[SiteNumber]) AS [VisitsEnteredTwo]
	   ,SUM(VET.[DifferenceInDays]) AS [TotalDifferenceInDays]

INTO #VisitsEnteredTwo

FROM #VisitsEnteredListTwo VET
GROUP BY VET.[SiteNumber]

--Determine Average Lag for Visits Entered Two

if object_id('tempdb..#AvgLagTwo') is not null begin drop table #AvgLagTwo end

SELECT
		MA.[SiteID]
	   ,ROUND(AVG(ALT.[DifferenceInDays]),2) AS [AvgLagTwo]
	   ,CASE
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) <=5 THEN 'Very Fast'
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 6 AND 10 THEN 'Fast'
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 11 AND 20 THEN 'Above Average'
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 21 AND 30 THEN 'Average'
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 31 AND 40 THEN 'Below Average'
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 61 AND 90 THEN 'Slow'
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) >91 THEN 'Very Slow'
		 	--WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) IS NULL THEN 'No Visits'
		 	ELSE 'No Visits'
		 END AS [SpeedRatingTwo]
	    ,CASE
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) <=5 THEN CAST('7' AS SMALLINT)
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 6 AND 10 THEN CAST('6' AS SMALLINT)
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 11 AND 20 THEN CAST('5' AS SMALLINT)
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 21 AND 30 THEN CAST('4' AS SMALLINT)
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 31 AND 40 THEN CAST('3' AS SMALLINT)
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) BETWEEN 61 AND 90 THEN CAST('2' AS SMALLINT)
		 	WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) >91 THEN CAST('1' AS SMALLINT)
		 	--WHEN ROUND(AVG(ALT.[DifferenceInDays]),2) IS NULL THEN CAST('-1' AS SMALLINT)
		 	ELSE CAST('-1' AS SMALLINT)
		 END AS [SpeedScoreTwo]

INTO #AvgLagTwo

FROM #MonthsActive MA
LEFT JOIN #VisitsEnteredListTwo ALT ON ALT.[SiteNumber] = MA.[SiteID]
GROUP BY MA.[SiteID]

--Determine Change Score

if object_id('tempdb..#ChangeScore') is not null begin drop table #ChangeScore end

SELECT
		MA.[SiteID]
	   ,CASE
			WHEN ALT.[SpeedRatingTwo] = 'No Visits' AND ALO.[SpeedRatingOne] = 'No Visits' THEN CAST('-9' AS SMALLINT)
			ELSE (ALT.[SpeedScoreTwo] - ALO.[SpeedScoreOne])
		END AS [ChangeScore]

INTO #ChangeScore

FROM #MonthsActive MA
LEFT JOIN #AvgLagOne ALO ON ALO.[SiteID] = MA.[SiteID]
LEFT JOIN #AvgLagTwo ALT ON ALT.[SiteID] = MA.[SiteID]

--Determine Direction of Change

if object_id('tempdb..#DirectionOfChange') is not null begin drop table #DirectionOfChange end

SELECT
		MA.[SiteID]
	   ,CASE
			WHEN CS.[ChangeScore] IN (-9,-8,-7,-6) THEN 'At risk'
			WHEN CS.[ChangeScore] IN (-5,-4) THEN 'Much Slower' 
			WHEN CS.[ChangeScore] IN (-3,-2,-1) THEN 'Slower'
			WHEN CS.[ChangeScore] = 0 THEN 'No change'
			WHEN CS.[ChangeScore] IN (1,2,3,4) THEN 'Faster' 
			WHEN CS.[ChangeScore] IN (5,6,7,8) THEN 'Much Faster'
			WHEN MA.[MonthsActive] < 15 OR NE.[NonExited] < 50 THEN 'n/a'
			ELSE '' 
		 END AS [DirectionOfChange]

INTO #DirectionOfChange

FROM #MonthsActive MA
LEFT JOIN #NonExited NE ON NE.[SiteID] = MA.[SiteID]
LEFT JOIN #ChangeScore CS ON CS.[SiteID] = MA.[SiteID]


SELECT 
		MA.[SiteID]
	   ,MA.[MonthsActive]
	   ,NE.[NonExited]
	   ,E.[Exited]
	   ,AVM.[AvgVisitsPerMonth]
	   ,NMA.[NineMonthActiveCount]
	   ,CE.[ConfirmedEvents]
	   ,RD.[RetrievedDocs]
	   ,DRP.[DocRetrievalPercent]
	   ,AP.[ActivePercent]
	   ,CR.[ConsistencyRating]
	   ,VEO.[VisitsEnteredOne]
	   ,VEO.[TotalDifferenceInDays]
	   ,ALO.[AvgLagOne]
	   ,ALO.[SpeedRatingOne]
	   ,ALO.[SpeedScoreOne]
	   ,VET.[VisitsEnteredTwo]
	   ,VET.[TotalDifferenceInDays]
	   ,ALT.[AvgLagTwo]
	   ,ALT.[SpeedRatingTwo]
	   ,ALT.[SpeedScoreTwo]
	   ,CS.[ChangeScore]
	   ,DOC.[DirectionOfChange]

FROM #MonthsActive MA
LEFT JOIN #NonExited NE ON NE.[SiteID] = MA.[SiteID]
LEFT JOIN #Exited E ON E.[SiteID] = MA.[SiteID]
LEFT JOIN #AvgVisitsPerMonth AVM ON AVM.[SiteID] = MA.[SiteID]
LEFT JOIN #NineMonthActive NMA ON NMA.[SiteID] = MA.[SiteID]
LEFT JOIN #ConfirmedEvents CE ON CE.[SiteID] = MA.[SiteID]
LEFT JOIN #RetrievedDocs RD ON RD.[SiteID] = MA.[SiteID]
LEFT JOIN #DocsRetrievalPercent DRP ON DRP.[SiteID] = MA.[SiteID]
LEFT JOIN #ActivePercent AP ON AP.[SiteID] = MA.[SiteID]
LEFT JOIN #ConsistencyRating CR ON CR.[SiteID] = MA.[SiteID]
LEFT JOIN #VisitsEnteredOne VEO ON VEO.[SiteNumber] = MA.[SiteID]
LEFT JOIN #AvgLagOne ALO ON ALO.[SiteID] = MA.[SiteID]
LEFT JOIN #VisitsEnteredTwo VET ON VET.[SiteNumber] = MA.[SiteID]
LEFT JOIN #AvgLagTwo ALT ON ALT.[SiteID] = MA.[SiteID]
LEFT JOIN #ChangeScore CS ON CS.[SiteID] = MA.[SiteID]
LEFT JOIN #DirectionOfChange DOC ON DOC.[SiteID] = MA.[SiteID]
ORDER BY MA.[SiteID]

--UNION ALL

--SELECT 
--		'All Sites' AS [SiteID]
--	   ,MAX(MA.[MonthsActive]) AS [MonthsActive]
--	   ,SUM(NE.[NonExited]) AS [NonExited]
--	   ,SUM(E.[Exited]) AS [Exited]
--	   ,CAST((SUM(AVM.[TotalVisits])/12.0) AS DECIMAL(5,1)) AS [AvgVisitsPerMonth]
--	   ,SUM(NMA.[NineMonthActiveCount])
--	   ,SUM(CE.[ConfirmedEvents])
--	   ,SUM(RD.[RetrievedDocs])
--	   ,ROUND(SUM(CAST(RD.[RetrievedDocs])AS FLOAT)/SUM(CAST(CE.[ConfirmedEvents] AS FLOAT)),2) AS [DocRetrievalPercent]
--	   ,ROUND(SUM(CAST(NMA.[NineMonthActiveCount] AS FLOAT))/SUM(CAST(NE.[NonExited] AS FLOAT)),2) AS [ActivePercent]
--	   ,CASE 
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .91 AND 1 THEN 'Very High'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .96 AND .90 THEN 'High'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .81 AND .85 THEN 'Above Average'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .71 AND .80 THEN 'Average'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .61 AND .70 THEN 'Below Average'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .41 AND .60 THEN 'Low'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) BETWEEN .31 AND .40 THEN 'Very Low'
--			WHEN ROUND((SUM(NMA.[NineMonthActiveCount])/SUM(NE.[NonExited])),2) <= .30 THEN 'At risk'
--			ELSE NULL
--		END AS [ConsistencyRating]
--	   ,SUM(VEO.[VisitsEnteredOne])
--	   ,(SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])) AS [AvgLagOne]
--	   ,CASE
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) <=5 THEN 'Very Fast'
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 6 AND 10 THEN 'Fast'
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 11 AND 20 THEN 'Above Average'
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 21 AND 30 THEN 'Average'
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 31 AND 40 THEN 'Below Average'
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 61 AND 90 THEN 'Slow'
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) >91 THEN 'Very Slow'
--		 	ELSE 'No Visits'
--		 END AS [SpeedRatingOne]
--	   ,CASE
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) <=5 THEN CAST('7' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 6 AND 10 THEN CAST('6' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 11 AND 20 THEN CAST('5' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 21 AND 30 THEN CAST('4' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 31 AND 40 THEN CAST('3' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) BETWEEN 61 AND 90 THEN CAST('2' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELO.[DifferenceInDays])/SUM(VEO.[VisitsEnteredOne])),2) >91 THEN CAST('1' AS SMALLINT)
--		 	ELSE CAST('-1' AS SMALLINT)
--		 END AS [SpeedScoreOne]
--	   ,SUM(VET.[VisitsEnteredTwo])
--	   ,(SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo]) AS [AvgLagTwo]
--	   ,CASE
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) <=5 THEN 'Very Fast'
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 6 AND 10 THEN 'Fast'
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 11 AND 20 THEN 'Above Average'
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 21 AND 30 THEN 'Average'
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 31 AND 40 THEN 'Below Average'
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 61 AND 90 THEN 'Slow'
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) >91 THEN 'Very Slow'
--		 	ELSE 'No Visits'
--		 END AS [SpeedRatingTwo]
--	   ,CASE
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) <=5 THEN CAST('7' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 6 AND 10 THEN CAST('6' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 11 AND 20 THEN CAST('5' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 21 AND 30 THEN CAST('4' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 31 AND 40 THEN CAST('3' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) BETWEEN 61 AND 90 THEN CAST('2' AS SMALLINT)
--		 	WHEN ROUND((SUM(VELT.[DifferenceInDays])/SUM(VET.[VisitsEnteredTwo])),2) >91 THEN CAST('1' AS SMALLINT)
--		 	ELSE CAST('-1' AS SMALLINT)
--		 END AS [SpeedScoreTwo]
--	   --,CS.[ChangeScore]
--	   --,DOC.[DirectionOfChange]
--
--FROM #MonthsActive MA
--LEFT JOIN #NonExited NE ON NE.[SiteID] = MA.[SiteID]
--LEFT JOIN #Exited E ON E.[SiteID] = MA.[SiteID]
--LEFT JOIN #AvgVisitsPerMonth AVM ON AVM.[SiteID] = MA.[SiteID]
--LEFT JOIN #NineMonthActive NMA ON NMA.[SiteID] = MA.[SiteID]
--LEFT JOIN #ConfirmedEvents CE ON CE.[SiteID] = MA.[SiteID]
--LEFT JOIN #RetrievedDocs RD ON RD.[SiteID] = MA.[SiteID]
--LEFT JOIN #DocsRetrievalPercent DRP ON DRP.[SiteID] = MA.[SiteID]
--LEFT JOIN #ActivePercent AP ON AP.[SiteID] = MA.[SiteID]
--LEFT JOIN #ConsistencyRating CR ON CR.[SiteID] = MA.[SiteID]
--LEFT JOIN #VisitsEnteredListOne VELO ON VELO.[SiteID] = MA.[SiteID]
--LEFT JOIN #VisitsEnteredOne VEO ON VEO.[SiteNumber] = MA.[SiteID]
--LEFT JOIN #AvgLagOne ALO ON ALO.[SiteID] = MA.[SiteID]
--LEFT JOIN #VisitsEnteredListTwo VELT ON VELT.[SiteID] = MA.[SiteID]
--LEFT JOIN #VisitsEnteredTwo VET ON VET.[SiteNumber] = MA.[SiteID]
--LEFT JOIN #AvgLagTwo ALT ON ALT.[SiteID] = MA.[SiteID]
--LEFT JOIN #ChangeScore CS ON CS.[SiteID] = MA.[SiteID]
--LEFT JOIN #DirectionOfChange DOC ON DOC.[SiteID] = MA.[SiteID]
--ORDER BY [SiteID]
GO
