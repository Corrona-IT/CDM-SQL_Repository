USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_uat_CAT_Enrollment]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/30/2019
-- Description:	Procedure for Drugs at Enrollment with Hierarchy for DOI
--              Does not include Reimbursement Test Site 9997
-- ===========================================================================


CREATE   PROCEDURE [PSA400].[usp_op_uat_CAT_Enrollment] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;

  
  
/*
CREATE TABLE [Reporting].[PSA400].[t_op_uat_Enrollment_Drugs]
(
VisitID bigint NOT NULL,
SiteID int NOT NULL,
SiteStatus nvarchar(20) NULL,
SubjectID bigint NOT NULL,
VisitType nvarchar(30) NULL,
VisitDate date NULL,
ProviderID int NULL,
YearOfBirth int NULL,
YearOfDiagnosis int NULL,
Diagnosis nvarchar(50) NULL,
EligibilityVersion nvarchar(12) NULL,
DrugHierarchy int NULL,
PageDescription nvarchar(250) NULL,
TreatmentName nvarchar(350) NULL,
TreatmentStartYear int NULL,
TreatmentStartMonth int NULL,
TreatmentStopYear int NULL,
TreatmentStopMonth int NULL,
CurrentDose nvarchar(150) NULL,
PastDose nvarchar(150) NULL,
DrugOfInterest nvarchar(350) NULL,
AdditionalDOI nvarchar(1000) NULL,
PageStatus nvarchar(150) NULL,
DrugReqSatisfied nvarchar(10) NULL,
FirstTimeUse nvarchar(50) NULL,
ChangesToday nvarchar(50) NULL,
Cohort nvarchar(250) NULL,

) ON [PRIMARY]
GO


CREATE TABLE [Reporting].[PSA400].[t_op_uat_CAT_Enrollment]
(
VisitID bigint NOT NULL,
SiteID int NOT NULL,
SiteStatus nvarchar(10) NULL,
SubjectID bigint NOT NULL,
VisitType nvarchar(50) NULL,
VisitDate date NULL,
ProviderID int NULL,
YearofBirth int NULL,
YearOfDiagnosis int NULL,
Diagnosis nvarchar(30) NULL,
EligibilityVersion nvarchar(10) NULL,
DrugHierarchy int NULL,
PageDescription nvarchar(250) NULL,
TreatmentName nvarchar(300) NULL,
TreatmentStartYear int NULL,
TreatmentStartMonth int NULL,
TreatmentStopYear int NULL,
TreatmentStopMonth int NULL,
CurrentDose nvarchar(150) NULL,
PastDose nvarchar(150) NULL,
DrugOfInterest nvarchar(350) NULL,
AdditionalDOI nvarchar(1000) NULL,
PageStatus nvarchar(150) NULL,
DOIInitiationStatus varchar(150) NULL, 
SubscriberDOI varchar(10) NULL,
DrugReqSatisfied nvarchar(10) NULL,
FirstTimeUse nvarchar(50) NULL,
ChangesToday nvarchar(50) NULL,
Cohort nvarchar(200) NULL,
INELIGIBLE_DEC nvarchar(30) NULL,
INELIGIBLE_EXCEPTION_DEC nvarchar(30) NULL,
RegistryEnrollmentStatus nvarchar(50) NULL,
EnrollmentException nvarchar(50) NULL,
ReviewOutcome nvarchar(75) NULL

) ON [PRIMARY]
GO
*/



IF OBJECT_ID('tempdb.dbo.#DrugCohort') IS NOT NULL BEGIN DROP TABLE #DrugCohort END;

SELECT DISTINCT [CorronaRegistryID]
      ,[Drug]
      ,CASE WHEN [Cohort]='Otezla' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN [Cohort]='IL-17 or JAKi' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN [Cohort]='Comparator Biologics' THEN 'Comparator Biologic'
	   ELSE [Cohort]
	   END AS [Cohort]

INTO #DrugCohort
FROM [Reimbursement].[Reference].[t_DrugHierarchy]
WHERE [CorronaRegistryID]=3

--SELECT * FROM #DrugCohort

IF OBJECT_ID('tempdb.dbo.#A1_2') IS NOT NULL BEGIN DROP TABLE #A1_2 END;

/**************Diagnosis Calculation From Enrollment**********************/

SELECT DISTINCT VisitID
      ,SiteID
	  ,SubjectID
	  ,YearOfDiagnosis
	  ,Diagnosis

INTO #A1_2

FROM
(

/*************Diagnosis from V1.2*************/

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
	  ,CASE WHEN DX_PA='X'
	   THEN 'PSA'
	   ELSE ''
	   END AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EP_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)

