USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_114_EnrollmentEligibility]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [IBD600].[v_op_114_EnrollmentEligibility] as


---Get enrollment information required
WITH ENR AS
(
SELECT VS.vID
      ,VS.SITENUM AS SiteID
	  ,VS.SUBNUM AS SubjectID
	  ,CAST(VS.VISITDATE AS date) AS EnrollmentDate
	  ,VS.VISNAME AS VisitType
	  ,VS.AGE AS AgeAtVisit
	  ,DX.MD_COD AS ProviderID
	  ,DX.DX_IBD_DEC AS Diagnosis
	  ,REIMB.INELIGIBLE_DEC AS SubjectEligibilityMonitorReview
	  ,ISNULL(REIMB.INELIGIBLE_RSN_DEC, '') + ISNULL(';  ' + REIMB.INELIGIBLE_RSN_OTH , '') AS IneligibleReasonMonitorReview
	  ,REIMB.INELIGIBLE_EXCEPTION_DEC AS ExceptionGrantedforEligibility
	  ,REIMB.INELIGIBLE_EXCEPTION_RSN AS EligibilityExceptionReason
	  ,REIMB.VISIT_PAID AS VisitPaid
	  ,REIMB.PII_HB AS PIIRequirementMet

FROM [MERGE_IBD].[staging].[VISIT] VS
LEFT JOIN [MERGE_IBD].[staging].[MD_DX] DX ON VS.VID=DX.VID AND VS.SUBNUM=DX.SUBNUM
LEFT JOIN [MERGE_IBD].[staging].[REIMB] REIMB ON VS.VID=REIMB.VID AND VS.SUBNUM=REIMB.SUBNUM
WHERE VS.VISNAME='Enrollment'
)



---Create calculated fields 
,ENRCALC as
(
SELECT vID
      ,SiteID
	  ,SubjectID
	  ,ProviderID
	  ,VisitType
	  ,EnrollmentDate
	  ,AgeAtVisit
	  ,Diagnosis
	  ,CASE WHEN AgeAtVisit>=18 AND ISNULL(Diagnosis, '')<>'' THEN 'Eligible'
	   ELSE 'Ineligible'
	   END AS CalculatedSubjectEligiblity
	  ,CASE WHEN SubjectEligibilityMonitorReview='Yes' THEN 'Eligible'
	   WHEN SubjectEligibilityMonitorReview='No' THEN 'Ineligible'
	   ELSE ISNULL(SubjectEligibilityMonitorReview, '')
	   END AS SubjectEligibilityMonitorReview
	  ,CASE WHEN AgeAtVisit<18 AND ISNULL(Diagnosis, '')<>'' THEN 'Too young'
	   WHEN AgeAtVisit>=18 AND ISNULL(Diagnosis, '')<='' THEN 'No Diagnosis'
	   WHEN AgeAtVisit<18 AND ISNULL(Diagnosis, '')='' THEN 'Too young and No Diagnosis'
	   ELSE ''
	   END AS CalculatedIneligiblityReason
	  ,IneligibleReasonMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,EligibilityExceptionReason
	  ,CASE WHEN VisitPaid='X' THEN 'Yes'
	   ELSE ''
	   END AS VisitPaid
	  ,CASE WHEN PIIRequirementMet='X' THEN 'Yes'
	   ELSE ''
	   END AS PIIRequirementMet
FROM ENR
)

---Final output matching calculated versus monitor reviewed

SELECT vID
      ,CAST(SiteID AS int) AS SiteID
	  ,SubjectID AS SubjectID
	  ,CAST(ProviderID AS int) AS ProviderID
	  ,VisitType
	  ,CAST(EnrollmentDate AS date) AS EnrollmentDate
	  ,CAST(AgeAtVisit AS int) AS AgeAtVisit
	  ,Diagnosis
	  ,CASE WHEN ISNULL(SubjectEligibilityMonitorReview , '')='' THEN 'Not Monitor Reviewed'
	   WHEN CalculatedSubjectEligiblity=ISNULL(SubjectEligibilityMonitorReview , '') THEN 'Match'
	   WHEN CalculatedSubjectEligiblity<>ISNULL(SubjectEligibilityMonitorReview , '') THEN 'Does Not Match'
	   ELSE ''
	   END AS CalculatedEligibilityVsMonitorReviewEligibility
	  ,CalculatedSubjectEligiblity
	  ,CalculatedIneligiblityReason
	  ,SubjectEligibilityMonitorReview
	  ,IneligibleReasonMonitorReview
	  ,ExceptionGrantedforEligibility
	  ,EligibilityExceptionReason
	  ,VisitPaid
	  ,PIIRequirementMet
FROM ENRCALC

---ORDER BY SiteID, SubjectID






GO
