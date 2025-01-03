USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_HBMissingIDs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================================================
-- V1.2 Author:		Kevin Soe
-- Create date: 08/10/2022
-- Description:	Procedure to create table for MS HB vs Clinical EDC comparison. Previous versions was set up as a view but took too long to run so converted into a stored procedure that writes to a table.
-- ===================================================================================================

			   --EXECUTE
CREATE PROCEDURE [MS700].[usp_op_HBMissingIDs] AS


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*		   --SELECT * FROM
CREATE TABLE [MS700].[t_op_HBMissingIDs]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar] (8) NULL,
	[SFSiteStatus] [varchar] (20) NULL,
	[SubjectID] [bigint] NULL,
	[DateofEnrollment] [date] NULL,
	[MissingInformation] [varchar] (50) NOT NULL
);
*/

TRUNCATE TABLE [Reporting].[MS700].[t_op_HBMissingIDs];

IF OBJECT_ID('tempdb..#EXITSUBJECTS') IS NOT NULL  DROP TABLE #EXITSUBJECTS 

--WITH EXITSUBJECTS AS (
SELECT SL.SiteID
      ,A.SubjectID as SubjectID

INTO #EXITSUBJECTS

FROM [Reporting].[MS700].[v_SiteParameter] SL
LEFT JOIN [Reporting].[MS700].[t_HBCompareVisitLog] A ON SL.SiteID=A.SiteID
WHERE A.VisitType='Exit'
AND SL.SiteID NOT IN (997, 998, 999)

--SELECT * FROM #EXITSUBJECTS

IF OBJECT_ID('tempdb..#HBSUBJECTS') IS NOT NULL  DROP TABLE #HBSUBJECTS 

--,HBSubjects AS (
SELECT DISTINCT [STNO] AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,[SUBJID] AS SubjectID
	  ,CAST(DATECNST AS date) AS DateofEnrollment
      ,'Enrollment Visit in RCC Clinical EDC' AS [MissingInformation]

INTO #HBSUBJECTS

FROM [Reporting].[MS700].[t_HB] HB
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=HB.STNO
WHERE CAST([SUBJID] AS bigint) NOT IN (SELECT SubjectID FROM #EXITSUBJECTS)
AND SS.SiteID NOT IN (997, 998, 999)

--SELECT * FROM #HBSUBJECTS

IF OBJECT_ID('tempdb..#CLINSUBJECTS') IS NOT NULL  DROP TABLE #CLINSUBJECTS 

--,ClinSubjects AS (
SELECT DISTINCT vl.SiteID AS SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,vl.SubjectID AS SubjectID
	  ,CAST(VisitDate AS date) DateofEnrollment
      ,'Personal Information in Trial Master PI EDC' AS [MissingInformation]
	  --SELECT *

INTO #CLINSUBJECTS

FROM [Reporting].[MS700].[t_HBCompareVisitLog] vl
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=vl.SiteID
WHERE CAST(vl.SubjectID AS bigint) NOT IN (SELECT SubjectID FROM #EXITSUBJECTS)
AND vl.VisitType LIKE 'Enroll%'
AND SS.SiteID NOT IN (997, 998, 999)

--SELECT * FROM #CLINSUBJECTS

IF OBJECT_ID('tempdb..#SubjectDetail') IS NOT NULL  DROP TABLE #SubjectDetail 

--,SubjectDetail AS (
SELECT * INTO #SubjectDetail FROM (

SELECT DISTINCT HB.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,HB.SubjectID
	  ,HB.DateofEnrollment
      ,HB.[MissingInformation]

FROM #HBSubjects HB
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=HB.SiteID
WHERE SubjectID NOT IN 
(SELECT DISTINCT SubjectID FROM #ClinSubjects)
AND ISNUMERIC(HB.SiteID)=1
--AND SS.SiteID NOT IN (997, 998, 999)

UNION

SELECT DISTINCT CLIN.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,CLIN.SubjectID
	  ,CLIN.DateofEnrollment
      ,CLIN.[MissingInformation]

FROM #ClinSubjects CLIN
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=CLIN.SiteID
WHERE SubjectID NOT IN 
(SELECT SubjectID FROM #HBSubjects) 
AND ISNUMERIC(CLIN.SiteID)=1
--AND CLIN.SiteID<>999
) as tmp

--SELECT * FROM #SubjectDetail

IF OBJECT_ID('tempdb..#NoRecords') IS NOT NULL  DROP TABLE #NoRecords 

--,NoRecords AS (
SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,NULL AS SubjectID
	  ,CAST(NULL AS date) AS DateofEnrollment
	  ,'None Missing' AS [SubjectIDNotfoundIn]

INTO #NoRecords

FROM [MS700].[v_SiteParameter] SP
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM #SubjectDetail)
--)

--SELECT * FROM #NoRecords

INSERT INTO [Reporting].[MS700].[t_op_HBMissingIDs]
(
	[SiteID],
	[SiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[DateofEnrollment],
	[MissingInformation]
)


SELECT *
FROM #SubjectDetail
WHERE SiteID NOT IN (999, 1440)

UNION

SELECT *
FROM #NoRecords
WHERE SiteID NOT IN (999, 1440)

END

--ORDER BY SiteID, SubjectID, SubjectIDNotfoundIn



GO
