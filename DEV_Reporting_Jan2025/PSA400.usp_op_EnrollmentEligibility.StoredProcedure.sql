USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_EnrollmentEligibility]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================================
-- Author:		Kaye Mowrey
-- Create date: 2/26/2019
-- Description:	Procedure for PSA400 Enrollment and Eligibility
-- =============================================================


CREATE PROCEDURE [PSA400].[usp_op_EnrollmentEligibility] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

/*
ALTER TABLE [Reporting].[PSA400].[t_op_EnrollmentEligibility]
(
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[Diagnosis] [nvarchar] (50) NULL,
	[EligibilityVersion] [nvarchar] (6) NULL,
	[EligibilityStatus] [nvarchar] (50) NULL,
	[EligibleDrug] [nvarchar] (400) NULL,
	[DrugOfInterest] [nvarchar] (10) NULL,
	[Cohort] [nvarchar] (250) NULL,
	[ReviewOutcome] [nvarchar] (150) NULL,
	[Hierarchy_DATA] [int] NULL

);

*/

--SELECT * FROM [Reporting].[PSA400].[t_op_EnrollmentEligibility] order by SiteID, SubjectID



/************Get Enrollment Provider IDs************/
IF object_id('tempdb..#ENPROVID') IS NOT NULL BEGIN DROP TABLE #ENPROVID END

SELECT DISTINCT vID, SITENUM, SUBNUM, VISNAME, MD_COD 
INTO #ENPROVID
FROM
(
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EP_01
UNION
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EPRO_01
)t

--SELECT * FROM #ENPROVID


 /************Get Drug Cohorts from Reimbursement view************/
IF object_id('tempdb..#SUGGESTEDCOHORT') IS NOT NULL BEGIN DROP TABLE #SUGGESTEDCOHORT END

SELECT DISTINCT [Drug] AS DrugName
      ,[Cohort] AS SuggestedCohort
	  ,[CorronaRegistryID]

INTO #SUGGESTEDCOHORT
FROM [Reimbursement].[Reference].[t_DrugHierarchy]
WHERE [CorronaRegistryID]=3 

--SELECT * FROM #SUGGESTEDCOHORT

 /************Get Drug Review Outcomes from Registry REIMB eCRF************/
IF object_id('tempdb..#REVIEWOUTCOME') IS NOT NULL BEGIN DROP TABLE #REVIEWOUTCOME END

SELECT DISTINCT vID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,VISNAME AS VisitType
	  ,INELIGIBLE
	  ,INELIGIBLE_EXCEPTION

INTO #REVIEWOUTCOME  
FROM [MERGE_SPA].[staging].[REIMB]
WHERE VISNAME LIKE 'Enroll%'

--SELECT * FROM #REVIEWOUTCOME

 /************Retrieve and calculate eligibility @ enrollment************/
IF object_id('tempdb..#Elig') IS NOT NULL BEGIN DROP TABLE #Elig END

SELECT CAST(R.SourceVisitID AS bigint) AS vID
      ,CAST(V.SITENUM AS int) AS SiteID
	  ,R.[SUBNUM] AS SubjectID
	  ,EP.MD_COD AS ProviderID
	  ,CAST(R.[VisitDate] AS date) AS EnrollmentDate
	  ,CASE WHEN V.[SUBNUM] = '3055010001' OR R.[VisitDate] BETWEEN '2017-04-03' and '2018-02-07' THEN '0'
	   WHEN R.[VisitDate] BETWEEN '2018-02-08' and '2018-09-30' THEN '1-2'
	   WHEN R.[VisitDate] BETWEEN '2018-10-01' and '2019-07-31' THEN '3'
	   WHEN R.[VisitDate] >= '2019-08-01' THEN '4'
	   ELSE ''
	   END AS EligibilityVersion
	  ,R.[Diagnosed_DATA] AS Diagnosis
	  ,CASE WHEN R.DrugReqSatisfied=1 THEN 'Eligible'
	   ELSE 'Not Eligible'
	   END AS EligibilityStatus
	  ,CASE WHEN R.DrugReqSatisfied=1 THEN R.[DRUG_NAME_DEC]
	   WHEN ISNULL(R.DrugReqSatisfied, '')='' AND RO.INELIGIBLE=1 THEN R.[DRUG_NAME_DEC]
	   WHEN ISNULL(R.DrugReqSatisfied, '')='' AND RO.INELIGIBLE=2 THEN ''
	   ELSE '' 
	   END AS EligibleDrug
	  ,CASE WHEN R.[DRUG_NAME_DEC] IN (SELECT DrugName FROM [Reporting].[PSA400].[t_op_DrugsOfInterest] WHERE RegistryName='PSA400' ) THEN 'Yes'
	   ELSE ''
	   END AS DrugOfInterest
	  ,CASE WHEN R.DrugReqSatisfied=1 THEN COALESCE(R.[Cohort_LOGIC], SC.SuggestedCohort)
	   WHEN R.DrugReqSatisfied IS NULL AND RO.INELIGIBLE=1 THEN COALESCE(R.[Cohort_LOGIC], SC.SuggestedCohort)
	   WHEN R.DrugReqSatisfied IS NULL AND RO.INELIGIBLE=2 THEN COALESCE(R.[Cohort_LOGIC], SC.SuggestedCohort)
	   ELSE ''
	   END AS Cohort
	  ,RO.INELIGIBLE
	  ,RO.INELIGIBLE_EXCEPTION
	  ,R.Hierarchy_DATA
