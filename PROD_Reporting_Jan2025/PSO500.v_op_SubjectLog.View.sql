USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_SubjectLog]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [PSO500].[v_op_SubjectLog] AS



SELECT CAST(V.[Site Object SiteNo] AS int) AS SiteID
      ,CASE WHEN ISNULL(SL.SiteStatus, '')='' THEN 'Active'
	   ELSE SL.SiteStatus
	   END AS SiteStatus
      ,V.[Patient Object PatientNo] AS SubjectID
	  ,CAST(V.[Visit Object VisitDate] AS date) AS EnrollmentDate
	  ,SI.[birthdate_pat] AS YOB
	  ,V.[Visit Object ProCaption] AS VisitType
	  ,CAST(E.[Visit Object VisitDate] AS date) AS ExitDate
	  ,CAST(E.[EXIT1_Physician_Cod] AS int) AS ExitProviderID
	  ,E.[EXIT2_exit_reason] AS ExitReason
	  ,E.[EXIT2_other_specify] AS ExitReasonDetails
	  ,E4.[EXIT4_death_seriousinf] AS DeathInfection
	  ,E.[EXIT2_death_dt] AS DateofDeath
	  ,E.[EXIT10_exit_comments] AS ExitComments

FROM [OMNICOMM_PSO].[inbound].[VISIT] V
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT] E ON E.[Site Object SiteNo]=V.[Site Object SiteNo]
LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT_EXIT4] AS E4 ON E4.VisitId=E.VisitId and E4.[Patient Object PatientNo]=E.[Patient Object PatientNo]
AND E.[Patient Object PatientNo]=V.[Patient Object PatientNo]
LEFT JOIN [OMNICOMM_PSO].[inbound].[G_Subject Information] SI on SI.[Sys. SiteNo]=V.[Site Object SiteNo] AND SI.[Sys. PatientNo]=V.[Patient Object PatientNo]
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SL on SL.SiteID=V.[Site Object SiteNo]
WHERE V.[Site Object SiteNo] NOT IN (997, 998, 999) AND
V.[Visit Object ProCaption] ='Enrollment'

--ORDER BY V.[Site Object SiteNo], V.[Patient Object PatientNo]




GO
