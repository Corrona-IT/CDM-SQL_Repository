USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EnrollmentEligibility_TEST]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [GPP510].[v_op_EnrollmentEligibility_TEST] AS 

With GPPEE AS
(
Select vl.SiteID
	  ,CASE WHEN VL.SiteID IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE VL.SFSiteStatus 
	   END AS SiteStatus
	  ,vl.SubjectID
	  ,vl.VisitProviderID
	  ,DS.IDENT2 AS YearofBirth
	  ,CASE WHEN (AD.CONSCOMP = 'X') THEN 'Yes'
	   WHEN (ISNULL(AD.CONSCOMP,'') = '') THEN 'No'
	   END AS ConsentStatus
	  ,CASE WHEN ((Select ELIGIBLE_DEC FROM [ZELTA_GPP].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) = 'Yes') THEN ('Yes')
	  WHEN ((Select ELIGIBLE_DEC FROM [ZELTA_GPP].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) = 'No') THEN ('No')
	  ELSE (Select ELIGIBLE_DEC FROM [ZELTA_GPP].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) END AS ConsentMarkedEligible
	  ,cast(vl.visitDate as date) AS EnrollmentDate
	  ,MD.DIAGDAT AS GPPDiagnosisDate --these next 4 variables are inclusion criteria
	  ,cast((DATEPART(YEAR,cast(vl.visitDate as date))) as int) - cast(DATEPART(YEAR,vl.YearofBirth) as int) AS AgeAtEnrollment
	  ,MD.OTHSTDY_DEC AS EnrolledInOtherStudies
	  ,AD.PIICOMP_C AS PIICompletion
	 -- Select * FROM [ZELTA_GPP].[dbo].[ADMIN]
	  ,CASE WHEN (DATEPART(YEAR,vl.visitDate) - DS.IDENT2 >= 18 AND MD.OTHSTDY_DEC = 'No' AND AD.PIICOMP_C = 1 AND (AD.CONSCOMP = 'X') AND MD.DIAGDAT IS NOT NULL)
				THEN ('Eligible')
	  WHEN ((MD.OTHSTDY_DEC IS NULL) OR (MD.DIAGDAT IS NULL) OR (AD.CONSCOMP IS NULL) OR (DS.IDENT2 IS NULL))
				THEN ('Needs review')
	  ELSE ('Not eligible')
	  END AS EligibilityStatus

	  ,V.VISITFLR_DEC AS IsSubjectExperiencingFlare
	  ,CASE WHEN (MD.MEDRELOBT_DEC = 'No') THEN MD.MEDRELOBT_DEC + '- ' + MD.MEDRELNOTOBT
	  WHEN (MD.MEDRELOBT_DEC = 'Yes') THEN MD.MEDRELOBT_DEC + '- Medical Records Authorization Uploaded'
	  END AS WereMedRecordsAuthObtained

	  ,CASE WHEN (EL.ELIG_EN_DEC IS NULL) THEN (' ') 
	   WHEN (EL.ELIG_EN_DEC = 'Yes') THEN ('Eligible') 
	   WHEN (EL.ELIG_EN_DEC = 'No' AND ISNULL(EL.ELIGEXC_EN_DEC,'') IN ('', 'No')) THEN ('Not eligible')
	   WHEN (EL.ELIG_EN_DEC = 'No' AND EL.ELIGEXC_EN_DEC = 'Yes') THEN ('Eligible - Review decision')
	   WHEN (EL.ELIG_EN_DEC = 'Under review (outcome TBD)') THEN ('Under review (outcome TBD)')
	   ELSE EL.ELIG_EN_DEC 
	   END AS EligibilityReview

	  ,CASE WHEN (VC.ENCOMPL = 'X') THEN 'Complete'
	   WHEN (ISNULL(VC.ENCOMPL,'') = '') THEN 'Incomplete'
	   END AS VisitCompletionStatus
	  
From [Reporting].[GPP510].[v_op_VisitLog_TEST] vl 
left join [Zelta_GPP_TEST].[dbo].DAT_SUB DS on vl.SubjectID = DS.Subnum
left join [ZELTA_GPP_TEST].[dbo].[MD_DX] MD on vl.SubjectID = MD.Subnum AND MD.PAGENAME = 'Provider Form A' AND vl.VID = MD.VID
left join [ZELTA_GPP_TEST].[dbo].[ADMIN] AD on vl.SubjectID = AD.Subnum AND AD.PAGENAME = 'Consent Status' 
left join [ZELTA_GPP_TEST].[dbo].[ELG] EL on vl.SubjectID = EL.SUBNUM AND EL.VISNAME = 'Enrollment' 
left join [ZELTA_GPP_TEST].[dbo].[VISIT] V on vl.SubjectID = V.SUBNUM AND V.VISNAME = 'Enrollment'  AND V.PAGENAME = 'Visit Information'
left join [ZELTA_GPP_TEST].[dbo].[VISIT_COMP] VC on vl.SubjectID = VC.SUBNUM AND VC.VISNAME = 'Enrollment' 
WHERE 1=1
AND vl.[VisitType] = 'Enrollment' 
)

