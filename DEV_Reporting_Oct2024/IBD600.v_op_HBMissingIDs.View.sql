USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_HBMissingIDs]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [IBD600].[v_op_HBMissingIDs] as

WITH EXITSUBJECTS AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,A.SubjectID as SubjectID
FROM [Reporting].[IBD600].[v_SiteParameter] SL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[IBD600].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'

)

,HBSubjects AS (
SELECT DISTINCT [STNO] AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,[SUBJID] AS SubjectID
	  ,CAST(DATECNST AS date) AS DateofEnrollment
      ,'Enrollment Visit in Clinical EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[IBD600].[t_HB] HB
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=HB.STNO
LEFT JOIN [Reporting].[IBD600].[t_HBCompareVisitLog] A ON HB.STNO=A.SiteID
WHERE CAST([SUBJID] AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
)

,ClinSubjects AS (
SELECT DISTINCT vl.SiteID AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,vl.SubjectID AS SubjectID
	  ,(SELECT DISTINCT CAST(VisitDate AS date) FROM [IBD600].[t_HBCompareVisitLog] vl2 WHERE vl2.SubjectID=vl.SubjectID AND
	    VisitType LIKE 'Enroll%') AS DateofEnrollment
      ,'Personal Information in Honest Broker EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[IBD600].[t_HBCompareVisitLog] VL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=VL.SiteID
WHERE CAST(SubjectID AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
)

,MissingIDs AS (
SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SFSiteStatus
      ,SubjectID
	  ,DateofEnrollment
      ,[SubjectIDNotfoundIn]
FROM HBSubjects
WHERE SubjectID NOT IN 
(SELECT DISTINCT SubjectID FROM ClinSubjects)
AND SiteID NOT LIKE '99%'
AND ISNULL(SiteStatus, '')<>'' AND ISNULL(SFSiteStatus, '')<>''

UNION

SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SFSiteStatus
      ,SubjectID
	  ,DateofEnrollment
      ,[SubjectIDNotfoundIn]
FROM ClinSubjects
WHERE SubjectID NOT IN 
(SELECT SubjectID FROM HBSubjects) 
AND SiteID NOT LIKE '99%'
AND ISNULL(SiteStatus, '')<>'' AND ISNULL(SFSiteStatus, '')<>''
)

,NoRecords AS
(
SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,NULL AS SubjectID
	  ,CAST(NULL AS date) AS DateOfEnrollment
	  ,'None Missing' AS SubjectIDNotfoundIn

FROM [IBD600].[v_SiteParameter] SP
LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM MissingIDs)
)


SELECT * FROM MissingIDs
WHERE SFSiteStatus IS NOT NULL
UNION
SELECT * FROM NoRecords
WHERE SFSiteStatus IS NOT NULL



GO