UNION

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
	  ,CASE WHEN DX_SPA='X' AND ISNULL(DX_AXIAL, '')='' THEN 'SpA'
	   ELSE ''
	   END AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EP_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)


UNION

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
      ,CASE WHEN DX_AS='X' THEN 'AS'
	   ELSE ''
	   END AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EP_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)
) PatientDiagnosis_1_2 WHERE ISNULL(Diagnosis, '')<>''

--SELECT * FROM #A1_2 WHERE SubjectID IN (3093010020, 3093010021, 3100471039, 3100500104, 3167010045, 3234010006)


IF OBJECT_ID('tempdb.dbo.#A2') IS NOT NULL BEGIN DROP TABLE #A2 END;

/*************Diagnosis from V2*************/

SELECT DISTINCT VisitID
      ,SiteID
	  ,SubjectID
	  ,YearOfDiagnosis
	  ,Diagnosis

INTO #A2

FROM
(

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
	  ,CASE WHEN DX_PA='X' THEN 'PSA'
	   ELSE ''
	   END AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EPRO_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)
AND ISNULL(DX_PA, '')<>''

UNION

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
      ,CASE WHEN DX_AS='X' THEN 'AS'
	   ELSE ''
	   END AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EPRO_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)
AND ISNULL(DX_AS, '')<>''

UNION 

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
	  ,CASE WHEN DX_AXIAL='X' THEN DX_AXIAL_TYPE_DEC + ' AxSpA'
	   ELSE ''
	   END AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EPRO_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997)
AND ISNULL(DX_AXIAL, '')<>''

UNION

SELECT vID AS VisitID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,YR_PA_DX AS YearOfDiagnosis
	  ,'missing' AS Diagnosis
FROM [MERGE_SPA_UAT].[staging].[EPRO_01] EPRO
WHERE SITENUM NOT IN (99999, 99998, 99997) 
AND  (ISNULL(DX_PA, '')='' AND ISNULL(DX_AS, '')='' AND ISNULL(DX_AXIAL, '')='')
) PatientDiagnosis

--SELECT * FROM #A2 WHERE SiteID=1440 SubjectID IN (3002020812, 3055080008, 3059010050, 3093010020, 3093010021, 3100451060, 3100471037, 3100471039, 3100500104, 3100531059, 3100531061, 3100641043, 3154010082, 3167010041, 3167010045, 3169010029, 3209010002, 3212010004, 3212010006, 3213200001, 3213200002, 3213200006, 3217010008, 3220010046, 3234010006) ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb.dbo.#B1_2') IS NOT NULL BEGIN DROP TABLE #B1_2 END;

/*********Enrollment V1.2 visits in the database that have an Enrollment date, includes Diagnosis********/

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
	  ,CASE WHEN (VisitDate < '2017-04-03') AND (SubjectID<>'3055010001') THEN '99'
	   WHEN (VisitDate >= '2017-04-03' AND VisitDate <= '2018-02-07') OR SubjectID='3055010001' THEN '0'
	   WHEN (VisitDate >= '2018-02-08' AND VisitDate <= '2018-09-30') THEN '1-2'
	   WHEN (VisitDate >= '2018-10-01' AND VisitDate <= '2019-07-31') THEN '3'
	   WHEN VisitDate >= '2019-08-01' THEN '4'
	   ELSE ''
	   END AS EligibilityVersion

INTO #B1_2

FROM 
(
SELECT S.SITENUM AS SiteID
      ,CASE WHEN S.ACTIVE='t' THEN 'Active'
	   WHEN S.ACTIVE='f' THEN 'Inactive'
	   ELSE ''
	   END AS SiteStatus
	  ,V.vID as VisitID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISITDATE AS VisitDate
	  ,V.VISNAME AS VisitType
	  ,E1.MD_COD AS ProviderID
	  ,ES1.BIRTHDATE AS YearOfBirth
	  ,A.YearOfDiagnosis

	  ,STUFF((
        SELECT ', '+ Diagnosis 
        FROM #A1_2 A
		WHERE A.VisitID=E1.vID
        FOR XML PATH('')
		)
		,1,1,'') AS Diagnosis


FROM [MERGE_SPA_UAT].[dbo].[DAT_SITES] S
JOIN [MERGE_SPA_UAT].[staging].[VS_01] V ON V.SITENUM=S.SITENUM AND V.[VISNAME] LIKE 'Enroll%' AND ISNULL(V.VISITDATE, '')<>''
LEFT JOIN [MERGE_SPA_UAT].[staging].[EP_01] E1 ON E1.vID=V.vID 
LEFT JOIN #A1_2 A ON A.VisitID=E1.vID 
LEFT JOIN [MERGE_SPA_UAT].[staging].[ES_01] ES1 ON ES1.vID=V.vID
WHERE S.SITENUM NOT IN (99999, 99998, 99997)
) ENROLLMENT_1_2

