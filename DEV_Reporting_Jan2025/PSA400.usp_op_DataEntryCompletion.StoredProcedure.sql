USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_DataEntryCompletion]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- ==================================================================================
-- Author:		Kevin Soe
-- Create date: 12/9/2020
-- Description:	Procedure to create table PSA Data Entry Completion Report
-- ==================================================================================

			  --EXECUTE
CREATE PROCEDURE [PSA400].[usp_op_DataEntryCompletion]  AS

/* 
			 SELECT * FROM
CREATE TABLE [Reporting].[PSA400].[t_op_DataEntryCompletion]
(
	   [VisitID] [bigint] NOT NULL
      ,[SiteID] [int] NOT NULL
	  ,[SiteStatus] [nvarchar] (10) NULL
      ,[SubjectID] [bigint] NOT NULL
      ,[VisitType] [nvarchar] (150) NULL
	  ,[VisitSequence] [int] NOT NULL
      ,[VisitDate] [date] NULL
      ,[IncompleteMDForms] [nvarchar] (600) NULL
      ,[IncompleteSUForms] [nvarchar] (600) NULL

);

*/

			 --SELECT * FROM
TRUNCATE TABLE [Reporting].[PSA400].[t_op_DataEntryCompletion]

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


/*
Determine which forms are in a No Data Status based on the DAT PAGs table
0 = No Data
5 = Data Entered
10 = Complete
15 = Monitored - Remotre
25 = Monitored - Onsite
20 = Signed
30 = Locked
*/

IF OBJECT_ID('tempdb..#NoDataForms') IS NOT NULL BEGIN DROP TABLE #NoDataForms END

SELECT * 
INTO #NoDataForms
FROM (
SELECT P.[vID]
      ,P.[SITENUM]
      ,P.[VISNAME]
      ,P.[PAGENAME]
	  ,CASE
	   WHEN P.[PAGENAME] LIKE '%Visit%' THEN 0
	   WHEN P.[PAGENAME] LIKE '%1 of%'  THEN 1
	   WHEN P.[PAGENAME] LIKE '%2 of%'  THEN 2
	   WHEN P.[PAGENAME] LIKE '%3 of%'  THEN 3
	   WHEN P.[PAGENAME] LIKE '%4 of%'  THEN 4
	   WHEN P.[PAGENAME] LIKE '%5 of%'  THEN 5
	   WHEN P.[PAGENAME] LIKE '%6 of%'  THEN 6
	   WHEN P.[PAGENAME] LIKE '%7 of%'  THEN 7
	   WHEN P.[PAGENAME] LIKE '%8 of%'  THEN 8
	   WHEN P.[PAGENAME] LIKE '%9 of%'  THEN 9
	   WHEN P.[PAGENAME] LIKE '%Diagnosis%'  THEN 10
	   WHEN P.[PAGENAME] LIKE '%Comor/AE%'  THEN 11
	   WHEN P.[PAGENAME] LIKE '%Infection%'  THEN 12
	   WHEN P.[PAGENAME] LIKE '%Clinical Assessments%'  THEN 13
	   WHEN P.[PAGENAME] LIKE '%Other Case Details%'  THEN 14
	   WHEN P.[PAGENAME] LIKE '%PsA-SpA Medications%'  THEN 15
	   WHEN P.[PAGENAME] LIKE '%Demography%'  THEN 16
	   WHEN P.[PAGENAME] LIKE '%PROs'  THEN 17
	   WHEN P.[PAGENAME] LIKE '%PROs-PsA%'  THEN 18
	   WHEN P.[PAGENAME] LIKE '%PROs-SpA/AS%'  THEN 19
	   --WHEN P.[PAGENAME] LIKE '%Lab%'  THEN 20
	   ELSE 99
	   END AS [FormOrder]
      ,P.[REVNUM]
      ,P.[SUBID]
      ,P.[SUBNUM] AS [SubjectID]
      ,P.[VISITID]
      ,P.[VISITSEQ]
	  ,V.[VISITDATE]
      ,P.[PAGEID]
      ,P.[PAGESEQ]
      ,P.[STATUSID]
      ,P.[DELETED]
      ,P.[REVISION]
      ,P.[PAGELMBY]
      ,P.[PAGELMDT]
      ,P.[DATALMBY]
      ,P.[DATALMDT]
      ,P.[REASON]
      ,P.[ORPHANED]
      ,P.[ORPHANEDINFO] -- SELECT *
  FROM [MERGE_SPA].[staging].[DAT_PAGS] P
  LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON P.[vID] = V.[vID]
  WHERE P.[STATUSID] = 0
  AND P.[PAGENAME] NOT LIKE '%1.2%'
  AND P.[PAGENAME] NOT LIKE '%Lab%'
	) D

