USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_BiorepQueryTool]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ==============================================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/28/2020
-- Description:	Procedure to create tables for Precision Med Biorepository Query Tool for AD550
-- Creates: [AD550].[t_op_BiorepList]; [AD550].[t_op_BiorepForms]; [AD550].[t_op_VisitDrugs]
-- ==============================================================================================


CREATE PROCEDURE [AD550].[usp_op_BiorepQueryTool] AS




BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


/***Determine if Investigational Topical is in use***/

IF OBJECT_ID('tempdb.dbo.#PhototherapyTopicals') IS NOT NULL BEGIN DROP TABLE #PhototherapyTopicals END;

SELECT DISTINCT pt.[subNum] AS SubjectID
      ,pt.[eventName]
	  ,pt.eventId
      ,pt.[eventOccurrence]
      ,pt.[crfOccurrence]
	  ,pt.crfName
      ,pt.[valueIndex] AS ROWNBR
      ,pt.[statusCode]
      ,pt.[phototopical_treatment_dec]
	  ,pt.[phototopical_treatment_txt]
INTO #PhototherapyTopicals
FROM [RCC_AD550].[staging].[currentphototherapytopicals_phototherapyandprescript] pt
LEFT JOIN [AD550].[t_op_VisitLog] vl ON vl.SubjectID=pt.subNum AND vl.eventId=pt.eventId AND vl.eventOccurrence=pt.eventOccurrence
WHERE phototopical_treatment_dec = 'investigational topical (specify)'

--SELECT * FROM #PhototherapyTopicals ORDER BY SubjectID, eventOccurrence, rownbr


/*****Get Subjects and Drugs - Put in separate table for bottom of Query Tool*****/

IF OBJECT_ID('tempdb.dbo.#DRUGS') IS NOT NULL BEGIN DROP TABLE #DRUGS END;

SELECT DISTINCT ad.SiteID
      ,CASE WHEN SiteID=1440 THEN 'Approved / Active'
	   ELSE ad.SiteStatus
	   END AS SiteStatus
	  ,ad.SubjectID
	  ,ad.ProviderID
	  ,ad.VisitDate
	  ,ad.VisitType
	  ,ad.eventId
	  ,ad.eventOccurrence
	  ,ad.crfName
	  ,ad.crfOccurrence
	  ,ad.TreatmentName
	  ,ad.OtherTreatment
	  ,ad.TreatmentStatus
	  ,ad.DrugStarted
	  ,ad.StartDate
	  ,ad.StopDate
	  ,replace(pt.phototopical_treatment_dec, ' (specify)', '') AS PhototopicalTreatment
INTO #DRUGS
FROM [AD550].[t_op_AllDrugs] ad
LEFT JOIN #PhototherapyTopicals pt on pt.SubjectID=ad.SubjectID and pt.eventOccurrence=ad.eventOccurrence AND pt.eventId=ad.eventId
WHERE 1=1
AND ad.VisitType<>'Exit'
AND TreatmentName IS NOT NULL
AND TreatmentName <> 'No Data'
ORDER BY SubjectID, VisitDate, eventOccurrence

--SELECT * FROM #DRUGS WHERE phototopicaltreatment is not null


/* Get biorepository forms with drugs with matching visit date in EDC */


DROP TABLE [AD550].[t_op_BiorepList];

SELECT DISTINCT SiteID,
       SiteStatus,
	   SubjectID,
	   gender,
	   YOB,
	   ProviderID, 
	   row_number() over (partition by SiteID, SubjectID, VisitType ORDER BY SiteID, SubjectID, VisitDate DESC, ShortCohort, DrugHierarchy) AS OrderNbr,
	   --RowNbr,
	   Cohort,
	   ShortCohort,
	   CollectionAttempted,
	   VisitDate,
	   VisitType,
	   eventId,
	   eventOccurrence,
	   DrugHierarchy,
	   Treatment,
	   TreatmentStatus,
	   DrugStarted,
	   StartDate,

	   STUFF((
	   SELECT DISTINCT ', ' + TreatmentName
	   FROM #DRUGS D
	   WHERE D.SubjectID=B.SubjectID
	   AND D.eventId=B.eventId
	   AND D.eventOccurrence=B.eventOccurrence
	   AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
	   AND D.TreatmentName NOT LIKE Treatment
	   FOR XML PATH('')),
        1,1,'') OtherTreatments,

	   PhototopicalTreatment,
	   crfName

