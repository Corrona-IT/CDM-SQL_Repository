USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortSummaryBySite_AS]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [PSA400].[v_op_CohortSummaryBySite_AS]  AS
WITH SUMMARY AS
(
SELECT DISTINCT SL.SiteID,
       ISNULL(IL17.Enrolled, 0) AS Enrolled,
	   ISNULL(IL17.Cohort, 'IL-17, JAK, or PDE4 Inhibitors') as Cohort
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort
from [Reporting].[PSA400].[v_op_CohortMonitoring_AS]
WHERE Cohort='IL-17, JAK, or PDE4 Inhibitors'
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
from [Reporting].[PSA400].[v_op_CohortMonitoring_AS]
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
FROM [Reporting].[PSA400].[v_op_CohortMonitoring_AS]
WHERE Cohort in ('Comparator Biologics', 'IL-17, JAK, or PDE4 Inhibitors')
GROUP BY SiteID
) TE ON TE.SiteID=SUMMARY.SiteID
--ORDER BY SiteID, Cohort DESC




GO
