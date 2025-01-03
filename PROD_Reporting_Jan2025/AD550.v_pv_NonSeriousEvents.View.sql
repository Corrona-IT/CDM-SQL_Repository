USE [Reporting]
GO
/****** Object:  View [AD550].[v_pv_NonSeriousEvents]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*THIS VIEW IS DIFFERENT IN DEVELOPMENT THAN PRODUCTION!! Once production is updated, please remove this line*/





CREATE VIEW [AD550].[v_pv_NonSeriousEvents] AS

/**Get list of Comorbidities**/

WITH COMORB AS
(
SELECT DISTINCT SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID
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
      ,CAE.[comor_type_dec] AS eventType
      ,CAE.[comor_other_specify] AS specifyEvent
      ,CAE.[comor_onset_dt] AS onsetDate
	  ,MAX(AL.[auditDate]) AS auditDate
  FROM [RCC_AD550].[staging].[comorbiditiesaes] CAE
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=CAE.subjectId AND VL.eventId=CAE.eventId AND VL.eventOccurrence=CAE.eventOccurrence
  LEFT JOIN [RCC_AD550].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=CAE.eventCrfId AND AL.[current]=1
  WHERE CAE.[comor_type_dec] NOT LIKE '%{TAE}%'
  GROUP BY CAE.siteName, CAE.subNum, CAE.subjectId, CAE.eventName, CAE.eventId, VL.VisitDate, CAE.eventOccurrence, CAE.crfName, CAE.crfId, CAE.eventCrfId, CAE.crfOccurrence, CAE.statusCode, CAE.hasData, CAE.comor_type_dec, CAE.comor_other_specify, CAE.comor_onset_dt

  --ORDER BY SiteID, SubjectID, eventId, eventOccurrence, crfOccurrence
)


/**Get list of infections**/

,INFECT AS (
--Non-Covid
SELECT DISTINCT SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID
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
      ,INF.[inf_type_dec] AS eventType
      ,INF.[inf_other_specify] AS specifyEvent
	  ,INF.[inf_location_specify] AS specifyLocation
	  ,INF.[inf_ser] AS Serious
	  ,INF.[inf_iv] AS IVAntibiotics
      ,INF.[inf_onset_dt] AS OnsetDate
	  ,CASE WHEN ISNULL([inf_path_code_other], '')='' THEN [inf_path_code_dec]
	    WHEN ISNULL([inf_path_code_other], '')<>'' THEN [inf_path_code_dec] + ': ' + [inf_path_code_other]
		ELSE [inf_path_code_dec]
		END AS Pathogen
	  ,MAX(AL.[auditDate]) AS auditDate
	  --SELECT *
  FROM [RCC_AD550].[staging].[infections] INF
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN [RCC_AD550].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=INF.eventCrfId AND AL.[current]=1
  WHERE (INF.[inf_type_dec] NOT LIKE '%{TAE}%' AND INF.[inf_type_dec] NOT LIKE 'COVID-19%')
  AND ((INF.[inf_ser] IS NULL OR INF.[inf_ser] = 0)
  AND (INF.[inf_iv] IS NULL OR INF.[inf_iv] = 0))

  GROUP BY INF.siteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_type_dec], INF.[inf_other_specify], INF.[inf_location_specify], INF.[inf_ser], INF.[inf_iv], INF.[inf_onset_dt], INF.inf_path_code_dec, INF.inf_path_code_other

UNION

--Covid
SELECT DISTINCT SUBSTRING(siteName, 0, CHARINDEX(' -', siteName)) AS SiteID
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
      ,INF.[inf_type_dec] AS eventType
      ,INF.[inf_other_specify] AS specifyEvent
	  ,INF.[inf_location_specify] AS specifyLocation
	  ,INF.[inf_ser] AS Serious
	  ,INF.[inf_iv] AS IVAntibiotics
      ,INF.[inf_onset_dt] AS OnsetDate
	  ,CASE WHEN ISNULL([inf_path_code_other], '')='' THEN [inf_path_code_dec]
	    WHEN ISNULL([inf_path_code_other], '')<>'' THEN [inf_path_code_dec] + ': ' + [inf_path_code_other]
		ELSE [inf_path_code_dec]
		END AS Pathogen
	  ,MAX(AL.[auditDate]) AS auditDate

  FROM [RCC_AD550].[staging].[infections] INF
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN [RCC_AD550].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=INF.eventCrfId AND AL.[current]=1
  WHERE INF.[inf_type_dec] LIKE 'COVID-19%'
  AND ((INF.[inf_ser] IS NULL OR INF.[inf_ser] = 0)
  AND (INF.[inf_iv] IS NULL OR INF.[inf_iv] = 0))

  GROUP BY INF.siteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_type_dec], INF.[inf_other_specify], INF.[inf_location_specify], INF.[inf_ser], INF.[inf_iv], INF.[inf_onset_dt], INF.inf_path_code_dec, INF.inf_path_code_other


)

