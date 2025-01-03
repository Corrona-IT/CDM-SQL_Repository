USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_uat_op_EER]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =============================================================
-- Author:		Kaye Mowrey
-- Create date: 29March2022; Updated: 6Jun2023
-- Description:	Procedure for Enrollment Eligibility Report
-- =============================================================


CREATE PROCEDURE [IBD600].[usp_uat_op_EER] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_uat_op_EER]
(
	   [ROWNUM] [int] NULL
      ,[vID] [bigint] NOT NULL
      ,[VisitType] [nvarchar](50) NULL
	  ,[SiteID] [int] NOT NULL
	  ,[SiteStatus] [nvarchar] (50) NULL
	  ,[SubjectID] [bigint] NOT NULL
	  ,[ProviderID] [int] NULL
	  ,[EnrollmentDate] [date] NOT NULL
	  ,[EligibilityVersion] [int] NULL
	  ,[YOB] [int] NULL
      ,[AgeAtVisit] [int] NULL
      ,[Diagnosis] [nvarchar] (150) NULL
      ,[DRUG_CLASS123_USE_EN] [int] NULL
	  ,[DrugClass] [nvarchar] (200) NULL
	  ,[DrugName] [nvarchar] (200) NULL
	  ,[EligibleDrug] [nvarchar] (200) NULL
      ,[PastUse] [nvarchar] (5) NULL
      ,[CurrentUse] [nvarchar] (5) NULL
      ,[ChangesToday] [nvarchar] (200) NULL
      ,[NoPriorUse] [nvarchar] (5) NULL
      ,[FirstDoseAdminTodayVisit] [nvarchar] (5) NULL
      ,[StartDate] [nvarchar] (20) NULL
      ,[ModPriorCurrStartDate] [date] NULL
      ,[MonthsSinceDrugStart] [int] NULL
	  ,[InitiatedWithin12MoEnroll] [nvarchar] (20) NULL 
	  ,[BiologicNaive] [nvarchar] (10) NULL
      ,[EligibilityStatus] [nvarchar] (100) NULL
      ,[ReviewOutcome] [nvarchar] (100) NULL
      ,[VisitCompletionStatus] [nvarchar] (50) NULL
);

*/

/*Get enrollment information including year of brith, provider ID and diagnosis*/

IF OBJECT_ID('tempdb..#ENR') IS NOT NULL BEGIN DROP TABLE #ENR END

SELECT DISTINCT VS.vID
      ,VS.SITENUM AS SiteID
	  ,CASE WHEN S.ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
	  ,VS.SUBNUM AS SubjectID
	  ,CAST(VS.VISITDATE AS date) AS EnrollmentDate
	  ,CASE WHEN VS.VISITDATE<'2019-01-01' THEN 0
	   WHEN VS.VISITDATE>='2019-01-01' AND VS.VISITDATE < '2022-02-10' THEN 1
	   WHEN VS.VISITDATE >= '2022-02-10' THEN 2
	   ELSE ''
	   END AS EligibilityVersion
	  ,VS.VISNAME AS VisitType
	  ,VS.AGE AS AgeAtVisit
	  ,DEM.[IDENT2] AS YOB
	  ,DX.MD_COD AS ProviderID
	  ,DX.DX_IBD_DEC AS Diagnosis
	  ,REIMB.INELIGIBLE_DEC AS SubjectEligibilityMonitorReview
	  ,ISNULL(REIMB.INELIGIBLE_RSN_DEC, '') + ISNULL(';  ' + REIMB.INELIGIBLE_RSN_OTH , '') AS IneligibleReasonMonitorReview
	  ,REIMB.INELIGIBLE_EXCEPTION_DEC AS ExceptionGrantedforEligibility
	  ,REIMB.INELIGIBLE_EXCEPTION_RSN AS EligibilityExceptionReason
	  ,REIMB.VISIT_PAID AS VisitPaid
	  ,REIMB.PII_HB AS PIIRequirementMet
	  ,REIMB.INELIGIBLE
	  ,REIMB.INELIGIBLE_EXCEPTION
