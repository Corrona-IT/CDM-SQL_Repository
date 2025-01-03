USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_pv_NonSerious_rcc]    Script Date: 1/3/2025 4:53:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












 


-- =============================================================
-- Author:		Kevin Soe
-- Create date: 12Sep2023
-- Description:	Procedure for RA-100 NonSerious Events
-- =============================================================

			  --EXECUTE
CREATE PROCEDURE [RA100].[usp_pv_NonSerious_rcc] AS


BEGIN
	SET NOCOUNT ON;

/*
CREATE TABLE [RA100].[t_pv_NonSerious_rcc](
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
	--[Pathogen] [nvarchar](500) NULL,
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
  FROM [RCC_RA100].[api].[v_auditlogs_items]
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
  FROM [RCC_RA100].[api].[v_auditlogs_crfStatus] 
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
      ,CAE.[cmr_2_1100_dec] AS eventType
      ,CAE.[cmr_2_1190] AS specifyEvent
      ,CAE.[cmr_2_1180] AS onsetDate
	  ,MAX(auditTrail.[auditDate]) AS auditDate
  INTO #COMORB  --SELECT * 
  FROM [RCC_RA100].[staging].[comorbiditiesaes] CAE
  LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.patientId=CAE.subjectId AND VL.eventId=CAE.eventId AND VL.eventOccurrence=CAE.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=CAE.[eventCrfId] AND auditTrail.sectionName LIKE '%Comorb%'
  WHERE CAE.[cmr_2_1100_dec] NOT LIKE '%{TAE}%'
  GROUP BY CAE.SiteName, CAE.subNum, CAE.subjectId, CAE.eventName, CAE.eventId, VL.VisitDate, CAE.eventOccurrence, CAE.crfName, CAE.crfId, CAE.eventCrfId, CAE.crfOccurrence, CAE.statusCode, CAE.hasData, CAE.[cmr_2_1100_dec], CAE.[cmr_2_1190], CAE.[cmr_2_1180]

  --SELECT * FROM #COMORB

/**Get list of infections**/

