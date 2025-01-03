USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_Missingness]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =================================================
-- Author:		Kevin Soe
-- Create date: 09/27/2022
-- Description:	Determine critical assesments are missing. 1=Missing 0=Not Missing
-- =================================================

		 --SELECT * FROM
CREATE VIEW [NMO750].[v_op_Missingness] AS

SELECT 
	 sub.[SiteID] AS [SiteID]
	,pro.[subNum] AS [SubjectID]
	,pro.[eventName] AS [VisitType]
	,vis.[eventOccurrence] AS [VisitNumber]
	,CAST(vis.[visit_dt] AS DATE) AS [VisitDate]
	,'' AS [VisitCode]
	,CASE 
		WHEN CAST(pro.[moca_vis_impair] AS int) IS NULL AND CAST(pro.[moca_visuospatial] AS int) IS NULL AND  CAST(pro.[moca_naming] AS int) IS NULL AND CAST(pro.[moca_attn_digits] AS int) IS NULL AND CAST(pro.[moca_attn_letters] AS int) IS NULL AND CAST(pro.[moca_attn_serial7] AS int) IS NULL AND CAST(pro.[moca_language_repeat] AS int) IS NULL AND CAST(pro.[moca_language_fluency] AS int) IS NULL AND CAST(pro.[moca_abstraction] AS int) IS NULL AND CAST(pro.[moca_delayed_recall] AS int) IS NULL AND CAST(pro.[moca_mis] AS int) IS NULL AND CAST(pro.[moca_orientation] AS int) IS NULL AND CAST(pro.[moca_edu_adj] AS int) IS NULL AND CAST(pro.[moca_assessor] AS int) IS NULL 
		THEN 1
		ELSE 0
	 END AS [MOCA]
	,CASE 
		WHEN CAST(eds.[visual_correction] AS int) IS NULL AND CAST(eds.[visual_acuity_r] AS int) IS NULL AND  CAST(eds.[visual_acuity_l] AS int) IS NULL AND CAST(eds.[visual_fs_score] AS int) IS NULL AND CAST(eds.[brain_eom_impair] AS int) IS NULL AND CAST(eds.[brain_nystagmus] AS int) IS NULL AND CAST(eds.[brain_trigeminal_damage] AS int) IS NULL AND CAST(eds.[brain_facial_weakness] AS int) IS NULL AND CAST(eds.[brain_hearing_loss] AS int) IS NULL AND CAST(eds.[brain_dysarthria] AS int) IS NULL AND CAST(eds.[brain_dysphagia] AS int) IS NULL AND CAST(eds.[brain_fs_score] AS int) IS NULL AND CAST(eds.[reflex_plantar_r] AS int) IS NULL AND CAST(eds.reflex_plantar_l AS int) IS NULL AND CAST(eds.[strength_deltoid_r] AS int) IS NULL  AND CAST(eds.[strength_deltoid_l] AS int) IS NULL AND CAST(eds.[strength_biceps_r] AS int) IS NULL  AND CAST(eds.[strength_biceps_l] AS int) IS NULL  AND CAST(eds.[strength_triceps_r] AS int) IS NULL  AND CAST(eds.[strength_triceps_l] AS int) IS NULL  AND CAST(eds.[strength_finger_flex_r] AS int) IS NULL AND CAST(eds.[strength_finger_flex_l] AS int) IS NULL  AND CAST(eds.[strength_finger_ext_r] AS int) IS NULL AND CAST(eds.[strength_finger_ext_l] AS int) IS NULL AND CAST(eds.[strength_hip_flex_r] AS int) IS NULL AND CAST(eds.[strength_hip_flex_l] AS int) IS NULL AND CAST(eds.[strength_knee_flex_r] AS int) IS NULL AND CAST(eds.[strength_knee_flex_l] AS int) IS NULL AND CAST(eds.[strength_knee_ext_r] AS int) IS NULL AND CAST(eds.[strength_knee_ext_l] AS int) IS NULL AND CAST(eds.[strength_plantar_r] AS int) IS NULL AND CAST(eds.[strength_plantar_l] AS int) IS NULL AND CAST(eds.[strength_dorsiflexion_r] AS int) IS NULL AND CAST(eds.[strength_dorsiflexion_l] AS int) IS NULL AND CAST(eds.[pyramidal_fs_score] AS int) IS NULL AND CAST(eds.[cerebellar_fs_score] AS int) IS NULL AND CAST(eds.[sensory_superficial_ue_r] AS int) IS NULL AND CAST(eds.[sensory_superficial_ue_l] AS int) IS NULL AND CAST(eds.[sensory_superficial_trunk_r] AS int) IS NULL AND CAST(eds.[sensory_superficial_trunk_l] AS int) IS NULL AND CAST(eds.[sensory_superficial_le_r] AS int) IS NULL AND CAST(eds.[sensory_superficial_le_l] AS int) IS NULL AND CAST(eds.[sensory_vibration_ue_r] AS int) IS NULL AND CAST(eds.[sensory_vibration_ue_l] AS int) IS NULL AND CAST(eds.[sensory_vibration_le_r] AS int) IS NULL AND CAST(eds.[sensory_vibration_le_l] AS int) IS NULL  AND CAST(eds.[sensory_position_ue_r] AS int) IS NULL AND CAST(eds.[sensory_position_ue_l] AS int) IS NULL AND CAST(eds.[sensory_position_le_r] AS int) IS NULL  AND CAST(eds.[sensory_position_le_l] AS int) IS NULL AND CAST(eds.[sensory_fs_score] AS int) IS NULL AND CAST(eds.[bowel_urine_retension] AS int) IS NULL AND CAST(eds.[bowel_urine_urgency] AS int) IS NULL AND CAST(eds.[bowel_bladder_cath] AS int) IS NULL AND CAST(eds.[bowel_dysfunction] AS int) IS NULL AND CAST(eds.[bowel_fs_score] AS int) IS NULL  AND CAST(eds.[cerebral_fs_score] AS int) IS NULL  AND CAST(eds.[amb_score] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [EDSS]
	,CASE 
		WHEN CAST(eds.[nausea] AS int) IS NULL AND CAST(eds.[nausea_days] AS int) IS NULL AND  CAST(eds.[nausea_freq] AS int) IS NULL AND CAST(eds.[nausea_duration] AS int) IS NULL AND CAST(eds.[vomiting] AS int) IS NULL AND CAST(eds.[vomiting_days] AS int) IS NULL AND CAST(eds.[vomiting_freq] AS int) IS NULL AND CAST(eds.[vomiting_duration] AS int) IS NULL AND CAST(eds.[hiccups] AS int) IS NULL AND CAST(eds.[hiccups_days] AS int) IS NULL AND CAST(eds.[hiccups_freq] AS int) IS NULL AND CAST(eds.[hiccups_duration] AS int) IS NULL AND CAST(eds.[sleep_wake] AS int) IS NULL AND CAST(eds.[sleep_wake_severity] AS int) IS NULL AND CAST(eds.[anorexia] AS int) IS NULL AND CAST(eds.[anorexia_duration] AS int) IS NULL AND CAST(eds.[seizure] AS int) IS NULL AND CAST(eds.[seizure_severity] AS int) IS NULL AND CAST(eds.[siadh] AS int) IS NULL AND CAST(eds.[siadh_severity] AS int) IS NULL AND CAST(eds.[hypothermia] AS int) IS NULL AND CAST(eds.[hypothermia_severity] AS int) IS NULL AND CAST(eds.[hyperthermia] AS int) IS NULL AND CAST(eds.[hyperthermia_severity] AS int) IS NULL AND CAST(eds.[aphasia] AS int) IS NULL AND CAST(eds.[aphasia_severity] AS int) IS NULL    
		THEN 1
		ELSE 0
	 END AS [SYMPTOMS]
	,CASE 
		WHEN CAST(eds.[pupillary_defect_r] AS int) IS NULL AND CAST(eds.[pupillary_defect_l] AS int) IS NULL AND  CAST(eds.[abn_vis_r] AS int) IS NULL AND CAST(eds.[abn_vis_l] AS int) IS NULL AND CAST(eds.[abn_vis_loc_r_central] AS int) IS NULL AND CAST(eds.[abn_vis_loc_r_superotemp] AS int) IS NULL AND CAST(eds.[abn_vis_loc_r_superonasal] AS int) IS NULL AND CAST(eds.[abn_vis_loc_r_interotemp] AS int) IS NULL AND CAST(eds.[abn_vis_loc_r_interonasal] AS int) IS NULL AND CAST(eds.[abn_vis_loc_l_central] AS int) IS NULL AND CAST(eds.[abn_vis_loc_l_superotemp] AS int) IS NULL AND CAST(eds.[abn_vis_loc_l_superonasal] AS int) IS NULL AND CAST(eds.[abn_vis_loc_l_interotemp] AS int) IS NULL AND CAST(eds.[abn_vis_loc_l_interonasal] AS int) IS NULL AND CAST(eds.[visual_deficit_r] AS int) IS NULL  AND CAST(eds.[visual_deficit_l] AS int) IS NULL  AND CAST(eds.[visual_acuity_20400] AS int) IS NULL  AND CAST(eds.[best_eye_snellen] AS int) IS NULL  AND CAST(eds.[best_eye_count] AS int) IS NULL  AND CAST(eds.[best_eye_motion] AS int) IS NULL  AND CAST(eds.[best_eye_light] AS int) IS NULL  AND CAST(eds.[best_eye_unable] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [OPTIC]
  	,CASE 
		WHEN CAST(sbj.[mfis_alert] AS int) IS NULL AND CAST(sbj.[mfis_attention] AS int) IS NULL AND  CAST(sbj.[mfis_think_clearly] AS int) IS NULL AND CAST(sbj.[mfis_clumsy] AS int) IS NULL AND CAST(sbj.[mfis_forgetful] AS int) IS NULL AND CAST(sbj.[mfis_pace] AS int) IS NULL AND CAST(sbj.[mfis_motivate_physical] AS int) IS NULL AND CAST(sbj.[mfis_social_activities] AS int) IS NULL AND CAST(sbj.[mfis_away_from_home] AS int) IS NULL AND CAST(sbj.[mfis_maintain_physical] AS int) IS NULL AND CAST(sbj.[mfis_decisions] AS int) IS NULL AND CAST(sbj.[mfis_thinking] AS int) IS NULL AND CAST(sbj.[mfis_muscles] AS int) IS NULL AND CAST(sbj.[mfis_uncomfortable] AS int) IS NULL AND CAST(sbj.[mfis_tasks_thinking] AS int) IS NULL  AND CAST(sbj.[mfis_organize_thoughts] AS int) IS NULL  AND CAST(sbj.[mfis_tasks_physical] AS int) IS NULL  AND CAST(sbj.[mfis_thinking_slowed] AS int) IS NULL  AND CAST(sbj.[mfis_concentrating] AS int) IS NULL  AND CAST(sbj.[mfis_limit_physical] AS int) IS NULL  AND CAST(sbj.[mfis_rest] AS int) IS NULL 
		THEN 1
		ELSE 0
	 END AS [MFIS]
	,CASE 
		WHEN CAST(sbj.[eq5d_mobility] AS int) IS NULL AND CAST(sbj.[eq5d_selfcare] AS int) IS NULL AND  CAST(sbj.[eq5d_activities] AS int) IS NULL AND CAST(sbj.[eq5d_pain] AS int) IS NULL AND CAST(sbj.[eq5d_anxiety] AS int) IS NULL AND CAST(sbj.[eq5d_overall] AS int) IS NULL   
		THEN 1
		ELSE 0
	 END AS [EQ5D]
	,CASE 
		WHEN CAST(sbj.[phq2_interest] AS int) IS NULL AND CAST(sbj.[phq2_depressed] AS int) IS NULL  
		THEN 1
		ELSE 0
	 END AS [PHQ2]
	,CASE 
		WHEN CAST(sbj.[pd_pain_now] AS int) IS NULL AND CAST(sbj.[pd_pain_strongest] AS int) IS NULL AND  CAST(sbj.[pd_pain_average] AS int) IS NULL AND CAST(sbj.[pd_pain_picture] AS int) IS NULL AND CAST(sbj.[pd_pain_radiate] AS int) IS NULL AND CAST(sbj.[pd_burning] AS int) IS NULL AND CAST(sbj.[pd_tingling] AS int) IS NULL AND CAST(sbj.[pd_light_touch] AS int) IS NULL AND CAST(sbj.[pd_sudden_attack] AS int) IS NULL AND CAST(sbj.[pd_cold_heat] AS int) IS NULL AND CAST(sbj.[pd_numbness] AS int) IS NULL AND CAST(sbj.[pd_slight_pressure] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [PAIN]
	,CASE 
		WHEN CAST(sbj.[sfmpq_throbbing] AS int) IS NULL AND CAST(sbj.[sfmpq_shooting] AS int) IS NULL AND  CAST(sbj.[sfmpq_stabbing] AS int) IS NULL AND CAST(sbj.[sfmpq_sharp] AS int) IS NULL AND CAST(sbj.[sfmpq_cramping] AS int) IS NULL AND CAST(sbj.[sfmpq_gnawing] AS int) IS NULL AND CAST(sbj.[sfmpq_hotburning] AS int) IS NULL AND CAST(sbj.[sfmpq_aching] AS int) IS NULL AND CAST(sbj.[sfmpq_heavy] AS int) IS NULL AND CAST(sbj.[sfmpq_tender] AS int) IS NULL AND CAST(sbj.[sfmpq_splitting] AS int) IS NULL AND CAST(sbj.[sfmpq_tiring] AS int) IS NULL AND CAST(sbj.[sfmpq_sickening] AS int) IS NULL AND CAST(sbj.[sfmpq_fearful] AS int) IS NULL AND CAST(sbj.[sfmpq_punishing] AS int) IS NULL AND CAST(sbj.[sfmpq_electricshock] AS int) IS NULL AND CAST(sbj.[sfmpq_cold] AS int) IS NULL AND CAST(sbj.[sfmpq_piercing] AS int) IS NULL AND CAST(sbj.[sfmpq_lighttouch] AS int) IS NULL AND CAST(sbj.[sfmpq_itching] AS int) IS NULL AND CAST(sbj.[sfmpq_tingling] AS int) IS NULL AND CAST(sbj.[sfmpq_numbness] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [SFMPQ]--SELECT *
  FROM [RCC_NMOSD750].[staging].[visitdate] vis
  LEFT JOIN --SELECT * FROM
  [Reporting].[NMO750].[v_op_subjects] sub ON vis.subjectId=sub.patientId
  LEFT JOIN --SELECT * FROM
  [RCC_NMOSD750].[staging].[provider] pro ON pro.subjectId=vis.subjectId AND pro.[eventId] = vis.[eventId] AND pro.[eventOccurrence] = vis.[eventOccurrence]
  LEFT JOIN --SELECT * FROM
  [RCC_NMOSD750].[staging].[subjectform] sbj ON vis.subjectId=sbj.subjectId AND vis.[eventId] = sbj.[eventId] AND vis.[eventOccurrence] = sbj.[eventOccurrence]
  LEFT JOIN --SELECT * FROM
  [RCC_NMOSD750].[staging].[edssnmosdmodule] eds ON vis.subjectId=eds.subjectId AND vis.[eventId] = eds.[eventId] AND vis.[eventOccurrence] = eds.[eventOccurrence]
  WHERE ISNULL(vis.[visit_dt],'')<>''
  AND sub.[SiteID] IS NOT NULL
  AND sub.[SiteID] NOT LIKE '%1440%'
  AND sub.[SiteID] NOT LIKE '99%'
  

  
  

  
 


















































  













  


































GO
