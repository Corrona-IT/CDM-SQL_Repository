USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_pv_TAEQCListing_rcc_km]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =================================================
-- Author:		Kevin Soe
-- Create date: 7/26/2023
-- Description:	Procedure for RA-100 TAE QC Listing in RCC
-- =================================================

			  --EXECUTE
CREATE PROCEDURE [RA100].[usp_pv_TAEQCListing_rcc_km] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*	   DROP
CREATE TABLE [RA100].[t_pv_TAEQCListing_rcc_km]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[TAEVersion] [nvarchar](5) NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar] (100) NULL,
	[DateReported] [date] NULL,
	[EventType] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[EventName] [nvarchar](350) NULL,
	[SpecifyEvent] [nvarchar](500) NULL,
	[EventOnsetDate] [date] NULL,
	--[MDConfirmed] [nvarchar](30) NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[noEventExplain] [nvarchar](500) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[Serious] [nvarchar](10) NULL,
	[SeriousReason] [nvarchar](500) NULL,
	[IVAntiInfect] [nvarchar](10) NULL,
	[FUVisitTreatments] [nvarchar](1500) NULL,
	[OtherFUVisitTreatments] [nvarchar](1500) NULL,
	[EventTreatments] [nvarchar](1200) NULL,
	[OtherEventTreatments] [nvarchar](1200) NULL,
	[gender] [nvarchar](10) NULL,
	[yearOfbirth] [int] NULL,
	[race] [nvarchar](500) NULL,
	[ethnicity] [nvarchar](100) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](150) NULL,
	[ReasonNoSupportDocs] [nvarchar](500) NULL,
	[SupportDocsApproved] [nvarchar] (20) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[crfCaption] [nvarchar] (300) NULL,
	[payEligibility] [nvarchar] (50) NULL,
	[DateCreated] [datetime] NULL,
	[auditType] [nvarchar](100) NULL,
	[LastModifiedDate] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[RA Drug Exposure] [datetime] NULL,
	[Other Concurrent Drugs] [datetime] NULL,
	[Event Completion] [datetime] NULL,
	[Case Processing] [datetime] NULL,
	[Confirmation Status] [datetime] NULL
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
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,'American Indian or Alaskan Native' AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity --SELECT *
FROM [Reporting].[RA100].[v_op_subjects_rcc] S --SELECT * FROM [RCC_RA100].[staging].[subjectform]
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.demg_1_1200_1=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,'Asian' AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[RA100].[v_op_subjects_rcc] S 
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.demg_1_1200_2=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,'Black/African American' AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[RA100].[v_op_subjects_rcc] S 
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.demg_1_1200_3=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,'Native Hawaiian or Other Pacific Islander' AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[RA100].[v_op_subjects_rcc] S 
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.demg_1_1200_4=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,'White' AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[RA100].[v_op_subjects_rcc] S 
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.demg_1_1200_5=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,'Other' + ': ' + S2.demg_1_1290 AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[RA100].[v_op_subjects_rcc] S 
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.demg_1_1200_99=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.demg_1_1000 AS gender
	  ,S2.demg_3_1100 AS yearOfBirth
	  ,NULL AS race
	  ,CASE WHEN S2.demg_1_1300=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.demg_1_1300=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.demg_1_1300 AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[RA100].[v_op_subjects_rcc] S 
LEFT JOIN [RCC_RA100].[staging].[subjectform] S2 ON S2.subjectId=S.patientId AND S2.eventId=9285
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND (ISNULL(S2.demg_1_1200_99, '')='' AND ISNULL(S2.demg_1_1200_5, '')='' AND ISNULL(S2.demg_1_1200_4, '')='' AND ISNULL(S2.demg_1_1200_3, '')='' AND ISNULL(S2.demg_1_1200_2, '')='' AND ISNULL(S2.demg_1_1200_1, '')='')
) subjects

--SELECT * FROM #SubjectSite1 WHERE SubjectID='999999999'

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

--SELECT * FROM #SubjectSite ORDER BY SiteID, SubjectID

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
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
			WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate
	   --SELECT *
FROM [RCC_RA100].[staging].[eventinfo] EI 
JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum AND (VL.VisitSequence=0 AND VL.VisitDate=ISNULL(EI.TAEDAT_4_1180, '') AND ISNULL(EI.TAERPT_4_1180, '')='') --SELECT * FROM [Reporting].[RA100].[t_op_AllDrugs_rcc]
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=VL.SubjectID AND D.VisitSequence=VL.VisitSequence
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
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
			WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_RA100].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum AND (VL.VisitDate=EI.TAERPT_4_1180 OR VL.VisitDate=EI.TAEDAT_4_1180)
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=VL.SubjectID AND (D.VisitEventOccurrence=VL.eventOccurrence OR D.VisitEventOccurrence=VL.eventOccurrence-1)
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
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
			WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN TAERPT_4_1100=1 THEN EI.[TAERPT_4_1180] 
	        WHEN TAERPT_4_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=EI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if event reported with exit visit
			ELSE EI.[TAERPT_4_1180]
			END AS ReportedVisitDate,--TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_RA100].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum AND VL.eventId=8045
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=VL.SubjectID AND (D.VisitDate<VL.VisitDate) AND ((ISNULL(D.StopDate, '')='') OR (ISNULL(D.StopDate, '')<>'' AND 
D.StartDate<D.StopDate AND D.StopDate >= D.VisitDate)) 
WHERE TAERPT_4_1100=3 AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
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
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
			WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN TAERPT_4_1100=1 THEN EI.[TAERPT_4_1180] 
	        WHEN TAERPT_4_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=EI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if event reported with exit visit
			ELSE EI.[TAERPT_4_1180]
			END AS ReportedVisitDate,--TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

--SELECT *
FROM [RCC_RA100].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum AND VL.eventId=8045
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=VL.SubjectID AND (D.VisitDate=VL.VisitDate) AND D.eventId=8045
WHERE TAERPT_4_1100=3 AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')

UNION

--WHEN TAE is reported at FU Visit or Exit Visit and there is a corresponding FU Visit Date OR TAE is reported between visits and onset date=Visit Date get drugs listed prior to that visit where treatment status is not stopped or no longer in use and has no stop date

