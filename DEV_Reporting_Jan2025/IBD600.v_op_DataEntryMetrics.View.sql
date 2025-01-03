USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_DataEntryMetrics]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [IBD600].[v_op_DataEntryMetrics] as

WITH AUDITLIST AS
(
SELECT row_number() OVER (partition by APGS.vID order by APGS.SITENUM, APGS.SUBNUM, VS.VISITDATE) AS ROWNUM
      ,APGS.vID
      ,APGS.SITENUM AS SiteID
      ,APGS.SUBNUM AS SubjectID
	  ,APGS.VISNAME AS VisitType
	  ,APGS.PAGENAME AS PageName
	  ,CAST(APGS.DATALMDT AS date) AS EntryDate
	  ,CAST(VS.VISITDATE AS date) as VisitDate
	   
FROM MERGE_IBD.staging.DAT_APGS APGS
JOIN MERGE_IBD.staging.[VISIT] VS ON VS.vID=APGS.vID
WHERE (APGS.PAGENAME='Visit Date' OR APGS.VISNAME Like 'Exit%')
AND ISNULL(APGS.DATALMDT, '')<>''
AND (APGS.VISNAME LIKE 'Enrollment%'
OR APGS.VISNAME LIKE 'Follow Up%')

UNION

SELECT row_number() OVER (partition by APGS.vID order by APGS.SITENUM, APGS.SUBNUM, EX.DISCONTINUE_DT) AS ROWNUM
      ,APGS.vID
      ,APGS.SITENUM AS SiteID
      ,APGS.SUBNUM AS SubjectID
	  ,APGS.VISNAME AS VisitType
	  ,APGS.PAGENAME AS PageName
	  ,CAST(APGS.DATALMDT AS date) AS EntryDate
	  ,CAST(EX.DISCONTINUE_DT AS date) as VisitDate
	   
FROM MERGE_IBD.staging.DAT_APGS APGS
JOIN MERGE_IBD.staging.[EXIT] EX ON EX.vID=APGS.vID
WHERE (APGS.VISNAME Like 'Exit%')
AND ISNULL(APGS.DATALMDT, '')<>''

)

SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,EntryDate
	  ,DATEDIFF(D, VisitDate, EntryDate) AS EntryLag
FROM AUDITLIST
WHERE ROWNUM=1
---ORDER BY SiteID, SubjectID, VisitDate



GO
