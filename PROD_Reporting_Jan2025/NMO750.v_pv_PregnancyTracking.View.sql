USE [Reporting]
GO
/****** Object:  View [NMO750].[v_pv_PregnancyTracking]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [NMO750].[v_pv_PregnancyTracking] AS

WITH UPDATES AS (
SELECT VL.[SiteID],
       SQ.[subjectId],
       SQ.[subNum],
	   SQ.[eventName],
	   SQ.[eventId],
	   VL.[VisitDate],
	   SQ.[eventOccurrence],
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
FROM [RCC_NMOSD750].[staging].[subjectform] SQ 
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SQ1 on SQ1.subNum=SQ.subNum AND SQ1.eventName='Enrollment Visit'
LEFT JOIN [Reporting].[NMO750].[t_op_VisitLog] VL ON VL.SubjectID=SQ.subNum AND VL.eventDefinitionId=SQ.eventId AND VL.eventOccurrence=SQ.eventOccurrence
LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_items] ALI ON ALI.eventCrfId=SQ.eventCrfId AND ALI.stagingVariable IN ('fu_pregnancy', 'pregnant_current') AND ALI.[current]=1
WHERE SQ.eventId IN (11174, 11175)
--AND SQ1.sex=1
AND ((ISNULL(oldValue, '')='' AND newValue='Yes') OR (oldValue='Yes' AND ISNULL(newValue, '')='') OR (oldValue='No' AND newValue='Yes'))
)
 

 ,NO_UPDATES AS  (
 SELECT COUNT(*) AS NbrRecords
 FROM UPDATES
 )

 SELECT [SiteID],
       [subjectId],
       [subNum],
	   [eventName],
	   [eventId],
	   [VisitDate],
	   [eventOccurrence],
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
       CAST(NULL AS bigint) AS subjectId,
	   '' AS subNum,
	   '' AS eventName,
	   CAST(NULL AS bigint) AS [eventId],
	   CAST(NULL AS date) AS [VisitDate],
	   CAST(NULL AS int) AS [eventOccurrence],
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

GO