SELECT DISTINCT subNum AS SubjectID,
       EI.subjectId AS PatientID,
	   siteName,
	   SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID,
	   REPLACE(eventName, ' TAE', '') AS eventName,
	   EI.eventId,
	   EI.eventOccurrence,
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
			WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN TAERPT_4_1100=1 THEN EI.[TAERPT_4_1180] 
	        WHEN TAERPT_4_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=EI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if event reported with exit visit
			ELSE EI.[TAERPT_4_1180]
			END AS ReportedVisitDate,--TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.VisitEventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_RA100].[staging].[eventinfo] EI                    
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum AND (VL.VisitDate=EI.TAERPT_4_1180 OR VL.VisitDate=EI.TAEDAT_4_1180)
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=VL.SubjectID AND (D.VisitDate<VL.VisitDate) AND ((ISNULL(D.StopDate, '')='') OR (ISNULL(D.StopDate, '')<>'' AND 
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
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
       WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
	   WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.eventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_RA100].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum AND VL.VisitDate=EI.TAERPT_4_1180
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=EI.subNum AND EI.TAEDAT_4_1180 NOT IN (SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=D.SubjectID) AND
(
D.VisitDate=(SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_op_AllDrugs_rcc] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate<=EI.TAEDAT_4_1180)
OR D.VisitDate=(SELECT MIN(VisitDate) FROM [Reporting].[RA100].[t_op_AllDrugs_rcc] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate>EI.TAEDAT_4_1180)
)
WHERE ((TAERPT_4_1100 IN (2) AND ISNULL(TAEDAT_4_1180, '')<>'') OR
(EI.TAERPT_4_1100=1 AND ISNULL(EI.TAERPT_4_1180, '')='' AND ISNULL(TAEDAT_4_1180, '')<>'') OR 
(EI.TAERPT_4_1100=1 AND ISNULL(EI.TAERPT_4_1180, '')<>'' AND ISNULL(TAEDAT_4_1180, '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=EI.subNum AND (V.VisitDate=EI.TAERPT_4_1180 OR V.VisitDate=EI.TAEDAT_4_1180))))
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
	   TAEDAT_4_1180 AS onsetDate,
	   CASE WHEN TAERPT_4_1100=1 THEN 'With a Provider Follow-Up form'
       WHEN TAERPT_4_1100=2 THEN 'Between registry visits'
	   WHEN TAERPT_4_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   TAERPT_4_1180 AS ReportedVisitDate,
	   VL.eventOccurrence AS FUeventOccurrence,
	   VL.VisitDate AS FUVisitDate,
	   D.VisitDate AS DrugVisitDate,
	   D.eventOccurrence AS DrugVisitOccurrence,
	   D.TreatmentName,
	   D.OtherTreatment,
	   D.TreatmentStatus,
	   D.StartDate,
	   D.StopDate

FROM [RCC_RA100].[staging].[eventinfo] EI 
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=EI.subNum and VL.VisitDate=EI.TAERPT_4_1180
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=EI.subNum 
AND D.VisitDate<=(SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_op_AllDrugs_rcc] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate<=EI.TAEDAT_4_1180)
WHERE ((TAERPT_4_1100 IN (2) AND ISNULL(TAEDAT_4_1180, '')<>'') OR
(EI.TAERPT_4_1100=1 AND ISNULL(EI.TAERPT_4_1180, '')='' AND ISNULL(TAEDAT_4_1180, '')<>'') OR 
(EI.TAERPT_4_1100=1 AND ISNULL(EI.TAERPT_4_1180, '')<>'' AND ISNULL(TAEDAT_4_1180, '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=EI.subNum and V.VisitDate=EI.TAERPT_4_1180)))
AND ISNULL(D.VisitDate, '')<>''
AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')
AND (D.StopDate IS NULL OR D.StopDate>EI.TAEDAT_4_1180)
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
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
			WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN PEQRPT_5_1100=1 THEN PEI.[PEQRPT_5_1180] 
	        WHEN PEQRPT_5_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			ELSE PEI.[PEQRPT_5_1180]
			END AS ReportedVisitDate
FROM [RCC_RA100].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
) P
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=P.SubjectID and VL.VisitDate=P.ReportedVisitDate
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=P.SubjectID AND (D.eventOccurrence=VL.eventOccurrence OR D.eventOccurrence=VL.eventOccurrence-1)
WHERE whenReported IN ('With a Provider Follow-Up form') AND ISNULL(OnsetDate, '')<>'' AND ISNULL(D.TreatmentName, '')<>''
AND EXISTS(SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=P.SubjectID AND V.VisitDate=P.ReportedVisitDate)
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
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
			WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
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

FROM [RCC_RA100].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=PEI.subNum and VL.eventId=8045 AND PEI.PEQRPT_5_1100=3
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=PEI.subNum AND D.VisitDate<VL.VisitDate 
WHERE PEQRPT_5_1100=3 
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
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
			WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
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

FROM [RCC_RA100].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=PEI.subNum and VL.eventId=8045
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=PEI.subNum AND D.eventId=8045
WHERE PEQRPT_5_1100=3 AND ISNULL(D.TreatmentName, '')<>''
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
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Provider Follow-Up form'
	        WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
			WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
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
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   PEI.PEQRPT_5_1100,
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

FROM [RCC_RA100].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=PEI.subNum AND PEI.PEQRPT_5_1100=3 AND VL.eventId=8045
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=PEI.subNum AND ISNULL(D.TreatmentName, '') NOT IN ('Pending', 'No Data', 'No Treatment', '') 
WHERE PEI.PEQRPT_5_1100=3
) EXIT2
WHERE DrugVisitDate=(SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_op_AllDrugs_rcc] D2 WHERE D2.SubjectID=EXIT2.SubjectID AND D2.VisitDate<EXIT2.ReportedVisitDate)


UNION

--WHEN PEQ is reported at FU Visit and there is a corresponding FU Visit Date get drugs listed prior to that visit where treatment status is not stopped or no longer in use and has no stop date

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   REPLACE(PEI.eventName, ' TAE', '') AS eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Subject Enrollment or Follow-Up Form'
	        WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
			WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	   END AS whenReported,
	   CASE WHEN PEQRPT_5_1100=1 THEN PEI.[PEQRPT_5_1180] 
	        WHEN PEQRPT_5_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
			ELSE PEI.[PEQRPT_5_1180]
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

FROM [RCC_RA100].[staging].[pregnancyinfo] PEI 
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.SubjectID=PEI.subNum and VL.VisitDate<PEI.PEQRPT_5_1180
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=VL.SubjectID AND D.VisitDate<PEI.[PEQRPT_5_1180] AND D.eventOccurrence=VL.eventOccurrence AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug') AND (ISNULL(D.StopDate, '')='' OR (ISNULL(D.StopDate, '')<>'' AND D.StopDate>PEI.PEQRPT_5_1180)) 

WHERE PEQRPT_5_1100=1 AND ISNULL(PEQRPT_5_1180, '')<>'' AND ISNULL(D.TreatmentName, '')<>''
AND EXISTS(SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=PEI.subNum AND V.VisitDate=PEI.PEQRPT_5_1180)
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
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Subject Enrollment or Follow-Up Form'
     	WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
	 	WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	 	END AS whenReported,
	   CASE WHEN PEQRPT_5_1100=1 THEN PEI.[PEQRPT_5_1180] 
	        WHEN PEQRPT_5_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
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
	   
FROM [RCC_RA100].[staging].[pregnancyinfo] PEI
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [RCC_RA100].[api].[eventdefinitions] ED ON ED.[id]=PEI.eventId
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=PEI.subNum AND D.VisitDate<=PD.[PEQMAT_5_1080] 
WHERE PEI.PEQRPT_5_1000=1
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND ISNULL(D.VisitDate, '')<>''
AND ((PEI.PEQRPT_5_1100 IN (2) AND ISNULL(PD.[PEQMAT_5_1080], '')<>'') OR
(PEI.PEQRPT_5_1100=1 AND ISNULL(PEI.PEQRPT_5_1180, '')='' AND ISNULL(PD.[PEQMAT_5_1080], '')<>'') OR 
(PEI.PEQRPT_5_1100=1 AND ISNULL(PEI.PEQRPT_5_1180, '')<>'' AND ISNULL(PD.[PEQMAT_5_1080], '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=PEI.subNum and V.VisitDate=PEI.PEQRPT_5_1180)))

UNION

--WHEN PEQ has no corresponding Follow-up date entered, uses onset --Next FU

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   PEI.eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Subject Enrollment or Follow-Up Form'
     	WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
	 	WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	 	END AS whenReported,
	   CASE WHEN PEQRPT_5_1100=1 THEN PEI.[PEQRPT_5_1180] 
	        WHEN PEQRPT_5_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
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
	   
FROM [RCC_RA100].[staging].[pregnancyinfo] PEI
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [RCC_RA100].[api].[eventdefinitions] ED ON ED.[id]=PEI.eventId
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=PEI.subNum 
AND D.VisitDate<=(SELECT MIN(VisitDate) FROM [Reporting].[RA100].[t_op_AllDrugs_rcc] D2 WHERE D2.SubjectID=D.SubjectID AND D2.VisitDate>(PD.[PEQMAT_5_1080]))
WHERE PEI.PEQRPT_5_1000=1
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND ISNULL(D.VisitDate, '')<>''
AND ((D.VisitType='Follow-up') OR (D.VisitType='Enrollment' AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')))
AND ((PEI.PEQRPT_5_1100 IN (2) AND ISNULL(PD.[PEQMAT_5_1080], '')<>'') OR
(PEI.PEQRPT_5_1100=1 AND ISNULL(PEI.PEQRPT_5_1180, '')='' AND ISNULL(PD.[PEQMAT_5_1080], '')<>'') OR 
(PEI.PEQRPT_5_1100=1 AND ISNULL(PEI.PEQRPT_5_1180, '')<>'' AND ISNULL(PD.[PEQMAT_5_1080], '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=PEI.subNum and V.VisitDate=PEI.PEQRPT_5_1180)))

UNION

--WHEN PEQ has no corresponding Follow-up date entered, uses onset --Any drugs started and not stopped prior to onset date

SELECT DISTINCT PEI.subNum AS SubjectID,
       PEI.subjectId AS PatientID,
	   PEI.siteName,
	   SUBSTRING(PEI.siteName, 0, CHARINDEX(' -', PEI.siteName)) AS SiteID,
	   PEI.eventName,
	   PEI.eventId,
	   PEI.eventOccurrence,
	   PD.[PEQMAT_5_1080] AS onsetDate,
	   CASE WHEN PEQRPT_5_1100=1 THEN 'With a Subject Enrollment or Follow-Up Form'
     	WHEN PEQRPT_5_1100=2 THEN 'Between registry visits'
	 	WHEN PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	 	END AS whenReported,
	   CASE WHEN PEQRPT_5_1100=1 THEN PEI.[PEQRPT_5_1180] 
	        WHEN PEQRPT_5_1100=3 THEN (SELECT VisitDate FROM [RA100].[t_op_VisitLog_rcc] VL2 WHERE VL2.SubjectID=PEI.subNum AND VL2.eventId=8045) --pull in exit date from visit log if pregnancy reported with exit visit
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
	   
FROM [RCC_RA100].[staging].[pregnancyinfo] PEI
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PD ON PD.subNum=PEI.subNum AND PD.eventId=PEI.eventId AND PD.eventOccurrence=PEI.eventOccurrence
LEFT JOIN [RCC_RA100].[api].[eventdefinitions] ED ON ED.[id]=PEI.eventId
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=PEI.subNum AND D.VisitDate<=PD.[PEQMAT_5_1080]
WHERE PEI.PEQRPT_5_1000=1
AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')
AND ISNULL(D.VisitDate, '')<>''
AND ((PEI.PEQRPT_5_1100 IN (1, 2) AND ISNULL(PD.[PEQMAT_5_1080], '')<>'') OR
(PEI.PEQRPT_5_1100=1 AND ISNULL(PEI.PEQRPT_5_1180, '')='' AND ISNULL(PD.[PEQMAT_5_1080], '')<>'') OR 
(PEI.PEQRPT_5_1100=1 AND ISNULL(PEI.PEQRPT_5_1180, '')<>'' AND ISNULL(PD.[PEQMAT_5_1080], '')<>'' AND NOT EXISTS (SELECT VisitDate FROM [Reporting].[RA100].[t_op_VisitLog_rcc] V WHERE V.SubjectID=PEI.subNum and V.VisitDate=PEI.PEQRPT_5_1180)))

) D

--SELECT * FROM #TAEDrugs

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
        ,1,1,'') AS OtherFUVisitTreatments,

	   	  STUFF((
	   SELECT DISTINCT ', ' + SV.[optionsText] --SELECT *
	   FROM [RCC_RA100].[staging].[radrugexposure] DE
	   LEFT JOIN (SELECT * FROM [RCC_RA100].[etl].[responseSetValues] WHERE responsesetLabel = 'RxList_RA') SV ON taerxuse_6_1000 = responsesetValue
	   WHERE DE.subNum=TD.SubjectID 
	   AND DE.subjectId=TD.PatientID 
	   AND DE.eventId=TD.eventId 
	   AND DE.eventOccurrence=TD.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS EventTreatments,

	  STUFF((
	   SELECT DISTINCT ', ' + [taerxuse_6_1090] --SELECT *
	   FROM [RCC_RA100].[staging].[radrugexposure] DE
	   WHERE DE.subNum=TD.SubjectID 
	   AND DE.subjectId=TD.PatientID 
	   AND DE.eventId=TD.eventId 
	   AND DE.eventOccurrence=TD.eventOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherEventTreatments

INTO #Drugs
FROM #TAEDRUGS TD

--SELECT * FROM #Drugs


/****Get Created Date for Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit') IS NOT NULL BEGIN DROP TABLE #TAEAudit END
--SELECT * FROM #TAEAudit
SELECT Rownum,
       SiteID,
       CAST(SubjectID AS varchar) AS SubjectID,
	   PatientID,
	   eventDefinitionId,
	   eventOccurence,
	   crfCaption,
	   crfOrder,
	   crfOccurence,
	   'Audit Trail' AS auditType,
	   DateCreated

INTO #TAEAudit
FROM
(
SELECT  ROW_NUMBER () OVER (PARTITION BY SubjectID, eventDefinitionId, eventOccurence ORDER BY SubjectID, eventDefinitionId, eventOccurence, crfOrder, DateCreated, crfOccurence) AS RowNum,
        SiteID,
		CAST(SubjectID AS varchar) AS SubjectID,
		PatientID,
		eventDefinitionId,
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
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
			WHEN EDI.[crfCaption] LIKE '%Details (TM)' THEN 'Event Details'
			WHEN EDI.[crfCaption] LIKE '%Info (TM)' THEN 'Event Info'
			WHEN EDI.[crfCaption] LIKE '%Exposure (TM)' THEN 'RA Drug Exposure'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption]LIKE '%Details' THEN 20
	   WHEN EDI.[crfCaption]='RA Drug Exposure' THEN 30
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 40
	   WHEN EDI.[crfCaption]='Event Completion' THEN 50
	   WHEN EDI.[crfCaption]='Confirmation Status' THEN 60
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject\
	  ,MIN(AL.[auditDate]) AS DateCreated
--SELECT *
  FROM [RCC_RA100].[api].[eventcrfs] EC 
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId --SELECT * FROM [RCC_RA100].[api].[eventdefinitions_crfs]
  JOIN [RCC_RA100].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_RA100].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId =EC.id --SELECT TOP 100 * FROM [RCC_RA100].[api].[auditlogs] where eventCrfId IS NOT NULL
  WHERE eventDefinitionId IN (9287, 9289, 9290, 9291, 9292, 9293, 9294, 9295, 9296, 9297, 9298, 9299, 9300)
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence
) A
) B 
  WHERE RowNum=1
--SELECT * FROM #TAEAudit ORDER BY PatientID, EventDefinitionID, eventOccurence


/****Get Created Date for Scheduled but not started Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit2') IS NOT NULL BEGIN DROP TABLE #TAEAudit2 END

SELECT B.subjectId,
	   B.patientId,
       B.dateStart,
	   CAST(test1 AS datetime) AS calcDateStart,
	   B.eventDefinitionId, 
	   B.[name] AS eventName,
	   B.eventOccurence AS eventOccurrence,
	   B.statusCode,
	   'Study Events Table' AS AuditType

INTO #TAEAudit2

FROM
(
SELECT SS.SubjectID
      ,SE.[dateStart]
	  ,CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1'), 105) + ' ' + 
        CONVERT(VARCHAR(9), CAST(DATEADD(SECOND, CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1') AS TIME), 120) AS calcDateStart
	  ,CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1'), 120) AS test1
	  ,CONVERT(VARCHAR(9), CAST(DATEADD(SECOND, CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1') AS TIME), 25) AS test2
      ,SE.[startTimeFlag]
      ,SE.[subjectId] AS [patientId]
      ,SE.[id]
      ,SE.[eventDefinitionId]
	  ,ED.[name]
      ,SE.[statusId]
      ,SE.[statusCode]
      ,SE.[eventOccurence]
  FROM [RCC_RA100].[api].[studyevents] SE --SELECT * FROM [RCC_RA100].[api].[eventdefinitions]
  LEFT JOIN #SubjectSite SS ON SS.patientId=SE.subjectId
  LEFT JOIN [RCC_RA100].[api].[eventdefinitions] ED ON ED.[id]=SE.eventDefinitionId
  WHERE eventDefinitionId IN (9287, 9289, 9290, 9291, 9292, 9293, 9294, 9295, 9296, 9297, 9298, 9299, 9300)
  AND statuscode='Scheduled'
  ) B
    WHERE SubjectID NOT IN (SELECT SubjectID FROM #TAEAudit TA WHERE TA.PatientID=B.patientId AND TA.eventDefinitionId=B.eventDefinitionId AND TA.eventOccurence=B.eventOccurence)

--SELECT * FROM #TAEAudit2 ORDER BY PatientID, eventOccurrence

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
	   LastModifiedDate

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
		LastModifiedDate
FROM
(
SELECT S.SiteID
      ,S.SubjectID
	  ,S.[patientId] AS PatientID
      ,EC.[eventDefinitionId]
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
			WHEN EDI.[crfCaption] LIKE '%Details (TM)' THEN 'Event Details'
			WHEN EDI.[crfCaption] LIKE '%Info (TM)' THEN 'Event Info'
			WHEN EDI.[crfCaption] LIKE '%Exposure (TM)' THEN 'RA Drug Exposure'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption]='RA Drug Exposure' THEN 20
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 30
	   WHEN EDI.[crfCaption] LIKE '%Details' THEN 40
	   WHEN EDI.[crfCaption]='Event Completion' THEN 50
	   WHEN EDI.[crfCaption]='Case Processing' THEN 60
	   WHEN EDI.[crfCaption]='Confirmation Status' THEN 70
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject\
	  ,MAX(AL.[auditDate]) AS LastModifiedDate
--SELECT * 
  FROM [RCC_RA100].[api].[eventcrfs] EC --SELECT * FROM #SubjectSite
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId --SELECT * FROM [RCC_RA100].[api].[auditlogs]
  JOIN [RCC_RA100].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_RA100].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId=EC.id AND AL.reasonForChange NOT IN ('Event Custom Label Changed', 'Form Custom Label Changed', 'CRF Custom Label Changed') 
  WHERE eventDefinitionId IN (9287, 9289, 9290, 9291, 9292, 9293, 9294, 9295, 9296, 9297, 9298, 9299, 9300)
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence
) A 
) B 

--SELECT * FROM #LMDT  ORDER BY SubjectID, RowNum




/***Get Last Modified Page and Date for Event***/

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
	   C.LastModifiedDate
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
LastModifiedDate

FROM #LMDT
) C 
LEFT JOIN #TAEAudit TA ON TA.SubjectID=C.SubjectID AND TA.eventDefinitionId=C.eventDefinitionId AND TA.eventOccurence=C.eventOccurence 
WHERE C.crfRowNum=1

--SELECT * FROM #LMDTGroup ORDER BY SiteID, SubjectID, eventDefinitionId, eventOccurence, crfOrder


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
	  ,EI.[TAERPT_4_1180] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_1]=1 THEN 'Hospitalization (new or prolonged)' 
	   ELSE NULL END AS seriousReason  --SELECT * FROM [RCC_AD550].[staging].[eventinfo] 
FROM [RCC_RA100].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[TAERPT_4_1180] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_2]=1 THEN 'Immediately life threatening' 
	   ELSE NULL END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[TAERPT_4_1180] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_3]=1 THEN 'Death' 
	   ELSE NULL END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[TAERPT_4_1180] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_4]=1 THEN 'Persistent/significant disability or incapacity' 
	   ELSE NULL END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[TAERPT_4_1180] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_5]=1 THEN 'Congenital anomaly/birth defect' 
	   ELSE NULL END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[TAERPT_4_1180] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_6]=1 THEN 'Provider deems as serious, important medical event' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfo] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[taerpt_4_1180_tm] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_tm_1]=1 THEN 'Hospitalization (new or prolonged)' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfotm] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[taerpt_4_1180_tm] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_tm_2]=1 THEN 'Immediately life threatening' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfotm] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[taerpt_4_1180_tm] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_tm_3]=1 THEN 'Death' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfotm] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[taerpt_4_1180_tm] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_tm_4]=1 THEN 'Persistent/significant disability or incapacity' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfotm] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[taerpt_4_1180_tm] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_tm_5]=1 THEN 'Congenital anomaly/birth defect' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfotm] EI

