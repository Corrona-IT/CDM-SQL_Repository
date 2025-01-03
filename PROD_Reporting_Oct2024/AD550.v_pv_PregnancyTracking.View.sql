USE [Reporting]
GO
/****** Object:  View [AD550].[v_pv_PregnancyTracking]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [AD550].[v_pv_PregnancyTracking] AS

WITH UPDATES AS (
SELECT VL.[SiteID],
       SQ.[subjectId],
       SQ.[subNum],
	   SQ.[eventName],
	   SQ.[eventId],
	   SQ.[eventOccurrence],
	   VL.[VisitDate],
	   SQ.[crfOccurrence],
	   SQ.[hasData],
	   CASE WHEN SQ1.[sex]=0 THEN 'Male'
	   WHEN SQ1.[sex]=1 THEN 'Female'
	   ELSE ''
	   END AS gender,
	   SQ.[eventCrfId],
	   ALI.[auditId],
	   ALI.[questionText],
	   ALI.[oldValue],
	   ALI.[newValue],
	   ALI.[auditDate] AS LastModifiedDate,
	   ALI.[current],
	   CASE WHEN ALI.[stagingVariable]='fu_pregnancy' THEN 1
	   WHEN ALI.[stagingVariable]='pregnant_current' THEN 2
	   ELSE 0
	   END AS columnOrder
FROM [RCC_AD550].[staging].[subject] SQ 
LEFT JOIN [RCC_AD550].[staging].[subject] SQ1 on SQ1.subjectId=SQ.subjectId AND SQ1.eventName='Enrollment Visit'
LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=SQ.subjectId AND VL.eventId=SQ.eventId AND VL.eventOccurrence=SQ.eventOccurrence
LEFT JOIN [RCC_AD550].[api].[v_auditlogs_items] ALI ON ALI.eventCrfId=SQ.eventCrfId AND ALI.stagingVariable IN ('fu_pregnancy', 'pregnant_current') AND ALI.[current]=1
WHERE SQ.eventId IN (8031, 8034)
AND SQ1.sex=1
AND ((ISNULL(oldValue, '')='' AND newValue='Yes') OR (oldValue='Yes' AND ISNULL(newValue, '')='') OR (oldValue='No' AND newValue='Yes'))
)
 

 ,NO_UPDATES AS (

 SELECT COUNT(*) AS NbrRecords
 FROM UPDATES
 )

 ,PREG AS (
 SELECT [SiteID],
       [subjectId],
       [subNum],
	   [eventName],
	   [eventId],
	   [eventOccurrence],
	   [VisitDate],
	   [crfOccurrence],
	   [hasData],
	   [gender],
	   [eventCrfId],
	   [auditId],
	   [questionText],
	   [oldValue],
	   [newValue],
	   LastModifiedDate,
	   [current],
	   columnOrder
FROM UPDATES

UNION

SELECT 0 AS SiteID,
       '' as subjectId,
	   '' as subNum,
	   '' AS eventName,
	   CAST(NULL AS bigint) AS [eventId],
	   CAST(NULL AS int) AS [eventOccurrence],
	   CAST(NULL AS date) AS [VisitDate],
	   CAST(NULL AS int) AS [crfOccurrence],
	   CAST(NULL AS int) AS [hasData],
	   '' AS [gender],
	   CAST(NULL AS bigint) AS [eventCrfId],
	   CAST(NULL AS int) AS [auditId],
	   'No response changes to questions' AS [questionText],
	   '' AS [oldValue],
	   '' AS [newValue],
	   GETDATE() AS LastModifiedDate,
	   CAST(NULL AS int) AS [current],
	   CAST(NULL AS int) AS columnOrder
FROM NO_UPDATES
WHERE NbrRecords=0
)

,DRUGS AS (
SELECT DISTINCT P.SiteID,
P.subNum, 
P.eventName,
P.VisitDate,
P.eventOccurrence, 
D.eventOccurrence AS DrugEventOccurrence,
D.TreatmentName, 
D.OtherTreatment,
D.TreatmentStatus
FROM PREG P
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=P.subNum AND (
(D.eventOccurrence=P.eventOccurrence OR D.eventOccurrence=P.eventOccurrence-1) OR (D.eventOccurrence<P.eventOccurrence-1 AND NOT EXISTS
(SELECT TreatmentStatus FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=P.subNum AND D2.eventOccurrence<(P.eventOccurrence-1) 
	   AND D2.TreatmentName=D.TreatmentName AND D2.TreatmentStatus IN ('Not applicable (no longer in use)', 'Stop/discontinue drug'))))
)

--Add follow up drugs at visit or visit before that are not past use only, or any drug reported as started or current that do not have a stop date from any visit prior

SELECT DISTINCT [SiteID],
       [subjectId],
       [subNum],
	   [eventName],
	   [eventId],
	   [eventOccurrence],
	   [VisitDate],
	   [crfOccurrence],
	   [hasData],
	   [gender],
	   [eventCrfId],
	   [auditId],
	   [questionText],
	   [oldValue],
	   [newValue],

	   STUFF((
	   SELECT DISTINCT ', ' + TreatmentName
	   FROM DRUGS  
	   WHERE DRUGS.subNum=PREG.subNum 
	   AND (DRUGS.eventOccurrence=PREG.eventOccurrence)
	   AND DRUGS.TreatmentName NOT IN ('Pending', 'No Data')
	   FOR XML PATH('')
        )
        ,1,1,'') AS VisitTreatments,

	   STUFF((
	   SELECT DISTINCT ', ' + OtherTreatment
	   FROM DRUGS
	   WHERE DRUGS.subNum=PREG.subNum
	   AND (DRUGS.eventOccurrence=PREG.eventOccurrence)
	   AND ISNULL(DRUGS.OtherTreatment, '')<>''
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherVisitTreatments,

	   [LastModifiedDate],
	   [current],
	   [columnOrder]

FROM PREG



GO