INTO #ENR   
FROM [MERGE_IBD_UAT].[staging].[VISIT] VS
LEFT JOIN [MERGE_IBD_UAT].[dbo].[DAT_SITES] S ON S.SITENUM=VS.SITENUM --Used to determine site status
LEFT JOIN [MERGE_IBD_UAT].[staging].[MD_DX] DX ON VS.VID=DX.VID AND VS.SUBNUM=DX.SUBNUM
LEFT JOIN [MERGE_IBD_UAT].[staging].[REIMB] REIMB ON VS.VID=REIMB.VID AND VS.SUBNUM=REIMB.SUBNUM AND REIMB.PAGENAME='Visit Date'
LEFT JOIN [MERGE_IBD_UAT].[dbo].[DAT_SUB] DEM ON DEM.SITENUM=VS.SITENUM AND DEM.SUBNUM=VS.SUBNUM  --used for YOB
WHERE VS.VISNAME='Enrollment'
AND ISNULL(VS.VISITDATE, '')<>''

--SELECT * FROM #ENR ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb..#DRUGINFO') IS NOT NULL BEGIN DROP TABLE #DRUGINFO END

/*Get drug information, assign protocol version, determine if biologic naive and calculate start date for 12 month rule*/
SELECT vID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,ProviderID
	  ,VisitType
	  ,EnrollmentDate
	  ,EligibilityVersion
	  ,YOB
	  ,AgeAtVisit
	  ,Diagnosis
	  ,DRUG_CLASS123_USE_EN
	  ,DrugClass
	  ,BiologicName
	  ,IstName
	  ,MesalamineName
	  ,DrugName
	  ,OtherDrugSpecify
	  ,NoPriorUse
	  ,PastUse
	  ,CurrentUse
	  ,ChangesAtVisit
	  ,ChangesToday
	  ,FirstDoseAdminTodayVisit
	  ,StartDateString
	  ,StartYear
	  ,StartMonth
	  ,StartDay
	  ,CAST(StartDate AS date) AS StartDate
	  ,VisitCompletionStatus
	  ,SubjectEligibilityMonitorReview
	  ,IneligibleReasonMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,EligibilityExceptionReason
	  ,VisitPaid
	  ,PIIRequirementMet
	  ,INELIGIBLE
	  ,INELIGIBLE_EXCEPTION
	  ,BiologicNaive

INTO #DRUGINFO 
FROM
(SELECT *,
		CASE WHEN StartDateString='UNK-UNK-UNK' THEN ''
		WHEN ISNULL(StartDateString, '')='' THEN ''
		ELSE CONCAT(StartYear, '-', StartMonth, '-', StartDay) 
		END AS StartDate
FROM
(
SELECT ENR.vID
      ,ENR.SiteID
	  ,ENR.SiteStatus
	  ,ENR.SubjectID
	  ,ENR.ProviderID
	  ,ENR.VisitType
	  ,ENR.EnrollmentDate
	  ,ENR.EligibilityVersion
	  ,ENR.YOB
	  ,ENR.AgeAtVisit
	  ,ENR.Diagnosis
	  --,DRUG.GX__ST_DT AS StartDateString
	  ,MDS.DRUG_CLASS123_USE_EN
  	  ,DRUG.NOT_DRUG_CLASS123_DEC AS DrugClass
	  ,DRUG.P__G__10_USE_DEC AS BiologicName
	  ,DRUG.P__G__20_USE_DEC AS IstName
	  ,DRUG.P__G__30_USE_DEC AS MesalamineName
	  ,COALESCE(P__G__10_USE_DEC, P__G__20_USE_DEC, P__G__30_USE_DEC) AS DrugName
	  ,DRUG.GX___C__OTH_NAME_TXT AS OtherDrugSpecify
	  ,DRUG.GX__USE_NONE AS NoPriorUse
	  ,DRUG.GX__USE_PAST AS PastUse
	  ,DRUG.GX__USE_CUR AS CurrentUse
	  ,GX__RX_TDY_DEC AS ChangesAtVisit
	  ,CASE WHEN GX__RX_TDY_DEC IN ('N/A - no longer in use', 'Stop') THEN 'Past use'
	   WHEN GX__RX_TDY_DEC IN ('No changes (current use)', 'Modify') THEN 'Current'
	   WHEN GX__RX_TDY_DEC='Start' THEN 'Prescribed'
	   ELSE GX__RX_TDY_DEC
	   END AS ChangesToday
	  ,DRUG.GX__DOSE_RCVD_TDY_DEC AS FirstDoseAdminTodayVisit
	  ,DRUG.GX__ST_DT AS StartDateString
	  ,CASE WHEN LEFT(RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)),	
	   CHARINDEX('-', RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)))-1)='UNK' THEN '06'
	   ELSE LEFT(RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)), 
	   CHARINDEX('-', RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)))-1)
	   END AS StartMonth
	  ,RIGHT(DRUG.GX__ST_DT, 2) AS DayofMo2
	  ,CASE	WHEN ISNUMERIC(RIGHT(DRUG.GX__ST_DT, 1))=1 THEN RIGHT(DRUG.GX__ST_DT, 2)
	   WHEN ISNULL(DRUG.GX__ST_DT, '')='' THEN NULL
	   WHEN RIGHT(DRUG.GX__ST_DT, 3)='UNK' THEN '15'
	   ELSE DRUG.GX__ST_DT 
	   END AS StartDay
	  ,SUBSTRING(DRUG.GX__ST_DT, 1, 4) AS StartYear
	  ,CASE WHEN VC.VISIT_COMPLETE='X' THEN 'Complete'
	   WHEN ISNULL(VC.VISIT_COMPLETE, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletionStatus
	  ,ENR.SubjectEligibilityMonitorReview
	  ,ENR.IneligibleReasonMonitorReview
	  ,ENR.ExceptionGrantedforEligibility
	  ,ENR.EligibilityExceptionReason
	  ,ENR.VisitPaid
	  ,ENR.PIIRequirementMet
	  ,ENR.INELIGIBLE
	  ,ENR.INELIGIBLE_EXCEPTION
	  ,CASE WHEN EXISTS (SELECT NOT_DRUG_CLASS123 FROM MERGE_IBD.staging.DRUG DRUG2 WHERE DRUG2.vID=DRUG.vID AND DRUG2.SUBNUM=DRUG.SUBNUM AND NOT_DRUG_CLASS123=1) THEN 'No'
	  ELSE 'Yes'
	  END AS BiologicNaive

FROM #ENR ENR
LEFT JOIN MERGE_IBD_UAT.staging.DRUG DRUG ON ENR.vID=DRUG.vID
LEFT JOIN [MERGE_IBD_UAT].[staging].[VISIT_COMP] VC ON VC.vID=ENR.vID 
LEFT JOIN [MERGE_IBD_UAT].[staging].[MD_SUMMARY] MDS ON MDS.vID=ENR.vID
WHERE VisitType='Enrollment'  
) D
) A

