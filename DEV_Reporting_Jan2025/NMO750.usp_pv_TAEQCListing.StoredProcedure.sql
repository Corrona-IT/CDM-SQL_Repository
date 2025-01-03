USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_pv_TAEQCListing]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 10/28/2022
-- Description:	Procedure for TAE QC Listing
-- =================================================


CREATE PROCEDURE [NMO750].[usp_pv_TAEQCListing] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_pv_TAEQCListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[gender] [nvarchar](15) NULL,
	[yearOfBirth] [int] NULL,
	[race] [nvarchar](250) NULL,
	[ethnicity] [nvarchar](100) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](40) NULL,
	[DateReported] [date] NULL,
	[EventType] [nvarchar](100) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](250) NULL,
	[eventCrfId] [bigint] NULL,
	[EventName] [nvarchar](250) NULL,
	[EventSpecify] [nvarchar](300) NULL,
	[EventOnsetDate] [date] NULL,
	[EventConfirmationStatus] [nvarchar](100) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](200) NULL,
	[Serious] [nvarchar] (30) NULL,
	[SeriousCriteria] [nvarchar](500) NULL,
	[SupportingDocuments] [nvarchar](100) NULL,
	[SupportingDocumentsUploaded] [nvarchar](500) NULL,
	[ReasonSourceDocsNotSubmitted] [nvarchar](750) NULL,
	[SupportDocsApproved] [nvarchar](50) NULL,
	[EventPaid] [nvarchar](50) NULL,
	[SourceDocsPaid] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[Confirmation Status] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[NMOSD Drug Exposure] [datetime] NULL,
	[EDSS-NMOSD Module] [datetime] NULL,
	[Infections] [datetime] NULL,
	[Comorbidities/AEs] [datetime] NULL,
	[Other Concurrent Drugs] [datetime] NULL,
	[Event Completion] [datetime] NULL,
	[Case Processing] [datetime] NULL
) ON [PRIMARY]
GO
*/



/****Get Subjects and Site information****/

IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END

SELECT DISTINCT S.[SiteID]
      ,S.[SiteStatus]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status] AS SubjectStatus
	  ,S.gender
	  ,S.yearOfBirth
	  ,S.race
	  ,S.ethnicity

INTO #SubjectSite
FROM [Reporting].[NMO750].[v_op_subjects] S 
WHERE ISNULL(S.[SiteID], '') <> '' 
--AND S.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #SubjectSite WHERE SubjectID='1440-0077'



/****Get Created Date for Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit') IS NOT NULL BEGIN DROP TABLE #TAEAudit END

SELECT Rownum,
       SiteID,
       SubjectID,
	   PatientID,
	   eventDefinitionId,
	   eventName,
	   eventOccurence,
	   crfCaption,
	   crfOrder,
	   crfId,
	   crfOccurence,
	   DateCreated

INTO #TAEAudit
FROM
(
SELECT  ROW_NUMBER () OVER (PARTITION BY SubjectID, eventDefinitionId, eventOccurence ORDER BY SubjectID, eventDefinitionId, eventOccurence, DateCreated, crfOrder, crfOccurence) AS RowNum,
        SiteID,
		SubjectID,
		PatientID,
		eventDefinitionId,
		eventName,
		eventOccurence,
		crfCaption,
		crfOrder,
		crfId,
		crfOccurence,
		DateCreated

FROM
(
SELECT S.SiteID
      ,S.SiteStatus
      ,S.SubjectID
	  ,S.[patientId] AS PatientID
      ,EC.[eventDefinitionId]
	  ,ED.[name] AS eventName
	  ,CASE WHEN EDI.[crfCaption] LIKE 'Timeline%' THEN 'Event Info'
	   WHEN EDI.[crfCaption] LIKE 'Pregnancy Info%' THEN 'Event Info'
	   WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption

	  ,CASE WHEN EDI.[crfCaption] LIKE '%Confirmation Status%' THEN 20
	   WHEN EDI.[crfCaption] LIKE '% Info' THEN 30
	   WHEN EDI.[crfCaption]LIKE '%Details' THEN 40
	   WHEN EDI.[crfCaption]='NMOSD Drug Exposure' THEN 50
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 60
	   WHEN EDI.[crfCaption]='Data Entry Completion' THEN 70
	   WHEN EDI.[crfCaption]='Confirmation Status' THEN 10
	   WHEN EDI.[crfCaption]='Timeline' THEN 80
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject
	  ,MIN(AL.[auditDate]) AS DateCreated

FROM [RCC_NMOSD750].[api].[auditlogs] AL
LEFT JOIN [RCC_NMOSD750].[api].[eventcrfs] EC ON AL.studyEventId=EC.studyEventId
JOIN [RCC_NMOSD750].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
LEFT JOIN [RCC_NMOSD750].[api].[eventdefinitions] ED ON ED.[id]=EDI.eventDefinitionsId
LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.patientId=EC.subjectId
WHERE AL.studyEventId IN (SELECT [id] FROM [RCC_NMOSD750].[api].[studyevents] WHERE eventDefinitionId IN (11176, 11177, 11178, 11180, 11181, 11182, 11183, 11184, 11185, 11186, 11187, 11188, 11189, 11252))
AND EDI.crfCaption NOT IN ('Targeted Event Reimbursement')
AND ISNULL(AL.[deleted], '')=''
AND S.[status] NOT IN ('Removed', 'Incomplete')
GROUP BY S.SiteID, S.SiteStatus, S.SubjectID, S.[patientId], EC.eventDefinitionId, ED.[name], EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence

) A
) B 
WHERE RowNum=1
  

--SELECT * FROM #TAEAudit WHERE SubjectID='1440-0077' ORDER BY eventName, eventOccurence
 



/****Get Created Date for Scheduled but not started Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit2') IS NOT NULL BEGIN DROP TABLE #TAEAudit2 END

SELECT SiteID,
       SubjectID,
       PatientID,
	   gender,
	   yearOfBirth,
	   race,
	   ethnicity,
       dateStart,
	   CAST(test1 AS datetime) AS calcDateStart,
	   eventDefinitionId, 
	   [name] AS eventType,
	   CASE WHEN [name] LIKE '%TAE' THEN REPLACE([name], ' TAE', '') 
	   WHEN [name]='Relapse Evaluation' THEN 'Relapse'
	   ELSE [name]
	   END AS EventName,
	   eventOccurence AS eventOccurrence,
	   statusCode

INTO #TAEAudit2

FROM
(
SELECT SE.[dateStart]
	  ,CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1'), 105) + ' ' + 
        CONVERT(VARCHAR(9), CAST(DATEADD(SECOND, CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1') AS TIME), 120) AS calcDateStart
	  ,CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1'), 120) AS test1
	  ,CONVERT(VARCHAR(9), CAST(DATEADD(SECOND, CAST(SE.dateStart AS bigint)/1000 ,'1970/1/1') AS TIME), 25) AS test2
      ,SE.[startTimeFlag]
	  ,SS.SiteID
	  ,SS.SubjectID
      ,SE.[subjectId] AS PatientID
	  ,SS.gender
	  ,SS.yearOfBirth
	  ,SS.race
	  ,SS.ethnicity
      ,SE.[id]
      ,SE.[eventDefinitionId]
	  ,ED.[name]
      ,SE.[statusId]
      ,SE.[statusCode]
      ,SE.[eventOccurence]
FROM [RCC_NMOSD750].[api].[studyevents] SE
  LEFT JOIN [RCC_NMOSD750].[api].[eventdefinitions] ED ON ED.[id]=SE.eventDefinitionId
  LEFT JOIN #SubjectSite SS ON SS.patientId=SE.subjectId
WHERE eventDefinitionId IN (11176, 11177, 11178, 11180, 11181, 11182, 11183, 11184, 11185, 11186, 11187, 11188, 11189, 11252)
    AND statuscode='Scheduled'
  ) B

--SELECT * FROM #TAEAudit2 WHERE SubjectID='1440-0077' ORDER BY PatientID, eventOccurrence


/***Get Last Modified Page and Date for Event***/

