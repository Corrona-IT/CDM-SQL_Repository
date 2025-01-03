USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_SiteScorecard]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- =================================================
-- Author:		Kevin Soe
-- Create date: 10/7/2019
-- V2 Update date: 4/1/2020
-- V3 Update date: 10/6/2020
-- V4 Update date: 11/8/2021 -View was converted to procedure for V4
-- Description:	Procedure for RA US Site Scorecard.
-- =================================================
			--SELECT * FROM
			  --EXECUTE
CREATE PROCEDURE [RA100].[usp_op_SiteScorecard] AS
	-- Add the parameters for the stored procedure here

--DECLARE @TP1StartEntryDate DATETIME
--DECLARE @TP1EndEntryDate DATETIME
--DECLARE @TP2StartEntryDate DATETIME
--DECLARE @TP2EndEntryDate DATETIME

--Exclude Visits with Visit Dates Prior to 3/25/2013, the release date TM 

/*
			 SELECT * FROM
CREATE TABLE [RA100].[t_op_SiteScorecard]
(
	[SiteID] [int] NULL,
	[SiteStatus] [varchar](8) NULL,
	[SalesforceStatus] [varchar](20) NULL,
	[TopEnrollingSite] [varchar](3) NULL,
	[MonthsActive] [float] NULL,
	[NonExited] [int] NULL,
	[Exited] [int] NULL,
	[TotalVisits] [int] NULL,
	[AvgVisitsPerMonth] [decimal](5,1) NULL,
	[NineMonthActiveCount] [int] NULL,
	[ConfirmedEvents] [int] NULL,
	[ExpectedEvents] [int] NULL,
	[RetrievedDocs] [int] NULL,
	[DocRetrievalPercent] [float] NULL,
	[AllTimeConfirmedEvents] [int] NULL,
	[AllTimeRetrievedDocs] [int] NULL,
	[AllTimeDocRetrievalPercent] [float] NULL,
	[ActivePercent] [float] NULL,
	[ConsistencyRating] [varchar](13) NULL,
	[DataContributionAllTime] [numeric](37,19) NULL,
	[RunningDataContributionAllTime] [numeric](37,19) NULL,
	[Top80AllTime] [nvarchar](10) NULL,
	[DataContribution12Mos] [numeric](37,19) NULL,
	[RunningDataContribution12Mos] [numeric](37,19) NULL,
	[Top8012Mos] [nvarchar](10) NULL,
	[ConductedICCVs] [int] NULL
);
INSERT INTO [RA100].[t_op_SiteScorecard]
SELECT * FROM [10.0.3.123].[Reporting].[RA100].[t_op_SiteScorecard]
*/

TRUNCATE TABLE [Reporting].[RA100].[t_op_SiteScorecard];

IF OBJECT_ID('tempdb.dbo.#VL') IS NOT NULL BEGIN DROP TABLE #VL END
--WITH VL AS 
--(
SELECT * 
INTO #VL
FROM [Reporting].[RA100].[v_op_VisitLog]
WHERE [VisitDate] >= '3/25/2013'
--),

IF OBJECT_ID('tempdb.dbo.#FPI') IS NOT NULL BEGIN DROP TABLE #FPI END
--FPI AS
--(
SELECT * 
INTO #FPI
FROM [Reporting].[RA100].[t_FPIDates]
--),

--Get Months Active

