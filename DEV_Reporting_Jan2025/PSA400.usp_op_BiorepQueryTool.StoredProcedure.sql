USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_BiorepQueryTool]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- ==============================================================================================
-- Author:		Kaye Mowrey
-- Create date: 17Dec2024
-- Description:	Procedure to create tables for Precision Med Biorepository Query Tool for PSA-400
-- Creates: [PSA400].[t_op_BiorepList]; [PSA400].[t_op_BiorepForms]; [PSA400PSA].[t_op_VisitDrugs]
-- ==============================================================================================


CREATE PROCEDURE [PSA400].[usp_op_BiorepQueryTool] AS




BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



/*****Join Enrollment and FU Drug Tables*****/

IF OBJECT_ID('tempdb.dbo.#DRUGS') IS NOT NULL BEGIN DROP TABLE #DRUGS END;

SELECT *
INTO #DRUGS
FROM 
(
SELECT SiteID,
	   SubjectID,
	   CAST(VisitDate AS date) AS VisitDate,
	   CASE WHEN VisitType='Enrollment Visit' THEN 'Enrollment'
	        WHEN VisitType='Follow up' THEN 'Follow-Up'
			WHEN VisitType LIKE '%Exit%' THEN 'Exit'
			ELSE VisitType
		END AS VisitType,
		Diagnosis,
	   [TreatmentName],
	   CAST(TreatmentStartDate AS date) AS StartDate,
	   CAST(CAST(TreatmentStopYear as varchar) + '-' + RIGHT('00' + CAST(TreatmentStopMonth AS varchar(2)),2) + '-' + '01' AS date) AS StopDate,
	   ChangesToday AS TreatmentStatus

FROM [PSA400].[t_op_uat_Enrollment_Drugs] ed
WHERE SiteID=1440

UNION

SELECT SiteID,
	   SubjectID,
	   CAST(VisitDate AS date) AS VisitDate,
	   CASE WHEN VisitType='Enrollment Visit' THEN 'Enrollment'
	        WHEN VisitType='Follow up' THEN 'Follow-Up'
			WHEN VisitType LIKE '%Exit%' THEN 'Exit'
			ELSE VisitType
		END AS VisitType,
		(SELECT DISTINCT Diagnosis FROM [PSA400].[t_op_Enrollment_Drugs] e WHERE e.SubjectID=fd.SubjectID) AS Diagnosis,
	   [TreatmentName],
	   CAST(TreatmentStartDate AS date) AS StartDate,
	   CAST(CAST(TreatmentStopYear as varchar) + '-' + RIGHT('00' + CAST(TreatmentStopMonth AS varchar(2)),2) + '-' + '01' AS date) AS StopDate,
	   ChangesToday AS TreatmentStatus

FROM [PSA400].[t_op_uat_Followup_Drugs] fd
WHERE fd.SiteID=1440
) d

--SELECT * FROM #DRUGS WHERE SiteID=1440

/*****Get Subjects and Drugs - Put in separate table for bottom of Query Tool*****/

IF OBJECT_ID('tempdb.dbo.#VISITDRUGS') IS NOT NULL BEGIN DROP TABLE #VISITDRUGS END;

SELECT DISTINCT vl.SiteID
	  ,vl.SubjectID
	  ,d.Diagnosis
	  ,vl.VisitDate
	  ,vl.VisitType
	  ,vl.VisitSequence
	  ,d.TreatmentName
	  ,d.TreatmentStatus
	  ,d.StartDate
	  ,d.StopDate
INTO #VISITDRUGS
FROM [PSA400].[v_op_uat_VisitLog] vl
LEFT JOIN #DRUGS d ON d.SubjectID=vl.SubjectID AND d.VisitDate=vl.VisitDate AND d.VisitType=vl.VisitType
WHERE 1=1
AND TreatmentName IS NOT NULL
AND TreatmentName <> 'No Data'
AND vl.SiteID=1440
ORDER BY SubjectID, VisitDate, TreatmentName

