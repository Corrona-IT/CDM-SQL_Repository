USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_HBSummarybySite]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


























-- =====================================================================
-- Author:		Kaye Mowrey
-- Create date: 12/14/2018
-- V2 Author: Kevin Soe
-- V2 Update Date: 5/1/2020
-- Description:	Procedure for RA 100 HB vs Clinical EDC Summary by Site
-- =====================================================================
			  --EXECUTE
CREATE PROCEDURE [RA100].[usp_op_HBSummarybySite] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


/*

CREATE TABLE [RA100].[t_op_HBSummarybySite]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[NbrinClinEDC] [int] NOT NULL,
	[NbrInHBEDC] [int] NULL,
	[NbrMatching] [int] NULL,
	[ActionRequired] [varchar] (4) NULL
);
*/


TRUNCATE TABLE [RA100].[t_op_HBSummarybySite]


/*******Get List Approved / Active Sites. Only Approved / Active Sites will be included in report*******/

IF object_id('tempdb..#ActiveSites') IS NOT NULL BEGIN DROP TABLE #ActiveSites END

SELECT DISTINCT CAST(S.[siteNumber] AS int) AS SiteID
		,S.[currentStatus] AS Status

INTO #ActiveSites

FROM [Salesforce].[dbo].[registryStatus] S
WHERE S.[name] =  'Rheumatoid Arthritis (RA-100,02-021)'
AND S.currentStatus = 'Approved / Active'


IF OBJECT_ID('tempdb..#ClinExitSubjects') IS NOT NULL BEGIN DROP TABLE #ClinExitSubjects END

SELECT SiteID
       ,SubjectID
	   ,VisitDate

INTO #ClinExitSubjects 

FROM [Reporting].[RA100].[t_HBCompareVisitLog] VL
WHERE VisitType='Exit'
AND VisitDate>=(SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] B WHERE B.SiteID=VL.SiteID AND B.SubjectID=VL.SubjectID AND B.VisitType IN ('Follow-Up', 'Enrollment', 'Exit'))

--SELECT * FROM #ClinExitSubjects WHERE SiteID=41


/*******Get List of subjects from the clinical EDC that that have an Enrollment or Follow up Date on or after 3/8/2014*******/

IF OBJECT_ID('tempdb..#ClinSubjects') IS NOT NULL BEGIN DROP TABLE #ClinSubjects END
--(ConsentType commented out for V2 by KSoe)
SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VisitDate
	  --,ConsentType
	  ,SubjectIDNotFoundIn
   --SELECT * FROM
INTO #ClinSubjects

FROM (

SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID, VisitDate ORDER BY SiteID, SubjectID, VisitDate, VisitType) AS ROWNUM
       , SiteID
       ,SubjectID
	   ,VisitType
	   ,VisitDate
	   --,CASE WHEN VisitType='Enrollment' AND VL.VisitDate>='2014-03-08' THEN 'New Consent'
	   -- WHEN VisitType='Enrollment' AND VL.VisitDate<'2014-03-08' THEN 'Re-Consent'
	   -- WHEN VisitType='Follow-Up' THEN 'Re-Consent'
	   -- END AS ConsentType
	   ,'HB EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[RA100].[t_HBCompareVisitLog] VL
WHERE VisitDate=(SELECT MIN(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] B WHERE B.SiteID=VL.SiteID AND B.SubjectID=VL.SubjectID AND VisitType IN ('Enrollment'/*, 'Follow-Up'*/) AND NOT EXISTS(
  SELECT VisitType FROM [Reporting].[RA100].[t_HBCompareVisitLog] C WHERE  C.SiteID=VL.SiteID AND C.SubjectID=VL.SubjectID AND C.VisitType='Exit')) AND
SubjectID NOT IN (SELECT SubjectID FROM #ClinExitSubjects)
AND SubjectID<>117010036


UNION

SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID, VisitDate ORDER BY SiteID, SubjectID, VisitDate, VisitType) AS ROWNUM
       , SiteID
       ,SubjectID
	   ,VisitType
	   ,VisitDate
	   --,CASE WHEN VisitType='Enrollment' AND VL.VisitDate>='2014-03-08' THEN 'New Consent'
	   -- WHEN VisitType='Enrollment' AND VL.VisitDate<'2014-03-08' THEN 'Re-Consent'
	   -- WHEN VisitType='Follow-Up' THEN 'Re-Consent'
	   -- END AS ConsentType
	   ,'HB EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[RA100].[t_HBCompareVisitLog] VL
