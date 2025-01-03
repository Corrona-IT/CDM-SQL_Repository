USE [Reporting]
GO
/****** Object:  View [dbo].[v_ALLSTUDIES_SSRS_Report_Report_Parameter]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[v_ALLSTUDIES_SSRS_Report_Report_Parameter] AS

SELECT DISTINCT [ReportName], [ReportID] FROM
(
  SELECT c.[Name] AS ReportName,
         c.[ItemID] AS ReportID,
	   CASE WHEN s.DaysofWeek=1 THEN 'Sunday'
	   WHEN s.DaysofWeek=2 THEN 'Monday'
	   WHEN s.DaysofWeek=3 THEN 'Tuesday'
	   WHEN s.DaysofWeek=4 THEN 'Wednesday'
	   WHEN s.DaysofWeek=5 THEN 'Thursday'
	   WHEN s.DaysofWeek=6 THEN 'Friday'
	   WHEN s.DaysofWeek=7 THEN 'Saturday'
	   ELSE ''
	   END AS [Day],
	   CASE WHEN s.MonthlyWeek=1 THEN 'First Week of Month'
	   WHEN s.MonthlyWeek=2 THEN 'Second Week of Month'
	   WHEN s.MonthlyWeek=3 THEN 'Third Week of Month'
	   WHEN s.MonthlyWeek=4 THEN 'Fourth Week of Month'
	   ELSE ''
	   END AS [Week],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="TO"])[1]','nvarchar(500)') as [Email To],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="CC"])[1]','nvarchar(200)') as [Email CC],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="BCC"])[1]','nvarchar(200)') as [Email BCC],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="Subject"])[1]','nvarchar(250)') as [Email Subject],
	   CONVERT(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="RenderFormat"])[1]','nvarchar(50)') as [Render Format]
  FROM [SSRS].[dbo].[ReportSchedule] rs
  JOIN [SSRS].[dbo].[Schedule] s on rs.ScheduleID=s.scheduleID
  JOIN [SSRS].[dbo].[Subscriptions] sub on rs.SubscriptionID=sub.SubscriptionID
  JOIN [SSRS].[dbo].[Catalog] c on rs.reportID=c.ItemID 
) SSRS
---WHERE [SSRS].[ReportName]='PSO Registry Monthly Visit Planner'
---ORDER BY RIGHT([Email Subject], 3)

GO
