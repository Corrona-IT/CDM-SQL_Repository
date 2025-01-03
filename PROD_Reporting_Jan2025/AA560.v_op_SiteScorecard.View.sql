USE [Reporting]
GO
/****** Object:  View [AA560].[v_op_SiteScorecard]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =================================================
-- Author:		Kevin Soe
-- Create date: 3/28/2023
-- Description:	View for AA tab of Site Scorecard 
-- =================================================
		 --SELECT * FROM
CREATE VIEW [AA560].[v_op_SiteScorecard] AS
	-- Add the parameters for the stored procedure here


--Get Months Active

WITH MonthsActive AS

(
SELECT  SS.[SiteID]
	   ,SS.[SiteStatus]
	   ,RS.[currentStatus] AS [SalesforceStatus]
	   ,CASE WHEN RS.[TopEnrollingSite] = 'Yes' THEN 'Yes'
	    ELSE 'No'
		END AS [TopEnrollingSite]
	   ,CAST((DATEDIFF(d,MIN(VL.[VisitDate]),(CAST(GETDATE() AS DATE)))/30.0) AS decimal(4,1)) AS [MonthsActive]
-- SELECT *
FROM [AA560].[v_SiteStatus] SS --SELECT * FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog]
LEFT JOIN [regetlprod].[Reporting].[AA560].[t_op_VisitLog]  VL ON VL.[SiteID] = SS.[SiteID]
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] = SS.[SiteID]
WHERE RS.[name] LIKE 'Alopecia Areata (AA-560)'
AND RS.[currentStatus] IN ('Approved / Active', 'On hold (active)', 'Pending closeout', 'Closed / Completed')
GROUP BY SS.[SiteID], SS.[SiteStatus], RS.[currentStatus], RS.[TopEnrollingSite]
),

--Get Total Non-Exited

NonExited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [NonExited]

FROM [regetlprod].[Reporting].[AA560].[t_op_PatientVisitTracker]
GROUP BY [SiteID]
),

--Get Total Exited

Exited AS

(
SELECT
	    [SiteID]
	   ,COUNT([SiteID]) AS [Exited]

FROM [regetlprod].[Reporting].[AA560].[t_op_SubjectLog]
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

FROM [AA560].[v_SiteStatus] SS
LEFT JOIN [regetlprod].[Reporting].[AA560].[t_op_VisitLog] VL ON VL.[SiteID] = SS.[SiteID]
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

FROM [regetlprod].[Reporting].[AA560].[t_op_PatientVisitTracker]
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
FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing]
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

FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing]
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

FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing]
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [SupportDocsApproved] = 'Yes'
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

FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing]
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [SupportDocsApproved] = 'Yes'
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
),

--Determine how much Enrollment & Follow-up visits each site has contribution to the registry total all time

DataContributionAllTime AS
(
SELECT
'AA-560' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total] 
FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Alopecia Areata (AA-560)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]
),

DataContribution12Mos AS
(
SELECT
'AA-560' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total] --SELECT *
FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Alopecia Areata (AA-560)'
AND [VisitDate] IS NOT NULL
--AND [VisitDate] >= CAST(DATEADD(MONTH,-12,GETDATE()) AS DATE) 
--AND [VisitDate] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]
),

RegSiteTotals AS
(
SELECT
		  'All Time' AS [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 ,[VisitType]
		 ,[Total]
		 FROM DataContributionAllTime 
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
		 FROM DataContribution12Mos
		 GROUP BY [Registry], [SiteID], [TopEnrollingSite], [VisitType], [TopEnrollingSite], [SiteStatus], [Total]


),

SiteENFUs AS 
(
SELECT
		  [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 --,[VisitType]
		 ,SUM([Total]) AS [SiteENFUTotal]
		 FROM RegSiteTotals
		 WHERE [VisitType] <> 'Exit'
		 GROUP BY [TimePeriod], [Registry], [SiteID], [TopEnrollingSite], [SiteStatus]
),

RegENFUs AS 
(
SELECT
		  [TimePeriod]
		 ,[Registry]
		 --,[VisitType]
		 ,SUM([Total]) AS [RegENFUTotal]
		 FROM RegSiteTotals
		 WHERE [VisitType] <> 'Exit'
		 GROUP BY [TimePeriod], [Registry]
),

DataContribution AS
(
SELECT
	 S.[TimePeriod]
	,S.[Registry]
	,S.[SiteID]
	,S.[SiteStatus]
	,S.[TopEnrollingSite]
	,S.[SiteENFUTotal]
	,R.[RegENFUTotal]
	,((CAST(S.[SiteENFUTotal] AS numeric)/CAST(R.[RegENFUTotal] AS numeric))) AS [DataContribution]
	FROM SiteENFUs S
	LEFT JOIN RegENFUs R ON S.[Registry] = R.[Registry] AND S.[TimePeriod] = R.[TimePeriod]
),

--Determine cumulative sum of data contribution from highest to lowest

RunningDC AS 
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
FROM DataContribution
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
FROM DataContribution
WHERE [TimePeriod] = '12 Mos'
),

ConductedICCVs12Mos AS
(
SELECT
		[Registry_Protocol_ID__c] AS [Registry]
        ,[name] AS [DQRNumber]
		,CAST([Site_Number__c] AS INT) AS [SiteID]
		,CASE 
                                           WHEN [DQR_Type__c] = 'ICCV-L' THEN 'ICCV-L1'
                                           ELSE [DQR_Type__c]
                                 END AS [DQRType]
		,MAX(CAST([Date_Visit_Conducted__c] AS DATE)) AS [Date]
		,[Status__c] AS [Status] --SELECT *
FROM [Salesforce].[dbo].[dataQualityReview]
WHERE [Date_Visit_Conducted__c] IS NOT NULL
AND [Date_Visit_Conducted__c] >= CAST(DATEADD(MONTH,-12,GETDATE()) AS DATE) 
--AND [Date_Visit_Conducted__c] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
--AND [DQR_Type__c] IN ('ICCV-EN','ICCV-L','ICCV-L1','ICCV-L+')
AND [Registry_Protocol_ID__c] = 'AA-560'
GROUP BY [Registry_Protocol_ID__c], [name] , [Site_Number__c], [DQR_Type__c], [Status__c]
),

ConductedICCVsCounts AS
(
SELECT 
 [Registry]
,[SiteID]
,COUNT([SiteID]) AS [ConductedICCVs]
FROM ConductedICCVs12Mos
GROUP BY [Registry], [SiteId]
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
LEFT JOIN DataContribution DCAT ON DCAT.[SiteID] = MA.[SiteID] AND DCAT.[TimePeriod] = 'All Time'
LEFT JOIN DataContribution DC12 ON DC12.[SiteID] = MA.[SiteID] AND DC12.[TimePeriod] = '12 Mos'
LEFT JOIN RunningDC RDCAT ON RDCAT.[SiteID] = MA.[SiteID] AND RDCAT.[TimePeriod] = 'All Time'
LEFT JOIN RunningDC RDC12 ON RDC12.[SiteID] = MA.[SiteID] AND RDC12.[TimePeriod] = '12 Mos'
LEFT JOIN ConductedICCVsCounts CIC ON CIC.[SiteID] = MA.[SiteID]



GO
