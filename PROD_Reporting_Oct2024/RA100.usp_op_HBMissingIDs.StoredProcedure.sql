USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_HBMissingIDs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















-- =======================================================
-- Author:		Kaye Mowrey
-- Create date: 12/14/2018
-- V2 Author: Kevin Soe
-- V2 Update Date: 5/1/2020
-- Description:	Procedure for RA 100 HB Missing IDs
-- =======================================================
			  --EXECUTE
CREATE PROCEDURE [RA100].[usp_op_HBMissingIDs] AS
	-- Add the parameters for the stored procedure here


BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
	SET NOCOUNT ON;


/*

CREATE TABLE [RA100].[t_op_HBMissingIDs]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[DateOfEnrollment] [date] NULL,
	--[ConsentType] [varchar](12) NULL,
	[SubjectIDNotFoundIn] [varchar](15) NULL
);
*/


TRUNCATE TABLE [RA100].[t_op_HBMissingIDs]

/*******Get List Approved / Active Sites. Only Approved / Active Sites will be included in report*******/

IF object_id('tempdb..#ActiveSites') IS NOT NULL BEGIN DROP TABLE #ActiveSites END

SELECT DISTINCT CAST([siteNumber] AS int) AS SiteID,
		[currentStatus] AS Status

INTO #ActiveSites

FROM [Salesforce].[dbo].[registryStatus] S
WHERE S.[name] =  'Rheumatoid Arthritis (RA-100,02-021)'
AND S.currentStatus = 'Approved / Active'


/*******Get List of exited subjects that do not have a follow up after the exit date*******/

IF OBJECT_ID('tempdb..#ClinExitSubjects') IS NOT NULL BEGIN DROP TABLE #ClinExitSubjects END

SELECT SiteID
       ,SubjectID
	   ,VisitDate AS DateOfEnrollment

INTO #ClinExitSubjects 

FROM [Reporting].[RA100].[t_HBCompareVisitLog] VL
WHERE VisitType='Exit'
AND VisitDate>=(SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] B WHERE B.SiteID=VL.SiteID AND B.SubjectID=VL.SubjectID AND B.VisitType IN ('Follow-Up', 'Enrollment', 'Exit'))

--ORDER BY SiteID, SubjectID, VisitDate
---SELECT * FROM #ClinExitSubjects WHERE SubjectID IN (19302048, 20013056, 19101095, 19101029) ORDER BY SiteID, SubjectID, VisitDate

/*******Get List of Subjects from Honest Broker table *******/
--date filter is currently commented out while we determine impact - KM: 12/12/2018


IF object_id('tempdb..#HBSubjects') IS NOT NULL BEGIN DROP TABLE #HBSubjects END

SELECT DISTINCT CAST([STNO] AS int) AS SiteID
      ,SiteStatus
      ,CAST([SUBJID] AS bigint) AS SubjectID
	  ,VISITDT AS VisitDate
	  ,DATECNST
	  ,TYPECNST
       --,CASE WHEN HB.TYPECNST=0 THEN 'New Consent'
	   --WHEN HB.TYPECNST=1 THEN 'Re-Consent' (commented out for V2)
	   --ELSE ''
	   --END AS ConsentType
	  ,'Clinical EDC' AS [SubjectIDNotfoundIn]

INTO #HBSubjects