IF OBJECT_ID('tempdb.dbo.#INFECT') IS NOT NULL BEGIN DROP TABLE #INFECT END
--SELECT * FROM #INFECT
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
      ,CASE 
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (suspected) {TAE}' THEN 'COVID-19 (suspected)'
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (confirmed) {TAE}' THEN 'COVID-19 (confirmed)' 
		ELSE INF.[inf_2_1100_dec] 
		END AS eventType
      ,INF.[inf_2_1190] AS specifyEvent
	  ,INF.[inf_2_1300] AS specifyLocation
	  ,INF.[inf_2_1500] AS Serious
	  ,INF.[inf_2_1600] AS IVAntibiotics
      ,INF.[inf_2_1180] AS OnsetDate
	--,CASE WHEN ISNULL([inf_path_code_other], '')='' THEN [inf_path_code_dec]
	--  WHEN ISNULL([inf_path_code_other], '')<>'' THEN [inf_path_code_dec] + ': ' + [inf_path_code_other]
	--ELSE [inf_path_code_dec]
	--END AS Pathogen  --Removed for the time being until a path_code_dec replacement can be identified
	  ,MAX(auditTrail.[auditDate]) AS auditDate
	  --SELECT *
  FROM [RCC_RA100].[staging].[infections] INF
  LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=INF.[eventCrfId] AND auditTrail.sectionName LIKE '%Infect%'
  WHERE (INF.[inf_2_1100_dec] NOT LIKE '%{TAE}%' AND INF.[inf_2_1100_dec] NOT LIKE 'COVID-19%' AND INF.[inf_2_1100_dec] NOT LIKE 'Hepatitis%' AND INF.[inf_2_1100_dec] NOT LIKE 'Tuberculosis%')
  AND (INF.[inf_2_1500] IS NULL OR INF.[inf_2_1600] = 0)
  GROUP BY INF.SiteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_2_1100_dec], INF.[inf_2_1190], INF.[inf_2_1300], INF.[inf_2_1500], INF.[inf_2_1600], INF.[inf_2_1180]--, INF.inf_path_code_dec, INF.inf_path_code_other

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
      ,CASE 
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (suspected) {TAE}' THEN 'COVID-19 (suspected)'
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (confirmed) {TAE}' THEN 'COVID-19 (confirmed)' 
		ELSE INF.[inf_2_1100_dec] 
		END AS eventType
      ,INF.[inf_2_1190] AS specifyEvent
	  ,INF.[inf_2_1300] AS specifyLocation
	  ,INF.[inf_2_1500] AS Serious
	  ,INF.[inf_2_1600] AS IVAntibiotics
      ,INF.[inf_2_1180] AS OnsetDate
	--,CASE WHEN ISNULL([inf_path_code_other], '')='' THEN [inf_path_code_dec]
	--  WHEN ISNULL([inf_path_code_other], '')<>'' THEN [inf_path_code_dec] + ': ' + [inf_path_code_other]
	--ELSE [inf_path_code_dec]
	--END AS Pathogen
	  ,MAX(auditTrail.[auditDate]) AS auditDate

  FROM [RCC_RA100].[staging].[infections] INF
  LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=INF.[eventCrfId] AND auditTrail.sectionName LIKE '%Infect%'
  WHERE INF.[inf_2_1100_dec] LIKE 'COVID-19%'
  AND (INF.[inf_2_1500] IS NULL OR INF.[inf_2_1600] = 0)
  GROUP BY INF.SiteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_2_1100_dec], INF.[inf_2_1190], INF.[inf_2_1300], INF.[inf_2_1500], INF.[inf_2_1600], INF.[inf_2_1180]--, INF.inf_path_code_dec, INF.inf_path_code_other

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
      ,CASE 
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (suspected) {TAE}' THEN 'COVID-19 (suspected)'
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (confirmed) {TAE}' THEN 'COVID-19 (confirmed)' 
		ELSE INF.[inf_2_1100_dec] 
		END AS eventType
      ,CASE
		WHEN INF.[INF_2_1700] = 1 THEN 'Acute'
		WHEN INF.[INF_2_1700] = 2 THEN 'Chronic' 
		WHEN INF.[INF_2_1700] = 3 THEN 'Latent' 
		END AS specifyEvent
	  ,INF.[inf_2_1300] AS specifyLocation
	  ,INF.[inf_2_1500] AS Serious
	  ,INF.[inf_2_1600] AS IVAntibiotics
      ,INF.[inf_2_1180] AS OnsetDate
	--,CASE WHEN ISNULL([inf_path_code_other], '')='' THEN [inf_path_code_dec]
	--  WHEN ISNULL([inf_path_code_other], '')<>'' THEN [inf_path_code_dec] + ': ' + [inf_path_code_other]
	--ELSE [inf_path_code_dec]
	--END AS Pathogen  --Removed for the time being until a path_code_dec replacement can be identified
	  ,MAX(auditTrail.[auditDate]) AS auditDate
	  --SELECT *
  FROM [RCC_RA100].[staging].[infections] INF
  LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=INF.[eventCrfId] AND auditTrail.sectionName LIKE '%Infect%'
  WHERE (INF.[inf_2_1100_dec] NOT LIKE '%{TAE}%' AND INF.[inf_2_1100_dec] LIKE 'Hepatitis%')
  AND (INF.[inf_2_1500] IS NULL OR INF.[inf_2_1600] = 0)
  GROUP BY INF.SiteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_2_1100_dec], INF.[INF_2_1700], INF.[inf_2_1300], INF.[inf_2_1500], INF.[inf_2_1600], INF.[inf_2_1180]--, INF.inf_path_code_dec, INF.inf_path_code_other

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
      ,CASE 
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (suspected) {TAE}' THEN 'COVID-19 (suspected)'
		WHEN INF.[inf_2_1100_dec] = 'COVID-19 (confirmed) {TAE}' THEN 'COVID-19 (confirmed)' 
		ELSE INF.[inf_2_1100_dec] 
		END AS eventType
      ,INF.[INF_2_1300]  AS specifyEvent
	  ,INF.[inf_2_1300] AS specifyLocation
	  ,INF.[inf_2_1500] AS Serious
	  ,INF.[inf_2_1600] AS IVAntibiotics
      ,INF.[inf_2_1180] AS OnsetDate
	--,CASE WHEN ISNULL([inf_path_code_other], '')='' THEN [inf_path_code_dec]
	--  WHEN ISNULL([inf_path_code_other], '')<>'' THEN [inf_path_code_dec] + ': ' + [inf_path_code_other]
	--ELSE [inf_path_code_dec]
	--END AS Pathogen  --Removed for the time being until a path_code_dec replacement can be identified
	  ,MAX(auditTrail.[auditDate]) AS auditDate
	  --SELECT *
  FROM [RCC_RA100].[staging].[infections] INF
  LEFT JOIN [Reporting].[RA100].[t_op_VisitLog_rcc] VL ON VL.patientId=INF.subjectId AND VL.eventId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN #auditTrail auditTrail ON auditTrail.[eventCrfId]=INF.[eventCrfId] AND auditTrail.sectionName LIKE '%Infect%'
  WHERE (INF.[inf_2_1100_dec] NOT LIKE '%{TAE}%' AND INF.[inf_2_1100_dec] LIKE 'Tuberculosis%')
  AND (INF.[inf_2_1500] IS NULL OR INF.[inf_2_1600] = 0)
  GROUP BY INF.SiteName, INF.subNum, INF.subjectId, INF.eventName, INF.eventId, VL.VisitDate, INF.eventOccurrence, INF.crfName, INF.crfId, INF.eventCrfId, INF.crfOccurrence, INF.statusCode, INF.hasData, INF.[inf_2_1100_dec], INF.[inf_2_1300], INF.[inf_2_1500], INF.[inf_2_1600], INF.[inf_2_1180]--, INF.inf_path_code_dec, INF.inf_path_code_other
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

	   --,STUFF((
	   --SELECT DISTINCT ', ' + Pathogen
	   --FROM #INFECT INF2
	   --WHERE INF2.SubjectID=INF.SubjectID
	   --AND INF2.eventId=INF.eventId 
	   --AND INF2.eventOccurrence=INF.eventOccurrence
	   --AND INF2.crfOccurrence=INF.crfOccurrence
	   --FOR XML PATH('')
       -- )
       -- ,1,1,'') AS Pathogen
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
	  ,NULL AS [specifyLocation]
	  ,NULL AS Serious
	  ,NULL AS IVAntibiotics
	  --,NULL AS [Pathogen]
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
	  --,[Pathogen]
      ,[OnsetDate]
	  ,[auditDate]
