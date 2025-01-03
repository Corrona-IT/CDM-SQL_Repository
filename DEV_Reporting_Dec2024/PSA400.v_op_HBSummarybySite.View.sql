USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_HBSummarybySite]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [PSA400].[v_op_HBSummarybySite] AS


--Get a listing of Subjects starting with Version 2 and above (those enrolled on or after 3/1/2017)
WITH V2SUBJECTS AS (
SELECT DISTINCT CVL.SiteID
      ,SS.SiteStatus
	  ,CVL.SubjectID
FROM [Reporting].[PSA400].[t_HBCompareVisitLog] CVL
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=CVL.SiteID
WHERE VisitType LIKE 'Enroll%'
AND VisitDate >= '2017-03-01'
)


,NBRINEDC AS (

SELECT SL.SiteID
      ,COUNT(DISTINCT SubjectID) AS NbrInCinEDC

FROM [Reporting].[PSA400].[v_op_SiteListing] SL
LEFT JOIN V2SUBJECTS v2 ON v2.SiteID=SL.SiteID
GROUP BY SL.SiteID
--ORDER BY SiteID
)


--Get a list of subject IDs by site that have an exit visit in the EDC
,EXITSUBJECTS AS (
SELECT DISTINCT SL.SiteID
      ,A.SubjectID as SubjectID
FROM [Reporting].[PSA400].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSA400].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'
--ORDER BY SiteID
)


--Get a count of the exits for each site in the EDC
,EXITSINEDC AS (
SELECT SL.SiteID
      ,(SELECT COUNT(DISTINCT SubjectID)
	    FROM [Reporting].[PSA400].[t_HBCompareVisitLog] A
		WHERE A.SiteID=SL.SiteID AND A.VisitType = 'Exit'
		AND SubjectID IN (SELECT SubjectID FROM V2SUBJECTS)) AS NbrExitsInClinEDC
FROM [Reporting].[PSA400].[v_op_SiteListing] SL
GROUP BY SL.SiteID
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


--Get a listing of the subjects per site in the Honest Broker file
,HBV2SUBJECTS AS (
SELECT DISTINCT STNO AS SiteID
      ,SS.SiteStatus
	  ,SUBJID AS SubjectID
FROM [Reporting].[PSA400].[t_HB] HB
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=HB.STNO
)

--Get a count of subjects in the Honest Broker file by site that are V2 subjects
,NBRINHB AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,COUNT (DISTINCT HB.SubjectID) AS NbrInHBEDC
FROM [Reporting].[PSA400].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN HBV2SUBJECTS HB ON HB.SiteID=SL.SiteID
GROUP BY SL.SiteID, SS.SiteStatus
--ORDER BY SL.SiteID
)


--Get a count of subjects in the Honest Broker file by site that have not been exited
,HBCount AS (
SELECT HB.SiteID
      ,HB.SiteStatus
	  ,COUNT(DISTINCT SubjectID) AS NbrInHBEDC
FROM HBV2SUBJECTS HB
WHERE ISNULL(SubjectID, '')<>''
AND HB.SubjectID NOT IN (SELECT DISTINCT SubjectID FROM EXITSUBJECTS ES)
GROUP BY HB.SiteID, HB.SiteStatus
--ORDER BY HB.SiteID
)

--Get a listing of subjects enrolled by site in the EDC that have not been exited
,ClinWOExitSSubjects AS (
SELECT A.SiteID AS SiteID
      ,A.SiteStatus
      ,A.SubjectID AS SubjectID
FROM V2SUBJECTS A
WHERE A.SubjectID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)

--Get a listing of subjects enrolled by site in the Honest Broker database that have not been exited
,HBWOExitSubjects AS (
SELECT SiteID
      ,HB.SiteStatus
	  ,SubjectID
FROM HBV2SUBJECTS HB 
WHERE SubjectID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)


,MATCHINGPAIRS AS (
SELECT SL.SiteID AS SiteID
      ,SS.SiteStatus
	  ,ISNULL(COUNT (DISTINCT SubjectID), 0) AS NbrMatching
FROM [Reporting].[PSA400].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID 
LEFT JOIN HBWOExitSubjects HB ON HB.SiteID=SL.SiteID
WHERE HB.SubjectID IN (SELECT SubjectID FROM ClinWOExitSSubjects)
GROUP BY SL.SiteID, SS.SiteStatus
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
FROM [Reporting].[PSA400].[v_op_SiteListing] SL
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN ClinCount Clin ON Clin.SiteID=SL.SiteID
LEFT JOIN HBCount HB ON HB.SiteID=SL.SiteID
LEFT JOIN MATCHINGPAIRS MP ON MP.SiteID=SL.SiteID
--ORDER BY CLIN.SiteID




GO
