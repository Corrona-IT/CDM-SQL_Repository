USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_CAT_ENRFU]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: 10/15/2019
-- Description:	Procedure for Drugs at Enrollment with Hierarchy for DOI
--              Does not include Reimbursement Test Site 9997
-- ===========================================================================



CREATE PROCEDURE [PSA400].[usp_op_CAT_ENRFU] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;

/*
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [PSA400].[t_op_Followup_Drugs](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](20) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitOrder] [int] NULL,
	[VisitDate] [date] NULL,
	[NextVisit] [int] NULL,
	[PageDescription] [nvarchar](250) NULL,
	[PageSequence] [int] NULL,
	[PageStatus] [nvarchar](250) NULL,
	[Cohort] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[TreatmentStartYear] [int] NULL,
	[TreatmentStartMonth] [int] NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[ChangeSinceLastVisit] [nvarchar](100) NULL,
	[CurrentDose] [nvarchar](150) NULL,
	[PastDose] [nvarchar](150) NULL,
	[FirstTimeUse] [nvarchar](10) NULL
) ON [PRIMARY]
GO




SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [PSA400].[t_op_DOI_Enroll_FirstFU](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](20) NULL,
	[SubjectID] [bigint] NOT NULL,
	[NextVisitDrugOrder] [int] NULL,
	[VisitOrder] [int] NULL,
	[NextVisit] [int] NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL,
	[YearofBirth] [int] NULL,
	[YearOfDiagnosis] [int] NULL,
	[Diagnosis] [nvarchar](250) NULL,
	[EligibilityVersion] [nvarchar](25) NULL,
	[DrugHierarchy] [int] NULL,
	[PageDescription] [nvarchar](250) NULL,
	[PageStatus] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[TreatmentStartYear] [int] NULL,
	[TreatmentStartMonth] [int] NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[ChangeSinceLastVisit] [nvarchar](100) NULL,
	[CurrentDose] [varchar](75) NULL,
	[PastDose] [varchar](75) NULL,
	[DrugOfInterest] [nvarchar](350) NULL,
	[AdditionalDOI] [nvarchar](1000) NULL,
	[DOIInitiationStatus] [nvarchar](150) NULL,
	[SubscriberDOI] [nvarchar](50) NULL,
	[DrugReqSatisfied] [nvarchar](50) NULL,
	[FirstTimeUse] [nvarchar](10) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[Cohort] [nvarchar](250) NULL,
	[RegistryEnrollmentStatus] [nvarchar](250) NULL,
	[ReviewOutcome] [nvarchar](250) NULL,
	[DOIFUMatch] [nvarchar](100) NULL,
	[NextVisitDrugHierarchy] [int] NULL,
	[NextVisitTreatmentName] [nvarchar](350) NULL,
	[NextVisitDate] [date] NULL,
	[NextVisitChanges] [nvarchar](50) NULL,
	[NextVisitStatus] [nvarchar](150) NULL,
	[InitiationStatus] [nvarchar](250) NULL,
	[ConfirmationVisitDate] [date] NULL,
	[SubscriberDOIAccrual] [nvarchar](25) NULL
) ON [PRIMARY]
GO

*/



/*****Bring in Exit Visits*****/

IF OBJECT_ID('tempdb.dbo.#DISCONTINUE') IS NOT NULL BEGIN DROP TABLE #DISCONTINUE END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,ExitDate
	  ,PageStatus

INTO #DISCONTINUE
FROM
(
---V1.2
SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,DISCONTINUE_DATE AS ExitDate
	  ,STATUSID_DEC AS PageStatus
FROM [MERGE_SPA].[staging].[EX_01]

UNION

---V2.0
SELECT SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,DISCONTINUE_DATE AS ExitDate
	  ,STATUSID_DEC AS PageStatus
FROM [MERGE_SPA].[staging].[EXIT_01]
) EV



/*****Bring in Enrollment Information to Match W/FU Data*****/

IF OBJECT_ID('tempdb.dbo.#FU1') IS NOT NULL BEGIN DROP TABLE #FU1 END;

