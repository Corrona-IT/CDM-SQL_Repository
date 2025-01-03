USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_SubjectInfo]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author: Kevin Soe
-- Create date: 12-May-2021
-- Description:	List of all subjects in TM for RA with key demographic (YOB, Sex, Onset Year) variables. 
-- To be compared against the subject info file from Biostats to resolve discrepancies.
---Data collected by ROM during their outreach efforts to obtain missing data will also be compared against for discrepancies.
-- =============================================
		 --SELECT * FROM [RA100].[t_op_SubjectInfo]
		 --DROP TABLE [RA100].[t_op_SubjectInfo]
			   --EXECUTE
CREATE PROCEDURE  [RA100].[usp_op_SubjectInfo] AS

/* All subjects view has TM Immutable ID. 
   PT Enrollment Page 1 has Sex.
   MD Enrollment Page 1 has RA Onset Year.
   Created Visits temp table because the Visit Tracker does not show last visits for terminally exited subjects. 
   Created last exit temp table because some patients with only exit visits were missing from subject log. 
   Will have to hide last exit values that show up for subjects that have a follow-up visit date after the last exit date within SSRS
   Created temp table to determine created date of subjects.
   Created a table for Biostats legacy data [Reporting].[RA100].[t_op_SubjectInfoBiostats]
   Created a table for missing data obtained by ROM [Reporting].[RA100].[t_op_SubjectInfoROMRetrievedData] *Removed on 10/18/2021-Confirmed not reliable to use since it cannot be recreated from source data*
   Created a table to record Imported Subjects [Reporting].[RA100].[t_op_RCCImportedSubjectInfo]
   Created a table for where resolved data will be stored [Reporting].[RA100].[t_op_SubjectInfoDiscrepancies]
   Created a table that lists all subjects designated to have a RA diagnosis in the Biostats dataset [Reporting].[RA100].[t_op_SubjectInfoBiostatsRAOnly]*/
   --SELECT * FROM [Reporting].[RA100].[t_op_SubjectInfoDiscrepancies]
/*
			 SELECT * FROM
CREATE TABLE [RA100].[t_op_SubjectInfo_]
(
	[SiteID] [int] NULL,
	[SiteStatus] [varchar](20) NULL,
	[SubjectID] [bigint] NULL,
	[SubIDL0s] [varchar](25) NULL,
	[TrialMasterID] [int] NOT NULL,
	[CreatedDate] [date] NULL,
	[VisitType] [varchar](250) NULL,
	[TMEnrollDate] [date] NULL,
	[BSEnrollDate] [date] NULL,
	[EnrollDateDiscrepancy] [varchar](250) NOT NULL,
	[RESEnrollDate] [date] NULL,
	[EnrollDate] [date] NULL,
	[TMYOB] [int] NULL,
	[BSYOB] [float] NULL,
	[YOBDiscrepancy] [varchar](7) NOT NULL,
	[RESYOB] [int] NULL,
	[YOB] [float] NULL,
	[TMSex] [nvarchar](1024) NULL,
	[BSSex] [nvarchar](255) NULL,
	[SexDiscrepancy] [varchar](7) NOT NULL,
	[RESSex] [nvarchar](25) NULL,
	[Sex] [nvarchar](1024) NULL,
	[TMOnsetYear] [nvarchar](1024) NULL,
	[BSOnsetYear] [nvarchar](255) NULL,
	[OnsetYearDiscrepancy] [varchar](7) NOT NULL,
	[RESOnsetYear] [int] NULL,
	[OnsetYear] [int] NULL,
	[TMDiagnosis] [varchar](2) NULL,
	[BSDiagnosis] [nvarchar](255) NULL,
	[DiagnosisDiscrepancy] [varchar](35) NOT NULL,
	[RESDiagnosis] [nvarchar](25) NULL,
	[Diagnosis] [nvarchar](25) NULL,
	[TMEthnicity] [varchar](255) NULL,
	[BSEthnicity] [nvarchar](255) NULL,
	[EthnicityDiscrepancy] [varchar](35) NOT NULL,
	[RESEthnicity] [nvarchar](25) NULL,
	[Ethnicity] [nvarchar](25) NULL,
	[LastVisitDate] [date] NULL,
	[ExitDate] [date] NULL,
	[MonthsSinceLastVisit] [decimal](8, 2) NULL,
	[SubjectStatus] [varchar](22) NULL,
	[Imported] [int] NULL,
	[RecordsInTM] [varchar](3) NOT NULL,
	[TotalFollowUps] [int] NULL,
	[TotalTAEs] [int] NULL,
	[InLegacy] [varchar](3) NOT NULL,
	[PTWDiscrepancies] [int] NULL,
	[FullyResolvedPTs] [int] NULL,
	[TotalDiscrepancies] [int] NULL,
	[TotalResolved] [int] NULL,
	[Discrepancies] [nvarchar](max) NULL,
	[EnrollDateDiscrepancyCount] [int] NULL,
	[YOBDiscrepancyCount] [int] NULL,
	[SexDiscrepancyCount] [int] NULL,
	[OnsetYearDiscrepancyCount] [int] NULL,
	[DiagnosisDiscrepancyCount] [int] NULL,
	[RESEnrollDateCount] [int] NULL,
	[RESYOBCount] [int] NULL,
	[RESSexCount] [int] NULL,
	[RESOnsetYearCount] [int] NULL,
	[RESDiagnosisCount] [int] NULL,
	[EligibleForImport] [int] NOT NULL
);
*/

/*
			 SELECT * FROM
CREATE TABLE [RA100].[t_op_SubjectInfoBiostats]
(
	[site_id] [int] NULL,
	[optional_id] [bigint] NULL,
	[TMImmutableID] [bigint] NULL,
	[Enrollment_date] [date] NULL,
	[Year_of_birth] [float] NULL,
	[Gender_sex] [nvarchar](255) NULL,
	[RA_onset_year] [nvarchar](255) NULL,
	[Diagnosis] [nvarchar](255) NULL,
	[optional_id_not_found] [bigint] NULL
);
INSERT INTO [RA100].[t_op_SubjectInfoBiostats]
SELECT * FROM [10.0.3.123].[Reporting].[RA100].[t_op_SubjectInfoBiostats]
*/

/*
			 SELECT * FROM
CREATE TABLE [RA100].[t_op_SubjectInfoDiscrepancies]
(	
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[TrialMasterID] [bigint] NULL,
	[TMEnrollDate] [date] NULL,
	[BSEnrollDate] [date] NULL,
	[EnrollDateDiscrepancy] [nvarchar](255) NULL,
	[RESEnrollDate] [date] NULL,
	[TMYOB] [int] NULL,
	[BSYOB] [int] NULL,
	[YOBDiscrepancy] [nvarchar](255) NULL,
	[RESYOB] [int] NULL,
	[TMSex] [nvarchar](255) NULL,
	[BSSex] [nvarchar](255) NULL,
	[SexDiscrepancy] [nvarchar](255) NULL,
	[RESSex] [nvarchar](255) NULL,
	[TMOnsetYear] [int] NULL,
	[BSOnsetYear] [int] NULL,
	[OnsetYearDiscrepancy] [nvarchar](255) NULL,
	[RESOnsetYear] [int] NULL,
	[TMDiagnosis] [nvarchar](255) NULL,
	[BSDiagnosis] [nvarchar](255) NULL,
	[DiagnosisDiscrepancy] [nvarchar](255) NULL,
	[RESDiagnosis] [nvarchar](255) NULL
) ;
INSERT INTO [RA100].[t_op_SubjectInfoDiscrepancies]
SELECT * FROM [10.0.3.123].[Reporting].[RA100].[t_op_SubjectInfoDiscrepancies]
*/

