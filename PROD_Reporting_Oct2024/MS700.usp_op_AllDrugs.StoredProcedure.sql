USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_AllDrugs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/22/2020
-- Description:	Procedure to create table for All Drugs for MS
-- ==================================================================================

CREATE PROCEDURE [MS700].[usp_op_AllDrugs] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [MS700].[t_op_AllDrugs](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](35) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitCompletion] [nvarchar](30) NULL,
	[eventId] [bigint] NULL,
	[crfName] [nvarchar](350) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[otherTreatment] [nvarchar](350) NULL,
	[NoPriorUse] [int] NULL,
	[PastUse] [int] NULL,
	[CurrentUse] [int] NULL,
	[StartedDrug] [int] NULL,
	[StartDate] [date] NULL,
	[StartReason] [nvarchar](100) NULL,
	[StoppedDrug] [int] NULL,
	[StopDate] [date] NULL,
	[StopReason] [nvarchar](100) NULL,
	[RestartDate] [date] NULL,
	[ModifiedDrug] [int] NULL,
	[ModifiedDate] [date] NULL,
	[ModifyReason] [nvarchar](100) NULL,
	[MostRecentInfusionDate] [date] NULL,
	[NoChanges] [int] NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[CTStartReason] [nvarchar](100) NULL,
	[CTStopReason] [nvarchar](100) NULL,
	[CTModifyReason] [nvarchar](100) NULL,
	[CurrentDose] [nvarchar](50) NULL,
	[CurrentFrequency] [nvarchar](50) NULL,
	[PastDose] [nvarchar](50) NULL,
	[PastFrequency] [nvarchar](50) NULL,
	[PrescribedDose] [nvarchar](50) NULL,
	[MostRecentRituxanDose] [nvarchar](50) NULL,
	[PastCycles] [int] NULL,
	[FirstDoseReceivedToday] [nvarchar](5) NULL
) ON [PRIMARY]
GO

*/

/*****Get Enrollment Subjects*****/

IF OBJECT_ID('tempdb.dbo.#EnrolledSubjects') IS NOT NULL BEGIN DROP TABLE #EnrolledSubjects END;

SELECT DISTINCT VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,VL.VisitDate AS EnrollmentDate
	  ,VL.VisitSequence
	  ,VL.eventCrfId
	  ,VL.eventOccurrence
	  ,VL.eventId
	  ,CASE WHEN VC.vc_3_1000=1 THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #EnrolledSubjects
FROM [MS700].[v_op_VisitLog] VL
LEFT JOIN [RCC_MS700].[staging].[visitcompletion] VC ON VC.subjectId=VL.PatientID AND VC.eventOccurrence=VL.eventOccurrence AND VC.eventId=3042
WHERE VL.eventId=3042

--SELECT * FROM #EnrolledSubjects

/*****Get Followup Subjects*****/

IF OBJECT_ID('tempdb.dbo.#FUSubjects') IS NOT NULL BEGIN DROP TABLE #FUSubjects END;

SELECT DISTINCT VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,VL.VisitDate AS VisitDate
	  ,VL.VisitSequence
	  ,VL.eventCrfId
	  ,VL.eventOccurrence
	  ,VL.eventId
	  ,CASE WHEN VC.vc_3_1000=1 THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #FUSubjects
FROM [MS700].[v_op_VisitLog] VL
LEFT JOIN [RCC_MS700].[staging].[visitcompletion] VC ON VC.subjectId=VL.PatientID AND VC.eventOccurrence=VL.eventOccurrence AND VC.eventId=3043
WHERE VL.eventId=3043

--SELECT * FROM #FUSubjects


/****Get Exited Subjects*****/

IF OBJECT_ID('tempdb.dbo.#Exits') IS NOT NULL BEGIN DROP TABLE #Exits END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,PatientID
	  ,ProviderID
	  ,VisitType
	  ,VisitDate AS ExitDate
	  ,VisitSequence
	  ,eventCrfId
	  ,eventOccurrence
	  ,eventId
INTO #Exits
FROM [MS700].[v_op_VisitLog]
WHERE eventId=3053

--SELECT * FROM #Exits


