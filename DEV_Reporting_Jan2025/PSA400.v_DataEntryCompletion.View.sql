USE [Reporting]
GO
/****** Object:  View [PSA400].[v_DataEntryCompletion]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/*********NOTE THAT THIS VIEW IS FOR INFORMATIONAL PURPOSES ONLY - DUE TO VISIT DATE AND VISIT 
ENTRY PARAMETERS THIS SQL IS IN SSRS AND DOES NOT USE THIS VIEW******************************/


CREATE VIEW [PSA400].[v_DataEntryCompletion] AS


WITH MINMAX AS
(
(
SELECT SiteID,
       'Enrollment' AS VisitName,
	   COUNT(distinct vID) AS NbrVisits, 
	   MIN(CompletionInHours) AS MinCIH,
	   MAX(CompletionInHours) AS MaxCIH,
	   AVG(CompletionInHours) AS AvgCIH
FROM [Reporting].[PSA400].[t_DataEntryCompletion]
WHERE VisitType='Enrollment Visit'
AND CompletionInMinutes>=0
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))
GROUP BY SiteID

UNION

SELECT SiteID,
       'Follow-Up' AS VisitName,
	   COUNT(Distinct vID) AS NbrVisits,
	   MIN(CompletionInHours) AS MinCIH,
	   MAX(CompletionInHours) AS MaxCIH,
	   AVG(CompletionInHours) AS AvgCIH
FROM [Reporting].[PSA400].[t_DataEntryCompletion]
WHERE VisitType='Follow Up Visit'
AND CompletionInMinutes>=0
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))
GROUP BY SiteID

UNION

SELECT SiteID
      ,'Total' as VisitName
	  ,COUNT(Distinct vID) AS NbrVisits
      ,MIN(CompletionInHours) AS MinCIH
	  ,MAX(CompletionInHours) AS MaxCIH
	  ,AVG(CompletionInHours) AS AvgCIH

FROM [Reporting].[PSA400].[t_DataEntryCompletion]
WHERE VisitType IN ('Enrollment Visit', 'Follow Up Visit')
AND CompletionInMinutes >=0
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))
GROUP BY SiteID
)

UNION

(
SELECT 9000 AS SiteID,
       'Enrollment' AS VisitName,
	   COUNT(distinct vID) AS NbrVisits, 
	   MIN(CompletionInHours) AS MinCIH,
	   MAX(CompletionInHours) AS MaxCIH,
	   AVG(CompletionInHours) AS AvgCIH
FROM [Reporting].[PSA400].[t_DataEntryCompletion]
WHERE VisitType='Enrollment Visit'
AND CompletionInMinutes>=0
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

UNION

SELECT 9000 AS SiteID,
       'Follow-Up' AS VisitName,
	   COUNT(Distinct vID) AS NbrVisits,
	   MIN(CompletionInHours) AS MinCIH,
	   MAX(CompletionInHours) AS MaxCIH,
	   AVG(CompletionInHours) AS AvgCIH
FROM [Reporting].[PSA400].[t_DataEntryCompletion]
WHERE VisitType='Follow Up Visit'
AND CompletionInMinutes>=0
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

UNION

SELECT 9000 AS SiteID
       ,'Total' as VisitName
	  ,COUNT(Distinct vID) AS NbrVisits
      ,MIN(CompletionInHours) AS MinCIH
	  ,MAX(CompletionInHours) AS MaxCIH
	  ,AVG(CompletionInHours) AS AvgCIH
FROM [Reporting].[PSA400].[t_DataEntryCompletion]
WHERE VisitType IN ('Enrollment Visit', 'Follow Up Visit')
AND CompletionInMinutes >=0
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

)
)

