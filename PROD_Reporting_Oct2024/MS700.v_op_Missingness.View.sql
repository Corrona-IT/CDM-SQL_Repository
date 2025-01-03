USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_Missingness]    Script Date: 11/13/2024 1:41:25 PM ******/
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
CREATE VIEW [MS700].[v_op_Missingness] AS

SELECT 
	 sub.[SiteID] AS [SiteID]
	,vis.[subNum] AS [SubjectID]
	,vis.[eventName] AS [VisitType]
	,CAST(vis.[visit_dt] AS DATE) AS [VisitDate]
	,vis.[visit_virtual_md_dec] AS [VisitCode]
	,pvs.[dx_ms_dec] AS [Diagnosis]
	,CASE 
		WHEN pvs.[cgi_dmt_current] = 1 AND pvs.[cgi] IS NULL THEN 1
		ELSE 0
	 END AS [CGI]
	,CASE --seconds for trials have to be cast as int to avoid varchar to numeric conversion error from occurring.
		WHEN (CAST(pcr.[t25fw_trial_1] AS int) IS NULL AND CAST(pcr.[t25fw_trial_time_sec_1]  AS int) IS NULL AND CAST(pcr.[t25fw_trial_affect_1] AS int) IS NULL AND  CAST(pcr.[t25fw_trial_rsn_not_1] AS int) IS NULL AND CAST(pcr.[t25fw_trial_rsn_not_attmpt_1] AS int) IS NULL) OR (pcr.[t25fw_trial_1] = 2) 
		THEN 1
		ELSE 0
	 END AS [25FWT1]
	,CASE 
		WHEN (CAST(pcr.[t25fw_trial_2] AS int) IS NULL AND CAST(pcr.[t25fw_trial_time_sec_2]  AS int) IS NULL AND CAST(pcr.[t25fw_trial_affect_2] AS int) IS NULL AND CAST(pcr.[t25fw_trial_rsn_not_2] AS int) IS NULL AND CAST(pcr.[t25fw_trial_rsn_not_attmpt_2] AS int) IS NULL) OR (pcr.[t25fw_trial_2] = 2) 
		THEN 1
		ELSE 0
	 END AS [25FWT2]
	,CASE 
		WHEN (CAST(pcr.[nhpt_dh_trial_1] AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_time_sec_1]  AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_affect_1] AS int) IS NULL AND  CAST(pcr.[nhpt_dh_trial_rsn_not_1] AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_rsn_not_attmpt_1] AS int) IS NULL) OR (pcr.[nhpt_dh_trial_1] = 2) 
		THEN 1
		ELSE 0
	 END AS [9HPT1]
	,CASE 
		WHEN (CAST(pcr.[nhpt_dh_trial_2] AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_time_sec_2]  AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_affect_2] AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_rsn_not_2] AS int) IS NULL AND CAST(pcr.[nhpt_dh_trial_rsn_not_attmpt_2] AS int) IS NULL) OR (pcr.[nhpt_dh_trial_2] = 2) 
		THEN 1
		ELSE 0
	 END AS [9HPT2]
	,CASE 
		WHEN (CAST(pcr.[nhpt_ndh_trial_1] AS int) IS NULL AND CAST(pcr.[nhpt_ndh_trial_time_sec_1]  AS int) IS NULL AND CAST(pcr.[nhpt_ndh_trial_affect_1] AS int) IS NULL AND CAST(pcr.[nhpt_ndh_trial_rsn_not_1] AS int) IS NULL AND CAST(pcr.[nhpt_ndh_trial_rsn_not_attmpt_1] AS int) IS NULL) OR (pcr.[nhpt_ndh_trial_1] = 2) 
		THEN 1
		ELSE 0
	 END AS [9HPTN]
	,CASE 
		WHEN CAST(pcr.[sdmt_correct] AS int) IS NULL AND CAST(pcr.[sdmt_attempted] AS int) IS NULL AND CAST(pcr.[sdmt_test_type] AS int) IS NULL 
		THEN 1
		ELSE 0
	 END AS [SDMT]
	,CASE 
		WHEN spr.[pdds] IS NULL THEN 1
		ELSE 0
	 END AS [PDDS]
	,CASE 
		WHEN smh.[dmt_current] = 1 AND smh.[dmt_pgic] IS NULL THEN 1
		ELSE 0
	 END AS [PGIC]
	,CASE 
		WHEN CAST(spr.[msis_tasks] AS int) IS NULL AND CAST(spr.[msis_grip] AS int) IS NULL AND  CAST(spr.[msis_carry] AS int) IS NULL AND CAST(spr.[msis_balance] AS int) IS NULL AND CAST(spr.[msis_moving] AS int) IS NULL AND CAST(spr.[msis_clumsy] AS int) IS NULL AND CAST(spr.[msis_stiff] AS int) IS NULL AND CAST(spr.[msis_heaviness] AS int) IS NULL AND CAST(spr.[msis_tremors] AS int) IS NULL AND CAST(spr.[msis_spasms] AS int) IS NULL AND CAST(spr.[msis_body] AS int) IS NULL AND CAST(spr.[msis_depend] AS int) IS NULL AND CAST(spr.[msis_activity] AS int) IS NULL AND CAST(spr.[msis_home] AS int) IS NULL AND CAST(spr.[msis_hands] AS int) IS NULL AND CAST(spr.[msis_time] AS int) IS NULL AND CAST(spr.[msis_transport] AS int) IS NULL AND CAST(spr.[msis_longer] AS int) IS NULL AND CAST(spr.[msis_moment] AS int) IS NULL AND CAST(spr.[msis_bathroom] AS int) IS NULL AND CAST(spr.[msis_unwell] AS int) IS NULL AND CAST(spr.[msis_sleeping] AS int) IS NULL AND CAST(spr.[msis_fatigue] AS int) IS NULL AND CAST(spr.[msis_worries] AS int) IS NULL AND CAST(spr.[msis_anxious] AS int) IS NULL AND CAST(spr.[msis_irritable] AS int) IS NULL AND CAST(spr.[msis_concentrate] AS int) IS NULL AND CAST(spr.[msis_confidence] AS int) IS NULL AND CAST(spr.[msis_depressed] AS int) IS NULL 
		THEN 1
		ELSE 0
	 END AS [MSIS]--SELECT *
  FROM [RCC_MS700].[staging].[visitinformation] vis
  LEFT JOIN --SELECT * FROM
  [Reporting].[MS700].[v_op_subjects] sub ON vis.subjectId=sub.patientId
  LEFT JOIN --SELECT * FROM
  [RCC_MS700].[staging].[providerdiseasestatus] pvs ON vis.[subNum] = pvs.[subNum] AND vis.[eventId] = pvs.[eventId] AND vis.[eventOccurrence] = pvs.[eventOccurrence]
  LEFT JOIN --SELECT * FROM
  [RCC_MS700].[staging].[providerclinicianreportedoutcomes] pcr ON vis.[subNum] = pcr.[subNum] AND vis.[eventId] = pcr.[eventId] AND vis.[eventOccurrence] = pcr.[eventOccurrence]
  LEFT JOIN --SELECT * FROM
  [RCC_MS700].[staging].[subjectpatientreportedoutcomes] spr ON vis.[subNum] = spr.[subNum] AND vis.[eventId] = spr.[eventId] AND vis.[eventOccurrence] = spr.[eventOccurrence]
  LEFT JOIN --SELECT * FROM
  [RCC_MS700].[staging].[subjectmedicalhistory] smh ON vis.[subNum] = smh.[subNum] AND vis.[eventId] = smh.[eventId] AND vis.[eventOccurrence] = smh.[eventOccurrence]
  WHERE ISNULL(vis.[visit_dt],'')<>''
  AND sub.[SiteID] <> '1440'
GO
