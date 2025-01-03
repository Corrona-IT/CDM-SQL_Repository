USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_v12_Drugs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [PSA400].[v_op_v12_Drugs]  AS

 
WITH V1_2Drugs AS

(
--Investigational Agent
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'Investigational Drug' AS TreatmentName
	  ,CASE WHEN ISNULL([INVEST_AGENT_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([INVEST_AGENT_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [INVEST_AGENT_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.INVEST_AGENT_DT_ST_YR AS TreatmentStartYear
	  ,D.INVEST_AGENT_DT_ST_MO AS TreatmentStartMonth
	  ,D.INVEST_AGENT_DT_STP_YR AS TreatmentStopYear
	  ,D.INVEST_AGENT_DT_STP_MO AS TreatmentStopMonth
	  ,'' AS CurrentDose
	  ,'' AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE INVEST_AGENT_USE='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Orencia
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'abatacept (Orencia)' AS TreatmentName
	  ,CASE WHEN ISNULL([ORENCIA_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([ORENCIA_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [ORENCIA_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.ORENCIA_DT_ST_YR AS TreatmentStartYear
	  ,D.ORENCIA_DT_ST_MO AS TreatmentStartMonth
	  ,D.ORENCIA_DT_STP_YR AS TreatmentStopYear
	  ,D.ORENCIA_DT_STP_MO AS TreatmentStopMonth
	  ,D.ORENCIA_DOSE8_DEC AS CurrentDose
	  ,D.ORENCIA_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [ORENCIA_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Humira
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'adalimumab (Humira)' AS TreatmentName
	  ,CASE WHEN ISNULL([HUMIRA_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([HUMIRA_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [HUMIRA_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.HUMIRA_DT_ST_YR AS TreatmentStartYear
	  ,D.HUMIRA_DT_ST_MO AS TreatmentStartMonth
	  ,D.HUMIRA_DT_STP_YR AS TreatmentStopYear
	  ,D.HUMIRA_DT_STP_MO AS TreatmentStopMonth
	  ,D.HUMIRA_DOSE8_DEC AS CurrentDose
	  ,D.HUMIRA_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [HUMIRA_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Kineret
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDecription
	  ,'anakinra (Kineret)' AS TreatmentName
	  ,CASE WHEN ISNULL([KINERET_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([KINERET_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [KINERET_CHG_PLAN_TODAY_DEC]
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.KINERET_DT_ST_YR AS TreatmentStartYear
	  ,D.KINERET_DT_ST_MO AS TreatmentStartMonth
	  ,D.KINERET_DT_STP_YR AS TreatmentStopYear
	  ,D.KINERET_DT_STP_MO AS TreatmentStopMonth
	  ,D.KINERET_DOSE_DEC AS CurrentDose
	  ,D.KINERET_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [KINERET_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Cimizia
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'certolizumab pegol (Cimzia)' AS TreatmentName
	  ,CASE WHEN ISNULL([CIMZIA_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([CIMZIA_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [CIMZIA_CHG_PLAN_TODAY_DEC]
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.CIMZIA_DT_ST_YR AS TreatmentStartYear
	  ,D.CIMZIA_DT_ST_MO AS TreatmentStartMonth
	  ,D.CIMZIA_DT_STP_YR AS TreatmentStopYear
	  ,D.CIMZIA_DT_STP_MO AS TreatmentStopMonth
	  ,D.CIMZIA_DOSE_DEC AS CurrentDose
	  ,D.CIMZIA_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [CIMZIA_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Otezla
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'apremilast (Otezla)' as TreatmentName
	  ,CASE WHEN ISNULL([OTEZLA_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([OTEZLA_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [OTEZLA_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.OTEZLA_DT_ST_YR AS TreatmentStartYear
	  ,D.OTEZLA_DT_ST_MO AS TreatmentStartMonth
	  ,D.OTEZLA_DT_STP_YR AS TreatmentStopYear
	  ,D.OTEZLA_DT_STP_MO AS TreatmentStopMonth
	  ,D.OTEZLA_DOSE_DEC AS CurrentDose
	  ,D.OTEZLA_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [OTEZLA_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Enbrel
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'etanercept (Enbrel)' AS TreatmentName
	  ,CASE WHEN ISNULL([ENBREL_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([ENBREL_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [ENBREL_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.ENBREL_DT_ST_YR AS TreatmentStartYear
	  ,D.ENBREL_DT_ST_MO AS TreatmentStartMonth
	  ,D.ENBREL_DT_STP_YR AS TreatmentStopYear
	  ,D.ENBREL_DT_STP_MO AS TreatmentStopMonth
	  ,D.ENBREL_DOSE8_DEC AS CurrentDose
	  ,D.ENBREL_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [ENBREL_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Simponi
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'golimumab (Simponi)' AS TreatmentName
	  ,CASE WHEN ISNULL([SIMPONI_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([SIMPONI_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [SIMPONI_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.SIMPONI_DT_ST_YR AS TreatmentStartYear
	  ,D.SIMPONI_DT_ST_MO AS TreatmentStartMonth
	  ,D.SIMPONI_DT_STP_YR AS TreatmentStopYear
	  ,D.SIMPONI_DT_STP_MO AS TreatmentStopMonth
	  ,D.SIMPONI_DOSE_DEC AS CurrentDose
	  ,D.SIMPONI_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [SIMPONI_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Remicade
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'infliximab (Remicade)' AS TreatmentName
	  ,CASE WHEN ISNULL([REMICADE_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([REMICADE_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [REMICADE_CHG_PLAN_TODAY_DEC]
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.REMICADE_DT_ST_YR AS TreatmentStartYear
	  ,D.REMICADE_DT_ST_MO AS TreatmentStartMonth
	  ,D.REMICADE_DT_STP_YR AS TreatmentStopYear
	  ,D.REMICADE_DT_STP_MO AS TreatmentStopMonth
	  ,CAST(D.REMICADE_DOSE8 AS nvarchar) AS CurrentDose
	  ,CAST(D.REMICADE_DOSE_STP AS nvarchar) AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [REMICADE_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Actemra
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'tocilizumab (Actemra)' AS TreatmentName
	  ,CASE WHEN ISNULL([ACTEMRA_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([ACTEMRA_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [ACTEMRA_CHG_PLAN_TODAY_DEC]
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.ACTEMRA_DT_ST_YR AS TreatmentStartYear
	  ,D.ACTEMRA_DT_ST_MO AS TreatmentStartMonth
	  ,D.ACTEMRA_DT_STP_YR AS TreatmentStopYear
	  ,D.ACTEMRA_DT_STP_MO AS TreatmentStopMonth
	  ,D.ACTEMRA_DOSE_DEC AS CurrentDose
	  ,D.ACTEMRA_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [ACTEMRA_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Xeljanz
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME  AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'tofacitinib (Xeljanz)' AS TreatmentName
	  ,CASE WHEN ISNULL([XELJANZ_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([XELJANZ_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [XELJANZ_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.XELJANZ_DT_ST_YR AS TreatmentStartYear
	  ,D.XELJANZ_DT_ST_MO AS TreatmentStartMonth
	  ,D.XELJANZ_DT_STP_YR AS TreatmentStopYear
	  ,D.XELJANZ_DT_STP_MO AS TreatmentStopMonth
	  ,D.XELJANZ_DOSE_DEC AS CurrentDose
	  ,D.XELJANZ_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [XELJANZ_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Stelara
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'ustekinumab (Stelara)' AS TreatmentName
	  ,CASE WHEN ISNULL([STELARA_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([STELARA_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [STELARA_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.STELARA_DT_ST_YR AS TreatmentStartYear
	  ,D.STELARA_DT_ST_MO AS TreatmentStartMonth
	  ,D.STELARA_DT_STP_YR AS TreatmentStopYear
	  ,D.STELARA_DT_STP_MO AS TreatmentStopMonth
	  ,D.STELARA_DOSE_DEC AS CurrentDose
	  ,D.STELARA_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [STELARA_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Rituxan
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'rituximab (Rituxan)' AS TreatmentName
	  ,CASE WHEN ISNULL([RITUXAN_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([RITUXAN_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [RITUXAN_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.RITUXAN_DT_ST_YR AS TreatmentStartYear
	  ,D.RITUXAN_DT_ST_MO AS TreatmentStartMonth
	  ,NULL AS TreatmentStopYear
	  ,NULL AS TreatmentStopMonth
	  ,CAST(D.RITUXAN_DOSE_STP AS nvarchar) AS CurrentDose
	  ,'' AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [RITUXAN_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Other
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,CASE WHEN ISNULL([OTH_BIO_DESC], '')<>'' THEN 'Other: ' +  [OTH_BIO_DESC] 
	   ELSE 'Other: Not specified'
	   END  AS TreatmentName
	  ,CASE WHEN ISNULL([OTH_BIO_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([OTH_BIO_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [OTH_BIO_CHG_PLAN_TODAY_DEC]
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.OTH_BIO_DT_ST_YR AS TreatmentStartYear
	  ,D.OTH_BIO_DT_ST_MO AS TreatmentStartMonth
	  ,D.OTH_BIO_DT_STP_YR AS TreatmentStopYear
	  ,D.OTH_BIO_DT_STP_MO AS TreatmentStopMonth
	  ,CAST(D.OTH_BIO_DOSE AS nvarchar) AS CurrentDose
	  ,CAST(D.OTH_BIO_DOSE_STP AS nvarchar) AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V	
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [OTH_BIO_USE]='X'
AND D.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--Cosentyx
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics V1.2' AS PageDescription
	  ,'secukinumab (Cosentyx)' AS TreatmentName
	  ,CASE WHEN ISNULL([COSENTYX_DT_STP_YR], '')<>'' THEN 'N/A (no longer in use)'
	   WHEN ISNULL([COSENTYX_CHG_PLAN_TODAY_DEC], '')='' THEN 'No changes'
	   ELSE [COSENTYX_CHG_PLAN_TODAY_DEC] 
	   END AS ChangesToday
	  ,D.STATUSID_DEC AS PageStatus
	  ,D.COSENTYX_DT_ST_YR AS TreatmentStartYear
	  ,D.COSENTYX_DT_ST_MO AS TreatmentStartMonth
	  ,D.COSENTYX_DT_STP_YR AS TreatmentStopYear
	  ,D.COSENTYX_DT_STP_MO AS TreatmentStopMonth
	  ,D.COSENTYX_DOSE_DEC AS CurrentDose
	  ,D.COSENTYX_DOSE_STP_DEC AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
WHERE [COSENTYX_USE]='X'
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--DMARDs/Steroids
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Conventional DMARDs V1.2' AS PageDescription
	  ,'csDMARD or steroid only' AS TreatmentName
	  ,'-' AS ChangesToday
	  ,CSDMARD.STATUSID_DEC AS PageStatus
	  ,NULL AS TreatmentStartYear
	  ,NULL AS TreatmentStartMonth
	  ,NULL AS TreatmentStopYear
	  ,NULL AS TreatmentStopMonth
	  ,'' AS CurrentDose
	  ,'' AS PastDose
FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_05] CSDMARD ON V.vID=CSDMARD.vID
WHERE ([PLAQUENIL_USE]='X' OR [ARAVA_USE]='X' OR [MTX_USE]='X' OR [AZULFIDINE_USE]='X' OR [OTH_DMARD_USE]='X' OR [PRED_USE]='X')
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')

UNION

--No Treatment
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS VisitDate
	  ,'Biologics/Conventional DMARDs (V1.2)' AS PageDescription
	  ,'No Treatment' AS TreatmentName
	  ,'-' AS ChangesToday
	  ,COALESCE(D.STATUSID_DEC,E.STATUSID_DEC) AS PageStatus
	  ,NULL AS TreatmentStartYear
	  ,NULL AS TreatmentStartMonth
	  ,NULL AS TreatmentStopYear
	  ,NULL AS TreatmentStopMonth
	  ,'' AS CurrentDose
	  ,'' AS PastDose

FROM [MERGE_SPA].[staging].[VS_01] V
LEFT JOIN [MERGE_SPA].[staging].[EP_06] D ON V.vID=D.vID
LEFT JOIN [MERGE_SPA].[staging].[EP_05] E ON E.vID=V.vID
WHERE (D.[NO_BIO_SM]='X' AND  E.[NO_DMARD_STERIOD_TODAY]='X')
AND V.VISNAME IN ('Enrollment Visit', 'Follow Up Visit')
) 

,DrugCohort AS
(
SELECT DISTINCT [CorronaRegistryID]
      ,[Drug]
      ,CASE WHEN [Cohort]='Otezla' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN [Cohort]='IL-17 or JAKi' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   ELSE [Cohort]
	   END AS [Cohort]

  FROM [Reimbursement].[Reference].[t_DrugHierarchy]
WHERE [CorronaRegistryID]=3
)

,DRUGS2 AS
(
SELECT vID AS VisitID
      ,SiteID
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,PageDescription
	  ,TreatmentName
	  ,ChangesToday
	  ,PageStatus
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
	  ,CASE WHEN TreatmentName='abatacept (Orencia)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='anakinra (Kineret)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='tofacitinib (Xeljanz)' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN TreatmentName='adalimumab (Humira)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='apremilast (Otezla)' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN TreatmentName='adalimumab (Humira)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='etanercept (Enbrel)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='infliximab (Remicade)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='csDMARD or steroid only' THEN 'csDMARD'
	   WHEN TreatmentName='Investigational Drug' THEN 'Investigational Drug'
	   WHEN TreatmentName LIKE '%Other%' THEN ''
	   ELSE Cohort
	   END AS Cohort

	  ,CASE WHEN PageDescription='Biologics' AND TreatmentName IN ('secukinumab (Cosentyx)', 'tofacitinib (Xeljanz)') AND ChangesToday='Start Drug' THEN 100
	   WHEN PageDescription='Biologics' AND ChangesToday='Start Drug' THEN 110
	   WHEN PageDescription='Biologics' AND TreatmentName IN ('secukinumab (Cosentyx)', 'tofacitinib (Xeljanz)') AND ChangesToday IN ('No changes', 'Change Dose') THEN 120
	   WHEN PageDescription='Biologics' AND ChangesToday IN ('No changes', 'Change Dose') AND TreatmentName<>'anakinra (Kineret)' THEN 130
	   WHEN PageDescription='Biologics' AND ChangesToday IN ('No changes', 'Change Dose') AND TreatmentName='anakinra (Kineret)' THEN 140
	   WHEN PageDescription='Biologics' AND TreatmentName LIKE '%Investigat%' THEN 150
	   WHEN PageDescription='Biologics' AND ChangesToday IN ('Stop Drug', 'N/A (no longer in use)') THEN 160
	   WHEN PageDescription='Conventional DMARDs' THEN 200
	   ELSE ''
	   END AS DrugHierarchy

	  ,CASE WHEN ChangesToday='Start Drug'  THEN 1
	   WHEN ChangesToday IN ('No changes', 'Change Dose') THEN 2
	   WHEN ChangesToday IN ('Stop Drug', 'N/A (no longer in use)') THEN 3
	   WHEN TreatmentName='Investigational Drug' THEN 5
	   ELSE 10
	   END AS ChangesTodayHierarchy

FROM V1_2Drugs D
LEFT JOIN DrugCohort DC ON DC.Drug=D.TreatmentName
WHERE SiteID NOT IN (99997, 99998, 99999)

)

SELECT VisitID,
       SiteID,
	   SubjectID,
	   VisitType,
	   VisitDate,
	   PageDescription,
	   TreatmentName,
	   DrugHierarchy,
	   ChangesToday,
	   PageStatus,
	   TreatmentStartYear,
	   TreatmentStartMonth,
	   TreatmentStopYear,
	   TreatmentStopMonth,
	   CurrentDose,
	   PastDose,
	   CASE WHEN TreatmentName='abatacept (Orencia)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='anakinra (Kineret)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='tofacitinib (Xeljanz)' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN TreatmentName='adalimumab (Humira)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='apremilast (Otezla)' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN TreatmentName='adalimumab (Humira)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='etanercept (Enbrel)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='infliximab (Remicade)' THEN 'Comparator Biologic'
	   WHEN TreatmentName='csDMARD or steroid only' THEN 'csDMARD'
	   WHEN TreatmentName='Investigational Drug' THEN 'Investigational Drug'
	   WHEN Cohort='Comparator Biologics' THEN 'Comparator Biologic'
	   WHEN Cohort='IL-17, JAKi or PDE4' THEN 'IL-17, JAK or PDE4 Inhibitor'
	   WHEN TreatmentName LIKE '%Other%' THEN ''
	   ELSE Cohort
	   END AS Cohort
FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY VisitId, SiteID, SubjectID, VisitType ORDER BY SiteID, SubjectID, DrugHierarchy, ChangesTodayHierarchy, TreatmentName) AS DrugHierarchy
      ,VisitID
	  ,CAST(SiteID AS int) AS SiteID
	  ,CAST(SubjectID AS bigint) AS SubjectID
	  ,VisitType
	  ,VisitDate
	  ,PageDescription

	  ,CASE WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: COSENT%' THEN 'secukinumab (Cosentyx)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: CONSENTYX%' THEN 'secukinumab (Cosentyx)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: CORENTYX%' THEN 'secukinumab (Cosentyx)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: HUMIRA%' THEN 'adalimumab (Humira)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: OTEZLA%' THEN 'apremilast (Otezla)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: APREMILAST%' THEN 'apremilast (Otezla)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: USTEKINUMAB%' THEN 'ustekinumab (Stelara)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: ETANERCEPT%' THEN 'etanercept (Enbrel)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: REMICADE%' THEN 'infliximab (Remicade)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: SIMPNI IV ARIA' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: SIMPONE ARIA' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: SIMPONI' THEN 'golimumab (Simponi)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: ENBREL%' THEN 'etanercept (Enbrel)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: ADALIMUMAB%' THEN 'adalimumab (Humira)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: KINERET%' THEN 'anakinra (Kineret)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: XELJANZ%' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: CIMZIA%' THEN 'certolizumab pegol (Cimzia)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: TALT%' THEN 'ixekizumab (Taltz)'
	   WHEN UPPER(DRUGS2.TreatmentName) LIKE '%OTHER: SECUKINUMAB%' THEN 'secukinumab (Cosentyx)'
	   ELSE DRUGS2.TreatmentName
	   END AS TreatmentName

	  ,ChangesToday
	  ,PageStatus
	  ,TreatmentStartYear
	  ,TreatmentStartMonth
	  ,TreatmentStopYear
	  ,TreatmentStopMonth
	  ,CurrentDose
	  ,PastDose
	  ,Cohort

FROM DRUGS2
WHERE SiteID NOT IN (99997, 99998, 99999)
) FINAL

--ORDER BY SiteID, SubjectID


GO
