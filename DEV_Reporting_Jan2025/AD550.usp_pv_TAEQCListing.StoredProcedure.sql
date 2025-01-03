USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_pv_TAEQCListing]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











 


-- =============================================================
-- Author:		Kaye Mowrey
-- Create date: 26Oct2022; Updated 30Jul2024
-- Description:	Procedure for AD-550 TAE Surveillance QC Listing
-- =============================================================


CREATE PROCEDURE [AD550].[usp_pv_TAEQCListing] AS


BEGIN
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_pv_TAEQCListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[reviewConfirmed] [nvarchar](50) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](50) NULL,
	[FUVisitDate] [date] NULL,
	[EventType] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[EventTerm] [nvarchar](350) NULL,
	[SpecifyEvent] [nvarchar](350) NULL,
	[EventOnsetDate] [date] NULL,
	[MDConfirmed] [nvarchar](30) NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[noEventExplain] [nvarchar](500) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[Serious] [nvarchar](10) NULL,
	[SeriousReason] [nvarchar](350) NULL,
	[IVAntiInfect] [nvarchar](10) NULL,
	[FUVisitTreatments] [nvarchar](1500) NULL,
	[OtherFUVisitTreatments] [nvarchar](1500) NULL,
	[EventTreatments] [nvarchar](1200) NULL,
	[OtherEventTreatments] [nvarchar](1200) NULL,
	[gender] [nvarchar](25) NULL,
	[yearOfBirth] [int] NULL,
	[race] [nvarchar](300) NULL,
	[ethnicity] [nvarchar](50) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](25) NULL,
	[SupportDocumentsNotUploadedReason] [nvarchar](500) NULL,
	[SupportDocsApproved] [nvarchar](20) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[PayEligibleStatus] [nvarchar](30) NULL,
	[DataEntryStatus] [nvarchar](50) NULL,
	[auditType] [nvarchar](25) NULL,
	[DateCreated] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Fractures] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[AD Drug Exposure] [datetime] NULL,
	[Other concurrent Drugs] [datetime] NULL,
	[Data Entry Completion] [datetime] NULL,
	[Supporting Documents Approval] [datetime] NULL,
	[Case Processing] [datetime] NULL
) ON [PRIMARY]
GO
*/

/****Get Subjects and Site information****/

IF OBJECT_ID('tempdb.dbo.#SubjectSite1') IS NOT NULL BEGIN DROP TABLE #SubjectSite1 END

SELECT SiteID,
       SubjectID,
	   patientId,
	   [status],
	   CASE WHEN gender=0 THEN 'male'
	   WHEN gender=1 THEN 'female'
	   ELSE CAST(gender AS varchar)
	   END AS gender,
	   yearOfBirth,
	   race,
	   ethnicity
INTO #SubjectSite1
FROM
(
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'American Indian or Alaskan Native' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] = 'Enrolled'
AND S2.race_native_am=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Asian' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status]  = 'Enrolled'
AND S2.race_asian=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Black/African American' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] = 'Enrolled'
AND S2.race_black=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Native Hawaiian or Other Pacific Islander' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] = 'Enrolled'
AND S2.race_pacific=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'White' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status]  = 'Enrolled'
AND S2.race_white=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Other' + ': ' + S2.race_oth_txt AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] = 'Enrolled'
AND S2.race_other=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,NULL AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] = 'Enrolled'
AND (ISNULL(S2.race_other, '')='' AND ISNULL(S2.race_white, '')='' AND ISNULL(S2.race_pacific, '')='' AND ISNULL(S2.race_black, '')='' AND ISNULL(S2.race_asian, '')='' AND ISNULL(S2.race_native_am, '')='')
) subjects

--SELECT * FROM #SubjectSite1 WHERE SubjectID='AD-1440-0055'


IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END

/**group multiple race responses to one line**/

SELECT DISTINCT SiteID,
       SubjectID,
	   patientId,
	   [status],
	   gender,
	   yearOfBirth,
	   STUFF((
	   SELECT DISTINCT ', ' + race
	   FROM #SubjectSite1 S1
	   WHERE S1.patientId=#SubjectSite1.patientId
	   FOR XML PATH('')
        )
        ,1,1,'') AS race,
	  ethnicity
	  
INTO #SubjectSite
FROM #SubjectSite1

--SELECT * FROM #SubjectSite WHERE SubjectID='AD-1440-0055'


IF OBJECT_ID('tempdb.dbo.#TAEDRUGS') IS NOT NULL BEGIN DROP TABLE #TAEDRUGS END

/**Get drugs reported at corresponding follow-up visits per event, with a separate line(s) lines for each drug for the specific event. These drugs will be 'stuffed' into one comma-separated line later in this procedure**/

SELECT DISTINCT SiteID,
       SubjectID,
	   PatientID,
	   eventName,
	   eventId,
	   eventOccurrence,
	   onsetDate,
	   whenReported,
	   ReportedVisitDate,
	   FUeventOccurrence,
	   FUVisitDate,
	   DrugVisitDate,
	   DrugVisitOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentStatus
