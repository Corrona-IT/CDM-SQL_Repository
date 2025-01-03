USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_TotalEnrollsByMonth]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [PSO500].[v_op_TotalEnrollsByMonth] as


With dt As
 (
 Select CAST('2015-04-01' AS DATE) As [TheDate]
 Union All
 Select DateAdd(month, 1, [TheDate]) From dt Where [TheDate] < CAST(GETDATE() AS DATE)
 )
 ,

 ENRMONTHS AS
 (
 SELECT [SiteID] AS [SiteID], [TheDate], '0' AS [TotalEnrollments]  FROM dt 
 CROSS JOIN [PSO500].[v_op_SiteListing] SITES
 )
 ,
 
 ENRCOUNTS AS
 (
 SELECT
	 [SiteID]
	,DATEADD(DAY, 1, EOMONTH([VisitDate], -1)) AS [EnrollmentDate]
	,COUNT([SiteID]) AS [TotalEnrollments]
 FROM [Reporting].[PSO500].[v_op_VisitLog]
 WHERE [VisitType] = 'Enrollment'
 GROUP BY [SiteID], [VisitDate]
 )
,

ENRGROUPED AS
(
 SELECT
	 [SiteID]
	,[EnrollmentDate]
	,SUM([TotalEnrollments]) AS [TotalEnrollments]
 FROM ENRCOUNTS 
 GROUP BY [SiteID], [EnrollmentDate]
 UNION
 SELECT
	 [SiteID]
	,[TheDate] AS [EnrollmentDate]
	,[TotalEnrollments]
 FROM ENRMONTHS
 )
 ,
 
 EMS AS
 (
 SELECT DISTINCT
	 [SiteID]
	,[EnrollmentDate]
	,DATEPART(MONTH, [EnrollmentDate]) AS [EnrollmentMonth]
	,DATEPART(YEAR, [EnrollmentDate]) AS [EnrollmentYear]
	,SUM([TotalEnrollments]) AS [TotalEnrollments]
	,SUM([TotalEnrollments]) OVER (PARTITION BY [SiteID] ORDER BY [EnrollmentDate]) AS [CumulativeTotal]
	FROM ENRGROUPED 
	GROUP BY [SiteID], [EnrollmentDate], [TotalEnrollments]
 )

 SELECT DISTINCT
	 [SiteID]
	,[EnrollmentDate]
	,[EnrollmentMonth]
	,[EnrollmentYear]
	,SUM([TotalEnrollments]) AS [TotalEnrollments]
	,[CumulativeTotal]
	FROM EMS 
	GROUP BY [SiteID], [EnrollmentDate], [EnrollmentMonth], [EnrollmentYear], [CumulativeTotal]


GO