--SELECT * FROM #DRUGINFO WHERE ChangesToday is null ORDER BY SiteID, SubjectID, DrugName

IF OBJECT_ID('tempdb.dbo.#MODSTARTSDT') IS NOT NULL BEGIN DROP TABLE #MODSTARTSDT END

/*Determine drug hierarchy (use status)*/

SELECT DISTINCT vID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,ProviderID
	  ,VisitType
	  ,EnrollmentDate
	  ,EligibilityVersion
	  ,YOB
	  ,AgeAtVisit
	  ,Diagnosis
	  ,StartDateString
	  ,StartYear
	  ,VisitCompletionStatus
	  ,DRUG_CLASS123_USE_EN
	  ,DrugClass
	  ,PastUse
	  ,CurrentUse
	  ,ChangesToday
	  ,NoPriorUse
	  ,DrugName
	  ,EligibleDrug
	  ,BiologicNaive
	  ,StartDate
	  ,FirstDoseAdminTodayVisit
	  ,CAST(ModPriorCurrStartDate AS date) AS ModPriorCurrStartDate
	  ,CASE WHEN ChangesToday='Prescribed' AND EligibleDrug='Yes' THEN 10
	   WHEN ChangesToday='Modify' AND EligibleDrug='Yes' THEN 20
	   WHEN ChangesToday='Current' AND EligibleDrug='Yes' THEN 30
	   WHEN ChangesToday='Prescribed' AND EligibleDrug='Needs Review' THEN 40
	   WHEN ChangesToday='Current' AND EligibleDrug='Needs Review' THEN 50
	   WHEN ChangesToday='Prescribed' AND EligibleDrug='No' THEN 60
	   WHEN ChangesToday='Current' AND EligibleDrug='No' THEN 70
	   WHEN ChangesToday='Past use' AND EligibleDrug='Yes' THEN 80
	   ELSE 99
	   END AS UseStatusOrder
	  ,CASE WHEN EligibleDrug='Yes' AND DrugClass='Biologic/biosimilar or small molecule' THEN 1
	   WHEN EligibleDrug='Yes' AND DrugClass='Immunosuppressant' THEN 5
	   WHEN EligibleDrug='Yes' AND DrugClass='Mesalamine/5-ASA' THEN 10
	   WHEN EligibleDrug='Yes' AND ISNULL(DrugClass, '')='' THEN 15
	   WHEN EligibleDrug='Needs review' AND DrugClass='Biologic/biosimilar or small molecule' THEN 20
	   WHEN EligibleDrug='Needs review' AND DrugClass='Immunosuppressant' THEN 25
	   WHEN EligibleDrug='Needs review' AND DrugClass='Mesalamine/5-ASA' THEN 30
	   WHEN EligibleDrug='Needs review' AND ISNULL(DrugClass, '')='' THEN 35
	   WHEN EligibleDrug='No' AND DrugClass='Biologic/biosimilar or small molecule' THEN 40
	   WHEN EligibleDrug='No' AND DrugClass='Immunosuppressant' THEN 45
	   WHEN EligibleDrug='No' AND DrugClass='Mesalamine/5-ASA' THEN 50
	   WHEN EligibleDrug='No' AND ISNULL(DrugClass, '')='' THEN 55
	   ELSE 99
	   END AS DrugOrder 
	  ,SubjectEligibilityMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,VisitPaid
	  ,PIIRequirementMet

