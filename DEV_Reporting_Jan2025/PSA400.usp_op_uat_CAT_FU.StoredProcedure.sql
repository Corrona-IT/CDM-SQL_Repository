USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_uat_CAT_FU]    Script Date: 1/3/2025 4:39:29 PM ******/
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



CREATE PROCEDURE [PSA400].[usp_op_uat_CAT_FU] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;

/*
CREATE TABLE [PSA400].[t_op_uat_DOI_CAT]
(
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
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[ChangeSinceLastVisit] [varchar](100) NULL,
	[CurrentDose] [varchar](75) NULL,
	[PastDose] [varchar](75) NULL,
	[DrugOfInterest] [nvarchar](350) NULL,
	[AdditionalDOI] [nvarchar](1000) NULL,
	[DOIInitiationStatus] [nvarchar](150) NULL,
	[SubscriberDOI] [nvarchar](50) NULL,
	[DrugReqSatisfied] [nvarchar](50) NULL,
	[FirstTimeUse] [nvarchar](10) NULL,
	[ChangesToday] [nvarchar](150) NULL,
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

IF OBJECT_ID('tempdb.dbo.#ExitVisits') IS NOT NULL BEGIN DROP TABLE #ExitVisits END;

SELECT DISTINCT SiteID
      ,SubjectID
	  ,ExitDate
	  ,PageStatus

INTO #ExitVisits
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

--SELECT * FROM #ExitVisits 


/**********Get Cohort and Biologic and Biosimilar Treatment at FU if DOI Prescribed at visit**********/

/*****Cohorts for Treatments from V.2 DRUG table at Follow-up*****/

IF OBJECT_ID('tempdb.dbo.#CohortTable') IS NOT NULL BEGIN DROP TABLE #CohortTable END;

SELECT DISTINCT [CorronaRegistryID]
      ,[Drug] AS TreatmentName
      ,CASE WHEN [Cohort]='Otezla' THEN 'IL-17i, JAKi or PDE4I'
	   WHEN [Cohort]='IL-17 or JAKi' THEN 'IL-17i, JAKi or PDE4I'
	   WHEN [Drug]='tocilizumab IV (Actemra)' THEN 'Comparator Biologics'
	   ELSE [Cohort]
	   END AS [Cohort]
INTO #CohortTable
FROM [Reimbursement].[Reference].[t_DrugHierarchy]

--SELECT * FROM #CohortTable ORDER BY [TreatmentName]


/*****Create Visit Order to find next FU visit*****/

IF OBJECT_ID('tempdb.dbo.#FUVisitOrder') IS NOT NULL BEGIN DROP TABLE #FUVisitOrder END;

SELECT DISTINCT vID AS VisitID
      ,ROW_NUMBER() OVER(PARTITION BY [SITENUM], [SUBNUM] ORDER BY [SITENUM], [SUBNUM], [VISITDATE]) AS VisitOrder
	  ,SITENUM AS SiteID
      ,SUBNUM AS SubjectID
	  ,'Follow up' AS VisitType
	  ,V.VISNAME
	  ,V.PAGENAME
	  ,VISITDATE AS VisitDate

INTO #FUVisitOrder

FROM [MERGE_SPA].[staging].[VS_01] V
WHERE V.SITENUM NOT IN (99997, 99998, 99999)
AND V.PAGENAME='Date of Visit'
AND V.VISNAME LIKE '%Follow%' 

--SELECT * FROM #FUVisitOrder ORDER BY SiteID, SubjectID, VisitDate


IF OBJECT_ID('tempdb.dbo.#FUDiagnosis') IS NOT NULL BEGIN DROP TABLE #FUDiagnosis END;

/*****Get ProviderID and Diagnosis at FU*****/

SELECT VisitID
      ,SiteID
	  ,ProviderID
	  ,SubjectID
	  ,Diagnosis
	  ,VISITSEQ
INTO #FUDiagnosis
FROM
(
SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,MD_COD AS ProviderID
	  ,SUBNUM AS SubjectID
	  ,CASE WHEN DX_PA='X' THEN 'PA'
	   ELSE ''
	   END AS Diagnosis
	  ,VISITSEQ
FROM [MERGE_SPA].[staging].[FPRO_01] FPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)

UNION

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,MD_COD AS ProviderID
	  ,SUBNUM AS SubjectID
      ,CASE WHEN DX_AS='X' THEN 'AS'
	   ELSE ''
	   END AS Diagnosis
	  ,VISITSEQ
FROM [MERGE_SPA].[staging].[FPRO_01] FPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)

UNION 

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,MD_COD AS ProviderID
	  ,SUBNUM AS SubjectID
	  ,CASE WHEN DX_AXIAL='X' THEN DX_AXIAL_TYPE_DEC + ' Ax_SpA'
	   ELSE ''
	   END AS Diagnosis
	  ,VISITSEQ
