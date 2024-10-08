USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_pv_TAEQCListing_TEST]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






















-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 2/24/2020
-- Description:	Procedure for Data Entry Lag Table
-- =================================================


CREATE PROCEDURE [AD550].[usp_pv_TAEQCListing_TEST] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_pv_TAEQCListing_TEST](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](35) NULL,
	[DateReported] [date] NULL,
	[EventType] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[EventName] [nvarchar](350) NULL,
	[EventOnsetDate] [date] NULL,
	[MDConfirmed] [nvarchar](30) NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](150) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[DateCreated] [datetime] NULL,
	[Event Info Last Modified Date] [datetime] NULL,
	[Event Info Question] [nvarchar](500) NULL,
	[Event Info New Value] [nvarchar](350) NULL,
	[Event Details Last Modified Date] [datetime] NULL,
	[Event Details Question] [nvarchar](500) NULL,
	[Event Details New Value] [nvarchar](350) NULL,
	[AD Drug Exposure Last Modified Date] [datetime] NULL,
	[AD Drug Exposure Question] [nvarchar](500) NULL,
	[AD Drug Exposure New Value] [nvarchar](350) NULL,
	[Other Concurrent Drugs Last Modified Date] [datetime] NULL,
	[Other Concurrent Drugs Question] [nvarchar](500) NULL,
	[Other Concurrent Drugs New Value] [nvarchar](350) NULL,
	[Data Entry Completion Last Modified Date] [datetime] NULL,
	[Data Entry Completion Question] [nvarchar](500) NULL,
	[Data Entry Completion New Value] [nvarchar](350) NULL,
	[Supporting Documents Approval Last Modified Date] [datetime] NULL,
	[Supporting Documents Approval Question] [nvarchar](500) NULL,
	[Supporting Documents Approval New Value] [nvarchar](350) NULL
) ON [PRIMARY]
GO
*/



/****Get Subjects and Site information****/

IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END

SELECT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]

INTO #SubjectSite
FROM [Reporting].[AD550].[v_op_subjects] S 
WHERE --S.[SiteID]<>1440 AND 
S.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #SubjectSite ORDER BY SiteID, SubjectID



/****Get Created Date for Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit') IS NOT NULL BEGIN DROP TABLE #TAEAudit END

SELECT Rownum,
       SiteID,
       CAST(SubjectID AS bigint) AS SubjectID,
	   PatientID,
	   eventDefinitionId,
	   eventOccurence,
	   crfCaption,
	   crfOrder,
	   crfOccurence,
	   DateCreated

INTO #TAEAudit
FROM
(
SELECT  ROW_NUMBER () OVER (PARTITION BY SubjectID, eventDefinitionId, eventOccurence ORDER BY SubjectID, eventDefinitionId, eventOccurence, crfOrder, DateCreated, crfOccurence) AS RowNum,
        SiteID,
		CAST(SubjectID AS bigint) AS SubjectID,
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
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption]LIKE '%Details' THEN 20
	   WHEN EDI.[crfCaption]='AD Drug Exposure' THEN 30
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 40
	   WHEN EDI.[crfCaption]='Data Entry Completion' THEN 50
	   WHEN EDI.[crfCaption]='Supporting Documents Approval' THEN 60
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject\
	  ,MIN(AL.[auditDate]) AS DateCreated

  FROM [RCC_AD550].[api].[eventcrfs] EC
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId
  JOIN [RCC_AD550].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_AD550].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId =EC.id

  WHERE eventDefinitionId IN (8035, 8036, 8037, 8039, 8040, 8041, 8042, 8043, 8044)
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  --AND ISNULL(AL.eventCrfId, '')<>''

  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence
) A
) B WHERE RowNum=1
  
--SELECT * FROM #TAEAudit ORDER BY PatientID, EventDefinitionID, eventOccurence


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
		reasonForChange,
		newValue,
		[variableName],
		item_labelPlainText

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
		reasonForChange,
		newValue,
		[variableName],
		item_labelPlainText
FROM
(
SELECT DISTINCT S.SiteID
      ,S.SubjectID
	  ,S.[patientId] AS PatientID
      ,EC.[eventDefinitionId]
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption]LIKE '%Details' THEN 20
	   WHEN EDI.[crfCaption]='AD Drug Exposure' THEN 30
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 40
	   WHEN EDI.[crfCaption]='Data Entry Completion' THEN 50
	   WHEN EDI.[crfCaption]='Supporting Documents Approval' THEN 60
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject\
	  ,MAX(AL.[auditDate]) AS LastModifiedDate
	  ,AL.reasonForChange
	  ,AL.newValue
	  ,ITEMSD.[variableName]
	  ,CRFI.item_labelPlainText

  FROM [RCC_AD550].[api].[eventcrfs] EC
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId
  JOIN [RCC_AD550].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_AD550].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId=EC.id
  LEFT JOIN [RCC_AD550].[api].[itemsdata] ITEMSD ON ITEMSD.itemFormMetadataId=AL.entityId
  LEFT JOIN [RCC_AD550].[api].[crfitems] CRFI ON CRFI.item_variableName=ITEMSD.variableName

  WHERE eventDefinitionId IN (8035, 8036, 8037, 8039, 8040, 8041, 8042, 8043, 8044)
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  AND ISNULL(AL.reasonForChange, '')<>'CRF Status Changed'
 -- AND ISNULL(AL.eventCrfId, '')<>''

  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence, AL.reasonForChange, AL.newValue, ITEMSD.[variableName], CRFI.item_labelPlainText
) A 
) B --WHERE RowNum=1

--SELECT * FROM #LMDT ORDER BY SubjectID, RowNum




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
	   TA.DateCreated,
	   C.LastModifiedDate,
	   CASE WHEN ISNULL(C.item_labelPlainText, '')='' THEN C.reasonForChange
	   ELSE C.item_labelPlainText
	   END AS Question,
	   C.newValue

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
reasonForChange,
newValue,
[variableName],
item_labelPlainText


FROM #LMDT
) C 
LEFT JOIN #TAEAudit TA ON TA.SubjectID=C.SubjectID AND TA.eventDefinitionId=C.eventDefinitionId AND TA.eventOccurence=C.eventOccurence 
WHERE C.crfRowNum=1

--SELECT * FROM #LMDTGroup ORDER BY SiteID, SubjectID, eventDefinitionId, eventOccurence, crfOrder



/****Get outcomes for all TAEs except pregnancy****/

IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

SELECT EI.subNum AS SubjectID
      ,EI.subjectId AS PatientID
	  ,EI.tae_md_cod AS ProviderID
	  ,EI.eventName AS EventName
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,EI.eventId
	  ,EI.eventCrfId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,CASE WHEN EI.tae_rpt_status=1 THEN 'Visit form'
	   WHEN EI.tae_rpt_status=2 THEN 'Between visits'
	   WHEN EI.tae_rpt_status=3 THEN 'Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,EI.tae_dt_rpt AS ReportedDate
	  ,EI.tae_ser_out_any AS SeriousOutcome
	  ,EI.[tae_outcome_status] AS Outcome
	  ,EI.tae_support_docs AS SupportingDocuments
	  ,CASE WHEN ISNULL(EI.tae_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,REIMB.taepay_event_status AS EventPaid
	  ,REIMB.taepay_support_docs_paid AS SourceDocsPaid

INTO #TAEOutcomes

FROM [RCC_AD550].[staging].[eventinfo] EI
LEFT JOIN [RCC_AD550].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=EI.subjectId
   AND REIMB.eventName=EI.eventName AND REIMB.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[supportingdocumentsapproval] SDA ON SDA.subjectId=EI.subjectId AND SDA.eventName=EI.eventName AND SDA.[eventOccurrence]=EI.eventOccurrence

--SELECT * FROM #TAEOutcomes 


/****Get Pregnancy TAE information including outcomes****/

IF OBJECT_ID('tempdb.dbo.#PREG') IS NOT NULL BEGIN DROP TABLE #PREG END

SELECT SS.SiteID
      ,TAEP.subNum AS SubjectID
      ,TAEP.subjectId AS PatientID
	  ,TAEP.statusCode
	  ,TAEP.peq_md_cod AS ProviderID
	  ,CASE WHEN TAEP.peq_rpt_status=1 THEN 'Visit form'
	   WHEN TAEP.peq_rpt_status=2 THEN 'Between visits'
	   WHEN TAEP.peq_rpt_status=3 THEN 'Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,TAEP.peq_dt_rpt AS DateReported
	  ,TAEP.eventName AS EventType
	  ,TAEP.eventId
	  ,TAEP.eventOccurrence
	  ,TAEP.crfName
	  ,TAEP.eventCrfId
	  ,'Pregnancy' AS EventName
	  ,CAST(NULL AS date) AS OnsetDate
	  ,NULL AS MDConfirmed
	  ,CASE WHEN TAEP.peq_report_type=1 THEN 'Confirmed event'
	   WHEN TAEP.peq_report_type=2 THEN 'Previously reported'
	   WHEN TAEP.peq_report_type=3 THEN 'Not an event'
	   ELSE CAST(NULL AS nvarchar)
	   END AS ConfirmationStatus
	  ,CASE WHEN TAEP.hasData=1 THEN 'Yes'
	   WHEN TAEP.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
	  ,'' AS Outcome
	  ,TAEP.peq_support_docs AS SupportingDocuments
	  ,CASE WHEN ISNULL(TAEP.peq_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,REIMB.taepay_event_status AS EventPaid
	  ,REIMB.taepay_support_docs_paid AS SourceDocsPaid
	  ,TA.eventDefinitionId
	  ,TA.eventOccurence

INTO #PREG
FROM [RCC_AD550].[staging].[pregnancyinfo] TAEP
LEFT JOIN #SubjectSite SS ON SS.PatientID=TAEP.subjectId
LEFT JOIN [RCC_AD550].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=TAEP.subjectId 
     AND REIMB.eventName=TAEP.eventName AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subjectId=TA.PatientID AND TA.eventDefinitionId=TAEP.eventId and TA.eventOccurence=TAEP.eventOccurrence
LEFT JOIN [RCC_AD550].[staging].[supportingdocumentsapproval] SDA ON SDA.subjectId=TAEP.subjectId AND SDA.eventName=TAEP.eventName AND SDA.[eventOccurrence]=TAEP.eventOccurrence
WHERE SS.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #PREG



IF OBJECT_ID('tempdb.dbo.#TAE') IS NOT NULL BEGIN DROP TABLE #TAE END

/****Get TAEs information for all but pregnancy****/

SELECT SS.SiteID
      ,C.SubjectID,
       C.PatientID,
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
	   C.EventOnsetDate,
	   C.MDConfirmed,
	   C.ConfirmationStatus,
	   C.hasData
	  ,TAEOUT.Outcome
	  ,TAEOUT.SupportingDocuments
	  ,TAEOUT.SupportingDocumentsUploaded
	  ,TAEOUT.EventPaid
	  ,TAEOUT.SourceDocsPaid

INTO #TAE
FROM 
(

SELECT B.SubjectID,
       B.PatientID,
	   B.statusCode,
	   B.ProviderID,
	   B.firstReportedVia,
	   B.DateReported,
	   B.EventType,
	   B.eventId,
	   B.eventOccurrence,
	   B.crfName,
	   B.eventCrfId,
	   B.EventName + ISNULL(', ' + SpecifyEvent, '') AS EventName,
	   B.EventOnsetDate,
	   B.MDConfirmed,
	   B.ConfirmationStatus,
	   B.hasData

FROM
(
SELECT A.SubjectID,
       A.PatientID,
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
	   A.MDConfirmed,
	   A.ConfirmationStatus,
	   A.hasData

FROM
(
SELECT EI.[subNum] AS SubjectID
      ,EI.[subjectId] AS PatientID
	  ,EI.[statusCode] AS statusCode
	  ,EI.[tae_md_cod] AS ProviderID
	  ,CASE WHEN EI.tae_rpt_status=1 THEN 'Visit form'
	   WHEN EI.tae_rpt_status=2 THEN 'Between visits'
	   WHEN EI.tae_rpt_status=3 THEN 'Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,EI.[tae_dt_rpt] AS DateReported
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,COALESCE([tae_vte_event_type_dec], [tae_ser_event_type_dec], [tae_eye_event_type_dec], [tae_hep_event_type_dec], [tae_gen_event_type_dec], [tae_c19_event_type_dec], [tae_cvd_event_type_dec], [tae_can_event_type_dec], [tae_ana_event_type_dec]) AS EventName
	  ,EI.[tae_event_type_specify] AS SpecifyEvent
	  ,EI.[tae_onset_dt] AS EventOnsetDate
	  ,EI.[tae_confirm_md_confirmed] AS MDConfirmed
	  ,CASE WHEN tae_status=1 THEN 'Confirmed event'
	   WHEN tae_status=2 THEN 'Previously reported'
	   WHEN tae_status=3 THEN 'Not an event'
	   ELSE CAST(NULL as varchar)
	   END AS ConfirmationStatus
	  ,CASE WHEN hasData=1 THEN 'Yes'
	   WHEN hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData

FROM [RCC_AD550].[staging].[eventinfo] EI

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
	[statusCode],
	[ProviderID],
	[firstReportedVia],
	[DateReported],
	[EventType],
    [eventId],
	[eventOccurrence],
	[crfName],
	[eventCrfId],
	[EventName],
	[EventOnsetDate],
	[MDConfirmed],
	ConfirmationStatus,
	[hasData],
	[Outcome],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[eventDefinitionId],
	[crfCaption],
	[crfOccurence],
	[crfId],
	[crfOrder],
	CONVERT(varchar, [LastModifiedDate], 113) AS LastModifiedDate,
	Question,
	CASE WHEN ISDATE(newValue)=1 THEN CONVERT(varchar, newValue, 113)
	ELSE newValue
	END AS newValue

INTO #EVENTS
FROM
(
SELECT DISTINCT Z.[SiteID],
	Z.[SubjectID],
	Z.[PatientID],
	Z.[statusCode],
	Z.[ProviderID],
	Z.[firstReportedVia],
	Z.[DateReported],
	Z.[EventType],
	Z.[eventId],
	Z.[eventOccurrence],
	Z.[crfName],
	Z.[eventCrfId],
	Z.[EventName],
	Z.[EventOnsetDate],
	CASE WHEN [MDConfirmed]=1 THEN 'Confirmed event'
	WHEN [MDConfirmed]=2 THEN 'TAE previously reported (duplicate)'
	WHEN [MDConfirmed]=3 THEN 'Not an event'
	ELSE ''
	END AS [MDConfirmed],
	Z.ConfirmationStatus,
	Z.[hasData],
	CASE WHEN Outcome=1 THEN 'Death'
	WHEN Outcome=2 THEN 'Ongoing event'
	WHEN Outcome=3 THEN 'Recovered no sequelae'
	WHEN Outcome=4 THEN 'Recovered with sequelae'
	WHEN Outcome=97 THEN 'Unknown'
	ELSE ''
	END AS Outcome,
	CASE WHEN SupportingDocuments=1 THEN 'Are attached'
	     WHEN SupportingDocuments=2 THEN 'Will be submitted separately'
		 WHEN SupportingDocuments=3 THEN 'Will not be submitted'
		 ELSE ''
		 END AS SupportingDocuments,
	[SupportingDocumentsUploaded],
	CASE WHEN [EventPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [EventPaid],
	CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [SourceDocsPaid],
	X.[DateCreated],
	X.[eventDefinitionId],
	X.[crfCaption],
	X.[crfOccurence],
	X.[crfId],
	X.[crfOrder],
	X.[LastModifiedDate],
	X.Question,
	CAST(X.newValue AS varchar) AS newValue
FROM #LMDTGroup X
LEFT JOIN #TAE Z ON Z.PatientID=X.PatientID AND Z.eventId=X.eventDefinitionId AND Z.eventOccurrence=X.eventOccurence
WHERE X.eventDefinitionId<>8044

UNION

SELECT DISTINCT M.[SiteID],
	M.[SubjectID],
	M.[PatientID],
	M.[statusCode],
	M.[ProviderID],
	M.[firstReportedVia],
	M.[DateReported],
	M.[EventType],
	M.[eventId],
	M.[eventOccurrence],
	M.[crfName],
	M.[eventCrfId],
	M.[EventName],
	CAST([OnsetDate] AS date) AS EventOnsetDate,
	CASE WHEN [MDConfirmed]=1 THEN 'Confirmed event'
	WHEN [MDConfirmed]=2 THEN 'TAE previously reported (duplicate)'
	WHEN [MDConfirmed]=3 THEN 'Not an event'
	ELSE ''
	END AS [MDConfirmed],
	ConfirmationStatus,
	[hasData],
	'' AS Outcome,
	CASE WHEN SupportingDocuments=1 THEN 'Are attached'
	     WHEN SupportingDocuments=2 THEN 'Will be submitted separately'
		 WHEN SupportingDocuments=3 THEN 'Will not be submitted'
		 ELSE ''
		 END AS SupportingDocuments,
	[SupportingDocumentsUploaded],
	CASE WHEN [EventPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [EventPaid],
	CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	     ELSE 'No'
		 END AS [SourceDocsPaid],
	L.[DateCreated],
	L.[eventDefinitionId],
	CASE WHEN L.[crfCaption]='Pregnancy Info' THEN 'Event Info'
	ELSE L.[crfCaption]
	END AS crfCaption,
	L.[crfOccurence],
	L.[crfId],
	L.[crfOrder],
	L.[LastModifiedDate],
	L.Question,
	CAST(L.newValue AS varchar) AS newValue

FROM #LMDTGroup L
LEFT JOIN #PREG M ON M.PatientID=L.PatientID AND M.eventId=L.eventDefinitionId AND M.eventOccurrence=L.eventOccurence
WHERE L.eventDefinitionId=8044
) K

--SELECT * FROM #EVENTS


IF OBJECT_ID('tempdb.dbo.#PIVOTEDDATA') IS NOT NULL BEGIN DROP TABLE #PIVOTEDDATA END

/****Pivot Data****/

SELECT *
INTO #PIVOTEDDATA
FROM
(
SELECT  SiteID,
		SubjectID, 
		[PatientID],
		[statusCode],
		[ProviderID],
		[firstReportedVia],
		[DateReported],
		[EventType],
		[eventId],
		[eventOccurrence],
		[eventCrfId],
		[EventName],
		[EventOnsetDate],
		[MDConfirmed],
		ConfirmationStatus,
		[hasData],
		[Outcome],
		[SupportingDocuments],
		[SupportingDocumentsUploaded],
		[EventPaid],
		[SourceDocsPaid],
		[DateCreated],
		DATA,
		[crfCaption] + ' ' + COLUMN_NAME AS PIV_COL

FROM #EVENTS  
CROSS APPLY (VALUES ('Last Modified Date', LastModifiedDate),
                    ('Question', Question),
					('New Value', newValue)) CS(COLUMN_NAME, DATA)) A

PIVOT (MAX(DATA)
       FOR PIV_COL IN ([Event Info Last Modified Date],
	                   [Event Info Question],
					   [Event Info New Value],
					   [Event Details Last Modified Date],
					   [Event Details Question],
					   [Event Details New Value],
					   [AD Drug Exposure Last Modified Date],
					   [AD Drug Exposure Question],
					   [AD Drug Exposure New Value],
					   [Other Concurrent Drugs Last Modified Date],
					   [Other Concurrent Drugs Question],
					   [Other Concurrent Drugs New Value],
					   [Supporting Documents Approval Last Modified Date],
					   [Supporting Documents Approval Question],
					   [Supporting Documents Approval New Value],
					   [Data Entry Completion Last Modified Date],
					   [Data Entry Completion Question],
					   [Data Entry Completion New Value])

) PV


TRUNCATE TABLE [Reporting].[AD550].[t_pv_TAEQCListing_TEST];

INSERT INTO [AD550].[t_pv_TAEQCListing_TEST]
(
	[SiteID],
	[SubjectID],
	[PatientID],
	[statusCode],
	[ProviderID],
	[firstReportedVia],
	[DateReported],
	[EventType],
	[eventId],
	[eventOccurrence],
	[eventCrfId],
	[EventName],
	[EventOnsetDate],
	[MDConfirmed],
	[ConfirmationStatus],
	[hasData],
	[Outcome],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[Event Info Last Modified Date],
	[Event Info Question],
	[Event Info New Value],
	[Event Details Last Modified Date],
	[Event Details Question],
	[Event Details New Value],
	[AD Drug Exposure Last Modified Date],
	[AD Drug Exposure Question],
	[AD Drug Exposure New Value],
	[Other Concurrent Drugs Last Modified Date],
	[Other Concurrent Drugs Question],
	[Other Concurrent Drugs New Value],
	[Data Entry Completion Last Modified Date],
	[Data Entry Completion Question],
	[Data Entry Completion New Value],
	[Supporting Documents Approval Last Modified Date],
	[Supporting Documents Approval Question],
	[Supporting Documents Approval New Value]
) 


SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[statusCode],
	[ProviderID],
	[firstReportedVia],
	[DateReported],
	[EventType],
	[eventId],
	[eventOccurrence],
	[eventCrfId],
	[EventName],
	[EventOnsetDate],
	[MDConfirmed],
	[ConfirmationStatus],
	[hasData],
	[Outcome],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[Event Info Last Modified Date]L,
	[Event Info Question],
	[Event Info New Value],
	[Event Details Last Modified Date],
	[Event Details Question],
	[Event Details New Value],
	[AD Drug Exposure Last Modified Date],
	[AD Drug Exposure Question],
	[AD Drug Exposure New Value],
	[Other Concurrent Drugs Last Modified Date],
	[Other Concurrent Drugs Question],
	[Other Concurrent Drugs New Value],
	[Data Entry Completion Last Modified Date],
	[Data Entry Completion Question],
	[Data Entry Completion New Value],
	[Supporting Documents Approval Last Modified Date],
	[Supporting Documents Approval Question],
	[Supporting Documents Approval New Value]

FROM #PIVOTEDDATA



--SELECT * FROM [AD550].[t_pv_TAEQCListing_TEST] ORDER BY SiteID, SubjectID, EventType



END

GO