INTO #MODSTARTSDT
FROM
(
SELECT vID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,ProviderID
	  ,VisitType
	  ,EnrollmentDate
	  ,EligibilityVersion
	  ,YOB
	  ,AgeAtVisit
	  ,Diagnosis
	  ,StartDateString
	  ,StartYear
	  ,DRUG_CLASS123_USE_EN
  	  ,DrugClass
	  ,CASE WHEN EXISTS (SELECT DrugName FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.DrugName=D.DrugName AND D2.StartDate<>D.StartDate) THEN 'X'
	   ELSE PastUse
	   END AS PastUse
	  ,CurrentUse
	  ,ChangesToday
	  ,NoPriorUse
	  ,CASE WHEN ISNULL(OtherDrugSpecify, '')<>'' THEN DrugName + '; ' + OtherDrugSpecify
	   ELSE DrugName
	   END AS DrugName
/*Determine medication eligibility*/
	  ,CASE WHEN UPPER(DRUGNAME) LIKE '%INVEST%' THEN 'No'
	   WHEN EnrollmentDate < '2019-01-01' THEN 'Yes'
	   WHEN DrugName IS NULL AND EnrollmentDate >= '2019-01-01' AND VisitCompletionStatus='Complete' THEN 'No'
--Check for No Prior Use and across forms for new prescribed, Past Use and across forms for visits > 3/24/2022
--Look for Rinvoq in Other Specify for Drug Class 1: Biologic/biosimilar or small molecule and determine prior use
--For visits >14Apr2023 check Crohn's diagnosis prescribed/start only (prevalent no longer eligible)
	   WHEN EnrollmentDate >= '2023-04-14' AND ISNULL(DrugName, '') IN (SELECT DrugName FROM [IBD600].[t_op_drugreference] DREF WHERE DREF.DrugName=DrugName AND DREF.Diagnosis=Diagnosis AND EnrollmentDate BETWEEN CAST(DREF.EnrollmentDateStart AS date) AND CAST(DREF.EnrollmentDateEnd AS date)) AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT DrugName FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.DrugName=D.DrugName AND D2.StartDate<>D.StartDate)) AND ((Diagnosis = 'Ulcerative colitis') OR (Diagnosis LIKE '%Crohn%' AND ChangesToday='Prescribed')) THEN 'Yes'
	   WHEN EnrollmentDate >= '2023-04-14' AND ISNULL(DrugName, '') IN (SELECT DrugName FROM [IBD600].[t_op_drugreference] DREF WHERE DREF.DrugName=DrugName AND DREF.Diagnosis=Diagnosis AND EnrollmentDate BETWEEN CAST(DREF.EnrollmentDateStart AS date) AND CAST(DREF.EnrollmentDateEnd AS date)) AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT DrugName FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.DrugName=D.DrugName AND D2.StartDate<>D.StartDate)) AND (Diagnosis LIKE '%Crohn%' AND ISNULL(ChangesToday,'')<>'Prescribed') THEN 'No'
	   WHEN EnrollmentDate >= '2022-03-25' AND UPPER(DrugName) LIKE '%OTHER%' AND DrugClass='Biologic/biosimilar or small molecule' AND (UPPER(OtherDrugSpecify) LIKE '%RINVOQ%' OR UPPER(OtherDrugSpecify) LIKE '%UPADACIT%') AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT OtherDrugSpecify FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.OtherDrugSpecify=D.OtherDrugSpecify AND D2.StartDate<>D.StartDate)) THEN 'Yes'
	   WHEN EnrollmentDate >= '2022-03-25' AND UPPER(DrugName) LIKE '%OTHER%' AND DrugClass='Biologic/biosimilar or small molecule' AND (UPPER(OtherDrugSpecify) LIKE '%RINVOQ%' OR UPPER(OtherDrugSpecify) LIKE '%UPADACIT%') AND ((NoPriorUse='' AND (CurrentUse='' AND ISNULL(PastUse, '')='X')) OR EXISTS (SELECT OtherDrugSpecify FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.OtherDrugSpecify=D.OtherDrugSpecify AND D2.StartDate<>D.StartDate)) THEN 'No'
	   WHEN EnrollmentDate >= '2019-01-01' AND DrugClass='Biologic/biosimilar or small molecule' AND (UPPER(OtherDrugSpecify) LIKE '%INFLECT%') AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT OtherDrugSpecify FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.OtherDrugSpecify=D.OtherDrugSpecify AND D2.StartDate<>D.StartDate)) THEN 'Yes'