FROM [MERGE_SPA].[staging].[FPRO_01] FPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)

UNION

SELECT vID
      ,SITENUM AS SiteID
	  ,MD_COD AS ProviderID
	  ,SUBNUM AS SubjectID
	  ,'-' AS Diagnosis
	  ,VISITSEQ

FROM [MERGE_SPA].[staging].[EP_01A]
WHERE SITENUM NOT IN (99999, 99998, 99997)
) PatientDiagnosis WHERE ISNULL(Diagnosis, '')<>''

--SELECT * FROM #FUDiagnosis ORDER BY SiteID, SubjectID, VISITSEQ


IF OBJECT_ID('tempdb.dbo.#FUDiagnosis2') IS NOT NULL BEGIN DROP TABLE #FUDiagnosis2 END;

/*****Combine Diagnosis at FU into one field*****/

SELECT VisitID
      ,SiteID
	  ,ProviderID
	  ,SubjectID

	  ,STUFF((
        SELECT ', '+ Diagnosis 
        FROM #FUDiagnosis A
		WHERE A.VisitID=FUD.VisitID
        FOR XML PATH('')
		)
		,1,1,'') AS Diagnosis
	 
	 ,VISITSEQ
INTO #FUDiagnosis2
FROM #FUDiagnosis FUD


/*****Determine FirstTimeUse at Follow-up*****/

IF OBJECT_ID('tempdb.dbo.#FTU') IS NOT NULL BEGIN DROP TABLE #FTU END;

