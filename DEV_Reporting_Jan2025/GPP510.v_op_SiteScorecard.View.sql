USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SiteScorecard]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [GPP510].[v_op_SiteScorecard] AS

WITH MonthsActive AS

(
SELECT 
    SS.[SiteNumber] AS SiteID,
    SS.[SiteStatus],
    SS.[currentStatus] AS [SalesforceStatus],
    CASE 
        WHEN SS.[TopEnrollingSite] = 'Yes' THEN 'Yes'
        ELSE 'No'
    END AS [TopEnrollingSite],
    CAST((DATEDIFF(d, MIN(VL.[VisitDate]), CAST(GETDATE() AS DATE)) / 30.0) AS DECIMAL(4,1)) AS [MonthsActive]
FROM [GPP510].[v_op_SiteStatusView] SS
LEFT JOIN [Reporting].[GPP510].[v_op_VisitLog] VL ON VL.[SiteID] = SS.[SiteNumber]

WHERE 1=1 AND
    SS.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
    AND SS.[currentStatus] IN ('Approved / Active', 'Pending closeout', 'Closed / Completed')
	AND VisitType='Enrollment'
GROUP BY 
    SS.[SiteNumber], 
    SS.[SiteStatus], 
    SS.[currentStatus], 
    SS.[TopEnrollingSite]
),

--SELECT DISTINCT [currentStatus] FROM [Salesforce].[dbo].[registryStatus]
-------------------------------------------------------------------
--Get Total Non-Exited

NonExited AS
(
SELECT [SiteID]
	   ,COUNT([SubjectID]) AS [NonExited]
FROM GPP510.v_op_subjectlog
WHERE exit_date IS NULL
GROUP BY [SiteID]
),


--Get Total Exited

Exited AS
(
SELECT [SiteID]
	   ,COUNT([SiteID]) AS [Exited]
FROM GPP510.v_op_subjectlog
WHERE exit_date IS NOT NULL
GROUP BY [SiteID]
),


--Determine Avg Visits / mo. (12 mo.)

AvgVisitsPerMonth AS
(
SELECT
	    SS.[SiteNumber] as SiteID
	   ,CAST((COUNT(VL.[SiteID])/12.0) AS DECIMAL(5,1)) AS [AvgVisitsPerMonth]
	   ,COUNT(VL.[SiteID]) AS [TotalVisits]
 
 FROM [GPP510].[v_op_SiteStatusView] SS
LEFT JOIN [Reporting].GPP510.v_op_VisitLog  VL ON VL.[SiteID] = SS.[SiteNumber]

WHERE 1=1 
	AND visittype in ('Enrollment', 'Follow-Up (Non-flaring)')
AND [VisitDate] >= CAST(DATEADD(MONTH,-14,GETDATE()) AS DATE) 
AND [VisitDate] <= CAST(DATEADD(MONTH,-2,GETDATE()) AS DATE)
GROUP BY SS.[SiteNumber]
), 


--Determine 9 mo. active count

NineMonthActive AS (
    SELECT
        [SiteID],
        COUNT([SiteID]) AS [NineMonthActiveCount]

    FROM [GPP510].[v_op_SubjectFollowupTracker]
	WHERE [MonthsSinceLastVisit] <= 9
    GROUP BY [SiteID]
),



--Determine lAST 12 MONTHS Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

ConfirmedEvents AS
(
SELECT SITENUM as SiteID
	   ,COUNT([SUBNUM]) AS [ConfirmedEvents]
FROM GPP510.t_pv_TAEQCListing
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [OnsetDate] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [OnsetDate] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [Sitenum]
),



--Determine All Time Confirmed Events. Excludes Pregnancies. Only TAEs can have ReportType = 'Confirmed event'.

AllTimeConfirmedEvents AS
(
SELECT Sitenum as SiteID
	   ,COUNT([Subnum]) AS [AllTimeConfirmedEvents]
FROM GPP510.t_pv_TAEQCListing
WHERE [ConfirmationStatus] = 'Confirmed event'
GROUP BY [Sitenum]
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
		--Subnum as [SiteID]
		Sitenum as SiteID
	   ,COUNT([Subnum]) AS [RetrievedDocs]
FROM GPP510.t_pv_TAEQCListing 
WHERE 1=1
	AND [ConfirmationStatus] = 'Confirmed event'
	AND suppDocs='Are attached'
AND [OnsetDate] >= CAST(DATEADD(MONTH,-16,GETDATE()) AS DATE)
AND [OnsetDate] <= CAST(DATEADD(MONTH,-4,GETDATE()) AS DATE)
GROUP BY [Sitenum]
),



