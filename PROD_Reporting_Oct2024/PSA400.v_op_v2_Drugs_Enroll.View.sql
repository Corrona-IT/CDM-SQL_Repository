USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_v2_Drugs_Enroll]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/*****This was programmed separately by CDM programmer - Use Reimbursement Views for standardized drug listing from V2*****/

CREATE VIEW [PSA400].[v_op_v2_Drugs_Enroll]  AS



/***********Drugs from DRUG table at Enrollment***********/

WITH DrugCohort AS
(
SELECT DISTINCT [CorronaRegistryID]
      ,[Drug]
      ,CASE WHEN [Cohort]='Otezla' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN [Cohort]='IL-17 or JAKi' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN [Drug] IN ('guselkumab (Tremfya)', 'anakinra (Kineret)') THEN 'Comparator Biologic'
	   WHEN [Cohort]='Comparator Biologics' THEN 'Comparator Biologic'
	   ELSE [Cohort]
	   END AS [Cohort]

  FROM [Reimbursement].[Reference].[t_DrugHierarchy]
WHERE [CorronaRegistryID]=3
)


,SUBJECTS AS (
SELECT DISTINCT V.vID, 
       V.SITENUM, 
	   V.SUBNUM, 
	   V.VISNAME, 
	   EPRO.pagename,
	   V.VISITDATE, 
	   V.STATUSID_DEC
FROM [MERGE_SPA].[staging].[VS_01] V
JOIN [MERGE_SPA].[staging].[EPRO_01] EPRO ON EPRO.vID=V.vID
WHERE v.VISNAME LIKE 'Enroll%'
AND V.SITENUM NOT IN (99997, 99998, 99999)
UNION 
SELECT DISTINCT V.vID, 
       V.SITENUM, 
	   V.SUBNUM, 
	   V.VISNAME,
	   'MISSING' AS pagename, 
	   V.VISITDATE, 
	   V.STATUSID_DEC
FROM [MERGE_SPA].[staging].[VS_01] V
WHERE v.VISNAME LIKE 'Enroll%'
AND VISITDATE >='2018-01-01'
)
--select * from [MERGE_SPA].[staging].[EPRO_01] V where subnum in (3093010020, 3093010021, 3100471039, 3100500104, 3167010045, 3234010006)
--SELECT * FROM [MERGE_SPA].[staging].[VS_01] V WHERE subnum in (3093010020, 3093010021, 3100471039, 3100500104, 3167010045, 3234010006) 
--AND V.SUBNUM IN (3093010020, 3093010021, 3100471039, 3100500104, 3167010045, 3234010006) ORDER BY subnum


SELECT ROW_NUMBER() OVER(PARTITION BY VisitID, SiteID, SubjectID ORDER BY SiteID, SubjectID, ChangesTodayHierarchy, DrugHierarchyLogic, CohortHierarchy, TreatmentStartYear DESC) AS DrugHierarchy
       ,VisitID
	   ,SiteID
	   ,SubjectID
	   ,VisitType
	   ,VisitDate
	   ,VisitStatus
	   ,PageDescription
	   ,PageSequence
	   ,PageStatus
	   ,TreatmentName	  
	   ,TreatmentStartYear
	   ,TreatmentStartMonth
	   ,TreatmentStopYear
	   ,TreatmentStopMonth
	   ,DrugHierarchyLogic
	   ,ChangesToday
	   ,ChangesTodayHierarchy
	   ,FirstTimeUse
	   ,PastUse
	   ,CurrentUse
	   ,Cohort
	   ,CohortHierarchy
