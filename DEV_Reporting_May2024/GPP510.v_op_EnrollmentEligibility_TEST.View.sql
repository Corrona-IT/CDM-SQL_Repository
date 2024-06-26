USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EnrollmentEligibility_TEST]    Script Date: 6/6/2024 8:58:06 PM ******/
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
	  ,(DATEPART(YEAR,vl.YearofBirth)) AS YearofBirth
	  ,CASE WHEN (AD.CONSCOMP = 'X') THEN 'Yes'
	   WHEN (ISNULL(AD.CONSCOMP,'') = '') THEN 'No'
	   END AS ConsentStatus
	  ,CASE WHEN ((Select ELIGIBLE_DEC FROM [ZELTA_GPP_TEST].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) = 'Yes') THEN ('Eligible')
	  WHEN ((Select ELIGIBLE_DEC FROM [ZELTA_GPP_TEST].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) = 'No') THEN ('Not Eligible')
	  ELSE (Select ELIGIBLE_DEC FROM [ZELTA_GPP_TEST].[dbo].[ADMIN] EEA WHERE EEA.PAGENAME = 'Administrative' AND EEA.Subnum = vl.SubjectID) END AS EnrollmentEligibility
	  ,cast(vl.visitDate as date) AS EnrollmentDate
	  ,MD.DIAGDAT AS GPPDiagnosisDate
	  ,cast((DATEPART(YEAR,cast(vl.visitDate as date))) as int) - cast(DATEPART(YEAR,vl.YearofBirth) as int) AS AgeAtEnrollment
	  ,MD.OTHSTDY_DEC AS EnrolledInOtherStudies
	  ,AD.PIICOMP_C AS PIICompletion
	  ,V.VISITFLR_DEC AS IsSubjectExperiencingFlare
	  ,CASE WHEN (MD.MEDRELOBT_DEC = 'No') THEN MD.MEDRELOBT_DEC + '- ' + MD.MEDRELNOTOBT
	  WHEN (MD.MEDRELOBT_DEC = 'Yes') THEN MD.MEDRELOBT_DEC + '- Medical Records Authorization Uploaded'
	  END AS WereMedRecordsAuthObtained
	  ,CASE WHEN (SL.SubjectStatus IS NULL) THEN ('') 
	   WHEN (SL.SubjectStatus IS NOT NULL) THEN (SL.SubjectStatus) END AS RegistryEnrollmentStatus
	  ,CASE WHEN (EL.ELIG_EN_DEC IS NULL) THEN (' ') 
	   WHEN (EL.ELIG_EN_DEC = 'Yes') THEN ('Eligible') 
	   WHEN (EL.ELIG_EN_DEC = 'No' AND ISNULL(EL.ELIGEXC_EN_DEC,'') IN ('', 'No')) THEN ('Not eligible')
	   WHEN (EL.ELIG_EN_DEC = 'No' AND EL.ELIGEXC_EN_DEC = 'Yes') THEN ('Eligible by exception')
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
Select
SiteID
,SiteStatus
,SubjectID
,VisitProviderID
,YearofBirth
,ConsentStatus
,CASE WHEN (AgeAtEnrollment >= 18 AND EnrolledInOtherStudies = 'No' AND PIICompletion = 1 AND ConsentStatus = 'Yes' AND GPPDiagnosisDate IS NOT NULL)
      THEN ('Yes')
	  ELSE ('No')
	  END AS InclusionCriteriaMet
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
,EnrollmentEligibility
,EnrollmentDate
,GPPDiagnosisDate
,IsSubjectExperiencingFlare
,WereMedRecordsAuthObtained
,RegistryEnrollmentStatus
,EligibilityReview
--,Exception
,VisitCompletionStatus
FROM GPPEE

GO
