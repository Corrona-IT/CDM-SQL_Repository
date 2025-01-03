USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_HBSummarybySite]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [AD550].[v_op_HBSummarybySite] AS


WITH NBRINEDC AS (

SELECT SL.SiteID
      ,SS.SiteStatus
	  ,ISNULL(COUNT(DISTINCT A.SubjectID), 0) AS NbrInCinEDC

FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN [Reporting].[AD550].[v_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[AD550].[t_HBCompareVisitLog] A ON A.SiteID=SL.SiteID
GROUP BY SL.SiteID, SS.SiteStatus
--ORDER BY SiteID
)



,EXITSINEDC AS (

SELECT SL.SiteID
      ,SS.SiteStatus
      ,(SELECT ISNULL(COUNT(DISTINCT SubjectID), 0)
	    FROM [Reporting].[AD550].[t_HBCompareVisitLog] A
		WHERE A.SiteID=SL.SiteID AND A.VisitType='Exit') AS NbrExitsInClinEDC

FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN [Reporting].[AD550].[v_SiteStatus] SS ON SS.SiteID=SL.SiteID

GROUP BY SL.SiteID, SS.SiteStatus
--ORDER BY SiteID
)

,ClinCount AS (

SELECT EDC.SiteID
      ,EDC.SiteStatus
      ,NbrInCinEDC-EXITS.NbrExitsInClinEDC AS NbrInClinEDC
FROM NBRINEDC EDC
LEFT JOIN EXITSINEDC EXITS ON EDC.SiteID=EXITS.SiteID
--ORDER BY EDC.SiteID
)

,NBRINHB AS (

SELECT SL.SiteID
      ,SS.SiteStatus
      ,ISNULL(COUNT (DISTINCT HB.SUBJID), 0) AS NbrInHBEDC

FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN [Reporting].[AD550].[v_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN [Reporting].[AD550].[t_HB] HB ON HB.STNO=SL.SiteID
GROUP BY SL.SiteID, SS.SiteStatus
--ORDER BY SL.SiteID
)

,HBCount AS (

SELECT HB.SiteID
	  ,NbrInHBEDC-EXITS.NbrExitsInClinEDC AS NbrInHBEDC

FROM NBRINHB HB
LEFT JOIN EXITSINEDC EXITS ON HB.SiteID=EXITS.SiteID
--ORDER BY HB.SiteID
)

,EXITSUBJECTS AS (
SELECT SL.SiteID
      ,A.SubjectID as SubjectID
FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN [Reporting].[AD550].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'
--ORDER BY SiteID
)

,ClinWOExitSSubjects AS (
SELECT A.SiteID AS SiteID
      ,A.SubjectID AS SubjectID
FROM [Reporting].[AD550].[t_HBCompareVisitLog] A
WHERE A.SubjectID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)

,HBWOExitSubjects AS (
SELECT HB.STNO AS SiteID
      ,HB.SUBJID AS SubjectID
FROM [Reporting].[AD550].[t_HB] HB 
WHERE HB.SUBJID NOT IN (SELECT SubjectID FROM EXITSUBJECTS)
--ORDER BY SL.SiteID
)


,MATCHINGPAIRS AS (

SELECT SL.SiteID AS SiteID
      ,ISNULL(COUNT (DISTINCT SubjectID), 0) AS NbrMatching

FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN HBWOExitSubjects HB ON HB.SiteID=SL.SiteID
WHERE HB.SubjectID IN
   (SELECT SubjectID FROM ClinWOExitSSubjects)

GROUP BY SL.SiteID
--ORDER BY SL.SiteID
)


SELECT SL.SiteID
      ,Clin.SiteStatus
      ,Clin.NbrInClinEDC
	  ,HB.NbrInHBEDC
	  ,ISNULL(MP.NbrMatching, 0) AS NbrMatching
	  ,CASE WHEN ISNULL(MP.NbrMatching, 0)=CLIN.NbrInClinEDC AND ISNULL(MP.NbrMatching, 0)=HB.NbrInHBEDC
	   THEN 'No'
	   ELSE 'Yes'
	   END AS ActionRequired
FROM [Reporting].[AD550].[v_SiteParameter] SL
LEFT JOIN ClinCount Clin ON Clin.SiteID=SL.SiteID
LEFT JOIN HBCount HB ON HB.SiteID=SL.SiteID
LEFT JOIN MATCHINGPAIRS MP ON MP.SiteID=SL.SiteID
--ORDER BY CLIN.SiteID




GO