FROM
(

SELECT DISTINCT S.vID AS VisitID
      ,S.SITENUM AS SiteID
	  ,S.SUBNUM AS SubjectID
	  ,'Enrollment Visit' AS VisitType
	  ,S.VISITDATE AS VisitDate
	  ,S.STATUSID_DEC AS VisitStatus
	  ,D.PAGENAME AS PageDescription
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.PAGESEQ AS PageSequence
	  ,CASE WHEN ISNULL(D.DRUG_NAME_OTHER, '')<>'' THEN D.DRUG_NAME_DEC + ': ' + D.DRUG_NAME_OTHER
	   WHEN S.STATUSID_DEC='Complete' AND D.DRUG_NAME_DEC IS NULL THEN 'No Treatment'
	   WHEN S.STATUSID_DEC='Data Entered' AND D.DRUG_NAME_DEC IS NULL THEN 'Pending' 
	   ELSE D.DRUG_NAME_DEC
	   END AS TreatmentName

	  ,D.DRUG_HX_ST_YR AS TreatmentStartYear
	  ,D.DRUG_HX_ST_MO AS TreatmentStartMonth
	  ,D.DRUG_HX_STP_YR AS TreatmentStopYear
	  ,D.DRUG_HX_STP_MO AS TreatmentStopMonth

	  ,CASE WHEN D.DRUG_NAME_DEC IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') AND D.DRUG_RX_TODAY_DEC NOT IN ('N/A (no longer in use)', 'Stop') THEN 50
	   WHEN D.DRUG_NAME_DEC='Investigational Drug' AND ISNULL(D.DRUG_USE_PAST, '')='' AND ISNULL(RDH.CohortHierarchy, '')='' THEN 270
	   WHEN D.PAGENAME IN ('Biologics', 'Biosimilars') AND D.PAGENAME IN ('Biologics', 'Biosimilars') AND D.DRUG_NAME_DEC NOT IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') AND D.DRUG_RX_TODAY_DEC NOT IN ('N/A (no longer in use)', 'Stop') AND ISNULL(RDH.CohortHierarchy, '')='' THEN 160
	   WHEN D.PAGENAME IN ('Biologics', 'Biosimilars') AND ISNULL(RDH.CohortHierarchy, '')='' AND D.DRUG_RX_TODAY_DEC IN ('N/A (no longer in use)', 'Stop') THEN 400
	   WHEN D.PAGENAME='Conventional DMARDs' AND D.DRUG_RX_TODAY_DEC NOT IN ('N/A (no longer in use)', 'Stop') AND ISNULL(RDH.CohortHierarchy, '')='' THEN 600
	   WHEN D.PAGENAME='Conventional DMARDs' AND D.DRUG_RX_TODAY_DEC IN ('N/A (no longer in use)', 'Stop') AND ISNULL(RDH.CohortHierarchy, '')='' THEN 700
	   WHEN D.PAGENAME IS NULL AND S.STATUSID_DEC NOT IN ('No Data', 'Incomplete') THEN 800
	   WHEN D.PAGENAME IS NULL AND S.STATUSID_DEC IN ('No Data', 'Incomplete') THEN 50
	   ELSE RDH.CohortHierarchy 
	   END AS DrugHierarchyLogic

	  ,D.DRUG_RX_TODAY_DEC AS ChangesToday

	  ,CASE WHEN D.DRUG_NAME_DEC IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') AND D.DRUG_RX_TODAY_DEC='Start' THEN 10
	   WHEN D.DRUG_RX_TODAY_DEC='Start' AND D.PAGENAME IN ('Biologics', 'Biosimilars') THEN 15
	   WHEN D.DRUG_RX_TODAY_DEC IN ('No changes', 'Modify') AND D.DRUG_NAME_DEC IN ('secukinumab (Cosentyx)', 'ixekizumab (Taltz)', 'tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)') THEN 20
	   WHEN D.DRUG_RX_TODAY_DEC IN ('No changes', 'Modify') AND D.PAGENAME IN ('Biologics', 'Biosimilars') AND ISNULL(D.DRUG_DOSE_DEC,'')<>''THEN 25
	   WHEN D.DRUG_RX_TODAY_DEC IN ('No changes', 'Modify') AND D.PAGENAME IN ('Biologics', 'Biosimilars') AND ISNULL(D.DRUG_DOSE_DEC,'')=''THEN 30
	   WHEN D.DRUG_RX_TODAY_DEC='Start' AND D.PAGENAME='Conventional DMARDs' THEN 35
	   WHEN D.DRUG_RX_TODAY_DEC IN ('No changes', 'Modify') AND D.PAGENAME='Conventional DMARDs' THEN 40
	   WHEN D.DRUG_RX_TODAY_DEC IN ('Stop', 'N/A (no longer in use)') AND D.PAGENAME IN ('Biologics', 'Biosimilars') THEN 50
	   WHEN D.DRUG_RX_TODAY_DEC IN ('Stop', 'N/A (no longer in use)') AND D.PAGENAME='Conventional DMARDs' THEN 60
	   ELSE 70
	   END AS ChangesTodayHierarchy

	  ,CASE WHEN DRUG_NO_PRIOR_USE='X' THEN 'yes'
	   ELSE ''
	   END AS FirstTimeUse

	  ,D.DRUG_USE_PAST AS PastUse
	  ,D.DRUG_USE_CUR AS CurrentUse

	  ,CASE WHEN D.PAGENAME='Conventional DMARDs' THEN 'csDMARD'
	   WHEN D.DRUG_NAME_DEC='Investigational Drug' THEN 'Investigational drug'
	   ELSE DC.Cohort
	   END AS Cohort

	  ,CASE WHEN D.PAGENAME='Biologics' THEN 200
	   WHEN D.PAGENAME='Biosimilars' THEN 300
	   WHEN D.PAGENAME='Conventional DMARDs' THEN 800
	   WHEN D.DRUG_NAME_DEC='Investigational Drug' THEN 700
	   ELSE RDH.CohortHierarchy
	   END AS CohortHierarchy

FROM SUBJECTS S
LEFT JOIN [MERGE_SpA].[staging].[DRUG] D ON D.vID=S.vID AND D.PAGENAME IN ('Conventional DMARDs', 'Biologics', 'Biosimilars')
LEFT JOIN [Reimbursement].[Reference].[t_DrugHierarchy] RDH ON RDH.Drug=D.DRUG_NAME_DEC AND S.VISITDATE BETWEEN RDH.StartDate AND RDH.EndDate AND RDH.CorronaRegistryID=3 --Drug Hierarchy by date
  LEFT JOIN DrugCohort DC ON DC.Drug=D.DRUG_NAME_DEC --Drug Cohort only

) DRUGTABLE
WHERE SiteID NOT IN (99999, 99998, 99997)

GO
