USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_Comorbidities]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [NMO750].[v_op_Comorbidities] AS

WITH COMORB AS
(
SELECT SUBSTRING(CAE.[siteName], 1, 4) AS SiteID
      ,CAE.[subNum] AS SubjectID
      ,CAE.[subjectId] AS PatientID
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
	  ,CASE WHEN CAE.[comor_type_dec] LIKE '% (specify%' THEN SUBSTRING(CAE.[comor_type_dec], 0, PATINDEX('% (specify%', CAE.[comor_type_dec])) 
	   ELSE CAE.[comor_type_dec]
	   END AS EventType
      ,CAE.[comor_other_specify] AS specifyEvent
      ,CAE.[comor_onset_dt] AS onsetDate
	  ,MAX(AL.[auditDate]) AS auditDate
  FROM [RCC_NMOSD750].[staging].[comorbiditiesaes] CAE
  LEFT JOIN [Reporting].[NMO750].[t_op_VisitLog] VL ON VL.patientId=CAE.subjectId AND VL.eventDefinitionId=CAE.eventId AND VL.eventOccurrence=CAE.eventOccurrence
  LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=CAE.eventCrfId AND AL.[current]=1
  WHERE CAE.[comor_type_dec] NOT LIKE '%{TAE}%'
  -- AND RTRIM(CAE.[comor_type_dec]) LIKE 'Other%(specify)' 
  GROUP BY CAE.[siteName], CAE.[subNum], CAE.[subjectId], CAE.[eventName], CAE.[eventId], VL.[VisitDate], CAE.[eventOccurrence], CAE.[crfName], CAE.[crfId], CAE.[eventCrfId], CAE.[crfOccurrence], CAE.[statusCode], CAE.[hasData], CAE.[comor_type_dec], CAE.[comor_other_specify], CAE.[comor_onset_dt]
)

,INFECTION AS
(
SELECT SUBSTRING(INF.[siteName], 1, 4) AS SiteID
      ,INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
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
	  ,CASE WHEN INF.[inf_type_dec] LIKE '% (specify%' THEN  SUBSTRING(INF.[inf_type_dec], 0, PATINDEX('% (specify%', INF.[inf_type_dec])) 
	   ELSE INF.[inf_type_dec]
	   END AS EventType
      ,INF.[inf_other_specify] AS specifyEvent
      ,INF.[inf_onset_dt] AS OnsetDate
	  ,MAX(AL.[auditDate]) AS auditDate
  FROM [RCC_NMOSD750].[staging].[infections] INF
  LEFT JOIN [Reporting].[NMO750].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventDefinitionId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=INF.eventCrfId AND AL.[current]=1
  WHERE INF.[inf_type_dec] NOT LIKE '%{TAE}%'
  --AND RTRIM(INF.[inf_type_dec]) LIKE 'Other%(specify)'
  GROUP BY INF.[siteName], INF.[subNum], INF.[subjectId], INF.[eventName], INF.[eventId], VL.[VisitDate], INF.[eventOccurrence], INF.[crfName], INF.[crfId], INF.[eventCrfId], INF.[crfOccurrence], INF.[statusCode],INF.[hasData], INF.[inf_type_dec], INF.[inf_other_specify], INF.[inf_onset_dt]
)


SELECT DISTINCT C.[SiteID]
      ,[SiteStatus]
	  ,[SFSiteStatus]
      ,[SubjectID]
      ,[PatientID]
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
FROM COMORB C
LEFT JOIN [NMO750].[v_SiteStatus] SS ON SS.SiteID=C.SiteID

UNION

SELECT DISTINCT I.[SiteID]
      ,[SiteStatus]
	  ,[SFSiteStatus]
      ,[SubjectID]
      ,[PatientID]
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
FROM INFECTION I
LEFT JOIN [NMO750].[v_SiteStatus] SS ON SS.SiteID=I.SiteID


GO
