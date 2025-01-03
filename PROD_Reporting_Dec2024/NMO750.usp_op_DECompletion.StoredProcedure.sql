USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_DECompletion]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 01/23/2020
-- Description:	Procedure to create table for page 1 of Patient Visit Tracker Report
-- ===================================================================================================

CREATE PROCEDURE [NMO750].[usp_op_DECompletion] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_op_DECompletion]
(
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar] (40) NULL,
	[SubjectID] [nvarchar] (12) NULL,
	[PatientID] [bigint] NULL,
	[VisitType] [nvarchar] (30) NULL,
	[EventType] [nvarchar] (300) NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[eventCompletion] [nvarchar] (100) NULL,
	[statusCode] [nvarchar] (100) NULL,
	[CompletionStatus] [nvarchar] (100) NULL

);
*/


/*Retrieve incomplete Enrollment, FU and Exit Visits**/

IF OBJECT_ID('tempdb..#decompletion') IS NOT NULL DROP TABLE #decompletion

SELECT SiteID,
       EDCSiteStatus,
	   SFSiteStatus,
	   CAST(SubjectID AS nvarchar) AS SubjectID,
	   patientId,
	   VisitType,
	  '' AS EventType,
	   VisitSequence,
	   eventDefinitionId,
	   eventOccurrence,
	   VisitDate,
	   statusCode,
	   eventCompletion,
	   CompletionStatus
INTO #decompletion
FROM
(
SELECT V.SiteID
      ,V.EDCSiteStatus
	  ,V.SFSiteStatus
      ,V.SubjectID
	  ,V.patientId
	  ,V.VisitType
	  ,V.VisitSequence
	  ,V.eventDefinitionId
	  ,V.eventOccurrence
	  ,V.VisitDate
	  ,DEComp.statusCode
	  ,COALESCE(DEComp.enr_accurate_confirmed, DEComp.fu_accurate_confirmed) AS eventCompletion
	  ,DEComp.statusCode AS CompletionStatus
	  ,VR.pay_visit_paid
	  ,VR.pay_earlyfu_oow
	  ,VR.pay_earlyfu_status
	  ,VR.pay_earlyfu_pay_exception

FROM [Reporting].[NMO750].[t_op_VisitLog] V --WHERE SubjectID IN ('7031-0020','7031-0025', '7031-0030', '7031-0041')
LEFT JOIN [RCC_NMOSD750].[staging].[eventcompletion] DEComp ON DEComp.subjectId=V.patientId and DeComp.eventId=V.eventDefinitionId AND DECOMP.eventOccurrence=V.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[staging].[visitreimbursement] VR ON VR.subNum=V.SubjectID AND VR.eventId=V.eventDefinitionId AND VR.eventOccurrence=V.eventOccurrence 
AND ISNULL(V.VisitDate, '')<>''
AND ISNULL(V.SubjectID, '')<>''
AND ISNULL(V.EligibleVisit, '')<>'No'
AND ISNULL(VR.pay_visit_paid, '')<>1
AND ((ISNULL(VR.pay_earlyfu_oow, '')<>1)
OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')=1)
OR (ISNULL(VR.pay_earlyfu_oow, '')=1 AND ISNULL(VR.pay_earlyfu_status, '')<>1 AND ISNULL(VR.pay_earlyfu_pay_exception, '')=1))
AND V.SubjectID NOT IN (SELECT SubjectID FROM [NMO750].[t_op_VisitLog] WHERE eventDefinitionId=11174 AND EligibleVisit='No')
) A
WHERE (VisitType IN ('Enrollment', 'Follow-up', 'Exit') AND statusCode<>'Completed')


--SELECT * FROM #decompletion WHERE SubjectID IN ('7031-0020','7031-0025', '7031-0030', '7031-0041')
--SELECT * FROM [RCC_NMOSD750].[staging].[eventcompletion] WHERE s NOT LIKE '1440-%'


/*Retrieve incomplete TAE forms that are Confirmed events*/

IF OBJECT_ID('tempdb..#IncompleteTAEs') IS NOT NULL DROP TABLE dbo.#IncompleteTAEs

SELECT SiteID,
       EDCSiteStatus,
	   SubjectID,
	   PatientID,
	   EventType,
	   EventName,
	   eventOccurrence,
	   VisitDate,
	   statusCode,
	   eventCompletion,
	   CompletionStatus,
	   eventCrfId,
	   EventConfirmationStatus,
	   EventPaid,
	   eventId,
	   CompletionEventName,
	   tae_reviewer_confirmation_confirmed
