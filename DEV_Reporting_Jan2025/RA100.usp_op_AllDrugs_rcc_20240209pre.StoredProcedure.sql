USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_AllDrugs_rcc_20240209pre]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==================================================================================
-- Author:		Kevin Soe
-- Create date: 9/12/2023
-- Description:	Procedure to create table for All Drugs for RA100
-- ==================================================================================
			  --EXECUTE
CREATE PROCEDURE [RA100].[usp_op_AllDrugs_rcc_20240209pre] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 
			 DROP TABLE
CREATE TABLE [Reporting].[RA100].[t_op_AllDrugs_rcc]
(
	   [SiteID] [int] NOT NULL
      ,[SubjectID] [nvarchar](30) NOT NULL
      ,[PatientID] [bigint] NOT NULL
	  ,[ProviderID] [int] NULL
      ,[VisitType] [nvarchar] (50) NULL
      ,[VisitDate] [date] NULL
	  ,[VisitSequence] [int] NULL
	  ,[VisitEventOccurrence] [int] NULL
	  ,[VisitCompletion] [nvarchar] (50) NULL
	  ,[eventId] [int] NULL
	  ,[eventOccurrence] [int] NULL
      ,[crfName] [nvarchar] (200) NULL
	  ,[crfId] [bigint] NULL
	  ,[eventCrfId] [bigint] NULL
	  ,[crfOccurrence] [int] NULL
      ,[TreatmentName] [nvarchar] (250) NULL
      ,[OtherTreatment] [nvarchar] (250) NULL
      ,[TreatmentStatus] [nvarchar] (200) NULL
	  ,[NoPriorUse] [int] NULL
	  ,[PastUse] [int] NULL
	  ,[CurrentUse] [int] NULL
	  ,[DrugStarted] [int] NULL
	  ,[StartDate] [date] NULL
      ,[StartReason] [nvarchar] (100) NULL
	  ,[DrugStopped] [int] NULL
	  ,[StopDate] [date] NULL
      ,[StopReason] [nvarchar] (100) NULL
	  ,[Modified] [int] NULL
	  --,[RestartDate] [date] NULL
	  --,[ChangeDate] [date] NULL
      ,[ChangeReason] [nvarchar] (100) NULL
	  ,[NoChanges] [int] NULL
	  ,[CurrentDose] [nvarchar] (100) NULL
	  ,[CurrentFrequency] [nvarchar] (100) NULL
	  ,[PastDose] [nvarchar] (100) NULL
	  ,[PastFrequency] [nvarchar] (100) NULL
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
	  ,CAST(VL.VisitDate AS date) AS EnrollmentDate
	  ,CASE WHEN VC.statusCode='Completed' THEN 'Complete' 
	   WHEN ISNULL(VC.statusCode, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #EnrolledSubjects
FROM [RA100].[v_op_subjects_rcc] S
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.patientId=S.patientId AND VL.eventId=9285
LEFT JOIN [RCC_RA100].[staging].[eventcompletion] VC ON VC.subjectId=VL.patientId AND VC.eventId=9285
WHERE S.[status]<>'Removed'
AND S.SiteID IS NOT NULL
AND S.SubjectID IS NOT NULL

--SELECT * FROM #EnrolledSubjects WHERE SiteID<>1440
--select * from [RA100].[v_op_subjects_rcc] S

/*****Get Followup Subjects*****/

IF OBJECT_ID('tempdb.dbo.#FUSubjects') IS NOT NULL BEGIN DROP TABLE #FUSubjects END;

SELECT DISTINCT VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,CAST(VL.VisitDate AS date) AS VisitDate
	  ,VL.VisitSequence
	  ,VL.eventOccurrence
	  ,CASE WHEN VC.statusCode='Completed' THEN 'Complete' 
	   WHEN ISNULL(VC.statusCode, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #FUSubjects
FROM [Reporting].[RA100].[t_op_VisitLog_rcc] VL
LEFT JOIN [RCC_RA100].[staging].[eventcompletion] VC ON VC.subjectId=VL.patientId AND VC.eventOccurrence=VL.eventOccurrence AND VC.eventId=9286
WHERE VL.VisitType='Follow-up'

--SELECT * FROM #FUSubjects


/****Get Exited Subjects*****/

IF OBJECT_ID('tempdb.dbo.#Exits') IS NOT NULL BEGIN DROP TABLE #Exits END;

SELECT DISTINCT VL.SiteID
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,CAST(VL.VisitDate AS date) AS VisitDate
	  ,VL.VisitSequence
	  ,VL.eventOccurrence
	  ,CASE WHEN VC.statusCode='Completed' THEN 'Complete' 
	   WHEN ISNULL(VC.statusCode, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletion
INTO #Exits
FROM [Reporting].[RA100].[t_op_VisitLog_rcc] VL
LEFT JOIN [RCC_RA100].[staging].[eventcompletion] VC ON VC.subjectId=VL.patientId AND VC.eventOccurrence=VL.eventOccurrence AND VC.eventId=9301
WHERE VL.eventId=9301
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
	  ,CASE WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Incomplete' OR rxuse_1_1000=1) THEN 'Pending'
	   WHEN ISNULL(TreatmentName, '')='' AND rxuse_1_1000=0 THEN 'No Treatment'
	   WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Complete' AND ISNULL(rxuse_1_1000, '')='') THEN 'No Data'
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
	  ,ED.rxuse_1_1100
	  ,(SELECT optionsText FROM [RCC_RA100].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=241049 AND value=ED.[rxuse_1_1100]) AS TreatmentName
	  ,ED.rxuse_1_1190 AS OtherTreatment
	  ,P.rxuse_1_1000
	  ,(SELECT optionsText FROM [RCC_RA100].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=140920 AND value=ED.[rxncf_1_1100]) AS TreatmentStatus
	  ,ED.rxncf_1_1086 AS NoPriorUse
	  ,ED.rxncf_1_1000_1 AS PastUse
	  ,ED.rxncf_1_1001_1 AS CurrentUse
	  ,CASE WHEN ED.rxncf_1_1200=1 THEN ES.EnrollmentDate
			WHEN ED.rxdat_1_1080 LIKE '%UNK - - - 2023%' THEN REPLACE(ED.rxdat_1_1080, 'UNK - - - 2023', '1 - January - 2023') --added on 20240208
			WHEN ED.rxdat_1_1080 LIKE '%UNK%' THEN REPLACE(ED.rxdat_1_1080, 'UNK', '1')
	   ELSE ED.rxdat_1_1080 -- Getting error 'Conversion failed when converting date and/or time from character string.' due to the data for rxdat_1_1080 having UNK as an option. Converting all UNKs to 1 resolved the issue
	   END AS StartDate
	  ,ED.rxrsn_1_1000_dec AS StartReason
	  ,ED.rxdat_1_1081 AS StopDate
	  ,ED.rxrsn_1_1001_dec AS StopReason
	  ,ED.rxrsn_1_1002_dec AS ChangeReason
	  ,ED.rxdat_1_1082 AS RestartDate
	  ,CASE WHEN ED.rxdse_1_1000_dec LIKE '%(%' THEN SUBSTRING(ED.rxdse_1_1000_dec, 0, CHARINDEX('(', ED.rxdse_1_1000_dec, 0))
	   ELSE ED.rxdse_1_1000_dec 
	   END AS CDose
	  ,CAST(CAST(ED.rxdse_1_1001 AS DEC(8, 2)) AS float) AS CDoseNum
	  ,ED.rxfrq_1_1000
	  ,SUBSTRING(ED.rxfrq_1_1000_dec, 0, CHARINDEX('(', ED.rxfrq_1_1000_dec, 0)) AS CFreq
	  ,CAST(CAST(ED.rxfrq_1_1001 AS dec(8,2)) AS float) AS CFreqNum
	  ,CASE WHEN ED.rxdse_1_1100_dec LIKE '%(%' THEN SUBSTRING(ED.rxdse_1_1100_dec, 0, CHARINDEX('(', ED.rxdse_1_1100_dec, 0)) 
	   ELSE ED.rxdse_1_1100_dec
	   END AS PDose
	  ,CAST(CAST(ED.rxdse_1_1101 AS DEC(8, 2)) AS float) AS PDoseNum
	  ,ED.rxfrq_1_1100_dec
	  ,SUBSTRING(ED.rxfrq_1_1100_dec, 0, CHARINDEX('(', ED.rxfrq_1_1100_dec, 0)) AS PFreq
	  ,CAST(CAST(ED.rxfrq_1_1101 AS dec(8,2)) AS float) AS PFreqNum
	  ,CASE WHEN ED.rxfrq_1_1101 IS NOT NULL THEN REPLACE(ED.rxfrq_1_1100_dec, ' __', ED.rxfrq_1_1101)
	   ELSE ED.rxfrq_1_1100_dec
	   END AS PastFrequency
	  ,ED.rxncf_1_1200 AS FirstDoseReceivedToday
	  --SELECT *
FROM #EnrolledSubjects ES  --SELECT * FROM [RCC_RA100].[staging].[radrughistory] 
LEFT JOIN [RCC_RA100].[staging].[radrughistory] ED ON ES.PatientID=ED.subjectId AND ED.eventId=9285
LEFT JOIN [RCC_RA100].[staging].[providerform] P ON P.subjectId=es.patientId AND P.eventId=9285
) A


--SELECT * FROM #EnrollDrugs ORDER BY SiteID, SubjectID


/* This SQL gets the text for the response values for Treatment Status (Changes Today)
 SELECT [responseSetId]
      ,[id]
      ,[displaySequence]
      ,[optionsText]
      ,[value]  --SELECT *
  FROM [RCC_RA100].[api].[responsesetvalues]
  WHERE [responseSetId]=241049
  ORDER BY displaySequence
  */

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
	  ,CASE WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Incomplete' OR rxuse_2_1000=1) THEN 'Pending'
	   WHEN ISNULL(TreatmentName, '')='' AND rxuse_2_1000=0 THEN 'No Treatment'
	   WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Complete' AND ISNULL(rxuse_2_1000, '')='') THEN 'No Data'
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
	  ,(SELECT optionsText FROM [RCC_RA100].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=241049 AND value=FUD.rxuse_2_1100) AS TreatmentName
	  ,FUD.rxuse_2_1190 AS OtherTreatment
	  ,(SELECT optionsText FROM [RCC_AD550].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=120028 AND value=FUD.rxncf_2_1100) AS TreatmentStatus
	  ,FUD.rxncf_2_1300_1 AS DrugStarted
	  ,CASE WHEN FUD.RXNCF_2_1200=1 THEN FUS.VisitDate
			WHEN FUD.RXDAT_2_1083 LIKE '%UNK%' THEN REPLACE(FUD.RXDAT_2_1083, 'UNK', '1')
	   ELSE FUD.RXDAT_2_1083 -- Getting error 'Conversion failed when converting date and/or time from character string.' due to the data for rxdat_1_1080 having UNK as an option. Converting all UNKs to 1 resolved the issue
	   END AS StartDate
	  ,FUD.rxrsn_2_1200_dec AS StartReason
	  ,FUD.rxncf_2_1301_1 AS DrugStopped
	  ,FUD.rxdat_2_1084 AS StopDate
	  ,FUD.rxrsn_2_1201_dec AS StopReason
	  ,FUD.rxncf_2_1302_1 AS Modified
	  ,FUD.rxdat_2_1085 as ChangeDate
	  ,FUD.RXRSN_2_1202_dec AS ChangeReason
	  ,FUD.rxncf_2_1386 AS NoChanges
	  ,CASE WHEN FUD.rxdse_2_1000_dec LIKE '%(%' THEN SUBSTRING(FUD.rxdse_2_1000_dec, 0, CHARINDEX('(', FUD.[rxdse_2_1000_dec], 0))
	   ELSE FUD.rxdse_2_1000_dec
	   END AS CDose
	  ,CAST(CAST(FUD.rxdse_2_1001 AS DEC(8, 2)) AS float) AS CDoseNum
	  ,SUBSTRING(FUD.rxfrq_2_1000_dec, 0, CHARINDEX('(', FUD.rxfrq_2_1000_dec, 0)) AS CFreq
	  ,CAST(CAST(FUD.rxfrq_2_1001 AS dec(8,2)) AS float) AS CFreqNum
	  ,CASE WHEN FUD.rxdse_2_1100_dec LIKE '%(%' THEN SUBSTRING(FUD.rxdse_2_1100_dec, 0, CHARINDEX('(', FUD.rxdse_2_1100_dec, 0)) 
	   ELSE FUD.rxdse_2_1100_dec
	   END AS PDose
	  ,CAST(CAST(FUD.rxdse_2_1101 AS DEC(8, 2)) AS float) AS PDoseNum
	  ,SUBSTRING(FUD.rxfrq_2_1100_dec, 0, CHARINDEX('(', FUD.rxfrq_2_1100_dec, 0)) AS PFreq
	  ,CAST(FUD.rxfrq_2_1101 AS float) AS PFreqNum
	 ,FUD.rxncf_2_1200 AS FirstDoseReceivedToday
	 ,P.rxuse_2_1000
--SELECT * 	  
FROM #FUSubjects FUS --SELECT * FROM [RCC_RA100].[staging].[radrugs]
LEFT JOIN [RCC_RA100].[staging].[radrugs] FUD ON FUD.subjectId=FUS.PatientID and FUD.eventId=9286 and FUD.eventOccurrence=FUS.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[providerform] P ON P.subjectId=FUS.ProviderID AND P.eventOccurrence=FUS.eventOccurrence AND P.eventId=9286
) B

--SELECT * FROM #FUDrugs ORDER BY SiteID, SubjectID

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
	  ,CASE WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Incomplete' OR exrxs_7_1000=1) THEN 'Pending'
	   WHEN ISNULL(TreatmentName, '')='' AND exrxs_7_1000=0 THEN 'No Treatment'
	   WHEN ISNULL(TreatmentName, '')='' AND (VisitCompletion='Complete' AND ISNULL(exrxs_7_1000, '')='') THEN 'No Data'
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
	  ,'Exit Details RA Drugs' AS crfName
      ,ExDrugs.[crfId]
      ,ExDrugs.[eventCrfId]
      ,ExDrugs.[crfOccurrence]
	  ,(SELECT optionsText FROM [RCC_RA100].[api].[responsesetvalues] RSV WHERE RSV.responseSetId=241049 AND value=ExDrugs.exrxs_7_1100) AS TreatmentName
      ,ExDrugs.exrxs_7_1190 AS OtherTreatment
	  ,CASE WHEN ExDrugs.exrxs_7_1500=1 THEN 'Current'
	   WHEN ExDrugs.exrxs_7_1500=0 THEN 'Stop/discontinue drug'
	   ELSE CAST(ExDrugs.exrxs_7_1500 AS varchar)
	   END AS TreatmentStatus
	  ,NULL AS NoPrioruse
	  ,NULL AS PastUse
	  ,ExDrugs.exrxs_7_1500 AS CurrentUse
	  ,ExDrugs.exrxs_7_1480 AS StartDate
	  ,NULL AS StartReason
	  ,ExDrugs.exrxs_7_1481 AS StopDate
	  ,NULL AS Stopreason
	  ,NULL AS ChangeReason
	  ,CAST(NULL AS date) AS RestartDate
	  ,REPLACE(ExDrugs.exrxs_7_1200_dec, ' (enter dose)', '') AS cDose
      ,CAST(ExDrugs.exrxs_7_1201 AS float) AS CDoseNum
      ,ExDrugs.exrxs_7_1300_dec AS CFreq
      ,ExDrugs.exrxs_7_1301 AS CFreqNum
	  ,NULL AS PDose
	  ,NULL AS PDoseNum
	  ,NULL AS PFreq
	  ,NULL AS PFreqNum
	  ,NULL AS PastFrequency
	  ,NULL AS FirstDoseReceivedToday
	  ,ExDet.exrxs_7_1000

FROM #Exits EX  --SELECT * FROM [RCC_RA100].[staging].[exitdetails_radmedications]
LEFT JOIN [RCC_RA100].[staging].[exitdetails_ramedications] ExDrugs ON EX.patientId=ExDrugs.subjectId
LEFT JOIN [RCC_RA100].[staging].[exitdetails] ExDet ON ExDet.subjectId=ExDrugs.subjectId AND ExDet.eventOccurrence=ExDrugs.eventOccurrence AND ExDet.eventId=9301
) EX1

--SELECT * FROM #ExitDrugs ORDER BY SiteID, SubjectID


TRUNCATE TABLE [Reporting].[RA100].[t_op_AllDrugs_rcc];

INSERT INTO [Reporting].[RA100].[t_op_AllDrugs_rcc]
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
	--,RestartDate
	--,ChangeDate
	,ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
)
-- Date conversions are having issues so some dates are removed for the time being
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
	,CASE 
		WHEN StartDate LIKE '%UNK%' THEN CAST((REPLACE(StartDate,'UNK',1)) AS DATE)
		ELSE CAST(StartDate AS DATE)
		END AS StartDate
	,CAST(StartReason AS nvarchar) AS StartReason
	,DrugStopped
	,CASE 
		WHEN StopDate LIKE '%UNK%' THEN CAST((REPLACE(StopDate,'UNK',1)) AS DATE)
		ELSE CAST(StopDate AS DATE)
		END AS StopDate
	,CAST(StopReason AS nvarchar) AS StopReason
	,Modified
	--,RestartDate
	--,ChangeDate
	,CAST(ChangeReason AS nvarchar) AS ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