--SELECT * FROM #VISITDRUGS


/* Get biorepository forms with drugs with matching visit date in EDC */

IF OBJECT_ID('[Reporting].[PSA400].[t_op_BiorepList]') IS NOT NULL BEGIN DROP TABLE [Reporting].[PSA400].[t_op_BiorepList] END;

SELECT DISTINCT SiteID,
	   SubjectID,
	   gender,
	   YOB, 
	   row_number() over (partition by SiteID, SubjectID, VisitType ORDER BY SiteID, SubjectID, VisitDate DESC, Cohort/*, DrugHierarchy*/) AS OrderNbr,
	   Cohort,
	   FormSection,
	   CollectionAttempted,
	   CollectionDate,
	   BiospecimenShipped,
	   VisitDate,
	   VisitType,
	   --DrugHierarchy,
	   Treatment,
	   TreatmentStatus,
	   StartDate,

	   STUFF((
	   SELECT DISTINCT ', ' + TreatmentName
	   FROM #DRUGS D
	   WHERE D.SubjectID=B.SubjectID
	   AND D.TreatmentName NOT IN ('Pending', 'No Data', 'No Treatment')
	   AND D.TreatmentName NOT LIKE Treatment
	   FOR XML PATH('')),
        1,1,'') OtherTreatments

