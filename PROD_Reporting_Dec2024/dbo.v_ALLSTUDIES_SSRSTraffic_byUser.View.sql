USE [Reporting]
GO
/****** Object:  View [dbo].[v_ALLSTUDIES_SSRSTraffic_byUser]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[v_ALLSTUDIES_SSRSTraffic_byUser] AS

WITH DataSources AS
(
SELECT [Name] AS ReportName
      ,[Path] AS ReportLocation
	  ,1 AS NbrTimesRun
	  ,l.TimeStart AS RunTime
	  ,(SELECT SUBSTRING(	
	                       (SELECT CAST(', ' AS VARCHAR(MAX))+CAST(c1.Name AS VARCHAR(MAX))
							FROM [SSRS].[dbo].[Catalog] AS C
							INNER JOIN [SSRS].[dbo].[DataSource] AS D ON C.[ItemID] = D.[ItemID]
							INNER JOIN [SSRS].[dbo].[Catalog] C1 ON D.[Link] = C1.ItemID
							WHERE C.[Type] = 2 AND C.[ItemId] = L.[ReportId]
							FOR XML PATH('')
						   ),
						 3, 10000000)
		) AS [DataSource]
	  /*,(SELECT SUBSTRING(
						(SELECT CAST(', ' AS VARCHAR(MAX))+CAST(t.UserName AS VARCHAR(MAX))
                        FROM
                        (
                            SELECT TOP 200000 RIGHT(l2.UserName, CHARINDEX('\', REVERSE(l2.UserName))-1)+'('+CAST(COUNT(*) AS VARCHAR(100))+')' AS UserName
                            FROM [SSRS].[dbo].[ExecutionLog](NOLOCK) AS L2
                            WHERE L2.ReportID = L.ReportId
                            GROUP BY L2.UserName
                            ORDER BY COUNT(*) DESC
                        ) AS t
                        FOR XML PATH('')
                    ), 3, 10000000)
		) AS ReportRanBy*/
		,UserName AS ReportRanBy
FROM [SSRS].[dbo].[ExecutionLog](NOLOCK) AS L
INNER JOIN [SSRS].[dbo].[Catalog](NOLOCK) AS C ON L.ReportID = C.ItemID
WHERE C.[Type] IN (2, 4) -- Only show reports 1=folder, 2=Report, 3=Resource, 4=Linked Report, 5=Data Source
AND l.TimeStart > '2021-05-31'
--GROUP BY l.[ReportId], c.[Name], c.[Path]
) 



SELECT ReportName
      ,ReportLocation
	  ,NbrTimesRun
	  ,RunTime
	  ,CAST(RunTime AS date) AS RunDate
	  ,DataSource
	  ,ReportRanBy
FROM DataSources
WHERE ReportRanBy NOT LIKE '%ReportServer'
--ORDER BY ReportRanBy, ReportName, RunTime

GO