/*           SELECT * FROM
CREATE TABLE [RA100].[t_op_RCCImportedSubjectInfo](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[Imported] [int] NULL
)
INSERT INTO [RA100].[t_op_RCCImportedSubjectInfo]
SELECT * FROM [10.0.3.123].[Reporting].[RA100].[t_op_RCCImportedSubjectInfo]
*/

/*			 SELECT * FROM
CREATE TABLE [RA100].[t_op_SubjectInfoROMRetrievedData](
	[site_id] [int] NOT NULL,
	[optional_id] [bigint] NOT NULL,
	[md_cod] [int] NOT NULL,
	[FirstFuVisitDate] [date] NULL,
	[Need] [nvarchar](100) NULL,
	[ROMEnrollDate] [date] NULL,
	[Notes] [nvarchar](100) NULL,
	[ROMEnrollDateNotes] [nvarchar](100) NULL,
	[ROMSex] [nvarchar](25) NULL,
	[ROMYOB] [int] NULL,
	[2ndRequest] [date] NULL,
	[VanessasCall] [date] NULL,
	[3rdRequest] [nvarchar](100) NULL
) 
INSERT INTO [Reporting].[RA100].[t_op_SubjectInfoROMRetrievedData]
SELECT * FROM [10.0.3.123].[Reporting].[RA100].[t_op_SubjectInfoROMRetrievedData]
*/

/*			 SELECT * FROM
CREATE TABLE [RA100].[t_op_SubjectInfoBiostatsRAOnly](
	[site_id] [int] NULL,
	[optional_id] [bigint] NULL,
	[TMImmutableID] [bigint] NULL,
	[Enrollment_date] [date] NULL,
	[Year_of_birth] [float] NULL,
	[Gender_sex] [nvarchar](255) NULL,
	[RA_onset_year] [nvarchar](255) NULL,
	[exit_date] [date] NULL,
	[Diagnosis] [nvarchar](255) NULL,
	[optional_id_not_found] [bigint] NULL,
	[first_visit_date] [date] NULL,
	[last_visit_date] [date] NULL
) 
INSERT INTO [Reporting].[RA100].[t_op_SubjectInfoBiostatsRAOnly]
SELECT * FROM [10.0.3.123].[Reporting].[RA100].[t_op_SubjectInfoBiostatsRAOnly]
*/

TRUNCATE TABLE [Reporting].[RA100].[t_op_SubjectInfo];

--Calculate total visit count for each subject

IF OBJECT_ID('tempdb.dbo.#TotalVisits') IS NOT NULL BEGIN DROP TABLE #TotalVisits END
--WITH TotalVisits AS
--(
SELECT
       [SiteID]
	  ,CAST([SubjectID] AS nvarchar) AS [SubjectID]
      ,COUNT([SubjectID]) AS [TotalVisits]

--SELECT * FROM #TotalVisits
INTO #TotalVisits
FROM [Reporting].[RA100].[v_op_VisitLog]
WHERE [SiteID] NOT LIKE '99%'
GROUP BY [SiteID], [SubjectID]
--),

--Calculate total follow-up count for each subject

IF OBJECT_ID('tempdb.dbo.#TotalFollowUps') IS NOT NULL BEGIN DROP TABLE #TotalFollowUps END
--TotalFollowUps AS 
--(
SELECT 
       [SiteID]
      ,[SubjectID]
      ,COUNT([VisitDate]) AS [TotalFollowUps]


  --SELECT * FROM #TotalFollowUps
  INTO #TotalFollowUps --SELECT *
  FROM [Reporting].[RA100].[v_op_VisitLog]
  WHERE [VisitType] = 'Follow-Up'
  GROUP BY [SiteID], [SubjectID]
--),

--Calculate total TAE count for each subject regardless of whether it is a confirmed event or not

IF OBJECT_ID('tempdb.dbo.#TotalTAEs') IS NOT NULL BEGIN DROP TABLE #TotalTAEs END
--TotalTAEs AS
--(
SELECT
       [SiteID]
	  ,CAST([SubjectID] AS nvarchar) AS [SubjectID]
      ,COUNT([SubjectID]) AS [TotalTAEs]

--SELECT * FROM #TotalTAEs
INTO #TotalTAEs --SELECT *
FROM [RA100].[v_pv_TAEQCListing]
WHERE [SiteID] NOT LIKE '99%'
--AND [ConfirmedEvent] = 'Yes'
GROUP BY [SiteID], [SubjectID]
--),

--Create table of subjects from Biostats legacy dataset with the data demographic, diagnosis, and enrollment data that will be included in the Subject Info File

IF OBJECT_ID('tempdb.dbo.#BSSubjectInfo') IS NOT NULL BEGIN DROP TABLE #BSSubjectInfo END
--BSSubjectInfo AS 
--(
SELECT	 
	 site_id
	,optional_id
	,CASE WHEN [Enrollment_date] = '' THEN NULL ELSE CAST([Enrollment_date] AS date) END AS [Enrollment_date]
	,CASE WHEN [Year_of_birth] = '' THEN NULL ELSE [Year_of_birth] END AS [Year_of_birth]
	,CASE WHEN [Gender_sex] = '' THEN NULL ELSE [Gender_sex] END AS [Gender_sex]
	,CASE WHEN [RA_onset_year] = '' THEN NULL ELSE [RA_onset_year] END AS [RA_onset_year]
	,CASE WHEN [Diagnosis] = '' THEN NULl WHEN [Enrollment_date] >= '03-25-2015' AND [DIAGNOSIS] IS NULL 
	 THEN 'RA' ELSE [Diagnosis] END AS [BSDiagnosis]

--SELECT * FROM #BSSubjectInfo
INTO #BSSubjectInfo --SELECT * 
FROM [RA100].[t_op_SubjectInfoBiostats]
--),

--Create ordered visits (EN & FU Only) so last visit dates for each patient can be determined

IF OBJECT_ID('tempdb.dbo.#OrderedVisits') IS NOT NULL BEGIN DROP TABLE #OrderedVisits END

SELECT 
	 ROW_NUMBER() OVER(PARTITION BY  SiteID, SubjectID ORDER BY VisitDate DESC) as [ROWNUM]
	,[SiteID]
	,[SubjectID]
	,[VisitType]
	,[VisitDate]
--SELECT * FROM #OrderedVisits
INTO #OrderedVisits
FROM [Reporting].[RA100].[v_op_VisitLog]
WHERE [VisitType] <> 'Exit'

