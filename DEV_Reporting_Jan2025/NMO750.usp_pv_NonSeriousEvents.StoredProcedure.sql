USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_pv_NonSeriousEvents]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- =================================================
-- Author:		Kaye Mowrey
-- V2 Author: Kevin Soe
-- Create date: 21Jun2021
-- V2 Create Date: 4Apr2023
-- Description:	Procedure for NonSeriousEvents Table
-- =================================================

			  --EXECUTE
CREATE PROCEDURE [NMO750].[usp_pv_NonSeriousEvents] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_pv_NonSeriousEvents](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[eventName] [nvarchar](350) NULL,
	[eventId] [bigint] NULL,
	[VisitDate] [date] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[statusCode] [nvarchar] (50) NULL,
	[hasData] [int] NULL,
	[eventType] [nvarchar] (350) NULL,
	[specifyEvent] [nvarchar] (350) NULL,
	[Pathogen] [nvarchar] (350) NULL,
	[OnsetDate] [date] NULL,
	[auditDate] [datetime] NULL
) ON [PRIMARY]
*/

/****Get Comorbidities****/

IF OBJECT_ID('tempdb.dbo.#Comorb') IS NOT NULL BEGIN DROP TABLE #Comorb END

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
	  ,CASE WHEN CAE.[comor_type_dec] LIKE '% (specify%' THEN  SUBSTRING(CAE.[comor_type_dec], 0, PATINDEX('% (specify%', CAE.[comor_type_dec])) 
	   ELSE CAE.[comor_type_dec]
	   END AS EventType
      ,CAE.[comor_other_specify] AS specifyEvent
      ,CAE.[comor_onset_dt] AS onsetDate
	  ,AL.[auditDate]
INTO #Comorb --SELECT * 
FROM [RCC_NMOSD750].[staging].[comorbiditiesaes] CAE
  LEFT JOIN [Reporting].[NMO750].[t_op_VisitLog] VL ON VL.SubjectID=CAE.subNum AND VL.eventDefinitionId=CAE.eventId AND VL.eventOccurrence=CAE.eventOccurrence
  LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=CAE.eventCrfId AND AL.[current]=1
WHERE CAE.[comor_type_dec] NOT LIKE '%{TAE}%'

--SELECT * FROM #Comorb ORDER BY SubjectID, eventOccurrence, crfOccurrence
--SELECT * FROM [Reporting].[NMO750].[t_op_VisitLog] VL

/****Get Pathogens for Infections****/

IF OBJECT_ID('tempdb.dbo.#Pathogen') IS NOT NULL BEGIN DROP TABLE #Pathogen END

SELECT SubjectID,
       PatientID,
	   eventId,
	   eventOccurrence,
	   crfName,
	   crfId,
	   eventCrfId,
	   crfOccurrence,
	   Pathogen
INTO #Pathogen
FROM
(SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
	  ,CASE WHEN [inf_path_code_as]=1 THEN 'Aspergillus (AS)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_bd]=1 THEN 'Bordetella (BD)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION
SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_ca]=1 THEN 'Candida (CA)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION
SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_cl]=1 THEN 'Clostridium difficile (CL)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_cd]=1 THEN 'Coccidioides (CD)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_cy]=1 THEN 'Cryptococcus (CY)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_ec]=1 THEN 'Escherichia coli (EC)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_hp]=1 THEN 'Haemophilus (HP)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_hbv]=1 THEN 'Hepatitis B virus (HBV)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_hcv]=1 THEN 'Hepatitis C virus (HCV)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_hc]=1 THEN 'Histoplasma capsulatum (HC)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_hiv]=1 THEN 'Human immunodeficiency virus (HIV)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_in]=1 THEN 'Influenza (IN)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_jc]=1 THEN 'JC Virus (PML) (JC)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_li]=1 THEN 'Listeria (LI)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence] 
      ,CASE WHEN [inf_path_code_mrsa]=1 THEN 'Methicillin-resistant staph aureus (MRSA)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_mssa]=1 THEN 'Methicillin-sensitive staph aureus (MSSA)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_mu]=1 THEN 'Mucorales (MU)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_tb]=1 THEN 'Mycobacterium tuberculosis (TB)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN ISNULL([inf_path_code_other], '')<>'' AND [inf_path_code_om]=1 THEN CONCAT('Other mycobacterial species (OM): ', [inf_path_code_other])
	   WHEN ISNULL([inf_path_code_other], '')='' AND [inf_path_code_om]=1 THEN 'Other mycobacterial species (OM)'
	   ELSE NULL 
	   END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_nm]=1 THEN 'Neisseria meningitidis (NM)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_pn]=1 THEN 'Pneumocystis (PN)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_pm]=1 THEN 'Pseudomonas (PM)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_sl]=1 THEN 'Salmonella (SL)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_cov]=1 THEN 'SARS-CoV-2 (COV)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN ISNULL([inf_path_code_other], '')<>'' AND [inf_path_code_sc]=1 THEN CONCAT('Streptococcus (SC): ', [inf_path_code_other])
	   WHEN ISNULL([inf_path_code_other], '')='' AND [inf_path_code_sc]=1 THEN 'Streptococcus (SC)'
	   ELSE NULL 
	   END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_vzv]=1 THEN 'Varicella-Zoster Virus (VZV)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN ISNULL([inf_path_code_other], '')<>'' AND [inf_path_code_op]=1 THEN CONCAT('Other organism (OP): ', [inf_path_code_other])
	   WHEN ISNULL([inf_path_code_other], '')='' AND [inf_path_code_op]=1 THEN 'Other organism (OP)'
	   ELSE NULL 
	   END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF

