USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_VisitPlanningLineListing_V2]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [PSA400].[v_op_VisitPlanningLineListing_V2]  as




WITH Exited as
(
SELECT A.SiteID
      ,A.SubjectID
	  
FROM Reporting.PSA400.v_op_085_ExitReport A
WHERE SiteID NOT IN (99999, 99998, 99997)

)

,Enroll AS
(
SELECT SITENUM As SiteID
      ,SUBNUM AS SubjectID
	  ,VISNAME AS VisitType
	  ,VISITID AS VisitID
	  ,VISITDATE AS EnrollmentDate

FROM MERGE_SPA.staging.VS_01 V

WHERE SUBNUM NOT IN (SELECT SubjectID from Exited)
AND VISITID=10
AND SITENUM NOT IN (99999, 99998, 99997)

)


,BIRTHYR AS
(
SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,BIRTHDATE AS BirthYear
FROM MERGE_SPA.staging.ES_01
WHERE VISITID=10 
AND SUBNUM NOT IN (SELECT SubjectID from Exited)
AND SITENUM NOT IN (99999, 99998, 99997)

UNION

SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,BIRTHDATE AS BirthYear
FROM MERGE_SPA.staging.ESUB_01
WHERE VISITID=10
AND SUBNUM NOT IN (SELECT SubjectID from Exited)
AND SITENUM NOT IN (99999, 99998, 99997)
)


,LastVisit AS
(
SELECT * FROM 
(
SELECT ROW_NUMBER() OVER (PARTITION BY V.SITENUM, V.SUBNUM ORDER BY V.SITENUM, V.SUBNUM, V.VISITDATE DESC) AS ROWNUM
      ,V.SITENUM As SiteID
      ,V.SUBNUM AS SubjectID
	  ,V.VISITDATE AS LastVisitDate
	  ,CASE WHEN V.VISNAME LIKE '%Follow%' THEN 'Follow Up'
	   ELSE V.VISNAME 
	   END AS LastVisitType

FROM MERGE_SPA.staging.VS_01 V
LEFT JOIN MERGE_SPA.staging.REIMB R ON R.vID=V.vID
WHERE ISNULL(R.LAST_ELIG_VISIT_DATE, '')=''
AND V.SITENUM NOT IN (99999, 99998, 99997)
AND V.SUBNUM NOT IN (SELECT SubjectID FROM Exited)


) C
WHERE ROWNUM=1
)


,SiteStatus AS
(
SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
FROM [MERGE_SPA].[dbo].[DAT_SITES]
WHERE SITENUM NOT IN (99999, 99998, 99997)
)

SELECT DISTINCT CAST(A.SiteID as int) AS SiteID
      ,SiteStatus
      ,CAST(A.SubjectID AS bigint) AS SubjectID
	  ,B.BirthYear as YearOfBirth
	  ,A.EnrollmentDate
	  ,C.LastVisitDate
	  ,C.LastVisitType

	  ----,(DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) AS MonthsSinceLastVisit
	  ,CAST((DATEDIFF(DAY, C.LastVisitDate, GETDATE())/30.0) as decimal(8,2)) AS MonthsSinceLastVisit
	  ,DATEADD(DAY, 180, C.LastVisitDate) AS TargetedNextFU
	  ,DATEADD(DAY, 150, C.LastVisitDate)  AS EarliestEligNextFU

FROM Enroll A
LEFT JOIN SiteStatus SS ON SS.SiteID=A.SiteID
LEFT JOIN LastVisit C ON A.SiteID=C.SiteID AND A.SubjectID=C.SubjectID
LEFT JOIN BIRTHYR B ON A.SiteID=B.SiteID AND A.SubjectID=B.SubjectID
WHERE A.SubjectID NOT IN (Select SubjectID from Exited)
AND A.SiteID NOT IN (99999, 99998, 99997)
AND ISNULL(C.LastVisitDate, '') <>''

--ORDER BY A.SiteID, A.SubjectID



GO
