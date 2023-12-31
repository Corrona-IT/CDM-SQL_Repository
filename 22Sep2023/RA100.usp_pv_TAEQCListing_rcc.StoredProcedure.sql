USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_pv_TAEQCListing_rcc]    Script Date: 9/22/2023 10:25:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =================================================
-- Author:		Kevin Soe
-- Create date: 7/26/2023
-- Description:	Procedure for RA-100 TAE QC Listing in RCC
-- =================================================


CREATE PROCEDURE [RA100].[usp_pv_TAEQCListing_rcc] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA100].[t_pv_TAEQCListing]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar] (35) NULL,
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
	[SupportDocsApproved] [nvarchar] (20) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[DateCreated] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[AD Drug Exposure] [datetime] NULL,
	[Other concurrent Drugs] [datetime] NULL,
	[Data Entry Completion] [datetime] NULL,
	[Supporting Documents Approval] [datetime] NULL

) ON [PRIMARY]
GO
*/



/****Get Subjects and Site information****/

IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END

SELECT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
  --SELECT * FROM
INTO #SubjectSite
FROM [Reporting].[RA100].[v_op_subjects] S 
WHERE ISNULL(S.[SiteID], '') NOT IN ('', 1440) AND 
S.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #SubjectSite ORDER BY SiteID, SubjectID



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
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption]LIKE '%Details' THEN 20
	   WHEN EDI.[crfCaption]='RA Drug Exposure' THEN 30
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 40
	   WHEN EDI.[crfCaption]='Event Completion' THEN 50
	   WHEN EDI.[crfCaption]='Supporting Documents Approval' THEN 60
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
) B WHERE RowNum=1
  
--SELECT * FROM #TAEAudit ORDER BY PatientID, EventDefinitionID, eventOccurence


/****Get Created Date for Scheduled but not started Events****/

IF OBJECT_ID('tempdb.dbo.#TAEAudit2') IS NOT NULL BEGIN DROP TABLE #TAEAudit2 END

SELECT subjectId AS PatientID,
       dateStart,
	   CAST(test1 AS datetime) AS calcDateStart,
	   eventDefinitionId, 
	   [name] AS eventName,
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
      ,SE.[subjectId]
      ,SE.[id]
      ,SE.[eventDefinitionId]
	  ,ED.[name]
      ,SE.[statusId]
      ,SE.[statusCode]
      ,SE.[eventOccurence]
  FROM [RCC_RA100].[api].[studyevents] SE --SELECT * FROM [RCC_RA100].[api].[eventdefinitions]
  LEFT JOIN [RCC_RA100].[api].[eventdefinitions] ED ON ED.[id]=SE.eventDefinitionId
  WHERE eventDefinitionId IN (9287, 9289, 9290, 9291, 9292, 9293, 9294, 9295, 9296, 9297, 9298, 9299, 9300)
  AND statuscode='Scheduled'
  ) B

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
	   ELSE EDI.[crfCaption]
	   END AS crfCaption
	  ,CASE WHEN EDI.[crfCaption] LIKE '% Info' THEN 10
	   WHEN EDI.[crfCaption]='RA Drug Exposure' THEN 20
	   WHEN EDI.[crfCaption]='Other Concurrent Drugs' THEN 30
	   WHEN EDI.[crfCaption] LIKE '%Details' THEN 40
	   WHEN EDI.[crfCaption]='Event Completion' THEN 50
	   WHEN EDI.[crfCaption]='Supporting Documents Approval' THEN 60
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
  LEFT JOIN [RCC_RA100].[api].[auditlogs] AL ON AL.studyEventId=EC.studyEventId AND AL.eventCrfId =EC.id
  WHERE eventDefinitionId IN (9287, 9289, 9290, 9291, 9292, 9293, 9294, 9295, 9296, 9297, 9298, 9299, 9300)
  AND crfCaption NOT IN ('Targeted Event Reimbursement')
  AND ISNULL(AL.[deleted], '')=''
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  GROUP BY S.SiteID, S.SubjectID, S.[patientId], EC.eventDefinitionId, EDI.crfCaption, EDI.crfId, EC.eventOccurence , EC.crfOccurence
) A 
) B --WHERE RowNum=1

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



/****Get outcomes for all TAEs except pregnancy****/

