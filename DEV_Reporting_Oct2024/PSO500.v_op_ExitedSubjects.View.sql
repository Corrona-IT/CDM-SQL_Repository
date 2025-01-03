USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_ExitedSubjects]    Script Date: 11/13/2024 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [PSO500].[v_op_ExitedSubjects] AS



SELECT E.[VisitId]
      ,CAST(E.[Site Object SiteNo] AS int) AS SiteID
	  ,CASE WHEN ISNULL(SL.SiteStatus, '')='' THEN 'Active'
	   ELSE SL.SiteStatus
	   END AS SiteStatus
      ,CAST(E.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,CAST(SI.[Enroll Date] AS date) AS EnrollmentDate
	  ,SI.[birthdate_pat] AS YOB
	  ,E.[Visit Object ProCaption] AS VisitType
	  ,CAST(E.[Visit Object VisitDate] AS date) AS ExitDate
	  ,CAST(E.[EXIT1_Physician_Cod] AS int) AS ExitProviderID
	  ,E.[EXIT2_exit_reason] AS ExitReason
	  ,E.[EXIT2_other_specify] AS ExitReasonDetails
	  ,E4.[EXIT4_death_seriousinf] AS DeathInfection
	  ,E.[EXIT2_death_dt] AS DateofDeath
	  ,E.[EXIT10_exit_comments] AS ExitComments

FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT] E
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT4] AS E4 ON E4.VisitId=E.VisitId and E4.[Patient Object PatientNo]=E.[Patient Object PatientNo]
LEFT JOIN [OMNICOMM_PSO].[inbound].[G_Subject Information] SI on SI.[Sys. SiteNo]=E.[Site Object SiteNo] AND SI.[Sys. PatientNo]=E.[Patient Object PatientNo]
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SL on SL.SiteID=E.[Site Object SiteNo]
WHERE E.[Site Object SiteNo] NOT IN (997, 998, 999)
AND NOT EXISTS (SELECT [Patient Object PatientNo] FROM [OMNICOMM_PSO].[inbound].[VISIT] V WHERE V.[Patient Object PatientNo]=E.[Patient Object PatientNo] AND V.[Visit_VISIT] IN ('Enrollment', 'Follow-up') AND V.[Visit Object VisitDate] > E.[Visit Object VisitDate])




GO
