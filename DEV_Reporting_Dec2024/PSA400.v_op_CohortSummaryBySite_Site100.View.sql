USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortSummaryBySite_Site100]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [PSA400].[v_op_CohortSummaryBySite_Site100]  AS
WITH SUMMARY AS
(
SELECT DISTINCT SL.SiteID,
       ISNULL(IL17.Enrolled, 0) AS Enrolled,
	   ISNULL(IL17.Cohort, 'Drugs of Interest') as Cohort,
	   'PSA' AS Diagnosis
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort,
	   Diagnosis
from [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort='Drugs of Interest'
AND Diagnosis LIKE '%PSA%'
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID, Cohort, Diagnosis
) IL17 ON IL17.SiteID=SL.SiteID

UNION

SELECT DISTINCT SL.SiteID,
       ISNULL(CB.Enrolled, 0) AS Enrolled,
	   ISNULL(CB.Cohort, 'Comparators') AS Cohort, 
	   'PSA' AS Diagnosis
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort,
	   Diagnosis
from [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort='Comparators'
AND Diagnosis LIKE '%PSA%'
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID, Cohort, Diagnosis
) CB ON CB.SiteID=SL.SiteID

UNION 

SELECT DISTINCT SL.SiteID,
       ISNULL(IL17.Enrolled, 0) AS Enrolled,
	   ISNULL(IL17.Cohort, 'Drugs of Interest') as Cohort,
	   'AS' AS Diagnosis
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort,
	   Diagnosis
from [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort='Drugs of Interest'
AND Diagnosis LIKE '%AS%'
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID, Cohort, Diagnosis
) IL17 ON IL17.SiteID=SL.SiteID

UNION

SELECT DISTINCT SL.SiteID,
       ISNULL(CB.Enrolled, 0) AS Enrolled,
	   ISNULL(CB.Cohort, 'Comparators') AS Cohort, 
	   'AS' AS Diagnosis
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort,
	   Diagnosis
from [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort='Comparators'
AND Diagnosis LIKE '%AS%'
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID, Cohort, Diagnosis
) CB ON CB.SiteID=SL.SiteID

UNION 

SELECT DISTINCT SL.SiteID,
       ISNULL(IL17.Enrolled, 0) AS Enrolled,
	   ISNULL(IL17.Cohort, 'Drugs of Interest') as Cohort,
	   'Ax-SpA' AS Diagnosis
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort,
	   Diagnosis
from [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort='Drugs of Interest'
AND Diagnosis LIKE '%SPA%'
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID, Cohort, Diagnosis
) IL17 ON IL17.SiteID=SL.SiteID

UNION

SELECT DISTINCT SL.SiteID,
       ISNULL(CB.Enrolled, 0) AS Enrolled,
	   ISNULL(CB.Cohort, 'Comparators') AS Cohort, 
	   'Ax-SpA' AS Diagnosis
FROM Reporting.PSA400.v_op_SiteListing SL
LEFT JOIN 
(
select SiteID,
       SUM(NbrEnrolled) AS Enrolled,
	   Cohort,
	   Diagnosis
from [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort='Comparators'
AND Diagnosis LIKE '%SPA%'
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID, Cohort, Diagnosis
) CB ON CB.SiteID=SL.SiteID
)

SELECT SUMMARY.SiteID,
       SUMMARY.Enrolled,
	   SUMMARY.Cohort,
	   SUMMARY.Diagnosis,
	   ISNULL(TE.TotalEnrolled, 0) AS TotalEnrolled
FROM SUMMARY 
LEFT JOIN 
(
SELECT SiteID,
       SUM(NbrEnrolled) AS TotalEnrolled
FROM [Reporting].[PSA400].[v_op_CohortMonitoring_Site100]
WHERE Cohort in ('Comparators', 'Drugs of Interest')
--AND [EnrollmentDate] >= (@EnrollmentDate)
GROUP BY SiteID
) TE ON TE.SiteID=SUMMARY.SiteID
--ORDER BY SiteID, Cohort DESC



GO