UNION

SELECT EI.subNum AS SubjectID
	  ,EI.[taerpt_4_1180_tm] AS FUVisitDate
	  ,EI.[eventName]
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,CASE WHEN [taeser_4_1001_tm_6]=1 THEN 'Provider deems as serious, important medical event that may jeopardize the patient and require medical or surgical intervention or treatment to prevent one of the other outcomes (e.g. severe blood disorders, seizures)' 
	   ELSE NULL
	   END AS seriousReason
FROM [RCC_RA100].[staging].[eventinfotm] EI


UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_12301]=1 THEN 'Post-natal serious infection' 
	   ELSE CAST([peqser_5_1001_12301] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_10002]=1 THEN 'Serious post-partum infection' 
	   ELSE CAST([peqser_5_1001_10002] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_1]=1 THEN 'Hospitalization (maternal) during pregnancy' 
	   ELSE CAST([peqser_5_1001_1] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_2]=1 THEN 'Immediately life threatening' 
	   ELSE CAST([peqser_5_1001_2] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_3]=1 THEN 'Maternal death' 
	   ELSE CAST([peqser_5_1001_3] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_4]=1 THEN 'Persistent/significant maternal disability for incapacity' 
	   ELSE CAST([peqser_5_1001_4] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

UNION

SELECT PEQ.subNum AS SubjectID
      ,PEQ.[PEQRPT_5_1180] AS FUVisitDate
	  ,PEQ.[eventName]
	  ,PEQ.eventId
	  ,PEQ.eventOccurrence
	  ,PEQ.crfName
	  ,PEQ.eventCrfId
	  ,CASE WHEN [peqser_5_1001_5]=1 THEN 'Provider deems as serious, important maternal medical event' 
	   ELSE CAST([peqser_5_1001_5] AS nvarchar)
	   END AS seriousReason
FROM [RCC_RA100].[staging].[pregnancyinfo] PEQ

) A
WHERE seriousReason IS NOT NULL

