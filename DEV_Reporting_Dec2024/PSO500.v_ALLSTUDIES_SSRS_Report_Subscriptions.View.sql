USE [Reporting]
GO
/****** Object:  View [PSO500].[v_ALLSTUDIES_SSRS_Report_Subscriptions]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [PSO500].[v_ALLSTUDIES_SSRS_Report_Subscriptions] AS



WITH RPTSUB AS (
SELECT ReportName
      ,ReportDescription
	  --,RevisedMatchData
	  ,REPLACE(SUBSTRING(RevisedMatchData, CHARINDEX('<StartDateTime>', RevisedMatchData) + 15, CHARINDEX('</StartDateTime>', RevisedMatchData) - (CHARINDEX('<StartDateTime>', RevisedMatchData) + 15)), 'T0', ' ') AS StartDateTime 

	  ,[Weekly Schedule]
	  ,[Monthly Schedule]
	  ,[Quarterly Schedule]
	  ,DaysofWeek
	  ,MonthlyWeek
	  ,DaysofMonth
	  ,[Month]
	  ,[Email To]
	  ,[Email CC]
	  ,[Email BCC]
	  ,[Email Subject]
	  ,[Render Format]

FROM (

  SELECT c.[Name] AS ReportName
      ,sub.[Description] AS ReportDescription

	  ,CAST(sub.[MatchData] AS NVARCHAR(MAX)) AS [MatchData]
	  ,LEFT(REPLACE(CAST(sub.[MatchData] AS Nvarchar(MAX)), ' xmlns="http://schemas.microsoft.com/sqlserver/reporting/2010/03/01/ReportServer"', ''), 500) AS RevisedMatchData

	  
	  ,CASE WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=1 THEN 'Sunday Weekly' 
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=2 THEN 'Monday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=3 THEN 'Tuesday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=4 THEN 'Wednesday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=5 THEN 'Thursday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=6 THEN 'Friday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=7 THEN 'Saturday' + ' Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=60 THEN 'Tuesday through Friday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=62 THEN 'Monday through Friday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')<>'' AND ISNULL(s.WeeksInterval, '')=1 AND ISNULL(s.MonthlyWeek, '')='' AND s.DaysofWeek=32 THEN 'Friday Weekly'
	   WHEN ISNULL(s.DaysofWeek, '')=16 AND ISNULL(s.WeeksInterval, '')=2 AND ISNULL(s.MonthlyWeek, '')='' AND
	     ISNULL(s.DaysOfMonth, '')=''  AND ISNULL(s.[Month], '')=''
		 THEN 'Every 2 Weeks'
	   WHEN ISNULL(s.DaysofWeek, '')=62 AND ISNULL(s.WeeksInterval, '')=1 AND ISNULL(s.MonthlyWeek, '')='' AND
	     ISNULL(s.DaysOfMonth, '')=''  AND ISNULL(s.[Month], '')=''
		 THEN 'Every Weekday'	   
	   ELSE ''
	   END AS [Weekly Schedule],
		
	   CASE WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=1 THEN 'Sunday' + ' On Week ' + CAST(s.MonthlyWeek as varchar) + ' Day '
	   WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=2 THEN 'Monday' + ' On Week ' + CAST(s.MonthlyWeek as varchar)
	   WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=3 THEN 'Tuesday' + ' On Week ' + CAST(s.MonthlyWeek as varchar)
	   WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=4 THEN 'Wednesday' + ' On Week ' + CAST(s.MonthlyWeek as varchar)
	   WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=5 THEN 'Thursday' + ' On Week ' + CAST(s.MonthlyWeek as varchar)
	   WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=6 THEN 'Friday' + ' On Week ' + CAST(s.MonthlyWeek as varchar)
	   WHEN ISNULL(s.MonthlyWeek, '')<>'' AND s.DaysofWeek=7 THEN 'Saturday' + ' On Week ' + CAST(s.MonthlyWeek as varchar)
	   WHEN ISNULL(s.DaysOfMonth, '')<>'' AND s.DaysOfMonth<32 THEN 'Monthly on Day ' + CAST(s.DaysOfMonth as varchar)
	   WHEN s.[Month]=2340 AND s.[MonthlyWeek]=5 AND s.[DaysofWeek]=8 THEN 'Last Wednesday of Month'
	   WHEN s.DaysOfMonth=8192 AND s.[Month]=4095 THEN 'Monthly on Day 14'
	   ELSE ''
	   END AS [Monthly Schedule],

	   CASE WHEN s.[Month]=2340 THEN 'Quarterly'
	   ELSE ''
	   END AS [Quarterly Schedule],

	   s.DaysofWeek,
	   s.MonthlyWeek,
	   s.DaysofMonth,
	   s.[Month],
	  
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="TO"])[1]','nvarchar(500)') as [Email To],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="CC"])[1]','nvarchar(200)') as [Email CC],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="BCC"])[1]','nvarchar(200)') as [Email BCC],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="Subject"])[1]','nvarchar(250)') as [Email Subject],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="RenderFormat"])[1]','nvarchar(50)') as [Render Format]


FROM [ReportServer].dbo.Subscriptions AS SUB 
     INNER JOIN [ReportServer].dbo.Users AS USR 
         ON SUB.OwnerID = USR.UserID 
     INNER JOIN [ReportServer].dbo.[Catalog] AS C
         ON SUB.Report_OID = C.ItemID 
     INNER JOIN [ReportServer].dbo.ReportSchedule AS RS 
         ON SUB.Report_OID = RS.ReportID AND SUB.SubscriptionID = RS.SubscriptionID 
     INNER JOIN [ReportServer].dbo.Schedule AS S 
         ON RS.ScheduleID = S.ScheduleID 
) SSRS
)


SELECT ReportName
      ,ReportDescription
	  ,CAST(StartDateTime AS time) as StartTime
	  ,[Weekly Schedule]
	  ,[Monthly Schedule]
	  ,[Quarterly Schedule]
	  ,DaysofWeek
	  ,MonthlyWeek
	  ,DaysofMonth
	  ,[Month]
	  ,[Email To]
	  ,[Email CC]
	  ,[Email BCC]
	  ,[Email Subject]
	  ,[Render Format]
FROM RPTSUB




---WHERE [SSRS].[ReportName]='PSO Clinical and Honest Broker Subject ID Comparison Report'
---ORDER BY RIGHT([Email Subject], 3)

---ORDER BY ReportName

GO