--Determine last visit date for each subject

IF OBJECT_ID('tempdb.dbo.#LastVisits') IS NOT NULL BEGIN DROP TABLE #LastVisits END

SELECT 
	 [ROWNUM]
	,[SiteID]
	,[SubjectID]
	,[VisitType]
	,[VisitDate] AS [LastVisitDate]
--SELECT * FROM #LastVisits
INTO #LastVisits
FROM #OrderedVisits
WHERE [ROWNUM] = 1

IF OBJECT_ID('tempdb.dbo.#OrderedExits') IS NOT NULL BEGIN DROP TABLE #OrderedExits END
--OrderedExits AS 
--(
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

  --SELECT * FROM #OrderedExits
  INTO #OrderedExits
  FROM [Reporting].[RA100].[v_op_VisitLog]
  --WHERE [VisitType] = 'Exit'
--),

IF OBJECT_ID('tempdb.dbo.#TerminalExits') IS NOT NULL BEGIN DROP TABLE #TerminalExits END
--TerminalExits AS
--(
SELECT 
	   [SiteID]
      ,[SubjectID]
      ,[VisitDate] AS [ExitDate]
      ,[VisitType]

--SELECT * FROM #TerminalExits
INTO #TerminalExits
FROM #OrderedExits
WHERE [ROWNUM] = 1
AND [VisitType] = 'Exit'
--)

IF OBJECT_ID('tempdb.dbo.#EnrollDates') IS NOT NULL BEGIN DROP TABLE #EnrollDates END
--EnrollDates AS
--(
SELECT 
	   [SiteID]
      ,[SubjectID]
      ,[VisitDate] AS [EnrollmentDate]
      ,[VisitType]
	  ,[YOB]

--SELECT * FROM #EnrollDates
INTO #EnrollDates
FROM [RA100].[v_op_SubjectLog]
WHERE [VisitType] = 'Enrollment'
--)

IF OBJECT_ID('tempdb.dbo.#PTCreateDate') IS NOT NULL BEGIN DROP TABLE #PTCreateDate END

SELECT * 
--SELECT * FROM #PTCreateDate
INTO #PTCreateDate
FROM  (
		SELECT *
			  ,ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY t1.[CreatedDate] asc) as SignOrder
		FROM (
				SELECT a.AuditId
				      ,CAST(a.[StateChangeDateTime] AS DATE) AS [CreatedDate]
					  ,a.[TrlObjectFormId]
					  ,a.[TrlObjectTypeId]
					  ,a.[TrlObjectStateBitMask]
					  ,a.[TrlObjectId]
					  ,a.[TrlObjectPatientId]
					  ,p.[PatientId]
					  ,a.[TrlObjectVisitId]
				FROM --		select top 100 * from
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits] a
				LEFT JOIN 
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Patient Information] p
				ON
						a.[TrlObjectPatientId] = p.[TrlObjectPatientId] 
				WHERE a.[TrlObjectFormId] is not null
					AND a.[TrlObjectTypeId] = 11   
					AND ((ISNULL(a.[TrlObjectStateBitmask], 0) & (8|4|2)) <> 0)
					--AND DATEDIFF(DD, a.[StateChangeDateTime], GetDate()) <= 730.0
			) t1
		 ) t2 WHERE SignOrder = 1		


IF OBJECT_ID('tempdb.dbo.#SubjectInfoCalc') IS NOT NULL BEGIN DROP TABLE #SubjectInfoCalc END