SELECT A.VisitID
      ,A.SiteID
      ,A.SubjectID
	  ,A.VisitOrder
	  ,A.PageDescription
	  ,A.PageSequence
	  ,A.VisitDate
	  ,DATEPART(YYYY, A.VisitDate) AS VisitYear
	  ,DATEPART(MM, A.VisitDate) AS VisitMonth
	  ,A.TreatmentName
	  ,A.ChangesToday

      ,CASE WHEN TreatmentName LIKE '%DMARD%' OR TreatmentName LIKE '%Investigational%' OR TreatmentName LIKE '%No Treatment%' THEN 'n/a'
	   WHEN TreatmentName LIKE '%Other%' THEN 'undefined'
	   WHEN EXISTS (SELECT B.TreatmentStopYear FROM [PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=A.SiteID and B.SubjectID=A.SubjectID AND B.TreatmentName=A.TreatmentName AND B.TreatmentStopYear < DATEPART(YYYY, A.VisitDate) AND B.VisitID<>A.VisitID) THEN 'no'
	   WHEN EXISTS (SELECT B.TreatmentStopYear FROM [PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=A.SiteID and B.SubjectID=A.SubjectID AND B.TreatmentName=A.TreatmentName AND B.TreatmentStopYear = DATEPART(YYYY, A.VisitDate) AND B.TreatmentStopMonth  < DATEPART(MM, A.VisitDate) AND B.VisitID<>A.VisitID) THEN 'no'
	   WHEN NOT EXISTS (SELECT B.TreatmentName FROM [PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=A.SiteID and B.SubjectID=A.SubjectID AND B.TreatmentName=A.TreatmentName AND B.VisitID<>A.VisitID AND B.VisitDate < A.VisitDate) THEN 'yes'
	   WHEN EXISTS (SELECT B.TreatmentName FROM [PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=A.SiteID and B.SubjectID=A.SubjectID AND B.TreatmentName=A.TreatmentName AND B.VisitID<>A.VisitID AND B.VisitDate < A.VisitDate AND (ISNULL(B.PastDose, '')<>'' OR ISNULL(TreatmentStopYear, '')<>'' OR B.ChangesToday IN ('Stop', 'Stop Drug', 'N/A (no longer in use)'))) THEN 'no'
	   WHEN NOT EXISTS (SELECT B.TreatmentName FROM [PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=A.SiteID and B.SubjectID=A.SubjectID AND B.TreatmentName=A.TreatmentName AND B.VisitID<>A.VisitID AND B.VisitDate < A.VisitDate AND (ISNULL(B.PastDose, '')<>'' OR ISNULL(TreatmentStopYear, '')<>'' OR B.ChangesToday IN ('Stop', 'Stop Drug', 'N/A (no longer in use)'))) THEN 'yes'
	   ELSE ''
	   END AS FirstTimeuse

INTO #FTU
FROM [PSA400].[t_op_Followup_Drugs] A
WHERE A.ChangesToday NOT IN ('Stop', 'Stop Drug', 'N/A (no longer in use)')
AND A.PageDescription LIKE '%Biologics%' OR A.PageDescription LIKE '%Biosim%'
ORDER BY A.SiteID, A.SubjectID, A.VisitDate

--SELECT * FROM #FTU WHERE SubjectID=3001010035 ORDER BY VISITDATE


/*****Get all Biologic or Biosimilar Drugs at Follow Up*****/

IF OBJECT_ID('tempdb.dbo.#ALLDRUG') IS NOT NULL BEGIN DROP TABLE #ALLDRUG END;

SELECT DISTINCT FUDRUG.VisitID
      ,FUDRUG.SiteID
	  ,FUDRUG.SiteStatus
	  ,FUDRUG.SubjectID
	  ,FUDRUG.VisitType
	  ,FUDRUG.VisitOrder
	  ,FUDRUG.VisitDate
	  ,FUDIAG.ProviderID
	  ,FUDIAG.Diagnosis
	  ,FUDRUG.NextVisit
	  ,FUDRUG.PageDescription
	  ,FUDRUG.PageSequence
	  ,FUDRUG.PageStatus
	  ,FUDRUG.Cohort
	  ,FUDRUG.TreatmentName

	  ,CASE WHEN UPPER(FUDRUG.TreatmentName) LIKE '%OTHER: COSENT%' AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'secukinumab (Cosentyx)'
	   WHEN FUDRUG.TreatmentName LIKE '%Other: consentyx%'AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'secukinumab (Cosentyx)'
	   WHEN UPPER(FUDRUG.TreatmentName) LIKE '%OTHER: HUMIRA%' AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'adalimumab (Humira)'
	   WHEN UPPER(FUDRUG.TreatmentName) LIKE '%OTHER: OTEZLA%' AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'apremilast (Otezla)'
	   WHEN UPPER(FUDRUG.TreatmentName) LIKE '%OTHER: USTEKINUMAB%' AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'ustekinumab (Stelara)'
	   WHEN UPPER(FUDRUG.TreatmentName) LIKE '%OTHER: ETANERCEPT%' AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'etanercept (Enbrel)'
	   WHEN UPPER(FUDRUG.TreatmentName) LIKE '%OTHER: REMICADE%'  AND FUDRUG.ChangesToday<>'N/A (no longer in use)' THEN 'infliximab (Remicade)'
	   ELSE FUDRUG.TreatmentName
	   END AS DrugOfInterest

	  ,CASE WHEN FUDRUG.ChangesToday LIKE '%Start%' THEN 'prescribed at visit'
       ELSE FUDRUG.ChangesToday
	   END AS ChangesToday 
	    
	  ,FUDRUG.TreatmentStartYear
	  ,FUDRUG.TreatmentStartMonth
	  ,FUDRUG.TreatmentStopYear
	  ,FUDRUG.TreatmentStopMonth
	  ,FUDRUG.ChangeSinceLastVisit
	  ,FUDRUG.CurrentDose
	  ,FUDRUG.PastDose
	  ,FTU.FirstTimeUse

INTO #ALLDRUG
FROM [Reporting].[PSA400].[t_op_Followup_Drugs] FUDRUG
LEFT JOIN #FUDiagnosis2 FUDIAG ON FUDIAG.VisitID=FUDRUG.VisitID
LEFT JOIN #FTU FTU ON FTU.VisitID=FUDRUG.VisitID AND FTU.TreatmentName=FUDRUG.TreatmentName AND FTU.ChangesToday=FUDRUG.ChangesToday
WHERE (FUDRUG.PageDescription LIKE '%Biologics%' OR FUDRUG.PageDescription LIKE '%Biosim%')

--SELECT * FROM [Reporting].[PSA400].[t_op_Followup_Drugs] 
--SELECT * FROM #ALLDRUG ORDER BY SiteID, SubjectID, VisitDate


/*****Get just follow ups that are STARTING drug and first FU visit after*****/

IF OBJECT_ID('tempdb.dbo.#FUStart') IS NOT NULL BEGIN DROP TABLE #FUStart END;

SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID, VisitDate ORDER BY SiteID, SubjectID, NextVisitDrugHierarchy, NextVisitTreatmentName) AS NextVisitDrugOrder
      ,VisitID
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitOrder
	  ,NextVisit
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,Diagnosis
	  ,PageDescription
	  ,TreatmentName
	  ,ChangesToday
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,FirstTimeUse
	  ,DrugOfInterest
	  ,SubscriberDOI
	  ,PageStatus
	  ,Cohort
	  ,DOIFUMatch
      ,NextVisitDrugHierarchy
	  ,NextVisitTreatmentName
	  ,NextVisitDate
	  ,NextVisitChanges
	  ,NextVisitCurrentDose
	  ,NextVisitPastDose
	  ,NextVisitStartYear
	  ,NextVisitStartMonth
	  ,NextVisitStopYear
	  ,NextVisitStopMonth
	  ,NextVisitStatus
	  ,NextVisitVisitOrder
	  ,NextVisitNextVisit
	  ,ExitDate

INTO #FUStart
FROM
(
  
SELECT DISTINCT D.VisitID
	  ,D.SiteID
	  ,D.SiteStatus
	  ,D.SubjectID
	  ,D.VisitOrder
	  ,D.NextVisit
	  ,D.VisitType
	  ,D.VisitDate
	  ,D.ProviderID
	  ,D.Diagnosis
	  ,D.PageDescription
	  ,D.TreatmentName
	  ,D.TreatmentStartYear
	  ,D.TreatmentStartMonth
	  ,D.TreatmentStopYear
	  ,D.TreatmentStopMonth
	  ,D.ChangeSinceLastVisit
	  ,D.CurrentDose
	  ,D.PastDose
	  ,D.DrugOfInterest
	  ,D.PageStatus
	  ,D.FirstTimeuse

	  ,CASE WHEN D.DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') THEN 'yes'
	   ELSE 'no'
	   END AS SubscriberDOI

	  ,D.ChangesToday
	  ,D.Cohort

	  ,CASE WHEN D.DrugOfInterest=NV.TreatmentName THEN NV.TreatmentName
	   WHEN NV.TreatmentName='No treatment' THEN 'no match'
	   WHEN D.DrugOfInterest<>NV.TreatmentName THEN 'no match'
	   ELSE ''
	   END AS DOIFUMatch

	 ,CASE WHEN D.DrugOfInterest=NV.TreatmentName THEN 10
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND NV.CurrentDose<>'' THEN 30
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND ISNULL(NV.PastDose, '')<>'' THEN 50
	  WHEN ISNULL(NV.TreatmentName, '')='' THEN 80
	  ELSE 90
	  END AS NextVisitDrugHierarchy

	  ,NV.TreatmentName AS NextVisitTreatmentName
	  ,NV.VisitDate AS NextVisitDate
	  ,NV.ChangesToday AS NextVisitChanges
	  ,NV.CurrentDose AS NextVisitCurrentDose
	  ,NV.PastDose AS NextVisitPastDose
	  ,NV.TreatmentStartYear AS NextVisitStartYear
	  ,NV.TreatmentStartMonth AS NextVisitStartMonth
	  ,NV.TreatmentStopYear AS NextVisitStopYear
	  ,NV.TreatmentStopMonth AS NextVisitStopMonth

	 ,CASE WHEN D.DrugOfInterest=NV.TreatmentName THEN 'match at next visit'
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND ISNULL(NV.TreatmentName, '')<>'' THEN 'no match at next visit'
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND NV.TreatmentName='No treatment' THEN 'no match at next visit'
	  WHEN ISNULL(NV.VisitOrder, '')='' THEN 'no next visit'
	  WHEN NV.PageStatus='no data' THEN 'no data'
	  ELSE ''
	  END AS NextVisitStatus

	 ,NV.VisitOrder AS NextVisitVisitOrder
	 ,NV.NextVisit AS NextVisitNextVisit
	 ,EV.ExitDate AS ExitDate

FROM  #ALLDRUG D
LEFT JOIN [PSA400].[t_op_Followup_Drugs] NV ON NV.SiteID=D.SiteID AND NV.SubjectID=D.SubjectID AND NV.VisitOrder=D.NextVisit 
LEFT JOIN #ExitVisits EV ON EV.SiteID=D.SiteID AND EV.SubjectID=D.SubjectID
WHERE D.ChangesToday='prescribed at visit' 
AND (D.PageDescription LIKE '%Biologics%' OR D.PageDescription LIKE '%Biosim%')

) FUS

--SELECT * FROM #FUStart FUStart WHERE SubjectID=3001010106



/*****Get Treatments started between visits*****/

IF OBJECT_ID('tempdb.dbo.#SubDOIBetweenVisits') IS NOT NULL BEGIN DROP TABLE #SubDOIBetweenVisits END;

SELECT *

INTO #SubDOIBetweenVisits
FROM
(
SELECT [VisitID]
      ,[SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[PageDescription]
      ,[PageSequence]
      ,[TreatmentName]
 
	  ,CASE WHEN ISNULL(ChangesToday, '') IN ('', 'No changes', 'Change Dose', 'Stop Drug', 'Current') THEN 'Started'
	   WHEN ChangesToday='N/A (no longer in use)' THEN 'Started and stopped'
	   ELSE '-'
	   END AS [ChangeSinceLastVisit]

  FROM [PSA400].[t_op_Followup_Drugs] A
  WHERE A.VisitDate=(SELECT MIN(VisitDate) FROM [PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=A.SiteID AND B.SubjectiD=A.SubjectID AND B.TreatmentName=A.TreatmentName)
  AND A.TreatmentName IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz XR)', 'tofacitinib (Xeljanz)')
  AND A.PageDescription='Biologics V1.2'
  AND A.ChangesToday <> 'Start Drug'
  AND TreatmentName NOT IN (SELECT TreatmentName FROM [PSA400].[t_op_Enrollment_Drugs] C WHERE C.SiteID=A.SiteID AND C.SubjectiD=A.SubjectID)
  AND SiteID NOT IN (99997, 99998, 99999)
  
UNION

  SELECT DISTINCT D.vID AS VisitID
      ,D.SITENUM AS SiteID
	  ,D.SUBNUM AS SubjectID
	  ,D.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,D.PAGENAME AS PageDescription
	  ,D.PAGESEQ AS PageSequence

	  ,CASE WHEN ISNULL(D.DRUG_NAME_OTHER, '')<>'' THEN D.DRUG_NAME_DEC + ': ' + D.DRUG_NAME_OTHER
	   ELSE D.DRUG_NAME_DEC 
	   END AS TreatmentName

      ,CASE WHEN D.DRUG_0_LV='X' THEN 'No changes'
	   WHEN D.DRUG_1_LV='X' AND ISNULL(D.DRUG_2_LV, '')='' THEN 'Started'
	   WHEN D.DRUG_2_LV='X' AND ISNULL(D.DRUG_1_LV, '')='' THEN 'Stopped'
	   WHEN D.DRUG_1_LV='X' AND D.DRUG_2_LV='X' THEN 'Started and stopped'
	   WHEN D.DRUG_3_LV='X' THEN 'Modified'
	   ELSE ''
	   END AS ChangeSinceLastVisit
FROM [MERGE_SPA].[staging].[DRUG] D
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=D.vID 
WHERE D.DRUG_1_LV='X' 
AND D.PAGENAME IN ('Biologics', 'Biosimilars')
AND NOT EXISTS (SELECT D2.SUBNUM FROM [MERGE_SPA].[staging].[DRUG] D2 LEFT JOIN [MERGE_SPA].[staging].[VS_01] V2 ON V2.vID=D2.vID WHERE D2.SITENUM=D.SITENUM AND D2.SUBNUM=D.SUBNUM AND D2.DRUG_NAME_DEC=D.DRUG_NAME_DEC AND D2.PAGENAME=D.PAGENAME AND V2.VisitDate<V.VISITDATE)
AND D.SITENUM NOT IN (99997, 99998, 99999)
) BTWNVISIT

--SELECT * FROM #SubDOIBetweenVisits WHERE SubjectID=3002020032 ORDER BY SiteID, SubjectID, TreatmentName, FirstReportedDate


IF OBJECT_ID('tempdb.dbo.#SubDOIBetween') IS NOT NULL BEGIN DROP TABLE #SubDOIBetween END;

SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID, VisitDate ORDER BY SiteID, SubjectID, NextVisitDrugHierarchy, NextVisitTreatmentName) AS NextVisitDrugOrder
      ,VisitID
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitOrder
	  ,NextVisit
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,Diagnosis
	  ,PageDescription
	  ,TreatmentName
	  ,ChangesToday
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,FirstTimeUse
	  ,DrugOfInterest
	  ,SubscriberDOI
	  ,PageStatus
	  ,CASE WHEN ISNULL(Cohort, '')='' THEN '-'
	   ELSE Cohort
	   END AS Cohort
	  ,DOIFUMatch
      ,NextVisitDrugHierarchy
	  ,NextVisitTreatmentName
	  ,NextVisitDate
	  ,NextVisitChanges
	  ,NextVisitCurrentDose
	  ,NextVisitPastDose
	  ,NextVisitStartYear
	  ,NextVisitStartMonth
	  ,NextVisitStopYear
	  ,NextVisitStopMonth
	  ,NextVisitStatus
	  ,NextVisitVisitOrder
	  ,NextVisitNextVisit
	  ,ExitDate

INTO #SubDOIBetween
FROM
(
  
SELECT DISTINCT SDBV.VisitID
	  ,SDBV.SiteID
	  ,D.SiteStatus
	  ,SDBV.SubjectID
	  ,D.VisitOrder
	  ,D.NextVisit
	  ,D.VisitType
	  ,D.VisitDate
	  ,D.ProviderID
	  ,D.Diagnosis
	  ,SDBV.PageDescription
	  ,SDBV.PageSequence
	  ,SDBV.TreatmentName
	  ,D.TreatmentStartYear
	  ,D.TreatmentStartMonth
	  ,D.TreatmentStopYear
	  ,D.TreatmentStopMonth
	  ,SDBV.ChangeSinceLastVisit
	  ,D.CurrentDose
	  ,D.PastDose
	  ,D.DrugOfInterest
	  ,D.PageStatus
	  ,CASE WHEN EXISTS (SELECT TreatmentName FROM [Reporting].[PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=SDBV.SiteID AND B.SubjectID=SDBV.SubjectID AND B.TreatmentName=SDBV.TreatmentName AND B.VisitDate<D.VisitDate) 
	    OR EXISTS(SELECT TreatmentName FROM [Reporting].[PSA400].[t_op_Enrollment_Drugs] C WHERE C.SiteID=SDBV.SiteID AND C.SubjectID=SDBV.SubjectID AND C.TreatmentName=SDBV.TreatmentName)  THEN 'no'
	   WHEN NOT EXISTS (SELECT TreatmentName FROM [Reporting].[PSA400].[t_op_Followup_Drugs] B WHERE B.SiteID=SDBV.SiteID AND B.SubjectID=SDBV.SubjectID AND B.TreatmentName=SDBV.TreatmentName AND B.VisitDate<D.VisitDate) AND NOT EXISTS (SELECT TreatmentName FROM [Reporting].[PSA400].[t_op_Enrollment_Drugs] C WHERE C.SiteID=SDBV.SiteID AND C.SubjectID=SDBV.SubjectID AND C.TreatmentName=SDBV.TreatmentName) THEN 'yes'
	   ELSE ''
	   END AS FirstTimeUse

	  ,CASE WHEN D.DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') THEN 'yes'
	   ELSE 'no'
	   END AS SubscriberDOI

	  ,CASE WHEN ISNULL(D.ChangesToday, '')='' AND SDBV.ChangeSinceLastVisit='Started' THEN 'Started between visits'
	   WHEN ISNULL(D.ChangesToday, '')='' AND SDBV.ChangeSinceLastVisit='Started and stopped' THEN 'Started and stopped between visits'
	   WHEN ISNULL(D.ChangesToday, '')<>'' AND SDBV.ChangeSinceLastVisit='Started' THEN D.ChangesToday + ', started between visits'
	   WHEN SDBV.ChangeSinceLastVisit='Started and stopped' THEN D.ChangesToday + ', started and stopped between visits'
	   ELSE D.ChangesToday
	   END AS ChangesToday

	  ,CASE WHEN D.DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)', 'apremilast (Otezla)') THEN 'IL-17I, JAKi OR PDE4i'
	   WHEN D.DrugOfInterest IN ('adalimumab (Humira)', 'etanercept (Enbrel)', 'infliximab (Remicade)', 'golimumab (Simponi)', 'ustekinumab (Stelara)', 'certolizumab pegol (Cimzia)', 'guselkumab (Tremfya)', 'anakinra (Kineret)') THEN 'Comparator Biologics'
	   ELSE D.Cohort
	   END AS Cohort

	  ,CASE WHEN D.DrugOfInterest=NV.TreatmentName THEN NV.TreatmentName
	   WHEN NV.TreatmentName='No treatment' THEN 'no match'
	   WHEN D.DrugOfInterest<>NV.TreatmentName THEN 'no match'
	   ELSE ''
	   END AS DOIFUMatch

	 ,CASE WHEN D.DrugOfInterest=NV.TreatmentName THEN 10
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND NV.CurrentDose<>'' THEN 30
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND ISNULL(NV.PastDose, '')<>'' THEN 50
	  WHEN ISNULL(NV.TreatmentName, '')='' THEN 80
	  ELSE 90
	  END AS NextVisitDrugHierarchy

	  ,NV.TreatmentName AS NextVisitTreatmentName
	  ,NV.VisitDate AS NextVisitDate
	  ,NV.ChangesToday AS NextVisitChanges
	  ,NV.CurrentDose AS NextVisitCurrentDose
	  ,NV.PastDose AS NextVisitPastDose
	  ,NV.TreatmentStartYear AS NextVisitStartYear
	  ,NV.TreatmentStartMonth AS NextVisitStartMonth
	  ,NV.TreatmentStopYear AS NextVisitStopYear
	  ,NV.TreatmentStopMonth AS NextVisitStopMonth

	 ,CASE WHEN D.DrugOfInterest=NV.TreatmentName THEN 'match at next visit'
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND ISNULL(NV.TreatmentName, '')<>'' THEN 'no match at next visit'
	  WHEN D.DrugOfInterest<>NV.TreatmentName AND NV.TreatmentName='No treatment' THEN 'no match at next visit'
	  WHEN ISNULL(NV.VisitOrder, '')='' THEN 'no next visit'
	  WHEN NV.PageStatus='no data' THEN 'no data'
	  ELSE ''
	  END AS NextVisitStatus

	 ,NV.VisitOrder AS NextVisitVisitOrder
	 ,NV.NextVisit AS NextVisitNextVisit
	 ,EV.ExitDate

FROM #SubDOIBetweenVisits SDBV
LEFT JOIN #ALLDRUG D ON D.SiteID=SDBV.SiteID AND D.SubjectID=SDBV.SubjectID AND D.VisitID=SDBV.VisitID AND D.PageDescription=SDBV.PageDescription AND D.PageSequence=SDBV.PageSequence AND D.TreatmentName=SDBV.TreatmentName
LEFT JOIN [PSA400].[t_op_Followup_Drugs] NV ON NV.SiteID=SDBV.SiteID AND NV.SubjectID=SDBV.SubjectID AND NV.VisitOrder=D.NextVisit
LEFT JOIN #ExitVisits EV ON EV.SiteID=SDBV.SiteID AND EV.SubjectID=SDBV.SubjectID
) SubDOI

--SELECT * FROM #SubDOIBetween WHERE SubjectID=3001010025 ORDER BY SiteID, SubjectID, VisitDate, TreatmentName


/*****Follow up, next follow drug that matched or showing no match at next follow up, other calculations*****/

TRUNCATE TABLE [Reporting].[PSA400].[t_op_DOI_CAT]

INSERT INTO [Reporting].[PSA400].[t_op_DOI_CAT]


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
      ,NULL AS [YearofBirth]
      ,NULL AS [YearOfDiagnosis]
      ,Diagnosis
      ,'' AS [EligibilityVersion]
      ,NULL AS [DrugHierarchy]

	  ,PageDescription
	  ,PageStatus
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,DrugOfInterest

	  ,'' AS AdditionalDOI
	  ,'prescribed at visit' AS DOIInitiationStatus

	  ,SubscriberDOI

	  ,'' AS DrugReqSatisifed
	  ,FirstTimeUse

	  ,ChangesToday
	  ,Cohort
	  ,'' AS [RegistryEnrollmentStatus]
	  ,'' AS [ReviewOutcome]

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
	   WHEN NextVisitStatus='match at next visit' AND ChangeSinceLastVisit IN ('No changes', 'Modified', 'Started') THEN 'confirmed'
	   WHEN NextVisitStatus='match at next visit' AND NextVisitChanges LIKE '%Start%' THEN 'drug not started'
	   WHEN NextVisitStatus='match at next visit' AND (NextVisitChanges LIKE '%Stop%' OR NextVisitChanges='N/A (no longer in use)') THEN 'drug stopped'
	   WHEN NextVisitStatus='match at next visit' AND ISNULL(NextVisitChanges, '')='' AND ISNULL(NextVisitPastDose, '')<>'' THEN 'drug stopped'
	   WHEN NextVisitStatus='match at next visit' AND ISNULL(NextVisitChanges, '')='' AND ChangeSinceLastVisit IN ('Stopped', 'Started and stopped') THEN 'drug stopped'
	   WHEN NextVisitStatus='match at next visit' AND ISNULL(NextVisitCurrentDose, '')='' AND (NextVisitChanges NOT LIKE '%Start%' AND NextVisitChanges NOT LIKE '%Stop%' ) THEN 'assumed'
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

	  ,CASE WHEN DrugOfInterest NOT IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') THEN '-'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)') AND NextVisitStatus='match at next visit' AND (NextVisitChanges IN ('No changes', 'Modify') OR ISNULL(NextVisitCurrentDose, '')<>'') THEN 'yes'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)') AND NextVisitStatus='match at next visit' AND (ISNULL(NextVisitCurrentDose, '')<>'' AND NextVisitChanges NOT LIKE '%Start%' AND NextVisitChanges NOT LIKE '%Stop%') THEN 'yes'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)') AND (ISNULL(NextVisitChanges, '')='' AND ISNULL(NextVisitPastDose, '')<>'') OR NextVisitChanges='Stop' THEN 'no (revoked)'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', ' tofacitinib (Xeljanz XR)') AND NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')<>'' THEN 'no (revoked)'
	   ELSE ''
	   END AS SubscriberDOIAccrual