SELECT DISTINCT VisitID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,YearOfBirth
	  ,YearOfDiagnosis
	  ,Diagnosis
	  ,EligibilityVersion
	  ,DrugHierarchy
	  ,PageDescription
	  ,TreatmentName
	  ,DrugOfInterest
	  ,PageStatus
	  ,DOIInitiationStatus
	  ,SubscriberDOI
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,RegistryEnrollmentStatus
	  ,ReviewOutcome

INTO #FU1

FROM [Reporting].[PSA400].[t_op_CAT_Enrollment] 
WHERE DrugHierarchy=1
--AND EligibilityVersion<>'99'

--SELECT * FROM #F1 ORDER BY SiteID, SubjectID


/**********Get Cohort and Biologic and Biosimilar Treatment at FU**********/

/*****Cohorts for Treatments from V.2 DRUG table at Follow-up*****/

IF OBJECT_ID('tempdb.dbo.#FU2') IS NOT NULL BEGIN DROP TABLE #FU2 END;

SELECT DISTINCT [CorronaRegistryID]
      ,[Drug] AS TreatmentName
      ,CASE WHEN [Cohort]='Otezla' THEN 'IL-17, JAKi or PDE4 Inhibitor'
	   WHEN [Cohort]='IL-17 or JAKi' THEN 'IL-17, JAKi or PDE4 Inhibitor'
	   WHEN [Drug] IN ('guselkumab (Tremfya)', 'anakinra (Kineret)') THEN 'Comparator Biologic'
	   WHEN [Cohort]='Comparator Biologics' THEN 'Comparator Biologic'
	   ELSE [Cohort]
	   END AS [Cohort]
INTO #FU2
FROM [Reimbursement].[Reference].[t_DrugHierarchy]

--SELECT * FROM #FU2 ORDER BY [TreatmentName]


/*****Create Visit Order to find next FU visit*****/

IF OBJECT_ID('tempdb.dbo.#VisitOrder') IS NOT NULL BEGIN DROP TABLE #VisitOrder END;

SELECT DISTINCT vID AS VisitID
      ,ROW_NUMBER() OVER(PARTITION BY [SITENUM], [SUBNUM] ORDER BY [SITENUM], [SUBNUM], [VISITDATE]) AS VisitOrder
	  ,SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,'Follow up' AS VisitType
	  ,V.VISNAME
	  ,V.PAGENAME
	  ,VISITDATE AS VisitDate

INTO #VisitOrder

FROM [MERGE_SPA].[staging].[VS_01] V
WHERE V.SITENUM NOT IN (99997, 99998, 99999)
AND V.PAGENAME='Date of Visit'
AND V.VISNAME LIKE '%Follow%' 

--SELECT * FROM #VisitOrder ORDER BY SiteID, SubjectID, VisitDate



/***********Treatments from DRUG table at Follow-up***********/

IF OBJECT_ID('tempdb.dbo.#FU3') IS NOT NULL BEGIN DROP TABLE #FU3 END;

