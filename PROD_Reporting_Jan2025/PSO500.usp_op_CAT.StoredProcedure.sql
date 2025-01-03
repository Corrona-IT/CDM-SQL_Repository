USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_CAT]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: May 12, 2020
-- Description:	Procedure for Drugs at Enrollment with Hierarchy for DOI
--              Does not include Test Sites 997, 998, 999
-- ===========================================================================


CREATE PROCEDURE [PSO500].[usp_op_CAT] AS
	-- Add the parameters for the stored procedure here

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;


/*

CREATE TABLE [PSO500].[t_op_CAT]
(
	[EnrollVisitId] [bigint] NOT NULL,
	[PatientId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [nvarchar] (30) NOT NULL,
	[VisitType] [nvarchar](40) NULL,
	[ProviderID] [int] NULL,
	[BirthDate] [int] NULL,
	[EnrollDate] [date] NULL,
	[DiagnosisYear] [int] NULL,
	[EligVersion] [int] NULL,
	[crfStatus] [nvarchar](200) NULL,
	[Treatment] [nvarchar](350) NULL,
	[otherTreatment] [nvarchar](350) NULL,
	[DOI] [nvarchar](500) NULL,
	[EligibleTreatment] [nvarchar](40) NULL,
	[FirstDoseToday] [nvarchar](10) NULL,
	[firstUse] [nvarchar](10) NULL,
	[calcFirstUse] [nvarchar] (10) NULL,
	[AllowedPreviousUse] [nvarchar](10) NULL,
	[BiologicNaive] [nvarchar](10) NULL,
	[additionalStartDate] [nvarchar] (5) NULL,
	[TreatmentType] [nvarchar](150) NULL,
	[DOIType] [nvarchar](50) NULL,
	[TreatmentStatus] [nvarchar](150) NULL,
	[TwelveMonthInitiationRule] [nvarchar](25) NULL,
	[startDate] [date] NULL,
	[stopDate] [date] NULL,
	[pastUseStartDate] [date] NULL,
	[pastUseStopDate] [date] NULL,
	[MonthsSinceStart] [bigint] NULL,
	[DaysSinceStart] [bigint] NULL,
	[DaysInterrupted] [bigint] NULL,
	[trxmtBetween] [nvarchar](20) NULL,
	[MonthsSincePastUseStart] [bigint] NULL,
	[FUVisitId] [bigint] NULL,
	[InitiationStatus] [nvarchar](300) NULL,
	[DrugStartDateConfirmation] [date] NULL,
	[RegistryEnrollmentStatus] [nvarchar](100) NULL,
	[EligibilityReview] [nvarchar](100) NULL
) ON [PRIMARY]
GO

CREATE TABLE [PSO500].[t_EligDashboard]
(
	[Site ID] [int] NOT NULL,
	[Subject ID] [nvarchar] (30) NULL,
	[Eligible Treatment] [nvarchar](50) NULL,
	[Enrollment Date] [date] NULL,

) ON [PRIMARY]
GO
*/



/******************Get subject enrollment*********************/

IF OBJECT_ID('tempdb.dbo.#PROVIDERID') IS NOT NULL BEGIN DROP TABLE #PROVIDERID END;

SELECT DISTINCT VisitId
      ,PatientId
	  ,SubjectID
	  ,VisitDate
	  ,VisitType
	  ,ProviderID
	  ,DiagnosisYear
	  ,crfStatus
INTO #PROVIDERID
FROM 
(
SELECT DISTINCT VisitId
      ,PatientId
	  ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[Visit Object ProCaption] AS VisitType
	  ,CASE WHEN ISNULL(PE1_md_cod, '')='' THEN CAST(NULL AS int)
	   ELSE PE1_md_cod
	   END AS ProviderID
	  ,CASE WHEN ISNULL(PE3_yr_ps_dx, '')='' THEN CAST(NULL AS int)
	   ELSE PE3_yr_ps_dx
	   END AS DiagnosisYear
	  ,[Form Object Status] AS crfStatus
FROM OMNICOMM_PSO.inbound.PE
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
) A
--select * from #PROVIDERID

IF OBJECT_ID('tempdb.dbo.#BIRTHDATE') IS NOT NULL BEGIN DROP TABLE #BIRTHDATE END;

SELECT DISTINCT VisitId
      ,PatientId
	  ,SubjectID
	  ,BirthDate
	  ,crfStatus
INTO #BIRTHDATE
FROM
(
SELECT VisitId
      ,PatientId
	  ,[Site Object SiteNo] AS SiteID
	  ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
	  ,[Visit Object VisitDate] AS VisitDate
	  ,CASE WHEN ISNULL(DM1_birthdate,'')='' THEN CAST(NULL AS int)
	   ELSE DM1_birthdate
	   END AS BirthDate
	  ,[Form Object Status] AS crfStatus
FROM OMNICOMM_PSO.inbound.DM
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
) B

--SELECT * FROM #PROVIDERID

IF OBJECT_ID('tempdb.dbo.#ENROLL') IS NOT NULL BEGIN DROP TABLE #ENROLL END;

SELECT DISTINCT VIS.VisitId
      ,VIS.PatientId
      ,CAST(SIT.[Site Number] AS int) AS SiteID
      ,PAT.[PatientNo] AS SubjectID
	  ,VIS.ProCaption AS VisitType
	  ,CAST(PID.ProviderID AS int) AS ProviderID
	  ,CAST(BD.BirthDate AS int) AS BirthDate
	  ,SUB.SUB_BirthDate
	  ,SUB.SUB_Age
	  ,CAST(VIS.VisitDate AS date) AS VisitDate
	  ,CAST(PID.DiagnosisYear AS int) AS DiagnosisYear
	  ,CASE WHEN CAST(VIS.VisitDate AS date) < '2016-06-20' THEN 1
	   WHEN CAST(VIS.VisitDate AS date) BETWEEN '2016-06-20' AND '2020-04-30' THEN 2
	   WHEN CAST(VIS.VisitDate AS date) > '2020-04-30' THEN 3
	   ELSE NULL
	   END AS EligVersion
	  ,BD.crfStatus
INTO #ENROLL
FROM OMNICOMM_PSO.inbound.[G_Site Information] SIT
INNER JOIN OMNICOMM_PSO.inbound.[Patients] PAT ON SIT.SiteId=PAT.SiteId
INNER JOIN OMNICOMM_PSO.inbound.[Visits] VIS ON VIS.PatientId=PAT.PatientId
LEFT JOIN #PROVIDERID PID ON PID.VisitId=VIS.VisitId AND PID.PatientId=VIS.PatientId
LEFT JOIN #BIRTHDATE BD ON BD.VisitId=VIS.VisitId AND BD.PatientId=VIS.PatientId
LEFT JOIN
(SELECT DISTINCT subject_id AS SubjectID
      ,[Enroll Date]
	  ,SUBSTRING([Enroll Date], 1, 4) AS EnrollYear
      ,birthdate_pat AS SUB_BirthDate
	  ,PatientId AS PatientId
	  ,CASE WHEN ISNULL([birthdate_pat], '')='' THEN CAST(NULL AS int)
	   WHEN ISNULL([Enroll Date], '')='' THEN CAST(NULL AS int)
	   ELSE CAST(SUBSTRING([Enroll Date], 1, 4) AS int)-birthdate_pat
	   END AS SUB_Age
	  ,[Sys. SiteNo] SiteID
FROM OMNICOMM_PSO.inbound.[G_Subject Information] SUB
WHERE [Sys. SiteNo] NOT IN (999, 998, 997)) SUB ON SUB.PatientId=VIS.PatientId

WHERE ISNULL(VIS.VisitDate, '') <> ''
AND VIS.ProCaption IN ('Enrollment')
AND [Site Number] NOT IN (997, 998, 999)

