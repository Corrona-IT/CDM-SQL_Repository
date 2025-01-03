USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_HBSummarybySite]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [IBD600].[v_op_HBSummarybySite] AS


WITH NBRINEDC AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,COUNT(DISTINCT SubjectID) AS NbrInCinEDC
FROM [Reporting].[IBD600].[v_SiteParameter] SL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[IBD600].[t_HBCompareVisitLog] A ON A.SiteID=SL.SiteID
GROUP BY SL.SiteID, SS.SiteStatus, SS.SFSiteStatus
--ORDER BY SiteID
)

--Get listing of subjects exited from the registry in the EDC
,EXITSUBJECTS AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,A.SubjectID as SubjectID
FROM [Reporting].[IBD600].[v_SiteParameter] SL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[IBD600].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'
--ORDER BY SiteID
)

--Get a count of subjects exits by site from the EDC
,EXITSINEDC AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,(SELECT COUNT(DISTINCT SubjectID) 
	    FROM [Reporting].[IBD600].[t_HBCompareVisitLog] A
		WHERE A.SiteID=SL.SiteID AND A.VisitType='Exit') AS NbrExitsInClinEDC
FROM [Reporting].[IBD600].[v_SiteParameter] SL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
GROUP BY SL.SiteID, SS.SiteStatus, SS.SFSiteStatus
--ORDER BY SiteID
)

--Get count of non-exited subjects by site in the EDC
,ClinCount AS (
SELECT EDC.SiteID
      ,EDC.SiteStatus
	  ,EDC.SFSiteStatus
      ,NbrInCinEDC-ISNULL(EXITS.NbrExitsInClinEDC, 0) AS NbrInClinEDC
FROM NBRINEDC EDC
LEFT JOIN EXITSINEDC EXITS ON EDC.SiteID=EXITS.SiteID
--ORDER BY EDC.SiteID
)

--Get a count of subjects by site in the HB database 
,NBRINHB AS (
SELECT SL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,COUNT (DISTINCT HB.SUBJID) AS NbrInHBEDC
FROM [Reporting].[IBD600].[v_SiteParameter] SL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[IBD600].[t_HB] HB ON HB.STNO=SL.SiteID
GROUP BY SL.SiteID, SS.SiteStatus, SS.SFSiteStatus
--ORDER BY SL.SiteID
)

,ClinWOExitSSubjects AS (
SELECT A.SiteID AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,A.SubjectID AS SubjectID
FROM [Reporting].[IBD600].[t_HBCompareVisitLog] A
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=A.SiteID
WHERE A.SubjectID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)

,HBWOExitSubjects AS (
SELECT HB.STNO AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,HB.SUBJID AS SubjectID
FROM [Reporting].[IBD600].[t_HB] HB 
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=HB.STNO
WHERE HB.SUBJID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)

--Get count of non-exited subject by site in the HB database
,HBCount AS (
SELECT HB.SiteID
      ,HB.SiteStatus
	  ,HB.SFSiteStatus
	  ,COUNT(DISTINCT SubjectID) AS NbrInHBEDC
FROM HBWOExitSubjects HB
WHERE ISNULL(HB.SubjectID, '')<>''
GROUP BY HB.SiteID, HB.SiteStatus,HB.SFSiteStatus
--ORDER BY HB.SiteID
)

,MATCHINGPAIRS AS (
SELECT HB.SiteID AS SiteID
      ,HB.SiteStatus
	  ,HB.SFSiteStatus
      ,COUNT (DISTINCT SubjectID) AS NbrMatching
FROM HBWOExitSubjects HB
WHERE HB.SubjectID IN
   (SELECT SubjectID FROM ClinWOExitSSubjects)
GROUP BY HB.SiteID, HB.SiteStatus, HB.SFSiteStatus
--ORDER BY SL.SiteID
)

SELECT SL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,ISNULL(Clin.NbrInClinEDC, 0) AS NbrInClinEDC
	  ,ISNULL(HB.NbrInHBEDC, 0) AS NbrInHBEDC
	  ,ISNULL(MP.NbrMatching, 0) AS NbrMatching
	  ,CASE WHEN ISNULL(MP.NbrMatching, 0)=CLIN.NbrInClinEDC AND ISNULL(MP.NbrMatching, 0)=HB.NbrInHBEDC
	   THEN 'No'
	   ELSE 'Yes'
	   END AS ActionRequired
FROM [Reporting].[IBD600].[v_SiteParameter] SL
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN ClinCount Clin ON Clin.SiteID=SL.SiteID
LEFT JOIN HBCount HB ON HB.SiteID=SL.SiteID
LEFT JOIN MATCHINGPAIRS MP ON MP.SiteID=SL.SiteID
--ORDER BY CLIN.SiteID




GO
