USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortTotalsbySite]    Script Date: 7/15/2024 12:41:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSA400].[v_op_CohortTotalsbySite]  AS


WITH SUMMARY AS
(
SELECT DISTINCT SL.SiteID,
       ISNULL(IL17.Enrolled, 0) AS Enrolled,
	   ISNULL(IL17.Cohort, 'IL-17 or JAKi') as Cohort
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort
from [Reporting].[PSA400].[v_op_CohortMonitoring]
WHERE Cohort='IL-17 or JAKi'
GROUP BY SiteID, Cohort 
) IL17 ON IL17.SiteID=SL.SiteID


UNION

SELECT DISTINCT SL.SiteID,
       ISNULL(CB.Enrolled, 0) AS Enrolled,
	   ISNULL(CB.Cohort, 'Comparator Biologics') AS Cohort
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort
from [Reporting].[PSA400].[v_op_CohortMonitoring]
WHERE Cohort='Comparator Biologics'
GROUP BY SiteID, Cohort 
) CB ON CB.SiteID=SL.SiteID
)

,TOTALS AS
(
SELECT SUMMARY.SiteID,
       SUMMARY.Enrolled,
	   SUMMARY.Cohort,
	   ISNULL(TE.TotalEnrolled, 0) AS TotalEnrolled,
	   (SELECT  Enrolled FROM SUMMARY S2 WHERE S2.SiteID=SUMMARY.SiteID AND S2.Cohort='Comparator Biologics') AS NbrCB,
	   (SELECT  Enrolled FROM SUMMARY S2 WHERE S2.SiteID=SUMMARY.SiteID AND S2.Cohort='IL-17 or JAKi') AS NbrJAK

FROM SUMMARY 
LEFT JOIN 
(
SELECT SiteID,
       SUM(NbrEnrolled) AS TotalEnrolled
FROM [Reporting].[PSA400].[v_op_CohortMonitoring]
WHERE Cohort in ('Comparator Biologics', 'IL-17 or JAKi')
GROUP BY SiteID
) TE ON TE.SiteID=SUMMARY.SiteID
)


SELECT SiteID,
	   TotalEnrolled,
	   NbrCB,
	   NbrJAK,
	   CAST(NbrJAK AS float)/(cast(NbrJAK as float) + cast(NbrCB as float)) AS JAKRatio,
	   ((NbrCB/2)-NbrJAK) AS NbrJAKtoEnroll

FROM TOTALS T
WHERE Cohort='IL-17 or JAKi'
AND TotalEnrolled>0


--ORDER BY SiteID, Cohort DESC

GO