/**Add pathogens to list of infections combined into one column separated by commas**/

,INFECTION AS (
SELECT DISTINCT SiteID
       ,SubjectID
	   ,PatientID
	   ,eventName
	   ,eventId
	   ,VisitDate
	   ,eventOccurrence
	   ,crfName
	   ,crfId
	   ,eventCrfId
	   ,crfOccurrence
	   ,statusCode
	   ,hasData
	   ,eventType
	   ,specifyEvent
	   ,specifyLocation
	   ,Serious
	   ,IVAntibiotics
	   ,OnsetDate

	   ,STUFF((
	   SELECT DISTINCT ', ' + Pathogen
	   FROM INFECT INF2
	   WHERE INF2.SubjectID=INF.SubjectID
	   AND INF2.eventId=INF.eventId 
	   AND INF2.eventOccurrence=INF.eventOccurrence
	   AND INF2.crfOccurrence=INF.crfOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS Pathogen
	   ,auditDate

FROM INFECT INF
)


/**Combine list of Comorbidities and Infections for total  list of NonSerious events**/

,NonSerious AS
(
SELECT DISTINCT [SiteID]
      ,[SubjectID]
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
	  ,'' AS [specifyLocation]
	  ,'' AS Serious
	  ,'' AS IVAntibiotics
	  ,'' AS [Pathogen]
      ,[OnsetDate]
	  ,[auditDate]
FROM COMORB

UNION

SELECT DISTINCT [SiteID]
      ,[SubjectID]
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
	  ,[specifyLocation]
	  ,[Serious]
	  ,[IVAntibiotics]
	  ,[Pathogen]
      ,[OnsetDate]
	  ,[auditDate]
FROM INFECTION
)
--SELECT * FROM NonSerious ORDER BY SiteID, subjectId, eventOccurrence, eventType, crfOccurrence

/**Get listing of all drugs from current and previous visit, and any other drugs that were started or current in two visits prior or more that have not been discontinued but are not listed on the forms after initial list**/

,DRUGS AS
(
SELECT DISTINCT NS.SubjectID, 
NS.eventName,
NS.VisitDate,
NS.eventOccurrence, 
D.eventOccurrence AS DrugEventOccurrence,
NS.eventType,
D.TreatmentName, 
D.OtherTreatment,
D.TreatmentStatus
FROM NonSerious NS
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=NS.SubjectID AND ((D.eventOccurrence=NS.eventOccurrence OR D.eventOccurrence=NS.eventOccurrence-1) OR (D.eventOccurrence<NS.eventOccurrence-1 AND NOT EXISTS
(SELECT TreatmentStatus FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=NS.SubjectID AND D2.eventOccurrence<(NS.eventOccurrence-1) 
	   AND D2.TreatmentName=D.TreatmentName AND D2.TreatmentStatus IN ('Not applicable (no longer in use)', 'Stop/discontinue drug'))))
)


/**Stuff all relevant drugs into one column separated by commas and add infection location**/

SELECT DISTINCT [SiteID]
      ,[SubjectID]
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
	  ,[specifyLocation]
	  ,CASE WHEN ISNULL(specifyEvent, '')<>'' AND ISNULL(specifyLocation, '')='' THEN specifyEvent
	   WHEN ISNULL(specifyEvent, '')='' AND ISNULL(specifyLocation, '')<>'' THEN specifyLocation
	   WHEN ISNULL(specifyEvent, '')<>'' AND ISNULL(specifyLocation, '')<>'' THEN (specifyEvent + '; ' +specifyLocation)
	   END AS specifyEventLocation
	  ,[Serious]
	  ,[IVAntibiotics]
	  ,[Pathogen]
	  ,[VisitTreatments]
	  ,[OtherVisitTreatments]
      ,[OnsetDate]
	  ,[auditDate]
FROM
(
SELECT [SiteID]
      ,[SubjectID]
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
	  ,[specifyLocation]
	  ,[Serious]
	  ,[IVAntibiotics]
	  ,[Pathogen]

	   ,STUFF((
	   SELECT DISTINCT ', ' + TreatmentName
	   FROM DRUGS  
	   WHERE DRUGS.SubjectID=NS.SubjectID 
	   AND DRUGS.eventOccurrence=NS.eventOccurrence
	   AND DRUGS.TreatmentName NOT IN ('Pending', 'No Data')
	   FOR XML PATH('')
        )
        ,1,1,'') AS VisitTreatments

	   ,STUFF((
	   SELECT DISTINCT ', ' + OtherTreatment
	   FROM DRUGS
	   WHERE DRUGS.SubjectID=NS.SubjectID
	   AND DRUGS.eventOccurrence=NS.eventOccurrence
	   AND ISNULL(DRUGS.OtherTreatment, '')<>''
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherVisitTreatments
	  
	  ,[OnsetDate]
	  ,[auditDate]

FROM NonSerious NS
) NSAE

--ORDER BY SubjectID, eventOccurrence, VisitTreatments

GO