UNION

SELECT INF.[subNum] AS SubjectID
      ,INF.[subjectId] AS PatientID
	  ,INF.[eventId]
      ,INF.[eventOccurrence]
      ,INF.[crfName]
      ,INF.[crfId]
      ,INF.[eventCrfId]
      ,INF.[crfOccurrence]
      ,CASE WHEN [inf_path_code_uk]=1 THEN 'Unknown (UK)' ELSE NULL END AS Pathogen
      ,[inf_path_code_other] AS OthInfectSpec
FROM [RCC_NMOSD750].[staging].[infections] INF
) A
WHERE ISNULL(Pathogen, '')<>''

--SELECT * FROM #Pathogen


/****Get Infections****/

IF OBJECT_ID('tempdb.dbo.#Infection') IS NOT NULL BEGIN DROP TABLE #Infection END

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
	  ,STUFF((
        SELECT ', '+ Pathogen 
        FROM #Pathogen B
		WHERE INF.subNum=B.SubjectID
		AND INF.eventId=B.eventId
		AND INF.eventOccurrence=B.eventOccurrence
		AND INF.crfOccurrence=B.crfOccurrence
        FOR XML PATH('')
        )
        ,1,1,'') AS Pathogen
	  ,AL.[auditDate]
INTO #Infection --SELECT * FROM #Infection
FROM [RCC_NMOSD750].[staging].[infections] INF
  LEFT JOIN [Reporting].[NMO750].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventDefinitionId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=INF.eventCrfId AND AL.[current]=1
WHERE INF.[inf_type_dec] NOT LIKE '%{TAE}%'

UNION

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
	  ,STUFF((
        SELECT ', '+ Pathogen 
        FROM #Pathogen B
		WHERE INF.subNum=B.SubjectID
		AND INF.eventId=B.eventId
		AND INF.eventOccurrence=B.eventOccurrence
		AND INF.crfOccurrence=B.crfOccurrence
        FOR XML PATH('')
        )
        ,1,1,'') AS Pathogen
	  ,AL.[auditDate]
--SELECT * FROM #Infection --SELECT *
FROM [RCC_NMOSD750].[staging].[infections] INF
  LEFT JOIN [Reporting].[NMO750].[t_op_VisitLog] VL ON VL.patientId=INF.subjectId AND VL.eventDefinitionId=INF.eventId AND VL.eventOccurrence=INF.eventOccurrence
  LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_crfStatus] AL ON AL.eventCrfId=INF.eventCrfId AND AL.[current]=1
WHERE INF.[inf_type_dec]  LIKE '%COVID%'
AND INF.[inf_ser] <> 1 AND INF.[inf_iv] <> 1

--SELECT * FROM #INFECTION ORDER BY SubjectID

TRUNCATE TABLE [Reporting].[NMO750].[t_pv_NonSeriousEvents];

INSERT INTO [NMO750].[t_pv_NonSeriousEvents]

(
	   [SiteID]
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
	  ,[Pathogen]
      ,[OnsetDate]
	  ,[auditDate]
)

SELECT DISTINCT *
FROM
(SELECT S.[SiteID]
      ,C.[SubjectID]
      ,C.[PatientID]
      ,C.[eventName]
	  ,C.[eventId]
	  ,C.[VisitDate]
      ,C.[eventOccurrence]
      ,[crfName]
      ,C.[crfId]
      ,C.[eventCrfId]
      ,C.[crfOccurrence]
      ,C.[statusCode]
      ,C.[hasData]
      ,C.[eventType]
      ,C.[specifyEvent]
	  ,NULL AS [Pathogen]
      ,C.[OnsetDate]
	  ,C.[auditDate]
FROM #Comorb C
LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.SubjectID=C.SubjectID

UNION

SELECT S.[SiteID]
      ,I.[SubjectID]
      ,I.[PatientID]
      ,I.[eventName]
	  ,I.[eventId]
	  ,I.[VisitDate]
      ,I.[eventOccurrence]
      ,I.[crfName]
      ,I.[crfId]
      ,I.[eventCrfId]
      ,I.[crfOccurrence]
      ,I.[statusCode]
      ,I.[hasData]
      ,I.[eventType]
      ,I.[specifyEvent]
	  ,I.[Pathogen]
      ,I.[OnsetDate]
	  ,I.[auditDate]
FROM #Infection I
LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.SubjectID=I.SubjectID
) C


---SELECT * FROM [Reporting].[NMO750].[t_pv_NonSeriousEvents] ORDER BY SiteID, SubjectID, OnsetDate


END

GO
