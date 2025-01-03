USE [Reporting]
GO
/****** Object:  View [dbo].[v_ALLSTUDIES_SSRS_Reports_Listing]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[v_ALLSTUDIES_SSRS_Reports_Listing] AS
WITH SiteSubscriptions AS

(
SELECT [SubscriptionID]
      ,[OwnerID]
      ,[Report_OID]
	  ,[LinkSourceID]
      ,[Locale]
      ,[InactiveFlags]
      ,S.[Description]
      ,[LastStatus]
      ,[EventType]
      ,[MatchData]
      ,[LastRunTime]
	  --Select * 
  FROM [SSRS].[dbo].[Subscriptions] S
  INNER JOIN [SSRS].[dbo].[Catalog] C ON C.[ItemID] = S.[Report_OID] 
  WHERE S.[Description] LIKE '%site%'
  ),

  ProdReports AS
  
  (
SELECT 
	   [ItemID] 
	  ,LEFT([Name],(CHARINDEX(' ',[Name]) - 1)) AS [Registry]
	  ,CASE 
		WHEN [PATH] LIKE '%Management%' THEN 'SMR'
		WHEN [PATH] LIKE '%Surveillance%' THEN 'PV'
		ELSE NULL
		END AS [ReportType]
	  ,SUBSTRING([Name],CHARINDEX(' ',[Name]) + 1, DATALENGTH([Name])) AS [Name]
      ,[Description]
	  ,CASE WHEN [ItemID] IN (SELECT LinkSourceID FROM SiteSubscriptions) THEN 'Yes' ELSE 'No'
	  END AS [SiteSubscription]
	  ,[Path]
  -- SELECT * 
  FROM [SSRS].[dbo].[Catalog]
  WHERE ([Path] LIKE '%Management%' 
  OR	[Path] LIKE '%Surveillance%')
  AND	([Path] NOT LIKE '%Linked%' AND [Path] NOT LIKE '%Archived%')
  AND [NAME] IS NOT NULL
  AND [Path] LIKE '%/%/%/%/%'
  AND [Path] NOT LIKE '%Scorecard%'
  AND [Path] NOT LIKE '%Payments%'
  AND [Path] NOT LIKE '%Administrator%'
  )

  SELECT 
		 [ItemID]
		,[Registry]
		,[ReportType]
		,[Name]
		,[Description]
		,[SiteSubscription]
		,[Path]
  FROM ProdReports



GO
