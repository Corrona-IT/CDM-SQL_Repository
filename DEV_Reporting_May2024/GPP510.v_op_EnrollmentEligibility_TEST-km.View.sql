USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EnrollmentEligibility_TEST-km]    Script Date: 6/6/2024 8:58:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [GPP510].[v_op_EnrollmentEligibility_TEST-km] AS 

With GPPEE AS
(
Select vl.SiteID
	  ,CASE WHEN VL.SiteID IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE VL.SFSiteStatus 
	   END AS SiteStatus
	  ,vl.SubjectID
	  ,vl.VisitProviderID

--for consent status, I would either have a status (Consented, Not consented) OR have the column header be 'Subject Consented'
	  ,(DATEPART(YEAR,vl.YearofBirth)) AS YearofBirth
	  ,CASE WHEN (AD.CONSCOMP = 'X') THEN 'Yes'
	   WHEN (ISNULL(AD.CONSCOMP,'') = '') THEN 'No'
	   END AS ConsentStatus

--If Jo wants this for consent reason, let's call it 'Consent Marked Eligible, and a Yes/No response - this is not Enrollment Eligibility, Enrollment Eligiblity is is determined by how criteria questions are answered at enrollment visit. I would call this one Inclusion/Exclusion Criteria met
	  ,CASE WHEN ((Select ELIGIBLE_DEC FROM [ZELTA_GPP_TEST].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) = 'Yes') THEN ('Eligible')
	  WHEN ((Select ELIGIBLE_DEC FROM [ZELTA_GPP_TEST].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) = 'No') THEN ('Not Eligible')
	  ELSE (Select ELIGIBLE_DEC FROM [ZELTA_GPP_TEST].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) END AS EnrollmentEligibility

	  ,cast(vl.visitDate as date) AS EnrollmentDate


--These three questions will determine actual Enrollment Eligibility.
	  ,MD.DIAGDAT AS GPPDiagnosisDate
	  ,cast((DATEPART(YEAR,cast(vl.visitDate as date))) as int) - cast(DATEPART(YEAR,vl.YearofBirth) as int) AS AgeAtEnrollment
	  ,MD.OTHSTDY_DEC AS EnrolledInOtherStudies
	  ,AD.PIICOMP_C AS PIICompletion
	  
	  ,V.VISITFLR_DEC AS IsSubjectExperiencingFlare

	  ,CASE WHEN (MD.MEDRELOBT_DEC = 'No') THEN MD.MEDRELOBT_DEC + '- ' + MD.MEDRELNOTOBT
	  WHEN (MD.MEDRELOBT_DEC = 'Yes') THEN MD.MEDRELOBT_DEC + '- Medical Records Authorization Uploaded'
	  END AS WereMedRecordsAuthObtained

--This is Subject Status, but not necessarily Enrollment Status. Not sure what Jo wanted for this column, but this would show current subject status not the subject status at enrollment.  
	  ,CASE WHEN (SL.SubjectStatus IS NULL) THEN ('') 
	   WHEN (SL.SubjectStatus IS NOT NULL) THEN (SL.SubjectStatus) END AS RegistryEnrollmentStatus


	  ,CASE WHEN (EL.ELIG_EN_DEC IS NULL) THEN (' ') 
	   WHEN (EL.ELIG_EN_DEC = 'Yes') THEN ('Eligible') 
	   WHEN (EL.ELIG_EN_DEC = 'No' AND ISNULL(EL.ELIGEXC_EN_DEC,'') IN ('', 'No')) THEN ('Not eligible')
	   WHEN (EL.ELIG_EN_DEC = 'No' AND EL.ELIGEXC_EN_DEC = 'Yes') THEN ('Eligible by exception')  -- Let's make this 'Eligible - Review decision'
	   ELSE EL.ELIG_EN_DEC 
	   END AS EligibilityReview


	  ,CASE WHEN (VC.ENCOMPL = 'X') THEN 'Complete'
	   WHEN (ISNULL(VC.ENCOMPL,'') = '') THEN 'Incomplete'
	   END AS VisitCompletionStatus
	  
From [Reporting].[GPP510].[v_op_VisitLog] vl 
left join [ZELTA_GPP_TEST].[dbo].[MD_DX] MD on vl.SubjectID = MD.Subnum AND MD.PAGENAME = 'Provider Form A' AND vl.VID = MD.VID
left join [ZELTA_GPP_TEST].[dbo].[ADMIN] AD on vl.SubjectID = AD.Subnum AND AD.PAGENAME = 'Consent Status'
left join [ZELTA_GPP_TEST].[dbo].[ELG] EL on vl.SubjectID = EL.SUBNUM AND EL.VISNAME = 'Enrollment'
left join [ZELTA_GPP_TEST].[dbo].[VISIT] V on vl.SubjectID = V.SUBNUM AND V.VISNAME = 'Enrollment'  AND V.VID = vl.VID
left join [ZELTA_GPP_TEST].[dbo].[VISIT_COMP] VC on vl.SubjectID = VC.SUBNUM AND VC.VISNAME = 'Enrollment'
--left join [ZELTA_GPP_TEST].[dbo].[DRUG] DR on vl.SubjectID = DR.SUBNUM AND DR.VISNAME = 'Enrollment'
left join [Reporting].[GPP510].[v_op_subjectlog] SL on vl.SubjectID = SL.SubjectID
--left join [Reporting].[GPP510].[v_op_SubjectFollowupTracker] FU on vl.SubjectID = FU.SubjectID
WHERE vl.[Visit Type] = 'Enrollment' 
--used to filter out duplicate subjectid rows
)

