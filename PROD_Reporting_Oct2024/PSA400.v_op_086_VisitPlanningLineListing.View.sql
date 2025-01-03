USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_086_VisitPlanningLineListing]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSA400].[v_op_086_VisitPlanningLineListing]  as




WITH Exited as
(
SELECT A.SiteID
      ,A.SubjectID
	  
FROM MERGE_SPA.cdm.v_Exit_Report A

)

,Enroll AS
(
SELECT SITENUM As SiteID
      ,SUBNUM AS SubjectID
	  ,VISNAME AS VisitType
	  ,VISITID AS VisitID
	  ,VISITDATE AS EnrollmentDate

FROM MERGE_SPA.dbo.VS_01 V

WHERE SUBNUM NOT IN (SELECT SubjectID from Exited)
AND VISITID IN (10, 11)
)


,BIRTHYR AS
(
SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,BIRTHDATE AS BirthYear
FROM MERGE_SPA.dbo.ES_01
WHERE VISITID IN (10 , 11)
AND SUBNUM NOT IN (SELECT SubjectID from Exited)

UNION

SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,BIRTHDATE AS BirthYear
FROM MERGE_SPA.dbo.ESUB_01
WHERE VISITID IN (10, 11)
AND SUBNUM NOT IN (SELECT SubjectID from Exited)
)


,LastVisit AS
(
SELECT V.SITENUM As SiteID
      ,V.SUBNUM AS SubjectID
	  ,V.VISITDATE AS LastVisitDate
	  ,V.VISNAME as LastVisitType

FROM MERGE_SPA.dbo.VS_01 V

WHERE V.VISITDATE <>'' AND V.VISITDATE=(
SELECT MAX(V2.VISITDATE) FROM MERGE_SPA.dbo.VS_01 V2 WHERE V2.SITENUM=V.SITENUM 
AND V2.SUBNUM=V.SUBNUM)
AND v.SUBNUM NOT IN (SELECT SubjectID from Exited)

)

SELECT DISTINCT A.SiteID 
      ,A.SubjectID
	  ,B.BirthYear as YearOfBirth
	  ,A.EnrollmentDate
	  ,C.LastVisitDate
	  ,C.LastVisitType

	  ----,(DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) AS MonthsSinceLastVisit
	  ,CAST((DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) as decimal(8,2)) AS MonthsSinceLastVisit
	  ,DATEADD(DAY, 180, C.LastVisitDate) AS TargetedNextFU
	  ,DATEADD(DAY, 150, C.LastVisitDate)  AS EarliestEligNextFU

FROM Enroll A
LEFT JOIN LastVisit C ON A.SiteID=C.SiteID AND A.SubjectID=C.SubjectID
LEFT JOIN BIRTHYR B ON A.SiteID=B.SiteID AND A.SubjectID=B.SubjectID


WHERE A.SubjectID not in (Select SubjectID from Exited)
AND A.SiteID NOT IN (99999, 99998, 99997)

---ORDER BY A.SiteID, A.SubjectID



GO
