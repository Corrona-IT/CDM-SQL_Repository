USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_AllDrugs_DEV]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- ================================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/28/2020
-- Description:	Procedure to create table for All Drugs for AD550
-- ==================================================================================

CREATE PROCEDURE [AD550].[usp_op_AllDrugs_DEV] AS


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [Reporting].[AD550].[t_op_AllDrugs_DEV]
(
	   [SiteID] [int] NOT NULL
      ,[SubjectID] [nvarchar] (25) NOT NULL
      ,[PatientID] [bigint] NOT NULL
	  ,[ProviderID] [int] NULL
      ,[VisitType] [nvarchar] (25) NULL
      ,[VisitDate] [date] NULL
	  ,[VisitSequence] [int] NULL
	  ,[VisitEventOccurrence] [int] NULL
	  ,[VisitCompletion] [nvarchar] (30) NULL
	  ,[eventId] [int] NULL
	  ,[eventOccurrence] [int] NULL
      ,[crfName] [nvarchar] (200) NULL
	  ,[crfId] [bigint] NULL
	  ,[eventCrfId] [bigint] NULL
	  ,[crfOccurrence] [int] NULL
      ,[TreatmentName] [nvarchar] (250) NULL
      ,[OtherTreatment] [nvarchar] (250) NULL
      ,[TreatmentStatus] [nvarchar] (100) NULL
	  ,[NoPriorUse] [int] NULL
	  ,[PastUse] [int] NULL
	  ,[CurrentUse] [int] NULL
	  ,[DrugStarted] [int] NULL
	  ,[StartDate] [date] NULL
      ,[StartReason] [nvarchar] (10) NULL
	  ,[DrugStopped] [int] NULL
	  ,[StopDate] [date] NULL
      ,[StopReason] [nvarchar] (10) NULL
	  ,[Modified] [int] NULL
	  ,[RestartDate] [date] NULL
	  ,[ChangeDate] [date] NULL
      ,[ChangeReason] [nvarchar] (10) NULL
	  ,[NoChanges] [int] NULL
	  ,[CurrentDose] [nvarchar] (50) NULL
	  ,[CurrentFrequency] [nvarchar] (50) NULL
	  ,[PastDose] [nvarchar] (50) NULL
	  ,[PastFrequency] [nvarchar] (50) NULL
	  ,[FirstDoseReceivedToday] [nvarchar] (10) NULL
);

*/

/*****Get Enrollment Subjects*****/

IF OBJECT_ID('tempdb.dbo.#EnrolledSubjects') IS NOT NULL BEGIN DROP TABLE #EnrolledSubjects END;

SELECT DISTINCT S.SiteID
      ,S.SubjectID
	  ,S.patientId
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,VL.VisitSequence
	  ,VL.eventOccurrence
	  ,VL.VisitDate AS EnrollmentDate
	  ,CASE WHEN VC.statusCode='Completed' THEN 'Complete' 
	   WHEN ISNULL(VC.statusCode, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #EnrolledSubjects
FROM [AD550].[v_op_subjects_DEV] S
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog_DEV] VL ON VL.patientId=S.patientId AND VL.eventId=8031
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] VC ON VC.subjectId=VL.patientId AND VC.eventId=8031
WHERE S.[status]='Enrolled'
AND S.SiteID IS NOT NULL
AND S.SubjectID IS NOT NULL

--SELECT * FROM #EnrolledSubjects WHERE SiteID<>1440
--select * from [AD550].[v_op_subjects_DEV] S

/*****Get Followup Subjects*****/

IF OBJECT_ID('tempdb.dbo.#FUSubjects') IS NOT NULL BEGIN DROP TABLE #FUSubjects END;

