USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_SubjectFollowupTracker]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [GPP510].[v_op_SubjectFollowupTracker] AS


WITH DE AS
(
SELECT 
      DISTINCT VL.SubjectID AS SubjectID
	  ,VL.vID
      ,VL.SiteID AS SiteID
	  ,CASE WHEN VL.SiteID IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE VL.SFSiteStatus 
	   END AS SiteStatus
	 -- ,VL.SubjectID AS SubjectID
	  ,YEAR(VL.YearofBirth) AS YOB
	  ,CAST(VL.VisitDate AS date) As LastEligibleVisitDate
	  ,VL.[VisitType] AS LastEligibleVisitType
	  ,CAST(DATEDIFF(D, VL.VisitDate, GETDATE())/30.00 AS decimal(6,2)) AS [MonthsSinceLastVisit]
	  ,CAST(DATEADD(D, 150, VL.VisitDate) AS date) AS [EarliestEligNextFU]
	  ,CAST(DATEADD(D, 180, VL.VisitDate) AS date) AS [TargetNextFUVisitDate]
	  ,ROW_NUMBER() OVER(PARTITION BY VL.SiteID, VL.SubjectID ORDER BY VL.VisitDate DESC) AS ROWNUM
	  
FROM Reporting.GPP510.v_op_VisitLog VL 
LEFT JOIN ZELTA_GPP.dbo.VISIT VIS ON VL.VID=VIS.VID
left join [ZELTA_GPP].[staging].[exit] ex on vl.SubjectID = ex.Subnum and ex.PAGESEQ = 0
--LEFT JOIN ZELTA_GPP.dbo.ELG ELG ON VL.VID=ELG.VID
WHERE VIS.PAGENAME='Visit Information' AND VL.EligibleVisit != 'No'
AND VIS.VISDAT IS NOT NULL
AND VIS.DATALMDT IS NOT NULL
--AND vl.siteID = '1440'
AND ex.Subnum IS NULL
AND VIS.SUBNUM NOT IN (SELECT SUBNUM FROM ZELTA_GPP.dbo.DAT_SUB WHERE DELETED='t')
--GROUP BY VL.SubjectID, VL.vID, VL.SiteID, VL.SiteStatus, VL.YearofBirth, VL.VisitDate, VL.[Visit Type]
ORDER BY VL.SiteID, VL.SubjectID, ROWNUM OFFSET 0 ROWS



)
,FlareOnset AS
(
	SELECT VIS1.SITENUM
	       ,VIS1.FLRSTDAT
	       ,VIS1.SUBNUM
		   ,VIS1.FLRENDAT
	       ,ROW_NUMBER() OVER(PARTITION BY VIS1.SITENUM, VIS1.SUBNUM ORDER BY VIS1.FLRSTDAT DESC) AS ROWNUM1
	FROM DE 
	LEFT JOIN ZELTA_GPP.dbo.FLR VIS1 ON DE.SubjectID = VIS1.SUBNUM
	WHERE VIS1.PAGENAME = 'Flare Details' AND
	DE.SubjectID = VIS1.SUBNUM
)
,FlareResol AS
(
	SELECT VIS1.SITENUM
	       ,VIS1.FLRSTDAT
	       ,VIS1.SUBNUM
		   ,VIS1.FLRENDAT
	       ,ROW_NUMBER() OVER(PARTITION BY VIS1.SITENUM, VIS1.SUBNUM ORDER BY VIS1.FLRENDAT DESC) AS ROWNUM2
	FROM DE 
	LEFT JOIN ZELTA_GPP.dbo.FLR VIS1 ON DE.SubjectID = VIS1.SUBNUM
	WHERE VIS1.PAGENAME = 'Flare Details' AND
	DE.SubjectID = VIS1.SUBNUM
)
,ACTIVE AS
(
SELECT PAGS.vID
      ,PAGS.SITENUM
	  ,PAGS.SUBNUM
	  ,PAGS.VISNAME
	  ,PAGS.PAGENAME
	  ,PAGS.DELETED 
FROM ZELTA_GPP.dbo.DAT_PAGS PAGS INNER JOIN DE ON DE.VID=PAGS.VID
WHERE PAGS.PAGENAME='Visit Information'
AND PAGS.DELETED='f'
)
SELECT DE.SiteID
	  ,DE.SiteStatus
	  ,DE.SubjectID
	  ,DE.YOB
	  ,DE.LastEligibleVisitDate
	  ,DE.LastEligibleVisitType
	  ,CASE WHEN DE.MonthsSinceLastVisit < 5 THEN 'Not Yet Due'
	   WHEN DE.MonthsSinceLastVisit >=5 AND DE.MonthsSinceLastVisit < 7 THEN 'Due Now'
	   WHEN DE.MonthsSinceLastVisit >= 7 THEN 'OVERDUE'
	   ELSE ''
	   END AS VisitStatus
	  ,CASE WHEN DE.MonthsSinceLastVisit < 5 THEN '3'
	   WHEN DE.MonthsSinceLastVisit >=5 AND DE.MonthsSinceLastVisit < 7 THEN '2'
	   WHEN DE.MonthsSinceLastVisit >= 7 THEN '1'
	   ELSE 4
	   END AS VisitStatusSortOrder
	  ,DE.MonthsSinceLastVisit
	  ,DE.EarliestEligNextFU
	  ,DE.TargetNextFUVisitDate
	  ,CAST(REPLACE(VIS1.FLRSTDAT, 'UNK', '01') AS DATE) AS LastFlareOnset
	  ,cast(VIS2.FLRENDAT as date) AS LastFlareResolution
	  ,CAST(DATEDIFF(D, VIS1.FLRENDAT, GETDATE())/30.00 AS decimal(6,2)) AS [MonthsSinceFlareResolution]

FROM DE
LEFT JOIN FlareOnset VIS1 ON DE.SubjectID=VIS1.SUBNUM AND ROWNUM1=1
LEFT JOIN FlareResol VIS2 ON DE.SubjectID=VIS2.SUBNUM AND ROWNUM2=2
WHERE 1=1
and DE.RowNum=1 --and ROWNUM1 = 1 AND ROWNUM2 = 1 --Incorrect, does not bring in subjects that don't have a flare - see left join above OR use 'AND (ISNULL(VIS1.ROWNUM1, '') IN ('', 1)) AND (ISNULL(VIS2.ROWNUM2, '') IN ('', 1))
AND DE.LastEligibleVisitDate IS NOT NULL
and DE.SubjectID IN (SELECT ACTIVE.SUBNUM FROM ACTIVE) 
ORDER BY SiteID, DE.SubjectID, DE.LastEligibleVisitDate OFFSET 0 ROWS

GO