FROM #INFECTION
) NS


/**Get listing of all drugs from current and previous visit, and any other drugs that are on the enrollment visit that were not no longer applicable or discontinued**/
--SELECT * FROM #DRUGS
IF OBJECT_ID('tempdb.dbo.#DRUGS') IS NOT NULL BEGIN DROP TABLE #DRUGS END --Removed until ALL DRUGs table is completed

SELECT DISTINCT NS.SubjectID, 
NS.eventName,
NS.VisitDate,
NS.eventOccurrence, 
D.eventOccurrence AS DrugEventOccurrence,
NS.eventType,
D.TreatmentName, 
D.OtherTreatment,
D.TreatmentStatus
INTO #DRUGS --SELECT * 
FROM #NonSerious NS --SELECT * FROM [Reporting].[RA100].[t_op_AllDrugs_rcc]
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=NS.SubjectID AND D.eventOccurrence=NS.eventOccurrence AND D.VisitType <> 'Exit'

UNION

SELECT DISTINCT NS.SubjectID, 
NS.eventName,
NS.VisitDate,
NS.eventOccurrence, 
D.eventOccurrence AS DrugEventOccurrence,
NS.eventType,
D.TreatmentName, 
D.OtherTreatment,
D.TreatmentStatus
--INTO #DRUGS --SELECT * 
FROM #NonSerious NS --SELECT * FROM [Reporting].[RA100].[t_op_AllDrugs_rcc]
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=NS.SubjectID AND D.eventOccurrence=NS.eventOccurrence-1 AND D.VisitType NOT IN ('Exit', 'Enrollment') 

UNION

SELECT DISTINCT NS.SubjectID, 
NS.eventName,
NS.VisitDate,
NS.eventOccurrence, 
D.eventOccurrence AS DrugEventOccurrence,
NS.eventType,
D.TreatmentName, 
D.OtherTreatment,
D.TreatmentStatus
--INTO #DRUGS --SELECT * 
FROM #NonSerious NS --SELECT * FROM [Reporting].[RA100].[t_op_AllDrugs_rcc]
LEFT JOIN [Reporting].[RA100].[t_op_AllDrugs_rcc] D ON D.SubjectID=NS.SubjectID 
WHERE D.VisitType = 'Enrollment'
AND D.TreatmentStatus NOT IN ('Not applicable (no longer in use)', 'Stop/discontinue drug')



/**Stuff all relevant drugs into one column separated by commas and add infection location**/

TRUNCATE TABLE [Reporting].[RA100].[t_pv_NonSerious_rcc];

INSERT INTO [RA100].[t_pv_NonSerious_rcc]
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
	  --,[Pathogen]
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
	  --,[Pathogen]
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
	  ,CASE 
		WHEN [Serious] = 0 THEN 'No' 
		WHEN [Serious] = 1 THEN 'Yes' 
		ELSE NULL
	   END AS [Serious]
	  ,CASE 
		WHEN [IVAntibiotics] = 0 THEN 'No' 
		WHEN [IVAntibiotics] = 1 THEN 'Yes' 
		ELSE NULL
	   END AS [IVAntibiotics]
	  --,[Pathogen]

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


--SELECT * FROM [Reporting].[RA100].[t_pv_NonSerious_rcc] ORDER BY SiteID, SubjectID, eventType, eventOccurrence

END

GO
