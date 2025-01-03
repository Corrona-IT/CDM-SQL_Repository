USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_EER_DOIENROLL]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [RA100].[v_op_EER_DOIENROLL]  AS


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
      ,EER.[VisitDate] AS EnrollmentDate
      ,EER.[OnsetYear]
      ,EER.[EligibilityVersion]
      ,EER.[DrugOfInterest] AS [EligibleMedication]
      ,EER.[DOIInitiationStatus] as [MedicationStatusatEnrollment]
	  ,EER.[StartDate]
	  ,EER.[AdditionalDOI] AS [AdditionalMedications]
      ,EER.[TwelveMonthInitiationRule]
      ,EER.[PriorJAKiUse]
      ,EER.[FirstTimeUse]
	  ,CASE WHEN EER.RegistryEnrollmentStatus = 'Not Eligible' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception') THEN 'Eligible - Review decision'
	   WHEN EER.RegistryEnrollmentStatus = 'Not Eligible' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND ISNULL(RAE.ExceptionGranted, '') IN ('', 'No') THEN 'Not eligible - Confirmed'
	   WHEN EER.RegistryEnrollmentStatus='Eligible'  AND RAE.PatientEligible='No' AND ExceptionGranted IS NULL THEN 'Eligible - Review decision'
	   WHEN EER.RegistryEnrollmentStatus='Needs Review' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception Granted') THEN 'Eligible - Review decision'
	   WHEN EER.RegistryEnrollmentStatus LIKE 'Eligible' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('No', 'Not Eligible') THEN 'Eligible - Review decision'
	   WHEN EER.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('Yes', 'Eligible') THEN 'Eligible - Review decision'
	   WHEN EER.RegistryEnrollmentStatus='Needs Review' AND PatientEligible IN ('Yes', 'Eligible') THEN 'Eligible'
	   WHEN EER.RegistryEnrollmentStatus='Needs Review' AND PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('No', 'Not Eligible') THEN 'Not eligible'
	   WHEN EER.RegistryEnrollmentStatus='Needs Review' AND PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception Granted') THEN 'Eligible'
	   ELSE EER.RegistryEnrollmentStatus
	   END AS RegistryEnrollmentStatus

	  ,CASE WHEN EER.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception Granted') THEN 'Not eligible - Exception granted'
	   WHEN EER.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('Yes', 'Eligible') THEN 'Eligible'
	   WHEN RAE.PatientEligible IN ('Under Review', 'Under review (outcome TBD)') THEN 'Under review (outcome TBD)'
	   WHEN EER.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('No', 'Not Eligible') THEN 'Not eligible - Confirmed'
	   WHEN PatientEligible='Yes' THEN 'Eligible'
	   WHEN PatientEligible='No' AND ISNULL(ExceptionGranted, '')='' THEN 'Not eligible'
	   ELSE 'NULL'
	   END AS CalcExceptionGranted

	  ,CASE WHEN RAE.PatientEligible IN ('Under Review', 'Under review (outcome TBD)') THEN 'Under review (outcome TBD)'
	   ELSE RAE.PatientEligible
	   END AS PatientEligible
	  ,RAE.ExceptionGranted
	  ,RAE.ExceptionReason

  FROM [Reporting].[RA100].[t_op_DOI_Enrollment] EER
  LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON CAST(RS.SiteNumber AS int)=EER.SiteID AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
  LEFT JOIN [RA100].[t_op_RAExceptionsList] RAE ON RAE.SiteID=EER.SiteID AND RAE.SubjectID=EER.SubjectID AND RAE.EnrollmentDate=EER.VisitDate
  AND ROWNUM=1
--WHERE EER.SubjectID=999369302
--ORDER BY SiteID, SubjectID
--SELECT * FROM [RA100].[t_op_DOI_Enrollment] EER WHERE SiteID LIKE '99%'

GO
