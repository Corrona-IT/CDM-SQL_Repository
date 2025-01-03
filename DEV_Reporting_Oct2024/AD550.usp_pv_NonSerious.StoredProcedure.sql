USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_pv_NonSerious]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












 


-- =============================================================
-- Author:		Kaye Mowrey Redo of KS view
-- Create date: 30May2023
-- Description:	Procedure for AD-550 NonSerious Events
-- =============================================================

CREATE PROCEDURE [AD550].[usp_pv_NonSerious] AS


BEGIN
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_pv_NonSerious](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[eventName] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[VisitDate] [date] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [bigint] NULL,
	[statusCode] [nvarchar] (100) NULL,
	[hasData] [nvarchar](10) NULL,
	[eventType] [nvarchar](500) NULL,
	[specifyEvent] [nvarchar] (500) NULL,
    [specifyLocation] [nvarchar] (500) NULL,
    [specifyEventLocation] [nvarchar] (500) NULL,
	[Serious] [nvarchar](10) NULL,
	[IVAntibiotics] [nvarchar](10) NULL,
	[Pathogen] [nvarchar](500) NULL,
	[VisitTreatments] [nvarchar](2000) NULL,
	[OtherVisitTreatments] [nvarchar](2000) NULL,
	[OnsetDate] [date] NULL,
	[auditDate] [datetime] NULL
) ON [PRIMARY]
GO
*/

/****Get Last Modified Comorbidities and Infections****/

IF OBJECT_ID('tempdb.dbo.#auditTrail') IS NOT NULL BEGIN DROP TABLE #auditTrail END

SELECT *
INTO #auditTrail
FROM 
(
    SELECT DISTINCT [auditId]
      ,[subjectId]
      ,[subNum]
	  ,[eventCrfId]
      ,[eventOccurrence]
      ,[crfOccurrence]
      ,[sectionName]
      ,[auditDate]
      ,[current]
      ,[deleted]
  FROM [RCC_AD550].[api].[v_auditlogs_items]
  WHERE [current]=1
  AND [deleted] IS NULL
  AND (sectionName LIKE '%Comorb%' OR sectionName LIKE '%Infect%')

UNION

SELECT DISTINCT [auditId]
      ,[subjectId]
      ,[subNum]
	  ,[eventCrfId]
      ,[eventOccurrence]
      ,[crfOccurrence]
	  ,[crfName] AS sectionName
      ,[auditDate]
      ,[current]
      ,[deleted]
  FROM [RCC_AD550].[api].[v_auditlogs_crfStatus] 
  WHERE [current]=1
  AND [deleted] IS NULL
  AND (crfName LIKE '%Comorb%' OR crfName LIKE '%Infect%')
) A

--SELECT * FROM #auditTrail 

/****Get comorbidites that are not labeled as TAEs****/

IF OBJECT_ID('tempdb.dbo.#COMORB') IS NOT NULL BEGIN DROP TABLE #COMORB END

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
	  ,MAX(auditTrail.[auditDate]) AS auditDate
  INTO #COMORB
  FROM [RCC_AD550].[staging].[comorbiditiesaes] CAE
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=CAE.subjectId AND VL.eventId=CAE.eventId AND VL.eventOccurrence=CAE.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=CAE.[eventCrfId] AND auditTrail.sectionName LIKE '%Comorb%'
  WHERE CAE.[comor_type_dec] NOT LIKE '%{TAE}%'
  GROUP BY CAE.SiteName, CAE.subNum, CAE.subjectId, CAE.eventName, CAE.eventId, VL.VisitDate, CAE.eventOccurrence, CAE.crfName, CAE.crfId, CAE.eventCrfId, CAE.crfOccurrence, CAE.statusCode, CAE.hasData, CAE.comor_type_dec, CAE.comor_other_specify, CAE.comor_onset_dt

/**Get list of infections**/

IF OBJECT_ID('tempdb.dbo.#INFECT') IS NOT NULL BEGIN DROP TABLE #INFECT END

SELECT *
INTO #INFECT
FROM 
(
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
	  ,MAX(auditTrail.[auditDate]) AS auditDate

  FROM [RCC_AD550].[staging].[infections] INF
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=INF.[eventCrfId] AND auditTrail.sectionName LIKE '%Infect%'
  WHERE (INF.[inf_type_dec] NOT LIKE '%{TAE}%' AND INF.[inf_type_dec] NOT LIKE 'COVID-19%')
  AND ((INF.[inf_ser] IS NULL OR INF.[inf_ser] = 0)
  AND (INF.[inf_iv] IS NULL OR INF.[inf_iv] = 0))
  GROUP BY INF.SiteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_type_dec], INF.[inf_other_specify], INF.[inf_location_specify], INF.[inf_ser], INF.[inf_iv], INF.[inf_onset_dt], INF.inf_path_code_dec, INF.inf_path_code_other