/*****Get Enrollment Drug Listing*****/
IF OBJECT_ID('tempdb.dbo.#EnrollDrugs') IS NOT NULL BEGIN DROP TABLE #EnrollDrugs END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,patientId
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,VisitSequence
	  ,eventOccurrence
	  ,eventId
	  ,VisitCompletion
	  ,crfName
	  ,crfId
	  ,eventCrfId
	  ,crfOccurrence
	  ,TreatmentName
	  ,OtherTreatment
	  ,NoPriorUse
	  ,PastUse
	  ,CurrentUse
	  ,StartedDrug
	  ,StartDate
	  ,rawStartDate
	  ,CASE WHEN ISNUMERIC(startmonth)=1 THEN ((startday + '-' + SUBSTRING(datename(month, dateadd(month, CAST(startmonth as int), -1)), 1, 3) + '-' + startyear))
	   ELSE (CAST(startday AS varchar) + '-' + startmonth + '-' + CAST(startyear AS varchar))
	   END AS enteredStartDate
	  ,StartReason
	  ,StoppedDrug
	  ,StopDate
	  ,StopReason
	  ,RestartDate
	  ,ModifiedDrug
	  ,ModifiedDate
	  ,ModifyReason
	  ,MostRecentInfusionDate
	  ,NoChanges
	  ,ChangesToday
	  ,CTStartReason
	  ,CTStopReason
	  ,CTModifyReason
	  ,CurrentDose
	  ,CurrentFrequency
	  ,PastDose
	  ,PastFrequency
	  ,PrescribedDose
	  ,MostRecentRituxanDose
	  ,PastCycles
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
	  ,ES.eventOccurrence
	  ,ES.eventId
	  ,ES.VisitCompletion
	  ,ED.crfName
	  ,ED.crfId
	  ,ED.eventCrfId
	  ,ED.crfOccurrence
	  ,CASE WHEN ISNULL(ED.zzz_use_dec, '')='' AND (ISNULL(ES.VisitCompletion, '')='Incomplete' AND ISNULL(DMT.drug_use, '')=1) THEN 'Pending'
	  WHEN ISNULL(ED.zzz_use_dec, '')='' AND (ISNULL(ES.VisitCompletion, '')='Incomplete' AND ISNULL(DMT.drug_use, '')='') THEN 'Pending'
	   WHEN ISNULL(ED.zzz_use_dec, '')='' AND (ISNULL(ES.VisitCompletion, '')='Complete' OR ISNULL(DMT.drug_use, '')=0) THEN 'No treatment'
	   WHEN ISNULL(ED.zzz_use_dec, '')='' AND (ISNULL(ES.VisitCompletion, '')='Complete' OR ISNULL(DMT.drug_use, '')='') THEN 'No treatment'
	   ELSE ED.zzz_use_dec
	   END AS TreatmentName
	  ,ED.zzz_other_specify AS OtherTreatment
	  ,ED.zzz_use_noprior AS NoPriorUse
	  ,ED.zzz_use_past AS PastUse
	  ,ED.zzz_use_curr AS CurrentUse
	  ,ED.zzz_dose_rcvd_tdy AS StartedDrug    
	  ,CASE WHEN ED.zzz_dose_rcvd_tdy=1 THEN ES.EnrollmentDate
	   ELSE ED.zzz_st_dt 
	   END AS StartDate
	  ,ED.zzz_st_dt_t AS rawStartDate
	  ,CASE WHEN ISNUMERIC(SUBSTRING(ED.zzz_st_dt_t, 0, CHARINDEX('-', ED.zzz_st_dt_t, 0)))=1 
	        THEN RIGHT('00' + (SUBSTRING(ED.zzz_st_dt_t, 0, CHARINDEX('-', ED.zzz_st_dt_t, 0))), 2)
		WHEN ISNUMERIC(SUBSTRING(ED.zzz_st_dt_t, 0, CHARINDEX('-', ED.zzz_st_dt_t, 0)))=0
		     THEN SUBSTRING(ED.zzz_st_dt_t, 0, CHARINDEX('-', ED.zzz_st_dt_t, 0))
		ELSE ED.zzz_st_dt_t
		END AS startday
	  ,SUBSTRING(ED.zzz_st_dt_t, CHARINDEX('-', ED.zzz_st_dt_t)+1, (((LEN(ED.zzz_st_dt_t))-CHARINDEX('-', REVERSE(ED.zzz_st_dt_t)))-CHARINDEX('-', ED.zzz_st_dt_t))) AS startmonth
	  ,RIGHT(ED.zzz_st_dt_t, 4) as startyear

	  ,SUBSTRING(ED.zzz_st_reason_dec, 1, 2) AS StartReason
	  ,CAST(NULL AS int) AS StoppedDrug     -- FU
	  ,ED.zzz_stp_dt AS StopDate
	  ,SUBSTRING(ED.zzz_stp_reason_dec, 1, 2) AS StopReason
	  ,ED.zzz_rst_dt AS RestartDate
	  ,CAST(NULL AS int) AS ModifiedDrug     --FU
	  ,CAST(NULL AS date) AS ModifiedDate    --FU
	  ,SUBSTRING(ED.zzz_mod_reason_dec, 1, 2) AS ModifyReason
	  ,ED.zzz_infusion_dt AS MostRecentInfusionDate
	  ,CAST(NULL AS int) AS NoChanges		--FU
	  ,ED.zzz_rx_dec AS ChangesToday
	  ,SUBSTRING(ED.zzz_rx_st_reason_dec, 1, 2) AS CTStartReason
	  ,SUBSTRING(ED.zzz_rx_stp_reason_dec, 1, 2) AS CTStopReason
	  ,SUBSTRING(ED.zzz_rx_mod_reason_dec, 1, 2) AS CTModifyReason
	  ,[zzz_dose_curr_dec] AS CurrentDose
	  ,CASE WHEN [zzz_freq_curr_num] IS NOT NULL THEN REPLACE([zzz_freq_curr_name_dec], ' __ ', [zzz_freq_curr_num])
	   ELSE [zzz_freq_curr_name_dec]
	   END AS CurrentFrequency
	  ,[zzz_dose_past_dec] AS PastDose
	  ,CASE WHEN [zzz_freq_past_num] IS NOT NULL THEN REPLACE([zzz_freq_past_name_dec], ' __ ', [zzz_freq_past_num])
	   ELSE [zzz_freq_past_name_dec]
	   END AS PastFrequency
	  ,[zzz_dose_pres] AS PrescribedDose
	  ,CAST([zzz_dose_recent] AS nvarchar) + 'mg' AS MostRecentRituxanDose
	  ,[zzz_dose_past_cycles] AS PastCycles
	  ,[zzz_dose_rcvd_tdy_dec] AS FirstDoseReceivedToday