INTO #IncompleteTAEs
FROM
(
SELECT TQCL.SiteID,
       SS.SiteStatus AS EDCSiteStatus,
       CAST(TQCL.SubjectID AS nvarchar) AS SubjectID,
	   TQCL.PatientID,
	   TQCL.EventType,
	   TQCL.[EventName],
	   TQCL.eventOccurrence,
	   COALESCE(TQCL.EventOnsetDate, TQCL.DateReported) AS VisitDate,
	   EC.statusCode,
	   COALESCE(DEComp.relapse_reviewer_confirmation_confirmed, DEComp.tae_reviewer_confirmation_confirmed, [peq_reviewer_conf_confirmed]) AS eventCompletion,
	   EC.statusCode AS CompletionStatus,
	   TQCL.[eventCrfId],
	   TQCL.[EventConfirmationStatus],
	   TQCL.EventPaid,
	   DEComp.eventId,
	   DEComp.eventName AS CompletionEventName,
	   CASE WHEN TQCL.EventType='Relapse' THEN DEComp.relapse_reviewer_confirmation_confirmed
	   WHEN TQCL.EventType<>'Relapse' THEN DEComp.tae_reviewer_confirmation_confirmed
	   ELSE ''
	   END AS tae_reviewer_confirmation_confirmed

FROM [Reporting].[NMO750].[t_pv_TAEQCListing] TQCL
LEFT JOIN [Reporting].[NMO750].[v_SiteStatus] SS ON SS.SiteID=TQCL.SiteID
LEFT JOIN [RCC_NMOSD750].[staging].[eventcompletion] DEComp ON DEComp.subjectId=TQCL.patientId and DeComp.eventId=TQCL.eventId AND DECOMP.eventOccurrence=TQCL.eventOccurrence
LEFT JOIN [Reporting].[NMO750].[v_eventcrfs] EC ON EC.SubjectID=DEComp.subNum AND EC.[id]=DEComp.[eventCrfId]
WHERE ISNULL(TQCL.EventPaid, '')<>'Yes'
AND ISNULL(EventConfirmationStatus, '') NOT IN ('Revoked', 'Previously reported', 'Not an event')
) B
WHERE ISNULL(statusCode, '')<>'Completed'

--SELECT * FROM #IncompleteTAEs WHERE SiteID<>1440 ORDER BY SubjectID, eventId, eventOccurrence


/*Retrieve Sites where there is no incomplete records listed so an 'All records completed' Message can be displayed*/

IF OBJECT_ID('tempdb..#NoRecords') IS NOT NULL DROP TABLE #NoRecords 

SELECT SP.SiteID
      ,SS.SiteStatus AS EDCSiteStatus
	  ,SF.currentStatus AS SFSiteStatus
	  ,NULL AS SubjectID
	  ,NULL AS PatientID
	  ,'' AS VisitType
	  ,'' AS EventType
	  ,CAST(NULL AS int) AS eventOccurrence
	  ,CAST(NULL AS date) AS VisitDate
	  ,'' AS eventCompletion
	  ,'' AS statusCode
      ,'All records completed' AS CompletionStatus
INTO #NoRecords
FROM [NMO750].[v_SiteParameter] SP
LEFT JOIN [NMO750].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.siteNumber=SP.SiteID AND SF.[name]='Neuromyelitis Optica Spectrum Disorder (NMOSD-750)'
WHERE SP.SiteID NOT IN (SELECT DISTINCT(SiteID) FROM #decompletion)
AND SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM #IncompleteTAEs)

--SELECT * FROM #NoRecords ORDER BY SiteID, SubjectID, VisitDate


TRUNCATE TABLE [Reporting].[NMO750].[t_op_DECompletion];

INSERT INTO [Reporting].[NMO750].[t_op_DECompletion]
(
	[SiteID],
	[EDCSiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[PatientID],
	[VisitType],
	[EventType],
	[eventOccurrence],
	[VisitDate],
	[eventCompletion],
	[statusCode],
	[CompletionStatus]
)

SELECT DISTINCT DE.SiteID,
     EDCSiteStatus,
	 SFSiteStatus,
	 CAST(DE.SubjectID AS nvarchar) AS SubjectID,
	 DE.PatientID,
	 DE.VisitType,
	 DE.EventType,
	 DE.eventOccurrence,
	 DE.VisitDate,
	 DE.eventCompletion,
	 DE.statusCode,
	 DE.CompletionStatus
FROM #decompletion DE

UNION

SELECT DISTINCT NR.SiteID,
     EDCSiteStatus,
	 SFSiteStatus,
	 CAST(SubjectID AS nvarchar) AS SubjectID,
	 PatientID,
	 VisitType,
	 EventType,
	 eventOccurrence,
	 VisitDate,
	 eventCompletion,
	 statusCode,
	 CompletionStatus
FROM #NoRecords NR

UNION

SELECT DISTINCT ITAE.SiteID,
     EDCSiteStatus,
	 CASE WHEN ITAE.SiteID=1440 THEN 'TestSite'
	 ELSE SF.currentStatus 
	 END AS [SFSiteStatus],
	 CAST(SubjectID AS nvarchar) AS SubjectID,
	 PatientID,
	 CASE WHEN EventType='Pregnancy Event' THEN EventType
	 WHEN EventType=EventName THEN EventType
	 WHEN ISNULL(EventName, '')='' THEN EventType
	 WHEN ISNULL(EventName, '')<>'' AND EventType<>EventName THEN CONCAT(EventType, '; ', EventName)
	 ELSE EventType
	 END AS VisitType,
	 EventName AS EventType,
	 eventOccurrence,
	 VisitDate,
	 eventCompletion,
	 statusCode,
	 CompletionStatus
FROM #IncompleteTAEs ITAE
LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.siteNumber=ITAE.SiteID AND SF.[name]='Neuromyelitis Optica Spectrum Disorder (NMOSD-750)'
--WHERE ISNULL(SiteID, '') NOT IN ('', 1440)

--SELECT * FROM [Reporting].[NMO750].[t_op_DECompletion] WHERE SubjectID IN ('7031-0020','7031-0025', '7031-0030', '7031-0041')ORDER BY SiteID, SubjectID, VisitType


END

GO