UNION

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
	  ,MAX(auditTrail.[auditDate]) AS auditDate

  FROM [RCC_AD550].[staging].[infections] INF
  LEFT JOIN [Reporting].[AD550].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=INF.[eventCrfId] AND auditTrail.sectionName LIKE '%Infect%'
  WHERE INF.[inf_type_dec] LIKE 'COVID-19%'
  AND ((INF.[inf_ser] IS NULL OR INF.[inf_ser] = 0)
  AND (INF.[inf_iv] IS NULL OR INF.[inf_iv] = 0))
  GROUP BY INF.SiteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_type_dec], INF.[inf_other_specify], INF.[inf_location_specify], INF.[inf_ser], INF.[inf_iv], INF.[inf_onset_dt], INF.inf_path_code_dec, INF.inf_path_code_other
 ) I

 /**Add pathogens to list of infections combined into one column separated by commas**/

 IF OBJECT_ID('tempdb.dbo.#INFECTION') IS NOT NULL BEGIN DROP TABLE #INFECTION END

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
	   FROM #INFECT INF2
	   WHERE INF2.SubjectID=INF.SubjectID
	   AND INF2.eventId=INF.eventId 
	   AND INF2.eventOccurrence=INF.eventOccurrence
	   AND INF2.crfOccurrence=INF.crfOccurrence
	   FOR XML PATH('')
        )
        ,1,1,'') AS Pathogen
	   ,auditDate
INTO #INFECTION
FROM #INFECT INF

/**Combine list of Comorbidities and Infections for total  list of NonSerious events**/

IF OBJECT_ID('tempdb.dbo.#NonSerious') IS NOT NULL BEGIN DROP TABLE #NonSerious END

SELECT *
INTO #NonSerious
FROM
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
FROM #COMORB

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
FROM #INFECTION
) NS


/**Get listing of all drugs from current and previous visit, and any other drugs that were started or current in two visits prior or more that have not been discontinued but are not listed on the forms after initial list**/

IF OBJECT_ID('tempdb.dbo.#DRUGS') IS NOT NULL BEGIN DROP TABLE #DRUGS END

SELECT DISTINCT NS.SubjectID, 
NS.eventName,
NS.VisitDate,
NS.eventOccurrence, 
D.eventOccurrence AS DrugEventOccurrence,
NS.eventType,
D.TreatmentName, 
D.OtherTreatment,
D.TreatmentStatus
INTO #DRUGS
FROM #NonSerious NS
LEFT JOIN [Reporting].[AD550].[t_op_AllDrugs] D ON D.SubjectID=NS.SubjectID AND ((D.eventOccurrence=NS.eventOccurrence OR D.eventOccurrence=NS.eventOccurrence-1) OR (D.eventOccurrence<NS.eventOccurrence-1 AND NOT EXISTS
(SELECT TreatmentStatus FROM [Reporting].[AD550].[t_op_AllDrugs] D2 WHERE D2.SubjectID=NS.SubjectID AND D2.eventOccurrence<(NS.eventOccurrence-1) 
	   AND D2.TreatmentName=D.TreatmentName AND D2.TreatmentStatus IN ('Not applicable (no longer in use)', 'Stop/discontinue drug'))))


/**Stuff all relevant drugs into one column separated by commas and add infection location**/

TRUNCATE TABLE [Reporting].[AD550].[t_pv_NonSerious];

INSERT INTO [AD550].[t_pv_NonSerious]
(
[SiteID]
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
	  ,[specifyEventLocation]
	  ,[Serious]
	  ,[IVAntibiotics]
	  ,[Pathogen]
	  ,[VisitTreatments]
	  ,[OtherVisitTreatments]
      ,[OnsetDate]
	  ,[auditDate]
)


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
	   FROM #DRUGS DRUGS
	   WHERE DRUGS.SubjectID=NS.SubjectID 
	   AND DRUGS.eventOccurrence=NS.eventOccurrence
	   AND DRUGS.TreatmentName NOT IN ('Pending', 'No Data')
	   FOR XML PATH('')
        )
        ,1,1,'') AS VisitTreatments

	   ,STUFF((
	   SELECT DISTINCT ', ' + OtherTreatment
	   FROM #DRUGS DRUGS
	   WHERE DRUGS.SubjectID=NS.SubjectID
	   AND DRUGS.eventOccurrence=NS.eventOccurrence
	   AND ISNULL(DRUGS.OtherTreatment, '')<>''
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherVisitTreatments
	  
	  ,[OnsetDate]
	  ,[auditDate]

FROM #NonSerious NS
) NS2


--SELECT * FROM [Reporting].[AD550].[t_pv_NonSerious] ORDER BY SiteID, SubjectID, eventType, eventOccurrence

END

GO
