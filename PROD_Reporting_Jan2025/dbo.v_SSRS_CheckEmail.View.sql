USE [Reporting]
GO
/****** Object:  View [dbo].[v_SSRS_CheckEmail]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[v_SSRS_CheckEmail] AS

WITH ExtensionToNvarchar AS
(
SELECT Sub.[Description]
      ,CAST(Sub.[ExtensionSettings] AS nvarchar(max)) AS ExtensionSettings
      ,Sub.[ModifiedDate]
      ,Sub.[LastStatus]
      ,S.[EventType]
	  ,S.[Name] AS SubscriptionName
      ,Sub.[MatchData]
      ,Sub.[LastRunTime]
      ,Sub.[Parameters]
      ,Sub.[DeliveryExtension]
      ,Sub.[Version]

FROM [SSRS].[dbo].[Subscriptions] AS Sub 
     INNER JOIN [SSRS].[dbo].ReportSchedule AS RS 
         ON SUB.Report_OID = RS.ReportID AND SUB.SubscriptionID = RS.SubscriptionID 
     INNER JOIN [SSRS].[dbo].Schedule AS S 
         ON RS.ScheduleID = S.ScheduleID

)


SELECT EN.[Description]
      ,RS.ReportName
      ,RS.[Email To]
	  ,RS.[Email CC]
	  ,RS.[Email BCC]
	  ,RS.[Email Subject]
	  ,SUBSTRING(ExtensionSettings, CHARINDEX('<ParameterValue><Name>Comment</Name><Value>', EN.ExtensionSettings) + 43, PATINDEX('%</Value></ParameterValue><ParameterValue><Name>IncludeLink%', EN.ExtensionSettings)-(CHARINDEX('<ParameterValue><Name>Comment</Name><Value>', EN.ExtensionSettings)+43)) AS EmailBody
      ,CAST(EN.[ModifiedDate] AS date) AS ModifiedDate
      ,EN.[LastStatus]
      ,EN.[EventType]
	  ,EN.SubscriptionName
      ,EN.[MatchData]
      ,EN.[LastRunTime]
      ,EN.[Parameters]
      ,EN.[DeliveryExtension]
      ,EN.[Version]

  FROM ExtensionToNvarchar EN
  JOIN [Reporting].[dbo].[v_ALLSTUDIES_SSRS_Report_Subscriptions] RS ON RS.ReportDescription=EN.[Description]

  
GO
