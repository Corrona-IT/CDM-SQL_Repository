USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_BiorepElig]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- ================================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/28/2020
-- Description:	Procedure to create table for All Drugs for AD550
-- ==================================================================================


CREATE PROCEDURE [AD550].[usp_op_BiorepElig] AS




BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [Reporting].[AD550].[t_op_BiorepElig]
(
	   [SiteStatus] [nvarchar] (50) NULL
	  ,[SiteID] [int] NOT NULL
      ,[SubjectID] [nvarchar] (25) NOT NULL
      ,[PatientID] [bigint] NOT NULL
	  ,[ProviderID] [int] NULL
      ,[VisitType] [nvarchar] (25) NULL
      ,[VisitDate] [date] NULL
	  ,[VisitSequence] [int] NULL
	  ,[VisitEventOccurrence] [int] NULL
	  ,[VisitCompletion] [nvarchar] (30) NULL
	  ,[eventId] [int] NULL
	  ,[eventOccurrence] [int] NULL
      ,[crfName] [nvarchar] (200) NULL
	  ,[crfId] [bigint] NULL
	  ,[eventCrfId] [bigint] NULL
	  ,[crfOccurrence] [int] NULL
      ,[TreatmentName] [nvarchar] (250) NULL
      ,[OtherTreatment] [nvarchar] (250) NULL
      ,[TreatmentStatus] [nvarchar] (100) NULL
	  ,[NoPriorUse] [int] NULL

);

*/

/*****Get Enrollment Subjects*****/

IF OBJECT_ID('tempdb.dbo.#VISITS') IS NOT NULL BEGIN DROP TABLE #VISITS END;

SELECT SiteID
      ,SFSiteStatus AS SiteStatus
	  ,vl.SubjectID
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,VisitSequence
	  ,sub.sex_dec AS Gender
	  ,COALESCE(sub.pregnant_current_dec, sub2.pregnant_current_dec) AS CurrentlyPregnant
INTO #VISITS
FROM [AD550].[t_op_VisitLog] vl
LEFT JOIN [RCC_AD550].[staging].[subject] sub ON vl.SubjectID=sub.subNum and sub.eventName='Enrollment Visit'
LEFT JOIN [RCC_AD550].[staging].[subject] sub2 ON vl.SubjectID=sub2.subNum AND vl.eventOccurrence=sub2.eventOccurrence and sub2.eventName='Follow-Up Visit'

--SELECT * FROM #VISITS ORDER BY SiteID, SubjectID, VisitDate


IF OBJECT_ID('tempdb.dbo.#PhototherapyTopicals') IS NOT NULL BEGIN DROP TABLE #PhototherapyTopicals END;

SELECT [subNum] AS SubjectID
      ,[eventName]
      ,[eventOccurrence]
      ,[crfOccurrence]
      ,[valueIndex] AS ROWNBR
      ,[statusCode]
      ,[phototopical_treatment_dec]
	  ,[phototopical_treatment_txt]
INTO #PhototherapyTopicals
FROM [RCC_AD550].[staging].[currentphototherapytopicals_phototherapyandprescript]
WHERE phototopical_treatment_dec = 'investigational topical (specify)'

--SELECT * FROM #PhototherapyTopicals order by SubjectID, eventOccurrence, crfOccurrence, ROWNBR

IF OBJECT_ID('tempdb.dbo.#DRUGS') IS NOT NULL BEGIN DROP TABLE #DRUGS END;

SELECT DISTINCT ad.SiteID
      ,ad.SubjectID
	  ,ad.VisitType
	  ,ad.VisitDate
	  ,ad.VisitSequence

	  ,CASE WHEN TreatmentName LIKE '%(specify)' AND OtherTreatment IS NOT NULL THEN REPLACE(TreatmentName, ' (specify)', '') + ': ' + OtherTreatment
	   ELSE TreatmentName
	   END AS TreatmentName  
	  ,bdr.DrugName
	  ,TreatmentStatus
	  ,ad.StartDate
	  ,CASE WHEN FirstDoseReceivedToday=0 THEN 'No'
	   WHEN FirstDoseReceivedToday=1 THEN 'Yes'
	   ELSE CAST(FirstDoseReceivedToday AS nvarchar)
	   END AS FirstDoseReceivedToday
INTO #DRUGS
FROM [AD550].[t_op_AllDrugs] ad
LEFT JOIN [AD550].[t_op_BiorepDrugRef] bdr ON bdr.DrugName=ad.TreatmentName

--SELECT * FROM #DRUGS ORDER BY SiteID, SubjectID, VisitDate, VisitSequence

IF OBJECT_ID('tempdb.dbo.#Biorep') IS NOT NULL BEGIN DROP TABLE #BioRep END;


SELECT subnum AS SubjectID
	  ,SUBSTRING(bio_cohort_dec, 1, 8) AS Cohort
	  ,SUBSTRING(bio_cohort_dec, 11, LEN(bio_cohort_dec)) AS CohortName
      ,brlabel AS VisitDefinition
      ,COALESCE(bio_visit_date_1, bio_visit_date_2) AS AssocVisitDate
	  ,COALESCE(bio_specimen_1_dec, bio_specimen_2_dec) AS CollectionAttempted
	  ,crfOccurrence
INTO #BioRep
FROM [RCC_AD550].[staging].[biorepositorycollection]



END
GO
