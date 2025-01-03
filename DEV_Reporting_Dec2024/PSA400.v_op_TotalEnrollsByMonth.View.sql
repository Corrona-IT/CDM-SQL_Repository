USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_TotalEnrollsByMonth]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [PSA400].[v_op_TotalEnrollsByMonth] as


With dt As
 (
 Select CAST('2017-03-01' AS DATE) As [TheDate]
 Union All
 Select DateAdd(month, 1, TheDate) From dt Where [TheDate] < CAST(GETDATE() AS DATE)
 )
 ,

 ENRMONTHS AS
 (
 SELECT SiteID, theDate, '0' AS [TotalEnrollments]  FROM dt 
 CROSS JOIN [PSA400].[v_op_SiteListing] SITES
 )
 ,
 
 ENRCOUNTS AS
 (
 SELECT
	 SiteID
	,DATEADD(DAY, 1, EOMONTH(EnrollmentDate, -1)) AS [EnrollmentDate]
	,COUNT(SiteID) AS [TotalEnrollments]
 FROM [PSA400].[v_op_Dashboard]
 GROUP BY SiteID, EnrollmentDate
 )
,

ENRGROUPED AS
(
 SELECT
	 SiteID
	,EnrollmentDate
	,SUM(TotalEnrollments) AS [TotalEnrollments]
 FROM ENRCOUNTS 
 GROUP BY SiteID, EnrollmentDate
 UNION
 SELECT
	 SiteID
	,theDate AS [EnrollmentDate]
	,TotalEnrollments
 FROM ENRMONTHS
 )
 ,

 EMS AS
 (
 SELECT DISTINCT
	 SiteID
	,EnrollmentDate
	,SUM(TotalEnrollments) AS [TotalEnrollments]
	,SUM([TotalEnrollments]) OVER (PARTITION BY [SiteID] ORDER BY [EnrollmentDate]) AS [CumulativeTotal]
	FROM ENRGROUPED 
	GROUP BY SiteID, EnrollmentDate, [TotalEnrollments]
 )

  SELECT DISTINCT
	 SiteID
	,EnrollmentDate
	,SUM(TotalEnrollments) AS [TotalEnrollments]
	,[CumulativeTotal]
	FROM EMS 
	GROUP BY SiteID, EnrollmentDate, [CumulativeTotal]
 

GO
