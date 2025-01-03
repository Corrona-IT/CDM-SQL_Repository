USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_VisitPlanningLineListing]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [RA100].[v_op_VisitPlanningLineListing]  as



WITH EXITS AS (

 SELECT SiteID,
        SubjectID,
		VisitDate, 
		VisitType
 FROM [Reporting].[RA100].[t_op_SubjectVisits] sv2
 WHERE sv2.VisitType='Exit' 
 AND ISNULL(sv2.VisitDate, '')<>''
 )

 ,SiteStatus AS
 (
 SELECT [Site Number] AS SiteID
      ,CASE WHEN UPPER([Address 3])='X' THEN 'Inactive'
	   ELSE 'Active'
	   END AS SiteStatus
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information]
)



SELECT SiteID
      ,SubjectID
	  ,SiteStatus
	  ,DATEDIFF(DD, VisitDate, GetDate())/30.0 AS MonthsSinceLastVisit
	  ,DATEADD(DD, 180, VisitDate) AS TargetNextFUVisit
	  ,DATEADD(DD, 150, VisitDate) AS EarliestNextFUVisit
	  ,EnrollingProviderID
	  ,VisitProviderID
	  ,VisitDate AS LastVisitDate
	  ,VisitType AS LastVisitType

FROM (
 SELECT ROW_NUMBER() OVER(PARTITION BY s.SiteID, s.SubjectID ORDER BY s.VisitDate DESC) as ROWNUM
	   ,s.SiteID
	   ,s.SiteStatus
	   ,s.SubjectID
	   ,s.VisitType
	   ,s.VisitDate
	   ,s.EnrollingProviderID
	   ,s.VisitProviderID
	   ,s.VisitID
 FROM (
		SELECT sv.SiteID
		        ,SS.SiteStatus
				,SubjectID
				,VisitType
				,VisitDate
				,EnrollingProviderID
				,VisitProviderID
				,VisitID
		FROM [Reporting].[RA100].[t_op_SubjectVisits] sv
		JOIN SiteStatus SS ON SS.SiteID=sv.SiteID
		WHERE ISNULL(VisitDate,'')<>''
		AND VisitType IN ('Enrollment', 'Follow-up')
		AND SubjectID NOT IN (
		    SELECT SubjectID FROM EXITS E WHERE E.SiteID=sv.SiteID
			AND E.SubjectID=sv.SubjectID 
			AND E.VisitDate >= sv.VisitDate
							  ) 
		) s
) V WHERE ROWNUM=1
---AND SubjectID=142110106

---ORDER BY SiteID, SubjectID
GO