SELECT DISTINCT VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,VL.VisitDate AS VisitDate
	  ,VL.VisitSequence
	  ,VL.eventOccurrence
	  ,CASE WHEN VC.statusCode='Completed' THEN 'Complete' 
	   WHEN ISNULL(VC.statusCode, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #FUSubjects
FROM [Reporting].[AD550].[t_op_VisitLog_DEV] VL
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] VC ON VC.subjectId=VL.patientId AND VC.eventOccurrence=VL.eventOccurrence AND VC.eventId=8034
WHERE VL.VisitType='Follow-up'

--SELECT * FROM #FUSubjects


/****Get Exited Subjects*****/

IF OBJECT_ID('tempdb.dbo.#Exits') IS NOT NULL BEGIN DROP TABLE #Exits END;

SELECT DISTINCT VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,VL.VisitDate AS VisitDate
	  ,VL.VisitSequence
	  ,VL.eventOccurrence
	  ,CASE WHEN VC.statusCode='Completed' THEN 'Complete' 
	   WHEN ISNULL(VC.statusCode, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #Exits
FROM [Reporting].[AD550].[t_op_VisitLog_DEV] VL
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] VC ON VC.subjectId=VL.patientId AND VC.eventOccurrence=VL.eventOccurrence AND VC.eventId=8045
WHERE VL.eventId=8045
AND ISNULL(VL.VisitDate, '')<>''

--SELECT * FROM #Exits


/*****Get Enrollment Drug Listing*****/

IF OBJECT_ID('tempdb.dbo.#EnrollDrugs') IS NOT NULL BEGIN DROP TABLE #EnrollDrugs END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,PatientID
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,VisitSequence
	  ,VisitEventOccurrence
	  ,VisitCompletion
	  ,eventId
	  ,eventOccurrence
	  ,crfName
	  ,crfId
	  ,eventCrfId
	  ,crfOccurrence
	  ,CASE WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Incomplete' OR enr_drug_hx=1) THEN 'Pending'
	   WHEN ISNULL(TreatmentName, '')='' AND enr_drug_hx=0 THEN 'No Treatment'
	   WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Complete' AND ISNULL(enr_drug_hx, '')='') THEN 'No Data'
	   ELSE TreatmentName
	   END AS TreatmentName
	  ,OtherTreatment
	  ,TreatmentStatus
	  ,NoPriorUse
	  ,PastUse
	  ,CurrentUse
	  ,CAST(NULL AS int) AS DrugStarted
	  ,StartDate
	  ,StartReason
	  ,CAST(NULL AS int) AS DrugStopped
	  ,StopDate
	  ,StopReason
	  ,CAST(NULL AS int) AS Modified
	  ,RestartDate
	  ,CAST(NULL AS date) AS ChangeDate
	  ,ChangeReason
	  ,CAST(NULL AS int) AS NoChanges
	  ,CASE WHEN ISNULL(CDoseNum, '')<>'' THEN REPLACE(CDose, '___', CAST(CDoseNum AS nvarchar))
	   ELSE CDose
	   END AS CurrentDose
	  ,CASE WHEN ISNULL(CFreqNum, '')<>'' AND CFreq LIKE '%taper%' THEN CFreq + CAST(CFreqNum AS nvarchar)
	   WHEN ISNULL(CFreqNum, '')<>'' AND CFreq LIKE '%__%' THEN REPLACE(CFreq, '__', CAST(CFreqNum AS nvarchar))
	   ELSE CFreq
	   END AS CurrentFrequency
	  ,CASE WHEN ISNULL(PDoseNum, '')<>'' THEN REPLACE(PDose, '___', CAST(PDoseNum AS nvarchar))
	   ELSE PDose
	   END AS PastDose
	  ,CASE WHEN ISNULL(PFreqNum, '')<>'' AND PFreq LIKE '%taper%' THEN PFreq + CAST(PFreqNum AS nvarchar)
	   WHEN ISNULL(PFreqNum, '')<>'' AND PFreq LIKE '%__%' THEN REPLACE(PFreq, '__', CAST(PFreqNum AS nvarchar))
	   ELSE PFreq
	   END AS PastFrequency
	  ,FirstDoseReceivedToday
