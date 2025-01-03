USE [Reporting]
GO
/****** Object:  View [PSA400].[v_QtrlyMetrics]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [PSA400].[v_QtrlyMetrics] AS

WITH LV AS
(
SELECT [SiteID]
      ,[SubjectID]
      ,CAST([EnrollmentDate] AS date) AS EnrollmentDate
	  ,LastVisitType
	  ,LastVisitDate
      ,[MonthsSinceLastVisit]
	  ,ROW_NUMBER() OVER (PARTITION BY SiteID, SubjectID, LastVisitType, LastVisitDate ORDER BY LastVisitDate) AS ROWNUM
  FROM MERGE_SPA.[cdm].[v_VisitPlanningLineListing] LASTVISIT

)

,LASTVISIT AS
(
  SELECT SiteID
        ,SubjectID
		,EnrollmentDate
		,LastVisitType
		,LastVisitDate
		,MonthsSinceLastVisit
FROM LV 
WHERE ROWNUM=1

)

,VL AS
(
  SELECT vID
        ,SITENUM AS SiteID
        ,SUBNUM AS SubjectID
		,VISNAME AS VisitType
		,VISITID
		,VISITDATE AS VisitDate
		,ROW_NUMBER() OVER(PARTITION BY SITENUM, SUBNUM, VISNAME, VISITDATE ORDER BY VISITDATE) AS ROWNUM
  FROM MERGE_SPA.cdm.v_SPA_VisitLog
  WHERE VISITDATE IS NOT NULL

)

,VISITLOG AS
(
SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VISITID
	  ,VisitDate
FROM VL
WHERE ROWNUM=1

) 


  SELECT VL.SiteID
        ,VL.SubjectID
		,VL.VisitType
		,CAST(VL.VisitDate AS date) AS VisitDate
		,LVIS.LastVisitType
		,LVIS.LastVisitDate
		,LVIS.MonthsSinceLastVisit

		,CASE WHEN LVIS.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VISITID IN (20, 25, 26) THEN 0
	  WHEN VL.VISITID IN (10, 11) AND LVIS.MonthsSinceLastVisit IS NOT NULL THEN 1
	  ELSE 0
	  END AS CurrentSubject
	  ,CASE WHEN LVIS.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VISITID IN (20, 25, 26) THEN 0
	  WHEN VL.VISITID IN (10, 11) AND LVIS.MonthsSinceLastVisit<15 THEN 1
	  ELSE 0
	  END AS ActiveSubject
	  ,CASE WHEN LVIS.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VISITID IN (20, 25, 26) THEN 0
	  WHEN VL.VISITID IN (10, 11) AND LVIS.MonthsSinceLastVisit>=15 THEN 1
	  ELSE 0
	  END AS InActiveSubject
	  ,CASE WHEN LVIS.MonthsSinceLastVisit IS NULL THEN 0
	  WHEN VL.VISITID IN (20, 25, 26) THEN 0
	  WHEN VL.VISITID IN (10, 11) AND LVIS.MonthsSinceLastVisit>9 AND LVIS.MonthsSinceLastVisit<14.99 THEN 1
	  ELSE 0
	  END AS OverdueVisit
	 ,CASE WHEN VL.VISITID IN (10, 11) THEN 1
	 ELSE 0
	 END AS SubjectEnroll
	 ,CASE WHEN VisitType LIKE 'Exit%' and VisitDate IS NULL THEN 0
	 WHEN LVIS.LastVisitDate IS NULL AND VL.VisitType LIKE 'Exit%' AND VL.VisitDate IS NOT NULL THEN 1
	 ELSE 0
	 END AS SubjectExit
	,CASE WHEN VL.VISITID IN (10, 11, 20, 25, 26) THEN 1
	ELSE 0
	END AS NbrVisits

FROM VISITLOG VL LEFT JOIN LASTVISIT LVIS ON LVIS.SubjectID=VL.SubjectID and LVIS.SiteID=VL.SiteID

---ORDER BY VL.SiteID, VL.SubjectID, VL.VisitDate




GO