FROM #EnrolledSubjects ES
LEFT JOIN [RCC_MS700].[staging].[providermstreatmentenrollment] ED ON ES.PatientID=ED.subjectId AND ES.eventOccurrence=ED.eventOccurrence AND ES.eventId=ED.eventId
LEFT JOIN [RCC_MS700].[staging].[providerreviewofsystemsdmts] DMT ON DMT.subjectId=ES.patientId AND DMT.eventId=ES.eventId AND DMT.eventOccurrence=ES.eventOccurrence
) A

--SELECT * FROM #EnrollDrugs WHERE TreatmentName IN ('No treatment', 'Pending') ORDER BY SiteID, SubjectID  -- WHERE TreatmentName IS NULL


/*****Get Followup Drug Listing*****/
IF OBJECT_ID('tempdb.dbo.#FUDrugs') IS NOT NULL BEGIN DROP TABLE #FUDrugs END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,patientId
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,VisitSequence
	  ,eventOccurrence
	  ,eventId
	  ,VisitCompletion
	  ,crfName
	  ,crfId
	  ,eventCrfId
	  ,crfOccurrence
	  ,TreatmentName
	  ,OtherTreatment
	  ,NoPriorUse
	  ,PastUse
	  ,CurrentUse
	  ,StartedDrug
	  ,StartDate
	  ,rawStartDate
	  ,CASE WHEN ISNUMERIC(startmonth)=1 THEN ((startday + '-' + SUBSTRING(datename(month, dateadd(month, CAST(startmonth as int), -1)), 1, 3) + '-' + startyear))
	   ELSE (CAST(startday AS varchar) + '-' + startmonth + '-' + CAST(startyear AS varchar))
	   END AS enteredStartDate
	  ,StartReason
	  ,StoppedDrug
	  ,StopDate
	  ,StopReason
	  ,RestartDate
	  ,ModifiedDrug
	  ,ModifiedDate
	  ,ModifyReason
	  ,MostRecentInfusionDate
	  ,NoChanges
	  ,ChangesToday
	  ,CTStartReason
	  ,CTStopReason
	  ,CTModifyReason
	  ,CurrentDose
	  ,CurrentFrequency
	  ,PastDose
	  ,PastFrequency
	  ,PrescribedDose
	  ,MostRecentRituxanDose
	  ,PastCycles
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
	  ,FUS.eventOccurrence
	  ,FUS.VisitCompletion
	  ,FUS.eventId
	  ,FUD.crfName
	  ,FUD.crfId
	  ,FUD.eventCrfId
	  ,FUD.crfOccurrence
	  ,CASE WHEN ISNULL(FUD.zzz_use_dec, '')='' AND (ISNULL(FUS.VisitCompletion, '')='Incomplete' AND ISNULL(DMT.drug_use, '')=1) THEN 'Pending'
	  WHEN ISNULL(FUD.zzz_use_dec, '')='' AND (ISNULL(FUS.VisitCompletion, '')='Incomplete' AND ISNULL(DMT.drug_use, '')='') THEN 'Pending'
	   WHEN ISNULL(FUD.zzz_use_dec, '')='' AND (ISNULL(FUS.VisitCompletion, '')='Complete' OR ISNULL(DMT.drug_use, '')=0) THEN 'No treatment'
	   WHEN ISNULL(FUD.zzz_use_dec, '')='' AND (ISNULL(FUS.VisitCompletion, '')='Complete' OR ISNULL(DMT.drug_use, '')='') THEN 'No treatment'
	   ELSE FUD.zzz_use_dec
	   END AS TreatmentName
	  ,FUD.zzz_other_specify AS OtherTreatment
	  ,CAST(NULL as int) AS NoPriorUse   -- ENROLL
	  ,CAST(NULL as int) AS PastUse		 -- ENROLL
	  ,CAST(NULL as int) AS CurrentUse	 -- ENROLL
	  ,FUD.zzz_use_start AS StartedDrug
	  ,FUD.zzz_st_dt AS StartDate

	  ,FUD.zzz_st_dt_t AS rawStartDate
 	  
	  ,CASE WHEN ISNUMERIC(SUBSTRING(FUD.zzz_st_dt_t, 0, CHARINDEX('-', FUD.zzz_st_dt_t, 0)))=1 
	        THEN RIGHT('00' + (SUBSTRING(FUD.zzz_st_dt_t, 0, CHARINDEX('-', FUD.zzz_st_dt_t, 0))), 2)
		WHEN ISNUMERIC(SUBSTRING(FUD.zzz_st_dt_t, 0, CHARINDEX('-', FUD.zzz_st_dt_t, 0)))=0
		     THEN SUBSTRING(FUD.zzz_st_dt_t, 0, CHARINDEX('-', FUD.zzz_st_dt_t, 0))
		ELSE FUD.zzz_st_dt_t
		END AS startday
	  ,SUBSTRING(FUD.zzz_st_dt_t, CHARINDEX('-', FUD.zzz_st_dt_t)+1, (((LEN(FUD.zzz_st_dt_t))-CHARINDEX('-', REVERSE(FUD.zzz_st_dt_t)))-CHARINDEX('-', FUD.zzz_st_dt_t))) AS startmonth
	  ,RIGHT(FUD.zzz_st_dt_t, 4) as startyear

	  ,SUBSTRING(FUD.zzz_st_reason_dec, 1, 2) AS StartReason
	  ,FUD.zzz_use_stop AS StoppedDrug
	  ,FUD.zzz_stp_dt AS StopDate
	  ,SUBSTRING(FUD.zzz_stp_reason_dec, 1, 2) AS StopReason
	  ,CAST(NULL AS date) AS RestartDate   -- ENROLL
	  ,FUD.zzz_use_mod AS ModifiedDrug
	  ,FUD.zzz_mod_dt as ModifiedDate
	  ,SUBSTRING(FUD.zzz_mod_reason_dec, 1, 2) AS ModifyReason
	  ,FUD.zzz_infusion_dt AS MostRecentInfusionDate
	  ,FUD.zzz_use_nochg AS NoChanges
	  ,FUD.[zzz_rx_dec] AS ChangesToday
	  ,SUBSTRING(FUD.zzz_rx_st_reason_dec, 1, 2) AS CTStartReason
	  ,SUBSTRING(FUD.zzz_rx_stp_reason_dec, 1, 2) AS CTStopReason
	  ,SUBSTRING(FUD.zzz_rx_mod_reason_dec, 1, 2) AS CTModifyReason
	 ,[zzz_dose_curr_dec] AS CurrentDose
	 ,CASE WHEN [zzz_freq_curr_num] IS NOT NULL THEN REPLACE([zzz_freq_curr_name_dec], ' __ ', [zzz_freq_curr_num])
	   ELSE [zzz_freq_curr_name_dec]
	   END AS CurrentFrequency
	 ,[zzz_dose_past_dec] AS PastDose
	 ,CASE WHEN [zzz_freq_past_num] IS NOT NULL THEN REPLACE([zzz_freq_past_name_dec], ' __ ', [zzz_freq_past_num])
	   ELSE [zzz_freq_past_name_dec]
	   END AS PastFrequency
	 ,[zzz_dose_pres] AS PrescribedDose
	 ,CAST([zzz_dose_recent] AS nvarchar) + 'mg' AS MostRecentRituxanDose
	 ,[zzz_dose_past_cycles] AS PastCycles
	 ,[zzz_dose_rcvd_tdy_dec] AS FirstDoseReceivedToday