INTO #EnrollDrugs
FROM
(
SELECT DISTINCT ES.SiteID
      ,ES.SubjectID
	  ,ES.PatientID
	  ,ES.ProviderID
	  ,ES.VisitType
	  ,ES.EnrollmentDate AS VisitDate
	  ,ES.VisitSequence
	  ,ES.eventOccurrence AS VisitEventOccurrence
	  ,ES.VisitCompletion
	  ,ED.eventId
	  ,ED.eventOccurrence
	  ,ED.crfName
	  ,ED.crfId
	  ,ED.eventCrfId
	  ,ED.crfOccurrence
	  ,ED.drug_use_dec AS TreatmentName
	  ,ED.drug_other_specify AS OtherTreatment
	  ,P.enr_drug_hx
	  ,(SELECT optionsText FROM [RCC_AD550].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=120028 AND value=ED.[drug_rx]) AS TreatmentStatus
	  ,ED.drug_use_noprior AS NoPriorUse
	  ,ED.drug_use_past AS PastUse
	  ,ED.drug_use_curr AS CurrentUse
	  ,CASE WHEN ED.drug_dose_rcvd_tdy=1 THEN ES.EnrollmentDate
	   ELSE ED.drug_st_dt 
	   END AS StartDate
	  ,ED.drug_st_reason AS StartReason
	  ,ED.drug_stp_dt AS StopDate
	  ,ED.drug_stp_reason AS StopReason
	  ,ED.drug_mod_reason AS ChangeReason
	  ,ED.[drug_rst_dt] AS RestartDate
	  ,CASE WHEN [drug_dose_curr_dec] LIKE '%(%' THEN SUBSTRING([drug_dose_curr_dec], 0, CHARINDEX('(', [drug_dose_curr_dec], 0))
	   ELSE [drug_dose_curr_dec] 
	   END AS CDose
	  ,CAST(CAST([drug_dose_curr_num] AS DEC(8, 2)) AS float) AS CDoseNum
	  ,SUBSTRING([drug_freq_curr_dec], 0, CHARINDEX('(', [drug_freq_curr_dec], 0)) AS CFreq
	  ,CAST(CAST(ED.[drug_freq_curr_num] AS dec(8,2)) AS float) AS CFreqNum
	  ,CASE WHEN [drug_dose_past_dec] LIKE '%(%' THEN SUBSTRING([drug_dose_past_dec], 0, CHARINDEX('(', [drug_dose_past_dec], 0)) 
	   ELSE [drug_dose_past_dec]
	   END AS PDose
	  ,CAST(CAST([drug_dose_past_num] AS DEC(8, 2)) AS float) AS PDoseNum
	  ,SUBSTRING([drug_freq_past_dec], 0, CHARINDEX('(', [drug_freq_past_dec], 0)) AS PFreq
	  ,CAST(CAST([drug_freq_past_num] AS dec(8,2)) AS float) AS PFreqNum
	  ,CASE WHEN ED.[drug_freq_past_num] IS NOT NULL THEN REPLACE(ED.[drug_freq_past_dec], ' __', ED.[drug_freq_past_num])
	   ELSE ED.[drug_freq_past_dec]
	   END AS PastFrequency
	  ,[drug_dose_rcvd_tdy] AS FirstDoseReceivedToday

FROM #EnrolledSubjects ES
LEFT JOIN [RCC_AD550].[staging].[adsystemicdrughistory] ED ON ES.PatientID=ED.subjectId AND ED.eventId=8031
LEFT JOIN [RCC_AD550].[staging].[provider] P ON P.subjectId=es.patientId AND P.eventId=8031
) A

--SELECT * FROM #EnrollDrugs WHERE SubjectID=57697180072 ORDER BY SiteID, SubjectID