SELECT DISTINCT
   PT.[SiteID] AS [SiteID]
  ,RS.[currentStatus] AS [SiteStatus]
  ,CAST(PT.[SubjectID] AS bigint) AS [SubjectID]
  ,PT.[SubIDL0s]
  --,BS.[optional_id] AS [PatientID]
  ,PT.[PatientId] AS [TrialMasterID]
  ,CD.[CreatedDate] 
  ,ED.[VisitType]
  ,ED.[EnrollmentDate] AS [TMEnrollDate]
  ,BS.[Enrollment_date] AS [BSEnrollDate]
  --,RD.[ROMEnrollDate]
  ,CASE
	WHEN ED.[EnrollmentDate] = BS.[Enrollment_date] /*AND ED.[EnrollmentDate] >= '01-01-2000' AND BS.[Enrollment_date] >= '01-01-2000'*/ THEN 'No'
	--WHEN ED.[EnrollmentDate] <> BS.[Enrollment_date] AND ED.[EnrollmentDate] < '03-25-2013' THEN 'Yes + TM Enroll Date is Pre-TM'
	--WHEN ED.[EnrollmentDate] < '03-25-2013' THEN 'TM Enroll Date is Pre-TM'
	WHEN ISNULL(ED.[EnrollmentDate],'')='' AND ISNULL(BS.[Enrollment_date],'')='' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] = '' AND BS.[Enrollment_date] = '' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] = '' AND BS.[Enrollment_date] IS NULL THEN 'Missing'
	--WHEN ED.[EnrollmentDate] IS NULL AND BS.[Enrollment_date] = '' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] < '01-01-2000' AND BS.[Enrollment_date] < '01-01-2000'  THEN 'Missing'
	--WHEN ED.[EnrollmentDate] < '01-01-2000' AND BS.[Enrollment_date] IS NULL  THEN 'Missing'
	--WHEN ED.[EnrollmentDate] < '01-01-2000' AND BS.[Enrollment_date] = '' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] < '01-01-2000' AND BS.[Enrollment_date] = '' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] < '01-01-2000' AND BS.[Enrollment_date] IS NULL THEN 'Missing'
	--WHEN ED.[EnrollmentDate] IS NULL AND BS.[Enrollment_date] < '01-01-2000' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] = '' AND BS.[Enrollment_date] < '01-01-2000' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] = '' AND BS.[Enrollment_date] < '01-01-2000' THEN 'Missing'
	--WHEN ED.[EnrollmentDate] IS NULL AND BS.[Enrollment_date] < '01-01-2000' THEN 'Missing'
	WHEN ED.[EnrollmentDate] IS NULL AND BS.[Enrollment_date] IS NOT NULL THEN 'No'
	WHEN ED.[EnrollmentDate] IS NOT NULL AND BS.[Enrollment_date] IS NULL THEN 'No'
	ELSE 'Yes'
   END AS [EnrollDateDiscrepancy]
  --,CASE
	--WHEN ED.[EnrollmentDate] < '03-25-2013' THEN 'Yes'
	--ELSE 'No'
  -- END AS [TMEnrollDateIsPreTM]
  ,SD.[RESEnrollDate]
  ,CASE
	WHEN ED.[EnrollmentDate] = BS.[Enrollment_date] AND ED.[EnrollmentDate] >= '01-01-1999' AND BS.[Enrollment_date] >= '01-01-1999' THEN ED.[EnrollmentDate]
	WHEN ED.[EnrollmentDate] IS NULL AND BS.[Enrollment_date] IS NOT NULL AND SD.[RESEnrollDate] IS NULL THEN BS.[Enrollment_date]
	WHEN ED.[EnrollmentDate] IS NOT NULL AND BS.[Enrollment_date] IS NULL AND SD.[RESEnrollDate] IS NULL THEN ED.[EnrollmentDate]
	WHEN SD.[RESEnrollDate] IS NOT NULL THEN SD.[RESEnrollDate]
	ELSE NULL
	END AS [EnrollDate]
  ,ED.[YOB] AS [TMYOB]
  ,BS.[Year_of_birth] AS [BSYOB]
  --,RD.[ROMYOB] 
  ,CASE
	WHEN ED.[YOB] = BS.[Year_of_birth] AND ISNUMERIC(ED.[YOB]) = 1 AND ISNUMERIC(BS.[Year_of_birth]) = 1 THEN 'No'
	WHEN ISNULL(ED.[YOB],'')='' AND ISNULL(BS.[Year_of_birth],'')='' THEN 'Missing'
	--WHEN ED.[YOB] = '' AND BS.[Year_of_birth] = '' THEN 'Missing'
	--WHEN ED.[YOB] = '' AND BS.[Year_of_birth] IS NULL THEN 'Missing'
	--WHEN ED.[YOB] IS NULL AND BS.[Year_of_birth] = '' THEN 'Missing'
	WHEN ED.[YOB] IS NULL AND ISNUMERIC(BS.[Year_of_birth]) = 1 THEN 'No'
	WHEN ISNUMERIC(ED.[YOB]) = 1 AND BS.[Year_of_birth] IS NULL THEN 'No'
	ELSE 'Yes'
   END AS [YOBDiscrepancy]
  ,SD.[RESYOB]
  ,CASE
	WHEN ED.[YOB] = BS.[Year_of_birth] AND ISNUMERIC(ED.[YOB]) = 1 AND ISNUMERIC(BS.[Year_of_birth]) = 1 AND SD.[RESYOB] IS NULL THEN ED.[YOB]
	WHEN ISNUMERIC(ED.[YOB]) = 1 AND BS.[Year_of_birth] IS NULL AND SD.[RESYOB] IS NULL THEN ED.[YOB]
	WHEN ED.[YOB] IS NULL AND ISNUMERIC(BS.[Year_of_birth]) = 1 AND SD.[RESYOB] IS NULL THEN BS.[Year_of_birth]
	WHEN SD.[RESYOB] IS NOT NULL THEN SD.[RESYOB]
	ELSE NULL
   END AS [YOB]
  ,PQ.[PEQ1_PEQ1] AS [TMSex]
  ,BS.[Gender_sex] AS [BSSex]
  --,RD.[ROMSex]
  ,CASE
	WHEN PQ.[PEQ1_PEQ1] IN ('Male', 'Female') AND  BS.[Gender_sex] IN ('Male', 'Female') AND PQ.[PEQ1_PEQ1] = BS.[Gender_sex] THEN 'No'
	WHEN ISNULL(PQ.[PEQ1_PEQ1],'')='' AND ISNULL(BS.[Gender_sex],'')='' THEN 'Missing'
	--WHEN PQ.[PEQ1_PEQ1] = '' AND BS.[Gender_sex] = '' THEN 'Missing'
	--WHEN PQ.[PEQ1_PEQ1] = '' AND BS.[Gender_sex] IS NULL THEN 'Missing'
	--WHEN PQ.[PEQ1_PEQ1] IS NULL AND BS.[Gender_sex] = '' THEN 'Missing'
	WHEN PQ.[PEQ1_PEQ1] IN ('Male', 'Female') AND (BS.[Gender_sex] IS NULL OR BS.[Gender_sex] = '') THEN 'No'
	WHEN (PQ.[PEQ1_PEQ1] IS NULL OR PQ.[PEQ1_PEQ1] ='') AND BS.[Gender_sex] IN ('Male', 'Female') THEN 'No'
	WHEN PQ.[PEQ1_PEQ1] NOT IN ('Male', 'Female') AND BS.[Gender_sex] IN ('Male', 'Female') THEN 'No'
	WHEN PQ.[PEQ1_PEQ1] IN ('Male', 'Female') AND BS.[Gender_sex] NOT IN ('Male', 'Female') THEN 'No'
	ELSE 'Yes'
   END AS [SexDiscrepancy]
  ,SD.[RESSex]
  ,CASE
	WHEN PQ.[PEQ1_PEQ1] IN ('Male', 'Female') AND  BS.[Gender_sex] IN ('Male', 'Female') AND PQ.[PEQ1_PEQ1] = BS.[Gender_sex] AND SD.[RESSex] IS NULL THEN PQ.[PEQ1_PEQ1]
	WHEN (PQ.[PEQ1_PEQ1] IS NULL OR PQ.[PEQ1_PEQ1] ='') AND BS.[Gender_sex] IN ('Male', 'Female') AND SD.[RESSex] IS NULL THEN BS.[Gender_sex]
	WHEN PQ.[PEQ1_PEQ1] NOT IN ('Male', 'Female') AND BS.[Gender_sex] IN ('Male', 'Female') AND SD.[RESSex] IS NULL THEN BS.[Gender_sex]
	WHEN PQ.[PEQ1_PEQ1] IN ('Male', 'Female') AND (BS.[Gender_sex] IS NULL OR BS.[Gender_sex] = '') AND SD.[RESSex] IS NULL THEN PQ.[PEQ1_PEQ1]
	WHEN PQ.[PEQ1_PEQ1] IN ('Male', 'Female') AND BS.[Gender_sex] NOT IN ('Male', 'Female') AND SD.[RESSex] IS NULL THEN PQ.[PEQ1_PEQ1]
	WHEN SD.[RESSex] IS NOT NULL THEN SD.[RESSex]
	ELSE NULL
   END AS [Sex]
  ,CASE WHEN MD.[PHE3_RASTYR] = 0 THEN NULL ELSE MD.[PHE3_RASTYR] END AS [TMOnsetYear]
  ,BS.[RA_onset_year] AS [BSOnsetYear]
  ,CASE
	WHEN MD.[PHE3_RASTYR] = BS.[RA_onset_year] THEN 'No'
	WHEN ISNULL(MD.[PHE3_RASTYR],'')='' AND ISNULL(BS.[RA_onset_year],'')='' THEN 'Missing'
	--WHEN MD.[PHE3_RASTYR] = '' AND BS.[RA_onset_year] = '' THEN 'Missing'
	--WHEN MD.[PHE3_RASTYR] = '' AND BS.[RA_onset_year] IS NULL THEN 'Missing'
	--WHEN MD.[PHE3_RASTYR] IS NULL AND BS.[RA_onset_year] = '' THEN 'Missing'
	WHEN MD.[PHE3_RASTYR] IS NULL AND BS.[RA_onset_year] IS NOT NULL THEN 'No'
	WHEN MD.[PHE3_RASTYR] IS NOT NULL AND BS.[RA_onset_year] IS  NULL THEN 'No'
	WHEN ISNUMERIC(MD.[PHE3_RASTYR]) = 0  AND BS.[RA_onset_year] IS NOT NULL THEN 'No'
	ELSE 'Yes'
   END AS [OnsetYearDiscrepancy]
  ,SD.[RESOnsetYear]
  ,CASE
	WHEN MD.[PHE3_RASTYR] = BS.[RA_onset_year] AND SD.[RESOnsetYear] IS NULL THEN MD.[PHE3_RASTYR]
	WHEN MD.[PHE3_RASTYR] IS NULL AND BS.[RA_onset_year] IS NOT NULL AND SD.[RESOnsetYear] IS NULL THEN BS.[RA_onset_year]
	WHEN MD.[PHE3_RASTYR] IS NOT NULL AND MD.[PHE3_RASTYR] <> '' AND BS.[RA_onset_year] IS  NULL AND SD.[RESOnsetYear] IS NULL THEN MD.[PHE3_RASTYR]
	WHEN ISNUMERIC(MD.[PHE3_RASTYR]) = 0  AND BS.[RA_onset_year] IS NOT NULL AND SD.[RESOnsetYear] IS NULL THEN BS.[RA_onset_year]
	WHEN SD.[RESOnsetYear] IS NOT NULL THEN SD.[RESOnsetYear]
	ELSE NULL
   END AS [OnsetYear]
  ,CASE
	WHEN ED.[EnrollmentDate] >= '03/25/2013' THEN 'RA'
	--RA Onset Year cannot be used as proxy for RA Diagnosis
	--WHEN MD.[PHE3_RASTYR] IS NOT NULL THEN 'RA'
	ELSE NULL
   END AS [TMDiagnosis]
  ,CASE 
	WHEN BS.[BSDiagnosis] IS NOT NULL THEN BS.[BSDiagnosis]
	--WHEN BS.[BSDiagnosis] IS NULL AND RA.[optional_id] IS NOT NULL THEN 'RA'
	ELSE NULL
   END AS [BSDiagnosis]
  ,CASE
	WHEN BS.[BSDiagnosis] IN ('PsA', 'Other') THEN 'Yes'
	--WHEN BS.[BSDiagnosis] IS NULL AND (ED.[EnrollmentDate] < '03/25/2013' AND RA.[optional_id] IS NULL) THEN 'Missing - ENR Prior to Mar 25, 2013'
    --WHEN (ED.[EnrollmentDate] < '03/25/2013' OR ED.[EnrollmentDate] IS NULL) /*AND (BS.[Enrollment_date] < '03/25/2013' OR BS.[Enrollment_date] IS NULL)*/ AND BS.[BSDiagnosis] IS NULL THEN 'Missing'
	WHEN ISNULL(BS.[BSDiagnosis],'')='' AND ISNULL(ED.[EnrollmentDate],'')='' THEN 'Missing'
	WHEN BS.[BSDiagnosis] ='RA' AND ED.[EnrollmentDate] < '03/25/2013' THEN 'Confirmation Required'
	WHEN BS.[BSDiagnosis] IS NULL AND ED.[EnrollmentDate] < '03/25/2013' THEN 'Confirmation Required'
	ELSE 'No'
   END AS [DiagnosisDiscrepancy]
  ,SD.[RESDiagnosis]
  ,CASE
	WHEN BS.[BSDiagnosis] IN ('PsA', 'Other') AND SD.[RESDiagnosis] IS NULL THEN NULL
	WHEN BS.[BSDiagnosis] IS NULL AND (ED.[EnrollmentDate] IS NULL OR ED.[EnrollmentDate] < '03/25/2013') AND SD.[RESDiagnosis] IS NULL THEN NULL
	WHEN BS.[BSDiagnosis] ='RA' AND ED.[EnrollmentDate] < '03/25/2013' AND SD.[RESDiagnosis] IS NULL THEN NULL
    --WHEN (ED.[EnrollmentDate] < '03/25/2013' OR ED.[EnrollmentDate] IS NULL) AND (BS.[Enrollment_date] < '03/25/2013' OR BS.[Enrollment_date] IS NULL) AND BS.[BSDiagnosis] IS NULL THEN NULL
	WHEN BS.[BSDiagnosis] IS NULL AND (ED.[EnrollmentDate] < '03/25/2013' OR ED.[EnrollmentDate] IS NULL) AND SD.[RESDiagnosis] IS NULL THEN NULL
	--WHEN ED.[EnrollmentDate] IS NULL AND BS.[BSDiagnosis] NOT IN ('PsA','Other') AND (BS.[BSDiagnosis] = 'RA' OR RA.[optional_id] IS NOT NULL) THEN 'RA'
	--WHEN ED.[EnrollmentDate] >= '03/25/2013' AND BS.[BSDiagnosis] IS NULL THEN 'RA'
	--WHEN ED.[EnrollmentDate] >= '03/25/2013' AND BS.[BSDiagnosis] NOT IN ('PsA','Other') AND (BS.[BSDiagnosis] = 'RA' OR RA.[optional_id] IS NOT NULL) THEN 'RA'
	--WHEN ED.[EnrollmentDate] < '03/25/2013' AND BS.[BSDiagnosis] NOT IN ('PsA','Other') AND (BS.[BSDiagnosis] = 'RA' OR RA.[optional_id] IS NOT NULL) THEN 'RA'
	--WHEN BS.[Enrollment_date] > '03/25/2013' OR BS.[RA_onset_year] IS NOT NULL THEN 'RA' (Onset year cannot be used as proxy for Diagnosis)
	WHEN SD.[RESDiagnosis] IS NOT NULL THEN SD.[RESDiagnosis]
	ELSE 'RA'
   END AS [Diagnosis]
  ,PQ.[PEQ3_PEQ3A] AS [TMEthnicity]
  ,NULL AS [BSEthnicity]
  ,CASE
	WHEN PQ.[PEQ3_PEQ3A] IS NOT NULL AND PQ.[PEQ3_PEQ3A] <> '' THEN 'No'
	ELSE 'Missing'
   END AS [EthnicityDiscrepancy]
  ,NULL AS [RESEthnicity]
  ,CASE
	WHEN PQ.[PEQ3_PEQ3A] IS NOT NULL THEN PQ.[PEQ3_PEQ3A]
	ELSE NULL
   END AS [Ethnicity]
  --,VT.[LastVisitDate] 
  ,LV.[LastVisitDate]
  --,SL.[ExitDate]
  ,TE.[ExitDate]
  ,CASE 
	WHEN TE.[ExitDate] IS NULL THEN CAST((DATEDIFF(DAY, LV.[LastVisitDate], GETDATE())/30.0) as decimal(8,2)) 
	WHEN TE.[ExitDate] IS NOT NULL THEN CAST((DATEDIFF(DAY, TE.[ExitDate], GETDATE())/30.0) as decimal(8,2)) 
	ELSE NULL
	END AS [MonthsSinceLastVisit]
  ,CASE
    WHEN II.[Imported] = 1 THEN 1
    ELSE 0
    END AS [Imported]
  ,CASE 
	WHEN TV.[TotalVisits] > 0 OR TT.[TotalTAEs] > 0 THEN 'Yes'
	ELSE 'No'
   END AS [RecordsInTM]
  ,CASE
	WHEN TF.[TotalFollowUps] IS NULL THEN 0 
	ELSE TF.[TotalFollowUps] 
   END AS [TotalFollowUps]
  ,CASE
	WHEN TT.[TotalTAEs] IS NULL THEN 0
	ELSE TT.[TotalTAEs]
   END AS [TotalTAEs]
  ,CASE
	WHEN PT.[SubjectID] = BS.[optional_id] THEN 'Yes'
	ELSE 'No'
	END AS [InLegacy]
   --SELECT * FROM #SubjectInfoCalc
