USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_116_VisitPlanningLineListing]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [IBD600].[v_op_116_VisitPlanningLineListing] as


WITH EX AS
(
SELECT EX.VID
      ,EX.SITENUM AS SiteID
	  ,EX.SUBNUM AS SubjectID
	  ,EX.DISCONTINUE_DT AS ExitDate
	  ,EX.VISNAME AS VisitType
FROM [MERGE_IBD].[staging].[EXIT] EX
)


,EnrollmentVisit as
(
SELECT DISTINCT vID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,CAST(VISITDATE AS date) AS EnrollmentDate
	  ,VISNAME
FROM [MERGE_IBD].[staging].[VISIT]

WHERE VISNAME='Enrollment'

)

    
,VisitList AS
(
SELECT distinct [VISIT].vID
	  ,[VISIT].SITENUM AS SiteID
      ,[VISIT].SUBNUM AS SubjectID
	  ,PTDEM.BIRTHDATE
	  ,[VISIT].VISNAME AS VisitType
	  ,CAST(VISIT.VISITDATE AS date) AS VisitDate
	  ,CAST(REIMB.LAST_ELIG_VISIT_DATE AS date) AS LastEligVisitDate
	  ,REIMB.OOW_FU_PERMITTED_DEC AS EligReimburse
	  ,ROW_NUMBER() OVER (PARTITION BY VISIT.SITENUM, VISIT.SUBNUM ORDER BY VISIT.SITENUM, VISIT.SUBNUM, VISIT.VISITDATE DESC) 
                              AS ROWNUM
FROM [MERGE_IBD].[staging].[VISIT]
LEFT JOIN [MERGE_IBD].[staging].[PT_DEMOG] PTDEM ON [VISIT].SUBNUM=PTDEM.SUBNUM
LEFT JOIN [MERGE_IBD].[staging].[REIMB] ON VISIT.SUBNUM=REIMB.SUBNUM AND VISIT.vID=REIMB.vID
WHERE VISIT.VISNAME IN ('Enrollment', 'Follow-up')
AND ISNULL(REIMB.LAST_ELIG_VISIT_DATE, '')=''

)

,LastEligVisit AS
(
SELECT ROWNUM
      ,VL.vID
      ,VL.SiteID
      ,VL.SubjectID
	  ,VL.Birthdate AS YearofBirth
	  ,EV.EnrollmentDate AS EnrollmentDate
	  ,VL.VisitDate
---	  ,VL.LastEligVisitDate AS LastEligibleVisitDate
	  ,VL.VisitType
	  ,VL.EligReimburse
FROM VisitList VL
LEFT JOIN EnrollmentVisit EV on VL.SubjectID=EV.SubjectID
AND ISNULL(VL.VisitDate, '')<>''
---ORDER BY SiteID, SubjectID, rownum

)


,SiteStatus AS
(
select DISTINCT(CAST(SITENUM AS int)) AS SiteID
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
FROM [MERGE_IBD].[dbo].[DAT_SITES]
)


SELECT CAST(EL.SiteID AS int) AS [Site ID]
      ,SS.SiteStatus
      ,EL.SubjectID AS [Subject ID]
	  ,EL.YearofBirth AS [Year of Birth]
	  ,CAST(DATEDIFF(D, EL.VisitDate, GETDATE())/30.00 AS decimal(6,2)) AS [Months Since Last Visit]
	  ,CAST(DATEADD(D, 180, EL.VisitDate) AS date) AS [Target Date for Next Follow up Visit]
	  ,CAST(DATEADD(D, 150, EL.VisitDate) AS date) AS [Earliest Eligible Date for Next Follow up Visit]
	  ,CAST(EL.EnrollmentDate AS date) AS EnrollmentDate
	  ,CAST(EL.VisitDate AS date) AS LastEligibleVisitDate
	  ,EL.VisitType as LastEligibleVisitType
	  ,EL.EligReimburse
FROM LastEligVisit EL
JOIN SiteStatus SS ON SS.SiteID=EL.SiteID
WHERE ROWNUM=1
AND SUBJECTID NOT IN (SELECT SUBJECTID FROM EX)

---ORDER BY SiteID, SubjectID, ROWNUM










GO
