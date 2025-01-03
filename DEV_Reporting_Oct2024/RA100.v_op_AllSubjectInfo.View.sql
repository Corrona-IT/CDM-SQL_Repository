USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_AllSubjectInfo]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author: Kevin Soe
-- Create date: 12-May-2021
-- Description:	View of all subject in TM for RA with key demographic variables. 
-- To be compared against the subject info file from Biostats to resolve discrepancies.
-- =============================================

CREATE VIEW [RA100].[v_op_AllSubjectInfo] AS

/* All subjects view has TM Immutable ID. 
   PT Enrollment Page 1 has Sex.
   MD Enrollment Page 1 has RA Onset Year.
   Had to create my own Last Visits table that needs to be set up to run on report execution or as a daily process
   because the Visit Tracker does not show last visits for terminally exited subjects. 
   Had to create my own last exit CTEs because some patients with only exit visits were missing from subject log. 
   Will have to hide last exit values that show up for subjects that have a follow-up visit date after the last exit date within SSRS*/

--IF OBJECT_ID('tempdb.dbo.#TotalVisits') IS NOT NULL BEGIN DROP TABLE #TotalVisits END
WITH TotalVisits AS
(
SELECT
       [SiteID]
	  ,CAST([SubjectID] AS nvarchar) AS [SubjectID]
      ,COUNT([SubjectID]) AS [TotalVisits]

--SELECT * FROM #TotalVisits
--INTO #TotalVisits
FROM [Reporting].[RA100].[v_op_VisitLog]
WHERE [SiteID] NOT LIKE '99%'
GROUP BY [SiteID], [SubjectID]
),

--IF OBJECT_ID('tempdb.dbo.#TotalTAEs') IS NOT NULL BEGIN DROP TABLE #TotalTAEs END
TotalTAEs AS
(
SELECT
       [SiteID]
	  ,CAST([SubjectID] AS nvarchar) AS [SubjectID]
      ,COUNT([SubjectID]) AS [TotalVisits]

--SELECT * FROM #TotalTAEs
--INTO #TotalTAEs
FROM [RA100].[v_pv_TAEQCListing]
WHERE [SiteID] NOT LIKE '99%'
GROUP BY [SiteID], [SubjectID]
),

BSEnrollDates AS 
(
SELECT	 
	 site_id
	,optional_id
	,CAST([Enrollment_date] AS date) AS [enrolldate]
FROM [RA100].[t_op_BiostatsSubjectInfo]
),

