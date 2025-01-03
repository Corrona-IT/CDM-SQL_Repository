USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_HBMissingIDs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE view [PSA400].[v_op_HBMissingIDs] as

WITH EXITSUBJECTS AS (
SELECT CAST(SL.SiteID AS int) AS SiteID
      ,SS.SiteStatus
      ,A.SubjectID AS SubjectID
FROM [Reporting].[PSA400].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[PSA400].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType LIKE 'Exit%'

)

,HBSubjects AS (
SELECT DISTINCT CAST([STNO] AS int) AS SiteID
      ,SS.SiteStatus
	  ,[SUBJID] AS SubjectID
	  ,CAST(DATECNST AS date) AS DateofEnrollment
      ,'Clinical EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[PSA400].[t_HB] HB
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=HB.STNO
WHERE CAST([SUBJID] AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)

)

,ClinSubjects AS (
SELECT DISTINCT CAST(vl.SiteID AS int) AS SiteID
      ,SS.SiteStatus
	  ,vl.SubjectID AS SubjectID
	  ,(SELECT DISTINCT CAST(VisitDate AS date) FROM [PSA400].[t_HBCompareVisitLog] vl2 WHERE vl2.SubjectID=vl.SubjectID AND
	    VisitType LIKE 'Enroll%') AS DateofEnrollment
      ,'HB EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[PSA400].[t_HBCompareVisitLog] vl
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=vl.SiteID
WHERE CAST(SubjectID AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
AND (SELECT DISTINCT CAST(VisitDate AS date) FROM [PSA400].[t_HBCompareVisitLog] vl2 WHERE vl2.SubjectID=vl.SubjectID AND
	    VisitType LIKE 'Enroll%')>='2017-03-01'
)


SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,DateofEnrollment
      ,[SubjectIDNotfoundIn]
FROM HBSubjects
WHERE SubjectID NOT IN 
(SELECT DISTINCT SubjectID FROM ClinSubjects)
AND SiteID NOT LIKE '99%'

UNION

SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,DateofEnrollment
      ,[SubjectIDNotfoundIn]
FROM ClinSubjects
WHERE SubjectID NOT IN 
(SELECT SubjectID FROM HBSubjects) 
AND SiteID NOT IN (99997, 99998, 99999)

--ORDER BY SiteID, SubjectID, SubjectIDNotfoundIn

GO
