USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_SiteProfile_Pre8Nov2021]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Garth and Kevin Soe
-- Create date: 20200819
-- Description:	create table for Site Scoreboard
-- =============================================
			   --EXECUTE
CREATE PROCEDURE [MULTI].[usp_op_SiteProfile_Pre8Nov2021] AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--	select * from MULTI.t_op_SiteProfile  where coalesce([MonthsActive_dec],0) <> coalesce([MonthsActive_float],0)

drop table MULTI.t_op_SiteProfile 

CREATE TABLE [MULTI].[t_op_SiteProfile](
	[Registry] [varchar](7) NOT NULL,
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](1024) NULL,
	[SalesforceStatus] [varchar](20) NULL,
	[TopEnrollingSite] [nvarchar](80) NULL,
	[MonthsActive] [float] NULL,
	[NonExited] [int] NULL,
	[Exited] [int] NULL,
	[TotalVisits] [int] NULL,
	[AvgVisitsPerMonth] [decimal](5, 1) NULL,
	[NineMonthActiveCount] [int] NULL,
	[ConfirmedEvents] [int] NULL,
	[ExpectedEvents] [int] NULL,
	[RetrievedDocs] [int] NULL,
	[DocRetrievalPercent] [float] NULL,
	[AllTimeConfirmedEvents] [int] NULL,
	[AllTimeRetrievedDocs] [int] NULL,
	[AllTimeDocRetrievalPercent] [float] NULL,
	[ActivePercent] [float] NULL,
	[ConsistencyRating] [varchar](13) NULL
)

drop table MULTI.t_op_SiteVisits 

CREATE TABLE [MULTI].[t_op_SiteVisits](
	[Registry] [varchar](7) NOT NULL,
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](1024) NULL,
	[TopEnrollingSite] [nvarchar](80) NULL,
	[VisitType] [varchar](50) NULL,
	[Total] [int] NULL
)

--drop table MULTI.t_op_SiteProfile 
insert into MULTI.t_op_SiteProfile 
select 
'PSO-500' AS [Registry]
,CAST([SiteID] AS INT) AS [SiteID]
,[SiteStatus]
,[SalesforceStatus]
,[TopEnrollingSite]
,[MonthsActive]
--,cast([MonthsActive] as decimal (4,1)) as [MonthsActive_dec]
--,cast([MonthsActive] as float) as [MonthsActive]
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
--into MULTI.t_op_SiteProfile 
FROM [Reporting].[PSO500].[v_op_SiteScorecard_V3]



insert into MULTI.t_op_SiteProfile 
SELECT
'IBD-600' AS [Registry]
,[SiteID]
,[SiteStatus]
,[SalesforceStatus]
,[TopEnrollingSite]
,cast([MonthsActive] as float) as [MonthsActive]
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
FROM [Reporting].[IBD600].[v_op_SiteScorecard_V3]



insert into MULTI.t_op_SiteProfile 
SELECT
'PSA-400' AS [Registry]
,[SiteID]
,[SiteStatus]
,[SalesforceStatus]
,[TopEnrollingSite]
,cast([MonthsActive] as float) as [MonthsActive]
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
FROM [Reporting].[PSA400].[v_op_SiteScorecard_V3]



insert into MULTI.t_op_SiteProfile 
SELECT
'RA-102' AS [Registry]
,[SiteID]
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
FROM [Reporting].[RA102].[v_op_SiteScorecard_V3]



insert into MULTI.t_op_SiteProfile 
SELECT
'MS-700' AS [Registry]
,[SiteID]
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
FROM [Reporting].[MS700].[v_op_SiteScorecard_V2]



insert into MULTI.t_op_SiteProfile 
SELECT
'RA-100' AS [Registry]
,[SiteID]
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
FROM [RA100].[v_op_SiteScorecard_V3]


insert into MULTI.t_op_SiteProfile 
SELECT
'AD-550' AS [Registry]
,[SiteID]
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
FROM [AD550].[v_op_SiteScorecard]
--select max(charindex(cast([MonthsActive] as varchar(255)),'.'))
--FROM [RA100].[v_op_SiteScorecard]


insert into MULTI.t_op_SiteVisits 
SELECT
'PSO-500' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
      ,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
FROM [Reporting].[PSO500].[v_op_VisitLog_V3] V
      LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
      ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Psoriasis (PSO-500)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


insert into MULTI.t_op_SiteVisits 
SELECT
'PSA-400' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
FROM [Reporting].[PSA400].[v_op_VisitLog_V3] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


insert into MULTI.t_op_SiteVisits
SELECT
'IBD-600' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
FROM [Reporting].[IBD600].[v_op_VisitLog_V2] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Inflammatory Bowel Disease (IBD-600)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


insert into MULTI.t_op_SiteVisits
SELECT
'MS-700' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
FROM [Reporting].[MS700].[v_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Multiple Sclerosis (MS-700)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


insert into MULTI.t_op_SiteVisits
SELECT 
'RA-100' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
      ,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
FROM [Reporting].[RA100].[v_op_VisitLog_V3] V
      LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
      ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)'
                              --Visit Date filter included for some reason in V1. Not Sure Why.                                         --This Led to Inconsistent Site Totals
                              --AND [VisitDate] >= '3/25/2013'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


insert into MULTI.t_op_SiteVisits
SELECT
'RA-102' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total]
FROM [Reporting].[RA102].[v_op_VisitLog_V3] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Japan RA Registry (RA-102)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]


insert into MULTI.t_op_SiteVisits
SELECT
'AD-550' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total] 
FROM [Reporting].[AD550].[v_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Atopic Dermatitis (AD-550)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]

GO