SELECT DISTINCT D.vID AS VisitID
      ,D.SITENUM AS SiteID
	  ,D.SUBNUM AS SubjectID
	  ,VO.VisitOrder
	  ,'Follow up' AS VisitType
	  ,CAST(VO.VisitDate AS date) AS VisitDate
	  ,D.PAGENAME AS PageDescription
	  ,D.PAGESEQ AS PageSequence
	  ,D.STATUSID_DEC AS PageStatus
	  ,CASE WHEN D.DRUG_NAME_DEC='Investigational Drug' THEN 'Investigational drug'
	   WHEN D.DRUG_NAME_DEC='apremilast (Otezla)' AND VO.VisitDate<'2021-03-16' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN D.DRUG_NAME_DEC='apremilast (Otezla)' AND VO.VisitDate>='2021-03-16' THEN 'Comparator Biologic'
	   WHEN FU2.Cohort='IL-17 or JAKi' AND VO.VisitDate<'2021-03-16' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN FU2.Cohort='IL-17 or JAKi' AND VO.VisitDate>='2021-03-16' THEN 'IL-17, JAK or IL-23 Inhibitor'
	   WHEN D.DRUG_NAME_DEC='prednisone' THEN 'csDMARD'
	   WHEN D.DRUG_NAME_DEC ='anakinra (Kineret)' THEN 'Comparator Biologic'
	   WHEN D.DRUG_NAME_DEC='guselkumab (Tremfya)' AND VO.VisitDate<'2021-03-16' THEN 'Comparator Biologic'
	   WHEN D.DRUG_NAME_DEC='guselkumab (Tremfya)' AND VO.VisitDate>='2021-03-16' THEN 'IL-17, JAK or IL-23 Inhibitor'
	   WHEN ISNULL(D.DRUG_NAME_DEC, '')='' THEN 'n/a'
	   ELSE FU2.Cohort
	   END AS Cohort
	  ,CASE WHEN ISNULL(D.DRUG_NAME_OTHER, '')<>'' THEN D.DRUG_NAME_DEC + ': ' + D.DRUG_NAME_OTHER
	   WHEN D.PAGENAME='Conventional DMARDs' THEN 'csDMARD' 
	   ELSE D.DRUG_NAME_DEC
	   END AS TreatmentName
	  ,D.DRUG_RX_TODAY_DEC AS ChangesToday
	  ,D.DRUG_1_LV_DT_YR AS TreatmentStartYear
	  ,D.DRUG_1_LV_DT_MO AS TreatmentStartMonth

	  ,CASE WHEN ISNULL(D.DRUG_1_LV_DT_MO, '')='' AND ISNULL(D.DRUG_1_LV_DT_YR, '')<>'' AND LEN(D.DRUG_1_LV_DT_YR)=4 THEN (CAST(D.DRUG_1_LV_DT_YR AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(D.DRUG_1_LV_DT_MO, '')<>'' AND ISNULL(D.DRUG_1_LV_DT_YR, '')<>'' AND LEN(D.DRUG_1_LV_DT_YR)=4 THEN (CAST(D.DRUG_1_LV_DT_YR AS nvarchar) + '-' + FORMAT(D.DRUG_1_LV_DT_MO, '00') + '-' + '15')
	   ELSE CAST(NULL AS date)
	   END AS TreatmentStartDate
	  ,D.DRUG_2_LV_DT_YR AS TreatmentStopYear
	  ,D.DRUG_2_LV_DT_MO AS TreatmentStopMonth

	  ,CASE WHEN D.DRUG_0_LV='X' THEN 'No changes'
	   WHEN D.DRUG_1_LV='X' AND ISNULL(D.DRUG_2_LV, '')='' THEN 'Started'
	   WHEN D.DRUG_2_LV='X' AND ISNULL(D.DRUG_1_LV, '')='' THEN 'Stopped'
	   WHEN D.DRUG_1_LV='X' AND D.DRUG_2_LV='X' THEN 'Started and stopped'
	   WHEN D.DRUG_3_LV='X' THEN 'Modified'
	   ELSE ''
	   END AS ChangeSinceLastVisit

	  ,CASE WHEN ISNULL(D.DRUG_DOSE_DEC, '')='' THEN ''
	   ELSE CAST(D.DRUG_DOSE_DEC AS nvarchar) 
	   END AS CurrentDose

	  ,CASE WHEN ISNULL(D.DRUG_PAST_DOSE_DEC, '')='' THEN ''
	   ELSE CAST(D.DRUG_PAST_DOSE_DEC AS nvarchar)
	   END AS PastDose

INTO #FU3
FROM [MERGE_SPA].[staging].[DRUG] D
LEFT JOIN #VisitOrder VO ON VO.VisitID=D.vID
LEFT JOIN #FU2 FU2 ON FU2.TreatmentName=D.DRUG_NAME_DEC
WHERE ISNULL(D.DRUG_NAME_DEC, '')<>''
AND D.VISNAME LIKE '%Follow%'
AND D.PAGENAME IN ('Biologics', 'Biosimilars', 'Conventional DMARDs')
AND D.SITENUM NOT IN (99997, 99998, 99999)

--SELECT * FROM #FU3 WHERE SubjectID=3093010003 ORDER BY SiteID, SubjectID, VisitDate, TreatmentName



/***********Treatments from V1.2 Follow-up***********/

IF OBJECT_ID('tempdb.dbo.#FU4') IS NOT NULL BEGIN DROP TABLE #FU4 END;

SELECT DISTINCT DV12.VisitID
      ,DV12.SiteID
	  ,DV12.SubjectID
	  ,VO.VisitOrder
	  ,'Follow up' AS VisitType
	  ,VO.VisitDate
	  ,DV12.PageDescription
	  ,NULL AS PageSequence
	  ,DV12.PageStatus
	  ,DV12.Cohort
	  ,DV12.TreatmentName
	  ,DV12.ChangesToday
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,CASE WHEN ISNULL(TreatmentStartMonth, '')='' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(TreatmentStartMonth, '')<>'' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE CAST(NULL as date) 
	   END AS TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,'' AS ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,'' AS FirstTimeUse

INTO #FU4
FROM [PSA400].[v_op_v12_Drugs] DV12
LEFT JOIN #VisitOrder VO ON VO.VisitID=DV12.VisitID
WHERE DV12.VisitType LIKE '%Follow%'

--SELECT * FROM #FU4 ORDER BY SiteID, SubjectID, VisitDate

TRUNCATE TABLE [Reporting].[PSA400].[t_op_Followup_Drugs];

INSERT INTO [Reporting].[PSA400].[t_op_Followup_Drugs]

/*****All Drugs at Follow Up*****/

SELECT DISTINCT VisitID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitOrder
	  ,VisitDate
	  ,VisitOrder+1 AS NextVisit
	  ,PageDescription
	  ,PageSequence
	  ,PageStatus
	  ,Cohort
	  ,TreatmentName
	  ,ChangesToday
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,FirstTimeUse

FROM
(
SELECT VisitID
      ,FU3.SiteID
      ,CASE WHEN S.ACTIVE='t' THEN 'Active'
	   WHEN S.ACTIVE='f' THEN 'Inactive'
	   ELSE ''
	   END AS SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitOrder
	  ,VisitDate
	  ,VisitOrder+1 AS NextVisit
	  ,PageDescription
	  ,PageSequence
	  ,PageStatus
	  ,Cohort
	  ,TreatmentName
	  ,ChangesToday
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,'' AS FirstTimeUse
FROM #FU3 FU3
LEFT JOIN [MERGE_SPA].[dbo].[DAT_SITES] S ON S.SITENUM=FU3.SiteID

UNION

SELECT VisitID
      ,FU4.SiteID
      ,CASE WHEN S.ACTIVE='t' THEN 'Active'
	   WHEN S.ACTIVE='f' THEN 'Inactive'
	   ELSE ''
	   END AS SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitOrder
	  ,VisitDate
	  ,VisitOrder+1 AS NextVisit
	  ,PageDescription
	  ,PageSequence
	  ,PageStatus
	  ,Cohort
	  ,TreatmentName
	  ,ChangesToday
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,'' AS FirstTimeUse
FROM #FU4 FU4
LEFT JOIN [MERGE_SPA].[dbo].[DAT_SITES] S ON S.SITENUM=FU4.SiteID
) FUU

--SELECT * FROM [Reporting].[PSA400].[t_op_Followup_Drugs] ORDER BY SiteID, SubjectID, VisitDate, VisitOrder, PageDescription 


/*****Get just enrollments with drug hierarchy of 1 and Treatment prescribed at visit, and first FU visit after*****/

IF OBJECT_ID('tempdb.dbo.#EFFU') IS NOT NULL BEGIN DROP TABLE #EFFU END;

SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, NextVisitDrugHierarchy, NextVisitTreatmentName) AS NextVisitDrugOrder
      ,VisitID
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,YearofBirth
	  ,YearOfDiagnosis
	  ,Diagnosis
	  ,EligibilityVersion
	  ,DrugHierarchy
	  ,PageDescription
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CAST(CurrentDose AS nvarchar(50)) AS CurrentDose
	  ,CAST(PastDose AS nvarchar(50)) AS PastDose
	  ,DrugOfInterest
	  ,AdditionalDOI
	  ,PageStatus
	  ,DOIInitiationStatus
	  ,SubscriberDOI
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,INELIGIBLE_DEC
	  ,INELIGIBLE_EXCEPTION_DEC
	  ,RegistryEnrollmentStatus
	  ,ReviewOutcome
	  ,DOIFUMatch
	  ,NextVisitDrugHierarchy
	  ,NextVisitTreatmentName
	  ,NextVisitDate
	  ,NextVisitChanges
	  ,VisitOrder
	  ,NextVisit
	  ,CAST(NextVisitCurrentDose AS nvarchar(50)) AS NextVisitCurrentDose
	  ,CAST(NextVisitPastDose AS nvarchar(50)) AS NextVisitPastDose
	  ,NextVisitStartYear
	  ,NextVisitStartMonth
	  ,NextVisitStopYear
	  ,NextVisitStopMonth
	  ,NextVisitStatus
	  ,ExitDate

INTO #EFFU

FROM
(
SELECT DISTINCT ES.[VisitID]
      ,ES.[SiteID]
      ,ES.[SiteStatus]
      ,ES.[SubjectID]
      ,ES.[VisitType]
      ,ES.[VisitDate]
      ,ES.[ProviderID]
      ,ES.[YearofBirth]
      ,ES.[YearOfDiagnosis]
      ,ES.[Diagnosis]
      ,ES.[EligibilityVersion]
      ,ES.[DrugHierarchy]
      ,ES.[PageDescription]
      ,ES.[TreatmentName]
      ,ES.[TreatmentStartYear]
      ,ES.[TreatmentStartMonth]
	  ,ES.[TreatmentStartDate]
      ,ES.[TreatmentStopYear]
      ,ES.[TreatmentStopMonth]
      ,CAST(ES.[CurrentDose] AS nvarchar(50)) AS CurrentDose
      ,CAST(ES.[PastDose] AS nvarchar(50)) AS PastDose
      ,ES.[DrugOfInterest]
	  ,ES.[AdditionalDOI]
      ,ES.[PageStatus]
      ,ES.[DOIInitiationStatus]
      ,ES.[SubscriberDOI]
      ,ES.[DrugReqSatisfied]
      ,ES.[FirstTimeUse]
      ,ES.[ChangesToday]
      ,ES.[Cohort]
      ,ES.[INELIGIBLE_DEC]
      ,ES.[INELIGIBLE_EXCEPTION_DEC]
      ,ES.[RegistryEnrollmentStatus]
      ,ES.[ReviewOutcome]

	  /***First FU***/
	  
	  ,CASE WHEN ES.DrugOfInterest=FFU.TreatmentName THEN FFU.TreatmentName
	   WHEN FFU.TreatmentName='No treatment' THEN 'no match'
	   WHEN ES.DrugOfInterest<>FFU.TreatmentName THEN 'no match'
	   ELSE ''
	   END AS DOIFUMatch

	 ,CASE WHEN ES.DrugOfInterest=FFU.TreatmentName THEN 10
	  WHEN ES.DrugOfInterest<>FFU.TreatmentName AND FFU.ChangesToday='Start' THEN 20
	  WHEN ES.DrugOfInterest<>FFU.TreatmentName AND FFU.CurrentDose<>'' THEN 30
	  WHEN ES.DrugOfInterest<>FFU.TreatmentName AND ISNULL(FFU.PastDose, '')<>'' THEN 50
	  WHEN ISNULL(FFU.TreatmentName, '')='' THEN 80
	  ELSE 90
	  END AS NextVisitDrugHierarchy

	 ,FFU.TreatmentName AS NextVisitTreatmentName
	 ,FFU.VisitDate AS NextVisitDate
	 ,FFU.ChangesToday AS NextVisitChanges
	 ,FFU.VisitOrder
	 ,FFU.NextVisit
	 ,CASE WHEN ISNULL(FFU.CurrentDose, '')='' THEN ''
	  ELSE CAST(FFU.CurrentDose AS nvarchar(50)) 
	  END AS NextVisitCurrentDose
	 ,CASE WHEN ISNULL(FFU.PastDose, '')='' THEN ''
	  ELSE CAST(FFU.PastDose AS nvarchar(50)) 
	  END AS NextVisitPastDose
	 ,FFU.TreatmentStartYear AS NextVisitStartYear
	 ,FFU.TreatmentStartMonth AS NextVisitStartMonth
	 ,FFU.TreatmentStartDate AS NextVisitStartDate
	 ,FFU.TreatmentStopYear AS NextVisitStopYear
	 ,FFU.TreatmentStopMonth AS NextVisitStopMonth
	 ,FFU.ChangeSinceLastVisit

	 ,CASE WHEN ES.DrugOfInterest=FFU.TreatmentName THEN 'match at next visit'
	  WHEN ES.DrugOfInterest<>FFU.TreatmentName AND ISNULL(FFU.TreatmentName, '')<>'' THEN 'no match at next visit'
	  WHEN ES.DrugOfInterest<>FFU.TreatmentName AND FFU.TreatmentName='No treatment' THEN 'no match at next visit'
	  WHEN ISNULL(FFU.VisitOrder, '')='' THEN 'no next visit'
	  WHEN FFU.PageStatus='no data' THEN 'no data'
	  ELSE ''
	  END AS NextVisitStatus

	 ,DISCONTINUE.ExitDate AS ExitDate

FROM [PSA400].[t_op_CAT_Enrollment] ES
LEFT JOIN [PSA400].[t_op_Followup_Drugs] FFU on FFU.SiteID=ES.SiteID AND FFU.SubjectID=ES.SubjectID AND FFU.VisitOrder=1 
LEFT JOIN #DISCONTINUE DISCONTINUE ON DISCONTINUE.SiteID=ES.SiteID AND DISCONTINUE.SubjectID=ES.SubjectID
WHERE ES.DrugHierarchy=1 AND ES.DOIInitiationStatus='prescribed at visit' 

) A

--SELECT * FROM #EFFU ORDER BY SiteID, SubjectID, NextVisitDrugOrder


/*****Enrollment and drug that matched or showing no match, other calculations*****/
/****************THIS TABLE POPULATES THE PSA CAT REPORT!!!************************/


TRUNCATE TABLE [Reporting].[PSA400].[t_op_DOI_Enroll_FirstFU];


INSERT INTO [Reporting].[PSA400].[t_op_DOI_Enroll_FirstFU]


SELECT DISTINCT VisitID
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,NextVisitDrugOrder
	  ,VisitOrder
	  ,NextVisit
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,YearofBirth
	  ,YearOfDiagnosis
	  ,Diagnosis
	  ,EligibilityVersion
	  ,DrugHierarchy
	  ,PageDescription
	  ,PageStatus
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CAST(CurrentDose AS varchar) AS CurrentDose
	  ,CAST(PastDose AS varchar) AS PastDose
	  ,DrugOfInterest
	  ,AdditionalDOI
	  ,DOIInitiationStatus
	  ,SubscriberDOI
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,RegistryEnrollmentStatus
	  ,ReviewOutcome
	  ,DOIFUMatch
	  ,NextVisitDrugHierarchy
	  ,NextVisitTreatmentName
	  ,NextVisitDate
	  ,NextVisitChanges
	  ,NextVisitStatus

	  ,CASE WHEN NextVisitStatus='no match at next visit' THEN 'drug not started'
	   WHEN NextVisitStatus='match at next visit' AND NextVisitChanges IN ('No changes', 'Modify') THEN 'confirmed'
	   WHEN NextVisitStatus='match at next visit' AND DrugOfInterest='Investigational Agent' AND (NextVisitChanges NOT LIKE '%Start%' AND NextVisitChanges NOT LIKE '%Stop%') THEN 'confirmed'
	   WHEN NextVisitStatus='match at next visit' AND ISNULL(NextVisitCurrentDose, '')<>'' THEN 'confirmed'
	   WHEN NextVisitStatus='match at next visit' AND NextVisitChanges LIKE '%Start%' AND ISNULL(CurrentDose, '')<>'' AND ISNULL(PastDose, '')<>'' THEN 'confirmed'
	   WHEN NextVisitStatus='match at next visit' AND ChangeSinceLastVisit IN ('No changes', 'Modified', 'Started') THEN 'confirmed'
	   WHEN NextVisitStatus='match at next visit' AND NextVisitChanges LIKE '%Start%' THEN 'drug not started'
	   WHEN NextVisitStatus='match at next visit' AND NextVisitChanges LIKE '%Stop%' OR NextVisitChanges='N/A (no longer in use)' THEN 'drug stopped'
	   WHEN NextVisitStatus='match at next visit' AND ISNULL(NextVisitChanges, '')='' AND ISNULL(NextVisitPastDose, '')<>'' THEN 'drug stopped'
	   WHEN NextVisitStatus='match at next visit' AND ChangeSinceLastVisit IN ('Stopped', 'Started and stopped') THEN 'drug stopped'
	   WHEN NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')='' THEN 'pending'
	   WHEN NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')<>'' THEN 'unknown-exited'
	   WHEN NextVisitStatus='no data' AND ISNULL(ExitDate, '')<>'' THEN 'unknown-exited'
	   WHEN NextVisitStatus='no data' AND ISNULL(ExitDate, '')='' THEN 'no data'
	   ELSE ''
	   END AS InitiationStatus

	  ,CASE WHEN NextVisitStatus='match at next visit' THEN NextVisitDate
	   WHEN NextVisitStatus='no next visit' THEN NULL
	   WHEN NextVisitStatus='no match at next visit' THEN NextVisitDate
	   WHEN NextvisitStatus='no data' THEN NextVisitDate
	   ELSE NULL
	   END AS ConfirmationVisitDate

	  ,CASE WHEN DrugOfInterest NOT IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)', 'guselkumab (Tremfya)') THEN '-'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)', 'guselkumab (Tremfya)') AND NextVisitStatus='match at next visit' AND (NextVisitChanges IN ('No changes', 'Modify') OR ISNULL(NextVisitCurrentDose, '')<>'') THEN 'yes'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)', 'guselkumab (Tremfya)') AND NextVisitStatus='match at next visit' AND (ISNULL(NextVisitCurrentDose, '')<>'' AND NextVisitChanges NOT LIKE '%Start%' AND NextVisitChanges NOT LIKE '%Stop%') THEN 'yes'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)', 'guselkumab (Tremfya)') AND (ISNULL(NextVisitChanges, '')='' AND ISNULL(NextVisitPastDose, '')<>'') OR NextVisitChanges='Stop' THEN 'no (revoked)'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)', 'guselkumab (Tremfya)') AND NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')<>'' THEN 'no (revoked)'
	   ELSE ''
	   END AS SubscriberDOIAccrual