FROM [Reporting].[RA100].[t_HB] HB
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] SS ON SS.SiteID=HB.STNO
WHERE CAST([SUBJID] AS bigint) NOT IN (SELECT SubjectID FROM #ClinExitSubjects) 
--AND DATECNST>='2014-07-01'

--SELECT * FROM #HBSubjects
	 

/*******Get List of subjects from the clinical EDC that that have an Enrollment or Follow up Date on or after 3/8/2014*******/

--select * from #ClinSubjects

IF OBJECT_ID('tempdb..#ClinSubjects') IS NOT NULL BEGIN DROP TABLE #ClinSubjects END
--(ConsentType commented out for V2 by KSoe)
SELECT SiteID
      ,SiteStatus
      ,SubjectID
	  ,VisitType
	  ,VisitDate
	  --,ConsentType
	  ,SubjectIDNotFoundIn
INTO #ClinSubjects
FROM (
--(Follow-ups commented out for V2 by KSoe)
SELECT ROW_NUMBER() OVER(PARTITION BY vl.SiteID, SubjectID, VisitDate ORDER BY vl.SiteID, SubjectID, VisitDate, VisitType) AS ROWNUM
       ,VL.SiteID
	   ,SS.SiteStatus
       ,SubjectID
	   ,VisitType
	   ,VisitDate
	   --,CASE WHEN VisitType='Enrollment' AND VL.VisitDate>='2014-03-08' THEN 'New Consent'
	   -- WHEN VisitType='Enrollment' AND VL.VisitDate<'2014-03-08' THEN 'Re-Consent'
	   -- WHEN VisitType='Follow-Up' THEN 'Re-Consent'
	   -- END AS ConsentType
	   ,'HB EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[RA100].[t_HBCompareVisitLog] VL
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] SS ON SS.SiteID=VL.SiteID
WHERE VisitDate=(SELECT MIN(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] B WHERE B.SiteID=VL.SiteID AND B.SubjectID=VL.SubjectID AND VisitType IN ('Enrollment'/*,'Follow-Up'*/) AND NOT EXISTS(
  SELECT VisitType FROM [Reporting].[RA100].[t_HBCompareVisitLog] C WHERE  C.SiteID=VL.SiteID AND C.SubjectID=VL.SubjectID AND C.VisitType='Exit')) AND
SubjectID NOT IN (SELECT SubjectID FROM #ClinExitSubjects)
AND SubjectID<>117010036
--AND VisitDate >= '2014-07-01'

UNION

--(Follow-ups commented out for V2 by KSoe)
SELECT ROW_NUMBER() OVER(PARTITION BY VL.SiteID, SubjectID, VisitDate ORDER BY VL.SiteID, SubjectID, VisitDate, VisitType) AS ROWNUM
       ,VL.SiteID
	   ,SS.SiteStatus
       ,SubjectID
	   ,VisitType
	   ,VisitDate
	   --,CASE WHEN VisitType='Enrollment' AND VL.VisitDate>='2014-03-08' THEN 'New Consent'
	   -- WHEN VisitType='Enrollment' AND VL.VisitDate<'2014-03-08' THEN 'Re-Consent'
	   -- WHEN VisitType='Follow-Up' THEN 'Re-Consent'
	   -- END AS ConsentType
	   ,'HB EDC' AS [SubjectIDNotfoundIn]
FROM [Reporting].[RA100].[t_HBCompareVisitLog] VL
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] SS ON SS.SiteID=VL.SiteID
WHERE VisitDate=(SELECT MIN(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] B WHERE B.SiteID=VL.SiteID AND B.SubjectID=VL.SubjectID AND VisitType IN ('Enrollment'/*,'Follow-Up'*/) AND B.VisitDate > (SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_HBCompareVisitLog] C WHERE  C.SiteID=VL.SiteID AND C.SubjectID=VL.SubjectID AND C.VisitType='Exit')) AND
SubjectID NOT IN (SELECT SubjectID FROM #ClinExitSubjects)
AND SubjectID<>117010036
--AND VisitDate >= '2014-07-01' --Added for V2

) A

WHERE ROWNUM=1


--ORDER BY SiteID, SubjectID, VisitDate
---SELECT * from #ClinSubjects WHERE SubjectID=2032582 ORDER BY SiteID, SubjectID, VisitDate


/*******Get List of subjects that are in the HB and not in the Clinical EDC and vice versa*******/

INSERT INTO [RA100].[t_op_HBMissingIDs]
(
    [SiteID],
	[SiteStatus],
	[SubjectID],
	[DateOfEnrollment],
    --[ConsentType],
    [SubjectIDNotFoundIn]
)

--(HB vs Clin Comparison results commented out for V2 by KSoe)
--SELECT DISTINCT SiteID
--      ,SubjectID
--	  ,DATECNST AS DateOfEnrollment
--	  --,ConsentType
--      ,[SubjectIDNotfoundIn]
--FROM #HBSubjects HB
--WHERE SubjectID NOT IN (SELECT DISTINCT SubjectID FROM #ClinSubjects)
--AND SiteID NOT LIKE '99%'
--AND DATECNST >= '2014-07-01'
----AND TYPECNST <> '1'

--UNION

SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,VisitDate AS DateOfEnrollment
	  --,ConsentType
      ,[SubjectIDNotfoundIn]
FROM #ClinSubjects
WHERE --(VisitDate >='2014-03-08')
(SubjectID NOT IN (SELECT SubjectID FROM #HBSubjects))
AND (SiteID NOT LIKE '99%')
AND VisitDate >= '2014-07-01'
AND VisitType = 'Enrollment'
AND SiteID IN (SELECT SiteID FROM #ActiveSites)
--ORDER BY SiteID, SubjectID, SubjectIDNotfoundIn

END








GO