--SELECT * FROM #ENROLL ORDER BY SiteID, SubjectID, VisitType, VisitDate



/*******************Get treatment at Enrollment**********************/

IF OBJECT_ID('tempdb.dbo.#ET') IS NOT NULL BEGIN DROP TABLE #ET END;

SELECT DISTINCT E.VisitId
      ,E.PatientId
	  ,E.SiteID
	  ,E.SubjectID
	  ,E.VisitType
	  ,E.ProviderID
	  ,E.BirthDate
	  ,E.SUB_BirthDate
	  ,CAST(E.VisitDate AS date) AS VisitDate
	  ,CASE WHEN ISNULL(BirthDate, '')<>'' THEN DATEPART(yyyy, E.VisitDate) - BirthDate 
	   ELSE CAST(NULL as int)
	   END AS AgeAtEnrollment
	  ,SUB_Age
	  ,E.DiagnosisYear
	  ,E.EligVersion
	  ,CASE WHEN ISNULL(T.crfStatus, '')='' THEN 'No data'
	   ELSE T.crfStatus
	   END AS crfStatus
	  ,T.Treatment
	  ,T.otherTreatment
	  ,CASE WHEN T.Treatment LIKE 'Other%' THEN NULL
	     WHEN CR.TreatmentType IS NULL AND EXISTS(SELECT DISTINCT TreatmentType FROM [Reporting].[PSO500].[t_op_CATReference] CR2 WHERE CR2.TreatmentName=T.Treatment) THEN (SELECT DISTINCT TreatmentType FROM [Reporting].[PSO500].[t_op_CATReference] CR2 WHERE CR2.TreatmentName=T.Treatment)
	   ELSE CR.TreatmentType
	   END AS TreatmentType
	  ,CR.DOIType
	  ,T.FirstDoseToday
	  ,T.firstUse
	  
	  ,CASE WHEN T.Treatment='adalimumab {Humira}' AND E.VisitDate BETWEEN '2021-06-28' AND '2022-01-01' THEN 'Not eligible'
	   WHEN T.Treatment='adalimumab {Humira}' AND T.startDate BETWEEN '2021-06-28' AND '2022-01-01' THEN 'Not eligible'
	   WHEN E.EligVersion IN (SELECT [Version] FROM [Reporting].[PSO500].[t_op_CATReference] CR WHERE T.Treatment=CR.TreatmentName)
	   THEN 'Eligible'
	   WHEN T.Treatment='Investigational Agent' THEN 'Not eligible'
	   WHEN T.Treatment LIKE 'Other%' THEN 'Needs review'
	   WHEN T.Treatment='No Treatment' THEN 'Not eligible'
	   WHEN T.crfStatus='No Data' THEN 'Pending'
	   WHEN ISNULL(T.Treatment, '')<>'No Data' AND E.EligVersion NOT IN (SELECT [Version] FROM [Reporting].[PSO500].[t_op_CATReference] CR WHERE T.Treatment=CR.TreatmentName)
	   THEN 'Not eligible'
	   ELSE ''
	   END AS EligibleTreatment

	  ,T.TreatmentStatus
	  ,CASE WHEN T.TreatmentStatus IN ('Prescribed Today', 'Changes Prescribed') THEN 'Eligible'
	   WHEN T.TreatmentStatus IN ('Current') AND NOT EXISTS(SELECT T2.stopDate FROM  [Reporting].[PSO500].[t_op_AllDrugs] T2 WHERE T2.VisitID=T.VisitID and T2.Treatment=T.Treatment AND T2.TreatmentStatus='Stopped Today') THEN 'Eligible'
	   WHEN T.TreatmentStatus IN ('Current') AND EXISTS(SELECT T2.stopDate FROM [Reporting].[PSO500].[t_op_AllDrugs] T2 WHERE T2.VisitID=T.VisitID and T2.Treatment=T.Treatment and T2.otherTreatment=T.otherTreatment AND T2.TreatmentStatus='Stopped Today') THEN 'Not eligible'
	   WHEN T.TreatmentStatus='Stopped Today' AND T.StopReasons LIKE '%TI%' THEN 'Needs review-TI'
	   WHEN T.TreatmentStatus='Stopped Today' AND T.StopReasons NOT LIKE '%TI%' THEN 'Not eligible'
	   WHEN T.TreatmentStatus='Unknown' THEN 'Needs review'
	   WHEN T.crfStatus='No data' THEN 'Pending'
	   WHEN T.TreatmentStatus IN ('Past', 'Stopped Today') THEN 'Not eligible'
	   ELSE ''
	   END AS EligibleTreatmentStatus

	  ,CASE WHEN ISNULL(T.startDate, '')='' then CAST(NULL AS date)
	   WHEN TreatmentStatus='Prescribed Today' AND FirstDoseToday='Yes' THEN E.VisitDate
	   ELSE CAST(T.startDate AS date)
	   END AS startDate

	  ,CASE WHEN ISNULL(T.changeDate, '')='' then CAST(NULL AS date)
	   ELSE CAST(T.changeDate AS date)
	   END AS changeDate

	  ,CASE WHEN ISNULL(T.stopDate, '')='' then CAST(NULL AS date)
	   ELSE CAST(T.stopDate AS date)
	   END AS stopDate

	  ,CASE WHEN T.TreatmentStatus='Past' AND ISNULL(T.stopDate, '')<>'' THEN DATEDIFF(dd, T.stopDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS DaysSincePastUse

	  ,CASE WHEN T.TreatmentStatus='Current' AND ISNULL(T.startDate, '')<>'' THEN DATEDIFF(mm, T.startDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS MonthsSinceStart

	  ,CASE WHEN T.TreatmentStatus='Current' AND ISNULL(T.startDate, '')<>'' THEN DATEDIFF(DD, T.startDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS DaysSinceStart

INTO #ET
FROM #ENROLL E
LEFT JOIN [Reporting].[PSO500].[t_op_AllDrugs] T ON T.VisitID=E.VisitId
LEFT JOIN [Reporting].[PSO500].[t_op_CATReference] CR ON CR.TreatmentName=T.Treatment AND CR.[Version]=E.EligVersion


--SELECT * FROM #ET ORDER BY SiteID, SubjectID
--SELECT * FROM [Reporting].[PSO500].[t_op_CATReference]
--SELECT * FROM 
--SELECT * FROM [Reporting].[PSO500].[t_op_AllDrugs] WHERE SubjectID=46856540039


/***************Add Hierarchies for choosing DOI*************/

IF OBJECT_ID('tempdb.dbo.#ET2') IS NOT NULL BEGIN DROP TABLE #ET2 END;

SELECT DISTINCT ET.VisitId
      ,ET.PatientId
	  ,ET.SiteID
	  ,ET.SubjectID
	  ,ET.VisitType
	  ,ET.ProviderID
	  ,ET.BirthDate
	  ,ET.SUB_BirthDate
	  ,ET.VisitDate
	  ,ET.AgeAtEnrollment
	  ,ET.SUB_Age
	  ,ET.DiagnosisYear
	  ,ET.EligVersion
	  ,ET.crfStatus
	  ,ET.Treatment
	  ,ET.otherTreatment
	  ,ET.TreatmentType
	  ,ET.DOIType
	  ,ET.FirstDoseToday
	  ,ET.firstUse
	  ,CASE WHEN ET.TreatmentStatus<>'Past' AND ISNULL(T.Treatment, '')<>'' THEN 'No'
	   WHEN ET.TreatmentStatus<>'Past' AND ISNULL(T.Treatment, '')='' THEN 'Yes'
	   ELSE ''
	   END AS calcFirstUse
	  ,ET.EligibleTreatment
	  ,ET.TreatmentStatus
	  ,ET.EligibleTreatmentStatus
	  ,ET.startDate
	  ,ET.changeDate
	  ,ET.stopDate
	  ,ET.DaysSincePastUse
	  ,ET.MonthsSinceStart
	  ,ET.DaysSinceStart

	  ,CASE WHEN ET.EligVersion=3 AND NOT EXISTS(SELECT TreatmentType FROM #ET ET2 WHERE ET2.SubjectID=ET.SubjectID AND ET2.VisitID=ET.VisitId AND ET2.TreatmentType = 'Biologic') THEN 'Yes'
	   WHEN ET.EligVersion=3 AND EXISTS(SELECT TreatmentType FROM #ET ET2 WHERE ET2.SubjectID=ET.SubjectID AND ET2.VisitID=ET.VisitId AND ET2.TreatmentType = 'Biologic') THEN 'No'
	   ELSE ''
	   END AS BiologicNaive

	  ,CASE WHEN ET.TreatmentStatus='Prescribed Today' AND TreatmentType='Biologic' AND EligibleTreatment='Eligible' THEN 10
	   WHEN ET.TreatmentStatus='Current' AND TreatmentType='Biologic' AND EligibleTreatment='Eligible' THEN 15
	   WHEN ET.TreatmentStatus='Changes Prescribed' AND TreatmentType='Biologic' AND EligibleTreatment='Eligible' THEN 16
	   WHEN ET.TreatmentStatus='Prescribed Today' AND TreatmentType='Non-Biologic' AND EligibleTreatment='Eligible'THEN 20
	   WHEN ET.TreatmentStatus IN ('Current', 'Changes Prescribed') AND TreatmentType='Non-Biologic' AND EligibleTreatment='Eligible' THEN 25
	   WHEN ET.EligibleTreatmentStatus='Needs review' THEN 30
	   WHEN ET.EligibleTreatmentStatus='Needs review-TI' THEN 31
	   WHEN ET.Treatment='adalimumab {Humira}' AND ET.VisitDate BETWEEN '2021-06-28' AND '2022-01-01' AND ET.TreatmentStatus IN ('Current', 'Prescribed Today', 'Changes Prescribed') THEN 32
	   WHEN ET.TreatmentStatus IN ('Current', 'Changes Prescribed') AND ET.Treatment LIKE 'Other%' THEN 33
	   WHEN ET.TreatmentStatus='Unknown' THEN 35
	   WHEN ET.Treatment='Investigational Agent' AND ET.TreatmentStatus NOT IN ('Past', 'Stopped Today') THEN 40 
	   WHEN ET.TreatmentStatus='Stopped Today' THEN 50
	   WHEN ET.TreatmentStatus='Past' THEN 60
	   ELSE 90
	   END AS TreatmentStatusHierarchy

	  ,CASE WHEN ET.TreatmentStatus='Prescribed Today' AND ET.EligibleTreatment='Eligible' AND ET.TreatmentType='Biologic' THEN 10
	   WHEN ET.TreatmentStatus='Current' AND ET.EligibleTreatment='Eligible'  AND ET.TreatmentType='Biologic' AND NOT EXISTS (SELECT TreatmentStatus FROM [Reporting].[PSO500].[t_op_AllDrugs] T2 WHERE VisitId=ET.VisitId AND T2.Treatment=ET.Treatment AND TreatmentStatus='Stopped Today') THEN 20
	   WHEN ET.TreatmentStatus='Changes Prescribed' AND ET.EligibleTreatment='Eligible' AND ET.TreatmentType='Biologic' THEN 20
	   WHEN ET.TreatmentStatus='Prescribed Today' AND ET.EligibleTreatment='Eligible' AND ET.TreatmentType='Non-Biologic' THEN 30 
	   WHEN ET.TreatmentStatus='Current' AND ET.EligibleTreatment='Eligible' AND NOT EXISTS (SELECT TreatmentStatus FROM [Reporting].[PSO500].[t_op_AllDrugs] T2 WHERE VisitId=ET.VisitId AND T2.Treatment=ET.Treatment AND TreatmentStatus='Stopped Today') AND ET.TreatmentType='Non-Biologic' THEN 40
	   WHEN ET.TreatmentStatus IN ('Prescribed Today', 'Changes Prescribed', 'Current') AND ET.Treatment LIKE 'Other%' AND EligibleTreatment='Needs review' THEN 42
	   WHEN ET.TreatmentStatus IN ('Other', 'Unknown', '') THEN 45
	   WHEN ET.crfStatus='No Data' THEN 50
	   WHEN ET.TreatmentStatus='Stopped Today' AND EligibleTreatmentStatus<>'Needs review-TI' THEN 60
	   WHEN ET.TreatmentStatus='Current' AND ET.EligibleTreatment='Eligible' AND EXISTS (SELECT TreatmentStatus FROM [Reporting].[PSO500].[t_op_AllDrugs] T2 WHERE VisitId=ET.VisitId AND T2.Treatment=ET.Treatment AND ET.TreatmentStatus='Stopped Today') THEN 70
	   WHEN ET.TreatmentStatus='Prescribed Today' AND  ET.EligibleTreatment='Not eligible' THEN 80
	   WHEN ET.TreatmentStatus='Current' AND ET.EligibleTreatment='Not eligible' THEN 85
		ELSE 90
		END AS DrugHierarchy

INTO #ET2
FROM #ET ET
LEFT JOIN [Reporting].[PSO500].[t_op_AllDrugs] T ON T.VisitId=ET.VisitId AND T.Treatment=ET.Treatment AND T.otherTreatment=ET.otherTreatment AND T.TreatmentStatus='Past' 


--SELECT * FROM #ET2 ORDER BY SiteID, SubjectID, Treatment

/***************Find Previous Use and Length of Interruption*************/

IF OBJECT_ID('tempdb.dbo.#INTERRUPT') IS NOT NULL BEGIN DROP TABLE #INTERRUPT END;

SELECT DISTINCT E.VisitId
      ,E.PatientId
	  ,E.SiteID
	  ,E.SubjectID
	  ,E.VisitType
	  ,E.ProviderID
	  ,E.BirthDate
	  ,E.SUB_BirthDate
	  ,E.VisitDate
	  ,CASE WHEN ISNULL(BirthDate, '')<>'' THEN DATEPART(yyyy, E.VisitDate) - BirthDate 
	   ELSE CAST(NULL as int)
	   END AS AgeAtEnrollment
	  ,CAST(E.SUB_Age AS int) AS SUB_Age
	  ,E.DiagnosisYear
	  ,E.EligVersion
	  ,E.crfStatus
	  ,E.Treatment AS currentTreatment
	  ,E.otherTreatment AS otherCurrentTreatment
	  ,E.FirstDoseToday
	  ,E.firstUse
	  ,CASE WHEN T.Treatment IS NOT NULL THEN 'No'
	   ELSE ''
	   END AS calcFirstUse
	  ,T.Treatment AS pastTreatment
	  ,T.otherTreatment AS otherPastTreatment
	  ,E.TreatmentStatus
	  ,CASE WHEN ISNULL(E.startDate, '')='' AND E.TreatmentStatus='Prescribed Today' THEN CAST(E.VisitDate AS date)
	   ELSE CAST(E.startDate AS date)
	   END AS startDate
	  ,E.stopDate
	  ,CAST(T.startDate AS date) AS pastUseStartDate
	  ,CAST(T.stopDate AS date) AS pastUseStopDate
	  ,CASE WHEN ISNULL(T.stopDate, '')<>'' THEN DATEDIFF(mm, T.stopDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS MonthsSincePreviousStop
	  ,E.MonthsSinceStart
	  ,E.DaysSinceStart
	  ,E.BiologicNaive
	  ,CASE WHEN ISNULL(E.startDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.startDate >= T.stopDate
	     THEN DATEDIFF(dd, T.stopDate, E.startDate) 
       WHEN ISNULL(E.startDate, '')='' AND E.TreatmentStatus='Prescribed Today' THEN DATEDIFF(dd, T.startDate, E.VisitDate)
		ELSE CAST(NULL AS bigint) 
		END AS DaysInterrupted
	 ,CASE WHEN ISNULL(T.startDate, '')<>'' THEN DATEDIFF(mm, T.startDate, E.VisitDate)
	  ELSE CAST(NULL AS bigint)
	  END AS MonthsSincePastUseStart
	 ,CASE WHEN ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND DATEDIFF(dd, T.stopDate, E.VisitDate) >= 365 THEN 'Yes'
       WHEN E.TreatmentStatus='Current' AND ISNULL(E.startDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.startDate > T.stopDate AND DATEDIFF(dd, T.stopDate, E.startDate)<= 180 AND DATEDIFF(dd, T.stopDate, E.VisitDate) < 365 THEN 'Yes'
	   WHEN E.TreatmentStatus='Current' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.startDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.startDate)>180 AND DATEDIFF(dd, T.stopDate, E.startDate) < 365 THEN 'No'
	   WHEN E.TreatmentStatus='Current' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '') <> '' AND E.startDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.startDate)<=180 AND DATEDIFF(dd, T.startDate, E.VisitDate) >= 365 THEN 'No'
       WHEN E.TreatmentStatus='Prescribed Today' AND ISNULL(E.VisitDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate AND DATEDIFF(dd, T.stopDate, E.VisitDate)<= 180 AND DATEDIFF(dd, T.stopDate, E.VisitDate)<365 THEN 'Yes'
	   WHEN E.TreatmentStatus='Prescribed Today' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.VisitDate)>180 AND DATEDIFF(dd, T.stopDate, E.VisitDate) < 365 THEN 'No'
	   WHEN E.TreatmentStatus='Prescribed Today' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.VisitDate)<=180 AND DATEDIFF(dd, T.startDate, E.VisitDate) >= 365 THEN 'No'
	   WHEN ISNULL(T.Treatment, '')<>'' AND (ISNULL(T.stopDate, '')='' OR ISNULL(T.startDate, '')='') THEN 'Unknown'
	   ELSE ''
	   END AS AllowedPreviousUse
 
INTO #INTERRUPT
FROM #ET2 E 
LEFT JOIN [Reporting].[PSO500].[t_op_AllDrugs] T ON T.VisitId=E.VisitId AND T.Treatment=E.Treatment AND T.otherTreatment=E.otherTreatment AND T.TreatmentStatus='Past' 
WHERE E.TreatmentStatus IN ('Current', 'Prescribed Today', 'Changes Prescribed') AND ISNULL(T.Treatment, '')<>''

--SELECT * FROM #INTERRUPT ORDER BY SiteID, SubjectID, VisitID, currentTreatment



/***Determine if treatments were started during interruption if interruption was less than 180 days***/

IF OBJECT_ID('tempdb.dbo.#TRXMTBETWEEN') IS NOT NULL BEGIN DROP TABLE #TRXMTBETWEEN END;

SELECT DISTINCT I.VisitId
      ,I.PatientId
	  ,I.SiteID
	  ,I.SubjectID
	  ,I.VisitType
	  ,I.ProviderID
	  ,I.BirthDate
	  ,I.SUB_BirthDate
	  ,I.VisitDate
	  ,I.AgeAtEnrollment
	  ,I.SUB_Age
	  ,I.DiagnosisYear
	  ,I.EligVersion
	  ,I.crfStatus
	  ,I.currentTreatment AS Treatment
	  ,I.otherCurrentTreatment AS otherTreatment
	  ,I.FirstDoseToday
	  ,I.firstUse
	  ,I.calcFirstUse
	  ,I.TreatmentStatus
	  ,I.startDate
	  ,I.pastUseStartDate
	  ,I.MonthsSinceStart
	  ,I.DaysSinceStart
	  ,I.BiologicNaive
	  ,I.stopDate
	  ,I.pastUseStopDate
	  ,I.DaysInterrupted
	  ,I.MonthsSincePastUseStart
	  ,CASE WHEN EXISTS (SELECT T.Treatment FROM [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=I.VisitID AND T.Treatment<>I.currentTreatment AND I.DaysInterrupted < 180 AND ISNULL(T.startDate, '')<>'' AND I.TreatmentStatus IN ('Current', 'Prescribed Today') AND CAST(T.startDate AS date) BETWEEN I.stopDate AND I.startDate) THEN 'Yes'
	   ELSE 'No'
	   END AS trxmtBetween
	  ,(SELECT T.Treatment FROM [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=I.VisitID AND T.Treatment<>I.currentTreatment AND I.DaysInterrupted < 180 AND ISNULL(T.startDate, '')<>'' AND I.TreatmentStatus IN ('Current', 'Prescribed Today') AND CAST(T.startDate AS date) BETWEEN I.stopDate AND I.startDate) AS TreatmentBetweenName

INTO #TRXMTBETWEEN
FROM #INTERRUPT I
WHERE DaysInterrupted<=180


--SELECT * FROM #TRXMTBETWEEN ORDER BY SiteID, SubjectID


/***************Determine drug eligibility and DOI***************/

IF OBJECT_ID('tempdb.dbo.#DOI') IS NOT NULL BEGIN DROP TABLE #DOI END;

SELECT DISTINCT ET.VisitId
      ,ET.PatientId
	  ,ET.SiteID
	  ,ET.SubjectID
	  ,ET.VisitType
	  ,ET.ProviderID
	  ,ET.BirthDate
	  ,ET.SUB_BirthDate
	  ,ET.VisitDate
	  ,ET.AgeAtEnrollment
	  ,ET.SUB_Age
	  ,ET.DiagnosisYear
	  ,ET.EligVersion
	  ,ET.crfStatus
	  ,ET.Treatment
	  ,ET.otherTreatment
	  ,ET.FirstDoseToday
	  ,ET.firstUse
	  ,ET.calcFirstUse
	  ,ET.TreatmentType
	  ,ET.DOIType
	  ,ET.TreatmentStatus
	  ,ET.EligibleTreatmentStatus
	  ,CASE WHEN ET.EligVersion=3 AND ET.EligibleTreatment='Eligible' AND ET.TreatmentType='Non-Biologic' AND ET.BiologicNaive='No' THEN 'Not eligible'
       ELSE ET.EligibleTreatment	  
	   END AS EligibleTreatment
	  ,ET.TreatmentStatusHierarchy
	  ,ET.DrugHierarchy
	  ,ET.startDate
	  ,I.pastUseStartDate
	  ,ET.MonthsSinceStart
	  ,ET.DaysSinceStart
	  ,ET.BiologicNaive
	  ,ET.stopDate
	  ,I.pastUseStopDate
	  ,I.MonthsSincePreviousStop
	  ,I.DaysInterrupted
  	  ,I.MonthsSincePastUseStart
	  ,TB.trxmtBetween

INTO #DOI
FROM #ET2 ET 
LEFT JOIN #INTERRUPT I ON I.VisitId=ET.VisitId AND I.currentTreatment=ET.Treatment AND I.otherCurrentTreatment=ET.otherTreatment AND I.TreatmentStatus=ET.TreatmentStatus
LEFT JOIN #TRXMTBETWEEN TB ON TB.VisitId=ET.VisitId AND TB.Treatment=ET.Treatment AND TB.otherTreatment=ET.otherTreatment AND TB.TreatmentStatus=ET.TreatmentStatus

--SELECT * FROM #DOI ORDER BY SiteID, SubjectID

/******************Determine Eligibility**************************/

IF OBJECT_ID('tempdb.dbo.#EnrollEligibility') IS NOT NULL BEGIN DROP TABLE #EnrollEligibility END;

SELECT DISTINCT DOI.VisitId
      ,DOI.PatientId
	  ,DOI.SiteID
	  ,DOI.SubjectID
	  ,DOI.VisitType
	  ,DOI.ProviderID
	  ,DOI.BirthDate
	  ,DOI.SUB_BirthDate
	  ,DOI.VisitDate
	  ,DOI.AgeAtEnrollment
	  ,DOI.SUB_Age
	  ,DOI.DiagnosisYear
	  ,DOI.EligVersion
	  ,DOI.crfStatus
	  ,CASE WHEN DOI.crfStatus='No Data' THEN 'No Data'
	   WHEN DOI.TreatmentStatus='Past' THEN 'Past use only'
	   ELSE DOI.Treatment
	   END AS Treatment
	  ,DOI.otherTreatment
	  ,DOI.DrugHierarchy
	  ,DOI.FirstDoseToday
	  ,DOI.firstUse
	  ,DOI.calcFirstUse
	  ,CASE WHEN firstUse='Yes' THEN ''
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND firstUse='No' AND calcFirstUse='Yes' AND crfStatus NOT IN ('Incomplete', 'No data') AND ISNULL(pastUseStopDate, '')='' THEN 'Yes'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND firstUse='No' AND calcFirstUse='Yes' AND crfStatus IN ('Incomplete', 'No data') AND ISNULL(pastUseStopDate, '')='' THEN 'Unknown'
	   WHEN DOI.TreatmentStatus IN ('Prescribed Today') AND calcFirstUse='No' AND ISNULL(pastUseStopDate, '')<>'' and DaysInterrupted>365 THEN 'Yes'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND calcFirstUse='No' AND DaysInterrupted>365 THEN 'Yes'
	   WHEN DOI.TreatmentStatus IN ('Changes Prescribed', 'Current', 'Changes Prescribed') AND calcFirstUse='No' AND DaysInterrupted <= 180 AND MonthsSincePastUseStart<12 AND trxmtBetween='No' THEN 'Yes'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND calcFirstUse='No' AND DaysInterrupted<=180 AND MonthsSincePastUseStart<12 AND trxmtBetween='Yes' THEN 'No'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND calcFirstUse='No' AND DaysInterrupted BETWEEN 181 AND 365 THEN 'No'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND calcFirstUse='No' AND DaysInterrupted<=180 AND MonthsSincePastUseStart >= 12 THEN 'No'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND calcFirstUse='No' AND ISNULL(pastUseStartDate, '')='' AND ISNULL(pastUseStopDate, '')<>'' AND DaysInterrupted<=180 THEN 'Unknown'
	   ELSE ''
	   END AS AllowedPreviousUse
	  ,BiologicNaive
	  ,DOI.TreatmentType
	  ,DOI.DOIType
	  ,CASE WHEN DOI.TreatmentStatus='Changes Prescribed' THEN 'Current'
	   ELSE DOI.TreatmentStatus
	   END AS TreatmentStatus
	  ,DOI.EligibleTreatmentStatus
	  ,CASE WHEN DOI.EligibleTreatmentStatus='Not eligible' THEN 'Not eligible'
	   ELSE DOI.EligibleTreatment
	   END AS EligibleTreatment
	  ,DOI.startDate
	  ,DOI.pastUseStartDate
	  ,DOI.MonthsSinceStart
	  ,DOI.DaysSinceStart
	  ,DOI.stopDate
	  ,DOI.pastUseStopDate
	  ,DOI.DaysInterrupted
	  ,DOI.MonthsSincePastUseStart
	  ,DOI.MonthsSincePreviousStop
	  ,DOI.trxmtBetween

	  ,CASE WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND EligibleTreatment='Eligible' AND DOI.DaysSinceStart<=365 THEN 'Met'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND EligibleTreatment='Eligible' AND DOI.DaysSinceStart > 365 THEN 'Not met'
	   WHEN DOI.TreatmentStatus IN ('Current', 'Changes Prescribed') AND EligibleTreatment='Eligible' AND DOI.DaysSinceStart IS NULL THEN 'Unknown'
	   WHEN DOI.TreatmentStatus NOT IN ('Current', 'Changes Prescribed') THEN ''
	   WHEN DOI.EligibleTreatment='Not Eligible' THEN ''
	   ELSE ''
	   END AS TwelveMonthInitiationRule

INTO #EnrollEligibility
FROM #DOI DOI


--SELECT * FROM #EnrollEligibility ORDER BY SiteID, SubjectID

/******************Find Exited Subjects**************************/

IF OBJECT_ID('tempdb.dbo.#EX') IS NOT NULL BEGIN DROP TABLE #EX END;

SELECT DISTINCT [Site ID]
      ,[SubjectID]
      ,VisitDate AS [ExitDate]
      ,[Exit Reason]
INTO #EX
FROM [Reporting].[PSO500].[v_op_ExitReport]

--SELECT * FROM [Reporting].[PSO500].[v_op_ExitReport]

/******************Find First FU after enrollment and Treatment at FU**************************/

IF OBJECT_ID('tempdb.dbo.#FirstFU') IS NOT NULL BEGIN DROP TABLE #FirstFU END;

SELECT  DISTINCT EE.VisitId AS EnrollVisitId
       ,EE.PatientId
	   ,EE.SiteID
	   ,EE.SubjectID
	   ,EE.VisitType
	   ,EE.ProviderID
	   ,EE.BirthDate
	   ,EE.SUB_BirthDate
	   ,EE.VisitDate AS EnrollDate
	   ,EE.AgeAtEnrollment
	   ,EE.SUB_Age
	   ,COALESCE(EE.AgeAtEnrollment, EE.SUB_Age) AS calcAge
	   ,EE.DiagnosisYear
	   ,EE.EligVersion
	   ,EE.crfStatus
	   ,EE.Treatment
	   ,EE.otherTreatment
	   ,CASE WHEN ISNULL(EE.otherTreatment, '')<>'' THEN EE.Treatment + '-' + EE.otherTreatment
	    ELSE EE.Treatment
		END AS DOI
	   ,EE.DrugHierarchy
	   ,EE.FirstDoseToday
	   ,EE.firstUse
	   ,EE.calcFirstUse
	   ,EE.AllowedPreviousUse
	   ,EE.BiologicNaive
	   ,EE.TreatmentType
	   ,EE.DOIType
	   ,EE.TreatmentStatus
	   ,EE.EligibleTreatmentStatus
	   ,EE.EligibleTreatment
	   ,EE.startDate
	   ,EE.stopDate
	   ,EE.pastUseStartDate
	   ,EE.pastUseStopDate
	   ,EE.MonthsSinceStart
	   ,EE.DaysSinceStart
	   ,EE.DaysInterrupted
	   ,EE.trxmtBetween
	   ,EE.MonthsSincePastUseStart
	   ,EE.TwelveMonthInitiationRule
	   ,VL.VisitID AS FUVisitId
	   ,CAST(VL.VisitDate AS date) AS FUVisitDate

	   ,CASE WHEN EE.TreatmentStatus='Prescribed Today' AND EXISTS (SELECT T.Treatment FROM [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment AND ISNULL(T.stopDate, '')<>'' AND T.stopDate>EE.VisitDate) THEN 'Confirmed'
	   WHEN EE.TreatmentStatus='Prescribed Today' AND EXISTS (SELECT T.Treatment FROM  [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment AND ISNULL(T.stopDate, '')<>'' AND T.stopDate=EE.VisitDate) THEN 'Drug not started'
	    WHEN EE.TreatmentStatus='Prescribed Today' AND EXISTS (SELECT T.Treatment FROM  [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment AND ISNULL(T.startDate, '')<>'' AND T.startDate>=EE.VisitDate) THEN 'Confirmed'
		WHEN EE.TreatmentStatus='Prescribed Today' AND EXISTS (SELECT T.Treatment FROM  [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment AND ISNULL(T.stopDate, '')='' AND T.TreatmentStatus<>'Unknown') THEN 'Confirmed'
		WHEN EE.TreatmentStatus='Prescribed Today' AND EXISTS (SELECT T.Treatment FROM  [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment AND ISNULL(T.stopDate, '')='' AND T.TreatmentStatus='Unknown') THEN 'Needs review'
	    WHEN EE.TreatmentStatus='Prescribed Today' AND ISNULL(VL.VisitDate, '')='' AND EE.SubjectID IN (SELECT SubjectID FROM #EX) THEN 'Drug not started'
		WHEN EE.TreatmentStatus='Prescribed Today' AND ISNULL(VL.VisitDate, '')<>'' AND NOT EXISTS (SELECT T.Treatment FROM  [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment) THEN 'Drug not started'
		WHEN EE.TreatmentStatus='Prescribed Today' AND ISNULL(VL.VisitDate, '')='' AND EE.SubjectID NOT IN (SELECT SubjectID FROM #EX) THEN 'Pending'
		WHEN EE.TreatmentStatus='Prescribed Today' AND EXISTS (SELECT T.Treatment FROM  [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=VL.VisitId AND T.Treatment=EE.Treatment AND T.otherTreatment=EE.otherTreatment AND ISNULL(T.stopDate, '')<>'' AND CAST(T.stopDate AS date)<CAST(EE.VisitDate AS date)) THEN 'Error-stop date prior to prescribed date'
	    ELSE 'n/a'
		END AS InitiationStatus

INTO #FirstFU   
FROM #EnrollEligibility EE
LEFT JOIN [Reporting].[PSO500].[v_op_VisitLog] VL ON VL.SiteID=EE.SiteID and VL.SubjectID=EE.SubjectID AND VL.VisitType='Follow-up' AND VL.CalcVisitSequence=1

--SELECT * FROM #FirstFU FFU where SubjectID IN (45031070126, 45161350091) AND Treatment='apremilast {Otezla}' ORDER BY SiteID, SubjectID



/******************Find Registry Enrollment Status**************************/

IF OBJECT_ID('tempdb.dbo.#RES') IS NOT NULL BEGIN DROP TABLE #RES END;

SELECT DISTINCT FFU.EnrollVisitId
       ,FFU.PatientId
	   ,FFU.SiteID
	   ,FFU.SubjectID
	   ,FFU.VisitType
	   ,FFU.ProviderID
	   ,FFU.BirthDate
	   ,FFU.SUB_BirthDate
	   ,FFU.EnrollDate
	   ,FFU.AgeAtEnrollment
	   ,FFU.SUB_Age
	   ,FFU.calcAge
	   ,FFU.DiagnosisYear
	   ,FFU.EligVersion
	   ,FFU.crfStatus
	   ,FFU.Treatment
	   ,FFU.otherTreatment
	   ,FFU.DOI
	   ,FFU.DrugHierarchy
	   ,FFU.FirstDoseToday
	   ,FFU.firstUse
	   ,FFU.calcFirstUse
	   ,FFU.AllowedPreviousUse
	   ,FFU.BiologicNaive
	   ,FFU.TreatmentType
	   ,FFU.DOIType
	   ,FFU.TreatmentStatus
	   ,FFU.EligibleTreatmentStatus
	   ,FFU.EligibleTreatment
	   ,FFU.startDate
	   ,FFU.stopDate
	   ,FFU.pastUseStartDate
	   ,FFU.pastUseStopDate
	   ,FFU.MonthsSinceStart
	   ,FFU.DaysSinceStart
	   ,FFU.DaysInterrupted
	   ,FFU.trxmtBetween
	   ,FFU.MonthsSincePastUseStart
	   ,FFU.TwelveMonthInitiationRule
	   ,FFU.FUVisitId
	   ,FUVisitDate
	   ,FFU.InitiationStatus

	  ,CASE WHEN FFU.TreatmentStatus='Prescribed Today' AND FFU.InitiationStatus='Confirmed' AND ISNULL(FirstDoseToday, '') IN ('', 'No') THEN (SELECT MIN(startDate) FROM [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitId=FFU.FUVisitId AND T.Treatment=FFU.Treatment AND T.otherTreatment=FFU.otherTreatment AND ISNULL(T.startDate, '')<>'')  
	   WHEN FFU.TreatmentStatus='Prescribed Today' AND FFU.InitiationStatus IN ('Error-stop date prior to prescribed date', 'Needs reveiw') AND ISNULL(FirstDoseToday, '') IN ('', 'No') THEN CAST(NULL AS date)
	   WHEN FFU.TreatmentStatus='Prescribed Today' AND FFU.InitiationStatus IN ('Confirmed') AND ISNULL(FirstDoseToday, '')='Yes' THEN FFU.EnrollDate
	   WHEN FFU.TreatmentStatus='Prescribed Today' AND FFU.InitiationStatus IN ('Pending', 'Drug not started') THEN CAST(NULL AS date)
	   END AS DrugStartDateConfirmation

	  ,CASE WHEN FFU.DOI='Investigational Agent' THEN 'Not eligible'
	   WHEN FFU.DOI='adalimumab {Humira}' AND EnrollDate BETWEEN '2021-06-28' AND '2022-01-01' THEN 'Not eligible'
	   WHEN FFU.DOI='adalimumab {Humira}' AND startDate BETWEEN '2021-06-28' AND '2022-01-01' THEN 'Not eligible'
	   WHEN FFU.DOI='No Data' THEN 'Needs review'
	   WHEN EligibleTreatment='Not eligible' THEN 'Not eligible'
	   WHEN ISNULL(calcAge, '')='' THEN 'Needs review'
	   WHEN TreatmentStatus='' THEN 'Needs Review'
	   WHEN FFU.EligibleTreatmentStatus='Not eligible' THEN 'Not eligible'
	   WHEN FFU.EligibleTreatmentStatus='Pending' THEN 'Needs review'
	   WHEN FFU.EligibleTreatmentStatus='Needs review-TI' THEN 'Needs review'
	   WHEN FFU.DOI LIKE '%Other%' THEN 'Needs review'
	   WHEN FFU.TreatmentStatus='Current' AND FFU.EligibleTreatmentStatus='Eligible' AND FFU.TwelveMonthInitiationRule='Unknown ' THEN 'Needs review'
	   WHEN FFU.DOI='Past use only' THEN 'Not eligible'
	   WHEN FFU.DOI='No treatment' THEN 'Not eligible'
	   WHEN FFU.TreatmentStatus='Stopped Today' THEN 'Not eligible'
	   WHEN FFU.TreatmentStatus='Past' THEN 'Not eligible'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed Today' AND InitiationStatus='Drug not started' THEN 'Eligible'
	   WHEN TreatmentStatus='Current' AND TwelveMonthInitiationRule='Not met' THEN 'Not eligible'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed Today' AND InitiationStatus IN ('Pending', 'Confirmed', 'Needs review') THEN 'Eligible'
       WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed Today' AND (firstUse='Yes') OR (firstUse='' AND calcFirstUse='Yes') OR (firstUse='No' AND AllowedPreviousUse='Yes') THEN 'Eligible'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' AND (firstUse='Yes') OR (firstUse='' AND calcFirstUse='Yes') OR (firstUse='No' AND AllowedPreviousUse='Yes') THEN 'Eligible'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed Today' AND firstUse='No' AND calcFirstUse='Yes' THEN 'Eligible'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' AND firstUse='No' AND calcFirstUse='Yes' THEN 'Eligible'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed Today' AND firstUse='No' AND calcFirstUse='No' AND AllowedPreviousUse='Unknown' THEN 'Needs review'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' AND firstUse='No' AND calcFirstUse='No' AND AllowedPreviousUse='Unknown' THEN 'Needs review'
	   WHEN calcAge>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Unknown' THEN 'Needs review'
	   WHEN firstUse='No' AND AllowedPreviousUse='No' THEN 'Not eligible'
	   WHEN calcAge <=17 THEN 'Not eligible'
	   WHEN TwelveMonthInitiationRule='Not met' THEN 'Not eligible'
	   ELSE '' 
	   END AS RegistryEnrollmentStatus

INTO #RES 
FROM #FirstFU FFU

--SELECT * FROM #RES ORDER BY SiteID, SubjectID, DrugHierarchy



/******************Determine Eligibility Hierarchy**************************/

IF OBJECT_ID('tempdb.dbo.#EligHierarchy') IS NOT NULL BEGIN DROP TABLE #EligHierarchy END;

SELECT EnrollVisitId
      ,PatientId
	  ,SiteID
	  ,SubjectID
	  ,VisitType
	  ,ProviderID
	  ,BirthDate
	  ,EnrollDate
	  ,AgeAtEnrollment
	  ,calcAge
	  ,DiagnosisYear
	  ,EligVersion
	  ,crfStatus
	  ,Treatment
	  ,otherTreatment
	  ,DOI
	  ,FirstDoseToday
	  ,firstUse
	  ,calcFirstUse
	  ,AllowedPreviousUse
	  ,BiologicNaive
	  ,TreatmentType
	  ,DOIType
	  ,TreatmentStatus
	  ,EligibleTreatmentStatus
	  ,EligibleTreatment
	  ,startDate
	  ,stopDate
	  ,pastUseStartDate
	  ,pastUseStopDate
	  ,MonthsSinceStart
	  ,DaysSinceStart
	  ,DaysInterrupted
	  ,trxmtBetween
	  ,MonthsSincePastUseStart
	  ,TwelveMonthInitiationRule
	  ,FUVisitId
	  ,CASE WHEN RegistryEnrollmentStatus IN ('Not eligible', 'Needs review') AND EligibilityReview='Not eligible - Exception granted' THEN 'Eligible - by Override'
	   WHEN RegistryEnrollmentStatus IN ('Not eligible', 'Needs review') AND EligibilityReview='Eligible' THEN 'Eligible - by Override'
	   WHEN RegistryEnrollmentStatus='Eligible' AND EligibilityReview='Not eligible' THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus='Needs review' AND EligibilityReview='Not eligible' THEN 'Not eligible'
	   WHEN RegistryEnrollmentStatus='Needs review' AND EligibilityReview IN ('Eligible', 'Not eligible - Exception granted') THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus='Not eligible' AND EligibilityReview='Not eligible' THEN 'Not eligible - Confirmed'
	   ELSE RegistryEnrollmentStatus
	   END AS RegistryEnrollmentStatus
	  ,DrugHierarchy
	  ,EnrollStatusHierarchy
	  ,InitiationStatusHierarchy
	  ,FUVisitDate
	  ,DrugStartDateConfirmation
	  ,InitiationStatus
	  ,EligibilityReview

INTO #EligHierarchy
FROM
(
SELECT  DISTINCT RES.EnrollVisitId
       ,RES.PatientId
	   ,RES.SiteID
	   ,RES.SubjectID
	   ,RES.VisitType
	   ,RES.ProviderID
	   ,RES.BirthDate
	   ,RES.EnrollDate
	   ,RES.AgeAtEnrollment
	   ,RES.calcAge
	   ,RES.DiagnosisYear
	   ,RES.EligVersion
	   ,RES.crfStatus
	   ,RES.Treatment
	   ,RES.otherTreatment
	   ,RES.DOI
	   ,RES.FirstDoseToday
	   ,RES.firstUse
	   ,RES.calcFirstUse
	   ,RES.AllowedPreviousUse
	   ,RES.BiologicNaive
	   ,RES.TreatmentType
	   ,RES.DOIType
	   ,RES.TreatmentStatus
	   ,RES.EligibleTreatmentStatus
	   ,RES.EligibleTreatment
	   ,RES.startDate
	   ,RES.stopDate
	   ,RES.pastUseStartDate
	   ,RES.pastUseStopDate
	   ,RES.MonthsSinceStart
	   ,RES.DaysSinceStart
	   ,RES.DaysInterrupted
	   ,RES.trxmtBetween
	   ,RES.MonthsSincePastUseStart
	   ,RES.TwelveMonthInitiationRule
	   ,RES.FUVisitId
	   ,RegistryEnrollmentStatus
	   ,RES.DrugHierarchy
	   ,CASE WHEN RES.RegistryEnrollmentStatus='Eligible' THEN 10
	    WHEN RES.RegistryEnrollmentStatus IN ('Not eligible', 'Needs review') AND ELG.[ELGEN_ineligible_en]='Yes' THEN 10
	    WHEN RES.RegistryEnrollmentStatus='Eligible-not started' THEN 15
	    WHEN RES.RegistryEnrollmentStatus='Needs review' THEN 50
		WHEN RES.RegistryEnrollmentStatus='Not eligible' AND ELG.[ELGEN_ineligible_en]='Under Review (Outcome TBD)' THEN 50
		WHEN RES.RegistryEnrollmentStatus='Pending' THEN 70
		WHEN RES.RegistryEnrollmentStatus='Not eligible' THEN 80
		ELSE 90
		END AS EnrollStatusHierarchy
	  ,CASE WHEN RES.InitiationStatus='Confirmed' THEN 10
	   WHEN RES.InitiationStatus='Pending' THEN 20
	   WHEN RES.EligibleTreatment='Eligible' AND RegistryEnrollmentStatus='Eligible' THEN 10
	   WHEN RES.InitiationStatus='Needs review' THEN 35
	   WHEN RES.InitiationStatus='Drug not started' THEN 60
	   WHEN RES.EligibleTreatment='Eligible' AND RegistryEnrollmentStatus='Not eligible' THEN 65
	   WHEN RES.EligibleTreatment='Not eligible' AND RES.InitiationStatus='n/a' THEN 70
	   WHEN RES.InitiationStatus LIKE 'Error%' THEN 80
	   ELSE 90
	   END AS InitiationStatusHierarchy
	  ,RES.FUVisitDate
	  ,RES.DrugStartDateConfirmation
	  ,RES.InitiationStatus
	  ,CASE WHEN ELG.[ELGEN_ineligible_en]='No' AND ELG.[ELGEN_ineligible_en_exception]='Yes' THEN 'Not eligible - Exception granted'
	   WHEN ELG.[ELGEN_ineligible_en]='Under Review (Outcome TBD)' THEN 'Under Review (Outcome TBD)'
	   WHEN ELG.[ELGEN_ineligible_en]='No' AND ELG.[ELGEN_ineligible_en_exception] IN ('No', '') THEN 'Not eligible'
	   WHEN ELG.[ELGEN_ineligible_en]='Yes' THEN 'Eligible'
	   ELSE''
	   END AS EligibilityReview

FROM #RES RES
LEFT JOIN [OMNICOMM_PSO].[inbound].[ELG] ELG ON RES.SiteID=ELG.[Site Object SiteNo] AND RES.SubjectID=ELG.[Patient Object PatientNo] AND ELG.[Visit Object ProCaption]='Enrollment' AND ELG.VisitId=RES.EnrollVisitId AND ELG.[Site Object SiteNo] NOT IN (997, 998, 999)
) B




/******************Determine Eligibility**************************/

IF OBJECT_ID('tempdb.dbo.#FinalElig') IS NOT NULL BEGIN DROP TABLE #FinalElig END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY EH.EnrollVisitId, EH.SiteID, EH.SubjectID ORDER BY EH.SiteID, EH.SubjectID, EH.EnrollStatusHierarchy, EH.DrugHierarchy, EH.InitiationStatusHierarchy, EH.StartDate DESC, EH.Treatment) AS ROWNUM
      ,EH.EnrollVisitId
      ,EH.PatientId
	  ,EH.SiteID
	  ,EH.SubjectID
	  ,EH.VisitType
	  ,EH.ProviderID
	  ,EH.BirthDate
	  ,EH.EnrollDate
	  ,EH.AgeAtEnrollment
	  ,EH.calcAge
	  ,EH.DiagnosisYear
	  ,EH.EligVersion
	  ,EH.crfStatus
	  ,EH.Treatment
	  ,EH.otherTreatment
	  ,EH.DOI
	  ,EH.EligibleTreatment
	  ,EH.FirstDoseToday
	  ,EH.firstUse
	  ,EH.calcFirstUse
	  ,EH.AllowedPreviousUse
	  ,EH.BiologicNaive
	  ,CASE WHEN EXISTS (SELECT startDate FROM #EligHierarchy E WHERE E.EnrollVisitId=EH.EnrollVisitId AND E.Treatment<>EH.Treatment AND E.TreatmentType='Biologic' AND E.startDate>EH.startDate AND EH.RegistryEnrollmentStatus IN ('Eligible', 'Needs Review')) THEN 'Yes'
	   ELSE ''
	   END AS additionalStartDate
	  ,EH.TreatmentType
	  ,EH.DOIType
	  ,EH.TreatmentStatus
	  ,EH.startDate
	  ,EH.stopDate
	  ,EH.pastUseStartDate
	  ,EH.pastUseStopDate
	  ,EH.MonthsSinceStart
	  ,EH.DaysSinceStart
	  ,EH.DaysInterrupted
	  ,EH.trxmtBetween
	  ,EH.MonthsSincePastUseStart
	  ,EH.TwelveMonthInitiationRule
	  ,EH.FUVisitId
	  ,EH.DrugHierarchy
	  ,EH.RegistryEnrollmentStatus	   
	  ,EH.EnrollStatusHierarchy
	  ,EH.FUVisitDate
	  ,EH.DrugStartDateConfirmation
	  ,EH.InitiationStatus
	  ,EH.InitiationStatusHierarchy
	  ,EH.EligibilityReview
	   
INTO #FinalElig
FROM #EligHierarchy EH

--SELECT * FROM #FinalElig WHERE EligibilityReview<>''

/*****Table for PSO Cohort Accrual Tracker (CAT)*****/

TRUNCATE TABLE [Reporting].[PSO500].[t_op_CAT];

INSERT INTO [Reporting].[PSO500].[t_op_CAT]
(
EnrollVisitId,
[PatientId],
SiteID,
SiteStatus,
SubjectID,
VisitType,
ProviderID,
BirthDate,
EnrollDate,
DiagnosisYear,
EligVersion,
crfStatus,
Treatment,
otherTreatment,
DOI,
EligibleTreatment,
FirstDoseToday,
firstUse,
calcFirstUse,
AllowedPreviousUse,
BiologicNaive,
additionalStartDate,
TreatmentType,
DOIType,
TreatmentStatus,
TwelveMonthInitiationRule,
startDate,
stopDate,
pastUseStartDate,
pastUseStopDate,
MonthsSinceStart,
DaysSinceStart,
DaysInterrupted,
trxmtBetween,
MonthsSincePastUseStart,
FUVisitId,
InitiationStatus,
DrugStartDateConfirmation,
RegistryEnrollmentStatus,
EligibilityReview
)

SELECT DISTINCT EnrollVisitId,
[PatientId],
FE.SiteID,
SS.SiteStatus,
SubjectID,
VisitType,
ProviderID,
BirthDate,
EnrollDate,
DiagnosisYear,
EligVersion,
crfStatus,
Treatment,
otherTreatment,
DOI,
EligibleTreatment,
FirstDoseToday,
firstUse,
calcFirstUse,
AllowedPreviousUse,
BiologicNaive,
additionalStartDate,
TreatmentType,
DOIType,
TreatmentStatus,
TwelveMonthInitiationRule,
CASE WHEN TreatmentStatus='Prescribed Today' AND DrugStartDateConfirmation IS NULL  AND InitiationStatus='Pending' THEN EnrollDate
WHEN TreatmentStatus='Prescribed Today' AND DrugStartDateConfirmation IS NOT NULL AND InitiationStatus='Confirmed' THEN DrugStartDateConfirmation
WHEN TreatmentStatus='Prescribed Today' AND InitiationStatus='Drug not started' THEN CAST(NULL AS date)
WHEN TreatmentStatus='Prescribed Today' AND InitiationStatus='Needs review' THEN CAST(NULL AS date)
ELSE startDate
END AS startDate,
stopDate,
pastUseStartDate,
pastUseStopDate,
MonthsSinceStart,
DaysSinceStart,
DaysInterrupted,
trxmtBetween,
MonthsSincePastUseStart,
FUVisitId,
InitiationStatus,
DrugStartDateConfirmation,

CASE WHEN additionalStartDate='Yes' AND EligibilityReview IN ('Under Review (Outcome TBD)') THEN 'Under Review (Outcome TBD)'
     ELSE RegistryEnrollmentStatus
	 END AS RegistryEnrollmentStatus,
EligibilityReview

FROM #FinalElig FE
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SS ON SS.SiteID=FE.SiteID
WHERE ROWNUM=1


---SELECT * FROM [Reporting].[PSO500].[t_op_CAT] WHERE Treatment='adalimumab {Humira}' ORDER BY SiteID, SubjectID, EnrollDate DESC
/*
/*****TABLE FOR PSO DASHBOARD*****/

TRUNCATE TABLE [Reporting].[PSO500].[t_EligDashboard];

INSERT INTO [Reporting].[PSO500].[t_EligDashboard]
(
	[Site ID],
	[Subject ID],
	[Eligible Treatment],
	[Enrollment Date]
)

 SELECT DISTINCT [SiteID] AS [Site ID]  
	   ,[SubjectID] AS [Subject ID]
	   ,DOI AS [Eligible Treatment]
	   ,[EnrollDate] AS [Enrollment Date]
FROM [Reporting].[PSO500].[t_op_CAT]
WHERE (RegistryEnrollmentStatus LIKE 'Eligible%')
AND [SiteID] not in (998, 999)

/*****TABLE FOR PSO VISITLOG FOR DASHBOARD*****/


 
TRUNCATE TABLE [Reporting].[PSO500].[t_VisitLog];

INSERT INTO [Reporting].[PSO500].[t_VisitLog] 
(
	   [SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[Month]
      ,[Year]
      ,[VisitType]
  )

SELECT DISTINCT [SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[Month]
      ,[Year]
      ,[VisitType]

FROM [Reporting].[PSO500].[v_op_VisitLog]
WHERE ISNULL(VisitDate, '') <> ''
AND VisitType IN ('Enrollment', 'Follow-up', 'Exit')
AND SiteID not in (997, 998, 999)
;
*/
END
GO