INTO [PSA400].[t_op_BiorepList]
FROM
(
SELECT A.SiteID,
	   A.SubjectID,
	   Gender,
	   YOB,
	   Cohort,
	   FormSection,
	   CollectionAttempted,
	   CollectionDate,
	   BiospecimenShipped,
	   ReasonNotShipped,
	   A.VisitDate,
	   A.VisitType,

	   CASE WHEN TreatmentName='Investigational Drug' THEN '10'
			WHEN Cohort='Cohort 1 (Cross-Sectional Subject - Single Timepoint)' AND TreatmentStatus IN ('No changes', 'Modify') AND TreatmentName IN (SELECT DrugName FROM [PSA400].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 1') THEN 30
			WHEN Cohort='Cohort 2 (Initiator Subject - Pre-/Post medication biospecimen collections)' AND TreatmentStatus IN ('Start') AND TreatmentName IN (SELECT DrugName FROM [PSA400].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 2') THEN 30
			WHEN Cohort='Cohort 1 (Cross-Sectional Subject - Single Timepoint)' AND TreatmentName IN (SELECT DrugName FROM [PSA400].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 1') THEN 50
			WHEN Cohort='Cohort 2 (Initiator Subject - Pre-/Post medication biospecimen collections)' AND TreatmentName IN (SELECT DrugName FROM [PSA400].[t_op_BiorepDrugRef] bdr WHERE DrugName=TreatmentName AND A.VisitDate between bdr.StartDate and bdr.EndDate AND bdr.cohort='Cohort 2') THEN 50
			ELSE 90
	   END AS DrugHierarchy,

	   TreatmentName AS Treatment,
	   TreatmentStatus,
	   StartDate,
	   StopDate

FROM
(
SELECT DISTINCT vl.SiteID, 
	   vl.SubjectID,
	   GENDER_DEC AS Gender,
	   BIRTHDATE AS YOB,
	   BCOHORT_DEC AS Cohort,
	   VIS1DAT AS AssocVisitDate,
	   CASE WHEN ISNULL( BCOHORT_DEC,'')<>'' THEN 'Collection 1' 
			ELSE ''
			END AS FormSection,

	   [ATTMP1YN_DEC] AS CollectionAttempted,
	   [COLL1DAT] AS CollectionDate,
	   [SHIP1YN_DEC] AS BiospecimenShipped,
	   CASE WHEN [NOSH1RSNSP] IS NOT NULL THEN [NOSH1RSN_DEC] + '; ' + [NOSH1RSNSP]
	   ELSE [NOSH1RSN_DEC]
	   END AS ReasonNotShipped,

	   vl.VisitDate,
	   vl.VisitType
	   
FROM [PSA400].[v_op_uat_VisitLog] vl 
LEFT JOIN [MERGE_SPA_UAT].[dbo].[ES_01] sub on sub.subNum=vl.SubjectID and sub.VISNAME='Enrollment Visit'
LEFT JOIN [MERGE_SPA_UAT].[dbo].[BIOREP] brc ON brc.subNum=vl.SubjectID AND brc.[VIS1DAT]=vl.VisitDate
WHERE 1=1
AND vl.VisitType <> 'Exit'

UNION

SELECT DISTINCT vl.SiteID, 
	   vl.SubjectID,
	   GENDER_DEC AS Gender,
	   BIRTHDATE AS YOB,
	   BCOHORT_DEC AS Cohort,
	   VIS2DAT AS AssocVisitDate,
	   CASE WHEN ISNULL( BCOHORT_DEC,'')<>'' THEN 'Collection 2' 
			ELSE ''
			END AS FormSection,

	   [ATTMP2YN_DEC] AS CollectionAttempted,
	   [COLL2DAT] AS CollectionDate,
	   [SHIP2YN_DEC] AS BiospecimenShipped,
	   CASE WHEN [NOSH2RSNSP] IS NOT NULL THEN [NOSH2RSN_DEC] + '; ' + [NOSH2RSNSP]
	   ELSE [NOSH2RSN_DEC]
	   END AS ReasonNotShipped,

	   vl.VisitDate,
	   vl.VisitType
	   
FROM [PSA400].[v_op_uat_VisitLog] vl 
LEFT JOIN [MERGE_SPA_UAT].[dbo].[ES_01] sub on sub.subNum=vl.SubjectID and sub.VISNAME='Enrollment Visit'
LEFT JOIN [MERGE_SPA_UAT].[dbo].[BIOREP] brc ON brc.subNum=vl.SubjectID AND brc.[VIS2DAT]=vl.VisitDate
AND ISNULL([ATTMP2YN_DEC], '')<>''
WHERE 1=1


) A
LEFT JOIN #DRUGS d ON d.SiteID=A.SiteID AND d.SubjectID=A.SubjectID AND d.VisitDate=A.VisitDate AND d.VisitType=A.VisitType
) B
WHERE SiteID=1440

--SELECT * FROM [PSA400].[t_op_BiorepList] where SiteID=1440 AND Cohort IS NOT NULL Order by SiteID, SubjectID, OrderNbr
--select distinct TreatmentStatus from [PSA400].[t_op_BiorepList]

IF OBJECT_ID('tempdb.dbo.#BioRepQuery') IS NOT NULL BEGIN DROP TABLE #BioRepQuery END;

SELECT DISTINCT SiteID,
       SubjectID,
	   Cohort,
	   CollectionType,
	   AssocVisitDate,
	   CollectionAttempted,
	   CollectionDate,
	   BiospecimenShipped,
	   ReasonNotShipped

INTO #BioRepQuery
FROM
(
SELECT DISTINCT vl.SiteID,
	   brc.subNum AS SubjectID,
	   brc.[BCOHORT_DEC] AS Cohort,  
	   brc.[VIS1DAT] AS AssocVisitDate,
	   CASE WHEN ISNULL(brc.[BCOHORT_DEC], '')<>'' THEN 'Collection 1'
			ELSE ''
			END AS CollectionType,
	   brc.[ATTMP1YN_DEC] AS CollectionAttempted,
	   brc.[COLL1DAT] AS CollectionDate,
	   brc.[SHIP1YN_DEC] AS BiospecimenShipped,
	   CASE WHEN ISNULL([NOSH1RSNSP], '')<>'' THEN 'Other: ' + [NOSH1RSNSP]
	        ELSE brc.[NOSH1RSN_DEC] 
			END AS ReasonNotShipped

FROM [MERGE_SPA_UAT].[dbo].[BIOREP] brc
LEFT JOIN Reporting.PSA400.v_op_uat_VisitLog VL on VL.SubjectID=brc.SUBNUM
WHERE [BCOHORT_DEC] IS NOT NULL

UNION

SELECT DISTINCT vl.SiteID,
       brc.subNum AS SubjectID,
	   brc.[BCOHORT_DEC] AS Cohort,  
	   brc.[VIS2DAT] AS AssocVisitDate,
	   CASE WHEN ISNULL(brc.[BCOHORT_DEC], '')<>'' THEN 'Collection 2'
			ELSE ''
			END AS CollectionType,
	   brc.[ATTMP2YN_DEC] as CollectionAttempted,
	   brc.[COLL2DAT] AS CollectionDate,
	   brc.[SHIP2YN_DEC] AS BiospecimenShipped,
	   CASE WHEN ISNULL([NOSH2RSNSP], '')<>'' THEN 'Other: ' + [NOSH2RSNSP]
	        ELSE brc.[NOSH2RSN_DEC] 
			END AS ReasonNotShipped

FROM [MERGE_SPA_UAT].[dbo].[BIOREP] brc
LEFT JOIN Reporting.PSA400.v_op_uat_VisitLog VL on VL.SubjectID=brc.SUBNUM
WHERE [BCOHORT_DEC] IS NOT NULL
AND (brc.[VIS2DAT] IS NOT NULL OR  brc.[ATTMP2YN_DEC] IS NOT NULL OR [COLL2DAT] IS NOT NULL OR [SHIP2YN_DEC] IS NOT NULL)
) BRSEC
WHERE 1=1
AND SiteID=1440

--SELECT * FROM #BioRepQuery WHERE SiteID=1440 ORDER BY SubjectID, AssocVisitDate



/* Get biorepository forms regardless of matching a visit date */

IF OBJECT_ID('[Reporting].[PSA400].[t_op_BiorepForms]') IS NOT NULL BEGIN DROP TABLE [Reporting].[PSA400].[t_op_BiorepForms] END;

SELECT DISTINCT VL.SiteID,
	   CASE WHEN VL.SiteID=1440 THEN 'Approved / Active'
	   ELSE VL.SFSiteStatus 
	   END AS SiteStatus,
	   BRQ.SubjectID,	   
	   Cohort, 
	   CollectionType,
       AssocVisitDate,
	   CollectionAttempted,
	   CollectionDate,
	   BiospecimenShipped,
	   ReasonNotShipped

INTO [PSA400].[t_op_BiorepForms]
FROM #BioRepQuery BRQ
LEFT JOIN [PSA400].[v_op_uat_VisitLog] VL ON VL.SubjectID=BRQ.SubjectID
WHERE 1=1
AND VL.SiteID=1440

--select DISTINCT SFSiteStatus from [PSA400].[v_op_uat_VisitLog]
--SELECT * FROM [PSA400].[t_op_BiorepForms] WHERE SiteID=1440 ORDER BY SiteID, SubjectID, Cohort, AssocVisitDate

/* Get drug listing by visit */

IF OBJECT_ID('[Reporting].[PSA400].[t_op_VisitDrugs]') IS NOT NULL BEGIN DROP TABLE [Reporting].[PSA400].[t_op_VisitDrugs] END;

SELECT DISTINCT SiteID,
	   SubjectID,
	   VisitDate,
	   VisitType,
	   TreatmentName,
	   TreatmentStatus,
	   StartDate,
	   StopDate

INTO [PSA400].[t_op_VisitDrugs]
FROM #DRUGS
WHERE 1=1
AND SiteID=1440

--SELECT * FROM [PSA400].[t_op_VisitDrugs] WHERE SiteID=1440
END

GO