IF OBJECT_ID('tempdb.dbo.#TAEOutcomes') IS NOT NULL BEGIN DROP TABLE #TAEOutcomes END

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
	  ,EI.taedat_4_1180 AS ReportedDate
	  ,EI.taeser_4_1000 AS SeriousOutcome
	  ,EI.taeout_4_1000 AS Outcome
	  ,EI.taedoc_4_1000 AS SupportingDocuments
	  ,CASE WHEN ISNULL(EI.taedoc_4_1002, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,CASE WHEN SDA.taepay_4_1000=1 THEN 'Yes'
	   WHEN SDA.taepay_4_1000=0 THEN 'No'
	   WHEN ISNULL(SDA.taepay_4_1000, '')='' THEN 'No'
	   ELSE CAST(SDA.taepay_4_1000 AS varchar)
	   END AS SupportDocsApproved
	  ,REIMB.taepay_4_1001 AS EventPaid
	  ,REIMB.taepay_4_1100 AS SourceDocsPaid

INTO #TAEOutcomes
--SELECT taerpt_4_1100 
FROM [RCC_RA100].[staging].[eventinfo] EI
LEFT JOIN [RCC_RA100].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=EI.subjectId
   AND REIMB.eventName=EI.eventName AND REIMB.eventOccurrence=EI.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[caseprocessing] SDA ON SDA.subjectId=EI.subjectId AND SDA.eventName=EI.eventName AND SDA.[eventOccurrence]=EI.eventOccurrence

--SELECT * FROM #TAEOutcomes 


/****Get Pregnancy TAE information including outcomes****/

IF OBJECT_ID('tempdb.dbo.#PREG') IS NOT NULL BEGIN DROP TABLE #PREG END

SELECT SS.SiteID
      ,TAEP.subNum AS SubjectID
      ,TAEP.subjectId AS PatientID
	  ,TAEP.statusCode
	  ,TAEP.PEQPID_5_1000 AS ProviderID
	  ,CASE WHEN TAEP.PEQRPT_5_1100=1 THEN 'With a Subject Enrollment or Follow-up form'
	   WHEN TAEP.PEQRPT_5_1100=2 THEN 'Between registry visits'
	   WHEN TAEP.PEQRPT_5_1100=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,TAEP.PEQMAT_5_1080_c AS DateReported
	  ,TAEP.eventName AS EventType
	  ,TAEP.eventId
	  ,TAEP.eventOccurrence
	  ,TAEP.crfName
	  ,TAEP.eventCrfId
	  ,'Pregnancy' AS EventName
	  ,CAST(NULL AS date) AS OnsetDate
	  ,NULL AS MDConfirmed
	  ,CASE WHEN TAEP.PEQRPT_5_1000=1 THEN 'Confirmed event'
	   WHEN TAEP.PEQRPT_5_1000=2 THEN 'Previously reported (duplicate)'
	   WHEN TAEP.PEQRPT_5_1000=3 THEN 'Not an event'
	   ELSE CAST(NULL AS nvarchar)
	   END AS ConfirmationStatus
	  ,CASE WHEN TAEP.hasData=1 THEN 'Yes'
	   WHEN TAEP.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
	  ,'' AS Outcome
	  ,TAEP.PEQDOC_5_1000 AS SupportingDocuments
	  ,CASE WHEN ISNULL(TAEP.PEQDOC_5_1002, '')='' THEN 'No'
	   ELSE 'Yes'
	   END AS SupportingDocumentsUploaded
	  ,'n/a' AS SupportDocsApproved
	  ,REIMB.taepay_4_1001 AS EventPaid
	  ,REIMB.taepay_4_1100 AS SourceDocsPaid
	  ,TA.eventDefinitionId
	  ,TA.eventOccurence

INTO #PREG
FROM [RCC_RA100].[staging].[pregnancyinfo] TAEP
LEFT JOIN #SubjectSite SS ON SS.PatientID=TAEP.subjectId
LEFT JOIN [RCC_RA100].[staging].[targetedeventreimbursement] REIMB ON REIMB.subjectId=TAEP.subjectId 
     AND REIMB.eventName=TAEP.eventName AND REIMB.eventOccurrence=TAEP.eventOccurrence
LEFT JOIN #TAEAudit TA ON TAEP.subjectId=TA.PatientID AND TA.eventDefinitionId=TAEP.eventId and TA.eventOccurence=TAEP.eventOccurrence
LEFT JOIN [RCC_RA100].[staging].[caseprocessing] SDA ON SDA.subjectId=TAEP.subjectId AND SDA.eventName=TAEP.eventName AND SDA.[eventOccurrence]=TAEP.eventOccurrence
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
	   C.MDConfirmed,-- (MAY NEED TO ADD BACK IN)
	   C.ConfirmationStatus,
	   C.hasData
	  ,TAEOUT.Outcome
	  ,TAEOUT.SupportingDocuments
	  ,TAEOUT.SupportingDocumentsUploaded
	  ,TAEOUT.SupportDocsApproved
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
	  ,EI.TAEPID_4_1000 AS ProviderID
	  ,CASE WHEN EI.taerpt_4_1100=1 THEN 'With a Follow-up Visit'
	   WHEN EI.taerpt_4_1100=2 THEN 'Between registry visits'
	   WHEN EI.taerpt_4_1100=3 THEN 'With a Subject Exit form'
	   ELSE ''
	   END AS firstReportedVia
	  ,EI.taedat_4_1180 AS DateReported
	  ,SUBSTRING(EI.[eventName], 1, LEN(EI.[eventName])-4) AS EventType
	  ,EI.eventId
	  ,EI.eventOccurrence
	  ,EI.crfName
	  ,EI.eventCrfId
	  ,COALESCE(TAEANA_4_1100_dec, TAECAN_4_1100_dec, TAECVD_4_1100_dec, TAEC19_4_1100_dec, TAEGEN_4_1100_dec, TAEGIP_4_1100_dec, TAEHEP_4_1100_dec, TAEZOS_4_1100_dec, TAEINF_4_1100_dec, TAENEU_4_1100_dec, TAESSB_4_1100_dec, TAEVTE_4_1100_dec) AS EventName
	  ,EI.TAEOTH_4_1190 AS SpecifyEvent
	  ,EI.TAEDAT_4_1180 AS EventOnsetDate
	  ,CASE WHEN EI.taerpt_4_1200_1 IS NOT NULL THEN 'I was involved in the care of the patient at the time of the event' 
	   ELSE CAST(NULL as varchar)
	   END AS MDConfirmed
	  ,CASE WHEN CS.TAERPT_4_1000=1 THEN 'Confirmed event'
	   WHEN CS.TAERPT_4_1000=2 THEN 'Previously reported (duplicate)'
	   WHEN CS.TAERPT_4_1000=3 THEN 'Not an event'
	   ELSE CAST(NULL as varchar)
	   END AS ConfirmationStatus
	  ,CASE WHEN EI.hasData=1 THEN 'Yes'
	   WHEN EI.hasData=0 THEN 'No'
	   ELSE ''
	   END AS hasData
--SELECT *
FROM [RCC_RA100].[staging].[eventinfo] EI
LEFT JOIN [RCC_RA100].[staging].[confirmationstatus] CS ON CS.subjectId=EI.subjectId AND CS.eventName=EI.eventName AND CS.[eventOccurrence]=EI.eventOccurrence  

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
	[SupportDocsApproved],
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
	X.[LastModifiedDate]
FROM #LMDTGroup X
LEFT JOIN #TAE Z ON Z.PatientID=X.PatientID AND Z.eventId=X.eventDefinitionId AND Z.eventOccurrence=X.eventOccurence
WHERE X.eventDefinitionId<>8044
AND ISNULL(Z.SiteID, '')<>'' AND ISNULL(Z.SubjectID, '')<>''

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
	[SupportDocsApproved],
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
	L.[LastModifiedDate]

FROM #LMDTGroup L
LEFT JOIN #PREG M ON M.PatientID=L.PatientID AND M.eventId=L.eventDefinitionId AND M.eventOccurrence=L.eventOccurence
WHERE L.eventDefinitionId=8044
) K


