USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_SubjectLog]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/* =========================================================================================
-- Original Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- Description:	Procedure to create table for SubjectLog for page 3 of new Visit Planning SMR Report
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/1/2020
-- V1.2 Author: Kevin Soe
-- V1.2 Create Date: 7/26/2022
-- V1.2 Description: Fix to address issue where subjects showed up in multiple rows due to a cartesian product 
===========================================================================================
*/
			--  EXECUTE
CREATE PROCEDURE [PSO500].[usp_op_SubjectLog] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSO500].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NOT NULL,
	[SubjectID] [nvarchar] (30) NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[VisitType] [nvarchar] (100) NULL,
	[ExitDate] [date] NULL,
	[ExitProviderID] [int] NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (1000) NULL,
	[DeathInfection] [nvarchar] (1000) NULL,
	[DateofDeath] [date] NULL,
	[ExitComments] [nvarchar] (1000) NULL

);


*/


TRUNCATE TABLE [Reporting].[PSO500].[t_op_SubjectLog];


IF OBJECT_ID('tempdb..#SubjectLog') IS NOT NULL BEGIN DROP TABLE #SubjectLog END


SELECT CAST(V.[Site Object SiteNo] AS int) AS SiteID
      ,CASE WHEN ISNULL(SL.SiteStatus, '')='' THEN 'Active'
	   ELSE SL.SiteStatus
	   END AS SiteStatus
      ,V.[Patient Object PatientNo] AS SubjectID
	  ,CAST(V.[Visit Object VisitDate] AS date) AS EnrollmentDate
	  ,SI.[birthdate_pat] AS YOB
	  ,V.[Visit Object ProCaption] AS VisitType
	  --V1 ExitDate
	  --,CAST(E.[Visit Object VisitDate] AS date) AS ExitDate 
	  --V1.1 ExitDate
	  ,CASE
		WHEN E.[Visit Object VisitDate] = '' THEN NULL
		ELSE E.[Visit Object VisitDate] 
		END AS ExitDate
	  ,CAST(E.[EXIT1_Physician_Cod] AS int) AS ExitProviderID
	  ,E.[EXIT2_exit_reason] AS ExitReason
	  ,E.[EXIT2_other_specify] AS ExitReasonDetails
	  ,E.[EXIT4_death_seriousinf] AS DeathInfection
	  ,E.[EXIT2_death_dt] AS DateofDeath
	  ,E.[EXIT10_exit_comments] AS ExitComments

INTO #SubjectLog

FROM [OMNICOMM_PSO].[inbound].[VISIT] V
LEFT JOIN (SELECT DISTINCT E.[Site Object SiteNo], E.[Patient Object PatientNo], E.[Visit Object VisitDate], E.[EXIT1_Physician_Cod],E.[EXIT2_exit_reason], E.[EXIT2_other_specify],E4.[EXIT4_death_seriousinf],E.[EXIT2_death_dt], E.[EXIT10_exit_comments] FROM 
[OMNICOMM_PSO].[inbound].[EXIT] E
LEFT JOIN 
[OMNICOMM_PSO].[inbound].[EXIT_EXIT4] E4 ON E.[VisitId]=E4.[VisitId] AND E.[PatientId]=E4.[PatientId] AND E.[FormId]=E4.[FormId]) E ON E.[Site Object SiteNo]=V.[Site Object SiteNo] AND E.[Patient Object PatientNo]=V.[Patient Object PatientNo]
LEFT JOIN [OMNICOMM_PSO].[inbound].[G_Subject Information] SI on SI.[Sys. SiteNo]=V.[Site Object SiteNo] AND SI.[Sys. PatientNo]=V.[Patient Object PatientNo]
LEFT JOIN [Reporting].[PSO500].[v_op_SiteListing] SL on SL.SiteID=V.[Site Object SiteNo]
WHERE V.[Site Object SiteNo] NOT LIKE '99%' AND
V.[Visit Object ProCaption] ='Enrollment'


INSERT INTO [Reporting].[PSO500].[t_op_SubjectLog]
(
	[SiteID],
	[SiteStatus],
	[SubjectID],
	[EnrollmentDate],
	[YOB],
	[VisitType],
	[ExitDate],
	[ExitProviderID],
	[ExitReason],
	[ExitReasonDetails],
	[DeathInfection],
	[DateofDeath],
	[ExitComments]

)

SELECT CAST(SiteID AS int) AS SiteID
      ,SiteStatus
	  ,SubjectID
	  ,CAST(EnrollmentDate AS date) as EnrollmentDate
	  ,YOB
	  ,VisitType
	  ,CAST(ExitDate AS date) AS ExitDate
	  ,CAST(ExitProviderID AS int) AS ExitProviderID
	  ,CASE WHEN ISNULL(ExitDate, '')<>'' AND ISNULL(ExitReason, '')='' THEN 'Unknown Exit Reason' 
	   ELSE ExitReason
	   END AS ExitReason
	  ,ExitReasonDetails
	  ,DeathInfection
	  ,DateofDeath
	  ,ExitComments

FROM #SubjectLog



END













GO