/*****Get Followup Drug Listing*****/
IF OBJECT_ID('tempdb.dbo.#FUDrugs') IS NOT NULL BEGIN DROP TABLE #FUDrugs END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,PatientID
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,VisitSequence
	  ,VisitEventOccurrence
	  ,VisitCompletion
	  ,eventId
	  ,eventOccurrence
	  ,crfName
	  ,crfId
	  ,eventCrfId
	  ,crfOccurrence
	  ,CASE WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Incomplete' OR fu_drug=1) THEN 'Pending'
	   WHEN ISNULL(TreatmentName, '')='' AND fu_drug=0 THEN 'No Treatment'
	   WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Complete' AND ISNULL(fu_drug, '')='') THEN 'No Data'
	   ELSE TreatmentName
	   END AS TreatmentName
	  ,OtherTreatment
	  ,TreatmentStatus
	  ,CAST(NULL AS int) AS NoPriorUse
	  ,CAST(NULL as int) AS Pastuse
	  ,CAST(NULL AS int) AS CurrentUse
	  ,DrugStarted
	  ,StartDate
	  ,StartReason
	  ,DrugStopped
	  ,StopDate
	  ,StopReason
	  ,Modified
	  ,CAST(NULL as date) AS RestartDate
	  ,ChangeDate
	  ,ChangeReason
	  ,NoChanges
	  ,CASE WHEN ISNULL(CDoseNum, '')<>'' THEN REPLACE(CDose, '___', CAST(CDoseNum AS nvarchar))
	   ELSE CDose
	   END AS CurrentDose
	  ,CASE WHEN ISNULL(CFreqNum, '')<>'' AND CFreq LIKE '%taper%' THEN CFreq + CAST(CFreqNum AS nvarchar)
	   WHEN ISNULL(CFreqNum, '')<>'' AND CFreq LIKE '%__%' THEN REPLACE(CFreq, '__', CAST(CFreqNum AS nvarchar))
	   ELSE CFreq
	   END AS CurrentFrequency
	  ,CASE WHEN ISNULL(PDoseNum, '')<>'' THEN REPLACE(PDose, '___', CAST(PDoseNum AS nvarchar))
	   ELSE PDose
	   END AS PastDose
	  ,CASE WHEN ISNULL(PFreqNum, '')<>'' AND PFreq LIKE '%taper%' THEN PFreq + CAST(PFreqNum AS nvarchar)
	   WHEN ISNULL(PFreqNum, '')<>'' AND PFreq LIKE '%__%' THEN REPLACE(PFreq, '__', CAST(PFreqNum AS nvarchar))
	   ELSE PFreq
	   END AS PastFrequency
	  ,FirstDoseReceivedToday