IF OBJECT_ID('tempdb.dbo.#MonthsActive') IS NOT NULL BEGIN DROP TABLE #MonthsActive END
--MonthsActive AS
--(
SELECT  SS.[SiteID]
	   ,SS.[SiteStatus]
	   ,RS.[currentStatus] AS [SalesforceStatus]
	   ,CASE WHEN RS.[TopEnrollingSite] = 'Yes' THEN 'Yes'
	    ELSE 'No'
		END AS [TopEnrollingSite]
	   ,CASE WHEN FPI.[FPIDate] <> '' THEN ROUND(CAST((DATEDIFF(d,FPI.[FPIDate],(CAST(GETDATE() AS DATE)))/30.0) AS FLOAT),1)
	    ELSE ROUND(CAST((DATEDIFF(d,MIN(VL.[VisitDate]),(CAST(GETDATE() AS DATE)))/30.0) AS FLOAT),1)
		END AS [MonthsActive]
-- SELECT * 
INTO #MonthsActive
FROM [RA100].[v_op_SiteStatus] SS
LEFT JOIN #FPI FPI ON FPI.[SiteID] = SS.[SiteID]
LEFT JOIN #VL VL ON VL.[SiteID] = SS.[SiteID]
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] = SS.[SiteID]
WHERE RS.[name] LIKE 'Rheumatoid Arthritis (RA-100,02-021)'
AND RS.[currentStatus] IN ('Approved / Active', 'On hold (active)', 'Pending closeout', 'Closed / Completed')
GROUP BY SS.[SiteID], SS.[SiteStatus], RS.[currentStatus], FPI.[FPIDate], RS.[TopEnrollingSite]
--),

--Get Total Non-Exited

IF OBJECT_ID('tempdb.dbo.#NonExited') IS NOT NULL BEGIN DROP TABLE #NonExited END
--NonExited AS
--(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [NonExited]

INTO #NonExited
FROM [Reporting].[RA100].[t_op_PatientVisitTracker]
GROUP BY [SiteID]
--),

--Get Total Exited

IF OBJECT_ID('tempdb.dbo.#Exited') IS NOT NULL BEGIN DROP TABLE #Exited END
--Exited AS
--(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [Exited]

--SELECT *
INTO #Exited
FROM [Reporting].[RA100].[v_op_SubjectLog]
WHERE [ExitDate] IS NOT NULL
GROUP BY [SiteID]
--),

--Determine Avg Visits / mo. (12 mo.)