,MEDIANCIH AS
(
(
SELECT SiteID,
       VisitName,
       AVG(CompletionInHours) AS MedianCIH
FROM
(
  SELECT SiteID
        ,'Enrollment' AS VisitName
        ,CompletionInHours
		,ROW_NUMBER() OVER (PARTITION BY SiteID ORDER BY CompletionInHours ASC, vID ASC) as RowAsc
		,ROW_NUMBER() OVER (PARTITION BY SiteID ORDER BY CompletionInHours DESC, vID DESC) as RowDesc

  FROM [Reporting].[PSA400].[t_DataEntryCompletion] 
  WHERE VisitType='Enrollment Visit'
  AND CompletionInMinutes>=0
---  AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---  OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

  UNION

  SELECT SiteID
		,'Follow-Up' AS VisitName
        ,CompletionInHours
		,ROW_NUMBER() OVER (PARTITION BY SiteID ORDER BY CompletionInHours ASC, vID ASC) as RowAsc
		,ROW_NUMBER() OVER (PARTITION BY SiteID ORDER BY CompletionInHours DESC, vID DESC) as RowDesc

  FROM [Reporting].[PSA400].[t_DataEntryCompletion] 
  WHERE VisitType='Follow Up Visit'
  AND CompletionInMinutes >=0
---  AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---  OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

UNION

  SELECT SiteID
		,'Total' AS VisitName
        ,CompletionInHours
		,ROW_NUMBER() OVER (PARTITION BY SiteID ORDER BY CompletionInHours ASC, vID ASC) as RowAsc
		,ROW_NUMBER() OVER (PARTITION BY SiteID ORDER BY CompletionInHours DESC, vID DESC) as RowDesc

  FROM [Reporting].[PSA400].[t_DataEntryCompletion] 
  WHERE VisitType IN ('Enrollment Visit', 'Follow Up Visit')
  AND CompletionInMinutes>=0
---  AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---  OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))


) X

WHERE RowAsc IN (RowDesc, RowDesc - 1, RowDesc + 1)
GROUP BY SiteID, VisitName

)
UNION

(SELECT 9000 AS SiteID,
       VisitName,
       AVG(CompletionInHours) AS MedianCIH
FROM
(
  SELECT 'Enrollment' AS VisitName
        ,CompletionInHours
		,ROW_NUMBER() OVER (PARTITION BY VisitType ORDER BY CompletionInHours ASC, vID ASC) as RowAsc
		,ROW_NUMBER() OVER (PARTITION BY VisitType ORDER BY CompletionInHours DESC, vID DESC) as RowDesc

  FROM [Reporting].[PSA400].[t_DataEntryCompletion] 
  WHERE VisitType='Enrollment Visit'
  AND CompletionInMinutes>=0
---  AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---  OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

  UNION

  SELECT 'Follow-Up' AS VisitName
        ,CompletionInHours
		,ROW_NUMBER() OVER (PARTITION BY VisitType ORDER BY CompletionInHours ASC, vID ASC) as RowAsc
		,ROW_NUMBER() OVER (PARTITION BY VisitType ORDER BY CompletionInHours DESC, vID DESC) as RowDesc

  FROM [Reporting].[PSA400].[t_DataEntryCompletion] 
  WHERE VisitType='Follow Up Visit'
  AND CompletionInMinutes >=0
---  AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))

UNION

  SELECT 'Total' AS VisitName
        ,CompletionInHours
		,ROW_NUMBER() OVER (ORDER BY CompletionInHours ASC, vID ASC) as RowAsc
		,ROW_NUMBER() OVER (ORDER BY CompletionInHours DESC, vID DESC) as RowDesc

  FROM [Reporting].[PSA400].[t_DataEntryCompletion] 
  WHERE VisitType IN ('Enrollment Visit', 'Follow Up Visit')
---AND ((VisitDate>=@StartingVisitDate AND VisitDate<=@EndingVisitDate)
---OR (CreatedDate>=@StartingEntryDate AND CreatedDate<=@EndingEntryDate))


) X

WHERE RowAsc IN (RowDesc, RowDesc - 1, RowDesc + 1)
GROUP BY VisitName
---ORDER BY VisitName
)
)

SELECT MM.SiteID
      ,MM.VisitName
	  ,MM.NbrVisits
	  ,MM.MinCIH
	  ,MM.MaxCIH
	  ,MM.AvgCIH
	  ,MC.MedianCIH
FROM MINMAX MM
LEFT JOIN MEDIANCIH MC ON MM.SiteID=MC.SiteID AND MM.VisitName=MC.VisitName

---ORDER BY SiteID, VisitName



GO