INTO #Elig
FROM [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] P ON P.SUBNUM = R.SUBNUM AND P.SourceVisitID = R.SourceVisitID
LEFT JOIN #SUGGESTEDCOHORT SC ON R.[DRUG_NAME_DEC]=SC.DrugName
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN #ENPROVID EP ON EP.vID=R.SourceVisitID AND EP.SUBNUM=R.SUBNUM
LEFT JOIN #REVIEWOUTCOME RO ON RO.vID=R.SourceVisitID
WHERE V.SITENUM NOT IN (99997, 99998, 99999) AND
R.Hierarchy_DATA=1

--SELECT * from [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy]


 /************Retrieve and calculate eligibility @ enrollment************/
IF object_id('tempdb..#Eligibility') IS NOT NULL BEGIN DROP TABLE #Eligibility END

SELECT DISTINCT vID
      ,SiteID
	  ,SubjectID
	  ,ProviderID
	  ,EnrollmentDate
	  ,EligibilityVersion
	  ,CASE 
	   WHEN EligibilityStatus='Eligible' AND INELIGIBLE<>0 THEN 'Eligible'
	   WHEN INELIGIBLE=1 OR INELIGIBLE_EXCEPTION=1 THEN 'Eligible'
	   WHEN EligibilityStatus='Eligible' AND INELIGIBLE=0 THEN 'Eligible-Status Update'
	   WHEN EligibilityStatus='Not Eligible' AND ISNULL(INELIGIBLE, '')='' THEN 'Needs Review'
	   WHEN EligibilityStatus='Not Eligible' AND INELIGIBLE IN (0,2)  THEN 'Not Eligible'
	   ELSE EligibilityStatus
	   END AS EligibilityStatus
	  ,Diagnosis
	  ,EligibleDrug
	  ,DrugOfInterest
	  ,Cohort
	  ,CASE
	   WHEN INELIGIBLE=1 THEN 'Confirmed Eligible'
	   WHEN INELIGIBLE_EXCEPTION=1 THEN 'Exception Granted'
	   WHEN INELIGIBLE=2 THEN 'Under review(outcome TBD)'
	   ELSE ''
	   END AS ReviewOutcome
	  ,Hierarchy_DATA

INTO #Eligibility
FROM #Elig




IF object_id('tempdb..#NODRUGTABLES') IS NOT NULL BEGIN DROP TABLE #NODRUGTABLES END

SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,E2.MD_COD AS ProviderID
	  ,CAST(V.VISITDATE AS date) AS EnrollmentDate
	  ,CASE WHEN E2.DX_PA='X' AND E2.DX_AS='X' AND E2.DX_AXIAL = 'X' THEN 'PSA, AS, AxSpA'
	   WHEN E2.DX_PA='X' AND E2.DX_AS='X' AND ISNULL(E2.DX_AXIAL, '')='' THEN 'PSA, AS'
	   WHEN E2.DX_PA='X' AND ISNULL(E2.DX_AS, '')='' AND E2.DX_AXIAL = 'X' THEN 'PSA, AxSpA'
	   WHEN ISNULL(E2.DX_PA, '')='' AND ISNULL(E2.DX_AS, '')='' AND E2.DX_AXIAL = 'X' THEN 'AS, AxSpA'
	   WHEN E2.DX_PA='X' AND ISNULL(E2.DX_AS, '')='' AND ISNULL(E2.DX_AXIAL, '')='' THEN 'PSA'
	   WHEN ISNULL(E2.DX_PA, '')='' AND E2.DX_AS='X' AND ISNULL(E2.DX_AXIAL, '')='' THEN 'AS'
	   WHEN ISNULL(E2.DX_PA, '')='' AND ISNULL(E2.DX_AS, '')='' AND E2.DX_AXIAL = 'X' THEN 'AxSpA'
	   ELSE ''
	   END AS Diagnosis
	  ,CASE WHEN V.[SUBNUM] = '3055010001' OR V.[VisitDate] BETWEEN '2017-04-03' and '2018-02-07' THEN '0'
	   WHEN V.[VisitDate] BETWEEN '2018-02-08' and '2018-09-30' THEN '1-2'
	   WHEN V.[VisitDate] BETWEEN '2018-10-01' and '2019-07-31' THEN '3'
	   WHEN V.[VisitDate] >= '2019-08-01' THEN '4'
	   ELSE ''
	   END AS EligibilityVersion
	  ,CASE WHEN R.INELIGIBLE=1 OR R.INELIGIBLE_EXCEPTION=1 THEN 'Eligible'
	   WHEN ISNULL(R.INELIGIBLE, '')='' THEN 'Needs Review'
	   WHEN R.INELIGIBLE IN (0,2)  THEN 'Not Eligible'
	   ELSE '' 
	   END AS EligibilityStatus
	  ,'' AS EligibleDrug
	  ,'' AS DrugOfInterest
	  ,'' AS Cohort
	  ,CASE
	   WHEN R.INELIGIBLE=1 THEN 'Confirmed Eligible'
	   WHEN R.INELIGIBLE_EXCEPTION=1 THEN 'Exception Granted'
	   WHEN R.INELIGIBLE=2 THEN 'Under review(outcome TBD)'
	   ELSE ''
	   END AS ReviewOutcome
	  ,NULL AS Hierarchy_DATA

INTO #NODRUGTABLES
FROM MERGE_SPA.staging.VS_01 V
LEFT JOIN MERGE_SPA.staging.EPRO_01 E2 ON E2.vID=V.vID
LEFT JOIN MERGE_SPA.staging.REIMB R ON R.vID=V.vID
WHERE V.VISNAME LIKE 'Enroll%'
AND V.VISITDATE>='2017-04-03'
AND V.SITENUM <>99997
AND V.SUBNUM NOT IN (SELECT SubjectID FROM #Eligibility)

--select * from #NODRUGTABLES ORDER BY SiteID, SubjectID

 /************Insert Values into table: [Reporting].[PSA400].[t_op_EnrollmentEligibility]************/
 
 TRUNCATE TABLE [Reporting].[PSA400].[t_op_EnrollmentEligibility]

 INSERT INTO [Reporting].[PSA400].[t_op_EnrollmentEligibility]
 (
	[vID],
	[SiteID],
	[SubjectID],
	[ProviderID],
	[EnrollmentDate],
	[Diagnosis],
	[EligibilityVersion],
	[EligibilityStatus],
	[EligibleDrug],
	[DrugOfInterest],
	[Cohort],
	[ReviewOutcome],
	[Hierarchy_DATA]
 )

 SELECT DISTINCT CAST(vID AS bigint) AS vID
       ,SiteID
	   ,SubjectID
	   ,ProviderID
	   ,EnrollmentDate
	   ,Diagnosis
	   ,EligibilityVersion
	   ,EligibilityStatus
	   ,EligibleDrug
	   ,DrugOfInterest
	   ,Cohort
	   ,ReviewOutcome
	   ,Hierarchy_DATA

FROM #Eligibility
WHERE EnrollmentDate>='2017-04-03'
OR SubjectID = '3055010001'
AND ISNULL(EnrollmentDate, '')<>''

UNION

SELECT DISTINCT vID
       ,SiteID
	   ,SubjectID
	   ,ProviderID
	   ,EnrollmentDate
	   ,Diagnosis
	   ,EligibilityVersion
	   ,EligibilityStatus
	   ,EligibleDrug
	   ,DrugOfInterest
	   ,Cohort
	   ,ReviewOutcome
	   ,Hierarchy_DATA
FROM #NODRUGTABLES
WHERE EnrollmentDate>='2017-04-03'
AND ISNULL(EnrollmentDate, '')<>''

---SELECT * FROM [Reporting].[PSA400].[t_op_EnrollmentEligibility] WHERE SubjectID=3055010001
END





GO
