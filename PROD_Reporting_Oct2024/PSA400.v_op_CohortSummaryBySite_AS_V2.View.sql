USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortSummaryBySite_AS_V2]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [PSA400].[v_op_CohortSummaryBySite_AS_V2]  AS

WITH SUMMARY AS(
SELECT DISTINCT SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   GroupCohort AS Cohort
FROM 
(
SELECT SS.SiteID,
       CASE WHEN NbrEnrolled IS NULL THEN 0
	   ELSE NbrEnrolled
	   END AS NbrEnrolled,
	   'Group 1' AS GroupCohort
FROM [Reporting].[PSA400].[v_op_SiteStatus] SS
LEFT JOIN [Reporting].[PSA400].[v_op_CohortMonitoring_AS_V2] ASV2 ON ASV2.SiteID=SS.SiteID AND Cohort IN ('IL-17, JAK or PDE4 Inhibitor', 'IL-17, JAK or IL-23 Inhibitor')
) IL17 
GROUP BY SiteID, GroupCohort 


UNION

SELECT DISTINCT SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   GroupCohort AS Cohort
FROM  
(
SELECT SS.SiteID,
       CASE WHEN NbrEnrolled IS NULL THEN 0
	   ELSE NbrEnrolled
	   END AS NbrEnrolled,
	   'Group 2' AS GroupCohort
FROM [Reporting].[PSA400].[v_op_SiteStatus] SS
LEFT JOIN [Reporting].[PSA400].[v_op_CohortMonitoring_AS_V2] ASV2 ON ASV2.SiteID=SS.SiteID AND Cohort = 'Comparator Biologic'
) CB 
GROUP BY SiteID, GroupCohort 
)



SELECT SS.SiteID,
       SS.SiteStatus,
       ISNULL(SUMMARY.Enrolled, 0) as Enrolled,
	   SUMMARY.Cohort,
	   ISNULL(TE.TotalEnrolled, 0) AS TotalEnrolled
FROM [Reporting].[PSA400].[v_op_SiteStatus] SS
LEFT JOIN SUMMARY ON SS.SiteID=SUMMARY.SiteID
LEFT JOIN 
(
SELECT SUMMARY.SiteID,
       SUM(Enrolled) AS TotalEnrolled
FROM SUMMARY
GROUP BY SiteID
) TE ON TE.SiteID=SUMMARY.SiteID



--ORDER BY SiteID, Cohort 


GO