OrderedExits AS 
(
SELECT 
	   ROW_NUMBER() OVER(PARTITION BY  SiteID, SubjectID ORDER BY VisitDate DESC) as ROWNUM
	  ,[VisitID]
      ,[SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[VisitType]
      ,[ProviderID]
      ,[VisitSequence]
      ,[CalcVisitSequence]
      ,[Registry]
  FROM [Reporting].[RA100].[v_op_VisitLog]
  WHERE [VisitType] = 'Exit'
),

TerminalExits AS
(
SELECT 
	   [SiteID]
      ,[SubjectID]
      ,[VisitDate] AS [ExitDate]
      ,[VisitType]
FROM OrderedExits
WHERE [ROWNUM] = 1
)

SELECT DISTINCT
   PT.[SiteID] AS [SiteID]
  ,RS.[currentStatus] AS [SiteStatus]
  ,CAST(PT.[SubjectID] AS bigint) AS [SubjectID]
  ,BS.[optional_id] AS [PatientID]
  ,PT.[PatientId] AS [TrialMasterID]
  ,SL.[VisitDate]
  ,SL.[VisitType]
  ,BE.[enrolldate] AS [BSEnrollDate]
  ,CASE
	WHEN SL.[VisitType] = 'Enrollment' AND SL.[VisitDate] = BE.[enrolldate] THEN 'No'
	WHEN SL.[VisitDate] IS NULL AND BE.[enrolldate] IS NULL THEN 'Missing'
	WHEN SL.[VisitDate] IS NULL AND BE.[enrolldate] IS NOT NULL THEN 'No'
	WHEN SL.[VisitType] = 'Follow-up' THEN 'No'
	WHEN SL.[VisitDate] IS NOT NULL AND SL.[VisitType] = 'Enrollment' AND BE.[enrolldate] IS NULL THEN 'No'
	ELSE 'Yes'
   END AS [EnrollDateDiscrepancy]
  ,SL.[YOB] AS [TMYOB]
  ,BS.[Year_of_birth] AS [BSYOB]
  ,CASE
	WHEN SL.[YOB] = BS.[Year_of_birth] THEN 'No'
	WHEN SL.[YOB] IS NULL AND BS.[Year_of_birth] IS NULL THEN 'Missing'
	WHEN SL.[YOB] IS NULL AND BS.[Year_of_birth] IS NOT NULL THEN 'No'
	WHEN SL.[YOB] IS NOT NULL AND BS.[Year_of_birth] IS NULL THEN 'No'
	ELSE 'Yes'
   END AS [YOBDiscrepancy]
  ,PQ.[PEQ1_PEQ1] AS [TMSex]
  ,BS.[Gender_sex] AS [BSSex]
  ,CASE
	WHEN PQ.[PEQ1_PEQ1] = BS.[Gender_sex] THEN 'No'
	WHEN PQ.[PEQ1_PEQ1] IS NULL AND BS.[Gender_sex] IS NULL THEN 'Missing'
	WHEN PQ.[PEQ1_PEQ1] IS NULL AND BS.[Gender_sex] IS NOT NULL THEN 'No'
	WHEN PQ.[PEQ1_PEQ1] IS NOT NULL AND BS.[Gender_sex] IS NULL THEN 'No'
	WHEN PQ.[PEQ1_PEQ1] NOT IN ('Male', 'Female') AND BS.[Gender_sex] IS NOT NULL THEN 'No'
	ELSE 'Yes'
   END AS [SexDiscrepancy]
  ,MD.[PHE3_RASTYR] AS [TMOnsetYear]
  ,BS.[RA_onset_year] AS [BSOnsetYear]
  ,CASE
	WHEN MD.[PHE3_RASTYR] = BS.[RA_onset_year] THEN 'No'
	WHEN MD.[PHE3_RASTYR] IS NULL AND BS.[RA_onset_year] IS NULL THEN 'Missing'
	WHEN MD.[PHE3_RASTYR] IS NULL AND BS.[RA_onset_year] IS NOT NULL THEN 'No'
	WHEN MD.[PHE3_RASTYR] IS NOT NULL AND BS.[RA_onset_year] IS  NULL THEN 'No'
	WHEN ISNUMERIC(MD.[PHE3_RASTYR]) = 0  AND BS.[RA_onset_year] IS NOT NULL THEN 'No'
	ELSE 'Yes'
   END AS [OnsetYearDiscrepancy]
  --,VT.[LastVisitDate] 
  ,LV.[LastVisitDate]
  --,SL.[ExitDate]
  ,TE.[ExitDate]
  ,NULL AS [Imported]
  ,CASE 
	WHEN TV.[TotalVisits] > 0 OR TT.[TotalVisits] > 0 THEN 'Yes'
	ELSE 'No'
   END AS [RecordsInTM]
  ,CASE
	WHEN PT.[SubjectID] = BS.[optional_id] THEN 'Yes'
	ELSE 'No'
	END AS [InLegacy]
  ,NULL AS [ImportEligibility]
FROM [RA100].[v_op_AllSubjects] PT
LEFT JOIN (SELECT [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)') RS ON PT.[SiteID] = RS.[siteNumber]
LEFT JOIN [RA100].[v_op_SubjectLog] SL ON PT.[SubjectID] = SL.[SubjectID] AND PT.[SiteID] = SL.[SiteID]
LEFT JOIN TerminalExits TE ON PT.[SubjectID] = TE.[SubjectID] AND PT.[SiteID] = TE.[SiteID] --SELECT * FROM [RA100].[t_op_LastVisits]
LEFT JOIN [RA100].[t_op_LastVisits] LV ON PT.[SubjectID] = LV.[SubjectID] AND PT.[SiteID] = LV.[SiteID]
--LEFT JOIN RA100.t_op_PatientVisitTracker VT ON PT.[SubjectID] = VT.[SubjectID] AND PT.[SiteID] = VT.[SiteID]
LEFT JOIN (SELECT [Site Object SiteNo], [Patient Object PatientNo], [PEQ1_PEQ1] FROM [OMNICOMM_RA100].[dbo].[PEQ1] WHERE ISNUMERIC([Patient Object PatientNo]) = 1) PQ ON PT.[SubjectID] = PQ.[Patient Object PatientNo]  AND PT.[SiteID] = PQ.[Site Object SiteNo]
LEFT JOIN (SELECT [Site Object SiteNo], [Patient Object PatientNo], [PHE3_RASTYR] FROM [OMNICOMM_RA100].[dbo].[PHEQ1] WHERE ISNUMERIC([Patient Object PatientNo]) = 1) MD ON PT.[SubjectID] = MD.[Patient Object PatientNo] AND PT.[SiteID] = MD.[Site Object SiteNo]
LEFT JOIN TotalVisits TV ON PT.[SubjectID] = TV.[SubjectID] AND PT.[SiteID] = TV.[SiteID]
LEFT JOIN TotalTAEs TT ON PT.[SubjectID] = TT.[SubjectID] AND PT.[SiteID] = TT.[SiteID]
LEFT JOIN [RA100].[t_op_BiostatsSubjectInfo] BS ON PT.[SubjectID] = BS.[optional_id] AND PT.[SiteID] = BS.[site_id]
LEFT JOIN BSEnrollDates BE ON PT.[SubjectID] = BE.[optional_id] AND PT.[SiteID] = BE.[site_id]
GO
