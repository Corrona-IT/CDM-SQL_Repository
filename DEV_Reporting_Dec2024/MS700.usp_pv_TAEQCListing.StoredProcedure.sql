USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_pv_TAEQCListing]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






















-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 6/24/2021
-- Description:	Procedure for TAE QC Listing
-- =================================================


CREATE PROCEDURE [MS700].[usp_pv_TAEQCListing] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [MS700].[t_pv_TAEQCListing]
(
	[SiteID] [int] NOT NULL,
	[SubjectID]	[VARCHAR] (15) NOT NULL,
	[PatientID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[DateCompleted]	[date] NULL,
	[DateReported] [date] NULL,
	[EventType]	[varchar] (500) NULL,
	[Event]	[varchar] (500) NULL,
	[OnsetDate]	[date] NULL,
	[ConfirmationStatus] [varchar] (500) NULL,
	[Outcome] [varchar] (500) NULL,
	[SupportingDocuments]	[varchar] (250) NULL,
	[SupportingDocumentsUploaded] [varchar] (150) NULL,
	[SupportingDocsApproved] [varchar] (25) NULL,
	[EventPaid]	 [int] NULL,
	[SourceDocsPaid] [int] NULL,
	[DateCreated] [datetime] NULL,
	[VisitType] [int] NULL,
	[eventSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[LastModifiedDate] [datetime] NULL

);
*/


TRUNCATE TABLE [Reporting].[MS700].[t_pv_TAEQCListing]

--SELECT * FROM [Reporting].[MS700].[t_pv_TAEQCListing] ORDER BY SiteID, SubjectID, OnsetDate

IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END

/****Get Subjects and Site information****/

SELECT S.SiteID
      ,S.SubjectID
	  ,S.patientId
	  ,S.SubjectStatus
	  ,S.gender
	  ,S.yearOfBirth
	  ,S.race
	  ,S.ethnicity

INTO #SubjectSite
FROM [Reporting].[MS700].[v_op_subjects] S 
WHERE S.SubjectStatus NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #SubjectSite


IF OBJECT_ID('tempdb.dbo.#LMDT') IS NOT NULL BEGIN DROP TABLE #LMDT END

/***Get Last Modified Date of Outcome pages for supporting documents pages***/

SELECT DISTINCT SiteID
      ,SubjectID
	  ,VisitTypeID
	  ,LMeventSequence
	  ,eventOccurence
	  ,LMauditLogID
	  ,LMcrfVersionId
	  ,LPM
	  ,LMUserId
	  ,LMstudyEVentId
	  ,LMeventCrfId
	  ,LMnewValue
	  ,LMoldValue
	  ,LMeventTypeId
	  ,LMreasonForChange
	  ,LMentityId
	  ,LastModDate
	  ,patientid1
	  ,studySiteId
	  ,LMcurrent
	  ,LMDeleted
	  ,LMcrfId
	  ,variableName
INTO #LMDT
FROM 
(
  SELECT ROW_NUMBER() OVER (PARTITION BY S.SiteID, S.SubjectID, EC.eventDefinitionId, EC.eventSequence, EC.eventOccurence, ITEMDATA.variableName ORDER BY  S.SiteID, S.SubjectID, AL.auditDate DESC) AS AuditDateOrder
        ,S.SiteID
        ,S.SubjectID
		,EC.eventDefinitionId AS VisitTypeID
		,EC.eventSequence AS LMeventSequence
		,EC.eventOccurence
        ,AL.[id] AS LMauditLogID
        ,AL.crfVersionId AS LMcrfVersionId
		,EDC.crfCaption AS LPM
		,AL.userId AS LMUserId
		,AL.studyEventId AS LMstudyEVentId
		,AL.eventCrfId  AS LMeventCrfId   --match this to TAE Information 
		,AL.newValue AS LMnewValue
		,AL.oldValue AS LMoldValue
		,AL.eventTypeId AS LMeventTypeId
		,AL.reasonForChange AS LMreasonForChange
		,AL.entityId AS LMentityId
		,CAST(AL.auditDate AS datetime) AS LastModDate
		,AL.subjectId as patientid1
		,AL.studySiteId
		,AL.[current] AS LMcurrent
		,AL.deleted AS LMDeleted
		,EC.crfId AS LMcrfId
		,ITEMDATA.variableName

  FROM [RCC_MS700].[api].[auditlogs] AL 
  INNER JOIN [RCC_MS700].[api].[eventcrfs] EC ON EC.studyEventId=AL.studyEventID AND EC.subjectid=AL.subjectId
  LEFT JOIN [RCC_MS700].[api].[eventdefinitions_crfs] EDC ON EDC.versionId=EC.crfVersionId and edc.crfId=EC.crfId 
  LEFT JOIN [RCC_MS700].[api].[itemsdata] ITEMDATA ON ITEMDATA.itemFormMetadataId=AL.[entityId] AND ITEMDATA.subjectId=al.subjectId AND ITEMDATA.eventCrfId=AL.eventCrfId
  LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON S.patientId=AL.subjectId 

  WHERE EDC.crfCaption IN ('TAE Outcomes', 'TAE Pregnancy Outcomes')
  AND AL.reasonForChange NOT IN ('Event Custom Label Changed', 'Form Custom Label Changed', 'CRF Custom Label Changed')
  AND ITEMDATA.variableName IN ('TAEDOC_4_1000', 'TAEDOC_4_1002', 'TAEDOC_4_1001', 'TAEDOC_4_1090', 'PEQDOC_5_1000', 'PEQDOC_5_1001', 'PEQDOC_5_1002', 'PEQDOC_5_1090')
   AND ISNULL(AL.[deleted], '')='' 
   AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')

) LASTMOD WHERE AuditDateOrder=1
--SELECT DISTINCT * FROM #LMDT WHERE SUBJECTID=70021030139




/****Get Audit Trail information****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit') IS NOT NULL BEGIN DROP TABLE #TAEAudit END

SELECT DISTINCT ROWNUM
      ,A.SiteID
	  ,A.SubjectID
	  ,A.patientid1
	  ,A.VisitTypeId AS VisitType
	  ,PageName
	  ,eventCrfId
	  ,eventSequence
	  ,eventOccurence
	  ,eventTypeId
	  ,reasonForChange
	  ,newValue
	  ,oldValue
	  ,FirstEntry
	  ,Deleted
	  ,(SELECT MAX(LastModDate) FROM #LMDT LMDT WHERE LMDT.SiteID=A.SiteID AND LMDT.patientid1=A.patientid1 AND LMDT.VisitTypeID=A.VisitTypeID AND LMDT.eventOccurence=A.eventOccurence) AS LastModifiedDate

 INTO #TAEAudit

 FROM ( 
 
  SELECT ROW_NUMBER() OVER (PARTITION BY S.SiteID, S.SubjectID, EC.eventDefinitionId, EC.eventOccurence ORDER BY  S.SiteID, S.SubjectID, AL.auditDate) AS RowNum
        ,S.SiteID
        ,S.SubjectID
		,EC.eventDefinitionId AS VisitTypeID
		,EC.eventSequence
        ,AL.[id] AS auditLogID
        ,AL.crfVersionId
		,EDC.crfCaption AS PageName
		,AL.userId
		,AL.studyEventId
		,AL.eventCrfId  --match this to TAE Information 
		,AL.reasonForChange
		,AL.newValue
		,AL.oldValue
		,AL.eventTypeId
		,AL.entityId
		,AL.auditDate AS FirstEntry
		,AL.subjectId as patientid1
		,AL.studySiteId
		,AL.[current]
		,AL.deleted AS Deleted
		,EC.crfId
		,EC.crfVersionId AS crfVersionId2
		,EC.subjectId AS patientid2
		,EC.studyEventId as studyeventid2
		,EC.eventOccurence

  FROM [RCC_MS700].[api].[auditlogs] AL
  INNER JOIN [RCC_MS700].[api].[eventcrfs] EC ON EC.studyEventId=AL.studyEventID AND EC.subjectid=AL.subjectId
  LEFT JOIN [RCC_MS700].[api].[eventdefinitions_crfs] EDC ON EDC.versionId=EC.crfVersionId and edc.crfId=EC.crfId AND EDC.eventDefinitionsId=EC.eventDefinitionId
  LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON S.patientId=AL.subjectId --AND S.studySiteID=AL.studySiteId

  WHERE EDC.crfCaption IN ('TAE Autoimmune', 'TAE General Serious', 'TAE Cancer / Malignancy', 'TAE Cardiovascular', 'TAE Hepatic', 'TAE Serious Infection', 'TAE MS Relapse', 'TAE Pregnancy Event', 'TAE Anaphylaxis / Severe Rxn') 
    AND ISNULL(AL.[deleted], '')=''
  AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')

 ) A WHERE RowNum=1
  --SELECT * FROM [RCC_MS700].[api].[eventdefinitions_crfs] where eventDefinitionsId IN (3044, 3045, 3046, 3047, 3048, 3049, 3050, 3051, 3052)
  --SELECT * FROM #TAEAudit ORDER BY SiteID, SubjectID, VisitType, eventSequence


/****Get Created Date for Scheduled but not started Events****/

IF OBJECT_ID('tempdb.dbo.#Scheduled') IS NOT NULL BEGIN DROP TABLE #Scheduled END

SELECT DISTINCT SE.[dateStart],
	   CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1'), 120) AS StartDate,
	   SE.[startTimeFlag],
	   SS.SiteID,
	   SS.SubjectID,
	   SS.patientId,
	   SS.gender,
	   SS.yearOfBirth,
	   SS.race,
	   SS.ethnicity,
	   SE.eventDefinitionId,
	   CASE WHEN ED.[name] = 'TAE MS Relapse' THEN 'Relapse'
	   WHEN ED.[name] LIKE '%TAE%' THEN REPLACE([name], 'TAE ', '')
	   END AS eventName,
	   SE.[eventOccurence],
	   SE.statusId,
	   SE.statusCode
INTO #Scheduled
FROM #SubjectSite SS
JOIN [RCC_MS700].[api].[studyevents] SE ON SS.patientId=SE.subjectId
LEFT JOIN [RCC_MS700].[api].[eventdefinitions] ED ON ED.[id]=SE.eventDefinitionId
WHERE eventDefinitionId IN (3044, 3045, 3046, 3047, 3048, 3049, 3050, 3051, 3052)
AND statusCode='Scheduled'
AND startTimeFlag='true'

--SELECT * FROM #Scheduled ORDER BY SiteID, SubjectID

IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

--SELECT * FROM #TAEOutcomes

/****Get outcomes for all TAEs except pregnancy****/

SELECT TAEO.subNum AS SubjectID
      ,TAEO.subjectId AS PatientID
	  ,TAEO.tae_md_cod AS ProviderID
	  ,TAEO.eventName AS EventName
	  ,SUBSTRING(TAEO.[eventName], 5, LEN(TAEO.[eventName])-4) AS EventType
	  ,TAEO.eventId
	  ,TAEO.eventCrfId
	  ,TAEO.eventOccurrence
	  ,TAEO.crfName
	  ,TAEO.tae_date_completed AS CompletedDate
	  ,TAEO.tae_dt_rpt AS ReportedDate
	  ,TAEO.tae_serious_outcome_dec AS SeriousOutcome
	  ,TAEO.tae_outcome_status_dec AS Outcome
	  ,TAEO.tae_support_docs_dec AS SupportingDocuments
	  ,CASE WHEN ISNULL(TAEO.tae_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,REIMB.tae_pay_support_docs_approved_dec AS SupportingDocsApproved
	  ,REIMB.tae_pay_event_status AS EventPaid
	  ,REIMB.tae_pay_support_docs_status AS SourceDocsPaid

INTO #TAEOutcomes
FROM [RCC_MS700].[staging].[taeoutcomes] TAEO
LEFT JOIN [RCC_MS700].[staging].[taereimbursement] REIMB ON REIMB.subjectId=TAEO.subjectId
   AND REIMB.eventName=TAEO.eventName AND REIMB.eventOccurrence=TAEO.eventOccurrence

--SELECT * FROM #TAEOutcomes WHERE SubjectID=70051130002


IF OBJECT_ID('tempdb.dbo.#PREG') IS NOT NULL BEGIN DROP TABLE #PREG END

/****Get Pregnancy TAE information including outcomes****/

SELECT SS.SiteID
      ,TAEP.subNum AS SubjectID
      ,TAEP.subjectId AS PatientID
	  ,TAEP.tae_md_cod AS ProviderID
	  ,SUBSTRING(TAEP.eventName, 5, LEN(TAEP.eventName)-4) AS EventType
	  ,'' AS [Event]
	  ,TAEP.eventId
	  ,TAEP.eventOccurrence
	  ,TAEP.crfName
	  ,TAEP.eventCrfId
	  ,TAEP.tae_date_completed AS DateCompleted
	  ,TAEP.tae_dt_rpt AS DateReported
	  ,CAST(NULL AS date) AS OnsetDate
	  ,TAEP.tae_report_type_dec AS ConfirmationStatus
	  ,'' AS Outcome
	  ,PREGO.tae_support_docs_dec AS SupportingDocuments
	  ,CASE WHEN ISNULL(PREGO.tae_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,REIMB.tae_pay_support_docs_approved_dec AS SupportingDocsApproved
	  ,REIMB.tae_pay_event_status AS EventPaid
	  ,REIMB.tae_pay_support_docs_status AS SourceDocsPaid
	  ,TA.FirstEntry AS DateCreated
	  ,TA.VisitType
	  ,TA.eventSequence
	  ,(SELECT MAX(TA.LastModifiedDate) FROM #TAEAudit TA WHERE TA.patientid1=TAEP.subjectId AND TA.VisitType=TAEP.eventId) AS LastModifiedDate


INTO #PREG
FROM [RCC_MS700].[staging].[taepregnancyevent] TAEP
LEFT JOIN #SubjectSite SS ON SS.patientId=TAEP.subjectId
LEFT JOIN [RCC_MS700].[staging].[taepregnancyoutcomes] PREGO ON PREGO.subjectId=TAEP.subjectId 
     AND PREGO.eventName=TAEP.eventName AND PREGO.eventOccurrence=TAEP.eventOccurrence 
LEFT JOIN [RCC_MS700].[staging].[taepregnancyreimbursement] REIMB ON REIMB.subjectId=TAEP.subjectId 
     AND REIMB.eventName=TAEP.eventName AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subjectId=TA.patientid1 AND TA.eventCrfId=TAEP.eventCrfId
WHERE SS.SubjectStatus NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #PREG WHERE SubjectID=70021030139

IF OBJECT_ID('tempdb.dbo.#TAE') IS NOT NULL BEGIN DROP TABLE #TAE END

/****Get TAEs information for all but pregnancy****/

SELECT SS.SiteID
      ,A.SubjectID
	  ,A.PatientID
	  ,TAEOUT.ProviderID
	  ,TAEOUT.CompletedDate AS DateCompleted
	  ,TAEOUT.ReportedDate AS DateReported
	  ,A.EventType
	  ,A.eventId
	  ,A.eventOccurrence
	  ,A.crfName
	  ,A.eventCrfId
	  ,A.EventName AS [Event]
	  ,A.EventOnsetDate AS OnsetDate
	  ,A.ConfirmationStatus
	  ,TAEOUT.Outcome
	  ,TAEOUT.SupportingDocuments
	  ,TAEOUT.SupportingDocumentsUploaded
	  ,TAEOUT.SupportingDocsApproved
	  ,TAEOUT.EventPaid
	  ,TAEOUT.SourceDocsPaid
	  ,TA.FirstEntry AS DateCreated
	  ,TA.VisitType
	  ,TA.eventSequence
	  ,TA.LastModifiedDate

INTO #TAE
FROM 
(
SELECT ANA.[subNum] AS SubjectID
      ,ANA.[subjectId] AS PatientID
	  ,SUBSTRING(ANA.[eventName], 5, LEN(ANA.[eventName])-4) AS EventType
	  ,ANA.eventId
	  ,ANA.eventOccurrence
	  ,ANA.crfName
	  ,ANA.eventCrfId
	  ,ANA.[tae_event_type_dec] AS EventName
	  ,ANA.[tae_event_onsetdt] AS EventOnsetDate
	  ,ANA.[tae_report_type_dec] AS ConfirmationStatus

FROM [RCC_MS700].[staging].[taeanaphylaxissevererxn] ANA

UNION

SELECT AI.[subNum] AS SubjectID
      ,AI.[subjectId] AS PatientID
	  ,SUBSTRING(AI.[eventName], 5, LEN(AI.[eventName])-4) AS EventType
	  ,AI.eventId
	  ,AI.eventOccurRence
	  ,AI.crfName
	  ,AI.eventCrfId
	  ,CASE WHEN ISNULL(AI.[tae_event_type_specify], '')='' THEN AI.[tae_event_type_dec]
	   WHEN AI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(AI.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(AI.[tae_event_type_specify], '')
	   WHEN AI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(AI.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE AI.[tae_event_type_dec]
	   END AS EventName
	  ,AI.[tae_event_onsetdt] AS EventOnsetDate
	  ,AI.[tae_report_type_dec] AS ConfirmationStatus

FROM [RCC_MS700].[staging].[taeautoimmune] AI

UNION

SELECT CM.[subNum] AS SubjectID
      ,CM.[subjectId] AS PatientID
	  ,SUBSTRING(CM.[eventName], 5, LEN(CM.[eventName])-4) AS EventType
	  ,CM.eventId
	  ,CM.eventOccurrence
	  ,CM.crfName
	  ,CM.eventCrfId
	  ,CASE WHEN ISNULL(CM.[tae_event_type_specify], '')='' THEN CM.[tae_event_type_dec]
	   WHEN CM.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CM.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(CM.[tae_event_type_specify], '')
	   WHEN CM.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CM.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE CM.[tae_event_type_dec]
	   END AS EventName
	  ,CM.[tae_event_onsetdt] AS EventOnsetDate
	  ,CM.[tae_report_type_dec] AS ConfirmationStatus
	   
FROM [RCC_MS700].[staging].[taecancermalignancy] CM

UNION

SELECT CAR.[subNum] AS SubjectID
      ,CAR.[subjectId] AS PatientID
	  ,SUBSTRING(CAR.[eventName], 5, LEN(CAR.[eventName])-4) AS EventType
	  ,CAR.eventId
	  ,CAR.eventOccurrence
	  ,CAR.crfName
	  ,CAR.eventCrfId
	  ,CASE WHEN ISNULL(CAR.[tae_event_type_specify], '')='' THEN CAR.[tae_event_type_dec]
	   WHEN CAR.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CAR.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(CAR.[tae_event_type_specify], '')
	   WHEN CAR.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CAR.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE CAR.[tae_event_type_dec]
	   END AS EventName
	  ,CAR.[tae_event_onsetdt] AS EventOnsetDate
	  ,CAR.[tae_report_type_dec] AS ConfirmationStatus	  

FROM [RCC_MS700].[staging].[taecardiovascular] CAR

UNION

SELECT GS.[subNum] AS SubjectID
      ,GS.[subjectId] AS PatientID
	  ,SUBSTRING(GS.[eventName], 5, LEN(GS.[eventName])-4) AS EventType
	  ,GS.eventId
	  ,GS.eventOccurrence
	  ,GS.crfName
	  ,GS.eventCrfId
	  ,CASE WHEN ISNULL(GS.[tae_event_type_specify], '')='' THEN GS.[tae_event_type_dec]
	   WHEN GS.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(GS.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(GS.[tae_event_type_specify], '')
	   WHEN GS.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(GS.[tae_event_type_specify], '')='' THEN 'Other'
	   WHEN GS.[tae_event_type_dec] NOT LIKE 'Other%' AND ISNULL(GS.[tae_event_type_specify], '')<>'' THEN GS.[tae_event_type_specify]
	   ELSE GS.[tae_event_type_dec]
	   END AS EventName
	  ,GS.[tae_event_onsetdt] AS EventOnsetDate
	  ,GS.[tae_report_type_dec] AS ConfirmationStatus
   
FROM [RCC_MS700].[staging].[taegeneralserious] GS

UNION

SELECT HEP.[subNum] AS SubjectID
      ,HEP.[subjectId] AS PatientID
	  ,SUBSTRING(HEP.[eventName], 5, LEN(HEP.[eventName])-4) AS EventType
	  ,HEP.eventId
	  ,HEP.eventOccurrence
	  ,HEP.crfName
	  ,HEP.eventCrfId
	  ,CASE WHEN ISNULL(HEP.[tae_event_type_specify], '')='' THEN HEP.[tae_event_type_dec]
	   WHEN HEP.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(HEP.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(HEP.[tae_event_type_specify], '')
	   WHEN HEP.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(HEP.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE HEP.[tae_event_type_dec]
	   END AS EventName
	  ,HEP.[tae_event_onsetdt] AS EventOnsetDate
	  ,HEP.[tae_report_type_dec] AS ConfirmationStatus
	  	   
FROM [RCC_MS700].[staging].[taehepatic] HEP

UNION

SELECT RELAPSE.[subNum] AS SubjectID
      ,RELAPSE.[subjectId] AS PatientID
	  ,SUBSTRING(RELAPSE.[eventName], 5, LEN(RELAPSE.[eventName])-4) AS EventType
	  ,RELAPSE.eventId
	  ,RELAPSE.eventOccurrence
	  ,RELAPSE.crfName
	  ,RELAPSE.eventCrfId
	  ,RELAPSE.[tae_event_type_specify] AS EventName
	  ,RELAPSE.[tae_event_onsetdt] AS EventOnsetDate
	  ,RELAPSE.[tae_report_type_dec] AS ConfirmationStatus
	   
FROM [RCC_MS700].[staging].[taemsrelapse] RELAPSE

UNION

SELECT SI.[subNum] AS SubjectID
      ,SI.[subjectId] AS PatientID
	  ,SUBSTRING(SI.[eventName], 5, LEN(SI.[eventName])-4) AS EventType
	  ,SI.eventId
	  ,SI.eventOccurrence
	  ,SI.crfName
	  ,SI.eventCrfId
	  ,CASE WHEN ISNULL(SI.[tae_event_type_specify], '')='' THEN SI.[tae_event_type_dec]
	   WHEN SI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(SI.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(SI.[tae_event_type_specify], '')
	   WHEN SI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(SI.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE SI.[tae_event_type_dec]
	   END AS EventName
	  ,SI.[tae_event_onsetdt] AS EventOnsetDate
	  ,SI.[tae_report_type_dec] AS ConfirmationStatus

FROM [RCC_MS700].[staging].[taeseriousinfection] SI
) A
INNER JOIN #SubjectSite SS ON SS.patientId=A.PatientID AND SS.SubjectID=a.SubjectID
LEFT JOIN #TAEAudit TA ON TA.SubjectID=A.SubjectID AND TA.VisitType=A.eventId AND TA.PageName=A.crfName AND TA.eventOccurence=A.eventOccurrence
LEFT JOIN #TAEOutcomes TAEOUT ON TAEOUT.SubjectID=A.SubjectID AND TAEOUT.EventId=A.EventId AND TAEOUT.eventOccurrence=A.eventOccurrence
WHERE SS.SubjectStatus NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #TAE ORDER BY SiteID, SubjectID, EventType, EventOccurrence

INSERT INTO [MS700].[t_pv_TAEQCListing]

(
	[SiteID],
	[SubjectID],
	[PatientID],
	[ProviderID],
	[DateCompleted],
	[DateReported],
	[EventType],
	[Event],
	[OnsetDate],
	[ConfirmationStatus],
	[Outcome],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[SupportingDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[VisitType],
	[eventSequence],
	[eventOccurrence],
	[LastModifiedDate]
)

(
--All TAEs except pregnancy and scheduled events

SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[ProviderID],
	[DateCompleted],
	[DateReported],
	[EventType],
	[Event],
	[OnsetDate],
	[ConfirmationStatus],
	[Outcome],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[SupportingDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[VisitType],
	[eventSequence],
	[eventOccurrence],
	[LastModifiedDate]
FROM #TAE


UNION

--Pregnancy events

SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[ProviderID],
	[DateCompleted],
	[DateReported],
	[EventType],
	[Event],
	CAST([OnsetDate] AS date) AS OnsetDate,
	[ConfirmationStatus],
	[Outcome],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[SupportingDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[VisitType],
	[eventSequence],
	[eventOccurrence],
	[LastModifiedDate]
FROM #PREG

UNION

--Scheduled events

SELECT DISTINCT Sched.SiteID
      ,Sched.SubjectID
	  ,Sched.PatientID
	  ,CAST(NULL AS int) AS ProviderID
	  ,CAST(NULL AS date) AS DateCompleted
	  ,CAST(NULL AS date) AS DateReported
	  ,Sched.eventName AS EventType
	  ,'' AS [Event]
	  ,CAST(NULL AS date) AS OnsetDate
	  ,'Scheduled event - no data' AS ConfirmationStatus
	  ,NULL AS Outcome
	  ,NULL AS SupportingDocuments
	  ,NULL AS SupportingDocumentsUploaded
	  ,NULL AS SupportingDocsApproved
	  ,NULL AS EventPaid
	  ,NULL AS SourceDocsPaid
	  ,StartDate AS DateCreated
	  ,eventDefinitionId AS VisitType
	  ,CAST(NULL AS int) AS eventSequence
	  ,eventOccurence
	  ,CAST(NULL AS date) AS LastModifiedDate
FROM #Scheduled Sched

)

--SELECT * FROM [MS700].[t_pv_TAEQCListing] WHERE SiteID<>1440 AND LastModifiedDate BETWEEN '2023-07-31' AND '2023-08-03' ORDER BY SiteID, SubjectID, EventType, eventOccurrence



END

GO
