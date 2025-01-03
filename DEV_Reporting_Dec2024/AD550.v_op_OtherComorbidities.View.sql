USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_OtherComorbidities]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [AD550].[v_op_OtherComorbidities] AS

WITH COMORB AS
(
SELECT DISTINCT SUBSTRING(CAE.[siteName], 1, 3) AS SiteID
      ,CAE.[subNum]
      ,CAE.[subjectId]
      ,CAE.[eventName]
	  ,CAE.[eventId]
	  ,VL.[VisitDate]
      ,CAE.[eventOccurrence]
      ,CAE.[crfName]
      ,CAE.[crfId]
      ,CAE.[eventCrfId]
      ,CAE.[crfOccurrence]
      ,CAE.[statusCode]
      ,CAE.[hasData]
      ,CAE.[comor_type_dec] AS eventType
      ,CAE.[comor_other_specify] AS specifyEvent
      ,CAE.[comor_onset_dt] AS onsetDate
	  ,MAX(AL.[auditDate]) AS auditDate
  FROM [RCC_AD550].[staging].[comorbiditiesaes] CAE
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=CAE.subjectId AND VL.eventId=CAE.eventId AND VL.eventOccurrence=CAE.eventOccurrence
  LEFT JOIN [RCC_AD550].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=CAE.eventCrfId AND AL.[current]=1
  WHERE RTRIM(CAE.[comor_type_dec]) LIKE 'Other%(specify)' 
  AND CAE.[comor_type_dec] NOT LIKE '%{TAE}%'
  GROUP BY CAE.siteName, CAE.subNum, CAE.subjectId, CAE.eventName, CAE.eventId, VL.VisitDate, CAE.eventOccurrence, CAE.crfName, CAE.crfId, CAE.eventCrfId, CAE.crfOccurrence, CAE.statusCode, CAE.hasData, CAE.comor_type_dec, CAE.comor_other_specify, CAE.comor_onset_dt
)

,INFECTION AS
(
SELECT SUBSTRING(INF.[siteName], 1, 3) AS SiteID
      ,INF.[subNum]
      ,INF.[subjectId]
      ,INF.[eventName]
	  ,INF.[eventId]
	  ,VL.[VisitDate]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,INF.[statusCode]
      ,INF.[hasData]
      ,INF.[inf_type_dec] AS eventType
      ,INF.[inf_other_specify] AS specifyEvent
      ,INF.[inf_onset_dt] AS OnsetDate
	  ,MAX(AL.[auditDate]) AS auditDate
  FROM [RCC_AD550].[staging].[infections] INF
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN [RCC_AD550].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=INF.eventCrfId AND AL.[current]=1
  WHERE RTRIM(INF.[inf_type_dec]) LIKE 'Other%(specify)'
  AND INF.[inf_type_dec] NOT LIKE '%{TAE}%'
  GROUP BY INF.siteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_type_dec], INF.[inf_other_specify], INF.[inf_onset_dt]
)


SELECT DISTINCT [SiteID]
      ,[subNum]
      ,[subjectId]
      ,[eventName]
	  ,[eventId]
	  ,[VisitDate]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[statusCode]
      ,[hasData]
      ,[eventType]
      ,[specifyEvent]
      ,[OnsetDate]
	  ,[auditDate]
FROM COMORB

UNION

SELECT DISTINCT [SiteID]
      ,[subNum]
      ,[subjectId]
      ,[eventName]
	  ,[eventId]
	  ,[VisitDate]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[statusCode]
      ,[hasData]
      ,[eventType]
      ,[specifyEvent]
      ,[OnsetDate]
	  ,[auditDate]
FROM INFECTION


GO