IF OBJECT_ID('tempdb.dbo.#AvgVisitsPerMonth') IS NOT NULL BEGIN DROP TABLE #AvgVisitsPerMonth END
--AvgVisitsPerMonth AS
--(
SELECT
	    SS.[SiteID]
	   ,CAST((COUNT(VL.[SiteID])/12.0) AS DECIMAL(5,1)) AS [AvgVisitsPerMonth]
	   ,COUNT(VL.[SiteID]) AS [TotalVisits]
	  --,[VisitDate]
	  --,CAST(DATEADD(MONTH,-14,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [14MonthsBack]
	  --,CAST(DATEADD(MONTH,-2,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [2MonthsBack]
	  --,CAST(DATEADD(MONTH,-16,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [16MonthsBack]
	  --,CAST(DATEADD(MONTH,-4,DATEADD(DAY,1-DAY(GETDATE()),GETDATE())) AS DATE) AS [4MonthsBack]

INTO #AvgVisitsPerMonth
FROM [RA100].[v_op_SiteStatus] SS
LEFT JOIN [Reporting].[RA100].[v_op_VisitLog] VL ON VL.[SiteID] = SS.[SiteID]
WHERE [VisitType] IN ('Enrollment', 'Follow-up')
AND [VisitDate] >= CAST(DATEADD(MONTH,-14,GETDATE()) AS DATE) 
AND [VisitDate] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
GROUP BY SS.[SiteID]
--), 

--Determine 9 mo. active count

IF OBJECT_ID('tempdb.dbo.#NineMonthActive') IS NOT NULL BEGIN DROP TABLE #NineMonthActive END
--NineMonthActive AS
--(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) [NineMonthActiveCount]

INTO #NineMonthActive
FROM [Reporting].[RA100].[t_op_PatientVisitTracker]
WHERE [MonthsSinceLastVisit] <= 9
GROUP BY [SiteID]
--),

--Determine Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

IF OBJECT_ID('tempdb.dbo.#ConfirmedEvents') IS NOT NULL BEGIN DROP TABLE #ConfirmedEvents END
--ConfirmedEvents AS
--(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [ConfirmedEvents]
--SELECT *
INTO #ConfirmedEvents
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
--),

--Determine All Time Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

IF OBJECT_ID('tempdb.dbo.#AllTimeConfirmedEvents') IS NOT NULL BEGIN DROP TABLE #AllTimeConfirmedEvents END
--AllTimeConfirmedEvents AS
--(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [AllTimeConfirmedEvents]
--SELECT *
INTO #AllTimeConfirmedEvents
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
--),

--Determine Expected Events NineMonthActive *.075

IF OBJECT_ID('tempdb.dbo.#ExpectedEvents') IS NOT NULL BEGIN DROP TABLE #ExpectedEvents END
--ExpectedEvents AS
--(
SELECT
		[SiteID]
	   ,CAST(ROUND((NMA.[NineMonthActiveCount] * .075),0) AS INT) AS [ExpectedEvents]

INTO #ExpectedEvents
FROM #NineMonthActive NMA
--),

--Determine Docs that have been retrieved for Confirmed TAEs

IF OBJECT_ID('tempdb.dbo.#RetrievedDocs') IS NOT NULL BEGIN DROP TABLE #RetrievedDocs END
--RetrievedDocs AS
--(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [RetrievedDocs]

INTO #RetrievedDocs
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
--),

--Determine Docs that have been retrieved for Confirmed TAEs All Time

IF OBJECT_ID('tempdb.dbo.#AllTimeRetrievedDocs') IS NOT NULL BEGIN DROP TABLE #AllTimeRetrievedDocs END
--AllTimeRetrievedDocs AS
--(
SELECT
		[SiteID]
	   ,COUNT([SiteID]) AS [AllTimeRetrievedDocs]

INTO #AllTimeRetrievedDocs
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
--),

--Determine Doc Retrieval %

IF OBJECT_ID('tempdb.dbo.#DocsRetrievalPercent') IS NOT NULL BEGIN DROP TABLE #DocsRetrievalPercent END
--DocsRetrievalPercent AS
--(
SELECT
		CE.[SiteID]
	   ,CASE 
			WHEN ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) IS NULL THEN CAST(0 AS FLOAT)
			ELSE ROUND(CAST(RD.[RetrievedDocs] AS FLOAT)/CAST(CE.[ConfirmedEvents] AS FLOAT),2) 
			END AS [DocRetrievalPercent]
INTO #DocsRetrievalPercent
FROM #ConfirmedEvents CE
LEFT JOIN #RetrievedDocs RD ON RD.[SiteID] = CE.[SiteID]
--),

--Determine Doc Retrieval % All Time

IF OBJECT_ID('tempdb.dbo.#AllTimeDocsRetrievalPercent') IS NOT NULL BEGIN DROP TABLE #AllTimeDocsRetrievalPercent END
--AllTimeDocsRetrievalPercent AS
--(
SELECT
		ATCE.[SiteID]
	   ,CASE 
			WHEN ROUND(CAST(ATRD.[AllTimeRetrievedDocs] AS FLOAT)/CAST(ATCE.[AllTimeConfirmedEvents] AS FLOAT),2) IS NULL THEN CAST(0 AS FLOAT)
			ELSE ROUND(CAST(ATRD.[AllTimeRetrievedDocs] AS FLOAT)/CAST(ATCE.[AllTimeConfirmedEvents] AS FLOAT),2) 
			END AS [AllTimeDocRetrievalPercent]
INTO #AllTimeDocsRetrievalPercent
FROM #AllTimeConfirmedEvents ATCE
LEFT JOIN #AllTimeRetrievedDocs ATRD ON ATRD.[SiteID] = ATCE.[SiteID]
--),

--Determine Active %

IF OBJECT_ID('tempdb.dbo.#ActivePercent') IS NOT NULL BEGIN DROP TABLE #ActivePercent END
--ActivePercent AS
--(
SELECT
		NE.[SiteID]
	   ,ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) AS [ActivePercent]

INTO #ActivePercent
FROM #NonExited NE
JOIN #NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]
--),

--Determine Consistency Rating

IF OBJECT_ID('tempdb.dbo.#ConsistencyRating') IS NOT NULL BEGIN DROP TABLE #ConsistencyRating END
--ConsistencyRating AS
--(
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

INTO #ConsistencyRating
FROM #NonExited NE
JOIN #NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]
--),

IF OBJECT_ID('tempdb.dbo.#DataContributionAllTime') IS NOT NULL BEGIN DROP TABLE #DataContribution24Mos END
--DataContribution24Mos AS
--(
SELECT 
'RA-100' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
      ,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
INTO #DataContributionAllTime
FROM [Reporting].[RA100].[v_op_VisitLog_V3] V
      LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
      ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)'
                              --Visit Date filter included for some reason in V1. Not Sure Why.                                         --This Led to Inconsistent Site Totals
                              --AND [VisitDate] >= '3/25/2013'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


IF OBJECT_ID('tempdb.dbo.#DataContribution12Mos') IS NOT NULL BEGIN DROP TABLE #DataContribution12Mos END
--DataContribution12Mos AS
--(
SELECT 
'RA-100' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
      ,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
INTO #DataContribution12Mos
FROM [Reporting].[RA100].[v_op_VisitLog_V3] V
      LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
      ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)'
                              --Visit Date filter included for some reason in V1. Not Sure Why.                                         --This Led to Inconsistent Site Totals
                              --AND [VisitDate] >= '3/25/2013'
AND [VisitDate] IS NOT NULL
AND [VisitDate] >= CAST(DATEADD(MONTH,-12,GETDATE()) AS DATE) 
--AND [VisitDate] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]
--),

IF OBJECT_ID('tempdb.dbo.#RegSiteTotals') IS NOT NULL BEGIN DROP TABLE #RegSiteTotals END
--RegSiteTotals AS
--(
SELECT * 
INTO #RegSiteTotals
FROM 
(
SELECT
		  'All Time' AS [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 ,[VisitType]
		 ,[Total]
		 FROM #DataContributionAllTime 
		 GROUP BY [Registry], [SiteID], [TopEnrollingSite], [VisitType], [TopEnrollingSite], [SiteStatus], [Total]
		 

UNION

SELECT
		  '12 Mos' AS [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 ,[VisitType]
		 ,[Total]
		 FROM #DataContribution12Mos
		 GROUP BY [Registry], [SiteID], [TopEnrollingSite], [VisitType], [TopEnrollingSite], [SiteStatus], [Total]
) RST


--),

IF OBJECT_ID('tempdb.dbo.#SiteENFUs') IS NOT NULL BEGIN DROP TABLE #SiteENFUs END
--SiteENFUs AS 
--(
SELECT
		  [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 --,[VisitType]
		 ,SUM([Total]) AS [SiteENFUTotal]
		 INTO #SiteENFUs
		 FROM #RegSiteTotals
		 WHERE [VisitType] <> 'Exit'
		 GROUP BY [TimePeriod], [Registry], [SiteID], [TopEnrollingSite], [SiteStatus]
--),

IF OBJECT_ID('tempdb.dbo.#RegENFUs') IS NOT NULL BEGIN DROP TABLE #RegENFUs END
--RegENFUs AS 
--(
SELECT
		  [TimePeriod]
		 ,[Registry]
		 --,[VisitType]
		 ,SUM([Total]) AS [RegENFUTotal]
		 INTO #RegENFUs
		 FROM #RegSiteTotals
		 WHERE [VisitType] <> 'Exit'
		 GROUP BY [TimePeriod], [Registry]
--),

IF OBJECT_ID('tempdb.dbo.#DataContribution') IS NOT NULL BEGIN DROP TABLE #DataContribution END
--DataContribution AS
--(
SELECT
	 S.[TimePeriod]
	,S.[Registry]
	,S.[SiteID]
	,S.[SiteStatus]
	,S.[TopEnrollingSite]
	,S.[SiteENFUTotal]
	,R.[RegENFUTotal]
	,((CAST(S.[SiteENFUTotal] AS numeric)/CAST(R.[RegENFUTotal] AS numeric))) AS [DataContribution]
	INTO #DataContribution
	FROM #SiteENFUs S
	LEFT JOIN #RegENFUs R ON S.[Registry] = R.[Registry] AND S.[TimePeriod] = R.[TimePeriod]
--)


--Determine cumulative sum of data contribution from highest to lowest
IF OBJECT_ID('tempdb.dbo.#RunningDC') IS NOT NULL BEGIN DROP TABLE #RunningDC END
--RunningDC AS 
--(
SELECT * 
INTO #RunningDC 
FROM
(
SELECT
	 [TimePeriod]
	,[Registry]
	,[SiteID]
	,[SiteStatus]
	,[TopEnrollingSite]
	,[SiteENFUTotal]
	,[RegENFUTotal]
	,[DataContribution]
	,SUM([DataContribution]) OVER (ORDER BY [TimePeriod], [DataContribution] DESC) AS [RunningDataContribution]
FROM #DataContribution
WHERE [TimePeriod] = 'All Time'


UNION

SELECT
	 [TimePeriod]
	,[Registry]
	,[SiteID]
	,[SiteStatus]
	,[TopEnrollingSite]
	,[SiteENFUTotal]
	,[RegENFUTotal]
	,[DataContribution]
	,SUM([DataContribution]) OVER (ORDER BY [TimePeriod], [DataContribution] DESC) AS [RunningDataContribution]

FROM #DataContribution
WHERE [TimePeriod] = '12 Mos'
) AS RDC

IF OBJECT_ID('tempdb.dbo.#ConductedICCVs12Mos') IS NOT NULL BEGIN DROP TABLE ConductedICCVs24Mos END
--ConductedICCVs24Mos AS
--(
SELECT
		[Registry_Protocol_ID__c] AS [Registry]
        ,[name] AS [DQRNumber]
		,CAST([Site_Number__c] AS INT) AS [SiteID]
		,CASE 
                                           WHEN [DQR_Type__c] = 'ICCV-L' THEN 'ICCV-L1'
                                           ELSE [DQR_Type__c]
                                 END AS [DQRType]
		,MAX(CAST([Date_Visit_Conducted__c] AS DATE)) AS [Date]
		,[Status__c] AS [Status]
INTO #ConductedICCVs12Mos
FROM [Salesforce].[dbo].[dataQualityReview]
WHERE [Date_Visit_Conducted__c] IS NOT NULL
AND [Date_Visit_Conducted__c] >= CAST(DATEADD(MONTH,-12,GETDATE()) AS DATE) 
--AND [Date_Visit_Conducted__c] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
--AND [DQR_Type__c] IN ('ICCV-EN','ICCV-L','ICCV-L1','ICCV-L+')
AND [Registry_Protocol_ID__c] = 'RA-100'
GROUP BY [Registry_Protocol_ID__c], [name] , [Site_Number__c], [DQR_Type__c], [Status__c]
--)

IF OBJECT_ID('tempdb.dbo.#ConductedICCVsCounts') IS NOT NULL BEGIN DROP TABLE ConductedICCVsCounts END
--ConductedICCVsCounts AS
--(
SELECT 
 [Registry]
,[SiteID]
,COUNT([SiteID]) AS [ConductedICCVs]
INTO #ConductedICCVsCounts
FROM #ConductedICCVs12Mos
GROUP BY [Registry], [SiteId]
--)


INSERT INTO [Reporting].[RA100].[t_op_SiteScorecard]
(
	   [SiteID]
      ,[SiteStatus]
      ,[SalesforceStatus]
      ,[TopEnrollingSite]
      ,[MonthsActive]
      ,[NonExited]
      ,[Exited]
      ,[TotalVisits]
      ,[AvgVisitsPerMonth]
      ,[NineMonthActiveCount]
      ,[ConfirmedEvents]
      ,[ExpectedEvents]
      ,[RetrievedDocs]
      ,[DocRetrievalPercent]
      ,[AllTimeConfirmedEvents]
      ,[AllTimeRetrievedDocs]
      ,[AllTimeDocRetrievalPercent]
      ,[ActivePercent]
      ,[ConsistencyRating]
      ,[DataContributionAllTime]
	  ,[RunningDataContributionAllTime]
	  ,[Top80AllTime]
      ,[DataContribution12Mos]
	  ,[RunningDataContribution12Mos]
	  ,[Top8012Mos]
	  ,[ConductedICCVs]
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
	   ,DCAT.[DataContribution] AS [DataContributionAllTime]
	   ,RDCAT.[RunningDataContribution] AS [RunningDataContributionAllTime]
	   ,CASE
			WHEN RDCAT.[RunningDataContribution] <= .8 THEN 'Yes'
			ELSE 'No'
		END AS [Top80AllTime]
	   ,DC12.[DataContribution] AS [DataContribution12Mos]
	   ,RDC12.[RunningDataContribution] AS [RunningDataContribution12Mos]
	   	   ,CASE
			WHEN RDC12.[RunningDataContribution] <= .8 THEN 'Yes'
			ELSE 'No'
		END AS [Top8012Mos]
	    ,CIC.[ConductedICCVs]

FROM #MonthsActive MA
LEFT JOIN #NonExited NE ON NE.[SiteID] = MA.[SiteID]
LEFT JOIN #Exited E ON E.[SiteID] = MA.[SiteID]
LEFT JOIN #AvgVisitsPerMonth AVM ON AVM.[SiteID] = MA.[SiteID]
LEFT JOIN #NineMonthActive NMA ON NMA.[SiteID] = MA.[SiteID]
LEFT JOIN #ConfirmedEvents CE ON CE.[SiteID] = MA.[SiteID]
LEFT JOIN #ExpectedEvents EE ON EE.[SiteID] = MA.[SiteID]
LEFT JOIN #RetrievedDocs RD ON RD.[SiteID] = MA.[SiteID]
LEFT JOIN #DocsRetrievalPercent DRP ON DRP.[SiteID] = MA.[SiteID]
LEFT JOIN #AllTimeConfirmedEvents ATCE ON ATCE.[SiteID] = MA.[SiteID]
LEFT JOIN #AllTimeRetrievedDocs ATRD ON ATRD.[SiteID] = MA.[SiteID]
LEFT JOIN #AllTimeDocsRetrievalPercent ATDRP ON ATDRP.[SiteID] = MA.[SiteID]
LEFT JOIN #ActivePercent AP ON AP.[SiteID] = MA.[SiteID]
LEFT JOIN #ConsistencyRating CR ON CR.[SiteID] = MA.[SiteID]
LEFT JOIN #DataContribution DCAT ON DCAT.[SiteID] = MA.[SiteID] AND DCAT.[TimePeriod] = 'All Time'
LEFT JOIN #DataContribution DC12 ON DC12.[SiteID] = MA.[SiteID] AND DC12.[TimePeriod] = '12 Mos'
LEFT JOIN #RunningDC RDCAT ON RDCAT.[SiteID] = MA.[SiteID] AND RDCAT.[TimePeriod] = 'All Time'
LEFT JOIN #RunningDC RDC12 ON RDC12.[SiteID] = MA.[SiteID] AND RDC12.[TimePeriod] = '12 Mos'
LEFT JOIN #ConductedICCVsCounts CIC ON CIC.[SiteID] = MA.[SiteID]




















GO
