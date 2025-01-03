USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_HBMissingIDs]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [MS700].[v_op_HBMissingIDs] AS

WITH EXITSUBJECTS AS (
SELECT SL.SiteID
      ,A.SubjectID as SubjectID
FROM [Reporting].[MS700].[v_SiteParameter] SL
LEFT JOIN [Reporting].[MS700].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'
AND SL.SiteID NOT IN (997, 998, 999)
)

,HBSubjects AS (
SELECT DISTINCT [STNO] AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,[SUBJID] AS SubjectID
	  ,CAST(DATECNST AS date) AS DateofEnrollment
      ,'Enrollment Visit in RCC Clinical EDC' AS [MissingInformation]
FROM [Reporting].[MS700].[t_HB] HB
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=HB.STNO
WHERE CAST([SUBJID] AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
AND SS.SiteID NOT IN (997, 998, 999)
)

,ClinSubjects AS (
SELECT DISTINCT vl.SiteID AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,vl.SubjectID AS SubjectID
	  ,CAST(VisitDate AS date) DateofEnrollment
      ,'Personal Information in Trial Master PI EDC' AS [MissingInformation]
	  
FROM [Reporting].[MS700].[t_HBCompareVisitLog] vl
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=vl.SiteID
WHERE CAST(vl.SubjectID AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
AND vl.VisitType LIKE 'Enroll%'
AND SS.SiteID NOT IN (997, 998, 999)
)


,SubjectDetail AS
(
SELECT DISTINCT HB.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,HB.SubjectID
	  ,HB.DateofEnrollment
      ,HB.[MissingInformation]

FROM HBSubjects HB
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=HB.SiteID
WHERE SubjectID NOT IN 
(SELECT DISTINCT SubjectID FROM ClinSubjects)
AND ISNUMERIC(HB.SiteID)=1
AND SS.SiteID NOT IN (997, 998, 999)


UNION

SELECT DISTINCT CLIN.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,CLIN.SubjectID
	  ,CLIN.DateofEnrollment
      ,CLIN.[MissingInformation]

FROM ClinSubjects CLIN
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=CLIN.SiteID
WHERE SubjectID NOT IN 
(SELECT SubjectID FROM HBSubjects) 
AND ISNUMERIC(CLIN.SiteID)=1
AND CLIN.SiteID<>999
)



,NoRecords AS (
SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,NULL AS SubjectID
	  ,CAST(NULL AS date) AS DateofEnrollment
	  ,'None Missing' AS [SubjectIDNotfoundIn]

FROM [MS700].[v_SiteParameter] SP
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM SubjectDetail)
)

SELECT *
FROM SubjectDetail
WHERE SiteID NOT IN (999, 1440)

UNION

SELECT *
FROM NoRecords
WHERE SiteID NOT IN (999, 1440)



--ORDER BY SiteID, SubjectID, SubjectIDNotfoundIn



GO