INTO #FUDrugs
FROM
(
SELECT DISTINCT FUS.SiteID
      ,FUS.SubjectID
	  ,FUS.PatientID
	  ,FUS.ProviderID
	  ,FUS.VisitType
	  ,FUS.VisitDate
	  ,FUS.VisitSequence
	  ,FUS.eventOccurrence AS VisitEventOccurrence
	  ,FUS.VisitCompletion
	  ,FUD.eventId
	  ,FUD.eventOccurrence
	  ,FUD.crfName
	  ,FUD.crfId
	  ,FUD.eventCrfId
	  ,FUD.crfOccurrence
	  ,FUD.drug_use_dec AS TreatmentName
	  ,FUD.drug_other_specify AS OtherTreatment
	  ,(SELECT optionsText FROM [RCC_AD550].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=120028 AND value=FUD.[drug_rx]) AS TreatmentStatus
	  ,FUD.drug_use_start AS DrugStarted
	  ,CASE WHEN FUD.drug_dose_rcvd_tdy=1 THEN FUS.VisitDate
	   ELSE FUD.drug_st_dt 
	   END AS StartDate
	  ,FUD.drug_st_reason AS StartReason
	  ,FUD.drug_use_stop AS DrugStopped
	  ,FUD.drug_stp_dt AS StopDate
	  ,FUD.drug_stp_reason AS StopReason
	  ,FUD.drug_use_mod AS Modified
	  ,FUD.drug_mod_dt as ChangeDate
	  ,FUD.drug_mod_reason AS ChangeReason
	  ,FUD.drug_use_nochg AS NoChanges
	  ,CASE WHEN FUD.[drug_dose_curr_dec] LIKE '%(%' THEN SUBSTRING(FUD.[drug_dose_curr_dec], 0, CHARINDEX('(', FUD.[drug_dose_curr_dec], 0))
	   ELSE FUD.[drug_dose_curr_dec] 
	   END AS CDose
	  ,CAST(CAST(FUD.[drug_dose_curr_num] AS DEC(8, 2)) AS float) AS CDoseNum
	  ,SUBSTRING(FUD.[drug_freq_curr_dec], 0, CHARINDEX('(', FUD.[drug_freq_curr_dec], 0)) AS CFreq
	  ,CAST(CAST(FUD.[drug_freq_curr_num] AS dec(8,2)) AS float) AS CFreqNum
	  ,CASE WHEN FUD.[drug_dose_past_dec] LIKE '%(%' THEN SUBSTRING(FUD.[drug_dose_past_dec], 0, CHARINDEX('(', FUD.[drug_dose_past_dec], 0)) 
	   ELSE FUD.[drug_dose_past_dec]
	   END AS PDose
	  ,CAST(CAST(FUD.[drug_dose_past_num] AS DEC(8, 2)) AS float) AS PDoseNum
	  ,SUBSTRING(FUD.[drug_freq_past_dec], 0, CHARINDEX('(', FUD.[drug_freq_past_dec], 0)) AS PFreq
	  ,CAST(FUD.[drug_freq_past_num] AS float) AS PFreqNum
	 ,[drug_dose_rcvd_tdy] AS FirstDoseReceivedToday
	 ,P.fu_drug
	  
FROM #FUSubjects FUS
LEFT JOIN [RCC_AD550].[staging].[adsystemicdrugs] FUD ON FUD.subjectId=FUS.PatientID and FUD.eventId=8034 and FUD.eventOccurrence=FUS.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[provider] P ON P.subjectId=FUS.ProviderID AND P.eventOccurrence=FUS.eventOccurrence AND P.eventId=8034
) B

/*****Get Exit Drug Listing*****/
IF OBJECT_ID('tempdb.dbo.#ExitDrugs') IS NOT NULL BEGIN DROP TABLE #ExitDrugs END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,PatientID
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,VisitSequence
	  ,VisitEventOccurrence
	  ,VisitCompletion
	  ,eventId
	  ,eventOccurrence
	  ,crfName
	  ,crfId
	  ,eventCrfId
	  ,crfOccurrence
	  ,CASE WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Incomplete' OR [exit_drug_use]=1) THEN 'Pending'
	   WHEN ISNULL(TreatmentName, '')='' AND [exit_drug_use]=0 THEN 'No Treatment'
	   WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Complete' AND ISNULL([exit_drug_use], '')='') THEN 'No Data'
	   ELSE TreatmentName
	   END AS TreatmentName
	  ,OtherTreatment
	  ,TreatmentStatus
	  ,NoPriorUse
	  ,PastUse
	  ,CurrentUse
	  ,CAST(NULL AS int) AS DrugStarted
	  ,StartDate
	  ,StartReason
	  ,CAST(NULL AS int) AS DrugStopped
	  ,StopDate
	  ,StopReason
	  ,CAST(NULL AS int) AS Modified
	  ,RestartDate
	  ,CAST(NULL AS date) AS ChangeDate
	  ,ChangeReason
	  ,CAST(NULL AS int) AS NoChanges
	  ,CASE WHEN ISNULL(CDoseNum, '')<>'' THEN REPLACE(CDose, '___', CDoseNum)
	   ELSE cDose
	   END AS CurrentDose
	  ,CASE WHEN ISNULL(CFreqNum, '')<>'' AND CFreq LIKE '%taper%' THEN CFreq + CAST(CFreqNum AS nvarchar)
	   WHEN ISNULL(CFreqNum, '')<>'' AND CFreq LIKE '%__%' THEN REPLACE(CFreq, '__', CAST(CFreqNum AS nvarchar))
	   ELSE CFreq
	   END AS CurrentFrequency
	  ,CASE WHEN ISNULL(PDoseNum, '')<>'' THEN REPLACE(PDose, '___', CAST(PDoseNum AS nvarchar))
	   ELSE PDose
	   END AS PastDose
	  ,CASE WHEN ISNULL(PFreqNum, '')<>'' AND PFreq LIKE '%taper%' THEN PFreq + CAST(PFreqNum AS nvarchar)
	   WHEN ISNULL(PFreqNum, '')<>'' AND PFreq LIKE '%__%' THEN REPLACE(PFreq, '__', CAST(PFreqNum AS nvarchar))
	   ELSE PFreq
	   END AS PastFrequency
	  ,FirstDoseReceivedToday