--Look for previous use of 'Other' to determine if review needed or not eligible due to prior use
	   WHEN EnrollmentDate >= '2022-03-25' AND UPPER(DrugName) LIKE '%OTHER%' AND DrugClass='Biologic/biosimilar or small molecule' AND ((NoPriorUse='' AND (CurrentUse='' AND ISNULL(PastUse, '')='X')) OR EXISTS (SELECT OtherDrugSpecify FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.OtherDrugSpecify=D.OtherDrugSpecify AND D2.StartDate<>D.StartDate)) THEN 'No'
	   WHEN EnrollmentDate >= '2022-03-25' AND UPPER(DrugName) LIKE '%OTHER%' AND DrugClass='Biologic/biosimilar or small molecule' AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT OtherDrugSpecify FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.OtherDrugSpecify=D.OtherDrugSpecify AND D2.StartDate<>D.StartDate)) THEN 'Needs review'
--Check eligibility for drugs when not 'Other' for visits > 3/24/2022
	   WHEN EnrollmentDate >= '2022-03-25' AND ChangesToday='Past use' THEN 'No'
       WHEN EnrollmentDate >= '2022-03-25' AND ISNULL(DrugName, '') IN (SELECT DrugName FROM [IBD600].[t_op_drugreference] DREF WHERE DREF.DrugName=DrugName AND DREF.Diagnosis=Diagnosis AND EnrollmentDate BETWEEN CAST(DREF.EnrollmentDateStart AS date) AND CAST(DREF.EnrollmentDateEnd AS date)) AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT DrugName FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.DrugName=D.DrugName AND D2.StartDate<>D.StartDate)) THEN 'Yes'
	   WHEN EnrollmentDate >= '2022-03-25' AND ISNULL(DrugName, '') IN (SELECT DrugName FROM [IBD600].[t_op_drugreference] DREF WHERE DREF.DrugName=DrugName AND DREF.Diagnosis=Diagnosis AND EnrollmentDate BETWEEN CAST(DREF.EnrollmentDateStart AS date) AND CAST(DREF.EnrollmentDateEnd AS date)) AND ((NoPriorUse='' AND (CurrentUse='X' AND ISNULL(PastUse, '')='X')) AND EXISTS (SELECT DrugName FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.DrugName=D.DrugName AND D2.StartDate<>D.StartDate)) THEN 'No'
