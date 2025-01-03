USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_HBMissingIDs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [PSO500].[v_op_HBMissingIDs] as

WITH EXITSUBJECTS AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,A.SubjectID as SubjectID
FROM [Reporting].[PSO500].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[PSO500].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'

)

,HBSubjects AS (
SELECT DISTINCT [STNO] AS SiteID
      ,SS.SiteStatus
	  ,[SUBJID] AS SubjectID
	  ,CAST(ICFDAT AS date) AS DateofEnrollment
      ,'Clinical EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[PSO500].[t_HB] HB
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=HB.STNO
WHERE CAST([SUBJID] AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)

)

,ClinSubjects AS (
SELECT DISTINCT vl.SiteID AS SiteID
      ,SS.SiteStatus
      ,vl.SubjectID AS SubjectID
	  ,(SELECT DISTINCT CAST(VisitDate AS date) FROM [PSO500].[t_HBCompareVisitLog] vl2 WHERE vl2.SubjectID=vl.SubjectID AND
	    VisitType LIKE 'Enroll%') AS DateofEnrollment
      ,'HB EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[PSO500].[t_HBCompareVisitLog] vl
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=vl.SiteID
WHERE CAST(SubjectID AS bigint) NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
)


SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,DateofEnrollment
      ,[SubjectIDNotfoundIn]
FROM HBSubjects
WHERE SubjectID NOT IN 
(SELECT DISTINCT SubjectID FROM ClinSubjects)
AND SiteID NOT IN (997, 998, 999)

UNION

SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,DateofEnrollment
      ,[SubjectIDNotfoundIn]
FROM ClinSubjects
WHERE SubjectID NOT IN 
(SELECT SubjectID FROM HBSubjects) 
AND SiteID NOT IN (997, 998, 999)


--ORDER BY SiteID, SubjectID, SubjectIDNotfoundIn

GO