FROM #FUSubjects FUS
LEFT JOIN [RCC_MS700].[staging].[providermstreatmentfollowup] FUD ON FUD.subjectId=FUS.PatientID AND FUD.eventOccurrence=FUS.eventOccurrence AND FUS.eventId=FUD.eventId
LEFT JOIN [RCC_MS700].[staging].[providerreviewofsystemsdmts] DMT ON DMT.subjectId=FUS.patientId AND DMT.eventId=FUS.eventId AND DMT.eventOccurrence=FUS.eventOccurrence
) B
--SELECT * FROM #FUDrugs WHERE SubjectID=70011000001 ORDER BY SiteID, SubjectID, VisitDate, TreatmentName


---Insert all drugs into table

TRUNCATE TABLE [Reporting].[MS700].[t_op_AllDrugs];

INSERT INTO [Reporting].[MS700].[t_op_AllDrugs]
(
	   SiteID,
       SubjectID,
	   PatientId, 
	   ProviderID, 
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   eventOccurrence,
	   VisitCompletion,
	   eventId,
	   crfName,
	   crfId,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StartedDrug,
	   StartDate,
	   rawStartDate,
	   enteredStartDate,
	   StoppedDrug,
	   StopDate,
	   StopReason,
	   RestartDate,
	   ModifiedDrug,
	   ModifiedDate,
	   ModifyReason,
	   MostRecentInfusionDate,
	   NoChanges,
	   ChangesToday,
	   CTStartReason,
	   CTStopReason,
	   CTModifyReason,
	   CurrentDose,
	   CurrentFrequency, 
	   PastDose,
	   PastFrequency,
	   PrescribedDose,
	   MostRecentRituxanDose,
	   PastCycles, 
	   FirstDoseReceivedToday
)