IF OBJECT_ID('tempdb.dbo.#LMDT') IS NOT NULL BEGIN DROP TABLE #LMDT END

SELECT RowNum,
       SiteID,
	   SubjectID,
	   PatientID,
	   eventDefinitionId,
	   EventType,
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
		EventType,
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
	  ,ED.[name] AS EventType
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Time%' THEN 'Event Info'
	   WHEN EDI.crfCaption LIKE 'Pregnancy Info%' THEN 'Event Info'
	   WHEN EDI.[crfCaption] LIKE '%Details' THEN 'Event Details'
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '%Confirmat%' THEN 5
	   WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption] LIKE '%Time%' THEN 11
	   WHEN EDI.[crfCaption]='%Drug Exposure' THEN 20
	   WHEN EDI.[crfCaption]='EDSS-NMOSD Module' THEN 21
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 30
	   WHEN EDI.[crfCaption] LIKE '%Details' THEN 40
	   WHEN EDI.[crfCaption]='Infections' THEN 44
	   WHEN EDI.[crfCaption]='Comorbidities/AEs' THEN 45
	   WHEN EDI.[crfCaption]='Event Completion' THEN 50
	   WHEN EDI.[crfCaption]='Case Processing' THEN 60
	   ELSE 90
	   END AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times crf occurs in specific event
      ,EC.[eventOccurence]  ---number of times event occurs for subject\
	  ,MAX(AL.[auditDate]) AS LastModifiedDate

  FROM [RCC_NMOSD750].[api].[eventcrfs] EC
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId
  JOIN [RCC_NMOSD750].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_NMOSD750].[api].[eventdefinitions] ED ON ED.[id]=EDI.eventDefinitionsId
  LEFT JOIN [RCC_NMOSD750].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId=EC.id AND AL.reasonForChange NOT IN ('Event Custom Label Changed', 'Form Custom Label Changed', 'CRF Custom Label Changed')

  WHERE EC.eventDefinitionId IN (11176, 11177, 11178, 11180, 11181, 11182, 11183, 11184, 11185, 11186, 11187, 11188, 11189, 11252)
  --AND AL.auditDate IS NOT NULL
  AND EDI.crfCaption NOT IN ('Targeted Event Reimbursement', 'Case Processing')
  AND ISNULL(AL.[deleted], '')=''
  AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')
 -- AND ISNULL(AL.eventCrfId, '')<>''

  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, ED.[name], EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence
) A 

UNION

SELECT ROW_NUMBER() OVER (PARTITION BY subjectId, eventDefinitionId, eventOccurence ORDER BY subjectId, eventDefinitionId, eventOccurence, crfOrder, LastModifiedDate DESC, crfOccurence) AS RowNum,
        SiteID,
		SubjectID,
		PatientID,
		eventDefinitionId,
		EventType,
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
	  ,ED.[name] AS EventType
	  ,EDI.[crfCaption]
	  ,90 AS crfOrder
	  ,EDI.[crfId]
      ,EC.[crfOccurence]  ---number of times a specific crf occurs within a specific visit/event type
      ,EC.[eventOccurence]  ---number of the specific visit/event type for the patient
	  ,MAX(AL.[auditDate]) AS LastModifiedDate

  FROM [RCC_NMOSD750].[api].[eventcrfs] EC
  LEFT JOIN #SubjectSite S ON S.patientId=EC.subjectId
  JOIN [RCC_NMOSD750].[api].[eventdefinitions_crfs] EDI ON EDI.eventDefinitionsId=EC.eventDefinitionId AND EDI.crfId=EC.crfId
  LEFT JOIN [RCC_NMOSD750].[api].[eventdefinitions] ED ON ED.[id]=EDI.eventDefinitionsId
  LEFT JOIN [RCC_NMOSD750].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId =EC.id

  WHERE EC.eventDefinitionId IN (11176, 11177, 11178, 11180, 11181, 11182, 11183, 11184, 11185, 11186, 11187, 11188, 11189, 11252)
  --AND AL.auditDate IS NOT NULL
  AND EDI.crfCaption  IN ('Case Processing')
  AND ISNULL(AL.[deleted], '')=''
  AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')
  AND entityId IN (858200, 887765, 888006)  ---Source Docs and revocation questions

  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, ED.[name], EDI.crfCaption, EDI.crfId, EC.eventOccurence, EC.crfOccurence
) A 
) B 

/*SELECT * FROM #LMDT WHERE SubjectID='1440-0077' ORDER BY SubjectID, eventDefinitionId, crfOrder, eventOccurence, RowNum
SELECT * FROM #TAEAudit2 ORDER BY SubjectID, eventDefinitionId, eventOccurrence */



/***Get Last Modified Page and Date for Event***/

IF OBJECT_ID('tempdb.dbo.#LMDTGroup') IS NOT NULL BEGIN DROP TABLE #LMDTGroup END

SELECT C.crfRowNum,
       C.SiteID,
	   C.SubjectID,
	   C.PatientID,
	   C.eventDefinitionId,
	   ED.[name] AS EventType,
	   C.eventOccurence,
	   C.crfCaption,
	   C.crfOrder,
	   C.crfId,
	   C.crfOccurence,
	   TA.DateCreated,
	   C.LastModifiedDate