--SELECT * FROM #B1_2 WHERE SubjectID=3001010023 ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb.dbo.#B2') IS NOT NULL BEGIN DROP TABLE #B2 END;

/*********Enrollment V2 visits in the database that have an Enrollment date, includes Diagnosis********/


SELECT DISTINCT VisitID
	  ,SiteID
      ,SiteStatus
	  ,SubjectID AS SubjectID
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
	  ,YearOfBirth
	  ,YearOfDiagnosis
	  ,Diagnosis
	  ,CASE WHEN (VisitDate < '2017-04-03') AND (SubjectID<>'3055010001') THEN '99'
	   WHEN (VisitDate >= '2017-04-03' AND VisitDate <= '2018-02-07') OR SubjectID='3055010001' THEN '0'
	   WHEN (VisitDate >= '2018-02-08' AND VisitDate <= '2018-09-30') THEN '1-2'
	   WHEN (VisitDate >= '2018-10-01' AND VisitDate <= '2019-07-31') THEN '3'
	   WHEN VisitDate >= '2019-08-01' THEN '4'
	   ELSE ''
	   END AS EligibilityVersion

INTO #B2

FROM 
(
SELECT ENROLLDRUG.SiteID
      ,CASE WHEN S.ACTIVE='t' THEN 'Active'
	   WHEN S.ACTIVE='f' THEN 'Inactive'
	   ELSE ''
	   END AS SiteStatus
	  ,ENROLLDRUG.VisitID as VisitID
	  ,ENROLLDRUG.SubjectID AS SubjectID
	  ,ENROLLDRUG.VisitDate
	  ,ENROLLDRUG.VisitType
	  ,E2.MD_COD AS ProviderID
	  ,ES2.BIRTHDATE AS YearOfBirth
	  ,A.YearOfDiagnosis
	  
	  ,STUFF((
        SELECT ', '+ Diagnosis 
        FROM #A2 A
		WHERE A.VisitID=E2.vID
        FOR XML PATH('')
		)
		,1,1,'') AS Diagnosis

FROM [PSA400].[v_op_v2_Drugs_Enroll] ENROLLDRUG
LEFT JOIN  [MERGE_SPA_UAT].[dbo].[DAT_SITES] S ON S.SITENUM=ENROLLDRUG.SiteID
LEFT JOIN [MERGE_SPA_UAT].[staging].[EPRO_01] E2 ON E2.vID=ENROLLDRUG.VisitID
LEFT JOIN #A2 A ON A.VisitID=E2.vID 
LEFT JOIN [MERGE_SPA_UAT].[staging].[ESUB_01] ES2 ON ES2.vID=ENROLLDRUG.VisitID

) ENROLLMENT2


--SELECT * FROM #B2 WHERE SubjectID=3140010135


IF OBJECT_ID('tempdb.dbo.#V1_2') IS NOT NULL BEGIN DROP TABLE #V1_2 END;

/*******All drugs and drug hierarchy at Enrollment from Version 1.2******/