--SELECT * FROM [MERGE_SPA].[dbo].[DAT_PAGS] WHERE [SUBNUM] = '3100290381'
--Get list of Incomplete visits based on query for V1 of DE Completion report


IF OBJECT_ID('tempdb..#Incomplete') IS NOT NULL BEGIN DROP TABLE #Incomplete END

SELECT * 
INTO #Incomplete
FROM 
(

SELECT
      evh.CorronaRegistryID,
	  evh.SourceVisitID AS [vID],
      evh.SiteID,
      evh.[SubjectID],
      evh.[VisitDate],
      evh.[VisitSEQ],
      CASE WHEN evt.[VisitType]= 'FollowUp' THEN 'Follow Up'
	  ELSE evt.[VisitType]
	  END AS VisitType,
      CASE WHEN ers.[EDCResponseStatus]='InComplete' THEN 'Incomplete'
	  WHEN ers.[EDCResponseStatus]='NoData' THEN 'No data'
	  ELSE ers.[EDCResponseStatus]
	  END AS EDCResponseStatus --SELECT *
FROM [CorronaDB_Load].[dbo].[EDCVisitHeader] evh
JOIN [CorronaDB_Load].[dbo].[EDCResponseStatus] ers
on ers.EDCResponseStatusID = evh.EDCResponseStatusID
JOIN [CorronaDB_Load].[dbo].[EDCVisitType] evt
on evt.VisitTypeID = evh.VisitTypeID
where evt.[VisitTypeID] in (
              2 --Enrollment 
             ,3 --FollowUp 
             --,4 --TAE 
             --,5 --Pregnancy 
             ,7 --Exit 
       )            
AND ers.[EDCResponseStatusID] IN (
			 1 -- Signed
             ,2 -- NoData
             ,3 -- InComplete
             ,4 ) -- Monitored*
AND ISNULL(evh.[VisitDate], '')<>''
AND CorronaRegistryID=3  ---PSA is RegistryID 3
AND evh.SiteID NOT IN (99997, 99998, 99999)   
AND evh.[VisitDate]>'2017-04-01'
) L

--Determine List of visits that have been confirmed incomplete in the EDC

IF OBJECT_ID('tempdb..#ConfirmedIncomplete') IS NOT NULL BEGIN DROP TABLE #ConfirmedIncomplete END

SELECT * 
INTO #ConfirmedIncomplete
FROM 
(
SELECT  [vID]
	   ,[SUBNUM] AS [SubjectID]
FROM [MERGE_SPA].[staging].[VS_01]
WHERE [CONFIRMED_INCOMPLETE] IS NOT NULL
) W


INSERT INTO [Reporting].[PSA400].[t_op_DataEntryCompletion]

