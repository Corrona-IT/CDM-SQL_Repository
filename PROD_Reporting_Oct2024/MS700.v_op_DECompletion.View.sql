USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_DECompletion]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [MS700].[v_op_DECompletion] AS


WITH INCOMPLETEVISITS AS
(

SELECT S.SiteID
      ,V.[subNum] AS SubjectID
	  ,V.subjectId AS PatientID
	  ,CASE WHEN V.[eventName]='Enrollment Visit' THEN 'Enrollment'
	   WHEN V.[eventName]='Follow-Up Visit' THEN 'Follow-Up' 
	   ELSE V.[eventName]
	   END AS VisitType
	  ,V.eventOccurrence AS VisitSequence
	  ,V.[visit_dt] AS VisitDate
	  ,VC.vc_3_1000 AS visitcompleted
	  ,EC.statusCode AS CRFStatus
	  ,'Incomplete' AS CompletionStatus

FROM [RCC_MS700].[staging].[visitinformation] V
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON V.subjectId=S.[patientId]
LEFT JOIN [RCC_MS700].staging.visitcompletion VC ON VC.subjectId=V.subjectId and VC.EventName=V.EventName AND VC.eventOccurrence=V.EventOccurrence
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC on EC.id=VC.eventCRFId
WHERE S.SiteID<>1440
AND V.[eventName] IN ('Enrollment Visit', 'Follow-Up Visit')
AND (ISNULL(EC.statusCode, '')<>'Completed' OR ISNULL(VC.vc_3_1000, '')<>1)
AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')

UNION

SELECT S.SiteID
      ,E.[subNum] AS SubjectID
	  ,E.subjectId AS PatientID
	  ,'Exit' AS VisitType
	  ,E.EventOccurrence AS VisitSequence
	  ,E.[exit_date] AS VisitDate
	  ,XC.extvc_7_1000 AS visitcompleted
  	  ,EC.statusCode AS CRFStatus
	  ,'Incomplete' AS CompletionStatus

FROM [RCC_MS700].[staging].[exitstatus] E
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON E.subjectId=S.[patientId]
LEFT JOIN [RCC_MS700].[staging].[exitcompletion] XC ON XC.subjectId=E.subjectId AND XC.EventName=E.EventName AND XC.eventOccurrence=E.EventOccurrence
LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC on EC.id=XC.eventCRFId

WHERE S.SiteID<>1440
AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')
AND (ISNULL(EC.statusCode, '')<>'Completed' OR ISNULL(xc.extvc_7_1000, '')<>1)

)

,decompletion AS
(
SELECT IV.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,IV.SubjectID
	  ,IV.PatientID
	  ,IV.VisitType
	  ,IV.VisitDate
	  ,IV.visitcompleted
	  ,IV.CRFStatus
	  ,IV.CompletionStatus
FROM INCOMPLETEVISITS IV
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=IV.SiteID
)

,NORECORDS AS (

SELECT SP.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,NULL AS SubjectID
	  ,NULL AS PatientID
	  ,'' AS VisitType
	  ,CAST(NULL AS date) AS VisitDate
	  ,NULL AS VisitCompleted
	  ,'' AS CRFStatus
     ,'All records completed' AS CompletionStatus
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
