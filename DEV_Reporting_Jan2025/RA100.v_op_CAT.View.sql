USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_CAT]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [RA100].[v_op_CAT]  AS


SELECT DISTINCT CAT.[SiteID]
      ,CASE WHEN CAT.[SiteID]=999 THEN 'Active'
	   ELSE CAT.[SiteStatus]
	   END AS [SiteStatus]
	  ,RS.[currentStatus]
      ,CAT.[SubjectID]
      ,CAT.[VisitType]
      ,CAT.[ProviderID]
      ,CAT.[YearofBirth]
      ,CAT.[VisitDate]
      ,CAT.[OnsetYear]
      ,CAT.[EligibilityVersion]
      ,CAT.[DrugOfInterest]
      ,CAT.[ChangesToday]
      ,CAT.[FirstUseDate]
      ,CAT.[StartDate]
      ,CAT.[DOIInitiationStatus]
      ,CAT.[AdditionalDOI]
      ,CAT.[SubscriberDOI]
      ,CAT.[TwelveMonthInitiationRule]
      ,CAT.[PriorJAKiUse]
      ,CAT.[FirstTimeUse]
	  ,CASE WHEN CAT.RegistryEnrollmentStatus = 'Not Eligible' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception') THEN 'Eligible - By Override'
	   WHEN CAT.RegistryEnrollmentStatus = 'Not Eligible' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND ISNULL(RAE.ExceptionGranted, '') IN ('', 'No') THEN 'Not Eligible - Confirmed'
	   WHEN CAT.RegistryEnrollmentStatus='Eligible'  AND RAE.PatientEligible='No' AND ExceptionGranted IS NULL THEN 'Eligible - By Override'
	   WHEN CAT.RegistryEnrollmentStatus='Needs Review' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception Granted') THEN 'Eligible - By Override'
	   WHEN CAT.RegistryEnrollmentStatus LIKE 'Eligible' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('No', 'Not Eligible') THEN 'Eligible - By Override'
	   WHEN CAT.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('Yes', 'Eligible') THEN 'Eligible - By Override'
	   WHEN CAT.RegistryEnrollmentStatus='Needs Review' AND PatientEligible IN ('Yes', 'Eligible') THEN 'Eligible'
	   WHEN CAT.RegistryEnrollmentStatus='Needs Review' AND PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('No', 'Not Eligible') THEN 'Not Eligible'
	   WHEN CAT.RegistryEnrollmentStatus='Needs Review' AND PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception Granted') THEN 'Eligible'
	   ELSE CAT.RegistryEnrollmentStatus
	   END AS RegistryEnrollmentStatus

	  ,CASE WHEN CAT.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('Yes', 'Not Eligible - Exception Granted') THEN 'Not Eligible - Exception Granted'
	   WHEN CAT.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('Yes', 'Eligible') THEN 'Eligible'
	   WHEN RAE.PatientEligible IN ('Under Review', 'Under review (outcome TBD)') THEN 'Under review (outcome TBD)'
	   WHEN CAT.RegistryEnrollmentStatus LIKE 'Not Eligible%' AND RAE.PatientEligible IN ('No', 'Not Eligible') AND RAE.ExceptionGranted IN ('No', 'Not Eligible') THEN 'Not Eligible'
	   WHEN PatientEligible='Yes' THEN 'Eligible'
	   WHEN PatientEligible='No' AND ISNULL(ExceptionGranted, '')='' THEN 'Not Eligible'
	   ELSE ''
	   END AS CalcExceptionGranted

	  ,CASE WHEN RAE.PatientEligible IN ('Under Review', 'Under review (outcome TBD)') THEN 'Under review (outcome TBD)'
	   ELSE RAE.PatientEligible
	   END AS PatientEligible
	  ,RAE.ExceptionGranted
	  ,RAE.ExceptionReason
      ,CASE WHEN CAT.[ConfirmationVisitDate] = '1900-01-01' THEN CAST(NULL AS date)
	   ELSE CAST(CAT.[ConfirmationVisitDate] AS date)
	   END AS [ConfirmationVisitDate] 
      ,CAT.[InitiationStatus]
      ,CAT.[SubscriberDOIAccrual]
	  ,CAT.[CsdmardCount]
  FROM [RA100].[t_op_DOI_Enroll_FirstFU] CAT
  LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.SiteNumber=CAT.SiteID AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
  LEFT JOIN [RA100].[t_op_RAExceptionsList] RAE ON RAE.SiteID=CAT.SiteID AND RAE.SubjectID=CAT.SubjectID AND RAE.EnrollmentDate=CAT.VisitDate

--ORDER BY VisitDate DESC, SubjectID
  --SELECT * FROM [RA100].[v_op_CAT] WHERE VisitDate >= '2022-01-01'  AND DrugOfInterest='CDMARD'
  --SELECT MAX(CsdmardCount) FROM [RA100].[v_op_CAT] WHERE CsdmardCount IS NOT NULL
  --AND DrugOfInterest='cDMARD or steroids only' 


GO
