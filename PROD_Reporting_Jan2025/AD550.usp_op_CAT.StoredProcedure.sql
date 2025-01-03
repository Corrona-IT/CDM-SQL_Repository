USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_CAT]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ==================================================================================
-- Author:		Kaye Mowrey
-- Updated:     04-Jan-2023
-- Description:	Procedure to create table for CAT for AD550
-- ==================================================================================


CREATE PROCEDURE [AD550].[usp_op_CAT] AS


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [Reporting].[AD550].[t_op_CAT]
(
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](10) NOT NULL,
	[SubjectID] [nvarchar] (30) NULL,
	[PatientID] [bigint] NULL,
	[PatientYOB] [int] NULL,
	[AgeAtEnrollment] [float] NULL,
	[OnsetAge] [float] NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](255) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[VisitEventOccurrence] [int] NULL,
	[VisitCompletion] [nvarchar](255) NULL,
	[eventId] [int] NULL,
	[eventOccurrence] [int] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[TreatmentName] [nvarchar](255) NULL,
	[OtherTreatment] [nvarchar](255) NULL,
	[TreatmentNameFull] [nvarchar](255) NULL,
	[EligibleTreatment] [nvarchar](255) NULL,
	[TreatmentStatus] [nvarchar](255) NULL,
	[DOIInitiationStatus] [nvarchar](255) NULL,
	[EligibilityHierarchy] [float] NULL,
	[SubscriberDOI] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[MonthsSinceStart] [float] NULL,
	[TwelveMonthInitiationRule] [nvarchar](255) NULL,
	[NoPriorUse] [int] NULL,
	[PastUse] [int] NULL,
	[CurrentUse] [int] NULL,
	[StopDate] [date] NULL,
	[RestartDate] [nvarchar](255) NULL,
	[CurrentDose] [nvarchar](255) NULL,
	[CurrentFrequency] [nvarchar](255) NULL,
	[PastDose] [nvarchar](255) NULL,
	[PastFrequency] [nvarchar](255) NULL,
	[EASI] [float] NULL,
	[EASIScoreStatus] [nvarchar] (30) NULL,
	[vigaad] [float] NULL,
	[RegistryEnrollmentStatus] [nvarchar](255) NULL,
	[RESHierarchy] [int] NULL,
	[FUTreatmentName] [nvarchar](255) NULL,
	[FUOtherTreatment] [nvarchar](255) NULL,
	[FUVisitDate] [nvarchar](255) NULL,
	[FUStartDate] [nvarchar](255) NULL,
	[ExitDate] [nvarchar](255) NULL,
	[EligibilityReview] [nvarchar](50) NULL,
	[notStarted] [int] NULL,
	[no_start_fu_name1] [nvarchar](250) NULL,
	[no_start_fu_name2] [nvarchar](250) NULL
) ON [PRIMARY];
*/
-----------------


/*****Get Enrollment Drugs*****/
IF OBJECT_ID('tempdb.dbo.#EnrollDrugs') IS NOT NULL BEGIN DROP TABLE #EnrollDrugs END;