WHERE VisitDate=(SELECT MIN(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] B WHERE B.SiteID=VL.SiteID AND B.SubjectID=VL.SubjectID AND VisitType IN ('Enrollment'/*, 'Follow-Up'*/) AND B.VisitDate > (SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] C WHERE  C.SiteID=VL.SiteID AND C.SubjectID=VL.SubjectID AND C.VisitType='Exit')) AND
SubjectID NOT IN (SELECT SubjectID FROM #ClinExitSubjects)
AND SubjectID<>117010036

) A

WHERE ROWNUM=1

---SELECT * from #ClinSubjects WHERE SubjectID=2032582 ORDER BY SiteID, SubjectID, VisitDate


IF OBJECT_ID('tempdb..#NbrInClinEDC') IS NOT NULL BEGIN DROP TABLE #NbrInClinEDC END

SELECT SL.SiteID
      ,ISNULL(COUNT(DISTINCT CS.SubjectID), 0) AS NbrInClinEDC

INTO #NbrInClinEDC

FROM [RA100].[v_op_SiteIDParameter] SL
LEFT JOIN #ClinSubjects CS ON SL.SiteID=CS.SiteID
WHERE CS.VisitDate >= '2014-07-01'
AND CS.VisitType = 'Enrollment'
GROUP BY SL.SiteID


IF OBJECT_ID('tempdb..#HBSubjects') IS NOT NULL BEGIN DROP TABLE #HBSubjects END

SELECT DISTINCT STNO AS SiteID
      ,SUBJID AS SubjectID
	  ,TYPECNST
   --SELECT * FROM
INTO #HBSubjects

FROM [Reporting].[RA100].[t_HB] HB
WHERE SUBJID NOT IN (SELECT SubjectID FROM #ClinExitSubjects)
AND SUBJID<>117010036
AND STNO NOT LIKE '99%'
--AND DATECNST>='2014-07-01'
--AND TYPECNST <> '1'



--IF OBJECT_ID('tempdb..#NbrInHB') IS NOT NULL BEGIN DROP TABLE #NbrInHB END
--
--SELECT SL.SiteID
--      ,ISNULL(COUNT (DISTINCT HB.SubjectID), 0) AS NbrInHBEDC
--
--INTO #NbrInHB
--
--FROM [RA100].[v_op_SiteIDParameter] SL
--LEFT JOIN #HBSubjects HB ON HB.SiteID=SL.SiteID
--WHERE HB.TYPECNST <> '1'
--GROUP BY SL.SiteID
--

IF OBJECT_ID('tempdb..#MATCHINGPAIRS') IS NOT NULL BEGIN DROP TABLE #MATCHINGPAIRS END

SELECT SL.SiteID AS SiteID
      ,ISNULL(COUNT (DISTINCT CS.SubjectID), 0) AS NbrMatching
   --SELECT * FROM
INTO #MATCHINGPAIRS
   --ORDER BY SiteID
FROM [RA100].[v_op_SiteIDParameter] SL
LEFT JOIN #ClinSubjects CS ON CS.SiteID=SL.SiteID
WHERE CS.SubjectID IN (SELECT SubjectID FROM #HBSubjects)
AND SubjectID<>117010036
AND CS.VisitDate >= '2014-07-01'
GROUP BY SL.SiteID

		  --SELECT * FROM
INSERT INTO [RA100].[t_op_HBSummarybySite]
(
  [SiteID],
  [SiteStatus],
  [NbrInClinEDC],
  --[NbrInHBEDC],
  [NbrMatching],
  [ActionRequired]
)

SELECT SL.SiteID
      ,SS.SiteStatus
      ,ISNULL(Clin.NbrInClinEDC, 0) AS NbrInClinEDC
	  --,ISNULL(HB.NbrInHBEDC, 0) AS NbrInHBEDC
	  ,ISNULL(MP.NbrMatching, 0) AS NbrMatching
	  ,CASE WHEN ISNULL(MP.NbrMatching, 0)=ISNULL(CLIN.NbrInClinEDC, 0) --AND ISNULL(MP.NbrMatching, 0)=ISNULL(HB.NbrInHBEDC, 0)
	   THEN 'No'
	   ELSE 'Yes'
	   END AS ActionRequired
FROM [RA100].[v_op_SiteIDParameter] SL
LEFT JOIN [RA100].[v_op_SiteStatus] SS ON SS.SiteID=SL.SiteID
LEFT JOIN #NbrInClinEDC Clin ON Clin.SiteID=SL.SiteID
--LEFT JOIN #NbrInHB HB ON HB.SiteID=SL.SiteID
LEFT JOIN #MATCHINGPAIRS MP ON MP.SiteID=SL.SiteID
WHERE SL.SiteID IN (SELECT SiteID FROM #ActiveSites)
ORDER BY CLIN.SiteID


END








GO
