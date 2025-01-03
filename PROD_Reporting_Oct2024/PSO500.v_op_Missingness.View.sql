USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_Missingness]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =================================================
-- Author:		Kevin Soe
-- Create date: 09/27/2022
-- Description:	Determine critical assesments are missing. 1=Missing 0=Not Missing
-- When data type is nvarchar, it's possible for blank values to be recorded so blank values need to be accounted for ISNULL. When data type is int, ISNULL cannot be used because 0 is equivalent to '' in SQL.
-- =================================================

		 --SELECT * FROM
CREATE VIEW [PSO500].[v_op_Missingness] AS

SELECT 
	 VIS.[Site Object SiteNo] AS [SiteID]
	,VIS.[Patient Object PatientNo] AS [SubjectID]
	,VIS.[Visit Object ProCaption] AS [VisitType]
	,CAST(VIS.[Visit Object VisitDate] AS DATE) AS [VisitDate]
    ,VIS.[Visit_VISVIRMD] AS [VisitCode]
	,CASE 
		WHEN SK1.[SK1_md_bsa] IS NULL THEN 1
		ELSE 0
	 END AS [BSA]
	,CASE 
		WHEN ISNULL(SK1.[SK2_md_global_pa],'')=''  THEN 1
		ELSE 0
	 END AS [IGA]
	--,SK1.[SK2_md_global_pa] AS [IGAActual]
	,CASE 
		WHEN ISNULL(PA1.[PASI1_PASI_HN_Skin],'')='' AND ISNULL(PA1.[PASI1_PASI_HN_Erythema],'')='' AND ISNULL(PA1.[PASI1_PASI_HN_Induration],'')='' AND  ISNULL(PA1.[PASI1_PASI_HN_Scaling],'')='' AND ISNULL(PA1.[PASI2_PASI_UE_Skin],'')='' AND ISNULL(PA1.[PASI2_PASI_UE_Erythema],'')='' AND ISNULL(PA1.[PASI2_PASI_UE_Induration],'')='' AND ISNULL(PA1.[PASI2_PASI_UE_Scaling],'')='' AND ISNULL(PA1.[PASI3_PASI_Torso_Skin],'')='' AND ISNULL(PA1.[PASI3_PASI_Torso_Erythema],'')='' AND ISNULL(PA1.[PASI3_PASI_Torso_Induration],'')='' AND ISNULL(PA1.[PASI3_PASI_Torso_Scaling],'')='' AND ISNULL(PA1.[PASI4_PASI_LE_Skin],'')='' AND ISNULL(PA1.[PASI4_PASI_LE_Erythema],'')='' AND ISNULL(PA1.[PASI4_PASI_LE_Induration],'')='' AND ISNULL(PA1.[PASI4_PASI_LE_Scaling],'')='' 
		THEN 1
		ELSE 0
	 END AS [PASI]
	,CASE 
		WHEN WBE.[WB2_pt_psoriasis_assess] IS NULL THEN 1
		ELSE 0
	 END AS [PGA]
	,CASE 
		WHEN ISNULL(WBE.[WB4_health_status_walking],'')='' AND ISNULL(WBE.[WB4_health_status_selfcare],'')='' AND ISNULL(WBE.[WB4_health_status_activies],'')='' AND  ISNULL(WBE.[WB4_health_status_pain],'')='' AND ISNULL(WBE.[WB4_health_status_anx_dep],'')='' AND WBE.[WB3_ps_pt_health_status] IS NULL AND ISNULL(WBE.[WB6_eq5d_mobility],'')='' AND ISNULL(WBE.[WB6_eq5d_selfcare],'')='' AND ISNULL(WBE.[WB6_eq5d_activities],'')='' AND ISNULL(WBE.[WB6_eq5d_pain],'')='' AND ISNULL(WBE.[WB6_eq5d_anxiety_depression],'')='' 
		THEN 1
		ELSE 0
	 END AS [EQ5D]
	,CASE 
		WHEN ISNULL(WBE.[WB5_ps_probs_pain],'')='' AND ISNULL(WBE.[WB5_ps_probs_embarras],'')='' AND ISNULL(WBE.[WB5_ps_probs_shop_home],'')='' AND  ISNULL(WBE.[WB5_ps_probs_clothes],'')='' AND ISNULL(WBE.[WB5_ps_probs_social],'')='' AND ISNULL(WBE.[WB5_ps_probs_sports],'')='' AND ISNULL(WBE.[WB5_ps_probs_work_prevent],'')='' AND ISNULL(WBE.[WB5_ps_probs_work_problem],'')='' AND ISNULL(WBE.[WB5_ps_probs_people],'')='' AND ISNULL(WBE.[WB5_ps_probs_sex],'')='' AND ISNULL(WBE.[WB5_ps_probs_treatment],'')='' 
		THEN 1
		ELSE 0
	 END AS [DLQI] --SELECT *
  FROM [OMNICOMM_PSO].[inbound].[VISIT] VIS
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_PSO].[inbound].[SKIN] SK1 ON VIS.PatientId = SK1.[PatientId] AND VIS.[VisitId] = SK1.[VisitId]
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_PSO].[inbound].[WB] WBE ON VIS.PatientId = WBE.[PatientId] AND VIS.[VisitId] = WBE.[VisitId]
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_PSO].[inbound].[PASI] PA1 ON VIS.PatientId = PA1.[PatientId] AND VIS.[VisitId] = PA1.[VisitId]
  WHERE VIS.[Visit Object ProCaption] = 'Enrollment'
  AND ISNULL(VIS.[Visit Object VisitDate],'')<>''
  AND VIS.[Site Object SiteNo] NOT LIKE '99%'

  UNION

