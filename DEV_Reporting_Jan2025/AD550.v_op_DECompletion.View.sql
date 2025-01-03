USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_DECompletion]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [AD550].[v_op_DECompletion] AS

WITH IncompleteVisits AS
(
SELECT V.SiteID
      ,V.SubjectID
	  ,V.SiteStatus
	  ,V.SFSiteStatus
	  ,V.patientId
	  ,V.VisitType
	  ,V.eventOccurrence
	  ,V.VisitSequence
	  ,V.eventId
	  ,V.VisitDate
	  ,DEComp.statusCode
	  ,'Incomplete' AS CompletionStatus
FROM [Reporting].[AD550].[t_op_VisitLog] V
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] DEComp ON DeComp.subjectId=V.patientId and DeComp.eventId=V.eventId AND DECOMP.eventOccurrence=V.eventOccurrence
WHERE ISNULL(DEComp.statusCode, '')<>'Completed'
 
)

,IncompleteTAEs AS
(
SELECT TQCL.SiteID,
	   SS.SiteStatus,
	   SS.SFSiteStatus,
       TQCL.SubjectID,
	   EC.patientId,
	   TQCL.EventType AS VisitType,
	   TQCL.eventOccurrence,
	   TQCL.EventType,
	   COALESCE(TQCL.EventOnsetDate, TQCL.FUVisitDate) AS VisitDate,
	   EC.statusCode,
	   'Incomplete' AS CompletionStatus,
	   TQCL.[eventCrfId],
	   TQCL.[ConfirmationStatus],
	   TQCL.EventPaid,
	   DEComp.eventId,
	   DEComp.tae_reviewer_confirmation_confirmed
FROM [Reporting].[AD550].[t_pv_TAEQCListing] TQCL
LEFT JOIN [Reporting].[AD550].[v_SiteStatus] SS ON SS.SiteID=TQCL.SiteID
LEFT JOIN [RCC_AD550].[staging].[dataentrycompletion] DEComp ON DEComp.subjectId=TQCL.patientId and DeComp.eventId=TQCL.eventId AND DECOMP.eventOccurrence=TQCL.eventOccurrence
LEFT JOIN [Reporting].[AD550].[v_eventcrfs] EC ON EC.SubjectID=DEComp.subNum AND  EC.[id]=DEComp.[eventCrfId]
WHERE ISNULL(EC.statusCode, '')<>'Completed' AND ISNULL(TQCL.EventPaid, '')<>'Yes' AND ISNULL(ConfirmationStatus, '') IN ('Confirmed event', '')
)

,decompletion AS
(
SELECT IV.SiteID
      ,IV.SiteStatus
	  ,IV.SFSiteStatus
      ,IV.SubjectID
	  ,IV.PatientID
	  ,IV.VisitType
	  ,'' AS EventType
	  ,IV.eventOccurrence
	  ,IV.VisitDate
	  ,IV.statusCode
	  ,IV.CompletionStatus
FROM INCOMPLETEVISITS IV
)

,NORECORDS AS (

SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,NULL AS SubjectID
	  ,NULL AS PatientID
	  ,'' AS VisitType
	  ,NULL AS eventOccurrence
	  ,'' AS EventType
	  ,CAST(NULL AS date) AS VisitDate
	  ,'' AS statusCode
      ,'All records completed' AS CompletionStatus
FROM AD550.v_SiteParameter SP
LEFT JOIN AD550.v_SiteStatus SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT(SiteID) FROM decompletion)
)


SELECT DISTINCT SiteID,
     SiteStatus,
	 SFSiteStatus,
	 SubjectID,
	 PatientID,
	 VisitType,
	 eventOccurrence,
	 EventType,
	 VisitDate,
	 statusCode,
	 CompletionStatus
FROM decompletion

UNION

SELECT DISTINCT SiteID,
     SiteStatus,
	 SFSiteStatus,
	 SubjectID,
	 PatientID,
	 VisitType,
	 eventOccurrence,
	 EventType,
	 VisitDate,
	 statusCode,
	 CompletionStatus
FROM NORECORDS

UNION

SELECT DISTINCT SiteID,
     SiteStatus,
	 SFSiteStatus,
	 SubjectID,
	 PatientID,
	 VisitType,
	 eventOccurrence,
	 EventType,
	 VisitDate,
	 statusCode,
	 CompletionStatus
FROM IncompleteTAEs
--ORDER BY SubjectID
GO