INTO #LMDTGroup
FROM
(
SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY LMDT.SubjectID, LMDT.eventDefinitionId, LMDT.eventOccurence, LMDT.crfId ORDER BY LMDT.SubjectID, LMDT.eventDefinitionId, LMDT.eventOccurence, LMDT.crfOrder, LMDT.LastModifiedDate DESC) AS crfRowNum,
LMDT.SiteID, 
LMDT.SubjectID, 
LMDT.PatientID, 
LMDT.eventDefinitionId, 
LMDT.eventOccurence, 
LMDT.crfCaption, 
LMDT.crfOrder, 
LMDT.crfId, 
LMDT.crfOccurence, 
LMDT.LastModifiedDate

FROM #LMDT LMDT

) C 
LEFT JOIN #TAEAudit TA ON TA.SubjectID=C.SubjectID AND TA.eventDefinitionId=C.eventDefinitionId AND TA.eventOccurence=C.eventOccurence
LEFT JOIN [RCC_NMOSD750].[api].[eventdefinitions] ED ON ED.[id]=TA.eventDefinitionId
WHERE C.crfRowNum=1

--SELECT * FROM #LMDTGroup WHERE SubjectID='1440-0077' ORDER BY SiteID, SubjectID, eventDefinitionId, eventOccurence, crfOrder



/****Get outcomes for all TAEs except pregnancy and relapse****/

IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

