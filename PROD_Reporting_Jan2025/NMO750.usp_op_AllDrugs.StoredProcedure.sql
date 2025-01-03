USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_AllDrugs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 30-Sep_2021
-- Description:	Procedure to create table for All Drugs
-- ==================================================================================

CREATE PROCEDURE [NMO750].[usp_op_AllDrugs] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [NMO750].[t_op_AllDrugs](
	[Registry] [nvarchar](15) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[SiteID] [int] NOT NULL,
	[SFSiteStatus] [nvarchar](200) NULL,
	[EDCSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[eventCrfId] [bigint] NULL,
	[birthYear] [bigint] NULL,
	[ProviderID] [bigint] NULL,
	[VisitType] [nvarchar](100) NULL,
	[eventDefinitionId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[VisitDate] [date] NULL,
	[NextVisitDate] [date] NULL,
	[PreviousVisitDate] [date] NULL,
	[Treatment] [nvarchar](250) NULL,
	[OtherTreatment] [nvarchar](300) NULL,
	[crfOccurrence] [bigint] NULL,
	[DrugStatus] [nvarchar](300) NULL,
	[DateStarted] [date] NULL,
	[DateStopped] [date] NULL,
	[DatePrescribed] [date] NULL,
	[DosingStatus] [nvarchar](300) NULL,
	[drugConfirmation] [nvarchar](100) NULL,
	[indication] [nvarchar](300) NULL,
	[ReasonStarted] [nvarchar](60) NULL,
	[ReasonStopped] [nvarchar](200) NULL,
	[ReasonNotStarted] [nvarchar](200) NULL,
	[drugDose] [nvarchar](200) NULL,
	[drugDoseOther] [nvarchar](200) NULL,
	[drugDoseTaperHigh] [nvarchar](200) NULL,
	[drugDoseTaperLow] [nvarchar](200) NULL,
	[drugFrequency] [nvarchar](200) NULL,
	[drugFrequencyOther] [nvarchar](250) NULL,
	[CompletionStatus] [nvarchar](100) NULL
) ON [PRIMARY]
GO


SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [NMO750].[t_op_DrugListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[eventName] [nvarchar](100) NULL,
	[eventId] [bigint] NULL,
	[crfName] [nvarchar](100) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[statusCode] [nvarchar](100) NULL,
	[Treatment] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[OtherTreatment] [nvarchar](300) NULL,
	[DrugStatus] [nvarchar](300) NULL,
	[drugconfirmation] [nvarchar](100) NULL,
	[indication] [nvarchar](300) NULL,
	[ReasonStarted] [nvarchar](60) NULL,
	[DatePrescribed] [date] NULL,
	[DateStarted] [date] NULL,
	[DosingStatus] [nvarchar](300) NULL,
	[ReasonNotStarted] [nvarchar](200) NULL,
	[drugDose] [nvarchar](200) NULL,
	[drugDoseOther] [nvarchar](200) NULL,
	[drugDoseTaperHigh] [nvarchar](200) NULL,
	[drugDoseTaperLow] [nvarchar](200) NULL,
	[drugFrequency] [nvarchar](200) NULL,
	[drugFrequencyOther] [nvarchar](250) NULL,
	[DateStopped] [date] NULL,
	[ReasonStopped] [nvarchar](200) NULL
) ON [PRIMARY]
GO
*/

/*****Get Enrollment and Follow Subject Visits*****/

IF OBJECT_ID('tempdb.dbo.#VisitLog') IS NOT NULL BEGIN DROP TABLE #VisitLog END;

SELECT Registry
      ,RegistryName
	  ,SiteID
      ,SFSiteStatus
	  ,EDCSiteStatus
	  ,SubjectID
	  ,patientId
	  ,birthYear
	  ,ProviderID
	  ,VisitType
	  ,eventDefinitionId
	  ,eventOccurrence
	  ,VisitDate
	  ,eventCrfId
	  ,CASE WHEN ISNULL(CompletionStatus, '')<>'Completed' THEN 'Incomplete'
	   WHEN CompletionStatus='Completed' THEN 'Complete'
	   ELSE ''
	   END AS CompletionStatus
INTO #VisitLog
FROM [NMO750].[t_op_VisitLog]
WHERE eventDefinitionId IN (11174, 11175)

--SELECT * FROM #VisitLog ORDER BY SiteID, SubjectID, eventDefinitionId, eventOccurrence



/****Get Exited Subjects*****/

IF OBJECT_ID('tempdb.dbo.#Exits') IS NOT NULL BEGIN DROP TABLE #Exits END;

SELECT Registry
      ,RegistryName
	  ,SiteID
      ,SFSiteStatus
	  ,EDCSiteStatus
	  ,SubjectID
	  ,patientId
	  ,birthYear
	  ,ProviderID
	  ,VisitType
	  ,eventDefinitionId
	  ,eventOccurrence
	  ,VisitDate
	  ,eventCrfId
	  ,CASE WHEN ISNULL(CompletionStatus, '')<>'Completed' THEN 'Incomplete'
	   WHEN CompletionStatus='Completed' THEN 'Complete'
	   ELSE ''
	   END AS CompletionStatus
INTO #Exits
FROM [NMO750].[t_op_VisitLog]
WHERE eventDefinitionId=11190

--SELECT * FROM #Exits


/**Get drugs listed on Visit form questions**/

IF OBJECT_ID('tempdb.dbo.#VisitMeds') IS NOT NULL BEGIN DROP TABLE #VisitMeds END;
SELECT subNum,
       eventId,
	   visit_dt,
	   tsqm9_drug_dec AS currentmed,
	   tsqm9_drug_specify AS othercurrentmed
INTO #VisitMeds
FROM [RCC_NMOSD750].[staging].[visitdate]
WHERE tsqm9_screen=1
--AND eventId=11175

/*****Get Drug Listing from Drug Log*****/

IF OBJECT_ID('tempdb.dbo.#DrugLog') IS NOT NULL BEGIN DROP TABLE #DrugLog END;

SELECT *
INTO #DrugLog
FROM 
(
SELECT SUBSTRING([siteName], 1, 4) AS SiteID
      ,[subNum] AS SubjectID
      ,[subjectId] AS PatientID
      ,[eventName]
      ,[eventId]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[statusCode]
      ,CASE WHEN ISNULL([drug_other_specify], '')<>'' AND [drug_use_dec] LIKE '%(specify)%' THEN CONCAT(REPLACE([drug_use_dec], '(specify) ', ''), '; ', [drug_other_specify])
	   ELSE [drug_use_dec]
	   END AS Treatment
	  ,[drug_use_dec] AS TreatmentName
 	  ,[drug_other_specify] AS OtherTreatment
	  ,CASE WHEN [drug_confirmation]=2 AND ISNULL([drug_stp_dt], '')='' THEN 'Current use'
	   WHEN [drug_confirmation]=1 AND ISNULL([drug_initiation_status], '')='' AND ISNULL([drug_st_dt], '')='' THEN 'New prescription (initiation unconfirmed)'
	   WHEN [drug_confirmation]=2 AND ISNULL([drug_stp_dt], '')<>'' THEN 'Past use/stopped'
	   WHEN [drug_confirmation]=1 AND [drug_initiation_status]=1 THEN 'Prescription was never administered'
	   ELSE ''
	   END AS DrugStatus
      ,CASE WHEN [drug_confirmation]=1 THEN 'Initiation pending'
	   WHEN [drug_confirmation]=2 THEN 'Initiated'
	   ELSE ''
	   END AS drugConfirmation
      ,[drug_indication_dec] AS indication
      ,[drug_st_reason] AS ReasonStarted
      ,[drug_pres_dt] AS DatePrescribed
      ,[drug_st_dt] AS DateStarted
      ,CASE WHEN [drug_initiation_status]=1 then 'Will not be initiated'
	   ELSE ''
	   END AS DosingStatus
      ,[drug_no_start_reason_dec] AS ReasonNotStarted
	  ,[drug_dose_dec] AS drugDose
	  ,REPLACE([drug_dose_dec], '___', ' ' + CAST([drug_dose_other] AS float)) AS drugDoseOther
      ,[drug_dose_taper_high] AS drugDoseTaperHigh
      ,[drug_dose_taper_low] AS drugDoseTaperLow
	  ,[drug_freq_dec] AS drugFrequency
	  ,drug_freq_other
      ,REPLACE([drug_freq_dec], '__', CAST([drug_freq_other] AS float) + ' ') AS drugFrequencyOther
      ,[drug_stp_dt] AS DateStopped
      ,[drug_stp_reason_dec] AS ReasonStopped
      ,[drug_review_dt] AS LastReviewDate
FROM [RCC_NMOSD750].[staging].[drug] drug
WHERE ISNULL([drug_use_dec], '')<>''

UNION

SELECT SUBSTRING([siteName], 1, 4) AS SiteID
      ,[subNum] AS SubjectID
      ,[subjectId] AS PatientID
      ,[eventName]
      ,[eventId]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[statusCode]
      ,CASE WHEN ISNULL([drug_other_specify], '')<>'' AND [drug_use_dec] LIKE '%(specify)%' THEN CONCAT(REPLACE([drug_use_dec], '(specify) ', ''), '; ', [drug_other_specify])
	   ELSE [drug_use_dec]
	   END AS Treatment
	  ,[drug_use_dec] AS TreatmentName
 	  ,[drug_other_specify] AS OtherTreatment
	  ,drug_status AS DrugStatus
      ,'' AS drugConfirmation
      ,[drug_indication_dec] AS indication
      ,[drug_st_reason] AS ReasonStarted
      ,CAST(NULL AS date) AS DatePrescribed
      ,[drug_st_dt] AS DateStarted
      ,'' AS DosingStatus
      ,'' AS ReasonNotStarted
	  ,[drug_dose_dec] AS drugDose
	  ,REPLACE([drug_dose_dec], '___', ' ' + CAST([drug_dose_other] AS float)) AS drugDoseOther
      ,[drug_dose_taper_high] AS drugDoseTaperHigh
      ,[drug_dose_taper_low] AS drugDoseTaperLow
	  ,[drug_freq_dec] AS drugFrequency
	  ,drug_freq_other
      ,REPLACE([drug_freq_dec], '__', CAST([drug_freq_other] AS float) + ' ') AS drugFrequencyOther
      ,[drug_stp_dt] AS DateStopped
      ,[drug_stp_reason_dec] AS ReasonStopped
      ,CAST(NULL AS date) AS LastReviewDate

FROM [RCC_NMOSD750].[staging].[drughistorypastuse] drughx
WHERE ISNULL(drug_use_dec, '')<>''
) DL

TRUNCATE TABLE [NMO750].[t_op_DrugListing];

INSERT INTO [NMO750].[t_op_DrugListing](
       [SiteID]
      ,[SubjectID]
      ,[PatientID]
      ,[eventName]
      ,[eventId]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[statusCode]
      ,[Treatment]
      ,[TreatmentName]
      ,[OtherTreatment]
      ,[DrugStatus]
      ,[drugconfirmation]
      ,[indication]
      ,[ReasonStarted]
      ,[DatePrescribed]
      ,[DateStarted]
      ,[DosingStatus]
      ,[ReasonNotStarted]
      ,[drugDose]
      ,[drugDoseOther]
      ,[drugDoseTaperHigh]
      ,[drugDoseTaperLow]
      ,[drugFrequency]
      ,[drugFrequencyOther]
      ,[DateStopped]
      ,[ReasonStopped]
  )

SELECT [SiteID]
      ,[SubjectID]
      ,[PatientID]
      ,[eventName]
      ,[eventId]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[statusCode]
      ,[Treatment]
      ,[TreatmentName]
      ,[OtherTreatment]
      ,[DrugStatus]
      ,[drugconfirmation]
      ,[indication]
      ,[ReasonStarted]
      ,[DatePrescribed]
      ,[DateStarted]
      ,[DosingStatus]
      ,[ReasonNotStarted]
      ,[drugDose]
      ,[drugDoseOther]
      ,[drugDoseTaperHigh]
      ,[drugDoseTaperLow]
      ,[drugFrequency]
      ,[drugFrequencyOther]
      ,[DateStopped]
      ,[ReasonStopped]
  FROM #DrugLog


--SELECT DISTINCT * FROM #DrugLog ORDER BY SiteID, SubjectID, crfOccurrence, DatePrescribed, DateStarted, DateStopped

/*****Determine Drugs by Visit*****/

IF OBJECT_ID('tempdb.dbo.#DrugsByVisit') IS NOT NULL BEGIN DROP TABLE #DrugsByVisit END;

SELECT VL.Registry
      ,VL.RegistryName
	  ,VL.SiteID
      ,VL.SFSiteStatus
	  ,VL.EDCSiteStatus
	  ,VL.SubjectID
	  ,VL.patientId
	  ,VL.eventCrfId
	  ,VL.birthYear
	  ,VL.ProviderID
	  ,VL.VisitType
	  ,VL.eventDefinitionId
	  ,VL.eventOccurrence
	  ,VL.VisitDate
  	  ,(SELECT MIN(VisitDate) FROM #VisitLog VL2 WHERE VL2.SubjectID=VL.SubjectID AND VL2.VisitDate > VL.VisitDate) AS NextVisitDate 
	  ,(SELECT MAX(VisitDate) FROM #VisitLog VL2 WHERE VL2.SubjectID=VL.SubjectID AND VL2.VisitDate < VL.VisitDate) AS PreviousVisitDate
	  ,CASE WHEN ISNULL(DL.Treatment, '')='' THEN 'No medication'
	   ELSE DL.Treatment
	   END AS Treatment
	  ,DL.OtherTreatment
	  ,DL.crfOccurrence
	  ,CASE WHEN ISNULL(Treatment, '')='' THEN 'N/A'
	   WHEN DrugStatus='Past use' THEN DrugStatus
	   WHEN DateStarted > DateStopped THEN 'Data entry error'
	   WHEN DateStarted = VisitDate THEN 'Drug started'
	   WHEN DateStarted < VisitDate AND ISNULL(DateStopped, '')='' THEN 'Current use'
	   WHEN DateStarted < VisitDate AND ISNULL(DateStopped, '') > VisitDate THEN 'Current use'
	   WHEN DateStopped <= VisitDate THEN 'Past use/stopped'
	   WHEN drugConfirmation='Initiated' THEN 'Drug started'
	   ELSE DrugStatus
	   END AS DrugStatus
	  ,DL.DateStarted
  	  ,DL.DateStopped
	  ,DL.DatePrescribed
	  ,DL.DosingStatus
	  ,DL.drugConfirmation
	  ,DL.indication
	  ,DL.ReasonStarted
	  ,DL.ReasonStopped
	  ,DL.ReasonNotStarted
	  ,CASE WHEN ISNULL(DL.drugDoseOther, '')<>'' THEN REPLACE(DL.drugDoseOther, ' (enter number)', '')
	   ELSE DL.drugDose
	   END AS drugDose
	  ,DL.drugDoseOther
	  ,DL.drugDoseTaperHigh
	  ,DL.drugDoseTaperLow
	  ,CASE WHEN ISNULL(DL.drugFrequencyOther, '')<>'' THEN REPLACE(DL.drugFrequencyOther, ' (enter number)', '')
	   ELSE DL.drugFrequency
	   END AS drugFrequency
	  ,DL.drugFrequencyOther
	  ,VL.CompletionStatus
INTO #DrugsByVisit
FROM #VisitLog VL
LEFT JOIN #DrugLog DL ON DL.SiteID=VL.SiteID AND DL.SubjectID=VL.SubjectID AND ISNULL(DL.Treatment, '')<>''

--ORDER BY VL.SubjectID, VisitType, VisitDate, crfOccurrence

--SELECT * FROM #DrugsByVisit ORDER BY SiteID, SubjectID, eventOccurrence, crfOccurrence



TRUNCATE TABLE [Reporting].[NMO750].[t_op_AllDrugs];

INSERT INTO [Reporting].[NMO750].[t_op_AllDrugs]
(
	   [Registry]
	  ,[RegistryName]
	  ,[SiteID]
	  ,[SFSiteStatus]
	  ,[EDCSiteStatus]
      ,[SubjectID]
      ,[PatientID]
	  ,[eventCrfId]
	  ,[birthYear]
	  ,[ProviderID]
      ,[VisitType]
	  ,[eventDefinitionId]
	  ,[eventOccurrence]
	  ,[VisitDate]
 	  ,[NextVisitDate]
	  ,[PreviousVisitDate]
      ,[Treatment]
      ,[OtherTreatment]
	  ,[crfOccurrence]
	  ,[DrugStatus]
	  ,[DateStarted]
	  ,[DateStopped]
	  ,[DatePrescribed]
	  ,[DosingStatus]
	  ,[drugConfirmation]
	  ,[indication]
	  ,[ReasonStarted]
	  ,[ReasonStopped]
	  ,[ReasonNotStarted]
	  ,[drugDose]
	  ,[drugDoseOther]
	  ,[drugDoseTaperHigh]
	  ,[drugDoseTaperLow]
	  ,[drugFrequency]
	  ,[drugFrequencyOther]
	  ,[CompletionStatus]
)

SELECT DISTINCT [Registry]
	  ,[RegistryName]
	  ,[SiteID]
	  ,[SFSiteStatus]
	  ,[EDCSiteStatus]
      ,[SubjectID]
      ,[PatientID]
	  ,[eventCrfId]
	  ,[birthYear]
	  ,[ProviderID]
      ,[VisitType]
	  ,[eventDefinitionId]
	  ,[eventOccurrence]
	  ,[VisitDate]
 	  ,[NextVisitDate]
	  ,[PreviousVisitDate]
      ,[Treatment]
      ,[OtherTreatment]
	  ,[crfOccurrence]
	  ,[DrugStatus]
	  ,[DateStarted]
	  ,[DateStopped]
	  ,[DatePrescribed]
	  ,[DosingStatus]
	  ,[drugConfirmation]
	  ,[indication]
	  ,[ReasonStarted]
	  ,[ReasonStopped]
	  ,[ReasonNotStarted]
	  ,[drugDose]
	  ,[drugDoseOther]
	  ,[drugDoseTaperHigh]
	  ,[drugDoseTaperLow]
	  ,[drugFrequency]
	  ,[drugFrequencyOther]
	  ,[CompletionStatus]
FROM #DrugsByVisit


--SELECT * FROM [Reporting].[NMO750].[t_op_AllDrugs] WHERE SubjectID='7046-0006' ORDER BY SiteID, SubjectID, VisitType, VisitDate, Treatment, OtherTreatment



END



GO