SELECT DISTINCT [DrugHierarchy]
      ,[VisitID]
      ,[SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[PageDescription]
	  ,[PageStatus]
      ,[TreatmentName]
      ,[ChangesToday]
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,CASE WHEN ISNULL(TreatmentStartMonth, '')='' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(TreatmentStartMonth, '')<>'' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
      ,[Cohort]

  INTO #V1_2
  FROM [PSA400].[v_op_v12_Drugs]
  WHERE VisitType LIKE 'Enroll%'

  

  --SELECT * FROM #V1_2 WHERE Cohort='Investigational Drug' ORDER BY SiteID, SubjectID

IF OBJECT_ID('tempdb..#C1_2') IS NOT NULL BEGIN DROP TABLE #C1_2 END;

/*******All drugs and drug hierarchy at Enrollment from Version 1.2******/

SELECT DISTINCT B.[VisitID]
      ,B.[SiteID]
	  ,B.SiteStatus
      ,B.[SubjectID]
      ,B.[VisitType]
      ,B.[VisitDate]
	  ,B.ProviderID
	  ,B.YearOfBirth
	  ,B.YearOfDiagnosis
	  ,B.Diagnosis
	  ,B.EligibilityVersion
	  ,NULL AS AlternateDrugHierarchy
	  ,V1_2.DrugHierarchy
      ,V1_2.[PageDescription]
      ,V1_2.[TreatmentName]
	  ,TreatmentStartYear
	  ,TreatmentStartMonth                                                               
	  ,CASE WHEN ISNULL(TreatmentStartMonth, '')='' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(TreatmentStartMonth, '')<>'' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
	  ,V1_2.[TreatmentName] AS DrugOfInterest
	  ,V1_2.[PageStatus]
	  ,'-' AS DrugReqSatisfied
	  ,'-' AS FirstTimeUse
      ,V1_2.[ChangesToday]
      ,V1_2.[Cohort]
	  
	  ,STUFF((
        SELECT ', ' + TreatmentName 
        FROM #V1_2 A
		WHERE A.VisitID=V1_2.VisitID
		AND A.DrugHierarchy<>1
		AND A.PageDescription='Biologics V1.2'
		AND A.ChangesToday NOT IN ('N/A (no longer in use)', 'Stop Drug')
        FOR XML PATH('')
        )
        ,1,1,'') AS AdditionalDOI

  INTO #C1_2
  FROM  #B1_2 B
  LEFT JOIN #V1_2 V1_2 ON V1_2.VisitID=B.VisitID
  ---WHERE V1_2.DrugHierarchy=1

--SELECT * FROM #C1_2 WHERE Cohort = 'Investigational Drug' ORDER BY SiteID, SubjectID, DrugHierarchy


IF OBJECT_ID('tempdb.dbo.#C2A') IS NOT NULL BEGIN DROP TABLE #C2A END;

/*******All drugs and drug hierarchy at Enrollment from REIMBURSEMENT VIEWS******/

SELECT DISTINCT B.[VisitID]
      ,B.[SiteID]
	  ,B.SiteStatus
      ,B.[SubjectID]
      ,B.[VisitType]
      ,B.[VisitDate]
	  ,B.ProviderID
	  ,B.YearOfBirth
	  ,B.YearOfDiagnosis
	  ,B.Diagnosis
	  ,B.EligibilityVersion
	  ,DH.Diagnosed_DATA AS R_Diagnosis
	  ,DH.PAGEDISPLAY AS PageDescription
	  ,DH.PAGESEQ AS PageSequence
	  ,DE.PageStatus
	  ,DE.TreatmentName
	  ,DE.TreatmentStartYear
	  ,DE.TreatmentStartMonth
	  ,CASE WHEN ISNULL(DE.TreatmentStartMonth, '')='' AND ISNULL(DE.TreatmentStartYear, '')<>'' THEN (CAST(DE.TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(DE.TreatmentStartMonth, '')<>'' AND ISNULL(DE.TreatmentStartYear, '')<>'' THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,DE.TreatmentStopYear
	  ,DE.TreatmentStopMonth
	  ,DRUG.DRUG_DOSE_DEC AS CurrentDose
	  ,DRUG.DRUG_PAST_DOSE_DEC AS PastDose
	  ,DH.Hierarchy_DATA AS DrugHierarchy
	  ,CASE WHEN DH.DrugReqSatisfied=1 THEN 'yes'
	   ELSE 'no'
	   END AS DrugReqSatisfied
	  ,DE.FirstTimeUse
	  ,DE.ChangesToday
	  ,CASE WHEN DH.DRUG_NAME_DEC='apremilast (Otezla)' AND B.[VisitDate]<'2021-03-16' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN DH.DRUG_NAME_DEC='apremilast (Otezla)' AND B.[VisitDate]>='2021-03-16' THEN 'Comparator Biologic'
	   WHEN DH.DRUG_NAME_DEC='Investigational Drug' THEN 'Investigational Drug'
	   WHEN DH.Cohort_LOGIC='IL-17 or JAKi' AND B.[VisitDate]<'2021-03-16' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN DH.Cohort_LOGIC='IL-17 or JAKi' AND B.[VisitDate]>='2021-03-16' THEN 'IL-17, JAK or IL-23 Inhibitor'
	   WHEN DH.DRUG_NAME_DEC='prednisone' THEN 'csDMARD'
	   WHEN DH.DRUG_NAME_DEC ='anakinra (Kineret)' THEN 'Comparator Biologic'
	   WHEN DH.DRUG_NAME_DEC='guselkumab (Tremfya)' AND B.[VisitDate]<'2021-03-16' THEN 'Comparator Biologic'
	   WHEN DH.DRUG_NAME_DEC='guselkumab (Tremfya)' AND B.[VisitDate]>='2021-03-16' THEN 'IL-17, JAK or IL-23 Inhibitor'
	   WHEN DH.Cohort_LOGIC='Comparator Biologics' THEN 'Comparator Biologic'
	   WHEN DE.TreatmentName IN ('No treatment', 'Pending') THEN 'n/a'
	   WHEN ISNULL(DH.Cohort_LOGIC, '')='' THEN 
	        (SELECT [Cohort] FROM #DrugCohort DC WHERE DH.DRUG_NAME_DEC=DC.[Drug])
	   ELSE DH.Cohort_LOGIC 
	   END AS Cohort

INTO #C2A

FROM  #B2 B
JOIN [PSA400].[v_op_v2_Drugs_Enroll] DE ON B.VisitID=DE.VisitID
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] DH ON DH.SourceVisitID=B.VisitID AND DH.SUBNUM=DE.SubjectID AND DH.PAGESEQ=DE.PageSequence AND DH.PAGEDISPLAY=DE.PageDescription
LEFT JOIN [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] DPP ON DPP.SourceVisitID=DH.SourceVisitID AND DPP.SUBNUM=DH.SUBNUM AND DPP.DRUG_NAME_DEC=DH.DRUG_NAME_DEC AND DPP.PAGESEQ=DH.PAGESEQ
LEFT JOIN [MERGE_SPA_UAT].[staging].[DRUG] ON DRUG.vID=DH.SourceVisitID AND DRUG.SUBNUM=DH.SUBNUM AND DRUG.DRUG_NAME_DEC=DH.DRUG_NAME_DEC AND DRUG.PAGESEQ=DH.PAGESEQ

--SELECT * FROM #C2A WHERE ISNULL(Cohort, '')='Investigational Drug' ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb.dbo.#C2') IS NOT NULL BEGIN DROP TABLE #C2 END;

/*******All drugs and drug hierarchy at Enrollment from REIMBURSEMENT VIEWS******/

SELECT DISTINCT C2A.[VisitID]
      ,C2A.[SiteID]
	  ,C2A.SiteStatus
      ,C2A.[SubjectID]
      ,C2A.[VisitType]
      ,C2A.[VisitDate]
	  ,C2A.ProviderID
	  ,C2A.YearOfBirth
	  ,C2A.YearOfDiagnosis
	  ,C2A.Diagnosis
	  ,C2A.EligibilityVersion
	  ,C2A.R_Diagnosis
	  ,C2A.PageDescription
	  ,C2A.PageSequence
	  ,C2A.PageStatus
	  ,KE.TreatmentName AS TreatmentName
	  ,C2A.TreatmentStartYear
	  ,C2A.TreatmentStartMonth
	  ,CASE WHEN ISNULL(C2A.TreatmentStartMonth, '')='' AND ISNULL(C2A.TreatmentStartYear, '')<>'' AND LEN(C2A.TreatmentStartYear)=4 THEN (CAST(C2A.TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(C2A.TreatmentStartMonth, '')<>'' AND ISNULL(C2A.TreatmentStartYear, '')<>'' AND LEN(C2A.TreatmentStartYear)=4 THEN (CAST(C2A.TreatmentStartYear AS nvarchar) + '-' + FORMAT(C2A.TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,C2A.TreatmentStopYear
	  ,C2A.TreatmentStopMonth
	  ,C2A.CurrentDose
	  ,C2A.PastDose
	  ,C2A.DrugHierarchy AS REIMBDrugHierarchy
	  ,KE.DrugHierarchy AS AltDrugHierarchy
	  ,CASE WHEN ISNULL(C2A.DrugHierarchy, '')<>ISNULL(KE.DrugHierarchy, '') THEN KE.DrugHierarchy
	   ELSE C2A.DrugHierarchy
	   END AS DrugHierarchy
	  ,C2A.DrugReqSatisfied
	  ,C2A.FirstTimeUse
	  ,C2A.ChangesToday
	  ,C2A.Cohort

INTO #C2

FROM [Reporting].[PSA400].[v_op_v2_Drugs_Enroll] KE
LEFT JOIN #C2A C2A ON KE.VisitID=C2A.VisitID AND ISNULL(KE.PageDescription, '')=ISNULL(C2A.PageDescription, '') AND ISNULL(KE.PageSequence, '')=ISNULL(C2A.PageSequence, '')

--SELECT * FROM #C2 WHERE Cohort='Investigational Drug' ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb.dbo.#AltDrugHierarchy') IS NOT NULL BEGIN DROP TABLE #AltDrugHierarchy END;

/*****GET ALTERNATIVE DRUG HIERARCHY*****/

SELECT DrugHierarchy
      ,VisitID
      ,SiteID
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,PageDescription
	  ,PageSequence
	  ,TreatmentName
	  ,ChangesToday

INTO #AltDrugHierarchy
FROM [PSA400].[v_op_v2_Drugs_Enroll]

--SELECT * FROM #AltDrugHierarchy WHERE Cohort='Investigational Drug' ORDER BY SiteID, SubjectID, DrugHierarchy

IF OBJECT_ID('tempdb.dbo.#D') IS NOT NULL BEGIN DROP TABLE #D END;

/*******Drug of Interest at Enrollment and Other DOI at Enrollment FROM REIMBURSEMENT VIEW******/
SELECT *
INTO #D
FROM
(
SELECT B.VisitID
      ,B.SiteID
	  ,B.SiteStatus
	  ,B.SubjectID
	  ,B.VisitType
	  ,B.VisitDate
	  ,B.ProviderID
	  ,B.YearOfBirth
	  ,B.YearOfDiagnosis
	  ,B.Diagnosis
	  ,B.EligibilityVersion
	  ,ADH.DrugHierarchy AS AlternateDrugHierarchy
	  ,C.DrugHierarchy
	  ,C.PageDescription
	  ,C.PageSequence
	  ,C.TreatmentName
	  ,C.TreatmentStartYear
	  ,C.TreatmentStartMonth
	  ,CASE WHEN ISNULL(TreatmentStartMonth, '')='' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(TreatmentStartMonth, '')<>'' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,C.TreatmentStopYear
	  ,C.TreatmentStopMonth
	  ,C.CurrentDose
	  ,C.PastDose
	  ,CASE WHEN C.Cohort='csDMARD' THEN 'csDMARD or steroid only'
	   WHEN C.PageDescription IN ('Conventional DMARDs', 'cDMARDs') THEN 'csDMARD or steroid only'
	   WHEN ISNULL(C.PageDescription, '')='' THEN 'No Treatment'
	   WHEN C.PageDescription IN ('Biologics', 'Biosimilars') AND C.ChangesToday='N/A (no longer in use)' THEN 'past biologic or JAKi use'
	   WHEN C.PageDescription IN ('Biologics', 'Biosimilars') THEN C.TreatmentName 
	   ELSE ''
	   END AS DrugOfInterest
	  ,C.PageStatus
	  ,C.DrugReqSatisfied
	  ,C.FirstTimeUse
	  ,C.ChangesToday
	  ,C.Cohort
	  ,STUFF((
        SELECT ', '+ TreatmentName 
        FROM #C2 C1
		WHERE C1.VisitID=C.VisitID
		AND DrugHierarchy<>1
		AND PageDescription='Biologics'
		and C1.ChangesToday NOT IN ('N/A (no longer in use)', 'Stop')
        FOR XML PATH('')
        )
        ,1,1,'') AS AdditionalDOI

FROM #B2 B
LEFT JOIN #C2 C ON B.VisitID=C.VisitID AND B.SubjectID=C.SubjectID
LEFT JOIN #AltDrugHierarchy ADH ON ADH.VisitID=C.VisitID AND ADH.TreatmentName=C.TreatmentName AND ADH.ChangesToday=C.ChangesToday
---WHERE C.DrugHierarchy=1

) REIMB

--SELECT* FROM #D WHERE Cohort='Investigational Drug'



IF OBJECT_ID('tempdb..#E') IS NOT NULL BEGIN DROP TABLE #E END;

/*******Combine V1.2 AND V2******/

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
	  ,AlternateDrugHierarchy
	  ,DrugHierarchy
	  ,PageDescription
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,CASE WHEN ISNULL(TreatmentStartDate, '')='' THEN CAST(NULL AS date)
	   ELSE CONVERT(date, TreatmentStartDate, 23) 
	   END AS TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
	  ,DrugOfInterest
	  ,AdditionalDOI
	  ,PageStatus
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort

INTO #E

FROM
(
SELECT VisitID
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
	  ,AlternateDrugHierarchy
	  ,DrugHierarchy
	  ,PageDescription
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,CASE WHEN ISNULL(TreatmentStartMonth, '')='' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(TreatmentStartMonth, '')<>'' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
	  ,DrugOfInterest
	  ,PageStatus
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,AdditionalDOI
FROM #D

UNION

SELECT VisitID
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
	  ,AlternateDrugHierarchy
	  ,DrugHierarchy
	  ,PageDescription
	  ,TreatmentName
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,CASE WHEN ISNULL(TreatmentStartMonth, '')='' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + '06' + '-' + '15')
	   WHEN ISNULL(TreatmentStartMonth, '')<>'' AND ISNULL(TreatmentStartYear, '')<>'' AND LEN(TreatmentStartYear)=4 THEN (CAST(TreatmentStartYear AS nvarchar) + '-' + FORMAT(TreatmentStartMonth, '00') + '-' + '15')
	   ELSE ''
	   END AS TreatmentStartDate
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
	  ,DrugOfInterest
	  ,PageStatus
	  ,DrugReqSatisfied
	  ,FirstTimeUse
	  ,ChangesToday
	  ,Cohort
	  ,AdditionalDOI

FROM #C1_2
WHERE ISNULL(DrugOfInterest, '')<>''
) AllEnrollDrugs

--SELECT * FROM #E WHERE Cohort='Investigational Drug' ORDER BY SiteID, SubjectID


TRUNCATE TABLE [Reporting].[PSA400].[t_op_UAT_Enrollment_Drugs];

INSERT INTO [Reporting].[PSA400].[t_op_UAT_Enrollment_Drugs]

SELECT DISTINCT VisitID,
       SiteID, 
	   SiteStatus,
	   SubjectID,
	   VisitType,
	   VisitDate,
	   ProviderID,
	   YearOfBirth,
	   YearOfDiagnosis,
	   Diagnosis,
	   EligibilityVersion,
	   CASE WHEN AlternateDrugHierarchy<>DrugHierarchy THEN AlternateDrugHierarchy
	   ELSE DrugHierarchy
	   END AS DrugHierarchy,
	   PageDescription,
	   TreatmentName,
	   TreatmentStartYear,
	   TreatmentStartMonth,
	   TreatmentStartDate,
	   TreatmentStopYear,
	   TreatmentStopMonth,
	   CurrentDose,
	   PastDose,
	   CASE WHEN UPPER(E.TreatmentName) LIKE '%OTHER: COSENT%' AND E.ChangesToday<>'N/A (no longer in use)' THEN 'secukinumab (Cosentyx)'
	   WHEN E.TreatmentName LIKE '%Other: consentyx%'AND E.ChangesToday<>'N/A (no longer in use)' THEN 'secukinumab (Cosentyx)'
	   WHEN UPPER(E.TreatmentName) LIKE '%OTHER: HUMIRA%' AND E.ChangesToday<>'N/A (no longer in use)' THEN 'adalimumab (Humira)'
	   WHEN UPPER(E.TreatmentName) LIKE '%OTHER: OTEZLA%' AND E.ChangesToday<>'N/A (no longer in use)' THEN 'apremilast (Otezla)'
	   WHEN UPPER(E.TreatmentName) LIKE '%OTHER: USTEKINUMAB%' AND E.ChangesToday<>'N/A (no longer in use)' THEN 'ustekinumab (Stelara)'
	   WHEN UPPER(E.TreatmentName) LIKE '%OTHER: ETANERCEPT%' AND E.ChangesToday<>'N/A (no longer in use)' THEN 'etanercept (Enbrel)'
	   WHEN UPPER(E.TreatmentName) LIKE '%OTHER: REMICADE%'  AND E.ChangesToday<>'N/A (no longer in use)' THEN 'infliximab (Remicade)'
	   ELSE E.TreatmentName
	   END AS DrugOfInterest,
	   AdditionalDOI,
	   PageStatus,
	   DrugReqSatisfied,
	   FirstTimeUse,
	   ChangesToday,
	   Cohort
FROM #E E

--SELECT * FROM #E WHERE SubjectID IN (3035030189) ORDER BY SiteID, SubjectID


--SELECT * FROM [Reporting].[PSA400].[t_op_Enrollment_Drugs] ORDER BY SiteID, SubjectID, DrugHierarchy


/*******Calculate Eligibility AND REVIEW OUTCOME AND INSERT INTO ENROLL TABLE******/

TRUNCATE TABLE [Reporting].[PSA400].[t_op_UAT_CAT_Enrollment];

INSERT INTO [Reporting].[PSA400].[t_op_UAT_CAT_Enrollment]

SELECT DISTINCT E.VisitID
      ,E.SiteID
	  ,E.SiteStatus
	  ,E.SubjectID
	  ,CASE WHEN E.VisitType LIKE 'Enroll%' THEN 'Enrollment'
	   WHEN E.VisitType LIKE 'Follow%' THEN 'Follow Up'
	   ELSE E.VisitType
	   END AS VisitType
	  ,E.VisitDate
	  ,E.ProviderID
	  ,E.YearOfBirth
	  ,E.YearOfDiagnosis
	  ,E.Diagnosis
	  ,E.EligibilityVersion
	  ,E.DrugHierarchy
	  ,CASE WHEN ISNULL(E.PageDescription, '')='' AND TreatmentName IN ('No Treatment', 'Pending') THEN 'missing'
	   ELSE E.PageDescription
	   END AS PageDescription
	  ,E.TreatmentName
	  ,E.TreatmentStartYear
	  ,E.TreatmentStartMonth
	  ,E.TreatmentStartDate
	  ,E.TreatmentStopYear
	  ,E.TreatmentStopMonth
	  ,E.CurrentDose
	  ,E.PastDose
	  ,E.DrugOfInterest
	  ,E.AdditionalDOI
	  ,CASE WHEN ISNULL(E.PageStatus, '')='' THEN 'missing'
	   ELSE E.PageStatus
	   END AS PageStatus
	  ,CASE WHEN E.DrugOfInterest=E.TreatmentName AND E.ChangesToday LIKE '%Start%' THEN 'prescribed at visit'
	   WHEN E.DrugOfInterest=E.TreatmentName AND E.ChangesToday IN ('No changes', 'Modify', 'Change Dose') THEN 'continued'
	   WHEN E.DrugOfInterest=E.TreatmentName AND E.ChangesToday LIKE '%Stop%' THEN 'discontinued at enrollment'
	   WHEN E.ChangesToday='N/A (no longer in use)' AND E.PageDescription LIKE '%Biologics%' THEN 'past biologic or JAKi use'
	   WHEN E.DrugOfInterest='csDMARD or steroid only' THEN '-'
	   WHEN E.DrugOfInterest<>E.TreatmentName THEN '-'
	   ELSE ''
	   END AS DOIInitiationStatus

	  ,CASE WHEN E.DrugOfInterest IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz XR)', 'tofacitinib (Xeljanz)', 'guselkumab (Tremfya)') THEN 'yes'
	   WHEN E.DrugOfInterest=TreatmentName AND E.DrugOfInterest NOT IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz XR)', 'tofacitinib (Xeljanz)', 'guselkumab (Tremfya)') THEN 'no'
	   WHEN E.DrugOfInterest<>E.TreatmentName THEN '-'
	   ELSE ''
	   END AS SubscriberDOI

	  ,E.DrugReqSatisfied
	  ,E.FirstTimeUse
	  ,E.ChangesToday
	  ,E.Cohort

	  ,R.INELIGIBLE_DEC
	  ,R.INELIGIBLE_EXCEPTION_DEC

	  ,CASE WHEN E.EligibilityVersion='99' THEN 'Eligible'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='yes' AND (R.INELIGIBLE_DEC='Yes' OR (ISNULL(R.INELIGIBLE_DEC, '')='' AND ISNULL(R.INELIGIBLE_EXCEPTION_DEC, '')='')) THEN 'Eligible'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='no' AND (R.INELIGIBLE_DEC = 'Yes' OR R.INELIGIBLE_EXCEPTION_DEC='Yes') THEN 'Eligible - by Override'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='yes' AND (R.INELIGIBLE_DEC = 'Yes' OR R.INELIGIBLE_EXCEPTION_DEC='Yes') THEN 'Eligible'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='yes' AND (R.INELIGIBLE_DEC='No' AND ISNULL(R.INELIGIBLE_EXCEPTION_DEC, '') IN ('', 'No')) THEN 'Not eligible - Confirmed'
	   WHEN E.EligibilityVersion<>'99' AND (E.DrugReqSatisfied='no' OR ISNULL(E.DrugReqSatisfied, '')='') AND ISNULL(R.INELIGIBLE_DEC, '')='' THEN 'Needs review'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='no' AND ISNULL(R.INELIGIBLE_DEC, '')='No' AND ISNULL(R.INELIGIBLE_EXCEPTION_DEC, '')='No' THEN 'Not eligible - Confirmed'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='no' AND ISNULL(R.INELIGIBLE_DEC, '')='' AND ISNULL(R.INELIGIBLE_EXCEPTION_DEC, '')='' THEN 'Not eligible'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='yes' AND (R.INELIGIBLE_DEC='Yes') THEN 'Eligible'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='yes' AND R.INELIGIBLE_DEC='Under review (outcome TBD)' THEN 'Eligible'
	   WHEN E.EligibilityVersion<>'99' AND E.DrugReqSatisfied='no' AND R.INELIGIBLE_DEC='Under review (outcome TBD)' THEN 'Not eligible'
	   ELSE '-'
	   END AS RegistryEnrollmentStatus

	  ,CASE WHEN R.INELIGIBLE_DEC = 'Yes' THEN 'Eligible'
	   WHEN R.INELIGIBLE_EXCEPTION_DEC='Yes' THEN 'Not Eligible - Exception Granted'
	   WHEN R.INELIGIBLE_DEC = 'No' AND R.INELIGIBLE_EXCEPTION_DEC<>'Yes' THEN 'Not eligible'
	   WHEN R.INELIGIBLE_DEC='Under review (outcome TBD)' THEN 'Under review'
	   ELSE ''
	   END AS ReviewOutcome

FROM #E E
LEFT JOIN [MERGE_SPA_UAT].[staging].[REIMB] R ON R.vID=E.VisitID
WHERE DrugHierarchy=1



--SELECT * FROM [Reporting].[PSA400].[t_op_CAT_Enrollment] WHERE SubjectID=3035030189 OR TreatmentName LIKE '%Tremfy%'  ORDER BY SiteID, SubjectID, DrugHierarchy
--SELECT DISTINCT Cohort FROM [Reporting].[PSA400].[t_op_CAT_Enrollment]

END

GO
