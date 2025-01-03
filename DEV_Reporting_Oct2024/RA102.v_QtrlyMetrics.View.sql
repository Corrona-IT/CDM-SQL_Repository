USE [Reporting]
GO
/****** Object:  View [RA102].[v_QtrlyMetrics]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [RA102].[v_QtrlyMetrics] AS



---Get Last Visit and Months Since Last Visit
WITH LastVisit AS
(
SELECT [Site ID] AS SiteID
      ,[Subject ID] AS SubjectID
	  ,CAST([Months Since Last Visit] AS decimal(6, 2)) AS MonthsSinceLastVisit
	  ,[Last Visit - Visit Type] AS LastVisitType
	  ,CAST([Last Visit Date] AS date) AS LastVisitDate 
	  ,ROW_NUMBER() OVER (PARTITION BY [Site ID], [Subject ID], [Last Visit - Visit Type], [Last Visit Date] ORDER BY [Last Visit Date]) AS ROWNUM
FROM MERGE_RA_Japan.Jen.VisitPlanningLineListingReport
WHERE [Site ID] NOT IN (9997, 9998, 9999)
---ORDER BY [Site ID], [Subject ID]
)

,LL AS
(
SELECT SiteID
      ,SubjectID
	  ,MonthsSinceLastVisit
	  ,LastVisitType
	  ,LastVisitDate
FROM LastVisit LL
WHERE ROWNUM=1
)

---Get Exit Visits
,EX as
(
SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,VISNAME AS VisitType
	  ,CAST(DISCONTINUE_DATE AS date) AS ExitDate
FROM MERGE_RA_Japan.reports.v_Exit_Report ExitV 
WHERE SITENUM NOT IN (9999, 9997, 9998)
---ORDER BY SITENUM, SUBNUM
)


---Get All Enrollment and FU Visits
,VisitLog AS
(
SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,VISNAME as VisitType
	  ,CAST(VISITDATE AS date) AS VisitDate
	  ,ROW_NUMBER() OVER(PARTITION BY SITENUM, SUBNUM, VISNAME, VISITDATE ORDER BY VISITDATE) AS ROWNUM
FROM MERGE_RA_Japan.reports.v_EF_VisitLog
WHERE SITENUM NOT IN (9999, 9997, 9998)
--ORDER BY SITENUM, SUBNUM
)

,VL AS
(
SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VisitDate
FROM VisitLog VL
WHERE ROWNUM=1
)


---Get Enrollment
,ENR AS
(
SELECT [Site ID] AS SiteID
      ,[Subject ID] AS SubjectID
	  ,'Enrollment' AS VisitType
	  ,CAST([Enrollment Date] as date) AS VisitDate
FROM MERGE_RA_Japan.Jen.EnrollmentReport
WHERE [Site ID] NOT IN (9999, 9997, 9998)
---ORDER BY SiteID, SubjectID
)

SELECT ENR.SiteID
      ,ENR.SubjectID
	  ,VL.VisitType
	  ,VL.VisitDate
	  ,LL.LastVisitDate
	  ,LL.MonthsSinceLastVisit
	  ,CASE WHEN LL.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VisitType='Followup' THEN 0
	  WHEN VL.VisitType='Enrollment' AND LL.MonthsSinceLastVisit IS NOT NULL THEN 1
	  ELSE 0
	  END AS CurrentSubject
	  ,CASE WHEN LL.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VisitType='Followup' THEN 0
	  WHEN VL.VisitType='Enrollment' AND LL.MonthsSinceLastVisit<15 THEN 1
	  ELSE 0
	  END AS ActiveSubject
	  ,CASE WHEN LL.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VisitType='Followup' THEN 0
	  WHEN VL.VisitType='Enrollment' AND LL.MonthsSinceLastVisit>=15 THEN 1
	  ELSE 0
	  END AS InActiveSubject
	  ,CASE WHEN LL.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VisitType='Followup' THEN 0
	  WHEN VL.VisitType='Enrollment' AND LL.MonthsSinceLastVisit>9 AND LL.MonthsSinceLastVisit<14.99 THEN 1
	  ELSE 0
	  END AS OverdueVisit
	 ,CASE WHEN VL.VisitType='Enrollment' THEN 1
	 ELSE 0
	 END AS SubjectEnroll
	 ,EX.ExitDate
	 ,CASE WHEN EX.ExitDate IS NULL THEN 0
	 WHEN LL.LastVisitDate IS NULL AND VL.VisitType='Exit' AND EX.ExitDate IS NOT NULL THEN 1
	 ELSE 0
	 END AS SubjectExit
	,CASE WHEN VL.VisitType IN ('Enrollment', 'Followup') THEN 1
	ELSE 0
	END AS NbrVisits 
FROM ENR LEFT JOIN EX ON EX.SiteID=ENR.SiteID and EX.SubjectID=ENR.SubjectID
LEFT JOIN VL ON VL.SiteID=ENR.SiteID AND VL.SubjectID=ENR.SubjectID
LEFT JOIN LL ON LL.SiteID=ENR.SiteID AND LL.SubjectID=ENR.SubjectID

---ORDER BY ENR.SiteID, ENR.SubjectID, VL.VisitDate






GO