SELECT 
	 VIS.[Site Object SiteNo] AS [SiteID]
	,VIS.[Patient Object PatientNo] AS [SubjectID]
	,VIS.[Visit Object ProCaption] AS [VisitType]
	,CAST(VIS.[Visit Object VisitDate] AS DATE) AS [VisitDate]
    ,VIS.[Visit_VISVIRMD] AS [VisitCode]
	,CASE 
		WHEN SK2.[SK1F_md_bsa_fu] IS NULL  THEN 1
		ELSE 0
	 END AS [BSA]
	,CASE 
		WHEN ISNULL(SK2.[SK2F_md_global_pa_fu],'')='' THEN 1
		ELSE 0
	 END AS [IGA]
	--,SK2.[SK2F_md_global_pa_fu] AS [IGAActual]
	,CASE 
		WHEN ISNULL(PA2.[PASI1F_PASI_HN_Skin_fu],'')='' AND ISNULL(PA2.[PASI1F_PASI_HN_Erythema_fu],'')='' AND ISNULL(PA2.[PASI1F_PASI_HN_Induration_fu],'')='' AND  ISNULL(PA2.[PASI1F_PASI_HN_Scaling_fu],'')='' AND ISNULL(PA2.[PASI2F_PASI_UE_Skin_fu],'')='' AND ISNULL(PA2.[PASI2F_PASI_UE_Erythema_fu],'')='' AND ISNULL(PA2.[PASI2F_PASI_UE_Induration_fu],'')='' AND ISNULL(PA2.[PASI2F_PASI_UE_Scaling_fu],'')='' AND ISNULL(PA2.[PASI3F_PASI_Torso_Skin_fu],'')='' AND ISNULL(PA2.[PASI3F_PASI_Torso_Erythema_fu],'')='' AND ISNULL(PA2.[PASI3F_PASI_Torso_Induration_fu],'')='' AND ISNULL(PA2.[PASI3F_PASI_Torso_Scaling_fu],'')='' AND ISNULL(PA2.[PASI4F_PASI_LE_Skin_fu],'')='' AND ISNULL(PA2.[PASI4F_PASI_LE_Erythema_fu],'')='' AND ISNULL(PA2.[PASI4F_PASI_LE_Induration_fu],'')='' AND ISNULL(PA2.[PASI4F_PASI_LE_Scaling_fu],'')='' 
		THEN 1
		ELSE 0
	 END AS [PASI]
	,CASE 
		WHEN WBF.[WBF2_pt_psoriasis_assess_fu] IS NULL THEN 1
		ELSE 0
	 END AS [PGA]
	,CASE 
		WHEN ISNULL(WBF.[WBF6_health_status_walking_fu],'')='' AND ISNULL(WBF.[WBF6_health_status_selfcare_fu],'')='' AND ISNULL(WBF.[WBF6_health_status_activies_fu],'')='' AND  ISNULL(WBF.[WBF6_health_status_pain_fu],'')='' AND ISNULL(WBF.[WBF6_health_status_anx_dep_fu],'')='' AND WBF.[WBF5_ps_pt_health_status_fu] IS NULL AND ISNULL(WBF.[WBF8_eq5d_mobility_fu],'')='' AND ISNULL(WBF.[WBF8_eq5d_selfcare_fu],'')='' AND ISNULL(WBF.[WBF8_eq5d_activities_fu],'')='' AND ISNULL(WBF.[WBF8_eq5d_pain_fu],'')='' AND ISNULL(WBF.[WBF8_eq5d_anxiety_depression_fu],'')='' 
		THEN 1
		ELSE 0
	 END AS [EQ5D]
	,CASE 
		WHEN ISNULL(WBF.[WBF7_ps_probs_pain_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_embarras_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_shop_home_fu],'')='' AND  ISNULL(WBF.[WBF7_ps_probs_clothes_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_social_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_sports_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_work_prevent_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_work_problem_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_people_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_sex_fu],'')='' AND ISNULL(WBF.[WBF7_ps_probs_treatment_fu],'')='' 
		THEN 1
		ELSE 0
	 END AS [DLQI] --SELECT *
  FROM [OMNICOMM_PSO].[inbound].[VISIT] VIS
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_PSO].[inbound].[SKIN2] SK2 ON VIS.PatientId = SK2.[PatientId] AND VIS.[VisitId] = SK2.[VisitId]
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_PSO].[inbound].[WBF] WBF ON VIS.PatientId = WBF.[PatientId] AND VIS.[VisitId] = WBF.[VisitId]
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_PSO].[inbound].[PASI2] PA2 ON VIS.PatientId = PA2.[PatientId] AND VIS.[VisitId] = PA2.[VisitId]
  WHERE VIS.[Visit Object ProCaption] = 'Follow-up'
  AND ISNULL(VIS.[Visit Object VisitDate],'')<>''
  AND VIS.[Site Object SiteNo] NOT LIKE '99%'
GO