INTO #ExitDrugs
FROM
(
SELECT EX.SiteID
      ,EX.SubjectID
	  ,EX.patientId
	  ,EX.ProviderID
	  ,EX.VisitType
	  ,EX.VisitDate
	  ,EX.VisitSequence
	  ,EX.eventOccurrence AS VisitEventOccurrence
	  ,EX.VisitCompletion
	  ,ExDrugs.eventId
	  ,ExDrugs.eventOccurrence
	  ,'Exit Details Systemic AD Meds' AS crfName
      ,ExDrugs.[crfId]
      ,ExDrugs.[eventCrfId]
      ,ExDrugs.[crfOccurrence]
	  ,ExDrugs.[exit_drug_dec] AS TreatmentName
      ,ExDrugs.[exit_drug_other] AS OtherTreatment
	  ,CASE WHEN ExDrugs.[exit_drug_curr]=1 THEN 'Current'
	   WHEN ExDrugs.[exit_drug_curr]=0 THEN 'Stop/discontinue drug'
	   ELSE CAST(ExDrugs.[exit_drug_curr] AS varchar)
	   END AS TreatmentStatus
	  ,NULL AS NoPrioruse
	  ,NULL AS PastUse
	  ,ExDrugs.[exit_drug_curr] AS CurrentUse
	  ,ExDrugs.[exit_drug_start_dt] AS StartDate
	  ,NULL AS StartReason
	  ,ExDrugs.[exit_drug_last_dose_dt] AS StopDate
	  ,NULL AS Stopreason
	  ,NULL AS ChangeReason
	  ,CAST(NULL AS date) AS RestartDate
	  ,REPLACE(ExDrugs.[exit_drug_dose_dec], ' (enter dose)', '') AS cDose
      ,CAST(ExDrugs.[exit_drug_dose_specify] AS float) AS CDoseNum
      ,ExDrugs.[exit_drug_freq_dec] AS CFreq
      ,ExDrugs.[exit_drug_freq_specify] AS CFreqNum
	  ,NULL AS PDose
	  ,NULL AS PDoseNum
	  ,NULL AS PFreq
	  ,NULL AS PFreqNum
	  ,NULL AS PastFrequency
	  ,NULL AS FirstDoseReceivedToday
	  ,ExDet.[exit_drug_use]

FROM #Exits EX
LEFT JOIN [RCC_AD550].[staging].[exitdetails_systemicadmedications] ExDrugs ON EX.patientId=ExDrugs.subjectId
LEFT JOIN [RCC_AD550].[staging].[exitdetails] ExDet ON ExDet.subjectId=ExDrugs.subjectId AND ExDet.eventOccurrence=ExDrugs.eventOccurrence AND ExDet.eventId=8045
) EX1