INTO #SubjectInfoCalc --SELECT *
FROM [RA100].[v_op_AllSubjectsWTrlIDs] PT
LEFT JOIN (SELECT [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)') RS ON PT.[SiteID] = RS.[siteNumber]
LEFT JOIN #EnrollDates ED ON PT.[SubjectID] = ED.[SubjectID] AND PT.[SiteID] = ED.[SiteID]
LEFT JOIN #TerminalExits TE ON PT.[SubjectID] = TE.[SubjectID] AND PT.[SiteID] = TE.[SiteID] --SELECT * FROM [RA100].[t_op_LastVisits]
--LEFT JOIN [RA100].[t_op_LastVisits] LV ON PT.[SubjectID] = LV.[SubjectID] AND PT.[SiteID] = LV.[SiteID]
LEFT JOIN #LastVisits LV ON PT.[SubjectID] = LV.[SubjectID] AND PT.[SiteID] = LV.[SiteID]
--LEFT JOIN RA100.t_op_PatientVisitTracker VT ON PT.[SubjectID] = VT.[SubjectID] AND PT.[SiteID] = VT.[SiteID]
LEFT JOIN (SELECT [Site Object SiteNo], [Patient Object PatientNo], [PEQ1_PEQ1], [PEQ3_PEQ3A] FROM [OMNICOMM_RA100].[dbo].[PEQ1] WHERE ISNUMERIC([Patient Object PatientNo]) = 1) PQ ON PT.[SubjectID] = PQ.[Patient Object PatientNo]  AND PT.[SiteID] = PQ.[Site Object SiteNo]
LEFT JOIN (SELECT [Site Object SiteNo], [Patient Object PatientNo], [PHE3_RASTYR] FROM [OMNICOMM_RA100].[dbo].[PHEQ1] WHERE ISNUMERIC([Patient Object PatientNo]) = 1) MD ON PT.[SubjectID] = MD.[Patient Object PatientNo] AND PT.[SiteID] = MD.[Site Object SiteNo]
LEFT JOIN #TotalVisits TV ON PT.[SubjectID] = TV.[SubjectID] AND PT.[SiteID] = TV.[SiteID]
LEFT JOIN #TotalFollowUps TF ON PT.[SubjectID] = TF.[SubjectID] AND PT.[SiteID] = TF.[SiteID]
LEFT JOIN #TotalTAEs TT ON PT.[SubjectID] = TT.[SubjectID] AND PT.[SiteID] = TT.[SiteID]
LEFT JOIN #BSSubjectInfo BS ON PT.[SubjectID] = BS.[optional_id] AND PT.[SiteID] = BS.[site_id]
--LEFT JOIN [RA100].[t_op_BiostatsSubjectInfo] BS ON PT.[SubjectID] = BS.[optional_id] AND PT.[SiteID] = BS.[site_id]
--SELECT * FROM [Reporting].[RA100].[t_op_SubjectInfoROMRetrievedData]
--LEFT JOIN [Reporting].[RA100].[t_op_SubjectInfoROMRetrievedData] RD ON PT.[SubjectID] = RD.[optional_id] AND PT.[SiteID] = RD.[site_id]
LEFT JOIN [RA100].[t_op_RCCImportedSubjectInfo] II ON PT.[SubjectID] = II.[SubjectID] AND PT.[SiteID] = II.[SiteID]
LEFT JOIN [RA100].[t_op_SubjectInfoDiscrepancies] SD ON PT.[SubjectID] = SD.[SubjectID] AND PT.[SiteID] = SD.[SiteID]
LEFT JOIN #PTCreateDate CD ON PT.[PatientID] = CD.[TrlObjectPatientId]
--LEFT JOIN [RA100].[t_op_SubjectInfoBiostatsRAOnly] RA ON PT.[SubjectID] = RA.[optional_id] AND PT.[SiteID] = RA.[site_id]



IF OBJECT_ID('tempdb.dbo.#SubjectStatuses') IS NOT NULL BEGIN DROP TABLE #SubjectStatuses END

SELECT
	 [SiteID]
	,[SubjectID]
	,CASE 
		WHEN [ExitDate] IS NOT NULL AND [MonthsSinceLastVisit] <= 18 THEN 'Exited (<=18 Months)'
		WHEN [ExitDate] IS NOT NULL AND [MonthsSinceLastVisit] > 18 THEN 'Exited (>18 Months)'
		WHEN [MonthsSinceLastVisit] > 18 AND [MonthsSinceLastVisit] <= 60 THEN 'Inactive (<=60 Months)'
		WHEN [MonthsSinceLastVisit] > 60 THEN 'Inactive (>60 Months)'
		WHEN [MonthsSinceLastVisit] <= 18 THEN 'Active (<=18 Months)'
		ELSE 'No Visits'
	 END AS [SubjectStatus]
--SELECT * FROM #SubjectStatuses
INTO #SubjectStatuses
FROM #SubjectInfoCalc


IF OBJECT_ID('tempdb.dbo.#SubjectInfoDiscCount') IS NOT NULL BEGIN DROP TABLE #SubjectInfoDiscCount END

SELECT
	 [SiteID]
	,[SubjectID]
	,SUM(CASE WHEN [EnrollDateDiscrepancy] IN ('Missing', 'Yes', 'TM Enroll Date is Pre-TM', 'Yes + TM Enroll Date is Pre-TM') THEN 1 ELSE 0 END) AS [EnrollDateDiscrepancyCount]
	--,SUM(CASE WHEN [TMEnrollDateIsPreTM] = 'Yes' THEN 1 ELSE 0 END) AS [TMEnrollDateIsPreTMCount]
	,SUM(CASE WHEN [YOBDiscrepancy] IN ('Missing', 'Yes') THEN 1 ELSE 0 END) AS [YOBDiscrepancyCount]
	,SUM(CASE WHEN [SexDiscrepancy] IN ('Missing', 'Yes') THEN 1 ELSE 0 END) AS [SexDiscrepancyCount]
	,SUM(CASE WHEN [OnsetYearDiscrepancy] IN ('Missing', 'Yes') THEN 1 ELSE 0 END) AS [OnsetYearDiscrepancyCount]
	,SUM(CASE WHEN [DiagnosisDiscrepancy] LIKE 'Missing%' OR [DiagnosisDiscrepancy] = 'Yes' OR [DiagnosisDiscrepancy] = 'Confirmation Required' THEN 1 ELSE 0 END) AS [DiagnosisDiscrepancyCount]
	,SUM(CASE WHEN [RESEnrollDate] IS NOT NULL THEN 1 ELSE 0 END) AS [RESEnrollDateCount]
	,SUM(CASE WHEN [RESYOB] IS NOT NULL THEN 1 ELSE 0 END) AS [RESYOBCount]
	,SUM(CASE WHEN [RESSex] IS NOT NULL THEN 1 ELSE 0 END) AS [RESSexCount]
	,SUM(CASE WHEN [RESOnsetYear] IS NOT NULL THEN 1 ELSE 0 END) AS [RESOnsetYearCount]
	,SUM(CASE WHEN [RESDiagnosis] IS NOT NULL THEN 1 ELSE 0 END) AS [RESDiagnosisCount]
--SELECT * FROM #SubjectInfoDiscCount
INTO #SubjectInfoDiscCount
FROM #SubjectInfoCalc
GROUP BY [SiteID], [SubjectID]


IF OBJECT_ID('tempdb.dbo.#SubjectInfoDiscTotal') IS NOT NULL BEGIN DROP TABLE #SubjectInfoDiscTotal END

SELECT
	 [SiteID]
	,[SubjectID]
	,[EnrollDateDiscrepancyCount] + [YOBDiscrepancyCount] + [SexDiscrepancyCount] + [OnsetYearDiscrepancyCount] + [DiagnosisDiscrepancyCount] AS [TotalDiscrepancies]
	,[RESEnrollDateCount] + [RESYOBCount] + [RESSexCount] + [RESOnsetYearCount] + [RESDiagnosisCount] AS [TotalResolved]
--#SubjectInfoDiscTotal
INTO #SubjectInfoDiscTotal
FROM #SubjectInfoDiscCount

IF OBJECT_ID('tempdb.dbo.#SubjectInfoDiscDetails') IS NOT NULL BEGIN DROP TABLE #SubjectInfoDiscDetails END

SELECT
	 SI.[SiteID]
	,SI.[SubjectID]
	,CASE
		WHEN SI.[EnrollDateDiscrepancy] = 'Missing' AND SD.[RESEnrollDate] IS NULL THEN 'Enroll Date - Missing'
		WHEN SI.[EnrollDateDiscrepancy] = 'Yes' AND SD.[RESEnrollDate] IS NULL THEN 'Enroll Date - Discrepancy'
		WHEN SI.[EnrollDateDiscrepancy] = 'TM Enroll Date is Pre-TM' AND SD.[RESEnrollDate] IS NULL THEN 'Enroll Date - TM Enroll Date is Pre-TM'
		WHEN SI.[EnrollDateDiscrepancy] = 'Yes + TM Enroll Date is Pre-TM' AND SD.[RESEnrollDate] IS NULL THEN 'Enroll Date - Discrepancy + TM Enroll Date is Pre-TM'
		ELSE NULL
	 END AS [EnrollDateDiscrepancyType]
	--,CASE
	--	WHEN SI.[TMEnrollDateIsPreTM] = 'Yes' AND SD.[RESEnrollDate] IS NULL THEN 'TM Enroll Date is Pre-TM'
	--	ELSE NULL
	-- END AS [TMEnrollDateIsPreTMType]
	,CASE
		WHEN SI.[YOBDiscrepancy] = 'Missing' AND SD.[RESYOB] IS NULL THEN 'YOB - Missing'
		WHEN SI.[YOBDiscrepancy] = 'Yes' AND SD.[RESYOB] IS NULL THEN 'YOB - Discrepancy'
		ELSE NULL
	 END AS [YOBDiscrepancyType]
	,CASE
		WHEN SI.[SexDiscrepancy] = 'Missing' AND SD.[RESSex] IS NULL THEN 'Sex - Missing'
		WHEN SI.[SexDiscrepancy] = 'Yes' AND SD.[RESSex] IS NULL THEN 'Sex - Discrepancy'
		ELSE NULL
	 END AS [SexDiscrepancyType]
	,CASE
		WHEN SI.[OnsetYearDiscrepancy] = 'Missing' AND SD.[RESOnsetYear] IS NULL THEN 'Onset Year - Missing'
		WHEN SI.[OnsetYearDiscrepancy] = 'Yes' AND SD.[RESOnsetYear] IS NULL THEN 'Onset Year - Discrepancy'
		ELSE NULL
	 END AS [OnsetYearDiscrepancyType]
	,CASE
		WHEN SI.[DiagnosisDiscrepancy] = 'Missing' AND SD.[RESDiagnosis] IS NULL THEN 'Diagnosis - Missing'
		WHEN SI.[DiagnosisDiscrepancy] = 'Yes' AND SD.[RESDiagnosis] IS NULL THEN 'Diagnosis - Discrepancy'
		WHEN SI.[DiagnosisDiscrepancy] = 'Confirmation Required' AND SD.[RESDiagnosis] IS NULL THEN 'Diagnosis - Confirmation Required'
		ELSE NULL
	 END AS [DiagnosisDiscrepancyType]
   --SELECT * FROM #SubjectInfoDiscDetails
INTO #SubjectInfoDiscDetails
FROM #SubjectInfoCalc SI --SELECT * FROM [RA100].[t_op_SubjectInfoDiscrepancies] 
LEFT JOIN [RA100].[t_op_SubjectInfoDiscrepancies] SD ON SI.[SubjectID] = SD.[SubjectID] AND SI.[SiteID] = SD.[SiteID]


IF OBJECT_ID('tempdb.dbo.#SubjectInfoDiscrepancies') IS NOT NULL BEGIN DROP TABLE #SubjectInfoDiscrepancies END

SELECT SI.* 
   --SELECT * FROM #SubjectInfoDiscrepancies
INTO #SubjectInfoDiscrepancies
FROM (
	SELECT
		 [SiteID]
		,[SubjectID]
		,[EnrollDateDiscrepancyType] AS [Discrepancies]
	   --SELECT * FROM
	FROM #SubjectInfoDiscDetails
	WHERE [EnrollDateDiscrepancyType] IS NOT NULL
	--UNION
	--SELECT
	--	 [SiteID]
	--	,[SubjectID]
	--	,[TMEnrollDateIsPreTMType] AS [Discrepancies]
	--   --SELECT * FROM
	--FROM #SubjectInfoDiscDetails
	--WHERE [TMEnrollDateIsPreTMType] IS NOT NULL
	UNION
	SELECT
		 [SiteID]
		,[SubjectID]
		,[YOBDiscrepancyType] AS [Discrepancies]
	   --SELECT * FROM
	FROM #SubjectInfoDiscDetails
	WHERE [YOBDiscrepancyType] IS NOT NULL
	UNION
	SELECT
		 [SiteID]
		,[SubjectID]
		,[SexDiscrepancyType] AS [Discrepancies]
	   --SELECT * FROM
	FROM #SubjectInfoDiscDetails
	WHERE [SexDiscrepancyType] IS NOT NULL
	UNION
	SELECT
		 [SiteID]
		,[SubjectID]
		,[OnsetYearDiscrepancyType] AS [Discrepancies]
	   --SELECT * FROM
	FROM #SubjectInfoDiscDetails
	WHERE [OnsetYearDiscrepancyType] IS NOT NULL
	UNION
	SELECT
		 [SiteID]
		,[SubjectID]
		,[DiagnosisDiscrepancyType] AS [Discrepancies]
	   --SELECT * FROM
	FROM #SubjectInfoDiscDetails
	WHERE [DiagnosisDiscrepancyType] IS NOT NULL
) SI


IF OBJECT_ID('tempdb.dbo.#PTsWDiscrepancies') IS NOT NULL BEGIN DROP TABLE #PTsWDiscrepancies END

SELECT
	 [SiteID]
	,[SubjectID]
	,CASE WHEN [TotalDiscrepancies] > 0 THEN 1 
	 ELSE NULL
	 END AS [PTWDiscrepancies]
	,CASE WHEN [TotalDiscrepancies] > 0 AND [TotalResolved] > 0 AND [TotalDiscrepancies] = [TotalResolved] THEN 1 
	 ELSE NULL
	 END AS [FullyResolvedPTs]
--#SubjectInfoDiscTotal
INTO #PTsWDiscrepancies
FROM #SubjectInfoDiscTotal

INSERT INTO [Reporting].[RA100].[t_op_SubjectInfo]
(
	 [SiteID]
	,[SiteStatus]
	,[SubjectID]
	,[SubIDL0s]
	,[TrialMasterID]
    ,[CreatedDate]
	,[VisitType]
	,[TMEnrollDate]
	,[BSEnrollDate]
	,[EnrollDateDiscrepancy]
    ,[RESEnrollDate]
	,[EnrollDate]
	,[TMYOB]
	,[BSYOB]
	,[YOBDiscrepancy]
    ,[RESYOB]
	,[YOB]
	,[TMSex]
	,[BSSex]
	,[SexDiscrepancy]
    ,[RESSex]
	,[Sex]
	,[TMOnsetYear]
	,[BSOnsetYear]
	,[OnsetYearDiscrepancy]
    ,[RESOnsetYear]
	,[OnsetYear]
    ,[TMDiagnosis]
    ,[BSDiagnosis]
    ,[DiagnosisDiscrepancy]
    ,[RESDiagnosis]
	,[Diagnosis]
	,[TMEthnicity]
	,[BSEthnicity]
	,[EthnicityDiscrepancy]
	,[RESEthnicity]
	,[Ethnicity]
	,[LastVisitDate]
	,[ExitDate]
    ,[MonthsSinceLastVisit]
    ,[SubjectStatus]
	,[Imported]
	,[RecordsInTM]
    ,[TotalFollowUps]
    ,[TotalTAEs]
	,[InLegacy]
    ,[PTWDiscrepancies]
	,[FullyResolvedPTs]
    ,[TotalDiscrepancies]
	,[TotalResolved]
	,[Discrepancies]
	,[EnrollDateDiscrepancyCount]
	,[YOBDiscrepancyCount]
	,[SexDiscrepancyCount]
	,[OnsetYearDiscrepancyCount]
	,[DiagnosisDiscrepancyCount]
	,[RESEnrollDateCount]
	,[RESYOBCount]
	,[RESSexCount]
	,[RESOnsetYearCount]
	,[RESDiagnosisCount]
    ,[EligibleForImport]
)



SELECT 
	 SC.[SiteID]
	,SC.[SiteStatus]
	,SC.[SubjectID]
	,SC.[SubIDL0s]
	,SC.[TrialMasterID]
	,SC.[CreatedDate]
	,SC.[VisitType]
	,SC.[TMEnrollDate]
	,SC.[BSEnrollDate]
	--,SC.[ROMEnrollDate]
	,SC.[EnrollDateDiscrepancy]
	,SC.[RESEnrollDate]
	,SC.[EnrollDate]
	,SC.[TMYOB]
	,SC.[BSYOB]
	--,SC.[ROMYOB]
	,SC.[YOBDiscrepancy]
	,SC.[RESYOB]
	,SC.[YOB]
	,SC.[TMSex]
	,SC.[BSSex]
	--,SC.[ROMSex]
	,SC.[SexDiscrepancy]
	,SC.[RESSex]
	,SC.[Sex]
	,SC.[TMOnsetYear]
	,SC.[BSOnsetYear]
	,SC.[OnsetYearDiscrepancy]
	,SC.[RESOnsetYear]
	,SC.[OnsetYear]
	,SC.[TMDiagnosis]
	,SC.[BSDiagnosis]
	,SC.[DiagnosisDiscrepancy]
	,SC.[RESDiagnosis]
	,SC.[Diagnosis]
	,SC.[TMEthnicity]
	,SC.[BSEthnicity]
	,SC.[EthnicityDiscrepancy]
	,SC.[RESEthnicity]
	,SC.[Ethnicity]
	,SC.[LastVisitDate]
	,SC.[ExitDate]
	,SC.[MonthsSinceLastVisit]
	,SS.[SubjectStatus]
	,SC.[Imported]
	,SC.[RecordsInTM]
	,SC.[TotalFollowUps]
	,SC.[TotalTAEs]
	,SC.[InLegacy]
    ,PD.[PTWDiscrepancies]
	,PD.[FullyResolvedPTs]
	,ST.[TotalDiscrepancies]
	,ST.[TotalResolved]
	,STUFF((SELECT ', ' + [Discrepancies] FROM #SubjectInfoDiscrepancies SD WHERE SD.[SubjectID]=SC.[SubjectID] AND SD.[SiteID]=SC.[SiteID] FOR XML PATH('')),1,1, '') AS [Discrepancies]
	,SI.[EnrollDateDiscrepancyCount]
	,SI.[YOBDiscrepancyCount]
	,SI.[SexDiscrepancyCount]
	,SI.[OnsetYearDiscrepancyCount]
	,SI.[DiagnosisDiscrepancyCount]
	,SI.[RESEnrollDateCount]
	,SI.[RESYOBCount]
	,SI.[RESSexCount]
	,SI.[RESOnsetYearCount]
	,SI.[RESDiagnosisCount]
	,CASE
		WHEN SC.[EnrollDate] IS NULL OR SC.[YOB] IS NULL OR SC.[Sex] IS NULL OR SC.[OnsetYear] IS NULL OR SC.[Diagnosis] IS NULL THEN 0
		ELSE 1
	 END AS [EligibleForImport]

FROM #SubjectInfoCalc SC
LEFT JOIN #SubjectInfoDiscTotal ST ON SC.[SubjectID] = ST.[SubjectID] AND SC.[SiteID] = ST.[SiteID]
LEFT JOIN #SubjectStatuses SS ON SC.[SubjectID] = SS.[SubjectID] AND SC.[SiteID] = SS.[SiteID]
LEFT JOIN #PTsWDiscrepancies PD ON SC.[SubjectID] = PD.[SubjectID] AND SC.[SiteID] = PD.[SiteID]
LEFT JOIN #SubjectInfoDiscCount SI ON SC.[SubjectID] = SI.[SubjectID] AND SC.[SiteID] = SI.[SiteID]

GO