,medication AS
(
Select Subnum
,DRUG_DEC AS Drug
,CASE WHEN (ISNULL(RXDAT,'') = '') THEN FSTDAT 
ELSE RXDAT END AS medicationStartDate
FROM [ZELTA_GPP_TEST].[dbo].[DRUG] D
WHERE 1=1
AND PAGENAME = 'Drug Log' --Set to drug log instead of visname = enrollment per kayes instructions
AND DRUG_DEC != 'Other (specify)'
AND COALESCE(RXDAT, FSTDAT) <= (SELECT VISDAT FROM [GPP510].[v_op_VisitLog_simple] VT WHERE VT.SUBNUM=D.SUBNUM AND VT.VISNAME='Enrollment')

UNION

Select Subnum
,DRUGOTH AS Drug
,CASE WHEN (ISNULL(RXDAT,'') = '') THEN FSTDAT 
ELSE RXDAT END AS medicationStartDate
FROM [ZELTA_GPP_TEST].[dbo].[DRUG] DO
WHERE 1=1
AND PAGENAME = 'Drug Log'
AND DRUG_DEC = 'Other (specify)'
AND COALESCE(RXDAT, FSTDAT) <= (SELECT VISDAT FROM [GPP510].[v_op_VisitLog_simple] VT WHERE VT.SUBNUM=DO.SUBNUM AND VT.VISNAME='Enrollment')

)


Select
SiteID
,SiteStatus
,SubjectID
,VisitProviderID
,YearofBirth
,ConsentStatus

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
,ConsentMarkedEligible
,EnrollmentDate
,GPPDiagnosisDate
,EnrolledInOtherStudies
,IsSubjectExperiencingFlare
,WereMedRecordsAuthObtained

,CASE WHEN EligibilityStatus = 'Not eligible' AND EligibilityReview IN ('Eligible - Review decision') THEN 'Eligible - Review decision'
	  WHEN EligibilityStatus = 'Not eligible' AND EligibilityReview IN ('Eligible') THEN 'Eligible'
	  WHEN EligibilityStatus IN ('Not eligible','Needs review') AND EligibilityReview = 'Not eligible' THEN 'Not eligible'
	  WHEN EligibilityStatus IN ('Eligible','Needs review') AND EligibilityReview = 'Eligible - Review decision' THEN 'Eligible - Review decision' 
	  WHEN EligibilityStatus IN ('Eligible','Needs review') AND EligibilityReview = 'Eligible' THEN 'Eligible'
	  WHEN EligibilityStatus IN ('Eligible','Needs review') AND EligibilityReview = 'Eligible'  THEN 'Eligible'
	  WHEN EligibilityStatus = 'Needs review' AND EligibilityReview = 'Under review (outcome TBD)' THEN 'Needs review'
	  WHEN ISNULL(EligibilityReview, '')='' THEN EligibilityStatus
	  END AS EligibilityStatus


,EligibilityReview
,VisitCompletionStatus

FROM GPPEE
--ORDER BY SiteID, SubjectID
GO