--SELECT * FROM #EVENTS

TRUNCATE TABLE [Reporting].[AD550].[t_pv_TAEQCListing];

INSERT INTO [AD550].[t_pv_TAEQCListing]
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
	[SupportDocsApproved],
	[EventPaid],
	[SourceDocsPaid],
	[DateCreated],
	[Event Info],
	[Event Details],
	[AD Drug Exposure],
	[Other concurrent Drugs],
	[Data Entry Completion],
	[Supporting Documents Approval]
)

SELECT *
FROM
(
SELECT  E.SiteID,
		E.SubjectID, 
		E.[PatientID],
		E.[statusCode],
		E.[ProviderID],
		E.[firstReportedVia],
		E.[DateReported],
		E.[EventType],
		E.[eventId],
		E.[eventOccurrence],
		E.[eventCrfId],
		E.[EventName],
		E.[EventOnsetDate],
		E.[MDConfirmed],
		E.ConfirmationStatus,
		E.[hasData],
		E.[Outcome],
		E.[SupportingDocuments],
		E.[SupportingDocumentsUploaded],
		E.[SupportDocsApproved],
		E.[EventPaid],
		E.[SourceDocsPaid],
		COALESCE([DateCreated], calcDateStart) AS DateCreated,
		E.[LastModifiedDate],
		E.[crfCaption]  

FROM #EVENTS E
LEFT JOIN #TAEAudit2 TA2 ON TA2.PatientID=E.PatientID AND TA2.eventDefinitionId=E.eventDefinitionId AND TA2.eventOccurrence=E.eventOccurrence  
) AS SourceTable PIVOT(MAX(LastModifiedDate) FOR crfCaption IN ([Event Info], [Event Details], [AD Drug Exposure], [Other Concurrent Drugs], [Data Entry Completion], [Supporting Documents Approval])) AS PivotTable


--SELECT * FROM [AD550].[t_pv_TAEQCListing] ORDER BY SiteID, SubjectID, EventType



END

GO