--Check eligibility (biologic/small molecule only) for drugs from 1/1/2019-3/24/2022
	   WHEN EnrollmentDate >= '2019-01-01' AND ChangesToday='Past use' THEN 'No'
	   WHEN EnrollmentDate >= '2019-01-01' AND DrugClass='Biologic/biosimilar or small molecule' AND (UPPER(OtherDrugSpecify) LIKE '%RENFLEX%') AND ((NoPriorUse='X' OR (CurrentUse='X' AND ISNULL(PastUse, '')='')) AND NOT EXISTS (SELECT OtherDrugSpecify FROM #DRUGINFO D2 WHERE D2.vID=D.VID AND D2.OtherDrugSpecify=D.OtherDrugSpecify AND D2.StartDate<>D.StartDate)) THEN 'Needs review'
	   WHEN EnrollmentDate >= '2019-01-01' AND ISNULL(D.DrugName, '') IN (SELECT DrugName FROM [IBD600].[t_op_drugreference] DREF WHERE DREF.DrugName=D.DrugName AND DREF.Diagnosis=D.Diagnosis AND D.EnrollmentDate BETWEEN CAST(DREF.EnrollmentDateStart AS date) AND CAST(DREF.EnrollmentDateEnd AS date)) THEN 'Yes'
	   WHEN EnrollmentDate >= '2019-01-01' AND ISNULL(DrugName, '') NOT IN (SELECT DrugName FROM [IBD600].[t_op_drugreference] DREF WHERE DREF.DrugName=DrugName AND DREF.Diagnosis=Diagnosis AND EnrollmentDate BETWEEN CAST(DREF.EnrollmentDateStart AS date) AND CAST(DREF.EnrollmentDateEnd AS date)) THEN 'No'
	   ELSE 'Not calculated'
	   END AS EligibleDrug
	  ,StartDate
	  ,FirstDoseAdminTodayVisit
	  ,CASE WHEN StartDate='' THEN CAST(NULL AS date)
	   WHEN ChangesToday='Prescribed' AND FirstDoseAdminTodayVisit='Yes' THEN EnrollmentDate
	   ELSE StartDate
	   END AS ModPriorCurrStartDate
	  ,VisitCompletionStatus
	  ,SubjectEligibilityMonitorReview
	  ,IneligibleReasonMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,EligibilityExceptionReason
	  ,VisitPaid
	  ,PIIRequirementMet
	  ,INELIGIBLE
	  ,INELIGIBLE_EXCEPTION
	  ,BiologicNaive
FROM #DRUGINFO D
) D1

--SELECT * FROM #MODSTARTSDT WHERE UPPER(DrugName) LIKE '%OTHER%' ORDER BY SiteID, SubjectID, DrugName


IF OBJECT_ID('tempdb..#ELIG') IS NOT NULL BEGIN DROP TABLE #ELIG END

/*Determine patient eligibility*/

SELECT ROWNUM
      ,vID
	  ,VisitType
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,ProviderID
	  ,EnrollmentDate
	  ,EligibilityVersion
	  ,YOB
	  ,AgeAtVisit 
	  ,Diagnosis
	  ,DRUG_CLASS123_USE_EN
	  ,DrugClass
	  ,DrugName
	  ,EligibleDrug
	  ,PastUse
	  ,CurrentUse
	  ,ChangesToday
	  ,NoPriorUse
	  ,FirstDoseAdminTodayVisit
	  ,StartDate
	  ,ModPriorCurrStartDate
	  ,MonthsSinceDrugStart
	  ,InitiatedWithin12MoEnroll
	  ,VisitCompletionStatus
	  ,UseStatusOrder
	  ,SubjectEligibilityMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,VisitPaid
--Determine RegistryEnrollmentStatus after manual review
	  ,CASE WHEN EligibilityStatus='Eligible' AND ReviewOutcome='Not eligible' THEN 'Not eligible'
	   WHEN EligibilityStatus='Not eligible' AND ReviewOutcome='Not eligible -Exception granted' THEN 'Eligible - Review decision'
	   WHEN  EligibilityStatus='Not eligible' AND ReviewOutcome='Not eligible' THEN 'Not eligible - Confirmed'
	   WHEN EligibilityStatus='Not eligible' AND ReviewOutcome='Eligible' THEN 'Eligible - Review decision'
	   WHEN EligibilityStatus='Eligible' AND ReviewOutcome='Eligible' THEN 'Eligible'
	   WHEN EligibilityStatus='Eligible' AND ReviewOutcome='Not eligible -Exception granted' THEN 'Eligible - Review decision'
	   WHEN EligibilityStatus='Needs review' AND ReviewOutcome='Under review (outcome TBD)' THEN 'Needs review'
	   WHEN EligibilityStatus='Needs review' AND ReviewOutcome='Eligible' THEN 'Eligible'
	   WHEN EligibilityStatus='Needs review' AND ReviewOutcome='Not eligible' THEN 'Not eligible'
	   WHEN EligibilityStatus='Needs review' AND ReviewOutcome='Not eligible -Exception granted' THEN 'Eligible - Review decision'
	   WHEN ISNULL(ReviewOutcome, '')='' THEN EligibilityStatus
	   ELSE EligibilityStatus
	   END AS EligibilityStatus
	  ,ReviewOutcome
	  ,PIIRequirementMet
	  ,BiologicNaive

INTO #ELIG	
FROM
(
SELECT  ROW_NUMBER() OVER (PARTITION BY vID, MSD.SiteID, SubjectID ORDER BY vID, SiteID, SubjectID, EnrollmentDate, UseStatusOrder, DrugOrder, DrugName, ModPriorCurrStartDate) AS ROWNUM
      ,MSD.vID
	  ,MSD.VisitType
      ,MSD.SiteID
	  ,MSD.SiteStatus
	  ,MSD.SubjectID
	  ,MSD.ProviderID
	  ,EnrollmentDate
	  ,EligibilityVersion
--Determine EnrollmentEligiblityStatus from all eligibility criteria gathered in earlier tables
	  ,CASE WHEN EnrollmentDate > '2019-01-19' AND Diagnosis='Other indeterminate colitis' THEN 'Not eligible'
	   WHEN MSD.EnrollmentDate >= '2022-03-25' AND UPPER(MSD.DrugName) LIKE '%XELJANZ%' AND PastUse='X' THEN 'Needs review'
	   WHEN MSD.EnrollmentDate >= '2022-03-25' AND MSD.DrugClass='Immunosuppressant' AND MSD.BiologicNaive='No' THEN 'Not eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND MSD.DRUG_CLASS123_USE_EN IS NULL AND VisitCompletionStatus='Incomplete' THEN 'Needs review'
       WHEN MSD.EnrollmentDate >= '2019-01-01' AND ISNULL(MSD.DRUG_CLASS123_USE_EN, '')<>0 AND DrugName IS NULL AND VisitCompletionStatus='Incomplete' THEN 'Needs review'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND EligibleDrug='Needs review' THEN 'Needs review'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND EligibleDrug='No' THEN 'Not eligible'
	   WHEN MSD.EnrollmentDate < '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '')<>'' THEN 'Eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND ChangesToday='Prescribed' AND NoPriorUse='X' THEN 'Eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND ChangesToday='Prescribed' AND PastUse='X' THEN 'Not eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND CurrentUse='X' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))<=13 THEN 'Eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND CurrentUse='X' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))>13 THEN 'Not eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND (AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis')) AND EligibleDrug='Yes' AND ChangesToday='Prescribed' AND ISNULL(PastUse, '')='' AND ISNULL(NoPriorUse, '')='' AND ISNULL(CurrentUse, '')='' THEN 'Eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') 
			AND ISNULL(PastUse, '')='' AND (ISNULL(MSD.StartDate, '')='') THEN 'Needs review'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') 
			AND ISNULL(PastUse, '')='' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))<=13 THEN 'Eligible'
	  WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') 
			AND ISNULL(PastUse, '')='' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))>13 THEN 'Not eligible'
	  WHEN MSD.EnrollmentDate >= '2019-01-01' AND AgeAtVisit>=18 AND ISNULL(Diagnosis, '') NOT IN ('','Other indeterminate colitis') AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') AND ISNULL(PastUse, '')='X' THEN 'Not eligible'
	   WHEN MSD.EnrollmentDate >= '2019-01-01' AND (EligibleDrug='No' OR AgeAtVisit<18 OR ISNULL(Diagnosis, '') IN ('','Other indeterminate colitis') OR ISNULL(ChangesToday, '')='Past Use') THEN 'Not eligible'
	   ELSE ''
	   END AS EligibilityStatus
	  ,YOB
	  ,AgeAtVisit
	  ,Diagnosis
  	  ,MSD.DRUG_CLASS123_USE_EN
	  ,MSD.DrugClass
	  ,DrugName
	  ,MSD.EligibleDrug
	  ,MSD.BiologicNaive
	  ,MSD.PastUse
	  ,MSD.CurrentUse
	  ,MSD.ChangesToday
	  ,NoPriorUse
	  ,MSD.FirstDoseAdminTodayVisit
	  ,MSD.StartDate
	  ,ModPriorCurrStartDate
	  ,CASE WHEN ISNULL(MSD.ModPriorCurrStartDate, '')<>'' THEN DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))
	   END AS MonthsSinceDrugStart
	  ,CASE WHEN ChangesToday IN ('Current', 'Modify') AND (DATEDIFF(D, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))/30)<=12 THEN 'Yes'
	   WHEN ChangesToday IN ('Current', 'Modify') AND DATEDIFF(D, CAST(MSD.ModPriorCurrStartDate AS date), CAST(EnrollmentDate AS date))/30>13 THEN 'No'
	   WHEN ChangesToday IN ('Prescribed', 'Past use') THEN 'n/a'
	   ELSE ''
	   END AS InitiatedWithin12MoEnroll
	  ,VisitCompletionStatus
	  ,UseStatusOrder
	  ,SubjectEligibilityMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,CASE WHEN SubjectEligibilityMonitorReview='Yes' THEN 'Eligible'
	   WHEN SubjectEligibilityMonitorReview='No' AND ExceptionGrantedforEligibility='No' THEN 'Not eligible'
	   WHEN SubjectEligibilityMonitorReview='No' AND ExceptionGrantedforEligibility='Yes' THEN 'Not eligible -Exception granted'
	   WHEN SubjectEligibilityMonitorReview='Under review (outcome TBD)' THEN 'Under review (outcome TBD)'
	   END AS ReviewOutcome
	  ,VisitPaid
	  ,PIIRequirementMet
    