SELECT DISTINCT CS.subNum AS SubjectID
      ,CS.subjectId AS PatientID
	  ,EI.tae_md_cod AS ProviderID
	  ,EI.eventName AS EventName
	  ,SUBSTRING(CS.[eventName], 1, LEN(CS.[eventName])-4) AS EventType
	  ,CS.eventId
	  ,CS.eventCrfId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,CASE WHEN EI.tae_rpt_status=1 THEN 'With a Visit Form'
	   WHEN EI.tae_rpt_status=2 THEN 'Between registry visits'
	   WHEN EI.tae_rpt_status=3 THEN 'Exit form'
	   WHEN EI.tae_rpt_status=4 THEN 'With a Relapse Evaluation event'
	   ELSE CAST(EI.tae_rpt_status AS nvarchar)
	   END AS firstReportedVia
	  ,EI.tae_dt_rpt AS ReportedDate
	  ,CASE WHEN EI.[tae_outcome_status]=1 THEN 'Death'
	   WHEN EI.[tae_outcome_status]=2 THEN 'Ongoing event'
	   WHEN EI.[tae_outcome_status]=3 THEN 'Fully recovered/resolved'
	   WHEN EI.[tae_outcome_status]=4 THEN 'Recovered/resolved with sequelae'
	   WHEN EI.[tae_outcome_status]=97 THEN 'Unknown'
	   ELSE NULL
	   END AS Outcome
  	  ,CASE WHEN EI.tae_ser_out_any=1 THEN 'Yes'
	   WHEN EI.tae_ser_out_any=0 THEN 'No'
	   ELSE CAST(tae_ser_out_any AS nvarchar)
	   END AS Serious
	  ,ISNULL(REPLACE(tae_ser_out_hosp, '1', 'Hospitalization (new or prolonged)'), '')
		+ISNULL(REPLACE(tae_ser_out_life_threat, '1', ', Immediately life threatening'), '')
		+ISNULL(REPLACE(tae_ser_out_death, '1', ', Death'), '')
		+ISNULL(REPLACE(tae_ser_out_disability, '1', ', Persistent disability or incapacity'), '')
		+ISNULL(REPLACE(tae_ser_out_defect_cong, '1', ', Congenital anomaly/birth defect'), '')
		+ISNULL(REPLACE(tae_ser_out_md_serious, '1', ', Important medical event'), '') 
		AS SeriousCriteria
	  ,CASE WHEN [ser_antibiotics_inpatient_iv]=1 OR [ser_antibiotics_outpatient_iv]=1 THEN 'Yes'
	   WHEN [ser_antibiotics_inpatient_iv]=0 AND [ser_antibiotics_outpatient_iv]=0 THEN 'No'
	   WHEN [ser_antibiotics_inpatient_iv]=0 AND [ser_antibiotics_outpatient_iv] IS NULL THEN 'No'
	   WHEN [ser_antibiotics_inpatient_iv] IS NULL AND [ser_antibiotics_outpatient_iv]=0 THEN 'No'
	   WHEN [ser_antibiotics_inpatient_iv] IS NULL AND [ser_antibiotics_outpatient_iv] IS NULL THEN CAST(NULL AS nvarchar)
	   END AS IVAntiInfective
	  ,EI.tae_support_docs AS SupportingDocuments
	  ,CASE WHEN ISNULL(EI.tae_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN tae_support_docs_reason_not=1 AND ISNULL(tae_support_docs_reason_other, '')='' THEN 'Hospital would not fax or relase documents'
	   WHEN tae_support_docs_reason_not=1 AND ISNULL(tae_support_docs_reason_other, '')<>'' THEN 'Hospital would not fax or relase documents: ' + tae_support_docs_reason_other
	   WHEN tae_support_docs_reason_not=2 THEN 'Patient would not authorize release of records'
	   WHEN tae_support_docs_reason_not=3 AND ISNULL(tae_support_docs_reason_other, '')='' THEN 'Other reason'
	   WHEN tae_support_docs_reason_not=3 AND ISNULL(tae_support_docs_reason_other, '')<>'' THEN 'Other reason: ' + tae_support_docs_reason_other
	   ELSE CAST(tae_support_docs_reason_not AS nvarchar)
	   END AS ReasonSourceDocsNotSubmitted

	  ,CASE WHEN CP.[taepay_support_docs_approved]=1 THEN 'Yes'
	   WHEN CP.[taepay_support_docs_approved]=0 THEN 'No'
	   WHEN ISNULL(CP.[taepay_support_docs_approved], '')='' THEN 'No'
	   ELSE CAST(CP.[taepay_support_docs_approved] AS varchar)
	   END AS SupportDocsApproved 
	  ,REIMB.taepay_event_status AS EventPaid
	  ,REIMB.taepay_support_docs_paid AS SourceDocsPaid

INTO #TAEOutcomes

FROM [RCC_NMOSD750].[staging].[confirmationstatus] CS
LEFT JOIN [RCC_NMOSD750].[staging].[eventinfo] EI ON EI.subNum=CS.subNum AND EI.eventId=CS.eventId AND EI.eventOccurrence=CS.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[infectiondetails] ID ON ID.subNum=CS.subNum AND ID.eventId=CS.eventId AND ID.eventOccurrence=CS.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[caseprocessing] CP ON CP.subjectId=EI.subjectId AND CP.eventId=EI.eventId AND CP.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=EI.subjectId
   AND REIMB.eventName=EI.eventName AND REIMB.eventOccurrence=EI.eventOccurrence
LEFT JOIN #TAEAudit TA ON TA.SubjectID=EI.subNum AND TA.eventDefinitionId=EI.eventId AND TA.eventOccurence=EI.eventOccurrence

--SELECT * FROM #TAEOutcomes WHERE SubjectID='1440-0077' ORDER BY SubjectID, eventId, eventOccurrence


/****Get Pregnancy TAE information including outcomes****/

IF OBJECT_ID('tempdb.dbo.#PREG') IS NOT NULL BEGIN DROP TABLE #PREG END

SELECT DISTINCT SS.SiteID
      ,TAEP.subNum AS SubjectID
      ,TAEP.subjectId AS PatientID
	  ,TAEP.statusCode
	  ,TAEP.peq_md_cod AS ProviderID
	  ,CASE WHEN TAEP.peq_rpt_status=1 THEN 'With a Visit Form'
	   WHEN TAEP.peq_rpt_status=2 THEN 'Between registry visits'
	   WHEN TAEP.peq_rpt_status=3 THEN 'Exit form'
	   WHEN TAEP.peq_rpt_status=4 THEN 'With a Relapse Evaluation event'
	   ELSE NULL
	   END AS firstReportedVia
	  ,TAEP.peq_dt_rpt AS DateReported
	  ,TAEP.eventName AS EventType
	  ,TAEP.eventId
	  ,TAEP.eventOccurrence
	  ,TAEP.crfName
	  ,TAEP.eventCrfId
	  ,TAEP.crfOccurrence
	  ,'Pregnancy' AS EventName
	  ,PD.peq_last_menstrual_dt AS OnsetDate
	  ,CASE WHEN TAEP.peq_report_type=1 THEN 'Confirmed event'
	   WHEN TAEP.peq_report_type=2 THEN 'Previously reported'
	   WHEN TAEP.peq_report_type=3 THEN 'Not an event'
	   ELSE CAST(NULL AS nvarchar)
	   END AS ConfirmationStatus
	  ,CASE WHEN TAEP.hasData=1 THEN 'Yes'
	   WHEN TAEP.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
	  ,ISNULL(REPLACE(PD.[peq_delivery_live_birth], '1', 'Live Birth'), '')
	         +ISNULL(REPLACE(PD.[peq_neonatal_miscarriage], '1', ', Miscarriage'), '')
			 +ISNULL(REPLACE(PD.[peq_neonatal_abortion], '1', ', Elective termination'), '')
			 +ISNULL(REPLACE(PD.[peq_neonatal_defect_cong], '1', ', Congenital anomaly/birth defect'), '')
	   AS Outcome
	  ,CASE WHEN [peq_neonatal_death_timing]=1 THEN 'Fetal death prior to labor'
	   WHEN [peq_neonatal_death_timing]=2 THEN 'Fetal death during labor'
	   WHEN [peq_neonatal_death_timing]=3 THEN 'Neonatal death'
	   WHEN [peq_neonatal_death_timing]=4 THEN 'Infant death'
	   ELSE ''
	   END AS Death
	  ,CASE WHEN peq_ser_out_any=0 THEN 'No'
	   WHEN peq_ser_out_any=1 THEN 'Yes'
	   ELSE CAST(peq_ser_out_any AS nvarchar)
	   END AS Serious
	  ,ISNULL(REPLACE(peq_ser_out_hosp, '1', 'Hospitalization (maternal) during pregnancy'), '')
			+ISNULL(REPLACE(peq_ser_out_life_threat, '1', ', Immediately life threatening'), '')
			+ISNULL(REPLACE(peq_ser_out_death, '1', ', Maternal death'), '')
			+ISNULL(REPLACE(peq_ser_out_disability, '1', ', Persistent/significant maternal disability or incapacity'), '')
			+ISNULL(REPLACE(peq_ser_out_pp_inf, '1', ', Serious post-partum infection {TAE}'), '')
			+ISNULL(REPLACE(peq_ser_out_pn_inf, '1', ', Post-natal serious infection {TAE}'), '')
			+ISNULL(REPLACE(peq_ser_out_md_serious, '1', ', Important medical event'), '') 
	   AS SeriousCriteria
	  ,NULL AS IVAntiInfective
	  ,SS.gender
	  ,SS.yearOfBirth
	  ,SS.race
	  ,SS.ethnicity
	  ,TAEP.peq_support_docs AS SupportingDocuments
	  ,CASE WHEN ISNULL(peq_support_docs_upload, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN TAEP.peq_support_docs_reason_not=1 AND ISNULL(TAEP.peq_support_docs_reason_other, '')='' THEN 'Hospital would not fax or release documents'
	   WHEN TAEP.peq_support_docs_reason_not=1 AND ISNULL(TAEP.peq_support_docs_reason_other, '')<>'' THEN 'Hospital would not fax or release documents: ' + TAEP.peq_support_docs_reason_other
	   WHEN TAEP.peq_support_docs_reason_not=2 THEN 'Patient would not authorize release of records'
	   WHEN TAEP.peq_support_docs_reason_not=3 AND ISNULL(TAEP.peq_support_docs_reason_other, '')='' THEN 'Other reason'
	   WHEN TAEP.peq_support_docs_reason_not=3 AND ISNULL(TAEP.peq_support_docs_reason_other, '')<>'' THEN 'Other reason: ' + TAEP.peq_support_docs_reason_other
	   ELSE CAST(TAEP.peq_support_docs_reason_not AS nvarchar)
	   END AS ReasonSourceDocsNotSubmitted
	  ,CASE WHEN CP.[taepay_support_docs_approved]=1 THEN 'Yes'
	   WHEN CP.[taepay_support_docs_approved]=0 THEN 'No'
	   WHEN ISNULL(CP.[taepay_support_docs_approved], '')='' THEN 'No'
	   ELSE CAST(CP.[taepay_support_docs_approved] AS varchar)
	   END AS SupportDocsApproved
	  --,NULL AS SupportDocsApproved
	  ,REIMB.taepay_event_status AS EventPaid
	  ,REIMB.taepay_support_docs_paid AS SourceDocsPaid
	  ,TA.eventDefinitionId
	  ,TA.eventOccurence

INTO #PREG
FROM [RCC_NMOSD750].[staging].[pregnancyinfo] TAEP
LEFT JOIN [RCC_NMOSD750].[staging].[confirmationstatus] CS ON CS.subNum=TAEP.subNum AND CS.eventId=TAEP.eventId AND CS.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[pregnancydetails] PD ON PD.subNum=TAEP.subNum AND PD.eventId=TAEP.eventId AND PD.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #SubjectSite SS ON SS.SubjectID=TAEP.subNum
LEFT JOIN [RCC_NMOSD750].[staging].[targetedeventreimbursement] REIMB ON REIMB.subNum=TAEP.subNum 
     AND REIMB.eventName=TAEP.eventName AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[caseprocessing] CP ON CP.subjectId=TAEP.subjectId AND CP.eventId=TAEP.eventId AND CP.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subNum=TA.SubjectID AND TA.eventDefinitionId=TAEP.eventId and TA.eventOccurence=TAEP.eventOccurrence
WHERE SS.SubjectStatus NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #PREG WHERE Subjectid='7030-0037' ORDER BY SiteID, SubjectID, eventOccurrence
--SELECT * FROM [RCC_NMOSD750].[staging].[pregnancyinfo]


/****Get RELAPSE information including outcomes****/

IF OBJECT_ID('tempdb.dbo.#Relapse') IS NOT NULL BEGIN DROP TABLE #Relapse END

SELECT DISTINCT SS.SiteID,
       T.subNum AS SubjectID,
       T.subjectId AS PatientID,
	   T.crfName,
	   T.eventCrfId,
	   T.eventId,
	   T.eventOccurrence,
	   T.crfOccurrence,
	   EComp.statusCode,
	   CASE WHEN T.hasData=1 THEN 'Yes'
	   WHEN T.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData,
	   T.relapse_provider_id AS ProviderID,
	   'Relapse' AS EventType,
	   'Relapse' AS EventName,
	   T.relapse_onset_date AS eventOnsetDate,
	   'With a Relapse Evaluation event' AS firstReportedVia,
	   CAST(NULL AS date) AS DateReported,

	   CASE WHEN CP.[relapse_revocation]=1 THEN 'Revoked' 
	   WHEN CP.[relapse_revocation]=0 THEN 'Not revoked'
	   WHEN ISNULL(T.relapse_onset_date, '')<>'' AND ISNULL(CP.[relapse_revocation], '')='' OR CP.[relapse_revocation]=0 THEN 'Not revoked'
	   ELSE CAST(CP.[relapse_revocation] AS nvarchar)
	   END AS ConfirmationStatus,

	   T.relapse_onset_date AS OnsetDate,
	   CASE WHEN RD.relapse_ser_out=1 THEN 'Yes'
	   WHEN RD.relapse_ser_out=0 THEN 'No'
	   ELSE CAST(RD.relapse_ser_out AS nvarchar)
	   END AS Serious,
	  ISNULL(REPLACE(relapse_ser_out_hosp, '1', 'Hospitalization (new or prolonged)'), '')
		+ISNULL(REPLACE(relapse_ser_out_life_threat, '1', ', Immediately life threatening'), '')
		+ISNULL(REPLACE(relapse_ser_out_death, '1', ', Death'), '')
		+ISNULL(REPLACE(relapse_ser_out_disability, '1', ', Persistent disability or incapacity'), '')
		+ISNULL(REPLACE(relapse_ser_out_defect_cong, '1', ', Congenital anomaly/birth defect'), '')
		+ISNULL(REPLACE(relapse_ser_out_md_serious, '1', ', Important medical event'), '') AS SeriousCriteria,
	   NULL AS IVAntiInfective,
	   SS.gender,
	   SS.yearOfBirth,
	   SS.race,
	   SS.ethnicity,
	   CASE WHEN RD.relapse_outcome_status=1 THEN 'Death'
	   WHEN RD.relapse_outcome_status=2 THEN 'Ongoing event'
	   WHEN RD.relapse_outcome_status=3 THEN 'Fully recovered/resolved'
	   WHEN RD.relapse_outcome_status=4 THEN 'Recovered/resolved with sequelae'
	   WHEN RD.relapse_outcome_status=97 THEN 'Unknown'
	   ELSE NULL
	   END AS Outcome,
	   CASE WHEN RD.[relapse_support_docs]=1 THEN 'Are attached'
	   WHEN RD.[relapse_support_docs]=2 THEN 'Will be submitted separately'
	   ELSE CAST(RD.[relapse_support_docs] AS nvarchar)
	   END AS SupportingDocuments,
	   CASE WHEN ISNULL(RD.[relapse_support_docs_upload], '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded,
	   NULL AS ReasonSourceDocsNotSubmitted,
	   CASE WHEN CP.[taepay_support_docs_approved]=1 THEN 'Yes'
	   WHEN CP.[taepay_support_docs_approved]=0 THEN 'No'
	   ELSE CAST(CP.[taepay_support_docs_approved] AS nvarchar)
	   END AS SupportDocsApproved,
   	   TER.taepay_event_status AS EventPaid,
	   TER.taepay_support_docs_paid AS SourceDocsPaid

INTO #Relapse
FROM [RCC_NMOSD750].[staging].[timeline] T
LEFT JOIN #SubjectSite SS ON SS.PatientID=T.subjectId
LEFT JOIN [RCC_NMOSD750].[staging].[relapsedetails] RD ON RD.subNum=T.subNum AND RD.eventOccurrence=T.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[relapsedetails_acutetherapy] RDA ON RDA.subNum=RD.subNum AND RDA.eventOccurrence=RD.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[caseprocessing] CP ON CP.subNum=T.subNum AND CP.eventOccurrence=T.eventOccurrence AND CP.eventId=11176
LEFT JOIN [RCC_NMOSD750].[staging].[eventCompletion] EComp ON EComp.subNum=T.subNum AND EComp.eventOccurrence=T.eventOccurrence AND EComp.eventId=T.eventId
LEFT JOIN [RCC_NMOSD750].[staging].[targetedeventreimbursement] TER ON TER.subNum=T.subNum AND TER.eventId=T.eventId AND TER.eventOccurrence=T.eventOccurrence
WHERE SS.SubjectStatus NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #Relapse R WHERE SubjectID='1440-0077' ORDER BY SubjectID, eventOccurrence
--SELECT * FROM [RCC_NMOSD750].[staging].[relapsedetails]



/****Get TAEs information for all but pregnancy****/

IF OBJECT_ID('tempdb.dbo.#TAE') IS NOT NULL BEGIN DROP TABLE #TAE END

SELECT DISTINCT SS.SiteID
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
	   C.crfOccurrence,
	   C.EventName,
	   C.EventSpecify,
	   C.EventOnsetDate,
	   C.ConfirmationStatus,
	   C.hasData,
	  TAEOUT.Outcome,
	  TAEOUT.Serious,
	  TAEOUT.SeriousCriteria,
	  TAEOUT.IVAntiInfective,
	  SS.gender,
	  SS.yearOfBirth,
	  SS.race,
	  SS.ethnicity,
	  TAEOUT.SupportingDocuments,
	  TAEOUT.SupportingDocumentsUploaded,
	  TAEOUT.ReasonSourceDocsNotSubmitted,
	  TAEOUT.SupportDocsApproved,
	  TAEOUT.EventPaid,
	  TAEOUT.SourceDocsPaid

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
	   B.crfOccurrence,
	   B.EventName,
	   B.EventSpecify,
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
	   A.crfOccurrence,
	   CASE WHEN EventName LIKE '%(specify)%' THEN REPLACE(EventName, ' (specify)', '')
	   WHEN EventName LIKE '%(specify type)%' THEN REPLACE(EventName, ' (specify type)', '')
	   WHEN EventName LIKE '%(specify location)%' THEN REPLACE(EventName, ' (specify location)', '')
	   ELSE EventName
	   END AS EventName,
	   A.EventSpecify,
	   A.EventOnsetDate,
	   A.MDConfirmed,
	   A.ConfirmationStatus,
	   A.hasData

FROM
(
SELECT CS.[subNum] AS SubjectID
      ,CS.[subjectId] AS PatientID
	  ,CS.[statusCode] AS statusCode
	  ,EI.[tae_md_cod] AS ProviderID
	  ,CASE WHEN EI.tae_rpt_status=1 THEN 'With a Visit form'
	   WHEN EI.tae_rpt_status=2 THEN 'Between registry visits'
	   WHEN EI.tae_rpt_status=3 THEN 'With a Subject Exit form'
	   WHEN EI.tae_rpt_status=4 THEN 'With a Relapse Evaluation event'
	   ELSE NULL
	   END AS firstReportedVia
	  ,EI.[tae_dt_rpt] AS DateReported
	  ,REPLACE(CS.[eventName], ' TAE', '') AS EventType
	  ,CS.eventId
	  ,CS.eventOccurrence
	  ,CS.crfName
	  ,CS.eventCrfId
	  ,CS.crfOccurrence

	  ,COALESCE([tae_ana_event_type_dec], [tae_aut_event_type_dec], [tae_cvd_event_type_dec], [tae_c19_event_type_dec], [tae_gi_event_type_dec], [tae_gen_event_type_dec], [tae_hep_event_type_dec], [tae_hze_event_type_dec], [tae_can_event_type_dec], [tae_ser_event_type_dec], [tae_ssb_event_type_dec], [tae_vte_event_type_dec]) AS EventName

	  ,EI.[tae_event_type_specify] AS EventSpecify
	  ,EI.[tae_onset_dt] AS EventOnsetDate
	  ,EI.[tae_confirm_md_confirmed] AS MDConfirmed
	  ,CASE WHEN CS.tae_status=1 THEN 'Confirmed event'
	   WHEN CS.tae_status=2 THEN 'Previously reported'
	   WHEN CS.tae_status=3 THEN 'Not an event'
	   ELSE CAST(CS.tae_status AS varchar)
	   END AS ConfirmationStatus
	  ,CASE WHEN CS.hasData=1 THEN 'Yes'
	   WHEN CS.hasData=0 THEN 'No'
	   WHEN ISNULL(CS.hasData, '')='' then 'No'
	   ELSE ''
	   END AS hasData

FROM [RCC_NMOSD750].[staging].[confirmationstatus] CS
LEFT JOIN [RCC_NMOSD750].[staging].[eventinfo] EI ON EI.subNum=CS.subNum AND EI.eventId=CS.eventId AND EI.eventOccurrence=CS.eventOccurrence
) A
) B
) C
LEFT JOIN #SubjectSite SS ON SS.SubjectID=C.SubjectID
LEFT JOIN #TAEOutcomes TAEOUT ON TAEOUT.SubjectID=C.SubjectID AND TAEOUT.EventId=C.EventId AND TAEOUT.eventOccurrence=C.eventOccurrence
WHERE SS.SubjectStatus NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #TAE WHERE SubjectID='1440-0077' ORDER BY SiteID, SubjectID, EventType, eventOccurrence


IF OBJECT_ID('tempdb.dbo.#Events') IS NOT NULL BEGIN DROP TABLE #Events END

/****Put all data into one record****/

SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[statusCode],
	[ProviderID],
	[EventType],
	[eventOccurrence],
	[EventName],
	[EventSpecify],
	[EventOnsetDate],
	[firstReportedVia],
	[DateReported],
    [eventId],
	CAST([crfName] AS varchar) AS [crfName],
	[eventCrfId],
	[ConfirmationStatus],
	[hasData],
	[Outcome],
	[Serious],
	[SeriousCriteria],
	[IVAntiInfective],
	[gender],
	[yearOfBirth],
	[race],
	[ethnicity],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[ReasonSourceDocsNotSubmitted],
	[SupportDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
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

--TAEs
SELECT Z.[SiteID],
	Z.[SubjectID],
	Z.[PatientID],
	Z.[statusCode],
	Z.[ProviderID],
	REPLACE(Z.[EventType], ' TAE', '') AS EventType,
	Z.[eventOccurrence],
	Z.[EventName],
	Z.[EventSpecify],
	Z.[EventOnsetDate],
	Z.[firstReportedVia],
	Z.[DateReported],
	Z.[eventId],
	Z.[crfName],
	Z.[eventCrfId],
	Z.ConfirmationStatus,
	Z.[hasData],
	Z.Outcome,
	Serious,
	CASE WHEN SUBSTRING(SeriousCriteria, 1, 1)=',' THEN SUBSTRING(SeriousCriteria, 2, LEN(SeriousCriteria)-1) 
	ELSE SeriousCriteria
	END AS SeriousCriteria,
	CAST(IVAntiInfective AS nvarchar) AS IVAntiInfective,
	gender,
	YearOfBirth,
	race,
	ethnicity,
	CASE WHEN SupportingDocuments=1 THEN 'Are attached'
	     WHEN SupportingDocuments=2 THEN 'Will be submitted separately'
		 WHEN SupportingDocuments=3 THEN 'Will not be submitted'
		 ELSE CAST(SupportingDocuments AS nvarchar)
		 END AS SupportingDocuments,
	[SupportingDocumentsUploaded],
	[ReasonSourceDocsNotSubmitted],
	CASE WHEN Z.ConfirmationStatus='Confirmed Event' THEN CAST([SupportDocsApproved] AS nvarchar) 
	WHEN ISNULL(Z.ConfirmationStatus, '')='' THEN CAST(NULL AS nvarchar)
	ELSE 'N/A'
	END AS [SupportDocsApproved],
	CASE WHEN [EventPaid]=1 THEN 'Yes'
	WHEN [EventPaid]=0 THEN 'No'
	ELSE CAST(EventPaid AS nvarchar) 
	END AS [EventPaid],
	CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	WHEN [SourceDocsPaid]=0 THEN 'No'
	ELSE CAST(SourceDocsPaid AS nvarchar)
	END AS [SourceDocsPaid],
	L.[DateCreated],
	L.[eventDefinitionId],
	L.[crfCaption],
	L.[crfOccurence],
	L.[crfId],
	L.[crfOrder],
	L.[LastModifiedDate]
FROM #TAE Z
LEFT JOIN #LMDTGroup L ON Z.SubjectID=L.SubjectID AND Z.eventId=L.eventDefinitionId AND Z.eventOccurrence=L.eventOccurence
WHERE L.eventDefinitionId NOT IN (11189, 11176)
AND ISNULL(eventOccurrence, '')<>''

UNION

--Relapse
SELECT DISTINCT R.SiteID,
       R.SubjectID,
	   R.PatientID,
	   COALESCE(R.statusCode, TA2.statusCode) AS StatusCode,
	   R.ProviderID,
	   SUBSTRING(R.EventType, 1, 7) AS EventType,
	   R.eventOccurrence,
	   R.eventName,
	   CAST(NULL AS nvarchar) AS EventSpecify,
	   R.eventOnsetDate,
	   R.firstReportedVia,
	   R.DateReported,
	   R.eventId,
	   R.crfName,
	   R.eventCrfId,
	   R.ConfirmationStatus,
	   R.hasData,
	   R.Outcome,
	   Serious,
	   CASE WHEN SUBSTRING(SeriousCriteria, 1, 1)=',' THEN SUBSTRING(SeriousCriteria, 2, LEN(SeriousCriteria)-1) 
		ELSE SeriousCriteria
		END AS SeriousCriteria,
	   CAST(IVAntiInfective AS nvarchar) AS AntiInfective,
	   R.gender,
	   R.YearOfBirth,
	   R.race,
	   R.ethnicity,
	   R.SupportingDocuments,
	   R.SupportingDocumentsUploaded,
	   CAST([ReasonSourceDocsNotSubmitted] AS varchar) AS [ReasonSourceDocsNotSubmitted],
	   CAST(SupportDocsApproved AS nvarchar) AS SupportDocsApproved,
	   CASE WHEN [EventPaid]=1 THEN 'Yes'
	   WHEN [EventPaid]=0 THEN 'No'
	   ELSE CAST([EventPaid] AS nvarchar)
	   END AS [EventPaid],
	   CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	   WHEN [SourceDocsPaid]=0 THEN 'No'
	   ELSE CAST(SourceDocsPaid AS nvarchar)
	   END AS [SourceDocsPaid],
	   COALESCE(L.DateCreated, TA2.calcDateStart) as DateCreated,
	   L.eventDefinitionId,
	   L.crfCaption,
	   L.crfOccurence,
	   L.crfId,
	   L.crfOrder,
	   L.LastModifiedDate
FROM #Relapse R
LEFT JOIN #LMDTGroup L ON L.PatientID=R.PatientID AND L.eventDefinitionId=R.eventId AND L.eventOccurence=R.eventOccurrence 
LEFT JOIN #TAEAudit2 TA2 ON TA2.PatientID=R.PatientID AND TA2.eventDefinitionId=R.eventId AND TA2.eventOccurrence=R.eventOccurrence 

UNION

--Pregnancy
SELECT SiteID,
       SubjectID,
	   PatientID, 
	   statusCode,
	   ProviderID,
	   EventType,
	   eventOccurrence,
	   EventName,
	   EventSpecify,
	   EventOnsetDate,
	   firstReportedVia,
	   Datereported,
	   eventId,
	   crfName,
	   eventCrfId,
	   ConfirmationStatus,
	   hasData,
	   CASE WHEN ISNULL(Death, '')='' THEN Outcome
	   WHEN ISNULL(Outcome, '')<>'' AND ISNULL(Death, '')<>'' THEN Outcome + ', ' + Death
	   WHEN ISNULL(Outcome, '')='' THEN Death
	   ELSE ''
	   END AS Outcome,
	   Serious,
	   SeriousCriteria,
	   IVAntiInfective,
	   gender,
	   yearOfBirth,
	   race,
	   ethnicity,
	   SupportingDocuments,
	   SupportingDocumentsUploaded,
	   ReasonSourceDocsNotSubmitted,
	   CASE WHEN ConfirmationStatus='Confirmed Event' THEN CAST([SupportDocsApproved] AS nvarchar) 
	   WHEN ISNULL(ConfirmationStatus, '')='' THEN CAST(NULL AS nvarchar)
	   ELSE 'N/A'
	   END AS [SupportDocsApproved],
	   --SupportDocsApproved,
	   EventPaid,
	   SourceDocsPaid,
	   DateCreated,
	   eventDefinitionId,
	   crfCaption,
	   crfOccurence, 
	   crfId,
	   crfOrder,
	   LastModifiedDate

FROM (
SELECT M.[SiteID],
	M.[SubjectID],
	M.[PatientID],
	M.[statusCode],
	M.[ProviderID],
	M.[EventType],
	M.[eventOccurrence],
	M.[EventName],
	'' AS EventSpecify,
	CAST([OnsetDate] AS date) AS EventOnsetDate,
	M.[firstReportedVia],
	M.[DateReported],
	M.[eventId],
	M.[crfName],
	M.[eventCrfId],
	ConfirmationStatus,
	[hasData],
    CASE WHEN SUBSTRING(Outcome, 1, 1)=',' THEN SUBSTRING(Outcome, 2, LEN(Outcome)-1)
	ELSE Outcome
	END AS Outcome,
	Death,
	Serious,
	CASE WHEN SUBSTRING(SeriousCriteria, 1, 1)=',' THEN SUBSTRING(SeriousCriteria, 2, LEN(SeriousCriteria)-1) 
	ELSE SeriousCriteria
	END AS SeriousCriteria,
	'' AS IVAntiInfective,
	gender,
	yearOfBirth,
	race,
	ethnicity,
	CASE WHEN SupportingDocuments=1 THEN 'Are attached'
	     WHEN SupportingDocuments=2 THEN 'Will be submitted separately'
		 WHEN SupportingDocuments=3 THEN 'Will not be submitted'
		 ELSE CAST(SupportingDocuments AS nvarchar)
		 END AS SupportingDocuments,
	[SupportingDocumentsUploaded],
	[ReasonSourceDocsNotSubmitted],
	CAST([SupportDocsApproved] AS nvarchar) AS [SupportDocsApproved],
	CASE WHEN [EventPaid]=1 THEN 'Yes'
	WHEN [EventPaid]=0 THEN 'No'
	ELSE CAST(EventPaid AS nvarchar)
	END AS [EventPaid],
	CASE WHEN [SourceDocsPaid]=1 THEN 'Yes'
	WHEN [SourceDocsPaid]=0 THEN 'No'
	ELSE CAST(SourceDocsPaid AS nvarchar)
	END AS [SourceDocsPaid],
	L.[DateCreated],
	L.[eventDefinitionId],
	CASE WHEN L.[crfCaption]='Pregnancy Info' THEN 'Event Info'
	ELSE L.[crfCaption]
	END AS crfCaption,
	L.[crfOccurence],
	L.[crfId],
	L.[crfOrder],
	L.[LastModifiedDate]

FROM #PREG M
LEFT JOIN #LMDTGroup L ON M.SubjectID=L.SubjectID AND M.eventId=L.eventDefinitionId AND M.eventOccurrence=L.eventOccurence 
AND M.SubjectID IS NOT NULL
) P

UNION

--Scheduled Events

SELECT DISTINCT TA2.SiteID
      ,TA2.SubjectID
	  ,TA2.PatientID
	  ,TA2.statusCode
	  ,CAST(NULL AS int) AS ProviderID
	  ,CASE WHEN EventType='Relapse Evaluation' THEN 'Relapse'
	   ELSE REPLACE(EventType, ' TAE', '') 
	   END AS EventType
	  ,eventOccurrence
	  ,'' AS eventName
	  ,NULL AS EventSpecify
	  ,CAST(NULL AS date) AS eventOnsetDate
	  ,NULL AS firstReportedVia
	  ,CAST(NULL AS date) AS DateReported
	  ,eventDefinitionId AS eventId
	  ,NULL AS crfName
	  ,CAST(NULL AS bigint) AS eventCrfId
	  ,NULL AS ConfirmationStatus
	  ,'No' AS hasData
	  ,NULL AS Outcome
	  ,CAST(NULL AS nvarchar) AS Serious
	  ,'' AS SeriousCriteria
	  ,NULL AS IVAntiInfective
	  ,gender
	  ,yearOfBirth
	  ,race
	  ,ethnicity
	  ,NULL AS SupportingDocuments
	  ,NULL AS SupportingDocumentsUploaded
	  ,NULL AS ReasonSourceDocsNotSubmitted
	  ,NULL AS SupportDocsApproved
	  ,NULL AS EventPaid
	  ,NULL AS SourceDocsPaid
	  ,calcDateStart AS DateCreated
	  ,eventDefinitionId
	  ,NULL AS crfCaption
	  ,CAST(NULL AS int) AS crfOccurence
	  ,CAST(NULL AS int) AS crfId
	  ,CAST(NULL AS int) AS crfOrder
	  ,CAST(NULL AS date) AS LastModifiedDate

FROM #TAEAudit2 TA2
WHERE (CONCAT(SubjectID, eventDefinitionId, eventOccurrence) NOT IN (SELECT CONCAT(SubjectID, eventId, eventOccurrence) FROM #PREG))
AND (CONCAT(TA2.SubjectID, TA2.eventDefinitionId, TA2.eventOccurrence) NOT IN (SELECT CONCAT(R.SubjectID, R.eventId, R.eventOccurrence) FROM #Relapse R))
AND (CONCAT(TA2.SubjectID, TA2.eventDefinitionId, TA2.eventOccurrence) NOT IN (SELECT CONCAT(T.SubjectID, T.eventId, T.eventOccurrence) FROM #TAE T))
) K

--SELECT * FROM #EVENTS WHERE SubjectID='1440-0077' ORDER BY SiteID, SubjectID, eventId, eventOccurrence
--SELECT * FROM [Reporting].[NMO750].[t_pv_TAEQCListing] WHERE SubjectID='1440-0077' ORDER BY SiteID, SubjectID, eventId, eventOccurrence

TRUNCATE TABLE [Reporting].[NMO750].[t_pv_TAEQCListing];

INSERT INTO [NMO750].[t_pv_TAEQCListing]
(
	[SiteID],
	[SubjectID],
	[PatientID],
	[statusCode],
	[gender],
	[yearOfBirth],
	[race],
	[ethnicity],
	[ProviderID],
	[firstReportedVia],
	[DateReported],
	[EventType],
	[eventId],
	[eventOccurrence],
	[eventCrfId],
	[EventName],
	[EventSpecify],
	[EventOnsetDate],
	[EventConfirmationStatus],
	[hasData],
	[Outcome],
	[Serious],
	[SeriousCriteria],
	[IVAntiInfective],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[ReasonSourceDocsNotSubmitted],
	[SupportDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[Confirmation Status],
	[Event Info],
	[Event Details],
	[NMOSD Drug Exposure],
	[EDSS-NMOSD Module],
	[Infections],
	[Comorbidities/AEs],
	[Other Concurrent Drugs],
	[Event Completion],
	[Case Processing]
)


SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
	[statusCode],
	[gender],
	[yearOfBirth],
	[race],
	[ethnicity],
	[ProviderID],
	[firstReportedVia],
	[DateReported],
	[EventType],
	[eventId],
	[eventOccurrence],
	[eventCrfId],
	[EventName],
	[EventSpecify],
	[EventOnsetDate],
	[EventConfirmationStatus],
	[hasData],
	[Outcome],
	[Serious],
	[SeriousCriteria],
	[IVAntiInfective],
	[SupportingDocuments],
	[SupportingDocumentsUploaded],
	[ReasonSourceDocsNotSubmitted],
	[SupportDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[Confirmation Status],
	[Event Info],
	[Event Details],
	[NMOSD Drug Exposure],
	[EDSS-NMOSD Module],
	[Infections],
	[Comorbidities/AEs],
	[Other Concurrent Drugs],
	[Event Completion],
	[Case Processing]
FROM
(
SELECT  E.SiteID,
		E.SubjectID, 
		E.[PatientID],
		CASE WHEN E.[statusCode] IN ('Data Entry Started', 'Not Started') THEN 'Incomplete'
		WHEN E.[statusCode]='Completed' THEN 'Complete'
		WHEN E.[statusCode]='Scheduled' THEN 'Scheduled'
		ELSE E.[statusCode]
		END AS [statusCode],
		SS.[gender],
		SS.[yearOfBirth],
		SS.[race],
		SS.[ethnicity],
		E.[ProviderID],
		E.[firstReportedVia],
		E.[DateReported],
		E.EventType,
		E.[eventId],
        E.eventOccurrence,
		E.[eventCrfId],
		E.[EventName],
		E.[EventSpecify],
		E.[crfCaption],
		E.[EventOnsetDate],
		E.[ConfirmationStatus] AS [EventConfirmationStatus],
		E.[hasData],
		E.[Outcome],
		E.[Serious],
		E.[SeriousCriteria],
		E.[IVAntiInfective],
		E.[SupportingDocuments],
		E.[SupportingDocumentsUploaded],
		E.[ReasonSourceDocsNotSubmitted],
		E.[SupportDocsApproved],
		E.[EventPaid],
		E.[SourceDocsPaid],
        E.DateCreated,
		E.[LastModifiedDate]
 
FROM #EVENTS E
LEFT JOIN #SubjectSite SS ON SS.SubjectID=E.SubjectID
WHERE ISNULL(E.SiteID, '')<>'' AND ISNULL(E.EventType, '')<>''             
) AS SourceTable PIVOT(MAX(LastModifiedDate) FOR crfCaption IN ([Confirmation Status], [Event Info], [Event Details], [NMOSD Drug Exposure], [EDSS-NMOSD Module], [Infections], [Comorbidities/AEs], [Other Concurrent Drugs], [Event Completion], [Case Processing])) AS PivotTable


END

GO
