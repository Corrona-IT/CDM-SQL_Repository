USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_CohortMonitoring]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSA400].[v_op_CohortMonitoring]  AS

WITH ENPROVID AS
(
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EP_01
union
SELECT vID, sitenum, subnum, visname, md_cod FROM MERGE_SPA.staging.EPRO_01
)

SELECT 
      R.SourceVisitID AS VisitId,
      V.SITENUM AS SiteID,
	  R.[SUBNUM] AS SubjectID,
	  R.[VisitDate] AS EnrollmentDate,
	  R.[IncidentUse_DATA] AS Diagnosis,
	  R.[DRUG_NAME_DEC] AS EligibleDrug,
	  R.[Cohort_LOGIC] AS Cohort,
	  1 as NbrEnrolled,
	  ENPROVID.MD_COD AS ProviderID
	  FROM [Reimbursement].[cdb_spa].[v_Drugs_Hierarchy] R
LEFT JOIN [MERGE_SPA].[staging].[VS_01] V ON V.vID=R.SourceVisitID
LEFT JOIN ENPROVID ON ENPROVID.vID=R.SourceVisitID
WHERE V.SITENUM NOT IN (99997, 99998, 99999) AND
R.[IncidentUse_LOGIC] IN ('PSA', 'PSA, AS')
AND R.[Cohort_LOGIC] IN ('IL-17 or JAKi', 'Comparator Biologics')

---ORDER BY SiteID


GO