FROM #MODSTARTSDT MSD
) E

--SELECT * FROM #ELIG WHERE EnrollmentDate >= '2019-01-01' ORDER BY SiteID, SubjectID, ROWNUM

TRUNCATE TABLE [Reporting].[IBD600].[t_op_EER]

INSERT INTO [IBD600].[t_op_EER] (
       [ROWNUM]
      ,[vID]	  
      ,[VisitType]
      ,[SiteID]
      ,[SiteStatus]
      ,[SubjectID]
      ,[ProviderID]
      ,[EnrollmentDate]
      ,[EligibilityVersion]
      ,[YOB]
      ,[AgeAtVisit]
      ,[Diagnosis]
      ,[DRUG_CLASS123_USE_EN]
      ,[DrugClass]
      ,[DrugName]
      ,[EligibleDrug]
      ,[PastUse]
      ,[CurrentUse]
	  ,[ChangesToday]
      ,[NoPriorUse]
      ,[FirstDoseAdminTodayVisit]
      ,[StartDate]
      ,[ModPriorCurrStartDate]
      ,[MonthsSinceDrugStart]
      ,[InitiatedWithin12MoEnroll]
	  ,[BiologicNaive]
      ,[EligibilityStatus]
      ,[ReviewOutcome]
	  ,[VisitCompletionStatus]
)


