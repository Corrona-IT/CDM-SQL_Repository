USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_EnrollmentwithDrugandCohort]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [PSA400].[v_op_EnrollmentwithDrugandCohort]  AS

WITH ENPROVID AS
(
SELECT vID, sitenum, CAST(subnum AS varchar) AS subnum, visname, md_cod FROM MERGE_SPA.staging.EP_01
union
SELECT vID, sitenum, CAST(subnum AS varchar) AS subnum, visname, md_cod FROM MERGE_SPA.staging.EPRO_01
--ORDER BY sitenum, subnum
)

 
,SUGGESTEDCOHORT AS
(
SELECT DISTINCT [Drug] AS DrugName
      ,[Cohort] AS SuggestedCohort
	  ,[CorronaRegistryID]
FROM [Reimbursement].[Reference].[t_DrugHierarchy]
WHERE [CorronaRegistryID]=3 
)

,REVIEWOUTCOME AS
(
SELECT vID
      ,SITENUM AS SiteID
	  ,CAST(SUBNUM AS nvarchar) AS SubjectID
	  ,VISNAME AS VisitType
	  ,INELIGIBLE
	  ,INELIGIBLE_EXCEPTION
	  
FROM [MERGE_SPA].[staging].[REIMB]
WHERE VISNAME LIKE 'Enroll%'
)

SELECT vID
      ,SiteID
	  ,CAST(SubjectID AS nvarchar) AS SubjectID
	  ,ProviderID
	  ,EnrollmentDate
	  ,EligibilityVersion
	  ,Diagnosis
	  ,Eligibility
	  ,EligibleDrug
	  ,DrugOfInterest
	  ,Cohort
	  ,INELIGIBLE
	  ,INELIGIBLE_EXCEPTION
	  ,CASE WHEN Eligibility='Not eligible' AND INELIGIBLE=2 THEN 'Under Review'
	   WHEN Eligibility='Not eligible' AND INELIGIBLE=0 AND INELIGIBLE_EXCEPTION=0 THEN 'Confirmed Not Eligible'
	   WHEN Eligibility='Not eligible' AND INELIGIBLE=0 AND INELIGIBLE_EXCEPTION=1 THEN 'Exception Granted'
	   WHEN Eligibility='Not eligible' AND INELIGIBLE=1 THEN 'Confirmed Eligible'
	   WHEN Eligibility='Not eligible' AND ISNULL(INELIGIBLE, '')='' THEN 'Pending Review'
	   ELSE ''
	   END AS ReviewOutcome
	  ,Hierarchy_DATA

FROM (
SELECT R.SourceVisitID AS vID
      ,CAST(V.SITENUM AS int) AS SiteID
	  ,CAST(R.[SUBNUM] AS nvarchar) AS SubjectID
	  ,ENPROVID.MD_COD AS ProviderID
	  ,CAST(R.[VisitDate] AS date) AS EnrollmentDate
	  ,CASE WHEN R.[VisitDate] BETWEEN '2017-04-03' and '2018-02-07' THEN '0'
	   WHEN R.[VisitDate] BETWEEN '2018-02-08' and '2018-09-30' THEN '1-2'
	   WHEN R.[VisitDate] >= '2018-10-01' THEN '3'
	   ELSE ''
	   END AS EligibilityVersion
	  ,COALESCE(R.[IncidentUse_DATA], R.[CurrentUse_DATA]) AS Diagnosis
	  ,CASE WHEN DrugReqSatisfied=1 THEN 'Eligible'
	   ELSE 'Not eligible'
	   END AS Eligibility
	  ,CASE WHEN DrugReqSatisfied=1 THEN R.[DRUG_NAME_DEC]
	   ELSE '' 
	   END AS EligibleDrug
	  ,CASE WHEN R.[DRUG_NAME_DEC] IN (SELECT DrugName FROM [Reporting].[PSA400].[t_op_DrugsOfInterest] WHERE RegistryName='PSA400' ) THEN 'Yes'
	   ELSE ''
	   END AS DrugOfInterest
	  ,CASE WHEN R.[SUBNUM]='3100290707' THEN 'Comparator Biologics'
	   WHEN DrugReqSatisfied=1 THEN COALESCE(R.[Cohort_LOGIC], SC.SuggestedCohort)
	   ELSE ''
	   END AS Cohort
	  ,RO.INELIGIBLE
	  ,RO.INELIGIBLE_EXCEPTION
	  ,R.Hierarchy_DATA

FROM [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R
LEFT JOIN SUGGESTEDCOHORT SC ON R.[DRUG_NAME_DEC]=SC.DrugName
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN ENPROVID ON ENPROVID.vID=R.SourceVisitID AND CAST(ENPROVID.SUBNUM AS nvarchar)=CAST(R.SUBNUM AS nvarchar)
LEFT JOIN REVIEWOUTCOME RO ON RO.vID=R.SourceVisitID
WHERE V.SITENUM NOT IN (99997, 99998, 99999) AND
R.Hierarchy_DATA=1) a


--AND DrugReqSatisfied=1

--ORDER BY SiteID, SubjectID  

GO