FROM #FUStart FS
WHERE NextVisitDrugOrder=1

UNION

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
      ,NULL AS [YearofBirth]
      ,NULL AS [YearOfDiagnosis]
      ,Diagnosis
      ,'' AS [EligibilityVersion]
      ,NULL AS [DrugHierarchy]
	  ,PageDescription
	  ,PageStatus
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,ChangeSinceLastVisit
	  ,CurrentDose
	  ,PastDose
	  ,DrugOfInterest
	  ,'' AS AdditionalDOI

	  ,CASE WHEN DrugOfInterest=TreatmentName AND ChangesToday='No changes, started between visits' THEN 'prescribed between visits; no changes today'
	   WHEN DrugOfInterest=TreatmentName AND ChangesToday='No changes, started and stopped between visits' THEN 'prescribed and stopped between visits; no changes today'
	   WHEN DrugOfInterest=TreatmentName AND ChangesToday='prescribed at visit, started and stopped between visits' THEN 'prescribed and stopped between visits; prescribed at visit today'
	   WHEN DrugOfInterest=TreatmentName AND ChangesToday='Stop, started and stopped between visits' THEN 'prescribed and stopped between visits; stopped today'
	   WHEN DrugOfInterest=TreatmentName AND ChangesToday='started between visits' THEN 'prescribed between visits; no changes today'
	   WHEN DrugOfInterest=TreatmentName AND ChangesToday='Stop, started between visits' THEN 'prescribed between visits; drug discontinued today'
	   WHEN DrugOfInterest=TreatmentName AND ChangesToday='Modify, started between visits' THEN 'prescribed between visits; modified today'
	   WHEN ChangesToday='N/A (no longer in use), started and stopped between visits' THEN 'prescribed and stopped between visits; past biologic or JAKi use'
	   WHEN ChangesToday='Started and stopped between visits' THEN 'prescribed between visits; drug discontinued'
	   WHEN DrugOfInterest<>TreatmentName THEN '-'
	   ELSE ''
	   END AS DOIInitiationStatus

	  ,SubscriberDOI
	  ,'' AS DrugReqSatisifed
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,'' AS [RegistryEnrollmentStatus]
	  ,'' AS [ReviewOutcome]
	  ,DOIFUMatch
      ,NextVisitDrugHierarchy
	  ,NextVisitTreatmentName
	  ,VisitDate AS NextVisitDate
	  ,NextVisitChanges
  	  ,NextVisitStatus

	  ,CASE WHEN ChangesToday='Stop, started between visits' THEN 'drug stopped'
	   WHEN ChangesToday='N/A (no longer in use), started and stopped between visits' THEN 'drug stopped'
	   WHEN ChangesToday='started and stopped between visits' THEN 'drug stopped'
	   WHEN ChangesToday='No changes, started between visits' THEN 'confirmed'
	   WHEN ChangesToday='Modify, started between visits' THEN 'confirmed'
	   WHEN DrugOfInterest='Investigational Drug' AND ChangesToday='Started between visits' THEN 'confirmed'
	   WHEN ChangesToday='prescribed at visit, started between visits' AND NextVisitStatus='no next visit' THEN 'pending'
	   WHEN ChangesToday='prescribed at visit, started between visits' AND NextVisitStatus='match at next visit' THEN 'confirmed'
	   ELSE ''
	   END AS InitiationStatus

	  ,CASE WHEN NextVisitStatus='match at next visit' THEN NextVisitDate
	   WHEN NextVisitStatus='no next visit' and ISNULL(TreatmentStartYear, '')<>''THEN VisitDate
	   WHEN NextVisitStatus='no match at next visit' THEN NextVisitDate
	   WHEN NextvisitStatus='no data' THEN NextVisitDate
	   ELSE NULL
	   END AS ConfirmationVisitDate

	  ,CASE WHEN DrugOfInterest NOT IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') THEN 'no'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') AND ChangesToday IN ('No changes, started between visits', 'Modify, started between visits') OR ISNULL(NextVisitCurrentDose, '')<>'' THEN 'yes'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') AND ISNULL(CurrentDose, '')<>'' AND ChangesToday NOT IN ('Stop', 'Stop Drug') THEN 'yes'
	   WHEN DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') AND ISNULL(PastDose, '')<>'' OR ChangesToday IN ('Stop, started between visits', 'N/A (no longer in use), started and stopped between visits', 'Started and stopped between visits') THEN 'no (revoked)'
	   ELSE ''
	   END AS SubscriberDOIAccrual

