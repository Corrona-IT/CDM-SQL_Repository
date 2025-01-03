USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_DECompletion_wTAEs]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [MS700].[v_op_DECompletion_wTAEs] AS


WITH INCOMPLETEVISITS AS
(

SELECT VL.SiteID
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
	  ,VL.SubjectID
	  ,VL.patientId
	  ,VL.VisitType AS VisitEventType
	  ,VL.eventId
	  ,VL.eventOccurrence
	  ,VL.VisitDate AS VisitOnsetDate
	  ,VC.vc_3_1000 AS [Status]
	  ,EC.statusCode AS CRFStatus
	  ,'Incomplete' AS CompletionStatus
	  ,VR.[pay_3_1200] AS EventPaid

FROM [MS700].[v_op_VisitLog] VL 
LEFT JOIN [RCC_MS700].[staging].[visitcompletion] VC ON VC.subjectId=VL.patientId and VC.eventId=VL.eventId AND VC.eventOccurrence=VL.EventOccurrence
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC on EC.id=VC.eventCRFId
LEFT JOIN [RCC_MS700].[staging].[visitreimbursement] VR ON VR.subjectId=VL.patientId AND VR.eventId=VL.eventId AND VR.eventOccurrence=VL.eventOccurrence
WHERE VL.EligibleVisit='Yes'
AND VL.eventId IN (3042, 3043)
AND (ISNULL(EC.statusCode, '') NOT IN ('Completed', 'Locked')
AND ISNULL(VR.[pay_3_1200], '')<>1)
AND VL.SubjectID NOT IN (SELECT SubjectID FROM [MS700].[v_op_VisitLog] VL WHERE eventId=3042 AND EligibleVisit='No')

UNION

SELECT VL.SiteID
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
	  ,VL.SubjectID
	  ,VL.patientId
	  ,VL.VisitType AS VisitEventType
	  ,VL.eventId
	  ,VL.eventOccurrence
	  ,VL.VisitDate AS VisitOnsetDate
	  ,XC.extvc_7_1000 AS [Status]
	  ,EC.statusCode AS CRFStatus
	  ,'Incomplete' AS CompletionStatus
	  ,ER.extpay_7_1000 AS EventPaid
FROM [MS700].[v_op_VisitLog] VL 
LEFT JOIN [RCC_MS700].[staging].[exitcompletion] XC ON XC.subjectId=VL.patientId and XC.eventId=VL.eventId
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC on EC.id=XC.eventCRFId
LEFT JOIN [RCC_MS700].[staging].[exitreimbursement] ER ON ER.subjectId=VL.patientId AND ER.eventId=VL.eventId
WHERE VL.eventId=3053
AND (ISNULL(EC.statusCode, '') NOT IN ('Completed', 'Locked')
AND ISNULL(ER.extpay_7_1000, '')<>1)
AND VL.SubjectID NOT IN (SELECT SubjectID FROM [MS700].[v_op_VisitLog] VL WHERE eventId=3042 AND EligibleVisit='No')

UNION

SELECT S.SiteID
      ,S.SiteStatus
	  ,SS.SFSiteStatus
      ,ES.subnum AS SubjectID
	  ,ES.subjectId AS PatientID
	  ,'Exit' AS VisitEventType
	  ,ES.eventId
	  ,ES.eventOccurrence
	  ,ES.exit_date AS VisitOnsetDate
	  ,XC.extvc_7_1000 AS [Status]
	  ,EC.statusCode AS CRFStatus
	  ,'Incomplete' AS CompletionStatus
	  ,ER.extpay_7_1000 AS EventPaid

FROM [RCC_MS700].[staging].[exitstatus] ES
LEFT JOIN [MS700].[v_op_subjects] S ON S.patientId=ES.subjectId
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=S.SiteID
LEFT JOIN [RCC_MS700].[staging].[exitcompletion] XC ON XC.subjectId=ES.subjectId and XC.eventId=ES.eventId
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC on EC.id=XC.eventCRFId
LEFT JOIN [RCC_MS700].[staging].[exitreimbursement] ER ON ER.subjectId=ES.subjectId AND ER.eventId=ES.eventId
WHERE ES.eventId=3053
AND ISNULL(EC.statusCode, '') NOT IN ('Completed', 'Locked')
AND ISNULL(ER.extpay_7_1000, '')<>1
AND ISNULL(exit_date, '')=''
AND ES.subNum NOT IN (SELECT SubjectID FROM [MS700].[v_op_VisitLog] VL WHERE eventId=3042 AND EligibleVisit='No')


UNION

SELECT DISTINCT TL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,CAST(TL.SubjectID AS bigint) AS SubjectID
	  ,CAST(TL.PatientID AS bigint) AS PatientID
	  ,CASE WHEN ISNULL(TL.[Event], '')<>'' THEN TL.[EventType] + ': ' + TL.[Event] 
	   ELSE TL.[EventType]
	   END AS VisitEventType
	  ,TL.EventId
	  ,TL.[EventOccurrence]
	  ,TL.[OnsetDate] AS VisitOnsetDate
	  ,TL.[tae_reviewer_confirmation] AS [Status]
	  ,TL.eventStatus AS CRFStatus
	  ,'Incomplete' AS CompletionStatus
	  ,TL.EventPaid AS EventPaid

FROM [MS700].[t_op_TAEListing] TL
LEFT JOIN [MS700].[v_SiteStatus] SS ON SS.SiteID=TL.SiteID
WHERE TL.ConfirmationStatus IN ('Confirmed event', 'Report of pregnancy')
AND ((ISNULL(TL.EventPaid, '')<>1 AND ISNULL(TL.[tae_reviewer_confirmation], '')<>1)
OR (ISNULL(TL.EventPaid, '')<>1 AND TL.eventStatus<>'Completed'))

)


,decompletion AS (

SELECT IV.SiteID
      ,IV.SiteStatus
	  ,IV.SFSiteStatus
      ,IV.SubjectID
	  ,IV.PatientID
	  ,IV.VisitEventType
	  ,IV.eventId
	  ,IV.eventOccurrence
	  ,IV.VisitOnsetDate
	  ,IV.[Status]
	  ,IV.CRFStatus
	  ,IV.CompletionStatus
	  ,IV.EventPaid
FROM INCOMPLETEVISITS IV
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=IV.SiteID
)

,NORECORDS AS (

SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,NULL AS SubjectID
	  ,NULL AS PatientID
	  ,'' AS VisitEventType
	  ,NULL AS eventId
	  ,NULL AS eventOccurrence
	  ,CAST(NULL AS date) AS VisitOnsetDate
	  ,NULL AS [ReviewStatus]
	  ,'' AS CRFStatus
     ,'All records completed' AS CompletionStatus
	 ,NULL AS EventPaid
FROM MS700.v_SiteParameter SP
LEFT JOIN MS700.v_SiteStatus SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT(SiteID) FROM decompletion)
)


SELECT *
FROM decompletion

UNION

SELECT *
FROM NORECORDS

GO
