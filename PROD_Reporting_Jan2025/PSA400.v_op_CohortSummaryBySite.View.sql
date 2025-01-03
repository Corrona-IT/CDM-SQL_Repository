USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortSummaryBySite]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [PSA400].[v_op_CohortSummaryBySite]  AS
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

SELECT SUMMARY.SiteID,
       SUMMARY.Enrolled,
	   SUMMARY.Cohort,
	   ISNULL(TE.TotalEnrolled, 0) AS TotalEnrolled
FROM SUMMARY 
LEFT JOIN 
(
SELECT SiteID,
       SUM(NbrEnrolled) AS TotalEnrolled
FROM [Reporting].[PSA400].[v_op_CohortMonitoring]
WHERE Cohort in ('Comparator Biologics', 'IL-17 or JAKi')
GROUP BY SiteID
) TE ON TE.SiteID=SUMMARY.SiteID
--ORDER BY SiteID, Cohort DESC

GO
