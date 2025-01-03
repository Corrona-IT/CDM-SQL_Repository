USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_EER]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [RA100].[v_op_EER]  AS


SELECT DISTINCT EER.[SiteID]
      ,CASE WHEN EER.[SiteID]=999 THEN 'Active'
	   ELSE EER.[SiteStatus]
	   END AS [SiteStatus]
	  ,CASE WHEN EER.SiteID LIKE '99%' THEN 'Approved / Active'
	   ELSE RS.[currentStatus]
	   END AS SFSiteStatus
      ,EER.[SubjectID]
      ,EER.[ProviderID]
      ,EER.[YearofBirth]
      ,EER.[EnrollmentDate] AS EnrollmentDate
      ,EER.[OnsetYear]
	  ,EER.Age
	  ,EER.JuvenileRA
      ,EER.[EligibilityVersion]
      ,EER.[EligibleMedication]
      ,EER.[TreatmentStatus]
	  ,EER.[StartDate]
	  ,EER.[AdditionalMedications]
      ,EER.[TwelveMonthInitiationRule]
      ,EER.[PriorJAKiUse]
      ,EER.[FirstTimeUse]
	  ,CASE WHEN EER.RegistryEnrollmentStatus = 'Not eligible' AND RAE.PatientEligible='No' AND RAE.ExceptionGranted ='Yes' THEN 'Eligible - Review decision'
	  WHEN EER.RegistryEnrollmentStatus = 'Not eligible' AND RAE.PatientEligible='No' AND ISNULL(RAE.ExceptionGranted, '') IN ('', 'No') THEN 'Not eligible - Confirmed'
	  WHEN EER.RegistryEnrollmentStatus='Not eligible' AND RAE.PatientEligible='Yes' THEN 'Eligible - Review decision'
	  WHEN EER.RegistryEnrollmentStatus='Eligible' AND RAE.PatientEligible='No' AND ISNULL(ExceptionGranted, '')='' THEN 'Not eligible'
	  WHEN EER.RegistryEnrollmentStatus='Eligible' AND RAE.PatientEligible='No' AND RAE.ExceptionGranted='Yes'  THEN 'Eligible - Review decision'
	  WHEN EER.RegistryEnrollmentStatus='Needs review' AND RAE.PatientEligible='No' AND RAE.ExceptionGranted='Yes'  THEN 'Eligible - Review decision'
	  WHEN EER.RegistryEnrollmentStatus='Needs review' AND PatientEligible='Yes' THEN 'Eligible'
	  WHEN EER.RegistryEnrollmentStatus='Needs review' AND PatientEligible='No' AND RAE.ExceptionGranted IN ('', 'No') THEN 'Not eligible'
	  WHEN EER.RegistryEnrollmentStatus='Needs review' AND PatientEligible='No' AND RAE.ExceptionGranted='Yes' THEN 'Eligible - Review decision'
	  WHEN EER.RegistryEnrollmentStatus='Eligible' AND PatientEligible='Yes' THEN 'Eligible - Review decision'
	  WHEN EER.[RegistryEnrollmentStatus]='' THEN 'NULL'
	  ELSE EER.RegistryEnrollmentStatus
	  END AS RegistryEnrollmentStatus

	,CASE WHEN RAE.PatientEligible='No' AND RAE.ExceptionGranted='Yes' THEN 'Not eligible - Exception granted'
	 WHEN RAE.PatientEligible='Yes' THEN 'Eligible'
	 WHEN RAE.PatientEligible IN ('Under Review', 'Under review (outcome TBD)') THEN 'Under review (outcome TBD)'
	 WHEN RAE.PatientEligible ='No' AND ISNULL(RAE.ExceptionGranted, '') IN ('No', '') THEN 'Not eligible'
	 WHEN ISNULL(RAE.PatientEligible, '')='' THEN 'NULL'
	 END AS EligibilityReview

  FROM [Reporting].[RA100].[t_op_EER] EER
  LEFT JOIN [RA100].[t_op_RAExceptionsList] RAE ON RAE.SiteID=EER.SiteID AND RAE.SubjectID=EER.SubjectID AND RAE.EnrollmentDate=EER.EnrollmentDate
  LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON CAST(RS.SiteNumber AS int)=EER.SiteID AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'


  --SELECT * FROM [Reporting].[RA100].[t_op_EER] EER where EligibilityReview IS NOT NULL

GO
