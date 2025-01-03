USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_HBSummarybySite]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [PSO500].[v_op_HBSummarybySite] AS

--Get a count of the number of subjects despite status at all sites
WITH NBRINEDC AS (
SELECT SL.SiteID
      ,COUNT(DISTINCT SubjectID) AS NbrInCinEDC
FROM [Reporting].[PSO500].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSO500].[t_HBCompareVisitLog] A ON A.SiteID=SL.SiteID
GROUP BY SL.SiteID
--ORDER BY SiteID
)

--Get a list of subject IDs by site that have an exit visit in the EDC
,EXITSUBJECTS AS (
SELECT DISTINCT SL.SiteID
      ,A.SubjectID as SubjectID
FROM [Reporting].[PSO500].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSO500].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'
--ORDER BY SiteID
)

--Get a count of the exits for each site in the EDC
,EXITSINEDC AS (
SELECT ES.SiteID
      ,COUNT(DISTINCT SubjectID) AS NbrExitsInClinEDC
FROM EXITSUBJECTS ES
GROUP BY ES.SiteID
--ORDER BY SiteID
)

--Get a count of subjects in the EDC that have not been exited by site
,ClinCount AS (
SELECT EDC.SiteID
      ,NbrInCinEDC-ISNULL(EXITS.NbrExitsInClinEDC, 0) AS NbrInClinEDC
FROM NBRINEDC EDC
LEFT JOIN EXITSINEDC EXITS ON EDC.SiteID=EXITS.SiteID
--ORDER BY EDC.SiteID
)

--Get a count of the number of subjects per site in the Honest Broker file
,NBRINHB AS (
SELECT SL.SiteID
      ,COUNT (DISTINCT HB.SUBJID) AS NbrInHBEDC
FROM [Reporting].[PSO500].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSO500].[t_HB] HB ON HB.STNO=SL.SiteID
AND ISNULL(HB.SUBJID, '')<>''
GROUP BY SL.SiteID
--ORDER BY SL.SiteID
)

--Get a count of subjects in the Honest Broker file by site that have not been exited
,HBCount AS (
SELECT STNO AS SiteID,
       COUNT(DISTINCT SUBJID) AS NbrInHBEDC
FROM [Reporting].[PSO500].[t_HB] HB
WHERE ISNULL(HB.SUBJID, '')<>''
AND SUBJID NOT IN (SELECT SUBJECTID FROM EXITSUBJECTS ES WHERE ES.SiteID=HB.STNO)
GROUP BY STNO
--ORDER BY HB.SiteID
)

--Get a listing of subjects enrolled by site in the EDC that have not been exited
,ClinWOExitSSubjects AS (
SELECT A.SiteID AS SiteID
      ,A.SubjectID AS SubjectID
FROM [Reporting].[PSO500].[t_HBCompareVisitLog] A
WHERE A.SubjectID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
AND A.VisitType='Enrollment'
--ORDER BY SL.SiteID
)


--Get a listing of subjects by site in the Honest Broker file that have not been exited 
,HBWOExitSubjects AS (
SELECT DISTINCT HB.STNO AS SiteID
      ,HB.SUBJID AS SubjectID
FROM [Reporting].[PSO500].[t_HB] HB 
WHERE HB.SUBJID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)

--Get a count of subjects that are in both the Honest Broker File and the EDC
,MATCHINGPAIRS AS (
SELECT SL.SiteID AS SiteID
      ,ISNULL(COUNT (DISTINCT SubjectID), 0) AS NbrMatching
FROM [Reporting].[PSO500].[v_op_SiteListing] SL
LEFT JOIN HBWOExitSubjects HB ON HB.SiteID=SL.SiteID
WHERE HB.SubjectID IN (SELECT SubjectID FROM ClinWOExitSSubjects)
GROUP BY SL.SiteID
--ORDER BY SL.SiteID
)


SELECT SL.SiteID
      ,SS.SiteStatus
      ,ISNULL(Clin.NbrInClinEDC, 0) AS NbrInClinEDC
	  ,ISNULL(HB.NbrInHBEDC, 0) AS NbrInHBEDC
	  ,ISNULL(MP.NbrMatching, 0) AS NbrMatching
	  ,CASE WHEN ISNULL(MP.NbrMatching, 0)=CLIN.NbrInClinEDC AND ISNULL(MP.NbrMatching, 0)=HB.NbrInHBEDC
	   THEN 'No'
	   ELSE 'Yes'
	   END AS ActionRequired
FROM [Reporting].[PSO500].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=SL.SiteID
LEFT JOIN ClinCount Clin ON Clin.SiteID=SL.SiteID
LEFT JOIN HBCount HB ON HB.SiteID=SL.SiteID
LEFT JOIN MATCHINGPAIRS MP ON MP.SiteID=SL.SiteID
--ORDER BY CLIN.SiteID




GO
