USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_HBMissingIDs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE view [AD550].[v_op_HBMissingIDs] as

WITH EXITSUBJECTS AS (
SELECT SL.SiteID
      ,A.SubjectID as SubjectID
FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN [Reporting].[AD550].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'

)

,HBSubjects AS (
SELECT DISTINCT [STNO] AS SiteID
      ,[SUBJID] AS SubjectID
	  ,CAST(DATECNST AS date) AS DateofEnrollment
      ,'Clinical EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[AD550].[t_HB]
WHERE [SUBJID] NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
)

,ClinSubjects AS (
SELECT DISTINCT vl.SiteID AS SiteID
      ,vl.SubjectID AS SubjectID
	  ,CAST(VisitDate AS date) DateofEnrollment
      ,'HB EDC' AS [SubjectIDNotfoundIn]
	  
FROM [Reporting].[AD550].[t_HBCompareVisitLog] vl
WHERE SubjectID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
AND vl.VisitType LIKE 'Enroll%'
)


,SubjectDetail AS
(
SELECT DISTINCT HB.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,HB.SubjectID
	  ,HB.DateofEnrollment
      ,HB.[SubjectIDNotfoundIn]

FROM HBSubjects HB
LEFT JOIN [AD550].[v_SiteStatus] SS ON SS.SiteID=HB.SiteID
WHERE SubjectID NOT IN 
(SELECT DISTINCT SubjectID FROM ClinSubjects)
AND ISNUMERIC(HB.SiteID)=1


UNION

SELECT DISTINCT CLIN.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,CLIN.SubjectID
	  ,CLIN.DateofEnrollment
      ,CLIN.[SubjectIDNotfoundIn]

FROM ClinSubjects CLIN
LEFT JOIN [AD550].[v_SiteStatus] SS ON SS.SiteID=CLIN.SiteID
WHERE SubjectID NOT IN 
(SELECT SubjectID FROM HBSubjects) 
AND ISNUMERIC(CLIN.SiteID)=1
)



,NoRecords AS
(
SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,'' AS SubjectID
	  ,CAST(NULL AS date) AS DateofEnrollment
	  ,'All records match-no action required' AS [SubjectIDNotfoundIn]

FROM [AD550].[v_SiteParameter] SP
LEFT JOIN [AD550].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM SubjectDetail)
)

SELECT *
FROM SubjectDetail

UNION

SELECT *
FROM NoRecords



--ORDER BY SiteID, SubjectID, SubjectIDNotfoundIn



GO
