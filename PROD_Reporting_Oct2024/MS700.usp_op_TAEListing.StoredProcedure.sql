USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_TAEListing]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 2/24/2020
-- Description:	Procedure for TAEQCListing
-- =================================================


CREATE PROCEDURE [MS700].[usp_op_TAEListing] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [MS700].[t_op_TAEListing]
(
	[SiteID] [int] NOT NULL,
	[SubjectID]	[VARCHAR] (15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[DateCompleted]	[date] NULL,
	[DateReported] [date] NULL,
	[EventType]	[varchar] (500) NULL,
	[Event]	[varchar] (500) NULL,
	[EventId] [int] NULL,
	[EventOccurrence] [int] NULL,
	[crfName] [varchar] (500) NULL,
	[eventCrfId] [bigint] NULL,
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
	[LastModifiedDate] [date] NULL,
	[tae_reviewer_confirmation] [int] NULL,
	[eventStatus] [varchar] (150) NULL

);
*/

--SELECT * FROM [Reporting].[MS700].[t_op_TAEListing]

TRUNCATE TABLE [Reporting].[MS700].[t_op_TAEListing]



IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END


/****Get Subjects and Site information****/

SELECT S.SiteID
      ,S.SubjectID
	  ,S.patientId AS PatientID

INTO #SubjectSite
FROM [Reporting].[MS700].[v_op_subjects] S 
WHERE S.SiteID<>1440



IF OBJECT_ID('tempdb.dbo.#LMDT') IS NOT NULL BEGIN DROP TABLE #LMDT END

/***Get Last Modified Date of Outcome pages for supporting documents pages***/

SELECT * 
INTO #LMDT
FROM 
(
  SELECT ROW_NUMBER() OVER (PARTITION BY S.SiteID, S.SubjectID, EC.eventDefinitionId, EC.eventOccurence, EC.eventSequence, ITEMDATA.variableName ORDER BY  S.SiteID, S.SubjectID, AL.auditDate DESC) AS AuditDateOrder
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
		,CAST(AL.auditDate AS date) AS LastModDate
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
  AND ITEMDATA.variableName IN ('TAEDOC_4_1000', 'TAEDOC_4_1002', 'TAEDOC_4_1001', 'TAEDOC_4_1090', 'PEQDOC_5_1000', 'PEQDOC_5_1001', 'PEQDOC_5_1002', 'PEQDOC_5_1090')
   AND ISNUMERIC(S.SiteID)=1 AND
   ISNULL(AL.[deleted], '')='' 
   AND S.SiteID<>1440

) LASTMOD WHERE AuditDateOrder=1
--SELECT * FROM #LMDT WHERE ISNULL(SiteID, '')=''
--SELECT * FROM [RCC_MS700].[api].[eventcrfs] WHERE eventOccurence IS NOT NULL


/****Get Audit Trail information****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit') IS NOT NULL BEGIN DROP TABLE #TAEAudit END

--SELECT * FROM #TAEAudit 

SELECT ROWNUM
      ,A.SiteID
	  ,A.SubjectID
	  ,A.patientid1
	  ,A.VisitTypeId AS VisitType
	  ,PageName
	  ,eventCrfId
	  ,eventSequence
	  ,eventOccurence
	  ,eventTypeId
	  ,FirstEntry
	  ,Deleted
	  ,(SELECT MAX(LastModDate) FROM #LMDT LMDT WHERE LMDT.SiteID=A.SiteID AND LMDT.SubjectID=A.SubjectID AND LMDT.VisitTypeID=A.VisitTypeID AND LMDT.eventOccurence=A.eventOccurence) AS LastModifiedDate
	  ,eventStatus

 INTO #TAEAudit

 FROM ( 
 
  SELECT ROW_NUMBER() OVER (PARTITION BY S.SiteID, S.SubjectID, EC.eventDefinitionId, EventTypeId, EC.eventSequence, EC.eventOccurence ORDER BY  S.SiteID, S.SubjectID, AL.auditDate) AS RowNum
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
		,AL.newValue
		,AL.oldValue
		,AL.eventTypeId
		,AL.reasonForChange
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
		,EC.statusCode AS eventStatus

  FROM [RCC_MS700].[api].[auditlogs] AL
  LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC ON EC.studyEventId=AL.studyEventID AND EC.subjectid=AL.subjectId
  LEFT JOIN [RCC_MS700].[api].[eventdefinitions_crfs] EDC ON EDC.versionId=EC.crfVersionId and edc.crfId=EC.crfId AND EDC.eventDefinitionsId=EC.eventDefinitionId
  LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON S.patientId=AL.subjectId --AND S.studySiteID=AL.studySiteId

  WHERE EDC.crfCaption IN ('TAE Autoimmune', 'TAE General Serious', 'TAE Cancer / Malignancy', 'TAE Cardiovascular', 'TAE Hepatic', 'TAE Serious Infection', 'TAE MS Relapse', 'TAE Pregnancy Event', 'TAE Anaphylaxis / Severe Rxn') 
  AND reasonForChange='CRF Status Changed'
  --AND oldValue='Not Started'
  AND ISNUMERIC(S.SiteID)=1
  AND ISNULL(AL.[deleted], '')=''
  AND S.SiteID<>1440
  
    ) A WHERE RowNum=1
  
  --SELECT * FROM #TAEAudit WHERE ISNULL(SiteID, '')=''


IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

/****Get outcomes for all TAEs except pregnancy****/

SELECT TAEO.subNum AS SubjectID
      ,TAEO.subjectId AS PatientID
	  ,TAEO.tae_md_cod AS ProviderID
	  ,TAEO.eventName AS EventName
	  ,SUBSTRING(TAEO.[eventName], 5, LEN(TAEO.[eventName])-4) AS EventType
	  ,TAEO.crfId
	  ,TAEO.crfVersionId
	  ,TAEO.eventId
	  ,TAEO.eventCrfId
	  ,TAEO.crfOccurrence
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
   AND REIMB.eventId=TAEO.eventId AND REIMB.eventOccurrence=TAEO.eventOccurrence

--SELECT * FROM #TAEOutcomes


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
	  ,TAEP.crfId
	  ,TAEP.eventCrfId
	  ,TAEP.crfOccurrence
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
	  ,(SELECT MAX(TA.LastModifiedDate) FROM #TAEAudit TA WHERE TA.SubjectID=TAEP.subNum AND TA.VisitType=TAEP.eventId) AS LastModifiedDate
	  ,EC.statusCode AS eventStatus


INTO #PREG
FROM [RCC_MS700].[staging].[taepregnancyevent] TAEP
LEFT JOIN #SubjectSite SS ON SS.PatientID=TAEP.subjectId
LEFT JOIN [RCC_MS700].[staging].[taepregnancyoutcomes] PREGO ON PREGO.subjectId=TAEP.subjectId 
     AND PREGO.eventId=TAEP.eventId AND PREGO.eventOccurrence=TAEP.eventOccurrence 
LEFT JOIN [RCC_MS700].[staging].[taepregnancyreimbursement] REIMB ON REIMB.subjectId=TAEP.subjectId 
     AND REIMB.eventId=TAEP.eventId AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subjectId=TA.patientid1 AND TA.eventCrfId=TAEP.eventCrfId
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC on EC.id=TAEP.eventCRFId AND EC.eventOccurence=TAEP.eventOccurrence AND EC.subjectId=TAEP.subjectId
AND SS.SiteID<>1440

--SELECT * FROM #PREG WHERE ISNULL(SiteID, '')=''


IF OBJECT_ID('tempdb.dbo.#TAECompletionStatus') IS NOT NULL BEGIN DROP TABLE #TAECompletionStatus END

/****Get TAE Completion Status****/

SELECT subNum
      ,subjectId
	  ,eventId
	  ,eventOccurrence
	  ,eventName
	  ,eventStatus
INTO #TAECompletionStatus
FROM 
(
SELECT TC.subNum
      ,TC.subjectId
	  ,TC.eventId
	  ,TC.eventOccurrence
	  ,TC.eventName
	  ,EC.statusCode AS eventStatus

FROM [RCC_MS700].[staging].[taecompletion] TC 
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC ON EC.subjectId=TC.subjectId AND EC.[id]=TC.eventCrfId

UNION

SELECT PC.subNum
      ,PC.subjectId
	  ,PC.eventId
	  ,PC.eventOccurrence
	  ,PC.eventName
	  ,EC.statusCode AS eventStatus

FROM [RCC_MS700].[staging].[taepregnancycompletion] PC 
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC ON EC.subjectId=PC.subjectId AND EC.[id]=PC.eventCrfId
) C

--SELECT * FROM #TAECompletionStatus WHERE subjectId=110256

IF OBJECT_ID('tempdb.dbo.#TAE') IS NOT NULL BEGIN DROP TABLE #TAE END

/****Get TAEs information for all but pregnancy****/

SELECT DISTINCT SS.SiteID
      ,CAST(A.SubjectID AS bigint) AS SubjectID
	  ,CAST(A.PatientID AS bigint) AS PatientID
	  ,TAEOUT.ProviderID
	  ,TAEOUT.CompletedDate AS DateCompleted
	  ,TAEOUT.ReportedDate AS DateReported
	  ,A.EventType
	  ,A.eventId
	  ,A.eventOccurrence
	  ,A.crfName
	  ,A.crfId
	  ,A.eventCrfId
	  ,A.crfOccurrence
	  ,A.valueIndex
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
	  ,TA.eventStatus

INTO #TAE
FROM 
(
SELECT CAST(ANA.[subNum] AS bigint) AS SubjectID
      ,ANA.[subjectId] AS PatientID
	  ,SUBSTRING(ANA.[eventName], 5, LEN(ANA.[eventName])-4) AS EventType
	  ,ANA.eventId
	  ,ANA.eventOccurrence
	  ,ANA.crfName
	  ,ANA.crfId
	  ,ANA.eventCrfId
	  ,ANA.crfOccurrence
	  ,ANA.valueIndex
	  ,ANA.[tae_event_type_dec] AS EventName
	  ,ANA.[tae_event_onsetdt] AS EventOnsetDate
	  ,ANA.[tae_report_type_dec] AS ConfirmationStatus

FROM [RCC_MS700].[staging].[taeanaphylaxissevererxn] ANA

UNION

SELECT CAST(AI.[subNum] AS bigint) AS SubjectID
      ,AI.[subjectId] AS PatientID
	  ,SUBSTRING(AI.[eventName], 5, LEN(AI.[eventName])-4) AS EventType
	  ,AI.eventId
	  ,AI.eventOccurRence
	  ,AI.crfName
	  ,AI.crfId
	  ,AI.eventCrfId
	  ,AI.crfOccurrence
	  ,AI.valueIndex
	  ,CASE WHEN ISNULL(AI.[tae_event_type_specify], '')='' THEN AI.[tae_event_type_dec]
	   WHEN AI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(AI.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(AI.[tae_event_type_specify], '')
	   WHEN AI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(AI.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE AI.[tae_event_type_dec]
	   END AS EventName
	  ,AI.[tae_event_onsetdt] AS EventOnsetDate
	  ,AI.[tae_report_type_dec] AS ConfirmationStatus

FROM [RCC_MS700].[staging].[taeautoimmune] AI

UNION

SELECT CAST(CM.[subNum] AS bigint) AS SubjectID
      ,CM.[subjectId] AS PatientID
	  ,SUBSTRING(CM.[eventName], 5, LEN(CM.[eventName])-4) AS EventType
	  ,CM.eventId
	  ,CM.eventOccurrence
	  ,CM.crfName
	  ,CM.crfId
	  ,CM.eventCrfId
	  ,CM.crfOccurrence
	  ,CM.valueIndex
	  ,CASE WHEN ISNULL(CM.[tae_event_type_specify], '')='' THEN CM.[tae_event_type_dec]
	   WHEN CM.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CM.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(CM.[tae_event_type_specify], '')
	   WHEN CM.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CM.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE CM.[tae_event_type_dec]
	   END AS EventName
	  ,CM.[tae_event_onsetdt] AS EventOnsetDate
	  ,CM.[tae_report_type_dec] AS ConfirmationStatus
	   
FROM [RCC_MS700].[staging].[taecancermalignancy] CM

UNION

SELECT CAST(CAR.[subNum] AS bigint) AS SubjectID
      ,CAR.[subjectId] AS PatientID
	  ,SUBSTRING(CAR.[eventName], 5, LEN(CAR.[eventName])-4) AS EventType
	  ,CAR.eventId
	  ,CAR.eventOccurrence
	  ,CAR.crfName
	  ,CAR.crfId
	  ,CAR.eventCrfId
	  ,CAR.crfOccurrence
	  ,CAR.valueIndex
	  ,CASE WHEN ISNULL(CAR.[tae_event_type_specify], '')='' THEN CAR.[tae_event_type_dec]
	   WHEN CAR.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CAR.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(CAR.[tae_event_type_specify], '')
	   WHEN CAR.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(CAR.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE CAR.[tae_event_type_dec]
	   END AS EventName
	  ,CAR.[tae_event_onsetdt] AS EventOnsetDate
	  ,CAR.[tae_report_type_dec] AS ConfirmationStatus	  

FROM [RCC_MS700].[staging].[taecardiovascular] CAR

UNION

SELECT CAST(GS.[subNum] AS bigint) AS SubjectID
      ,GS.[subjectId] AS PatientID
	  ,SUBSTRING(GS.[eventName], 5, LEN(GS.[eventName])-4) AS EventType
	  ,GS.eventId
	  ,GS.eventOccurrence
	  ,GS.crfName
	  ,GS.crfId
	  ,GS.eventCrfId
	  ,GS.crfOccurrence
	  ,GS.valueIndex
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

SELECT CAST(HEP.[subNum] AS bigint) AS SubjectID
      ,HEP.[subjectId] AS PatientID
	  ,SUBSTRING(HEP.[eventName], 5, LEN(HEP.[eventName])-4) AS EventType
	  ,HEP.eventId
	  ,HEP.eventOccurrence
	  ,HEP.crfName
	  ,HEP.crfId
	  ,HEP.eventCrfId
	  ,HEP.crfOccurrence
	  ,HEP.valueIndex
	  ,CASE WHEN ISNULL(HEP.[tae_event_type_specify], '')='' THEN HEP.[tae_event_type_dec]
	   WHEN HEP.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(HEP.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(HEP.[tae_event_type_specify], '')
	   WHEN HEP.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(HEP.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE HEP.[tae_event_type_dec]
	   END AS EventName
	  ,HEP.[tae_event_onsetdt] AS EventOnsetDate
	  ,HEP.[tae_report_type_dec] AS ConfirmationStatus
	  	   
FROM [RCC_MS700].[staging].[taehepatic] HEP

UNION

SELECT CAST(RELAPSE.[subNum] AS bigint) AS SubjectID
      ,RELAPSE.[subjectId] AS PatientID
	  ,SUBSTRING(RELAPSE.[eventName], 5, LEN(RELAPSE.[eventName])-4) AS EventType
	  ,RELAPSE.eventId
	  ,RELAPSE.eventOccurrence
	  ,RELAPSE.crfName
	  ,RELAPSE.crfId
	  ,RELAPSE.eventCrfId
	  ,RELAPSE.crfOccurrence
	  ,RELAPSE.valueIndex
	  ,RELAPSE.[tae_event_type_specify] AS EventName
	  ,RELAPSE.[tae_event_onsetdt] AS EventOnsetDate
	  ,RELAPSE.[tae_report_type_dec] AS ConfirmationStatus
	   
FROM [RCC_MS700].[staging].[taemsrelapse] RELAPSE

UNION

SELECT CAST(SI.[subNum] AS bigint) AS SubjectID
      ,SI.[subjectId] AS PatientID
	  ,SUBSTRING(SI.[eventName], 5, LEN(SI.[eventName])-4) AS EventType
	  ,SI.eventId
	  ,SI.eventOccurrence
	  ,SI.crfName
	  ,SI.crfId
	  ,SI.eventCrfId
	  ,SI.crfOccurrence
	  ,SI.valueIndex
	  ,CASE WHEN ISNULL(SI.[tae_event_type_specify], '')='' THEN SI.[tae_event_type_dec]
	   WHEN SI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(SI.[tae_event_type_specify], '')<>'' THEN 'Other: ' + ISNULL(SI.[tae_event_type_specify], '')
	   WHEN SI.[tae_event_type_dec] LIKE 'Other%' AND ISNULL(SI.[tae_event_type_specify], '')='' THEN 'Other'
	   ELSE SI.[tae_event_type_dec]
	   END AS EventName
	  ,SI.[tae_event_onsetdt] AS EventOnsetDate
	  ,SI.[tae_report_type_dec] AS ConfirmationStatus

FROM [RCC_MS700].[staging].[taeseriousinfection] SI
) A
LEFT JOIN #SubjectSite SS ON SS.PatientID=A.PatientID 
LEFT JOIN #TAEAudit TA ON TA.patientid1=A.PatientID AND TA.VisitType=A.eventId AND TA.eventOccurence=A.eventOccurrence
LEFT JOIN #TAEOutcomes TAEOUT ON TAEOUT.PatientID=A.PatientID AND TAEOUT.eventId=A.eventId AND TAEOUT.eventOccurrence=A.eventOccurrence
--select * from #tae WHERE PatientID=110256
--SELECT * FROM #TAEOutcomes WHERE ISNULL(SiteID, '')=''

INSERT INTO [MS700].[t_op_TAEListing]

(
	[SiteID],
	[SubjectID],
	[PatientID],
	[ProviderID],
	[DateCompleted],
	[DateReported],
	[EventType],
	[Event],
	[EventId],
	[EventOccurrence],
	[crfName],
	[eventCrfId],
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
	[LastModifiedDate],
	[tae_reviewer_confirmation],
	[eventStatus]
)

(

SELECT DISTINCT TAE.[SiteID],
	TAE.[SubjectID],
	TAE.[PatientID],
	TAE.[ProviderID],
	TAE.[DateCompleted],
	TAE.[DateReported],
	TAE.[EventType],
	TAE.[Event],
	TAE.[EventId],
	TAE.[eventOccurrence],
	TAE.[crfName],
	TAE.[eventCrfId],
	TAE.[OnsetDate],
	TAE.[ConfirmationStatus],
	TAE.[Outcome],
	TAE.[SupportingDocuments],
	TAE.[SupportingDocumentsUploaded],
	TAE.[SupportingDocsApproved],
	TAE.[EventPaid],
	TAE.[SourceDocsPaid],
	TAE.[DateCreated],
	TAE.[VisitType],
	TAE.[eventSequence],
	TAE.[LastModifiedDate],
	TC.[tae_reviewer_confirmation],
	TCS.eventStatus

FROM #TAE TAE
LEFT JOIN [RCC_MS700].[staging].[taecompletion] TC ON TC.subjectId=TAE.PatientID AND TC.eventId=TAE.eventId AND TC.eventOccurrence=TAE.eventOccurrence
LEFT JOIN #TAECompletionStatus TCS ON TCS.subjectId=TAE.PatientID AND TCS.eventId=TAE.eventId AND TCS.eventOccurrence=TAE.eventOccurrence
WHERE ISNULL(SiteID, '')<>''

UNION

SELECT DISTINCT PREG.[SiteID],
	PREG.[SubjectID],
	PREG.[PatientID],
	PREG.[ProviderID],
	PREG.[DateCompleted],
	PREG.[DateReported],
	PREG.[EventType],
	PREG.[Event],
	PREG.[EventId],
	PREG.[eventOccurrence],
	PREG.[crfName],
	PREG.[eventCrfId],
	CAST(PREG.[OnsetDate] AS date) AS OnsetDate,
	PREG.[ConfirmationStatus],
	PREG.[Outcome],
	PREG.[SupportingDocuments],
	PREG.[SupportingDocumentsUploaded],
	PREG.[SupportingDocsApproved],
	PREG.[EventPaid],
	PREG.[SourceDocsPaid],
	PREG.[DateCreated],
	PREG.[VisitType],
	PREG.[eventSequence],
	PREG.[LastModifiedDate],
	PC.[tae_reviewer_confirmation],
	TCS.eventStatus

FROM #PREG PREG
LEFT JOIN [RCC_MS700].[staging].[taepregnancycompletion] PC ON PC.subjectId=PREG.PatientID AND PC.eventId=PREG.eventId AND PC.eventOccurrence=PREG.eventOccurrence
LEFT JOIN #TAECompletionStatus TCS ON TCS.subjectId=PREG.PatientID AND TCS.eventId=PREG.eventId AND TCS.eventOccurrence=PREG.eventOccurrence

)


--SELECT * FROM [MS700].[t_op_TAEListing] ORDER BY SiteID, SubjectID, OnsetDate

END

GO