INTO #TAEDRUGS
FROM
(
--when TAE is reported at enrollment visit or between visits with onset date=enrollment visit date, pull in all drugs at enrollment regardless of status at enrollment
SELECT DISTINCT subNum AS SubjectID,
       EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN tae_rpt_status=2 THEN 'Between registry visits'
			WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI 
JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum AND (VL.VisitSequence=0 AND VL.VisitDate=ISNULL(EI.tae_onset_dt, '') AND ISNULL(EI.tae_dt_rpt, '')='') 
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=VL.SubjectID AND D.VisitSequence=VL.VisitSequence
WHERE VL.VisitSequence=0

 UNION

--when TAE is reported at FU Visit and there is a corresponding FU Visit Date OR TAE is reported between visits and onset date=Visit Date, get drugs listed at that visit and prior visit REGARDLESS of TreatmentStatus unless prior visit is enrollment, then only get drugs that are current or started (not stopped, not past) - NOTE: Because any current, modified or started drug is collected in a later CTE, do not pull in drugs if visitOccurrence=0 and they will be gathered later

SELECT DISTINCT subNum AS SubjectID,
       EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN tae_rpt_status=2 THEN 'Between registry visits'
			WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum AND (VL.VisitDate=EI.tae_dt_rpt OR VL.VisitDate=EI.tae_onset_dt)
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=VL.SubjectID AND (D.VisitEventOccurrence=VL.eventOccurrence OR D.VisitEventOccurrence=VL.eventOccurrence-1)
WHERE D.eventOccurrence<>0

UNION

--WHEN TAE is reported at an Exit Visit and there is a corresponding Exit Visit Date get drugs listed prior to that visit where treatment status is not stopped or no longer in use and has no stop date

SELECT DISTINCT subNum AS SubjectID,
       EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN tae_rpt_status=2 THEN 'Between registry visits'
			WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN tae_rpt_status=1 THEN EI.[tae_dt_rpt] 
	        WHEN tae_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=EI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if event reported with exit visit
			ELSE EI.[tae_dt_rpt]
			END AS ReportedVisitDate,--tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum AND VL.eventId=8045
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=VL.SubjectID AND (D.VisitDate<VL.VisitDate) AND ((ISNULL(D.StopDate, '')='') OR (ISNULL(D.StopDate, '')<>'' AND 
D.StartDate<D.StopDate AND D.StopDate >= D.VisitDate)) 
WHERE tae_rpt_status=3 AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND D.TreatmentStatus NOT IN ('Stop/discontinue drug', 'Not applicable (no longer in use)')

UNION

--WHEN TAE is reported at an Exit Visit and there is a corresponding Exit Visit Date get drugs listed at the Exit Visit regardless of status

SELECT DISTINCT subNum AS SubjectID,
       EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN tae_rpt_status=2 THEN 'Between registry visits'
			WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN tae_rpt_status=1 THEN EI.[tae_dt_rpt] 
	        WHEN tae_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=EI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if event reported with exit visit
			ELSE EI.[tae_dt_rpt]
			END AS ReportedVisitDate,--tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum AND VL.eventId=8045
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=VL.SubjectID AND (D.VisitDate=VL.VisitDate) AND D.eventId=8045
WHERE tae_rpt_status=3 AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')

UNION

--WHEN TAE is reported at FU Visit or Exit Visit and there is a corresponding FU Visit Date OR TAE is reported between visits and onset date=Visit Date get drugs listed prior to that visit where treatment status is not stopped or no longer in use and has no stop date

SELECT DISTINCT subNum AS SubjectID,
       EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN tae_rpt_status=2 THEN 'Between registry visits'
			WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN tae_rpt_status=1 THEN EI.[tae_dt_rpt] 
	        WHEN tae_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=EI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if event reported with exit visit
			ELSE EI.[tae_dt_rpt]
			END AS ReportedVisitDate,--tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI                    
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum AND (VL.VisitDate=EI.tae_dt_rpt OR VL.VisitDate=EI.tae_onset_dt)
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=VL.SubjectID AND (D.VisitDate<VL.VisitDate) AND ((ISNULL(D.StopDate, '')='') OR (ISNULL(D.StopDate, '')<>'' AND 
D.StartDate<D.StopDate AND D.StopDate >= D.VisitDate)) 
WHERE D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')

UNION

--WHEN TAE is reported between registry visits or with FU where the FU date reported does not match a visit FU date and onset date <> a FU visit date, uses Onset date as marker for corresponding follow-ups and pulls all drugs from previous and next visits regardless of treatment status

SELECT subNum AS SubjectID,
	   EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
       WHEN tae_rpt_status=2 THEN 'Between registry visits'
	   WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.eventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum AND VL.VisitDate=EI.tae_dt_rpt
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=EI.subNum AND EI.tae_onset_dt NOT IN (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=D.SubjectID) AND
(
D.VisitDate=(SELECT MAX(VisitDate) FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate<=EI.tae_onset_dt)
OR D.VisitDate=(SELECT MIN(VisitDate) FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate>EI.tae_onset_dt)
)
WHERE ((tae_rpt_status IN (2) AND ISNULL(tae_onset_dt, '')<>'') OR
(EI.tae_rpt_status=1 AND ISNULL(EI.tae_dt_rpt, '')='' AND ISNULL(tae_onset_dt, '')<>'') OR 
(EI.tae_rpt_status=1 AND ISNULL(EI.tae_dt_rpt, '')<>'' AND ISNULL(tae_onset_dt, '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=EI.subNum AND (V.VisitDate=EI.tae_dt_rpt OR V.VisitDate=EI.tae_onset_dt))))
AND ISNULL(D.VisitDate, '')<>''
AND D.VisitEventOccurrence<>0
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')

UNION

--WHEN TAE is reported between registry visits that does not have a date or date that does not match an actual follow-up. Uses Onset date as marker for corresponding follow-ups and pulls all drugs from visits prior to the onset date that are reported current or started and not stopped
SELECT DISTINCT subNum AS SubjectID,
	   EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   tae_onset_dt AS onsetDate,
	   CASE WHEN tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
       WHEN tae_rpt_status=2 THEN 'Between registry visits'
	   WHEN tae_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   tae_dt_rpt AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.eventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=EI.subNum and VL.VisitDate=EI.tae_dt_rpt
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=EI.subNum 
AND D.VisitDate<=(SELECT MAX(VisitDate) FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate<=EI.tae_onset_dt)
WHERE ((tae_rpt_status IN (2) AND ISNULL(tae_onset_dt, '')<>'') OR
(EI.tae_rpt_status=1 AND ISNULL(EI.tae_dt_rpt, '')='' AND ISNULL(tae_onset_dt, '')<>'') OR 
(EI.tae_rpt_status=1 AND ISNULL(EI.tae_dt_rpt, '')<>'' AND ISNULL(tae_onset_dt, '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=EI.subNum and V.VisitDate=EI.tae_dt_rpt)))
AND ISNULL(D.VisitDate, '')<>''
AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')
AND (D.StopDate IS NULL OR D.StopDate>EI.tae_onset_dt)
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')

UNION

SELECT DISTINCT P.SubjectID,
       P.PatientID,
	   P.siteName,
	   P.SiteID,
	   P.eventName,
	   P.eventId,
	   P.eventOccurrence,
	   P.OnsetDate,
	   P.whenReported,
	   P.ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate
FROM
(

--WHEN PEQ is reported With a FU Visit and there is a corresponding FU visit date, get drugs listed listed at that visit and prior visit regardless of TreatmentStatus

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   REPLACE(PEI.eventName, ' TAE', '') AS eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN peq_rpt_status=2 THEN 'Between registry visits'
			WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN peq_rpt_status=1 THEN PEI.[peq_dt_rpt] 
	        WHEN peq_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			ELSE PEI.[peq_dt_rpt]
			END AS ReportedVisitDate
FROM [RCC_AD550].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
) P
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=P.SubjectID and VL.VisitDate=P.ReportedVisitDate
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=P.SubjectID AND (D.eventOccurrence=VL.eventOccurrence OR D.eventOccurrence=VL.eventOccurrence-1)
WHERE whenReported IN ('With a Provider Follow-Up form') AND ISNULL(OnsetDate, '')<>'' AND ISNULL(D.TreatmentName, '')<>''
AND EXISTS(SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=P.SubjectID AND V.VisitDate=P.ReportedVisitDate)
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')


UNION

--WHEN PEQ is reported at an Exit Visit and there is a corresponding Exit Visit Date get drugs listed prior to that visit where treatment status is not stopped or no longer in use and has no stop date

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   REPLACE(PEI.eventName, ' TAE', '') AS eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN peq_rpt_status=2 THEN 'Between registry visits'
			WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   (SELECT VL.VisitDate WHERE VL.eventId=8045) AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=PEI.subNum and VL.eventId=8045 AND PEI.peq_rpt_status=3
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=PEI.subNum AND D.VisitDate<VL.VisitDate 
WHERE peq_rpt_status=3 
AND ISNULL(D.TreatmentName, '') NOT IN ('', 'Pending', 'No Data', 'No Treatment')
AND (D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug') 
OR ISNULL(D.StopDate, '')>VL.VisitDate)

UNION

--WHEN PEQ is reported at an Exit Visit and there is a corresponding Exit Visit Date get drugs listed at the Exit visit regardless of status

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   REPLACE(PEI.eventName, ' TAE', '') AS eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN peq_rpt_status=2 THEN 'Between registry visits'
			WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   (SELECT VL.VisitDate WHERE VL.eventId=8045) AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=PEI.subNum and VL.eventId=8045
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=PEI.subNum AND D.eventId=8045
WHERE peq_rpt_status=3 AND ISNULL(D.TreatmentName, '')<>''
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')

UNION

--WHEN PEQ is reported at an Exit Visit and there is a corresponding Exit Visit Date get drugs listed from the prior visit regardless of treatment status

SELECT SubjectID,
       PatientID,
	   siteName,
	   SiteID,
	   eventName,
	   eventId,
	   eventOccurrence,
	   onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Provider Follow-Up form'
	        WHEN peq_rpt_status=2 THEN 'Between registry visits'
			WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   ReportedVisitDate,
	   FUeventOccurrence,
	   FUVisitDate,
	   DrugVisitDate,
	   DrugVisitOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentStatus,
	   StartDate,
	   StopDate
FROM
(SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   REPLACE(PEI.eventName, ' TAE', '') AS eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   PEI.peq_rpt_status,
	   (SELECT VL.VisitDate WHERE VL.eventId=8045) AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   (SELECT VL.VisitDate WHERE VL.eventId=8045) AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=PEI.subNum AND PEI.peq_rpt_status=3 AND VL.eventId=8045
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=PEI.subNum AND ISNULL(D.TreatmentName, '') NOT IN ('Pending', 'No Data', 'No Treatment', '') 
WHERE PEI.peq_rpt_status=3
) EXIT2
WHERE DrugVisitDate=(SELECT MAX(VisitDate) FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=EXIT2.SubjectID AND D2.VisitDate<EXIT2.ReportedVisitDate)


UNION

--WHEN PEQ is reported at FU Visit and there is a corresponding FU Visit Date get drugs listed prior to that visit where treatment status is not stopped or no longer in use and has no stop date

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   REPLACE(PEI.eventName, ' TAE', '') AS eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Subject Enrollment or Follow-Up Form'
	        WHEN peq_rpt_status=2 THEN 'Between registry visits'
			WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN peq_rpt_status=1 THEN PEI.[peq_dt_rpt] 
	        WHEN peq_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			ELSE PEI.[peq_dt_rpt]
			END AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	  D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_AD550].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.SubjectID=PEI.subNum and VL.VisitDate<PEI.peq_dt_rpt
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=VL.SubjectID AND D.VisitDate<PEI.[peq_dt_rpt] AND D.eventOccurrence=VL.eventOccurrence AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug') AND (ISNULL(D.StopDate, '')='' OR (ISNULL(D.StopDate, '')<>'' AND D.StopDate>PEI.peq_dt_rpt)) 

WHERE peq_rpt_status=1 AND ISNULL(peq_dt_rpt, '')<>'' AND ISNULL(D.TreatmentName, '')<>''
AND EXISTS(SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=PEI.subNum AND V.VisitDate=PEI.peq_dt_rpt)
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')

UNION

--WHEN PEQ is reported between registry visits or has no corresponding Follow-up date entered, uses onset --Previous FU

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   PEI.eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Subject Enrollment or Follow-Up Form'
     	WHEN peq_rpt_status=2 THEN 'Between registry visits'
	 	WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	 	END AS whenReported,
	   CASE WHEN peq_rpt_status=1 THEN PEI.[peq_dt_rpt] 
	        WHEN peq_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			END AS ReportedVisitDate,
	   NULL AS FUeventOccurrence,
	   CAST(NULL AS date) AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate
	   
FROM [RCC_AD550].[staging].[pregnancyinfo] PEI
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [RCC_AD550].[api].[eventdefinitions] ED ON ED.[id]=PEI.eventId
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=PEI.subNum AND D.VisitDate<=PD.[peq_last_menstrual_dt] 
WHERE PEI.peq_report_type=1
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND ISNULL(D.VisitDate, '')<>''
AND ((PEI.peq_rpt_status IN (2) AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'') OR
(PEI.peq_rpt_status=1 AND ISNULL(PEI.peq_dt_rpt, '')='' AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'') OR 
(PEI.peq_rpt_status=1 AND ISNULL(PEI.peq_dt_rpt, '')<>'' AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=PEI.subNum and V.VisitDate=PEI.peq_dt_rpt)))

UNION

--WHEN PEQ has no corresponding Follow-up date entered, uses onset --Next FU

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   PEI.eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Subject Enrollment or Follow-Up Form'
     	WHEN peq_rpt_status=2 THEN 'Between registry visits'
	 	WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	 	END AS whenReported,
	   CASE WHEN peq_rpt_status=1 THEN PEI.[peq_dt_rpt] 
	        WHEN peq_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			END AS ReportedVisitDate,
	   NULL AS FUeventOccurrence,
	   CAST(NULL AS date) AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate
	   
FROM [RCC_AD550].[staging].[pregnancyinfo] PEI
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [RCC_AD550].[api].[eventdefinitions] ED ON ED.[id]=PEI.eventId
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=PEI.subNum 
AND D.VisitDate<=(SELECT MIN(VisitDate) FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate>(PD.[peq_last_menstrual_dt]))
WHERE PEI.peq_report_type=1
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND ISNULL(D.VisitDate, '')<>''
AND ((D.VisitType='Follow-up') OR (D.VisitType='Enrollment' AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')))
AND ((PEI.peq_rpt_status IN (2) AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'') OR
(PEI.peq_rpt_status=1 AND ISNULL(PEI.peq_dt_rpt, '')='' AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'') OR 
(PEI.peq_rpt_status=1 AND ISNULL(PEI.peq_dt_rpt, '')<>'' AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=PEI.subNum and V.VisitDate=PEI.peq_dt_rpt)))

UNION

--WHEN PEQ has no corresponding Follow-up date entered, uses onset --Any drugs started and not stopped prior to onset date

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   PEI.eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[peq_last_menstrual_dt] AS onsetDate,
	   CASE WHEN peq_rpt_status=1 THEN 'With a Subject Enrollment or Follow-Up Form'
     	WHEN peq_rpt_status=2 THEN 'Between registry visits'
	 	WHEN peq_rpt_status=3 THEN 'With a Subject Exit form'
	 	END AS whenReported,
	   CASE WHEN peq_rpt_status=1 THEN PEI.[peq_dt_rpt] 
	        WHEN peq_rpt_status=3 THEN (SELECT VisitDate FROM [AD550].[t_op_VisitLog] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			END AS ReportedVisitDate,
	   NULL AS FUeventOccurrence,
	   CAST(NULL AS date) AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate
	   
FROM [RCC_AD550].[staging].[pregnancyinfo] PEI
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [RCC_AD550].[api].[eventdefinitions] ED ON ED.[id]=PEI.eventId
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=PEI.subNum AND D.VisitDate<=PD.[peq_last_menstrual_dt]
WHERE PEI.peq_report_type=1
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')
AND ISNULL(D.VisitDate, '')<>''
AND ((PEI.peq_rpt_status IN (1, 2) AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'') OR
(PEI.peq_rpt_status=1 AND ISNULL(PEI.peq_dt_rpt, '')='' AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'') OR 
(PEI.peq_rpt_status=1 AND ISNULL(PEI.peq_dt_rpt, '')<>'' AND ISNULL(PD.[peq_last_menstrual_dt], '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] V WHERE V.SubjectID=PEI.subNum and V.VisitDate=PEI.peq_dt_rpt)))

) D


IF OBJECT_ID('tempdb.dbo.#Drugs') IS NOT NULL BEGIN DROP TABLE #Drugs END

SELECT DISTINCT SiteID,
	   SubjectID,
	   PatientID,
	   eventName,
	   eventId,
	   eventOccurrence,
	   onsetDate,
	   whenReported,
	   ReportedVisitDate,

	   STUFF((
	   SELECT DISTINCT ', ' + TreatmentName
	   FROM #TAEDRUGS T2
	   WHERE T2.SubjectID=TD.SubjectID
	   AND T2.eventId=TD.eventId
	   AND T2.eventOccurrence=TD.eventOccurrence
	   AND T2.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
	   FOR XML PATH('')),
        1,1,'') FUVisitTreatments,

	   STUFF((
	   SELECT DISTINCT ', ' + OtherTreatment
	   FROM #TAEDRUGS T2
	   WHERE T2.SubjectID=TD.SubjectID
	   AND T2.eventId=TD.eventId
	   AND T2.eventOccurrence=TD.eventOccurrence
	   AND T2.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherFUVisitTreatments
/*
	   STUFF((
	   SELECT DISTINCT ', ' + [drug_dec]
	   FROM [RCC_AD550].[staging].[addrugexposure] DE
	   WHERE DE.subNum=TD.SubjectID 
	   AND DE.subjectId=TD.PatientID 
	   AND DE.eventId=TD.eventId 
	   AND DE.eventOccurrence=TD.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS EventTreatments,

	  STUFF((
	   SELECT DISTINCT ', ' + [drug_other_specify]
	   FROM [RCC_AD550].[staging].[addrugexposure] DE
	   WHERE DE.subNum=TD.SubjectID 
	   AND DE.subjectId=TD.PatientID 
	   AND DE.eventId=TD.eventId 
	   AND DE.eventOccurrence=TD.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherEventTreatments
*/
INTO #Drugs
FROM #TAEDRUGS TD

--SELECT * FROM #TAEDrugs WHERE SubjectID='AD-1440-0055'

/**Get Created Date for Events**/

IF OBJECT_ID('tempdb.dbo.#TAEAudit') IS NOT NULL BEGIN DROP TABLE #TAEAudit END

SELECT Rownum,
       SiteID,
       SubjectID,
	   PatientID,
	   eventDefinitionId,
	   eventType,
	   eventOccurence,
	   crfCaption,
	   crfOrder,
	   crfOccurence,
	   'Audit Trail' AS auditType,
	   DateCreated

INTO #TAEAudit
FROM
(
SELECT ROW_NUMBER () OVER (PARTITION BY SubjectID, eventDefinitionId, eventOccurence ORDER BY SubjectID, eventDefinitionId, eventOccurence, DateCreated, crfOrder, crfOccurence) AS RowNum,
        SiteID,
		SubjectID,
		PatientID,
		eventDefinitionId,
		eventType,
		eventOccurence,
		crfCaption,
		crfOrder,
		crfId,
		crfOccurence,
		DateCreated

FROM
(
SELECT S.SiteID
      ,S.SubjectID
	  ,S.[patientId] AS PatientID
      ,EC.[eventDefinitionId]
	  ,REPLACE(ED.[name], ' TAE', '') AS eventType
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption] LIKE 'Fractures' THEN 15
	   WHEN EDI.[crfCaption]LIKE '%Details' THEN 20
	   WHEN EDI.[crfCaption]='AD Drug Exposure' THEN 30
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 40
	   WHEN EDI.[crfCaption]='Data Entry Completion' THEN 50
	   WHEN EDI.[crfCaption]='Supporting Documents Approval' THEN 60
	   WHEN EDI.[crfCaption]='Case Processing' THEN 70

	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  
      ,EC.[eventOccurence]  
	  ,MIN(AL.[auditDate]) AS DateCreated

  FROM [RCC_AD550].[api].[auditlogs] AL 
  LEFT JOIN [RCC_AD550].[api].[eventcrfs] EC ON AL.studyEventId=EC.studyEventId
  JOIN [RCC_AD550].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_AD550].[api].[eventdefinitions] ED ON ED.[id]=EDI.eventDefinitionsId
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId
  WHERE AL.studyEventId IN (SELECT [id] FROM [RCC_AD550].[api].[studyevents] WHERE eventDefinitionId IN (8035, 8036, 8037, 8038, 8039, 8040, 8041, 8042, 8043, 8044, 22814)) 
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] = 'Enrolled'

  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, ED.[name], EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence
) A
) B
 WHERE RowNum=1

 --SELECT * FROM #TAEAudit WHERE SubjectID='AD-1440-0055'

/****Get Created Date for Scheduled but not started Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit2') IS NOT NULL BEGIN DROP TABLE #TAEAudit2 END

SELECT B.SubjectID,
	   B.patientId,
       B.dateStart,
	   B.eventDefinitionId, 
	   B.[name] AS eventName,
	   B.eventOccurence AS eventOccurrence,
	   B.statusCode,
	   'Study Events Table' AS AuditType
INTO #TAEAudit2
FROM
(
SELECT SS.SubjectID
      ,DATEADD(SECOND, CAST([dateStart] as BIGINT)/1000 ,'1970/1/1') as dateStart 
      ,SE.[subjectId] AS patientId
      ,SE.[id]
      ,SE.[eventDefinitionId]
	  ,ED.[name]
      ,SE.[statusId]
      ,SE.[statusCode]
      ,SE.[eventOccurence]
  FROM [RCC_AD550].[api].[studyevents] SE
  LEFT JOIN #SubjectSite SS ON SS.patientId=SE.subjectId
  LEFT JOIN [RCC_AD550].[api].[eventdefinitions] ED ON ED.[id]=SE.eventDefinitionId
  WHERE eventDefinitionId IN (8035, 8036, 8037, 8038, 8039, 8040, 8041, 8042, 8043, 8044, 22814)
  AND statuscode='Scheduled'
  ) B
  WHERE SubjectID NOT IN (SELECT SubjectID FROM #TAEAudit TA WHERE TA.PatientID=B.patientId AND TA.eventDefinitionId=B.eventDefinitionId AND TA.eventOccurence=B.eventOccurence)

--SELECT * FROM #TAEAudit2 WHERE SubjectID='AD-1440-0055'

/***Get Last Modified Page and Date for Event***/

IF OBJECT_ID('tempdb.dbo.#LMDT') IS NOT NULL BEGIN DROP TABLE #LMDT END

SELECT RowNum,
       SiteID,
	   SubjectID,
	   PatientID,
	   eventDefinitionId,
	   eventOccurence,
	   crfCaption,
	   crfOrder,
	   crfId,
	   [crfOccurence],
	   LastModifiedDate,
	   reasonForChange

INTO #LMDT
FROM
(
SELECT ROW_NUMBER() OVER (PARTITION BY subjectId, eventDefinitionId, eventOccurence ORDER BY subjectId, eventDefinitionId, eventOccurence, crfOrder, LastModifiedDate DESC, crfOccurence) AS RowNum,
        SiteID,
		SubjectID,
		PatientID,
		eventDefinitionId,
		eventOccurence,
		crfCaption,
		crfOrder,
		crfId,
		[crfOccurence],
		LastModifiedDate,
		reasonForChange
FROM
(
SELECT S.SiteID
      ,S.SubjectID
	  ,S.[patientId] AS PatientID
      ,EC.[eventDefinitionId]
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption] LIKE 'Fractures' THEN 15
	   WHEN EDI.[crfCaption]='AD Drug Exposure' THEN 20
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 30
	   WHEN EDI.[crfCaption] LIKE '%Details' THEN 40
	   WHEN EDI.[crfCaption]='Data Entry Completion' THEN 50
	   WHEN EDI.[crfCaption]='Supporting Documents Approval' THEN 60
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject\
	  ,MAX(AL.[auditDate]) AS LastModifiedDate
	  ,AL.reasonForChange

  FROM [RCC_AD550].[api].[eventcrfs] EC
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId
  JOIN [RCC_AD550].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_AD550].[api].[auditlogs] AL ON AL.subjectId=EC.subjectId AND AL.eventCrfId=EC.[id] AND AL.reasonForChange NOT IN ('Event Custom Label Changed', 'Form Custom Label Changed', 'CRF Custom Label Changed') 
  WHERE eventDefinitionId IN (8035, 8036, 8037, 8038, 8039, 8040, 8041, 8042, 8043, 8044, 22814)
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence, AL.reasonForChange
) A 
) B 

--SELECT * FROM #LMDT ORDER BY SiteID, SubjectID, eventDefinitionId, eventOccurence, rowNum

/***Group Last Modified Page and Date for Event***/

IF OBJECT_ID('tempdb.dbo.#LMDTGroup') IS NOT NULL BEGIN DROP TABLE #LMDTGroup END

SELECT C.crfRowNum,
       C.SiteID,
	   C.SubjectID,
	   C.PatientID,
	   C.eventDefinitionId,
	   C.eventOccurence,
	   C.crfCaption,
	   C.crfOrder,
	   C.crfId,
	   C.crfOccurence,
	   TA.auditType,
	   TA.DateCreated,
	   C.LastModifiedDate,
	   C.reasonForChange
INTO #LMDTGroup
FROM
(
SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY SubjectID, PatientID, eventDefinitionId, eventOccurence, crfId ORDER BY SubjectID, eventDefinitionId, eventOccurence, crfOrder, LastModifiedDate DESC) AS crfRowNum,
SiteID, 
SubjectID, 
PatientID, 
eventDefinitionId, 
eventOccurence, 
crfCaption, 
crfOrder, 
crfId, 
crfOccurence, 
LastModifiedDate,
reasonForChange

FROM #LMDT
) C 
LEFT JOIN #TAEAudit TA ON TA.SubjectID=C.SubjectID AND TA.eventDefinitionId=C.eventDefinitionId AND TA.eventOccurence=C.eventOccurence 
WHERE C.crfRowNum=1

--select * from #LMDTGroup where subjectid='AD-1440-0055' and crfCaption='Case Processing'

IF OBJECT_ID('tempdb.dbo.#ReasonSerious') IS NOT NULL BEGIN DROP TABLE #ReasonSerious END

/**Get reason for TAE serious to put in one column separated by commas**/

SELECT SubjectID
	  ,FUVisitDate
	  ,eventName
	  ,eventId
	  ,eventOccurrence
	  ,crfName
	  ,eventCrfId
	  ,seriousReason
INTO #ReasonSerious
FROM
(
SELECT EI.subNum AS SubjectID
	  ,EI.[tae_dt_rpt] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [tae_ser_out_hosp]=1 THEN 'Hospitalization (new or prolonged)' 
	   ELSE NULL END AS seriousReason
FROM [RCC_AD550].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[tae_dt_rpt] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [tae_ser_out_life_threat]=1 THEN 'Immediately life threatening' 
	   ELSE NULL END AS seriousReason
FROM [RCC_AD550].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[tae_dt_rpt] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [tae_ser_out_death]=1 THEN 'Death' 
	   ELSE NULL END AS seriousReason
FROM [RCC_AD550].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[tae_dt_rpt] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [tae_ser_out_disability]=1 THEN 'Persistent/significant disability or incapacity' 
	   ELSE NULL END AS seriousReason
FROM [RCC_AD550].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[tae_dt_rpt] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [tae_ser_out_defect_congenital]=1 THEN 'Congenital anomaly/birth defect' 
	   ELSE NULL END AS seriousReason
FROM [RCC_AD550].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[tae_dt_rpt] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [tae_ser_out_md_serious]=1 THEN 'Provider deems as serious, important medical event' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_AD550].[staging].[eventinfo] EI

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_pn_inf]=1 THEN 'Post-natal serious infection' 
	   ELSE CAST([peq_ser_out_pn_inf] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_pp_inf]=1 THEN 'Serious post-partum infection' 
	   ELSE CAST([peq_ser_out_pp_inf] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_hosp]=1 THEN 'Hospitalization (maternal) during pregnancy' 
	   ELSE CAST([peq_ser_out_hosp] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_life_threat]=1 THEN 'Immediately life threatening' 
	   ELSE CAST([peq_ser_out_life_threat] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_death]=1 THEN 'Maternal death' 
	   ELSE CAST([peq_ser_out_death] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_disability]=1 THEN 'Persistent/significant maternal disability for incapacity' 
	   ELSE CAST([peq_ser_out_disability] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[peq_dt_rpt] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peq_ser_out_md_serious]=1 THEN 'Provider deems as serious, important maternal medical event' 
	   ELSE CAST([peq_ser_out_md_serious] AS nvarchar)
	   END AS seriousReason
FROM [RCC_AD550].[staging].[pregnancyinfo] PEQ

) A
WHERE seriousReason IS NOT NULL


/****Get fracture locations to stuff in TAEOutcomes****/

IF OBJECT_ID('tempdb.dbo.#Fractures') IS NOT NULL BEGIN DROP TABLE #Fractures END

SELECT DISTINCt subNum
	  ,eventId
	  ,eventOccurrence
	  ,crfOccurrence
	  ,eventName
	  ,frac_location_dec
	  ,frac_other_specify
	  ,CASE WHEN frac_location_dec LIKE '%(specify)%' THEN frac_location_dec + ', ' + frac_other_specify
	   WHEN frac_location_dec='Spine' THEN frac_location_dec + ', ' + frac_spine_specify_dec
	   WHEN ISNULL(frac_location_dec, '')='' AND ISNULL(frac_other_specify, '')<>'' THEN 'Location not entered,' + ' ' + frac_other_specify
	   ELSE frac_location_dec
	   END AS fracture_location
	  ,frac_spine_specify_dec

INTO #Fractures
FROM [RCC_AD550].[staging].[fractures] F

--SELECT * FROM #FRACTURES


/****Get TAEs and TAE outcomes for all TAEs except pregnancy****/

IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

SELECT SubjectID,
       PatientID,
	   ProviderID,
	   EventType,
	   EventTerm,
	   COALESCE(SpecifyEvent, fracture_location) AS SpecifyEvent,
	   EventOnsetDate,
	   MDConfirmed,
	   ConfirmationStatus,
	   noEventExplain,
	   hasData,
	   eventId,
	   eventCrfId,
	   eventOccurrence,
	   crfName,
	   firstReportedVia,
	   FUVisitDate,
	   Outcome,
	   Serious,
	   SeriousReason,
	   IVAntiInfect,
	   FUVisitTreatments,
	   OtherFUVisitTreatments,
	   EventTreatments,
	   OtherEventTreatments,
	   SupportingDocuments,
	   SupportingDocumentsUploaded,
	   CASE WHEN ISNULL(tae_docs_reason_other, '')<>'' THEN SupportDocumentsNotUploadedReason + ', ' + tae_docs_reason_other
	   ELSE SupportDocumentsNotUploadedReason
	   END AS SupportDocumentsNotUploadedReason,
	   SupportDocsApproved,
	   EventPaid,
	   SourceDocsPaid
INTO #TAEOutcomes
FROM
(
SELECT EI.subNum AS SubjectID
      ,EI.subjectId AS PatientID
	  ,EI.tae_md_cod AS ProviderID
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,COALESCE([tae_vte_event_type_dec], [tae_ser_event_type_dec], [tae_eye_event_type_dec], [tae_hep_event_type_dec], [tae_gen_event_type_dec], [tae_c19_event_type_dec], [tae_cvd_event_type_dec], [tae_can_event_type_dec], [tae_ana_event_type_dec], EI.tae_frac_event_type_dec) AS EventTerm
	  ,EI.tae_event_type_specify AS SpecifyEvent

	  ,STUFF((
	   SELECT DISTINCT '; ' + fracture_location
	   FROM #Fractures F
	   WHERE F.subNum=EI.subNum
	         AND EI.eventId=22814 AND EI.eventId=F.eventId 
			 AND F.eventOccurrence=EI.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS fracture_location

	  ,EI.[tae_onset_dt] AS EventOnsetDate
	  ,EI.[tae_confirm_md_confirmed] AS MDConfirmed
	  ,CASE WHEN tae_status=1 THEN 'Confirmed event'
	   WHEN tae_status=2 THEN 'Previously reported'
	   WHEN tae_status=3 THEN 'Not an event'
	   ELSE ''
	   END AS ConfirmationStatus
	  ,EI.[tae_noevent_explain] AS noEventExplain
	  ,CASE WHEN EI.hasData=1 THEN 'Yes'
	   WHEN EI.hasData=0 THEN 'No'
	   ELSE CAST(EI.hasData AS varchar)
	   END AS hasData
	  ,EI.eventId
	  ,EI.eventCrfId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,CASE WHEN EI.tae_rpt_status=1 THEN 'With a Provider Follow-Up form'
	   WHEN EI.tae_rpt_status=2 THEN 'Between registry visits'
	   WHEN EI.tae_rpt_status=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia

	  ,CASE WHEN EI.tae_rpt_status=3 THEN (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] VL WHERE VL.SubjectID=EI.subNum AND VL.eventId=8045)
	   ELSE EI.tae_dt_rpt
	   END AS FUVisitDate

	  ,CASE WHEN EI.[tae_outcome_status]=1 THEN 'Death'
	   WHEN EI.[tae_outcome_status]=2 THEN 'Ongoing event'
	   WHEN EI.[tae_outcome_status]=3 THEN 'Recovered no sequelae'
	   WHEN EI.[tae_outcome_status]=4 THEN 'Recovered with sequelae'
	   WHEN EI.[tae_outcome_status]=97 THEN 'Unknown'
	   ELSE NULL
	   END AS Outcome

	   ,CASE WHEN EI.tae_ser_out_any=1 THEN 'Yes'
	    WHEN EI.tae_ser_out_any=0 THEN 'No'
	    ELSE CAST(EI.tae_ser_out_any AS varchar)
	    END AS Serious

	   ,STUFF((
        SELECT DISTINCT ', ' + seriousReason
        FROM #ReasonSerious RS
		WHERE RS.SubjectID=EI.subNum
		AND RS.eventId=EI.eventId
		AND RS.eventOccurrence=EI.eventOccurrence
		AND RS.crfName=EI.crfName
		AND RS.eventName=EI.[eventName]
		AND RS.eventCrfId=EI.eventCrfId
        FOR XML PATH('')
        )
        ,1,1,'') AS SeriousReason

	  ,CASE WHEN TAEINF.ser_antibiotics_inpatient_iv=1 THEN 'yes'
	   WHEN TAEINF.ser_antibiotics_inpatient_iv=0 THEN 'no'
	   ELSE NULL
	   END AS IVAntiInfect
	  ,D.FUVisitTreatments
	  ,D.OtherFUVisitTreatments

	   ,STUFF((
	   SELECT DISTINCT ', ' + [drug_dec]
	   FROM [RCC_AD550].[staging].[addrugexposure] DE
	   WHERE DE.subNum=EI.subNum 
	   AND DE.subjectId=EI.subjectId 
	   AND DE.eventId=EI.eventId 
	   AND DE.eventOccurrence=EI.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS EventTreatments

	  ,STUFF((
	   SELECT DISTINCT ', ' + [drug_other_specify]
	   FROM [RCC_AD550].[staging].[addrugexposure] DE
	   WHERE DE.subNum=EI.subNum 
	   AND DE.subjectId=EI.subjectId 
	   AND DE.eventId=EI.eventId 
	   AND DE.eventOccurrence=EI.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherEventTreatments

	  ,CASE WHEN EI.tae_support_docs=1 THEN 'Are attached'
	   WHEN EI.tae_support_docs=2 THEN 'Will be submitted separately'
	   WHEN EI.tae_support_docs=3 THEN 'Will not be submitted'
	   ELSE NULL
	   END AS SupportingDocuments

	  ,CASE WHEN ISNULL(EI.tae_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded

	  ,CASE WHEN EI.tae_support_docs_reason_not=1 THEN 'Hospital would not fax or release documents'
	   WHEN EI.tae_support_docs_reason_not=2 THEN 'Patient would not authorize release of records'
	   WHEN EI.tae_support_docs_reason_not=3 THEN 'Other reason'
	   ELSE CAST(EI.tae_support_docs_reason_not AS varchar)
	   END AS SupportDocumentsNotUploadedReason
	  ,EI.tae_docs_reason_other
	  ,CASE WHEN SDA.[taepay_support_docs_approved]=1 THEN 'Yes'
	   WHEN SDA.[taepay_support_docs_approved]=0 THEN 'No'
	   WHEN ISNULL(SDA.[taepay_support_docs_approved], '')='' THEN 'No'
	   ELSE CAST(SDA.[taepay_support_docs_approved] AS varchar)
	   END AS SupportDocsApproved
	  ,REIMB.taepay_event_status AS EventPaid
	  ,REIMB.taepay_support_docs_paid AS SourceDocsPaid

FROM [RCC_AD550].[staging].[eventinfo] EI
LEFT JOIN [RCC_AD550].[staging].[seriousinfectiondetails] TAEINF ON TAEINF.subNum=EI.subNum AND TAEINF.eventId=EI.eventId AND TAEINF.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=EI.subjectId AND REIMB.eventId=EI.eventId AND REIMB.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[supportingdocumentsapproval] SDA ON SDA.subjectId=EI.subjectId AND SDA.eventId=EI.eventId AND SDA.[eventOccurrence]=EI.eventOccurrence
LEFT JOIN #Drugs D ON D.patientId=EI.subjectId AND D.eventId=EI.eventId AND D.eventOccurrence=EI.eventOccurrence
) A

--SELECT * FROM #TAEOUTCOMES WHERE EventType='Fracture'


/****Get Pregnancy TAE information including outcomes****/

IF OBJECT_ID('tempdb.dbo.#PREG') IS NOT NULL BEGIN DROP TABLE #PREG END

SELECT DISTINCT SiteID,
       SubjectID,
	   PatientID,
	   statusCode,
	   peq_reviewer_conf_confirmed,
	   ProviderID,
	   firstReportedVia,
	   FUVisitDate,
	   EventType,
	   eventId,
	   eventOccurrence,
	   crfName,
	   eventCrfId,
	   EventTerm,
	   SpecifyEvent,
	   OnsetDate,
	   MDConfirmed,
	   ConfirmationStatus,
	   noEventExplain,
	   hasData,
	   Outcome,
	   Serious,
	   SeriousReason,
	   IVAntiInfect,
	   FUVisitTreatments,
	   OtherFUVisitTreatments,
	   EventTreatments,
	   OtherEventTreatments,
	   gender,
	   yearOfBirth,
	   race,
	   ethnicity,
	   SupportingDocuments,
	   SupportingDocumentsUploaded,
	   CASE WHEN ISNULL([peq_docs_reason_other], '')<>'' THEN SupportDocumentsNotUploadedReason + ', ' + [peq_docs_reason_other]
	   ELSE SupportDocumentsNotUploadedReason
	   END AS SupportDocumentsNotUploadedReason,
	   SupportDocsApproved,
	   EventPaid,
	   SourceDocsPaid,
	   eventDefinitionId
INTO #PREG
FROM
(
SELECT SS.SiteID
      ,TAEP.subNum AS SubjectID
      ,TAEP.subjectId AS PatientID
	  ,CASE WHEN ISNULL(DE.statusCode,'')='' THEN 'No Data'
	   ELSE DE.statusCode
	   END AS statusCode
	  ,DE.peq_reviewer_conf_confirmed
	  ,TAEP.peq_md_cod AS ProviderID
	  ,CASE WHEN TAEP.peq_rpt_status=1 THEN 'With a Subject Enrollment or Follow-Up Form'
	   WHEN TAEP.peq_rpt_status=2 THEN 'Between registry visits'
	   WHEN TAEP.peq_rpt_status=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia

	 ,CASE WHEN TAEP.peq_rpt_status=3 THEN (SELECT VisitDate FROM [Reporting].[AD550].[t_op_VisitLog] VL WHERE VL.SubjectID=TAEP.subNum AND VL.eventId=8045)
	  ELSE TAEP.peq_dt_rpt
	  END AS FUVisitDate

	  ,TAEP.eventName AS EventType
	  ,TAEP.eventId
	  ,TAEP.eventOccurrence
	  ,TAEP.crfName
	  ,TAEP.eventCrfId
	  ,'Pregnancy' AS EventTerm
	  ,'' AS SpecifyEvent
	  ,PD.[peq_last_menstrual_dt] AS onsetDate
	  ,NULL AS MDConfirmed
	  ,CASE WHEN TAEP.peq_report_type=1 THEN 'Confirmed event'
	   WHEN TAEP.peq_report_type=2 THEN 'Previously reported'
	   WHEN TAEP.peq_report_type=3 THEN 'Not an event'
	   ELSE CAST(NULL AS nvarchar)
	   END AS ConfirmationStatus
	  ,TAEP.peq_report_noevent_exp AS noEventExplain
	  ,CASE WHEN TAEP.hasData=1 THEN 'Yes'
	   WHEN TAEP.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
	  ,'' AS Outcome
	  ,CASE WHEN [peq_ser_out_any]=0 THEN 'No'
	   WHEN [peq_ser_out_any]=1 then 'Yes'
	   ELSE CAST([peq_ser_out_any] AS nvarchar)
	   END AS Serious
	  ,STUFF((
        SELECT DISTINCT ', ' + seriousReason
        FROM #ReasonSerious RS
		WHERE RS.SubjectID=TAEP.subNum
		AND RS.eventId=TAEP.eventId
		AND RS.eventOccurrence=TAEP.eventOccurrence
		AND RS.crfName=TAEP.crfName
		AND RS.eventName=TAEP.[eventName]
		AND RS.eventCrfId=TAEP.eventCrfId
        FOR XML PATH('')
        )
        ,1,1,'') AS SeriousReason
	  ,'' AS IVAntiInfect
	  ,D.FUVisitTreatments
	  ,D.OtherFUVisitTreatments

	   ,STUFF((
	   SELECT DISTINCT ', ' + [drug_dec]
	   FROM [RCC_AD550].[staging].[addrugexposure] DE
	   WHERE DE.subNum=TAEP.subNum 
	   AND DE.subjectId=TAEP.subjectId 
	   AND DE.eventId=TAEP.eventId 
	   AND DE.eventOccurrence=TAEP.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS EventTreatments

	  ,STUFF((
	   SELECT DISTINCT ', ' + [drug_other_specify]
	   FROM [RCC_AD550].[staging].[addrugexposure] DE
	   WHERE DE.subNum=TAEP.subNum 
	   AND DE.subjectId=TAEP.subjectId 
	   AND DE.eventId=TAEP.eventId 
	   AND DE.eventOccurrence=TAEP.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherEventTreatments
	  ,SS.gender
	  ,SS.yearOfBirth
	  ,SS.race
	  ,SS.ethnicity
	  ,TAEP.peq_support_docs AS SupportingDocuments
	  ,CASE WHEN ISNULL(TAEP.peq_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN TAEP.peq_support_docs_reason_not=1 THEN 'Hospital would not fax or release documents'
	   WHEN TAEP.peq_support_docs_reason_not=2 THEN 'Patient would not authorize release of records'
	   WHEN TAEP.peq_support_docs_reason_not=3 THEN 'Other reason' + ', ' + [peq_docs_reason_other]
	   ELSE CAST(TAEP.peq_support_docs_reason_not AS varchar)
	   END AS SupportDocumentsNotUploadedReason
	  ,[peq_docs_reason_other]
	  ,'n/a' AS SupportDocsApproved
	  ,REIMB.taepay_event_status AS EventPaid
	  ,REIMB.taepay_support_docs_paid AS SourceDocsPaid
	  ,TA.eventDefinitionId
	  ,TA.eventOccurence

FROM [RCC_AD550].[staging].[pregnancyinfo] TAEP
LEFT JOIN [RCC_AD550].[staging].[pregnancydetails] PD ON PD.subNum=TAEP.subNum AND PD.eventId=TAEP.eventId AND PD.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #SubjectSite SS ON SS.PatientID=TAEP.subjectId
LEFT JOIN [RCC_AD550].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=TAEP.subjectId 
     AND REIMB.eventId=TAEP.eventId AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subjectId=TA.PatientID AND TA.eventDefinitionId=TAEP.eventId and TA.eventOccurence=TAEP.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[supportingdocumentsapproval] SDA ON SDA.subjectId=TAEP.subjectId AND SDA.eventId=TAEP.eventId AND SDA.[eventOccurrence]=TAEP.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] DE ON DE.subjectId=TAEP.subjectId AND DE.eventId=TAEP.eventId AND DE.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #Drugs D ON D.SubjectID=TAEP.subNum AND D.eventId=TAEP.eventId AND D.eventOccurrence=TAEP.eventOccurrence
WHERE SS.[status] = 'Enrolled'
) B

IF OBJECT_ID('tempdb.dbo.#TAE') IS NOT NULL BEGIN DROP TABLE #TAE END

/****Get TAEs information for all but pregnancy****/

SELECT DISTINCT SS.SiteID,
       SS.SubjectID,
       SS.PatientID,
	   A.statusCode,
	   A.tae_reviewer_confirmation_confirmed,
	   A.ProviderID,
	   A.firstReportedVia,
	   A.FUVisitDate,
	   A.EventType,
	   A.eventId,
	   A.eventOccurrence,
	   A.crfName,
	   A.eventCrfId,
	   A.EventTerm,
	   A.SpecifyEvent,
	   A.EventOnsetDate,
	   A.MDConfirmed,
	   A.ConfirmationStatus,
	   A.noEventExplain,
	   A.hasData,
	   A.Outcome,
	   A.Serious,
	   A.SeriousReason,
	   A.IVAntiInfect,
	   A.FUVisitTreatments,
	   A.OtherFUVisitTreatments,
	   A.EventTreatments,
	   A.OtherEventTreatments,
	   A.SupportingDocuments,
	   A.SupportingDocumentsUploaded,
	   A.SupportDocumentsNotUploadedReason,
	   A.SupportDocsApproved,
	   A.EventPaid,
	   A.SourceDocsPaid,
	   SS.gender,
	   SS.yearOfBirth,
	   SS.race,
	   SS.ethnicity

INTO #TAE
FROM 
(
SELECT TAE.SubjectID
      ,TAE.PatientID
	  ,DE.[statusCode] AS statusCode
	  ,DE.tae_reviewer_confirmation_confirmed
	  ,TAE.ProviderID
	  ,TAE.firstReportedVia
	  ,TAE.FUVisitDate
	  ,TAE.EventType
	  ,TAE.EventTerm
	  ,TAE.SpecifyEvent
	  ,TAE.eventId
	  ,TAE.eventOccurrence
	  ,TAE.crfName
	  ,TAE.eventCrfId
	  ,TAE.EventOnsetDate
	  ,TAE.MDConfirmed
	  ,TAE.ConfirmationStatus
	  ,TAE.noEventExplain
	  ,TAE.hasData
	  ,TAE.Outcome
	  ,TAE.Serious
	  ,TAE.SeriousReason
	  ,TAE.IVAntiInfect
	  ,TAE.FUVisitTreatments
	  ,TAE.OtherFUVisitTreatments
	  ,TAE.EventTreatments
	  ,TAE.OtherEventTreatments
	  ,TAE.SupportingDocuments
	  ,TAE.SupportingDocumentsUploaded
	  ,TAE.SupportDocumentsNotUploadedReason
	  ,TAE.SupportDocsApproved
	  ,TAE.EventPaid
	  ,TAE.SourceDocsPaid

FROM #TAEOutcomes TAE
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] DE ON DE.subNum=TAE.SubjectID AND DE.eventId=TAE.eventId AND DE.eventOccurrence=TAE.eventOccurrence
) A
LEFT JOIN #SubjectSite SS ON SS.PatientID=A.PatientID
WHERE SS.[status] = 'Enrolled'


IF OBJECT_ID('tempdb.dbo.#Events') IS NOT NULL BEGIN DROP TABLE #Events END

/****Put all data into one record****/

SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[statusCode],
	[reviewConfirmed],
	[ProviderID],
	[firstReportedVia],
	[FUVisitDate],
	[EventType],
    [eventId],
	[eventOccurrence],
	[crfName],
	[eventCrfId],
	[EventTerm],
	[SpecifyEvent],
	[EventOnsetDate],
	[MDConfirmed],
	[ConfirmationStatus],
	[noEventExplain],
	[hasData],
	[Outcome],
	[Serious],
	RTRIM(LTRIM([SeriousReason])) AS [SeriousReason],
	[IVAntiInfect],
	RTRIM(LTRIM([FUVisitTreatments])) AS [FUVisitTreatments],
	RTRIM(LTRIM([OtherFUVisitTreatments])) AS [OtherFUVisitTreatments],
	RTRIM(LTRIM([EventTreatments])) AS [EventTreatments],
	RTRIM(LTRIM([OtherEventTreatments])) AS [OtherEventTreatments],
	[gender],
	[yearOfBirth],
	RTRIM(LTRIM([race])) AS [race],
	[ethnicity],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[SupportDocumentsNotUploadedReason],
	[SupportDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[auditType],
	[DateCreated],
	[eventDefinitionId],
	[crfCaption],
	[crfOccurence],
	[crfId],
	[crfOrder],
	[LastModifiedDate]

INTO #EVENTS
FROM
(
SELECT DISTINCT Z.[SiteID],
	Z.[SubjectID],
	Z.[PatientID],
	Z.[statusCode],
	Z.[tae_reviewer_confirmation_confirmed] AS reviewConfirmed,
	Z.[ProviderID],
	Z.[firstReportedVia],
	Z.[FUVisitDate],
	Z.[EventType],
	Z.[eventId],
	Z.[eventOccurrence],
	Z.[crfName],
	Z.[eventCrfId],
	Z.[EventTerm],
	Z.[SpecifyEvent],
	Z.[EventOnsetDate],
	CASE WHEN [MDConfirmed]=1 THEN 'Confirmed event'
	WHEN [MDConfirmed]=2 THEN 'TAE previously reported (duplicate)'
	WHEN [MDConfirmed]=3 THEN 'Not an event'
	ELSE CAST(MDConfirmed AS varchar)
	END AS [MDConfirmed],
	Z.ConfirmationStatus,
	Z.noEventExplain,
	Z.[hasData],
	Outcome,
	Serious,
	SeriousReason,
	IVAntiInfect,
	FUVisitTreatments,
	OtherFUVisitTreatments,
	EventTreatments,
	OtherEventTreatments,
	gender,
	yearOfBirth,
	race,
	ethnicity,
	SupportingDocuments,
	[SupportingDocumentsUploaded],
	[SupportDocumentsnotUploadedReason],
	[SupportDocsApproved],
	CASE WHEN [EventPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [EventPaid],
	CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [SourceDocsPaid],
	X.[auditType],
	X.[DateCreated],
	X.[eventDefinitionId],
	X.[crfCaption],
	X.[crfOccurence],
	X.[crfId],
	X.[crfOrder],
	X.[LastModifiedDate]
FROM #LMDTGroup X
LEFT JOIN #TAE Z ON Z.PatientID=X.PatientID AND Z.eventId=X.eventDefinitionId AND Z.eventOccurrence=X.eventOccurence
WHERE X.eventDefinitionId<>8044
AND ISNULL(Z.SiteID, '')<>'' AND ISNULL(Z.SubjectID, '')<>''
AND X.DateCreated IS NOT NULL

UNION

SELECT DISTINCT M.[SiteID],
	M.[SubjectID],
	M.[PatientID],
	M.[statusCode],
	M.[peq_reviewer_conf_confirmed] AS reviewConfirmed,
	M.[ProviderID],
	M.[firstReportedVia],
	M.[FUVisitDate],
	M.[EventType],
	M.[eventId],
	M.[eventOccurrence],
	M.[crfName],
	M.[eventCrfId],
	M.[EventTerm],
	M.[SpecifyEvent],
	CAST([OnsetDate] AS date) AS EventOnsetDate,
	CASE WHEN [MDConfirmed]=1 THEN 'Confirmed event'
	WHEN [MDConfirmed]=2 THEN 'TAE previously reported (duplicate)'
	WHEN [MDConfirmed]=3 THEN 'Not an event'
	ELSE CAST(MDConfirmed AS varchar)
	END AS [MDConfirmed],
	ConfirmationStatus,
	noEventExplain,
	[hasData],
	'' AS Outcome,
	Serious,
	SeriousReason,
	IVAntiInfect,
	FUVisitTreatments,
	OtherFUVisitTreatments,
	EventTreatments,
	OtherEventTreatments,
	gender,
	yearOfBirth,
	race,
	ethnicity,
	CASE WHEN SupportingDocuments=1 THEN 'Are attached'
	     WHEN SupportingDocuments=2 THEN 'Will be submitted separately'
		 WHEN SupportingDocuments=3 THEN 'Will not be submitted'
		 ELSE CAST(SupportingDocuments AS varchar)
		 END AS SupportingDocuments,
	[SupportingDocumentsUploaded],
	[SupportDocumentsnotUploadedReason],
	[SupportDocsApproved],
	CASE WHEN [EventPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [EventPaid],
	CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [SourceDocsPaid],
	L.[auditType],
	L.[DateCreated],
	L.[eventDefinitionId],
	CASE WHEN L.[crfCaption]='Pregnancy Info' THEN 'Event Info'
	ELSE L.[crfCaption]
	END AS crfCaption,
	L.[crfOccurence],
	L.[crfId],
	L.[crfOrder],
	L.[LastModifiedDate]

FROM #LMDTGroup L
LEFT JOIN #PREG M ON M.PatientID=L.PatientID AND M.eventId=L.eventDefinitionId AND M.eventOccurrence=L.eventOccurence
WHERE L.eventDefinitionId=8044

UNION

SELECT SS.SiteID,
       TA2.SubjectID,
       TA2.patientId,
	   'Not Started' AS statusCode,
	   CAST(NULL AS int) AS reviewConfirmed,
	   CAST(NULL AS bigint) AS ProviderID,
	   NULL AS firstReportedVia,
	   CAST(NULL AS date) AS FUVisitDate,
	   REPLACE(TA2.eventName, ' TAE', '') AS eventType,
	   TA2.eventDefinitionId AS eventId,
	   TA2.eventOccurrence,
	   'Event Info' AS crfName,
	   CAST(NULL AS bigint) AS eventCrfId,
	   NULL AS EventTerm,
	   NULL AS SpecifyEvent,
	   CAST(NULL AS date) AS EventOnsetDate,
	   NULL AS MDConfirmed,
	   NULL AS ConfirmationStatus,
	   NULL AS noEventExplain,
	   'No' AS hasData,
	   NULL AS Outcome,
	   NULL AS Serious,
	   NULL AS SeriousReason,
	   NULL AS IVAntiInfect,
	   NULL AS FUVisitTreatments,
	   NULL AS OtherFUVisitTreatments,
	   NULL AS EventTreatments,
	   NULL AS OtherEventTreatments,
	   SS.gender,
	   SS.yearOfBirth,
	   SS.race,
	   SS.ethnicity,
	   NULL AS SupportingDocuments,
	   NULL AS SupportingDocumentsUploaded,
	   NULL AS SupportDocumentsnotUploadedReason,
	   NULL AS SupportDocsApproved,
	   NULL AS EventPaid,
	   NULL AS SourceDocsPaid,
	   TA2.AuditType,
	   TA2.dateStart AS DateCreated,
	   TA2.eventDefinitionId,
	   CASE WHEN TA2.eventDefinitionId=8044 THEN 'Pregnancy Info'
	   ELSE 'Event Info' 
	   END AS crfCaption,
	   NULL AS crfOccurence,
	   NULL AS crfId,
	   NULL AS crfOrder,
	   NULL AS LastModifiedDate
FROM #TAEAudit2 TA2
LEFT JOIN #SubjectSite SS ON SS.patientId=TA2.patientId

) K

--SELECT * FROM #EVENTS WHERE SubjectID='AD-1440-0055' and eventID=8044 ORDER BY SubjectID, eventid, eventOccurrence



TRUNCATE TABLE [Reporting].[AD550].[t_pv_TAEQCListing];

INSERT INTO [AD550].[t_pv_TAEQCListing]
(
 [SiteID]
,[SubjectID]
,[PatientID]
,[statusCode]
,[reviewConfirmed]
,[ProviderID]
,[firstReportedVia]
,[FUVisitDate]
,[EventType]
,[eventId]
,[eventOccurrence]
,[crfName]
,[eventCrfId]
,[EventTerm]
,[SpecifyEvent]
,[EventOnsetDate]
,[MDConfirmed]
,[ConfirmationStatus]
,[noEventExplain]
,[hasData]
,[Outcome]
,[Serious]
,[SeriousReason]
,[IVAntiInfect]
,[FUVisitTreatments]
,[OtherFUVisitTreatments]
,[EventTreatments]
,[OtherEventTreatments]
,[Gender]
,[yearOfBirth]
,[Race]
,[Ethnicity]
,[SupportingDocuments]
,[SupportingDocumentsUploaded]
,[SupportDocumentsNotUploadedReason]
,[SupportDocsApproved]
,[EventPaid]
,[SourceDocsPaid]
,[PayEligibleStatus]
,[DataEntryStatus]
,[AuditType]
,[DateCreated]
,[Event Info]
,[Fractures]
,[Event Details]
,[AD Drug Exposure]
,[Other Concurrent Drugs]
,[Data Entry Completion]
,[Supporting Documents Approval]
,[Case Processing]
)


SELECT DISTINCT *
FROM
(
SELECT  E.[SiteID],
		E.[SubjectID], 
		E.[PatientID],
		E.[statusCode],
		E.[reviewConfirmed],
		E.[ProviderID],
		E.[firstReportedVia],
		E.[FUVisitDate],
		E.[EventType],
		E.[eventId],
		E.[eventOccurrence],
		E.[crfName],
		E.[eventCrfId],
		E.[EventTerm],
		E.[SpecifyEvent],
		E.[EventOnsetDate],
		E.[MDConfirmed],
		E.[ConfirmationStatus],
		E.[noEventExplain],
		E.[hasData],
		E.[Outcome],
		E.[Serious],
		E.[SeriousReason],
		E.[IVAntiInfect],
		E.[FUVisitTreatments],
		E.[OtherFUVisitTreatments],
		E.[EventTreatments],
		E.[OtherEventTreatments],
		E.[gender],
		E.[yearOfBirth],
		E.[race],
		E.[ethnicity],
		E.[SupportingDocuments],
		E.[SupportingDocumentsUploaded],
		E.[SupportDocumentsNotUploadedReason],
		E.[SupportDocsApproved],
		E.[EventPaid],
		E.[SourceDocsPaid],
		CASE WHEN E.[statusCode] IN ('Data Entry Started', 'Not Started') THEN 'Not eligible'
        WHEN E.[statusCode] IN ('Completed', 'Complete') THEN 'Eligible'
		WHEN ISNULL(E.[statusCode], '')='' THEN 'Not eligible'
		ELSE E.statusCode
		END AS [PayEligibleStatus],
	    CASE WHEN ISNULL(E.[statusCode], '')='' THEN 'No Data'
		ELSE E.[statusCode]
		END AS [DataEntryStatus],
		E.[auditType],
		E.[DateCreated],
		E.[LastModifiedDate],
		E.[crfCaption]  
FROM #EVENTS E
) AS SourceTable PIVOT(MAX(LastModifiedDate) FOR crfCaption IN ([Event Info], [Fractures], [Event Details], [AD Drug Exposure], [Other Concurrent Drugs], [Data Entry Completion], [Supporting Documents Approval], [Case Processing])) AS PivotTable

--SELECT * FROM [Reporting].[AD550].[t_pv_TAEQCListing] WHERE EventType='Fracture' ORDER BY EventOccurrence SubjectID='AD-1440-0055' ORDER BY SiteID, SubjectID


END

GO