--SELECT * FROM #ReasonSerious

/****Get outcomes for all TAEs except pregnancy****/

IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

SELECT 
SubjectID,
PatientID,
ProviderID,
EventName,
EventType,
eventId,
eventCrfId,
eventOccurrence,
crfName,
firstReportedVia,
DateReported,
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
ReasonNoSupportDocs,
SupportDocsApproved,
EventPaid,
SourceDocsPaid
INTO #TAEOutcomes
FROM 
(
SELECT EI.subNum AS SubjectID
      ,EI.subjectId AS PatientID
	  ,EI.TAEPID_4_1000_TM AS ProviderID
	  ,EI.eventName AS EventName
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,EI.eventId
	  ,EI.eventCrfId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,CASE WHEN EI.taerpt_4_1100_TM=1 THEN 'With a Follow-up Visit'
	   WHEN EI.taerpt_4_1100_TM=2 THEN 'Between registry visits'
	   WHEN EI.taerpt_4_1100_TM=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,EI.taerpt_4_1180_tm AS DateReported 
	  ,CASE
	    WHEN EI2.Outcome=1 THEN 'Death'
		WHEN EI2.Outcome=2 THEN 'Ongoing event'
		WHEN EI2.Outcome=3 THEN 'Patient disabled'
		WHEN EI2.Outcome=4 THEN 'Patient recovered'
		WHEN EI2.Outcome=97 THEN 'Unknown'
		ELSE NULL
		END AS Outcome
	  ,CASE WHEN EI.TAESER_4_1000_TM=1 THEN 'Yes'
	   WHEN EI.TAESER_4_1000_TM=0 THEN 'No'
	   ELSE NULL
	   END AS [Serious]
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

	  --,CONCAT(EI.TAESER_4_1001_1, EI.TAESER_4_1001_2, EI.TAESER_4_1001_3, EI.TAESER_4_1001_4, EI.TAESER_4_1001_5, EI.TAESER_4_1001_6) AS [SeriousnessCriteria]
	  ,CASE WHEN TAEINF.aeivyn=1 THEN 'Yes'
	   WHEN TAEINF.aeivyn=0 THEN 'No'
	   ELSE NULL
	   END AS IVAntiInfect
	  ,D.FUVisitTreatments
	  ,D.OtherFUVisitTreatments
	  ,D.EventTreatments
	  ,D.OtherEventTreatments
	  ,CASE 
		WHEN EI.taedoc_4_1000_tm=1 THEN 'Are attached'
		WHEN EI.taedoc_4_1000_tm=2 THEN 'Will be submitted'
		WHEN EI.taedoc_4_1000_tm=3 THEN 'Will not be submitted'
		ELSE NULL
		END AS SupportingDocuments
	  ,CASE WHEN ISNULL(EI.taedoc_4_1002_tm, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN EI.taedoc_4_1001_tm=1 THEN 'Hospital would not fax or release documents (explain)'
	   WHEN EI.taedoc_4_1001_tm=2 THEN 'Patient would not authorize release of records'
	   WHEN EI.taedoc_4_1001_tm=3 THEN 'Other reason (explain)'
	   END AS ReasonNoSupportDocs
	  ,CASE WHEN SDA.taepay_4_1000=1 THEN 'Yes'
	   WHEN SDA.taepay_4_1000=0 THEN 'No'
	   WHEN ISNULL(SDA.taepay_4_1000, '')='' THEN 'No'
	   ELSE CAST(SDA.taepay_4_1000 AS varchar)
	   END AS SupportDocsApproved
	  ,REIMB.taepay_4_1001 AS EventPaid
	  ,REIMB.taepay_4_1100 AS SourceDocsPaid

--SELECT *
FROM [RCC_RA100].[staging].[eventinfotm] EI
LEFT JOIN [RCC_RA100].[staging].[infectiondetailstm] TAEINF ON TAEINF.subNum=EI.subNum AND TAEINF.eventId=EI.eventId AND TAEINF.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=EI.subjectId
   AND REIMB.eventName=EI.eventName AND REIMB.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[caseprocessing] SDA ON SDA.subjectId=EI.subjectId AND SDA.eventName=EI.eventName AND SDA.[eventOccurrence]=EI.eventOccurrence
LEFT JOIN #Drugs D ON D.patientId=EI.subjectId AND D.eventId=EI.eventId AND D.eventOccurrence=EI.eventOccurrence
LEFT JOIN (SELECT subjectID, eventName, eventOccurrence,
CASE
		WHEN taeout_4_1000_TM='Patient disabled' THEN 3
		WHEN taeout_4_1000_TM='Patient recovered' THEN 4
		ELSE taeout_4_1000_TM
		END AS Outcome  --Had to convert outcome responses to numeric codes because coding was mixed with some being numeric and some being text leading to conversion errors because the codes were not all an integer data type
FROM [RCC_RA100].[staging].[eventinfotm]) EI2 ON EI2.subjectId=EI.subjectId AND EI2.eventName=EI.eventName AND EI2.[eventOccurrence]=EI.eventOccurrence


UNION

SELECT EI.subNum AS SubjectID
      ,EI.subjectId AS PatientID
	  ,EI.TAEPID_4_1000 AS ProviderID
	  ,EI.eventName AS EventName
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,EI.eventId
	  ,EI.eventCrfId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,CASE WHEN EI.taerpt_4_1100=1 THEN 'With a Follow-up Visit'
	   WHEN EI.taerpt_4_1100=2 THEN 'Between registry visits'
	   WHEN EI.taerpt_4_1100=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,EI.taerpt_4_1180 AS DateReported 
	  ,CASE
	    WHEN EI.taeout_4_1000=1 THEN 'Death'
		WHEN EI.taeout_4_1000=2 THEN 'Ongoing event'
		WHEN EI.taeout_4_1000=3 THEN 'Fully recovered/resolved'
		WHEN EI.taeout_4_1000=4 THEN 'Recovered/resolved with sequelae'
		WHEN EI.taeout_4_1000=97 THEN 'Unknown'
		ELSE NULL
		END AS Outcome
	  ,CASE WHEN EI.TAESER_4_1000=1 THEN 'Yes'
	   WHEN EI.TAESER_4_1000=0 THEN 'No'
	   ELSE NULL
	   END AS [Serious]
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

	  --,CONCAT(EI.TAESER_4_1001_1, EI.TAESER_4_1001_2, EI.TAESER_4_1001_3, EI.TAESER_4_1001_4, EI.TAESER_4_1001_5, EI.TAESER_4_1001_6) AS [SeriousnessCriteria]
	  ,CASE WHEN TAEINF.TAEINF_4_1202=1 OR TAEINF.TAEINF_4_1201=1 THEN 'Yes'
	   WHEN (TAEINF.TAEINF_4_1202<>1 AND TAEINF.TAEINF_4_1201<>1) THEN 'No'
	   ELSE NULL
	   END AS IVAntiInfect
	  ,D.FUVisitTreatments
	  ,D.OtherFUVisitTreatments
	  ,D.EventTreatments
	  ,D.OtherEventTreatments
	  ,CASE 
		WHEN EI.taedoc_4_1000=1 THEN 'Are attached'
		WHEN EI.taedoc_4_1000=2 THEN 'Will be submitted'
		WHEN EI.taedoc_4_1000=3 THEN 'Will not be submitted'
		ELSE NULL
		END AS SupportingDocuments
	  ,CASE WHEN ISNULL(EI.taedoc_4_1002, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN EI.taedoc_4_1001=1 THEN 'Hospital would not fax or release documents (explain)'
	   WHEN EI.taedoc_4_1001=2 THEN 'Patient would not authorize release of records'
	   WHEN EI.taedoc_4_1001=3 THEN 'Other reason (explain)'
	   END AS ReasonNoSupportDocs
	  ,CASE WHEN SDA.taepay_4_1000=1 THEN 'Yes'
	   WHEN SDA.taepay_4_1000=0 THEN 'No'
	   WHEN ISNULL(SDA.taepay_4_1000, '')='' THEN 'No'
	   ELSE CAST(SDA.taepay_4_1000 AS varchar)
	   END AS SupportDocsApproved
	  ,REIMB.taepay_4_1001 AS EventPaid
	  ,REIMB.taepay_4_1100 AS SourceDocsPaid

--SELECT taerpt_4_1100 
FROM [RCC_RA100].[staging].[eventinfo] EI
LEFT JOIN [RCC_RA100].[staging].[infectiondetails] TAEINF ON TAEINF.subNum=EI.subNum AND TAEINF.eventId=EI.eventId AND TAEINF.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=EI.subjectId
   AND REIMB.eventName=EI.eventName AND REIMB.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[caseprocessing] SDA ON SDA.subjectId=EI.subjectId AND SDA.eventName=EI.eventName AND SDA.[eventOccurrence]=EI.eventOccurrence
LEFT JOIN #Drugs D ON D.patientId=EI.subjectId AND D.eventId=EI.eventId AND D.eventOccurrence=EI.eventOccurrence
) A

--SELECT * FROM #TAEOutcomes 


/****Get Pregnancy TAE information including outcomes****/

IF OBJECT_ID('tempdb.dbo.#PREG') IS NOT NULL BEGIN DROP TABLE #PREG END

SELECT DISTINCT SiteID,
       SubjectID,
	   PatientID,
	   TAEVersion,
	   statusCode,
	   --peq_reviewer_conf_confirmed,
	   ProviderID,
	   firstReportedVia,
	   DateReported,
	   EventType,
	   eventId,
	   eventOccurrence,
	   crfName,
	   eventCrfId,
	   EventName,
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
	   CASE WHEN ISNULL(AddExplainNoSupportDocs, '')<>'' THEN ReasonNoSupportDocs + ', ' + AddExplainNoSupportDocs
	   ELSE ReasonNoSupportDocs
	   END AS ReasonNoSupportDocs,
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
	  ,'V15' AS [TAEVersion]
	  ,TAEP.statusCode
	  ,TAEP.PEQPID_5_1000 AS ProviderID
	  ,CASE WHEN TAEP.PEQRPT_5_1100=1 THEN 'With a Subject Enrollment or Follow-up form'
	   WHEN TAEP.PEQRPT_5_1100=2 THEN 'Between registry visits'
	   WHEN TAEP.PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,TAEP.PEQRPT_5_1180 AS DateReported
	  ,TAEP.eventName AS EventType
	  ,TAEP.eventId
	  ,TAEP.eventOccurrence
	  ,TAEP.crfName
	  ,TAEP.eventCrfId
	  ,'Pregnancy' AS EventName
	  ,'' AS [SpecifyEvent]
	  ,CAST(PDE.peqmat_5_1080 AS date) AS OnsetDate
	  ,NULL AS MDConfirmed
	  ,CASE WHEN TAEP.PEQRPT_5_1000=1 THEN 'Confirmed event'
	   WHEN TAEP.PEQRPT_5_1000=2 THEN 'Previously reported (duplicate)'
	   WHEN TAEP.PEQRPT_5_1000=3 THEN 'Not an event'
	   ELSE CAST(NULL AS nvarchar)
	   END AS ConfirmationStatus
	  ,TAEP.PEQRPT_5_1090 AS noEventExplain
	  ,CASE WHEN TAEP.hasData=1 THEN 'Yes'
	   WHEN TAEP.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
	  ,'' AS Outcome
	  ,CASE WHEN [PEQSER_5_1000]=0 THEN 'No'
	   WHEN [PEQSER_5_1000]=1 then 'Yes'
	   ELSE CAST([PEQSER_5_1000] AS nvarchar)
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
	  ,D.EventTreatments
	  ,D.OtherEventTreatments
	  ,SS.gender
	  ,SS.yearOfBirth
	  ,SS.race
	  ,SS.ethnicity
	  ,CASE 
		WHEN TAEP.PEQDOC_5_1000=1 THEN 'Are attached'
		WHEN TAEP.PEQDOC_5_1000=2 THEN 'Will be submitted'
		WHEN TAEP.PEQDOC_5_1000=3 THEN 'Will not be submitted'
		ELSE NULL
		END AS SupportingDocuments
	  ,CASE WHEN ISNULL(TAEP.PEQDOC_5_1002, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN TAEP.peqdoc_5_1001=1 THEN 'Hospital would not fax or release documents (explain)'
	   WHEN TAEP.peqdoc_5_1001=2 THEN 'Patient would not authorize release of records'
	   WHEN TAEP.peqdoc_5_1001=3 THEN 'Other reason (explain)'
	   END AS ReasonNoSupportDocs
	  ,CASE WHEN SDA.taepay_4_1000=1 THEN 'Yes'
	   WHEN SDA.taepay_4_1000=0 THEN 'No'
	   WHEN ISNULL(SDA.taepay_4_1000, '')='' THEN 'No'
	   ELSE CAST(SDA.taepay_4_1000 AS varchar)
	   END AS SupportDocsApproved
	  ,[PEQDOC_5_1090] AS AddExplainNoSupportDocs
	  ,REIMB.taepay_4_1001 AS EventPaid
	  ,REIMB.taepay_4_1100 AS SourceDocsPaid
	  ,TA.eventDefinitionId
	  ,TA.eventOccurence

--INTO #PREG  --SELECT *
FROM [RCC_RA100].[staging].[pregnancyinfo] TAEP
LEFT JOIN #SubjectSite SS ON SS.PatientID=TAEP.subjectId
LEFT JOIN [RCC_RA100].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=TAEP.subjectId 
     AND REIMB.eventName=TAEP.eventName AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subjectId=TA.PatientID AND TA.eventDefinitionId=TAEP.eventId and TA.eventOccurence=TAEP.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[pregnancydetails] PDE ON PDE.subjectId=TAEP.subjectId AND PDE.eventName=TAEP.eventName AND PDE.[eventOccurrence]=TAEP.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[caseprocessing] SDA ON SDA.subjectId=TAEP.subjectId AND SDA.eventName=TAEP.eventName AND SDA.[eventOccurrence]=TAEP.eventOccurrence
LEFT JOIN #Drugs D ON D.SubjectID=TAEP.subNum AND D.eventId=TAEP.eventId AND D.eventOccurrence=TAEP.eventOccurrence
WHERE SS.[status] NOT IN ('Removed', 'Incomplete')
) B

--SELECT * FROM #PREG



IF OBJECT_ID('tempdb.dbo.#TAE') IS NOT NULL BEGIN DROP TABLE #TAE END

/****Get TAEs information for all but pregnancy****/

SELECT DISTINCT
	   SS.SiteID,
       C.SubjectID,
       C.PatientID,
	   C.TAEVersion,
	   C.statusCode,
	   C.ProviderID,
	   C.firstReportedVia,
	   C.DateReported,
	   C.EventType,
	   C.eventId,
	   C.eventOccurrence,
	   C.crfName,
	   C.eventCrfId,
	   C.EventName,
	   C.SpecifyEvent,
	   C.EventOnsetDate,
	   --C.MDConfirmed,-- (MAY NEED TO ADD BACK IN)
	   C.ConfirmationStatus,
	   C.noEventExplain,
	   C.hasData,
	   TAEOUT.Outcome,
	   TAEOUT.Serious,
	   TAEOUT.SeriousReason,
	   TAEOUT.IVAntiInfect,
	   TAEOUT.FUVisitTreatments,
	   TAEOUT.OtherFUVisitTreatments,
	   TAEOUT.EventTreatments,
	   TAEOUT.OtherEventTreatments,
	   SS.gender,
	   SS.yearOfBirth,
	   SS.race,
	   SS.ethnicity,
	   TAEOUT.SupportingDocuments,
	   TAEOUT.SupportingDocumentsUploaded,
	   TAEOUT.ReasonNoSupportDocs,
	   TAEOUT.SupportDocsApproved,
	   TAEOUT.EventPaid,
	   TAEOUT.SourceDocsPaid

INTO #TAE
FROM 
(

SELECT B.SubjectID,
       B.PatientID,
	   B.TAEVersion,
	   B.statusCode,
	   B.ProviderID,
	   B.firstReportedVia,
	   B.DateReported,
	   B.EventType,
	   B.eventId,
	   B.eventOccurrence,
	   B.crfName,
	   B.eventCrfId,
	   --B.EventName + ISNULL(', ' + SpecifyEvent, '') AS EventName,--Original format
	   B.EventName,
	   B.SpecifyEvent,
	   B.EventOnsetDate,
	   --B.MDConfirmed,
	   B.ConfirmationStatus,
	   B.noEventExplain,
	   B.hasData

FROM
(
SELECT A.SubjectID,
       A.PatientID,
	   A.TAEVersion,
	   A.statusCode,
	   A.ProviderID,
	   A.firstReportedVia,
	   A.DateReported,
	   A.EventType,
	   A.eventId,
	   A.eventOccurrence,
	   A.crfName,
	   A.eventCrfId,
	   CASE WHEN EventName LIKE '%(specify)%' THEN REPLACE(EventName, ' (specify)', '')
	   WHEN EventName LIKE '%(specify type)%' THEN REPLACE(EventName, ' (specify type)', '')
	   WHEN EventName LIKE '%(specify location)%' THEN REPLACE(EventName, ' (specify location)', '')
	   ELSE EventName
	   END AS EventName,
	   A.SpecifyEvent,
	   A.EventOnsetDate,
	   --A.MDConfirmed,
	   A.ConfirmationStatus,
	   A.noEventExplain,
	   A.hasData

FROM
(
SELECT DISTINCT
	   EI.[subNum] AS SubjectID
      ,EI.[subjectId] AS PatientID
	  ,'V15' AS [TAEVersion]
	  ,EI.[statusCode] AS statusCode
	  ,EI.TAEPID_4_1000 AS ProviderID
	  ,CASE WHEN EI.taerpt_4_1100=1 THEN 'With a Follow-up Visit'
	   WHEN EI.taerpt_4_1100=2 THEN 'Between registry visits'
	   WHEN EI.taerpt_4_1100=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,EI.taerpt_4_1180 AS DateReported
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,COALESCE(TAEANA_4_1100_dec, TAECAN_4_1100_dec, TAECVD_4_1100_dec, TAEC19_4_1100_dec, TAEGEN_4_1100_dec, TAEGIP_4_1100_dec, TAEHEP_4_1100_dec, TAEZOS_4_1100_dec, TAEINF_4_1100_dec, TAENEU_4_1100_dec, TAESSB_4_1100_dec, TAEVTE_4_1100_dec) AS EventName
	  ,CASE 
		WHEN EI.TAEINF_4_1101=1 THEN 'Acute'
		WHEN EI.TAEINF_4_1101=2 THEN 'Chronic'
		WHEN EI.taegen_4_1200_dec IS NOT NULL THEN EI.taegen_4_1200_dec
		ELSE EI.TAEOTH_4_1190 
	    END AS SpecifyEvent
	  ,EI.TAEDAT_4_1180 AS EventOnsetDate
	  --,CASE WHEN EI.taerpt_4_1200_1 IS NOT NULL THEN 'I was involved in the care of the patient at the time of the event' 
	  -- ELSE CAST(NULL as varchar)
	  -- END AS MDConfirmed
	  ,CASE WHEN CS.TAERPT_4_1000=1 THEN 'Confirmed event'
	   WHEN CS.TAERPT_4_1000=2 THEN 'Previously reported (duplicate)'
	   WHEN CS.TAERPT_4_1000=3 THEN 'Not an event'
	   ELSE CAST(NULL as varchar)
	   END AS ConfirmationStatus
	  ,CS.TAERPT_4_1090 AS [noEventExplain]
	  ,CASE WHEN EI.hasData=1 THEN 'Yes'
	   WHEN EI.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
--SELECT * FROM [RCC_RA100].[staging].[confirmationstatus]
FROM [RCC_RA100].[staging].[eventinfo] EI
LEFT JOIN [RCC_RA100].[staging].[confirmationstatus] CS ON CS.subjectId=EI.subjectId AND CS.eventName=EI.eventName AND CS.[eventOccurrence]=EI.eventOccurrence  
LEFT JOIN #TAEDRUGS TD ON TD.SubjectID=EI.subNum AND TD.eventId=EI.eventId AND TD.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[infectiondetails] ID ON ID.subjectId=EI.subjectId AND ID.eventName=EI.eventName AND ID.eventOccurrence=EI.eventOccurrence

UNION

SELECT CS.[subNum] AS SubjectID
      ,CS.[subjectId] AS PatientID
	  ,'V15' AS [TAEVersion]
	  ,CS.[statusCode] AS statusCode
	  ,'' AS ProviderID
	  ,'' AS firstReportedVia
	  ,'' AS DateReported
	  ,SUBSTRING(CS.[eventName], 1, LEN(CS.[eventName])-4) AS EventType
	  ,CS.eventId
	  ,CS.eventOccurrence
	  ,CS.crfName
	  ,CS.eventCrfId
	  ,'' AS EventName
	  ,'' SpecifyEvent
	  ,''AS EventOnsetDate
	  --,CASE WHEN CS.taerpt_4_1200_1 IS NOT NULL THEN 'I was involved in the care of the patient at the time of--the event' 
	  -- ELSE CAST(NULL as varchar)
	  -- END AS MDConfirmed
	  ,CASE WHEN CS.TAERPT_4_1000=1 THEN 'Confirmed event'
	   WHEN CS.TAERPT_4_1000=2 THEN 'Previously reported (duplicate)'
	   WHEN CS.TAERPT_4_1000=3 THEN 'Not an event'
	   ELSE CAST(NULL as varchar)
	   END AS ConfirmationStatus
	  ,CS.TAERPT_4_1090 AS [noEventExplain]
	  ,CASE WHEN CS.hasData=1 THEN 'Yes'
	   WHEN CS.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
--SELECT * FROM [RCC_RA100].[staging].[confirmationstatus]
FROM  [RCC_RA100].[staging].[confirmationstatus] CS 
LEFT JOIN #TAEDRUGS TD ON TD.SubjectID=CS.subNum AND TD.eventId=CS.eventId AND -TD.eventOccurrence=CS.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[infectiondetails] ID ON ID.subjectId=CS.subjectId AND ID.eventName=CS.eventName AND ID.eventOccurrence=CS.eventOccurrence
WHERE (taerpt_4_1000 <> 1 OR taerpt_4_1000 IS NULL)
AND tae_tm_c IS NULL

UNION

SELECT DISTINCT 
	   EITM.[subNum] AS SubjectID
      ,EITM.[subjectId] AS PatientID
	  ,'V14.5' AS [TAEVersion]
	  ,EITM.[statusCode] AS statusCode
	  ,EITM.TAEPID_4_1000_TM AS ProviderID
	  ,CASE WHEN EITM.taerpt_4_1100_TM=1 THEN 'With a Follow-up Visit'
	   WHEN EITM.taerpt_4_1100_TM=2 THEN 'Between registry visits'
	   WHEN EITM.taerpt_4_1100_TM=3 THEN 'With a Subject Exit form'
	   WHEN EITM.taerpt_4_1100_TM=4 THEN 'Event will not be reported because patient has died or exited the study'
	   ELSE ''
	   END AS firstReportedVia
	  ,EITM.TAERPT_4_1180_TM AS DateReported
	  ,SUBSTRING(EITM.[eventName], 1, LEN(EITM.[eventName])-4) AS EventType
	  ,EITM.eventId
	  ,EITM.eventOccurrence
	  ,EITM.crfName
	  ,EITM.eventCrfId
	  ,COALESCE(TAEANA_4_1100_tm_dec, TAECAN_4_1100_tm_dec, TAECVD_4_1100_tm_dec, TAEGEN_4_1100_tm_dec, TAEHEP_4_1100_tm_dec, TAEINF_4_1100_tm_dec, TAENEU_4_1100_tm_dec, TAEGIP_4_1100_tm_dec, TAESSB_4_1100_tm_dec) AS EventName
	  ,CASE 
		WHEN EITM.TAEINF_4_1101_TM=1 THEN 'Acute'
		WHEN EITM.TAEINF_4_1101_TM=2 THEN 'Chronic'
		WHEN EITM.taegen_4_1200_TM_dec IS NOT NULL THEN EITM.taegen_4_1200_TM_dec
		ELSE EITM.TAEOTH_4_1190_TM
	    END AS SpecifyEvent
	  ,EITM.taedat_4_1180_tm AS EventOnsetDate
	  --,CASE WHEN EITM.taerpt_4_1200_1 IS NOT NULL THEN 'I was involved in the care of the patient at the time of the event' 
	  -- ELSE CAST(NULL as varchar)
	  -- END AS MDConfirmed
	  ,CASE WHEN CS.TAERPT_4_1000=1 THEN 'Confirmed event'
	   WHEN CS.TAERPT_4_1000=2 THEN 'Previously reported (duplicate)'
	   WHEN CS.TAERPT_4_1000=3 THEN 'Not an event'
	   ELSE CAST(NULL as varchar)
	   END AS ConfirmationStatus
	  ,CS.TAERPT_4_1090 AS [noEventExplain]
	  ,CASE WHEN EITM.hasData=1 THEN 'Yes'
	   WHEN EITM.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
--SELECT *
FROM [RCC_RA100].[staging].[eventinfoTM] EITM
LEFT JOIN [RCC_RA100].[staging].[confirmationstatus] CS ON CS.subjectId=EITM.subjectId AND CS.eventName=EITM.eventName AND CS.[eventOccurrence]=EITM.eventOccurrence  
LEFT JOIN #TAEDRUGS TD ON TD.SubjectID=EITM.subNum AND TD.eventId=EITM.eventId AND TD.eventOccurrence=EITM.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[infectiondetails] ID ON ID.subjectId=EITM.subjectId AND ID.eventName=EITM.eventName AND ID.eventOccurrence=EITM.eventOccurrence
) A
) B
) C
LEFT JOIN #SubjectSite SS ON SS.PatientID=C.PatientID
LEFT JOIN #TAEOutcomes TAEOUT ON TAEOUT.PatientId=C.PatientID AND TAEOUT.EventId=C.EventId AND TAEOUT.eventOccurrence=C.eventOccurrence
WHERE SS.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #TAE ORDER BY SiteID, SubjectID, EventType


IF OBJECT_ID('tempdb.dbo.#Events') IS NOT NULL BEGIN DROP TABLE #Events END

/****Put all data into one record****/

SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[TAEVersion],
	[statusCode],
	--[reviewConfirmed],
	[ProviderID],
	[firstReportedVia],
	[DateReported],
	[EventType],
    [eventId],
	[eventOccurrence],
	[crfName],
	[eventCrfId],
	[EventName],
	[SpecifyEvent],
	[EventOnsetDate],
	--[MDConfirmed],
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
	[ReasonNoSupportDocs],
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
	Z.[TAEVersion],
	Z.[statusCode],
	--Z.[tae_reviewer_confirmation_confirmed] AS reviewConfirmed,
	Z.[ProviderID],
	Z.[firstReportedVia],
	Z.[DateReported],
	Z.[EventType],
	Z.[eventId],
	Z.[eventOccurrence],
	Z.[crfName],
	Z.[eventCrfId],
	Z.[EventName],
	Z.[SpecifyEvent],
	Z.[EventOnsetDate],
	--CASE WHEN [MDConfirmed]=1 THEN 'Confirmed event'
	--WHEN [MDConfirmed]=2 THEN 'TAE previously reported (duplicate)'
	--WHEN [MDConfirmed]=3 THEN 'Not an event'
	--ELSE CAST(MDConfirmed AS varchar)
	--END AS [MDConfirmed],
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
	[ReasonNoSupportDocs],
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
	X.[LastModifiedDate]  --SELECT * FROM #LMDTGroup  --SELECT * FROM #TAE
FROM #LMDTGroup X
LEFT JOIN #TAE Z ON Z.PatientID=X.PatientID AND Z.eventId=X.eventDefinitionId AND Z.eventOccurrence=X.eventOccurence
WHERE X.eventDefinitionId<>9300
AND ISNULL(Z.SiteID, '')<>'' AND ISNULL(Z.SubjectID, '')<>''
AND X.DateCreated IS NOT NULL


UNION

SELECT DISTINCT M.[SiteID],
	M.[SubjectID],
	M.[PatientID],
	M.[TAEVersion],
	M.[statusCode],
	--M.[peq_reviewer_conf_confirmed] AS reviewConfirmed,
	M.[ProviderID],
	M.[firstReportedVia],
	M.[DateReported],
	M.[EventType],
	M.[eventId],
	M.[eventOccurrence],
	M.[crfName],
	M.[eventCrfId],
	M.[EventName],
	M.[SpecifyEvent],
	CAST([OnsetDate] AS date) AS EventOnsetDate,
	--CASE WHEN [MDConfirmed]=1 THEN 'Confirmed event'
	--WHEN [MDConfirmed]=2 THEN 'TAE previously reported (duplicate)'
	--WHEN [MDConfirmed]=3 THEN 'Not an event'
	--ELSE CAST(MDConfirmed AS varchar)
	--END AS [MDConfirmed],
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
	--CASE WHEN SupportingDocuments=1 THEN 'Are attached'
	--     WHEN SupportingDocuments=2 THEN 'Will be submitted separately'
	--	 WHEN SupportingDocuments=3 THEN 'Will not be submitted'
	--	 ELSE CAST(SupportingDocuments AS varchar)
	--	 END AS SupportingDocuments,
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[ReasonNoSupportDocs],
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
WHERE L.eventDefinitionId=9300
--SELECT * FROM [RCC_RA100].[staging].[eventcompletion]

UNION

SELECT SS.SiteID,
       TA2.SubjectID,
       TA2.patientId,
	   'V15' AS [TAEVersion],
	   'Not Started' AS statusCode,
	   --CAST(NULL AS int) AS reviewConfirmed,
	   CAST(NULL AS bigint) AS ProviderID,
	   NULL AS firstReportedVia,
	   CAST(NULL AS date) AS DateReported,
	   REPLACE(TA2.eventName, ' TAE', '') AS eventType,
	   TA2.eventDefinitionId AS eventId,
	   TA2.eventOccurrence,
	   'Event Info' AS crfName,
	   CAST(NULL AS bigint) AS eventCrfId,
	   NULL AS EventName,
	   NULL AS SpecifyEvent,
	   CAST(NULL AS date) AS EventOnsetDate,
	   --NULL AS MDConfirmed,
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
	   CASE WHEN TA2.eventDefinitionId=9300 THEN 'Pregnancy Info'
	   ELSE 'Event Info' 
	   END AS crfCaption,
	   NULL AS crfOccurence,
	   NULL AS crfId,
	   NULL AS crfOrder,
	   NULL AS LastModifiedDate --SELECT * 
FROM #TAEAudit2 TA2
LEFT JOIN #SubjectSite SS ON SS.patientId=TA2.patientId

) K


--SELECT * FROM #EVENTS

TRUNCATE TABLE [Reporting].[RA100].[t_pv_TAEQCListing_rcc_km];

INSERT INTO [Reporting].[RA100].[t_pv_TAEQCListing_rcc_km]
(
[SiteID]
,[SubjectID]
,[PatientID]
,[TAEVersion]
,[statusCode]
,[ProviderID]
,[firstReportedVia]
,[DateReported]
,[EventType]
,[eventId]
,[eventOccurrence]
,[eventCrfId]
,[EventName]
,[SpecifyEvent]
,[EventOnsetDate]
,[ConfirmationStatus]
,[noEventExplain]
,[Outcome]
,[Serious]
,[SeriousReason]
,[IVAntiInfect]
,[FUVisitTreatments]
,[OtherFUVisitTreatments]
,[EventTreatments]
,[OtherEventTreatments]
,[gender]
,[yearOfBirth]
,[race]
,[ethnicity]
,[SupportingDocuments]
,[SupportingDocumentsUploaded]
,[ReasonNoSupportDocs]
,[SupportDocsApproved]
,[EventPaid]
,[SourceDocsPaid]
,[auditType]
,[hasData]
--,[payEligibility]
,[DateCreated]
,[Event Info]
,[Event Details]
,[RA Drug Exposure]
,[Other Concurrent Drugs]
,[Event Completion]
,[Case Processing]
,[Confirmation Status]

)

SELECT *
FROM
(
SELECT DISTINCT  
		E.SiteID,
		E.SubjectID, 
		E.[PatientID],
		E.[TAEVersion],
		E.[statusCode],
		E.[ProviderID],
		E.[firstReportedVia],
		E.[DateReported],
		E.[EventType],
		E.[eventId],
		E.[eventOccurrence],
		E.[eventCrfId],
		E.[EventName],
		E.[SpecifyEvent],
		E.[EventOnsetDate],
		--E.[MDConfirmed],
		E.ConfirmationStatus,
		E.noEventExplain,
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
		E.[ReasonNoSupportDocs],
		E.[SupportDocsApproved],
		E.[EventPaid],
		E.[SourceDocsPaid],
		E.[auditType],
		E.[hasData],
		E.[DateCreated],
		E.[LastModifiedDate],
		E.[crfCaption]--,
		--CASE WHEN COALESCE(C.taevc_4_1000_1, C.taevc_4_1000_tm, C.peqvc_5_1000_1)=1 THEN 'Eligible'
		--	ELSE 'Not Eligible'
		--	END AS [PayEligibility] --Results in a conversion error. Will leave for V2.
--SELECT * FROM [RCC_RA100].[staging].[eventcompletion]
FROM #EVENTS E
LEFT JOIN #TAEAudit2 TA2 ON TA2.PatientID=E.PatientID AND TA2.eventDefinitionId=E.eventDefinitionId AND TA2.eventOccurrence=E.eventOccurrence  
--LEFT JOIN [RCC_RA100].[staging].[eventcompletion] C ON C.subjectId=E.PatientID AND C.eventId=E.eventDefinitionId AND C.eventOccurrence=E.eventOccurrence
) AS SourceTable PIVOT(MAX(LastModifiedDate) FOR crfCaption IN ([Event Info], [Event Details], [RA Drug Exposure], [Other Concurrent Drugs], [Event Completion], [Case Processing], [Confirmation Status])) AS PivotTable


--SELECT * FROM [RA100].[t_pv_TAEQCListing_rcc] ORDER BY SiteID, SubjectID, EventType



END

GO