,medication AS
(
Select Subnum
,DRUG_DEC AS Drug
,CASE WHEN (ISNULL(RXDAT,'') = '') THEN FSTDAT 
ELSE RXDAT END AS medicationStartDate
FROM [ZELTA_GPP_TEST].[dbo].[DRUG]
WHERE Pagename = 'Drug Log' --Set to drug log instead of visname = enrollment per kayes instructions
AND DRUG_DEC != 'Other (specify)'
--AND ONGO = 'X'

Union

Select Subnum
,DRUGOTH AS Drug
,CASE WHEN (ISNULL(RXDAT,'') = '') THEN FSTDAT 
ELSE RXDAT END AS medicationStartDate
FROM [ZELTA_GPP_TEST].[dbo].[DRUG]
WHERE Pagename = 'Drug Log'
AND DRUG_DEC = 'Other (specify)'
--AND ONGO = 'X'
)


select *

--Registry Enrollment Status
--If RegistryEnrollmentStatus (RES) = 'Not eligible' and UPPER(EligibilityReview (ER)) LIKE '%ELIGIBLE%' THEN EligibiityReview
--If RegistryEnrollmentStatus (RES) = 'Needs review' and eligiblity review is not null or not under review then eligiblityreview

/* this is from IBD:
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

*/


FROM
(
SELECT SiteID
,SiteStatus
,SubjectID
,VisitProviderID
,YearofBirth
,ConsentStatus

--This is incomplete - there will be needs review is something is left blank, this would be Registry Enrollment Status AFTER we compare it against Eligibility Review
,CASE WHEN (AgeAtEnrollment >= 18 AND EnrolledInOtherStudies = 'No' AND PIICompletion = 1 AND ConsentStatus = 'Yes' AND GPPDiagnosisDate IS NOT NULL)
      THEN ('Yes') ---Eligible
--If YOB is null then 'Needs review'
--If diagnosis date is null then 'Needs review'
--If EnrolledInOtherStudies is null then 'Needs review'
--If ConsentStatus is null then 'Needs review'
	  ELSE ('No') --Not eligible
	  END AS InclusionCriteriaMet --RegistryEnrollmentStatus

,CASE WHEN (PIICompletion = 1) THEN ('Yes')
      ELSE ('No')
      END AS PIICompletion

,STUFF((
        SELECT DISTINCT ', ' + drug
        FROM medication RS
        WHERE RS.subNum=GPPEE.SubjectID
		AND RS.medicationStartDate <= GPPEE.EnrollmentDate 
        FOR XML PATH('')
        )
        ,1,1,'') AS medication

,EnrollmentEligibility -- this is actually Registry Enrollment Status - get rid of the Subject status which is name Registry Enrollment Status
,EnrollmentDate
,GPPDiagnosisDate
,IsSubjectExperiencingFlare
,WereMedRecordsAuthObtained

--This is where you need to look at Eligibility Review for final Registry Enrollment Status (which should be Enrollment Eligiblity). If Eligiblity Review is not null or not Under Review, then we would pull in the Eligiblity Review status over the Eligibility Status.
,RegistryEnrollmentStatus -- This is subject status and not needed, get rid of it and use this variable name for the column you named Enrollment Eligiblity
,EligibilityReview
,VisitCompletionStatus

FROM GPPEE
) A

GO