SELECT DISTINCT SiteID,
       SubjectID,
	   PatientID,
	   PatientYOB,
	   AgeAtEnrollment,
	   OnsetAge,
	   ProviderID,
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   VisitEventOccurrence,
	   VisitCompletion,
	   eventId,
	   eventOccurrence,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   --EligibleTreatment,
	   ------------------------
	     CASE 
			WHEN VisitDate > '2023-11-05' 
			AND EXISTS(
        SELECT 1 
			FROM [Reporting].[AD550].[t_op_AllDrugs] AD 
			WHERE AD.VisitType='Enrollment' 
			AND AD.SubjectID=SubjectID 
			AND AD.TreatmentName=TreatmentName 
			-- and not equal to %OTHER%
			--AND AD.TreatmentStatus!=TreatmentStatus 
			AND AD.TreatmentStatus=TreatmentStatus 
			AND (AD.StopDate < VisitDate OR PastUse = 1)
		) THEN 'No'
		ELSE EligibleTreatment
	   END AS EligibleTreatment,
	   ---------------------------
	   TreatmentStatus,
	   DOIInitiationStatus,
	   CASE WHEN EligibleTreatment='Yes' AND AgeAtEnrollment>17 AND DOIInitiationStatus='Prescribed at visit' AND SubscriberDOI='Yes' THEN 10
	   WHEN EligibleTreatment='Yes' AND AgeAtEnrollment>17 AND DOIInitiationStatus='Continued' AND SubscriberDOI='Yes' AND TwelveMonthInitiationRule='Met' THEN 20
	   WHEN EligibleTreatment='Yes' AND AgeAtEnrollment>17 AND DOIInitiationStatus='Prescribed at visit' AND SubscriberDOI='No' THEN 30
	   WHEN EligibleTreatment='Yes' AND AgeAtEnrollment>17 AND DOIInitiationStatus='Continued' AND SubscriberDOI='No' AND TwelveMonthInitiationRule='Met' THEN 40
	   WHEN EligibleTreatment='Yes' AND ISNULL(AgeAtEnrollment, '')='' AND DOIInitiationStatus='Prescribed at visit' AND SubscriberDOI='Yes'THEN 50 -- Needs review
	   WHEN EligibleTreatment='Yes' AND (ISNULL(AgeAtEnrollment, '')='' OR TwelveMonthInitiationRule='Needs review') AND DOIInitiationStatus='Continued' AND SubscriberDOI='Yes' THEN 55 -- Needs review
	   WHEN EligibleTreatment='Yes' AND ISNULL(AgeAtEnrollment, '')='' AND DOIInitiationStatus='Prescribed at visit' AND SubscriberDOI='No'THEN 60 --Needs review
	   WHEN EligibleTreatment='Yes' AND DOIInitiationStatus IN ('Continued', 'Prescribed at visit') AND (ISNULL(AgeAtEnrollment, '')='' OR TwelveMonthInitiationRule='Needs review') AND DOIInitiationStatus='Continued' AND SubscriberDOI='No' AND TwelveMonthInitiationRule='Met' THEN 65 --Needs review
	   WHEN EligibleTreatment='Pending' THEN 68  --Needs review
	   WHEN (EligibleTreatment='No' OR AgeAtEnrollment<17 OR TwelveMonthInitiationRule='Not met' OR DOIInitiationStatus='Stopped') THEN 80
	   WHEN (TreatmentName IN ('No Treatment', 'No Data')) OR DOIInitiationStatus='Past use only' THEN 90
	   ELSE CAST(NULL AS int)
	   END AS EligibilityHierarchy,
	   SubscriberDOI,
	   StartDate,
	   MonthsSinceStart,
	   TwelveMonthInitiationRule,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StopDate,
	   RestartDate,
	   CurrentDose,
	   CurrentFrequency, 
	   PastDose,
	   PastFrequency,
	   EASI,
	   EASIScoreStatus,
	   [vigaad],
	   CASE WHEN TreatmentName='investigational drug (specify)' THEN 'Not eligible'
	     ---------------------------- New Logic  ------------------------------------------------------------------
	   WHEN VisitDate > '2023-11-05' AND (StopDate < VisitDate OR PastUse = 1) AND VisitType='Enrollment'  THEN 'Not eligible'
	   ----------------------------- -----------------------------------------------------------------------------
	   WHEN TreatmentName LIKE 'other%' AND VisitDate < '2022-01-01' THEN 'Needs review'
	   WHEN AgeAtEnrollment<=17 THEN 'Not eligible'
	   WHEN ISNULL(AgeAtEnrollment, '')='' THEN 'Needs review'
	   WHEN TreatmentName='Pending' THEN 'Needs review'
	   WHEN AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND TreatmentStatus='Start drug (or restart drug)'  THEN 'Eligible'
	   WHEN AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND DOIInitiationStatus='continued' AND TwelveMonthInitiationRule='Met' THEN 'Eligible'
	   WHEN VisitDate < '2023-01-01' AND (EligibleTreatment='No' OR TreatmentStatus='Not applicable (no longer in use)' OR TwelveMonthInitiationRule='Not met') AND ([vigaad] < 3 OR EASI < 12) THEN 'Not eligible'
	   WHEN VisitDate >= '2023-01-01' AND (EligibleTreatment='No' OR TreatmentStatus='Not applicable (no longer in use)' OR TwelveMonthInitiationRule='Not met') THEN 'Not eligible'
	   WHEN VisitDate < '2023-01-01' AND AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND DOIInitiationStatus='continued' AND TwelveMonthInitiationRule='Not met' AND ([vigaad] >=3 AND EASI >=12) THEN 'Eligible - Disease activity'
	   WHEN AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND DOIInitiationStatus='continued' AND TwelveMonthInitiationRule='Needs review' THEN 'Needs review'
	   WHEN VisitDate < '2023-01-01' AND AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND TreatmentStatus='Not applicable (no longer in use)' AND ([vigaad] >=3 AND EASI >=12) THEN 'Eligible - Disease activity'
	   WHEN VisitDate >= '2023-01-01' AND AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND TreatmentStatus='Not applicable (no longer in use)' AND ([vigaad] >=3 AND EASI >=12) THEN 'Not eligible'
	   WHEN AgeAtEnrollment>17 AND EligibleTreatment='No' AND [vigaad] >=3 AND EASI >=12 THEN 'Eligible - Disease activity'
	   WHEN VisitDate < '2023-01-01' AND (EligibleTreatment='No' OR TreatmentStatus='Not applicable (no longer in use)' OR TwelveMonthInitiationRule='Not met') AND ([vigaad] IS NULL OR EASI IS NULL) THEN 'Needs review'
	   WHEN VisitDate < '2023-01-01' AND VisitDate < '2023-01-01' AND AgeAtEnrollment>17 AND TreatmentName IN ('No Treatment', 'No Data') AND ([vigaad] >=3 AND EASI >=12) THEN 'Eligible - Disease activity'
	   WHEN VisitDate >= '2023-01-01' AND AgeAtEnrollment>17 AND TreatmentName IN ('No Treatment', 'No Data') THEN 'Not eligible'
	   WHEN VisitDate < '2023-01-01' AND TreatmentName IN ('No Treatment', 'No Data') AND ([vigaad] < 3 OR EASI < 12) THEN 'Not eligible'
	   WHEN VisitDate >= '2023-01-01' AND TreatmentName IN ('No Treatment', 'No Data') THEN 'Not eligible'
	   WHEN VisitDate < '2023-01-01' AND TreatmentName IN ('No Treatment', 'No Data') AND ([vigaad] IS NULL OR EASI IS NULL) THEN 'Needs review'
	   WHEN VisitDate < '01-01-2023' AND AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND TreatmentStatus='Stop/discontinue drug' AND ([vigaad] >=3 AND EASI >=12) THEN 'Eligible - Disease activity'
	   WHEN VisitDate < '2023-01-01' AND EligibleTreatment='Yes' AND TreatmentStatus='Stop/discontinue drug' AND ([vigaad] < 3 OR EASI < 12) THEN 'Not eligible'
	   WHEN  VisitDate >= '2023-01-01' AND TreatmentStatus='Stop/discontinue drug' THEN 'Not eligible'
	   ELSE 'NULL'
	   END AS RegistryEnrollmentStatus
	   ----
	 

