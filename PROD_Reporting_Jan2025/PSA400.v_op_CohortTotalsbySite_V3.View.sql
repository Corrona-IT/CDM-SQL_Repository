USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortTotalsbySite_V3]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [PSA400].[v_op_CohortTotalsbySite_V3]  AS


WITH SUMMARY AS
(
SELECT DISTINCT SL.SiteID,
       ISNULL(Group1.Enrolled, 0) AS Enrolled,
	   ISNULL(Group1.Cohort, 'Group 1') as Cohort
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   'Group 1' AS Cohort
from [Reporting].[PSA400].[v_op_CohortMonitoring_V3]
WHERE CohortGroup='Group 1'
GROUP BY SiteID, Cohort 
) Group1 ON Group1.SiteID=SL.SiteID


UNION

SELECT DISTINCT SL.SiteID,
       ISNULL(Group2.Enrolled, 0) AS Enrolled,
	   ISNULL(Group2.Cohort, 'Group 2') AS Cohort
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   'Group 2' AS Cohort
from [Reporting].[PSA400].[v_op_CohortMonitoring_V3]
WHERE CohortGroup='Group 2'
GROUP BY SiteID, Cohort 
) Group2 ON Group2.SiteID=SL.SiteID
)

,TOTALS AS
(
SELECT SUMMARY.SiteID,
       SUMMARY.Enrolled,
	   SUMMARY.Cohort,
	   ISNULL(TE.TotalEnrolled, 0) AS TotalEnrolled,
	   G1.Enrolled AS NbrG1,
	   G2.Enrolled AS NbrG2
FROM SUMMARY 
LEFT JOIN 
(
SELECT SiteID,
       SUM(NbrEnrolled) AS TotalEnrolled
FROM [Reporting].[PSA400].[v_op_CohortMonitoring_V3]
WHERE CohortGroup IN ('Group 1','Group 2')
GROUP BY SiteID
) TE ON TE.SiteID=SUMMARY.SiteID
LEFT JOIN
(
SELECT  SiteID, Enrolled FROM SUMMARY S2 WHERE S2.Cohort='Group 2'
) G2 ON G2.SiteID=SUMMARY.SiteID
LEFT JOIN
(
SELECT  SiteID, Enrolled FROM SUMMARY S2 WHERE S2.Cohort='Group 1'
) G1 ON G1.SiteID=SUMMARY.SiteID


)


SELECT T.SiteID,
       SiteStatus,
	   TotalEnrolled,
	   NbrG1,
	   NbrG2,
	   CAST(NbrG1 AS float)/(cast(NbrG1 as float) + cast(NbrG2 as float)) AS G2Ratio,
	   ((NbrG2/2)-NbrG1) AS NbrG2toEnroll

FROM TOTALS T
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=T.SiteID
WHERE Cohort='Group 1'
AND TotalEnrolled>0

--ORDER BY SiteID, Cohort DESC



GO