SELECT CAST([vID] AS bigint) AS [VisitID]
	  ,CAST(I.[SiteID] AS int) AS [SiteID]
	  ,SS.SiteStatus
	  ,CAST([SubjectID] AS bigint) AS [SubjectID]
	  ,[VisitType] AS [VisitType]
	  ,CAST([VisitSEQ] AS int) AS [VisitSequence]
	  ,CAST([VisitDate] AS date) AS [VisitDate]
	  ,CASE 
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, '')) IS NULL 
	   THEN 'Complete'
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Provider Enrollment (1 of 9) V2.0, Provider Enrollment (2 of 9) V2.0, Provider Enrollment (3 of 9) V2.0, Provider Enrollment (4 of 9) V2.0, Provider Enrollment (5 of 9) V2.0, Provider Enrollment (6 of 9) V2.0, Provider Enrollment (7 of 9) V2.0, Provider Enrollment (8 of 9) V2.0, Provider Enrollment (9 of 9) V2.0'
	   THEN 'All' 
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Provider Follow-up (1 of 9) V2.0, Provider Follow-up (2 of 9) V2.0, Provider Follow-up (3 of 9) V2.0, Provider Follow-up (4 of 9) V2.0, Provider Follow-up (5 of 9) V2.0, Provider Follow-up (6 of 9) V2.0, Provider Follow-up (7 of 9) V2.0, Provider Follow-up (8 of 9) V2.0, Provider Follow-up (9 of 9) V2.0'
	   THEN 'All'
	   --WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%' OR [PAGENAME] LIKE '%Lab%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   --= 'Provider Enrollment (1 of 9) V2.0, Provider Enrollment (2 of 9) V2.0, Provider Enrollment (3 of 9) V2.0, Provider Enrollment (4 of 9) V2.0, Provider Enrollment (5 of 9) V2.0, Provider Enrollment (6 of 9) V2.0, Provider Enrollment (7 of 9) V2.0, Provider Enrollment (8 of 9) V2.0, Provider Enrollment (9 of 9) V2.0, Enrollment Lab (1 of 3) V2.0, Enrollment Lab (2 of 3) V2.0, Enrollment Lab (3 of 3) V2.0'
	   --THEN 'All' 
	   --WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%' OR [PAGENAME] LIKE '%Lab%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   --= 'Provider Follow-up (1 of 9) V2.0, Provider Follow-up (2 of 9) V2.0, Provider Follow-up (3 of 9) V2.0, Provider Follow-up (4 of 9) V2.0, Provider Follow-up (5 of 9) V2.0, Provider Follow-up (6 of 9) V2.0, Provider Follow-up (7 of 9) V2.0, Provider Follow-up (8 of 9) V2.0, Provider Follow-up (9 of 9) V2.0, Follow-up Lab (1 of 3) V2.0, Follow-up Lab (2 of 3) V2.0, Follow-up Lab (3 of 3) V2.0'
	   --THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'PROVIDER Diagnosis, PROVIDER Comor/AE, PROVIDER Infection/Other, PROVIDER Clinical Assessments, PROVIDER Other Case Details, PROVIDER PsA-SpA Medications'
	   THEN 'All' 
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'PROVIDER Diagnosis, PROVIDER MedHx-Comor/AE, PROVIDER MedHx-Infection/Other, PROVIDER Clinical Assessments, PROVIDER Other Case Details, PROVIDER PsA-SpA Medications'
	   THEN 'All' 
	   --WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%' OR [PAGENAME] LIKE '%Lab%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   --= 'PROVIDER Diagnosis, PROVIDER Comor/AE, PROVIDER Infection/Other, PROVIDER Clinical Assessments, PROVIDER Other Case Details, PROVIDER PsA-SpA Medications, PROVIDER Lab-Imaging'
	   --THEN 'All'
	   --WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%' OR [PAGENAME] LIKE '%Lab%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   --= 'PROVIDER Diagnosis, PROVIDER MedHx-Comor/AE, PROVIDER MedHx-Infection/Other, PROVIDER Clinical Assessments, PROVIDER Other Case Details, PROVIDER PsA-SpA Medications, PROVIDER Lab-Imaging'
	   --THEN 'All' 
	   ELSE 
	   LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Provider%' OR [PAGENAME] LIKE '%Visit%' OR [PAGENAME] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   END 
	   AS [IncompleteMDForms]
	  ,CASE 
	   WHEN [VisitType] = 'Exit' THEN NULL
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Subject%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, '')) IS NULL 
	   THEN 'Complete'
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Subject%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Subject Enrollment (1 of 9) V2.0, Subject Enrollment (2 of 9) V2.0, Subject Enrollment (3 of 9) V2.0, Subject Enrollment (4 of 9) V2.0, Subject Enrollment (5 of 9) V2.0, Subject Enrollment (6 of 9) V2.0, Subject Enrollment (7 of 9) V2.0, Subject Enrollment (8 of 9) V2.0, Subject Enrollment (9 of 9) V2.0'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Subject%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Subject Follow-up (1 of 8) V2.0, Subject Follow-up (2 of 8) V2.0, Subject Follow-up (3 of 8) V2.0, Subject Follow-up (4 of 8) V2.0, Subject Follow-up (5 of 8) V2.0, Subject Follow-up (6 of 8) V2.0, Subject Follow-up (7 of 8) V2.0, Subject Follow-up (8 of 8) V2.0'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Subject%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'SUBJECT Demography-Med Hx, SUBJECT PROs, SUBJECT PROs-PsA, SUBJECT PROs-SpA/AS'
	   THEN 'All' 
	   ELSE 
	   LTRIM(STUFF((SELECT ', ' + [PAGENAME] FROM #NoDataForms NDF WHERE NDF.[vID] = I.[vID] AND ([PAGENAME] LIKE '%Subject%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   END 
	   AS [IncompleteSUForms]
FROM #INCOMPLETE I
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=I.SiteID
WHERE I.[vID] NOT IN (SELECT [vID] FROM #ConfirmedIncomplete)
---ORDER BY [SiteNo], [Subject_Id], [VisitDate], [Instance]

END 





GO