INTO #EnrollDrugs
FROM
(
SELECT A.SiteID,
       A.SubjectID,
	   A.PatientID,
	   A.PatientYOB,
	   A.AgeAtEnrollment,
	   A.OnsetAge,
	   A.ProviderID,
	   A.VisitType,
	   A.VisitDate,
	   A.VisitSequence,
	   A.VisitEventOccurrence,
	   A.VisitCompletion,
	   A.eventId,
	   A.eventOccurrence,
	   A.eventCrfId,
	   A.crfOccurrence,
	   A.TreatmentName,
	   A.OtherTreatment,
	   A.TreatmentStatus,
	   A.DOIInitiationStatus,  
	   A.StartDate,
	   A.MonthsSinceStart,
	   A.TwelveMonthInitiationRule,
	   A.NoPriorUse,
	   A.PastUse,
	   A.CurrentUse,
	   A.StopDate,
	   A.RestartDate,
	   A.CurrentDose,
	   A.CurrentFrequency, 
	   A.PastDose,
	   A.PastFrequency,
	   A.EASI,
	   A.EASIScoreStatus,
	   A.[vigaad],
       CASE WHEN CATREF.DOIType='Subscriber' THEN 'Yes'
	   WHEN CATREF.DOIType='Registry' THEN 'No'
	   WHEN A.TreatmentName IN ('No Treatment', 'No Data') OR ISNULL(CATREF.DOIType, '')='' THEN 'n/a'
	   ELSE ''
	   END AS SubscriberDOI,
	   CASE WHEN A.TreatmentName=CATREF.TreatmentName AND A.VisitDate >= CATREF.EligStartDate AND A.VisitDate <= CATREF.EligEndDate THEN 'Yes'
	   WHEN A.TreatmentName IN ('No Treatment', 'No Data') THEN 'n/a'
	   WHEN (A.TreatmentName=CATREF.TreatmentName AND A.VisitDate < CATREF.EligStartDate) OR (A.VisitDate > CATREF.EligEndDate) THEN 'No'
	   WHEN ISNULL(CATREF.TreatmentName, '')='' THEN 'No'
	   ELSE ''
	   END AS EligibleTreatment
FROM 
(
SELECT DISTINCT AD.SiteID,
       AD.SubjectID,
	   AD.PatientID,
	   S.birthdate AS PatientYOB,
	   (DATEPART(yy, AD.VisitDate)-S.birthdate) AS AgeAtEnrollment,
	   CAST(P.[ageonset] AS float) as OnsetAge,
	   AD.ProviderID,
	   AD.VisitType,
	   AD.VisitDate,
	   AD.VisitSequence,
	   AD.VisitEventOccurrence,
	   AD.VisitCompletion,
	   AD.eventId,
	   AD.eventOccurrence,
	   AD.eventCrfId,
	   AD.crfOccurrence,
	   AD.TreatmentName,
	   AD.OtherTreatment,
	   AD.TreatmentStatus,
	   CASE WHEN AD.TreatmentStatus='Continue drug plan/no changes' THEN 'Continued'
	   WHEN AD.TreatmentStatus='Start drug (or restart drug)' THEN 'Prescribed at visit'
	   WHEN AD.TreatmentStatus='Stop/discontinue drug' THEN 'Stopped'
	   WHEN AD.TreatmentStatus='Not applicable (no longer in use)' THEN 'Past use only'
	   WHEN AD.TreatmentStatus='Modify dose or frequency' THEN 'Continued'
	   ELSE ''
	   END AS DOIInitiationStatus,  
	   AD.StartDate,
	   CASE WHEN ISNULL(StartDate, '')<>'' AND AD.TreatmentStatus='Continue drug plan/no changes' THEN DATEDIFF(MONTH, AD.StartDate, AD.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS MonthsSinceStart,
	   CASE WHEN ISNULL(StartDate, '')<>'' AND AD.TreatmentStatus='Continue drug plan/no changes' AND DATEDIFF(MONTH, AD.StartDate, AD.VisitDate)<=12 THEN 'Met'
	   WHEN ISNULL(StartDate, '')<>'' AND AD.TreatmentStatus='Modify dose or frequency' AND DATEDIFF(MONTH, AD.StartDate, AD.VisitDate)<=12 THEN 'Met'
	   WHEN ISNULL(RestartDate, '')<>'' AND AD.TreatmentStatus='Continue drug plan/no changes' AND DATEDIFF(MONTH, AD.ReStartDate, AD.VisitDate)<=12 THEN 'Met'
	   WHEN ISNULL(RestartDate, '')<>'' AND AD.TreatmentStatus='Modify dose or frequency' AND DATEDIFF(MONTH, AD.ReStartDate, AD.VisitDate)<=12 THEN 'Met'
	   WHEN ISNULL(StartDate, '')<>'' AND AD.TreatmentStatus='Continue drug plan/no changes' AND DATEDIFF(MONTH, AD.StartDate, AD.VisitDate)>12 THEN 'Not met'
	   WHEN ISNULL(StartDate, '')<>'' AND AD.TreatmentStatus='Modify dose or frequency' AND DATEDIFF(MONTH, AD.StartDate, AD.VisitDate)>12 THEN 'Not met'
	   WHEN ISNULL(StartDate, '')='' AND AD.TreatmentStatus='Continue drug plan/no changes' THEN 'Needs review'
	   WHEN ISNULL(StartDate, '')='' AND AD.TreatmentStatus='Modify dose or frequency' THEN 'Needs review'
	   ELSE 'n/a'
	   END AS TwelveMonthInitiationRule,
	   AD.NoPriorUse,
	   AD.PastUse,
	   AD.CurrentUse,
	   AD.StopDate,
	   AD.RestartDate,
	   AD.CurrentDose,
	   AD.CurrentFrequency, 
	   AD.PastDose,
	   AD.PastFrequency,
	   E.EASI,
	   CASE WHEN ([headneck_regionscore] IS NOT NULL OR [trunkback_regionscore] IS NOT NULL OR [arms_regionscore] IS NOT NULL OR [legsbuttocks_regionscore] IS NOT NULL) AND ([headneck_regionscore] IS NULL OR [trunkback_regionscore] IS NULL OR [arms_regionscore] IS NULL OR [legsbuttocks_regionscore] IS NULL) THEN 'incomplete'
	   WHEN [headneck_regionscore] IS NULL AND [trunkback_regionscore] IS NULL AND [arms_regionscore] IS NULL AND [legsbuttocks_regionscore] IS NULL THEN 'missing'
	   WHEN [headneck_regionscore] IS NOT NULL AND [trunkback_regionscore] IS NOT NULL AND [arms_regionscore] IS NOT NULL AND [legsbuttocks_regionscore] IS NOT NULL THEN ''
	   END AS EASIScoreStatus,
	   P.[vigaad]

FROM [Reporting].[AD550].[t_op_AllDrugs] AD
----------------We are searching for enrollment drugs only! (We dont care about FU)---------------------------------
LEFT JOIN [RCC_AD550].[staging].[subject] S ON S.[subNum]=AD.SubjectID AND S.eventName='Enrollment Visit'
LEFT JOIN [RCC_AD550].[staging].[provider] P ON P.subNum=AD.SubjectID AND P.eventName='Enrollment Visit'
LEFT JOIN [Reporting].[AD550].[t_op_EASI] E ON E.SubjectID=AD.SubjectID AND E.VisitType='Enrollment Visit'
WHERE AD.VisitType='Enrollment'
) A
LEFT JOIN [Reporting].[AD550].[t_op_CATReference] CATREF ON CATREF.TreatmentName=A.TreatmentName
) B

 
--SELECT * FROM [Reporting].[AD550].[t_op_AllDrugs] AD
--SELECT * FROM #EnrollDrugs  
--where SiteID = '1440'    ORDER BY SiteID, SubjectID, VisitDate 



/*****Get DOI at Enrollment*****/

IF OBJECT_ID('tempdb.dbo.#EnrollDOI') IS NOT NULL BEGIN DROP TABLE #EnrollDOI END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, RESHierarchy, EligibilityHierarchy, TreatmentName) AS RowNum,
       SiteID,
	   SubjectID,
	   PatientID,
	   PatientYOB,
	   AgeAtEnrollment,
	   OnsetAge,
	   ProviderID,
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   VisitEventOccurrence,
	   VisitCompletion,
	   eventId,
	   eventOccurrence,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentNameFull,
	   EligibleTreatment,
	   TreatmentStatus,
	   DOIInitiationStatus,
	   EligibilityHierarchy,
	   SubscriberDOI,
	   StartDate,
	   MonthsSinceStart,
	   TwelveMonthInitiationRule,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StopDate,
	   RestartDate,
	   CurrentDose,
	   CurrentFrequency,
	   PastDose,
	   PastFrequency,
	   EASI,
	   EASIScoreStatus,
	   [vigaad],
	   RegistryEnrollmentStatus,
	   RESHierarchy
INTO #EnrollDOI
FROM 
(
SELECT DISTINCT SiteID,
       SubjectID,
	   PatientID,
	   PatientYOB,
	   AgeAtEnrollment,
	   OnsetAge,
	   ProviderID,
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   VisitEventOccurrence,
	   VisitCompletion,
	   eventId, 
	   eventOccurrence,
	   eventCrfId,
	   crfOccurrence, 
	   TreatmentName,
	   OtherTreatment,
	   CASE WHEN ISNULL(OtherTreatment, '')='' THEN TreatmentName
	   WHEN TreatmentName='investigational drug (specify)' AND ISNULL(OtherTreatment, '')='' THEN 'Investigational drug'
	   WHEN TreatmentName='investigational drug (specify)' AND ISNULL(OtherTreatment, '')<>'' THEN 'Investigational drug-' + OtherTreatment
	   WHEN TreatmentName='other systemic AD medication (specify)' AND ISNULL(OtherTreatment, '')<>'' THEN 'Other systemic AD medication-' + OtherTreatment
	   ELSE ''
	   END AS TreatmentNameFull,
	   EligibleTreatment,
	   TreatmentStatus,
	   DOIInitiationStatus,
	   EligibilityHierarchy,
	   SubscriberDOI, 
	   StartDate,
	   MonthsSinceStart,
	   TwelveMonthInitiationRule,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StopDate,
	   RestartDate,
	   CurrentDose,
	   CurrentFrequency,
	   PastDose,
	   PastFrequency,
	   EASI,
       EASIScoreStatus,
	   [vigaad],
	   RegistryEnrollmentStatus,
	   CASE WHEN RegistryEnrollmentStatus = 'Eligible' AND ISNULL(OtherTreatment, '')='' THEN 10
	   WHEN RegistryEnrollmentStatus = 'Eligible' AND ISNULL(OtherTreatment, '')<>'' THEN 15
	   WHEN RegistryEnrollmentStatus = 'Eligible-score' AND ISNULL(OtherTreatment, '')='' THEN 20
	   WHEN RegistryEnrollmentStatus = 'Eligible-score' AND ISNULL(OtherTreatment, '')<>'' THEN 25
	   WHEN RegistryEnrollmentStatus = 'Needs review' AND ISNULL(OtherTreatment, '')='' THEN 30
	   WHEN RegistryEnrollmentStatus = 'Needs review' AND ISNULL(OtherTreatment, '')<>'' THEN 35
	   WHEN RegistryEnrollmentStatus = 'Not eligible' AND ISNULL(OtherTreatment, '')='' THEN 40
	   WHEN RegistryEnrollmentStatus = 'Not eligible' AND ISNULL(OtherTreatment, '')<>'' THEN 40
	   ELSE 90
	   END AS RESHierarchy

FROM #EnrollDrugs
) ED

--SELECT * FROM #EnrollDOI WHERE SubjectID IN (55141280016, 56695290001) ORDER BY SiteID, SubjectID, RowNum
--SELECT * FROM #EnrollDOI WHERE SiteID=1440  ORDER BY SubjectID


/*****Get Followup Drugs*****/

IF OBJECT_ID('tempdb.dbo.#FUDrugs') IS NOT NULL BEGIN DROP TABLE #FUDrugs END;

SELECT DISTINCT AD.SiteID,
       AD.SubjectID,
	   AD.PatientID,
	   S.birthdate AS PatientYOB,
	   CAST(P.[ageonset] AS float) AS OnsetAge,
	   AD.ProviderID,
	   AD.VisitType,
	   AD.VisitDate,
	   AD.VisitSequence,
	   AD.VisitEventOccurrence,
	   AD.VisitCompletion,
	   AD.eventId,
	   AD.eventOccurrence,
	   AD.eventCrfId,
	   AD.crfOccurrence,
	   AD.TreatmentName,
	   AD.OtherTreatment,
	   AD.TreatmentStatus,
	   CASE WHEN AD.TreatmentStatus='Continue drug plan/no changes' THEN 'Continued'
	   WHEN AD.TreatmentStatus='Start drug (or restart drug)' THEN 'Prescribed at visit'
	   WHEN AD.TreatmentStatus='Stop/discontinue drug' THEN 'Stopped'
	   WHEN AD.TreatmentStatus='Not applicable (no longer in use)' THEN 'Past use only'
	   ELSE ''
	   END AS DOIInitiationStatus,
	   AD.StartDate,
	   AD.NoPriorUse,
	   AD.PastUse,
	   AD.CurrentUse,
	   AD.StopDate,
	   AD.RestartDate,
	   AD.CurrentDose,
	   AD.CurrentFrequency, 
	   AD.PastDose,
	   AD.PastFrequency,
	   P.[fu_drug] AS notStarted,
	   P.no_start_fu_name1,
	   P.no_start_fu_name2
INTO #FUDrugs
FROM [Reporting].[AD550].[t_op_AllDrugs] AD
LEFT JOIN [RCC_AD550].[staging].[subject] S ON S.[subNum]=AD.SubjectID AND S.eventName='Follow-Up Visit' AND S.eventOccurrence=1
LEFT JOIN [RCC_AD550].[staging].[provider] P ON P.subNum=AD.SubjectID AND P.eventName='Follow-Up Visit' AND P.eventOccurrence=1
WHERE AD.VisitType='Follow-up'

--SELECT * FROM #FUDrugs ORDER BY SiteID, SubjectID, VisitDate

/****Get Exited Subjects*****/

IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 

SELECT SiteID
      ,SubjectID
	  ,PatientID
	  ,ProviderID
	  ,ExitDate
	  ,VisitType
	  ,ExitReason
	  ,OtherExitReason
	  ,hasData
INTO #EXITS
FROM
(
SELECT S.SiteID
      ,E.subNum AS SubjectID
	  ,E.subjectId as PatientID
	  ,E.exit_md_cod AS ProviderID
	  ,E.exit_date AS ExitDate
	  ,E.eventName AS VisitType
	  ,E.exit_reason_dec AS ExitReason
	  ,E.exit_reason_specify AS OtherExitReason
	  ,hasData

FROM [RCC_AD550].[staging].[exitdetails] E
LEFT JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=E.[subjectId]
WHERE S.[status] NOT IN ('Removed', 'Incomplete')
AND hasData=1
) A

--SELECT * FROM #EXITS

/*****Get Next Visit*****/

IF OBJECT_ID('tempdb.dbo.#NextVisit') IS NOT NULL BEGIN DROP TABLE #NextVisit END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, FUHierarchy) AS FURowNum,
 *
	   
INTO #NextVisit
FROM
(
SELECT DISTINCT RowNum,
       NFU.SiteID,
	   NFU.SubjectID,
	   NFU.PatientID,
	   PatientYOB,
	   AgeAtEnrollment,
	   OnsetAge,
	   NFU.ProviderID,
	   NFU.VisitType,
	   VisitDate,
	   VisitSequence,
	   VisitEventOccurrence,
	   VisitCompletion,
	   eventId,
	   eventOccurrence,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentNameFull,
	   CASE WHEN ISNULL(FUVisitDate, '')<>'' AND FUMatch='match' THEN 10
	   WHEN ISNULL(FUVisitDate, '')<>'' AND FUMatch='no match' THEN 20
	   WHEN ISNULL(FUVisitDate, '')='' THEN 80
	   ELSE 90
	   END AS FUHierarchy,
	   EligibleTreatment,
	   TreatmentStatus,
	   DOIInitiationStatus,
	   EligibilityHierarchy,
	   SubscriberDOI,
	   StartDate,
	   MonthsSinceStart,
	   TwelveMonthInitiationRule,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StopDate,
	   RestartDate,
	   CurrentDose,
	   CurrentFrequency,
	   PastDose,
	   PastFrequency,
	   EASI,
	   EASIScoreStatus,
	   [vigaad],
	   RegistryEnrollmentStatus,
	   RESHierarchy,
	   FUTreatmentName,
	   FUOtherTreatment,
	   FUVisitDate,
	   FUStartDate,
	   EX.ExitDate,
	   CASE WHEN pay_enr_eligible_dec='Yes' THEN 'Eligible'
	   WHEN pay_enr_eligible_dec='Under review (outcome TBD)' THEN 'Under review (outcome TBD)'
	   WHEN pay_enr_eligible_dec='No' AND pay_enr_exception_granted_dec='Yes' THEN 'Not eligible - Exception granted'
	   WHEN pay_enr_eligible_dec='No' AND ISNULL(pay_enr_exception_granted_dec, '') IN ('No', '') THEN 'Not eligible'
	   ELSE 'NULL'
	   END AS EligibilityReview, 
	   notStarted,
	   no_start_fu_name1,
	   no_start_fu_name2

FROM
(
SELECT DISTINCT E.RowNum,
       E.SiteID,
	   E.SubjectID,
	   E.PatientID,
	   E.PatientYOB,
	   E.AgeAtEnrollment,
	   E.OnsetAge,
	   E.ProviderID,
	   E.VisitType,
	   E.VisitDate,
	   E.VisitSequence,
	   E.VisitEventOccurrence,
	   E.VisitCompletion,
	   E.eventId,
	   E.eventOccurrence,
	   E.eventCrfId,
	   E.crfOccurrence,
	   E.TreatmentName,
	   E.OtherTreatment,
	   E.TreatmentNameFull,
	   CASE WHEN E.TreatmentName=FU.TreatmentName AND ISNULL(E.OtherTreatment, '')=ISNULL(FU.OtherTreatment, '') THEN 'match'
	   ELSE 'no match'
	   END AS FUMatch,
	   E.EligibleTreatment,
	   E.TreatmentStatus,
	   E.DOIInitiationStatus,
	   E.EligibilityHierarchy,
	   E.SubscriberDOI,
	   E.StartDate,
	   E.MonthsSinceStart,
	   E.TwelveMonthInitiationRule,
	   E.NoPriorUse,
	   E.PastUse,
	   E.CurrentUse,
	   E.StopDate,
	   E.RestartDate,
	   E.CurrentDose,
	   E.CurrentFrequency,
	   E.PastDose,
	   E.PastFrequency,
	   E.EASI,
	   E.EASIScoreStatus,
	   E.[vigaad],
	   E.RegistryEnrollmentStatus,
	   E.RESHierarchy,
	   FU.TreatmentName AS FUTreatmentName,
	   FU.OtherTreatment AS FUOtherTreatment,
	   FU.VisitDate AS FUVisitDate,
	   FU.StartDate AS FUStartDate,
	   VR.pay_enr_eligible_dec,
	   VR.pay_enr_exception_granted_dec,
	   FU.notStarted,
	   FU.no_start_fu_name1,
	   FU.no_start_fu_name2

FROM #EnrollDOI E 
LEFT JOIN #FUDrugs FU ON FU.SiteID=E.SiteID AND FU.PatientID=E.PatientID AND FU.VisitSequence=1
LEFT JOIN [RCC_AD550].[staging].[visitreimbursement] VR ON VR.subjectId=E.PatientID AND VR.eventName='Enrollment Visit'
WHERE E.RowNum=1
) NFU
LEFT JOIN #EXITS EX ON EX.SiteID=NFU.SiteID and EX.SubjectID=NFU.SubjectID AND ISNULL(EX.ExitDate, '')<>'' AND ((ExitDate > FUVisitDate) OR (ISNULL(ExitDate, '')<>'' AND ISNULL(FUVisitDate, '')=''))
) NFU2

--SELECT * FROM #NextVisit WHERE SubjectID IN (55031070001, 55031070017) ORDER BY SiteID, SubjectID, FUHierarchy --WHERE FUHierarchy IN (10, 20) 


TRUNCATE TABLE [Reporting].[AD550].[t_op_CAT];

INSERT INTO [Reporting].[AD550].[t_op_CAT]
(
	   SiteID,
	   SubjectID,
	   PatientID,
	   PatientYOB,
	   AgeAtEnrollment,
	   OnsetAge,
	   ProviderID,
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   VisitEventOccurrence,
	   VisitCompletion,
	   eventId,
	   eventOccurrence,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentNameFull,
	   EligibleTreatment,
	   TreatmentStatus,
	   DOIInitiationStatus,
	   EligibilityHierarchy,
	   SubscriberDOI,
	   StartDate,
	   MonthsSinceStart,
	   TwelveMonthInitiationRule,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StopDate,
	   RestartDate,
	   CurrentDose,
	   CurrentFrequency,
	   PastDose,
	   PastFrequency,
	   EASI,
	   EASIScoreStatus,
	   [vigaad],
	   RegistryEnrollmentStatus,
	   RESHierarchy,
	   FUTreatmentName,
	   FUOtherTreatment,
	   FUVisitDate,
	   FUStartDate,
	   ExitDate,
	   EligibilityReview,
	   SiteStatus,
	   notStarted,
	   no_start_fu_name1,
	   no_start_fu_name2
)


SELECT DISTINCT NV.SiteID,
	   SubjectID,
	   PatientID,
	   PatientYOB,
	   AgeAtEnrollment,
	   OnsetAge,
	   ProviderID,
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   VisitEventOccurrence,
	   VisitCompletion,
	   eventId,
	   eventOccurrence,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentNameFull,
	   EligibleTreatment,
	   TreatmentStatus,
	   DOIInitiationStatus,
	   EligibilityHierarchy,
	   SubscriberDOI,
	   StartDate,
	   MonthsSinceStart,
	   TwelveMonthInitiationRule,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StopDate,
	   RestartDate,
	   CurrentDose,
	   CurrentFrequency,
	   PastDose,
	   PastFrequency,
	   EASI,
	   EASIScoreStatus,
	   [vigaad],
	   CASE WHEN RegistryEnrollmentStatus LIKE 'Eligible%' AND EligibilityReview IN ('Eligible', '', 'Not eligible - Exception granted', 'Not eligible') THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus='Not eligible' AND EligibilityReview IN ('Eligible', 'Not eligible - Exception granted') THEN 'Eligible - Review decision'
	   WHEN RegistryEnrollmentStatus='Not eligible' AND EligibilityReview='Not eligible - Exception granted' THEN 'Eligible - Review decision'
	   WHEN RegistryEnrollmentStatus='Needs review' AND EligibilityReview='Not eligible - Exception granted' THEN 'Eligible - Review decision'
	   WHEN RegistryEnrollmentStatus='Not eligible' AND EligibilityReview='Not eligible' THEN 'Not eligible - Confirmed'
	   WHEN RegistryEnrollmentStatus IN ('Needs review', 'Pending') AND EligibilityReview='Eligible' THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus IN ('Needs review', 'Pending') AND EligibilityReview='Not eligible' THEN 'Not eligible'
	   ELSE RegistryEnrollmentStatus
	   END AS RegistryEnrollmentStatus,
	   RESHierarchy,
	   FUTreatmentName,
	   FUOtherTreatment,
	   FUVisitDate,
	   FUStartDate,
	   ExitDate,
	   EligibilityReview,
	   SiteStatus,
	   notStarted,
	   no_start_fu_name1,
	   no_start_fu_name2

FROM #NextVisit NV
LEFT JOIN [Reporting].[AD550].[v_SiteStatus] SS ON SS.SiteID=NV.SiteID
WHERE FURowNum=1

--SELECT * FROM #NextVisit WHERE SubjectID = 57697180072
--SELECT * FROM [Reporting].[AD550].[t_op_CAT] WHERE VisitDate >='2023-01-01' ORDER BY SiteID, SubjectID, VisitDate



END

GO