FROM #SubDOIBetween
WHERE NextVisitDrugOrder=1

UNION

SELECT [VisitID]
      ,[SiteID]
      ,[SiteStatus]
      ,[SubjectID]
      ,[NextVisitDrugOrder]
      ,[VisitOrder]
      ,[NextVisit]
      ,[VisitType]
      ,[VisitDate]
      ,[ProviderID]
      ,[YearofBirth]
      ,[YearOfDiagnosis]
      ,[Diagnosis]
      ,CAST([EligibilityVersion] AS nvarchar(5)) AS [EligibilityVersion]
      ,[DrugHierarchy]
      ,[PageDescription]
      ,[PageStatus]
      ,[TreatmentName]
      ,[TreatmentStartYear]
      ,[TreatmentStartMonth]
      ,[TreatmentStopYear]
      ,[TreatmentStopMonth]
	  ,[ChangeSinceLastVisit]
      ,[CurrentDose]
      ,[PastDose]
      ,[DrugOfInterest]
      ,[AdditionalDOI]
      ,[DOIInitiationStatus]
      ,[SubscriberDOI]
      ,[DrugReqSatisfied]
      ,[FirstTimeUse]
      ,[ChangesToday]
      ,[Cohort]
      ,[RegistryEnrollmentStatus]
      ,[ReviewOutcome]
      ,[DOIFUMatch]
      ,[NextVisitDrugHierarchy]
      ,[NextVisitTreatmentName]
      ,[NextVisitDate]
      ,[NextVisitChanges]
      ,[NextVisitStatus]
      ,[InitiationStatus]
      ,[ConfirmationVisitDate]
      ,[SubscriberDOIAccrual]
  FROM [PSA400].[t_op_DOI_Enroll_FirstFU]




--SELECT * FROM [PSA400].[t_op_DOI_CAT] ORDER BY SiteID, SubjectID, VisitDate


END

GO