INTO [AD550].[t_op_BiorepList]
FROM
(
SELECT --RowNbr,
       A.SiteID,
	   A.SiteStatus,
	   A.SubjectID,
	   gender,
	   YOB,
	   A.ProviderID,
	   Cohort,
	   ShortCohort,
	   CollectionAttempted,
	   A.VisitDate,
	   A.VisitType,
	   A.eventId,
	   A.eventOccurrence,

	   CASE WHEN TreatmentName='investigational drug (specify)' THEN '10'
			WHEN PhototopicalTreatment='Investigational topical' THEN '20'
			WHEN ShortCohort='Cohort 1' AND TreatmentStatus IN ('Continue drug plan/no changes', 'Modify dose or frequency') AND TreatmentName IN (SELECT DrugName FROM [AD550].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 1') THEN 30
			WHEN ShortCohort='Cohort 2' AND TreatmentStatus IN ('Start drug (or restart drug)') AND DrugStarted IS NULL AND TreatmentName IN (SELECT DrugName FROM [AD550].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 2') THEN 30
			WHEN ShortCohort='Cohort 1' AND TreatmentName IN (SELECT DrugName FROM [AD550].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 1') THEN 50
			WHEN ShortCohort='Cohort 2' AND TreatmentName IN (SELECT DrugName FROM [AD550].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 2') THEN 50
			ELSE 90
	   END AS DrugHierarchy,

	   CASE WHEN TreatmentName='investigational drug (specify)' THEN 'investigational drug'
			WHEN PhototopicalTreatment='Investigational topical' THEN 'Investigational topical'
			WHEN ISNULL(OtherTreatment, '')<>'' THEN TreatmentName + ', ' + OtherTreatment
	   ELSE TreatmentName
	   END AS Treatment,

	   CASE WHEN PhototopicalTreatment IS NOT NULL THEN '' 
			ELSE TreatmentStatus
	   END AS TreatmentStatus,

	   CASE WHEN PhototopicalTreatment IS NOT NULL THEN ''
			WHEN DrugStarted=1 THEN 'Yes'
			ELSE CAST(DrugStarted as nvarchar)
	   END AS DrugStarted,

	   StartDate,
	   PhototopicalTreatment,
	   d.crfName

FROM
(
SELECT DISTINCT vl.SiteID,
       --row_number() over (partition by vl.SiteID, vl.SubjectID ORDER BY vl.SiteID, vl.SubjectID, vl.VisitDate DESC, vl.VisitType DESC) AS RowNbr,
       vl.SFSiteStatus AS SiteStatus, 
	   vl.SubjectID,
	   sub.sex_dec AS gender,
	   sub.birthdate AS YOB,
	   vl.ProviderID,
	   brc.bio_cohort_dec AS Cohort,
	   SUBSTRING(brc.bio_cohort_dec, 1, 8) AS ShortCohort,

	   CASE WHEN SUBSTRING(brc.bio_cohort_dec, 1, 8)='Cohort 1' THEN brc.bio_specimen_1_dec
			WHEN SUBSTRING(brc.bio_cohort_dec, 1, 8)='Cohort 2' THEN brc.bio_specimen_2_dec
			ELSE ''
			END AS CollectionAttempted,



       --COALESCE(brc.bio_specimen_1_dec, brc1.bio_specimen_2_dec) AS CollectionAttempted,


	   vl.VisitDate,
	   vl.VisitType,
	   vl.eventId,
	   vl.eventOccurrence
	   
FROM [AD550].[t_op_VisitLog] vl 
LEFT JOIN [RCC_AD550].[staging].[subject] sub on sub.subNum=vl.SubjectID and sub.eventName='Enrollment Visit'
LEFT JOIN [RCC_AD550].[staging].[biorepositorycollection] brc ON brc.subNum=vl.SubjectID AND brc.bio_visit_date_1=vl.VisitDate
LEFT JOIN [RCC_AD550].[staging].[biorepositorycollection] brc1 ON brc1.subNum=vl.SubjectID AND brc1.bio_visit_date_2=vl.VisitDate
WHERE vl.VisitType <> 'Exit'
--ORDER BY SubjectID,VisitDate DESC
) A
LEFT JOIN #DRUGS d ON d.SiteID=A.SiteID AND d.SubjectID=A.SubjectID AND d.VisitDate=A.VisitDate AND d.eventOccurrence=A.eventOccurrence AND d.eventId=A.eventId
) B

--SELECT * FROM [AD550].[t_op_BiorepList] where SiteID=1440 AND SUBJECTID='AD-1440-0055' Order by SiteID, SubjectID, OrderNbr



IF OBJECT_ID('tempdb.dbo.#BioRepQuery') IS NOT NULL BEGIN DROP TABLE #BioRepQuery END;

SELECT DISTINCT brc.subNum AS SubjectID,
	   brc.bio_cohort_dec AS Cohort,  
	   SUBSTRING(brc.bio_cohort_dec, 1, 8) AS ShortCohort,
       brc.bio_visit_date_1 AS AssocVisitDate1,
	   brc.crfOccurrence,
	   brc.bio_specimen_1_dec AS CollectionAttempted1,
	   brc.bio_visit_date_2 AS AssocVisitDate2,
	   brc.bio_specimen_2_dec as CollectionAttempted2
INTO #BioRepQuery
FROM [RCC_AD550].[staging].[biorepositorycollection] brc
WHERE bio_cohort_dec IS NOT NULL

--SELECT * FROM #BioRepQuery ORDER BY SubjectID, AssocVisitDate1



/* Get biorepository forms regardless of matching a visit date */

DROP TABLE [AD550].[t_op_BiorepForms];

SELECT DISTINCT VL.SiteID,
       VL.SFSiteStatus AS SiteStatus,
	   BRQ.SubjectID,	   
	   Cohort,  
	   ShortCohort,
       AssocVisitDate1,
	   BRQ.crfOccurrence,
	   CollectionAttempted1,
	   AssocVisitDate2,
	   CollectionAttempted2

INTO [AD550].[t_op_BiorepForms]
FROM #BioRepQuery BRQ
LEFT JOIN [AD550].[t_op_VisitLog] VL ON VL.SubjectID=BRQ.SubjectID

--SELECT * FROM [AD550].[t_op_BiorepForms] ORDER BY SiteID, SubjectID, AssocVisitDate1

/* Get drug listing by visit */

DROP TABLE [AD550].[t_op_VisitDrugs];

SELECT DISTINCT SiteID,
       SiteStatus,
	   SubjectID,
	   ProviderID,
	   VisitDate,
	   VisitType,
	   eventId,
	   eventOccurrence,
	   crfName,
	   crfOccurrence,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentStatus,
	   DrugStarted,
	   StartDate,
	   StopDate,
	   PhototopicalTreatment
INTO [AD550].[t_op_VisitDrugs]
FROM #DRUGS

--SELECT * FROM [AD550].[t_op_VisitDrugs]
END

GO
