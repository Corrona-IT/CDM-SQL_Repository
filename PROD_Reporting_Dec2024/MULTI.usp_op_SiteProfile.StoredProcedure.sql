USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_SiteProfile]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Garth and Kevin Soe
-- Create date: 20200819
-- Most Recent Update date: 6-Apr-2023
-- Description:	create tables required for the Site Scoreboard/DQR Listing
-- =============================================
			  --EXECUTE
 CREATE PROCEDURE [MULTI].[usp_op_SiteProfile] AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--	select * from MULTI.t_op_SiteProfile  where coalesce([MonthsActive_dec],0) <> coalesce([MonthsActive_float],0)

drop table MULTI.t_op_SiteProfile 
		   --SELECT * FROM
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
	[ConsistencyRating] [varchar](13) NULL,
	[DataContributionAllTime] [numeric](10,8) NULL,
	[RunningDataContributionAllTime] [numeric](10,8) NULL,
	[Top80AllTime] [nvarchar] (10) NULL,
	[DataContribution12Mos] [numeric](10,8) NULL,
	[RunningDataContribution12Mos] [numeric](10,8) NULL,
	[Top8012Mos] [nvarchar] (10) NULL,
	[ConductedICCVs] [int] NULL
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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
--into MULTI.t_op_SiteProfile 
FROM [Reporting].[PSO500].[v_op_SiteScorecard_V4]



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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [Reporting].[IBD600].[v_op_SiteScorecard_V4]



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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [Reporting].[PSA400].[v_op_SiteScorecard_V4]



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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [Reporting].[RA102].[v_op_SiteScorecard_V4]



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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [Reporting].[MS700].[v_op_SiteScorecard_V3]



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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [RA100].[t_op_SiteScorecard]


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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [AD550].[v_op_SiteScorecard_V2]
-- select * from [AD550].[v_op_SiteScorecard_V2]
--select max(charindex(cast([MonthsActive] as varchar(255)),'.'))
--FROM [RA100].[v_op_SiteScorecard]

insert into MULTI.t_op_SiteProfile 
SELECT
'NMO-750' AS [Registry]
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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [Reporting].[NMO750].[v_op_SiteScorecard]

insert into MULTI.t_op_SiteProfile 
SELECT
'AA-560' AS [Registry]
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
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
FROM [Reporting].[AA560].[v_op_SiteScorecard]

insert into MULTI.t_op_SiteProfile 
SELECT
'GPP-510' AS [Registry]
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
--,'0' as [ConsistencyRating]
,[ConsistencyRating]
,CAST([DataContributionAllTime] AS numeric(10,8)) AS [DataContributionAllTime]
,CAST([RunningDataContributionAllTime] AS numeric(10,8)) AS [RunningDataContributionAllTime]
,[Top80AllTime]
,CAST([DataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,CAST([RunningDataContribution12Mos] AS numeric(10,8)) AS [DataContribution12Mos]
,[Top8012Mos]
,[ConductedICCVs]
--FROM [Reporting].[NMO750].[v_op_SiteScorecard]
FROM [Reporting].[GPP510].[v_op_SiteScorecard]

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

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
FROM [Reporting].[AD550].[t_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Atopic Dermatitis (AD-550)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]

insert into MULTI.t_op_SiteVisits
SELECT
'NMO-750' AS [Registry]
,V.[SiteID]
,RS.[currentStatus] AS [SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total] 
FROM [Reporting].[NMO750].[t_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
WHERE [name] = 'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)'
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], RS.[currentStatus]

insert into MULTI.t_op_SiteVisits
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

-------- Add GPP Below ----------------------------------------------------------------

insert into MULTI.t_op_SiteVisits
SELECT
'GPP-510' AS [Registry]
,V.[SiteID]
,V.[SiteStatus]
,CASE WHEN RS.[TopEnrollingSite] = 'Yes'  THEN 'Yes'
 ELSE 'No'
 END AS [TopEnrollingSite]
,V.[VisitType]
,COUNT(V.[SubjectID]) AS [Total] 
FROM [Reporting].GPP510.v_op_VisitLog V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
ON RS.[siteNumber] = V.[SiteID]
AND [VisitDate] IS NOT NULL
GROUP BY V.[SiteID], V.[VisitType], RS.[TopEnrollingSite], V.[SiteStatus]
---------------------------------------------------------------------------------
GO