--Determine Docs that have been retrieved for Confirmed TAEs All Time

AllTimeRetrievedDocs AS
(
SELECT Sitenum as SiteID
	   ,COUNT([Subnum]) AS [AllTimeRetrievedDocs]

FROM GPP510.t_pv_TAEQCListing
WHERE 1=1
	AND [ConfirmationStatus] = 'Confirmed event'
	AND suppDocs='Are attached'
AND [suppDocsApproved] = 'Yes'
GROUP BY [Sitenum]
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
		NE.[SiteID],
	   ROUND(CAST(NMA.[NineMonthActiveCount] AS FLOAT)/CAST(NE.[NonExited] AS FLOAT),2) AS [ActivePercent]
FROM NonExited NE
JOIN NineMonthActive NMA ON NMA.[SiteID] = NE.[SiteID]
),


--Determine Consistency Rating

ConsistencyRating AS
(
SELECT NE.[SiteID]
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
'GPP-510' AS [Registry]
,V.[SITENUM] AS SiteID
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VISNAME] AS VisitType
,COUNT(V.SUBNUM) AS [Total] 

FROM [GPP510].[v_op_VisitLog_simple] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] = V.SITENUM and RS.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
WHERE 1=1
AND ISNULL(VISDAT, '')<>''
GROUP BY V.SITENUM, V.VISNAME, RS.[TopEnrollingSite], RS.[currentStatus]
),
--------------------------------------------------------------------------

DataContribution12Mos AS
(
SELECT
'GPP-510' AS [Registry]
,V.SITENUM AS SiteID
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.VISNAME AS VisitType
,COUNT(V.SUBNUM) AS [Total] 
FROM [Reporting].[GPP510].[v_op_VisitLog_simple] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.SITENUM AND RS.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
WHERE ISNULL(VISDAT, '')<>''

GROUP BY V.SITENUM, V.VISNAME, RS.[TopEnrollingSite], RS.[currentStatus]
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

SELECT '12 Mos' AS [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 ,[VisitType]
		 ,[Total]
		 FROM DataContribution12Mos
		 GROUP BY [Registry], [SiteID], [TopEnrollingSite], [VisitType], [TopEnrollingSite], [SiteStatus], [Total]
),
--------------------------------------------------------------------------

SiteENFUs AS 
(
SELECT
		  [TimePeriod]
		 ,[Registry]
		 ,[SiteID]
		 ,[SiteStatus]
         ,[TopEnrollingSite]
		 ,SUM([Total]) AS [SiteENFUTotal]
		 FROM RegSiteTotals
		 WHERE [VisitType] <> 'Subject Exit'
		 GROUP BY [TimePeriod], [Registry], [SiteID], [TopEnrollingSite], [SiteStatus]
),

RegENFUs AS 
(
SELECT
		  [TimePeriod]
		 ,[Registry]
		 ,SUM([Total]) AS [RegENFUTotal]
		 FROM RegSiteTotals
		 WHERE [VisitType] <> 'Subject Exit'
		 GROUP BY [TimePeriod], [Registry]
),
--------------------------------------------------------------------------

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
		,CASE WHEN [DQR_Type__c] = 'ICCV-L' THEN 'ICCV-L1'
              ELSE [DQR_Type__c]
         END AS [DQRType]
		,MAX(CAST([Date_Visit_Conducted__c] AS DATE)) AS [Date]
		,[Status__c] AS [Status] --SELECT *
FROM [Salesforce].[dbo].[dataQualityReview]  
WHERE [Date_Visit_Conducted__c] IS NOT NULL
AND [Date_Visit_Conducted__c] >= CAST(DATEADD(MONTH,-12,GETDATE()) AS DATE) 
AND [Registry_Protocol_ID__c] = 'GPP-510' --None for GPP!
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


select
	'GPP-510' as Registry
	   ,MA.[SiteID]
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
	   ----- Error with AP, however the report calculates this on its own without using this figure. Going to skip it.
	   ,AP.[ActivePercent]
	   ----- Error with ConsistencyRating, but also seems report is recalculating this in SSRS, so skipping this.
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