SELECT [ROWNUM]
      ,[vID]	  
      ,[VisitType]
      ,[SiteID]
      ,[SiteStatus]
      ,[SubjectID]
      ,[ProviderID]
      ,[EnrollmentDate]
      ,[EligibilityVersion]
      ,[YOB]
      ,[AgeAtVisit]
      ,[Diagnosis]
      ,[DRUG_CLASS123_USE_EN]
      ,[DrugClass]
      ,CASE WHEN ISNULL([DrugName], '')='' AND VisitCompletionStatus='Incomplete' THEN 'Pending'
	   WHEN ISNULL([DrugName], '')='' and VisitCompletionStatus = 'Complete' THEN 'No medication'
	   ELSE [DrugName]
	   END AS [DrugName]
      ,[EligibleDrug]
      ,[PastUse]
      ,[CurrentUse]
	  ,[ChangesToday]
      ,[NoPriorUse]
      ,[FirstDoseAdminTodayVisit]
      ,[StartDate]
      ,[ModPriorCurrStartDate]
      ,[MonthsSinceDrugStart]
      ,[InitiatedWithin12MoEnroll]
	  ,CASE WHEN DrugClass='Immunosuppressant' THEN [BiologicNaive]
	   ELSE 'n/a'
	   END AS [BiologicNaive]
	  ,[EligibilityStatus]
      ,ISNULL([ReviewOutcome], 'NULL') AS [ReviewOutcome]
	  ,[VisitCompletionStatus]
FROM #ELIG
WHERE ROWNUM=1

--SELECT * FROM [Reporting].[IBD600].[t_uat_op_EER] ORDER BY SiteID, SubjectID, EnrollmentDate
--EnrollmentDate >= '2021-06-01' ORDER BY SiteID, SubjectID
--SELECT DISTINCT [ChangesToday] FROM [Reporting].[IBD600].[t_op_EER]


END

GO