FROM #EFFU EFFU
WHERE NextVisitDrugOrder=1

UNION

SELECT DISTINCT VisitID
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,NULL AS NextVisitDrugOrder
	  ,NULL AS VisitOrder
	  ,NULL AS NextVisit
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,YearofBirth
	  ,YearOfDiagnosis
	  ,Diagnosis
	  ,EligibilityVersion
	  ,DrugHierarchy
	  ,PageDescription
	  ,PageStatus
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,'' AS ChangeSinceLastVisit
	  ,CAST(CurrentDose AS varchar) AS CurrentDose
	  ,CAST(PastDose AS varchar) AS PastDose
	  ,DrugOfInterest
	  ,AdditionalDOI
	  ,DOIInitiationStatus
	  ,SubscriberDOI
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,RegistryEnrollmentStatus
	  ,ReviewOutcome

	  ,'-' AS DOIFUMatch
	  ,NULL AS NextVisitDrugHierarchy
	  ,'-' AS NextVisitTreatmentName
	  ,NULL AS NextVisitDate
	  ,'-' AS NextVisitChanges
	  ,'-' AS NextVisitStatus
	  ,'-' AS InitiationStatus
	  ,NULL AS ConfirmationVisitDate
	  ,'-' AS SubscriberDOIAccrual

FROM  [Reporting].[PSA400].[t_op_CAT_Enrollment] ES
WHERE DrugHierarchy=1 AND ES.DOIInitiationStatus<>'prescribed at visit'



--SELECT DISTINCT Cohort FROM [Reporting].[PSA400].[t_op_DOI_Enroll_FirstFU] WHERE SubjectID=3001080168 OR TreatmentName LIKE '%Tremfy%' ORDER BY SiteID, SubjectID







END

GO