SELECT DISTINCT SiteID,
       SubjectID,
	   PatientId, 
	   ProviderID, 
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   eventOccurrence,
	   VisitCompletion,
	   eventId,
	   crfName,
	   crfId,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StartedDrug,
	   StartDate,
	   rawStartDate,
	   enteredStartDate,
	   StoppedDrug,
	   StopDate,
	   StopReason,
	   RestartDate,
	   ModifiedDrug,
	   ModifiedDate,
	   ModifyReason,
	   MostRecentInfusionDate,
	   NoChanges,
	   ChangesToday,
	   CTStartReason,
	   CTStopReason,
	   CTModifyReason,
	   CurrentDose,
	   CurrentFrequency, 
	   PastDose,
	   PastFrequency,
	   PrescribedDose,
	   MostRecentRituxanDose,
	   PastCycles, 
	   FirstDoseReceivedToday
FROM  #EnrollDrugs
UNION
SELECT DISTINCT SiteID,
       SubjectID,
	   PatientId, 
	   ProviderID, 
	   VisitType,
	   VisitDate,
	   VisitSequence,
	   eventOccurrence,
	   VisitCompletion,
	   eventId,
	   crfName,
	   crfId,
	   eventCrfId,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   StartedDrug,
	   StartDate,
	   rawStartDate,
	   enteredStartDate,
	   StoppedDrug,
	   StopDate,
	   StopReason,
	   RestartDate,
	   ModifiedDrug,
	   ModifiedDate,
	   ModifyReason,
	   MostRecentInfusionDate,
	   NoChanges,
	   ChangesToday,
	   CTStartReason,
	   CTStopReason,
	   CTModifyReason,
	   CurrentDose,
	   CurrentFrequency, 
	   PastDose,
	   PastFrequency,
	   PrescribedDose,
	   MostRecentRituxanDose,
	   PastCycles, 
	   FirstDoseReceivedToday 
FROM #FUDrugs

--SELECT * FROM [Reporting].[MS700].[t_op_AllDrugs] ORDER BY SiteID, SubjectID, VisitDate, TreatmentName, otherTreatment



END



GO