FROM #EnrollDrugs
WHERE SiteID IS NOT NULL
AND SubjectID IS NOT NULL
--AND patientId <> '2676259'

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
	,CASE 
		WHEN StartDate LIKE '%UNK%' THEN CAST((REPLACE(StartDate,'UNK',1)) AS DATE)
		ELSE CAST(StartDate AS DATE)
		END AS StartDate
	,CAST(StartReason AS nvarchar) AS StartReason
	,DrugStopped
	,CASE 
		WHEN StopDate LIKE '%UNK%' THEN CAST((REPLACE(StopDate,'UNK',1)) AS DATE)
		ELSE CAST(StopDate AS DATE)
		END AS StopDate
	,CAST(StopReason AS nvarchar) AS StopReason
	,Modified
	--,RestartDate
	--,ChangeDate
	,CAST(ChangeReason AS nvarchar) AS ChangeReason
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
	,CASE 
		WHEN StartDate LIKE '%UNK%' THEN CAST((REPLACE(StartDate,'UNK',1)) AS DATE)
		ELSE CAST(StartDate AS DATE)
		END AS StartDate
	,CAST(StartReason AS nvarchar) AS StartReason
	,DrugStopped
	,CASE 
		WHEN StopDate LIKE '%UNK%' THEN CAST((REPLACE(StopDate,'UNK',1)) AS DATE)
		ELSE CAST(StopDate AS DATE)
		END AS StopDate
	,CAST(StopReason AS nvarchar) AS StopReason
	,Modified
	--,RestartDate
	--,ChangeDate
	,CAST(ChangeReason AS nvarchar) AS ChangeReason
	,NoChanges
	,CurrentDose
	,CurrentFrequency
	,PastDose
	,PastFrequency
	,FirstDoseReceivedToday
FROM #ExitDrugs
WHERE SiteID IS NOT NULL
AND SubjectID IS NOT NULL

--SELECT * FROM [Reporting].[RA100].[t_op_AllDrugs_rcc] ORDER BY SiteID DESC, SubjectID, VisitDate, TreatmentName, OtherTreatment



END



GO