--SELECT * FROM #ExitDrugs ORDER BY SiteID, SubjectID


TRUNCATE TABLE [Reporting].[AD550].[t_op_AllDrugs_DEV];

INSERT INTO [Reporting].[AD550].[t_op_AllDrugs_DEV]
(
     SiteID
	,SubjectID
	,PatientID
	,ProviderID
	,VisitType
	,VisitDate
	,VisitSequence
	,VisitEventOccurrence
	,VisitCompletion
	,eventId
	,eventOccurrence
	,crfName
	,crfId
	,crfOccurrence
	,TreatmentName
	,OtherTreatment
	,TreatmentStatus
	,NoPriorUse
	,PastUse
	,CurrentUse
	,DrugStarted
	,StartDate
	,StartReason
	,DrugStopped
	,StopDate
	,StopReason
	,Modified
	,RestartDate
	,ChangeDate
	,ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
)

SELECT DISTINCT SiteID
	,SubjectID
	,PatientID
	,ProviderID
	,VisitType
	,VisitDate
	,VisitSequence
	,VisitEventOccurrence
	,VisitCompletion
	,eventId
	,eventOccurrence
	,crfName
	,crfId
	,crfOccurrence
	,TreatmentName
	,OtherTreatment
	,TreatmentStatus
	,NoPriorUse
	,PastUse
	,CurrentUse
	,DrugStarted
	,StartDate
	,CAST(StartReason AS varchar) AS StartReason
	,DrugStopped
	,StopDate
	,CAST(StopReason AS varchar) AS StopReason
	,Modified
	,RestartDate
	,ChangeDate
	,CAST(ChangeReason AS varchar) AS ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
FROM #EnrollDrugs
WHERE SiteID IS NOT NULL
AND SubjectID IS NOT NULL

UNION

SELECT DISTINCT SiteID
	,SubjectID
	,PatientID
	,ProviderID
	,VisitType
	,VisitDate
	,VisitSequence
	,VisitEventOccurrence
	,VisitCompletion
	,eventId
	,eventOccurrence
	,crfName
	,crfId
	,crfOccurrence
	,TreatmentName
	,OtherTreatment
	,TreatmentStatus
	,NoPriorUse
	,PastUse
	,CurrentUse
	,DrugStarted
	,StartDate
	,CAST(StartReason AS varchar) AS StartReason
	,DrugStopped
	,StopDate
	,CAST(StopReason AS varchar) AS StopReason
	,Modified
	,RestartDate
	,ChangeDate
	,CAST(ChangeReason AS varchar) AS ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
FROM #FUDrugs
WHERE SiteID IS NOT NULL
AND SubjectID IS NOT NULL

UNION

SELECT DISTINCT SiteID
	,SubjectID
	,PatientID
	,ProviderID
	,VisitType
	,VisitDate
	,VisitSequence
	,VisitEventOccurrence
	,VisitCompletion
	,eventId
	,eventOccurrence
	,crfName
	,crfId
	,crfOccurrence
	,TreatmentName
	,OtherTreatment
	,TreatmentStatus
	,NoPriorUse
	,PastUse
	,CurrentUse
	,DrugStarted
	,StartDate
	,CAST(StartReason AS varchar) AS StartReason
	,DrugStopped
	,StopDate
	,CAST(StopReason AS varchar) AS StopReason
	,Modified
	,RestartDate
	,ChangeDate
	,CAST(ChangeReason AS varchar) AS ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
FROM #ExitDrugs
WHERE SiteID IS NOT NULL
AND SubjectID IS NOT NULL

--SELECT * FROM [Reporting].[AD550].[t_op_AllDrugs_DEV] WHERE SubjectID='999999999' ORDER BY SiteID DESC, SubjectID, VisitDate, TreatmentName, OtherTreatment


END

GO
