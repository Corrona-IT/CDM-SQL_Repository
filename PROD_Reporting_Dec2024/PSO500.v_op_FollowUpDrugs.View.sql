USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_FollowUpDrugs]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










/****PLEASE NOTE: This view feeds the PSO all drugs table*****/


CREATE VIEW [PSO500].[v_op_FollowUpDrugs] AS	


SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF2_bio_name_fu AS Treatment, 
		CASE WHEN LEN(BIOF2_oth_bio_use_fu)=0 THEN BIOF2_biosim_oth_name
		ELSE BIOF2_oth_bio_use_fu
		END AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF2_bio_name_fu<>''
		AND [BIOF2_bio_chg_no change_fu]=1 

UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF2_bio_name_fu AS Treatment, 
		CASE WHEN LEN(BIOF2_oth_bio_use_fu)=0 THEN BIOF2_biosim_oth_name
		ELSE BIOF2_oth_bio_use_fu
		END AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([BIOF2_bio_st_dt_fu], 1)='/' AND LEN([BIOF2_bio_st_dt_fu])=8 THEN LEFT([BIOF2_bio_st_dt_fu], 7) + '/01' 
		ELSE [BIOF2_bio_st_dt_fu] 
		END AS startDate,				
		STUFF(COALESCE(', '+NULLIF(BIOF2_bio_rsn1_fu__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF2_bio_rsn2_fu__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF2_bio_rsn3_fu__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN [BIOF2_bio_dose_fu]='Other' THEN [BIOF2_oth_bio_doseunits_fu] + ' ' + [BIOF2_bio_unit_fu]
	    ELSE [BIOF2_bio_dose_fu] + ' ' + [BIOF2_bio_unit_fu]
	    END AS Dose,
		CASE WHEN BIOF2_bio_freqdays_weeks_fu<>'' AND BIOF2_bio_freqdays_weeks_fu<>'' THEN 'q' + ' ' + BIOF2_bio_freqdays_weeks_fu + ' '  + REPLACE(BIOF2_bio_freq_fu, 'q_', '')
		ELSE BIOF2_bio_freq_fu
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF2_bio_name_fu<>''
		AND [BIOF2_bio_chg_startdrug_fu]=1

UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF2_bio_name_fu AS Treatment, 
		CASE WHEN LEN(BIOF2_oth_bio_use_fu)=0 THEN BIOF2_biosim_oth_name
		ELSE BIOF2_oth_bio_use_fu
		END AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		[BIOF2_bio_st_dt_fu2] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(BIOF2_bio_rsn1_fu2__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF2_bio_rsn2_fu2__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF2_bio_rsn3_fu2__C, ''), '')
			, 1, 1, '') AS changeReasons,

		CASE WHEN [BIOF2_bio_dose_fu2]='Other' THEN [BIOF2_oth_bio_doseunits_fu2] + ' ' + [BIOF2_bio_unit_fu2]
	    ELSE [BIOF2_bio_dose_fu2] + ' ' + [BIOF2_bio_unit_fu2]
	    END AS Dose,
		CASE WHEN BIOF2_bio_freqdays_weeks_fu2<>'' AND BIOF2_bio_freqdays_weeks_fu2<>'' THEN 'q' + ' ' + BIOF2_bio_freqdays_weeks_fu2 + ' '  + REPLACE(BIOF2_bio_freq_fu2, 'q_', '')
		ELSE BIOF2_bio_freq_fu2
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF2_bio_name_fu<>''
		AND [BIOF2_bio_chg_dosechange_fu]=1

UNION

SELECT  VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF2_bio_name_fu AS Treatment, 
		CASE WHEN LEN(BIOF2_oth_bio_use_fu)=0 THEN BIOF2_biosim_oth_name
		ELSE BIOF2_oth_bio_use_fu
		END AS otherTreatment, 
       'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		[BIOF2_bio_st_dt_fu3] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([BIOF2_bio_rsn1_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([BIOF2_bio_rsn2_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([BIOF2_bio_rsn3_fu3__C], ''), '')
			, 1, 1, '') AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF2_bio_name_fu<>''
		AND [BIOF2_bio_chg_stopdrug_fu]=1

UNION


SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  ,[CTF2_bionb_name_fu] AS Treatment
	  ,CASE WHEN [CTF2_bionb_name_fu] LIKE 'Other%' AND [CTF2_other_bionb_specify_fu]<>'' THEN [CTF2_other_bionb_specify_fu]
            WHEN [CTF2_bionb_name_fu] LIKE 'Other%' AND [CTF2_biosim_oth_name]<>'' THEN [CTF2_biosim_oth_name]
			ELSE ''
			END AS otherTreatment
      ,[CTF2_bionb_status_fu] AS TreatmentStatus
      ,[CTF2_rx_today_1stdose_rcvd_fu] AS FirstDoseToday
	  ,'' AS firstUse

	  ,CASE WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_rx_today_1stdose_rcvd_fu]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS StartDate

	  ,CASE WHEN [CTF2_bionb_status_fu]='Prescribed Today' THEN STUFF(COALESCE(', '+NULLIF([CTF2_bionb_rsntoday1_fu__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF2_bionb_rsntoday2_fu__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF2_bionb_rsntoday3_fu__C], ''), '')
			, 1, 1, '')
		ELSE ''
		END AS StartReasons

	  ,'' AS changeDate
	  ,'' AS changeReasons

	   ,CASE WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_bionb_presdose_fu]='Other' AND ISNUMERIC([CTF2_other_bionb_presdoseunits_fu])=1 THEN [CTF2_other_bionb_presdoseunits_fu] + ' ' + [CTF2_bionb_presdoseunits_fu]
	    WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_bionb_presdose_fu]='Other' AND ISNUMERIC([CTF2_other_bionb_presdoseunits_fu])=0 THEN [CTF2_other_bionb_presdoseunits_fu]
	    WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_bionb_presdose_fu] NOT LIKE 'Other%' THEN [CTF2_bionb_presdose_fu] + ' ' + [CTF2_bionb_presdoseunits_fu]
		ELSE ''
	    END AS Dose

	   ,CASE WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_bionb_presfreqweeks_fu]<>'' AND [CTF2_bionb_presfreq_fu] LIKE 'q_%' THEN 'q' + ' ' + [CTF2_bionb_presfreqweeks_fu] + ' '  + REPLACE([CTF2_bionb_presfreq_fu], 'q_', '')
	    WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_bionb_presfreqweeks_fu]<>'' AND [CTF2_bionb_presfreq_fu] NOT LIKE 'q_%' THEN [CTF2_bionb_presfreqweeks_fu]
		WHEN [CTF2_bionb_status_fu]='Prescribed Today' AND [CTF2_bionb_presfreqweeks_fu]='' THEN [CTF2_bionb_presfreq_fu]
	    ELSE ''
		END AS Frequency

	  ,'' AS stopDate
	  ,'' AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF2_bionb_name_fu]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF2_bionb_status_fu]='Prescribed Today'
  
UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  ,[CTF2_bionb_name_fu] AS Treatment
	  ,CASE WHEN [CTF2_bionb_name_fu] LIKE 'Other%' AND [CTF2_other_bionb_specify_fu]<>'' THEN [CTF2_other_bionb_specify_fu]
            WHEN [CTF2_bionb_name_fu] LIKE 'Other%' AND [CTF2_biosim_oth_name]<>'' THEN [CTF2_biosim_oth_name]
			ELSE ''
			END AS otherTreatment
      ,[CTF2_bionb_status_fu] AS TreatmentStatus
      ,[CTF2_rx_today_1stdose_rcvd_fu] AS FirstDoseToday
	  ,'' AS firstUse

	  ,'' AS StartDate

	  ,'' AS StartReasons

	  ,CASE WHEN [CTF2_bionb_status_fu]='Changes Prescribed' THEN [Visit Object VisitDate] 
	   ELSE ''
	   END AS changeDate
	  ,CASE WHEN [CTF2_bionb_status_fu]='Changes Prescribed' THEN STUFF(COALESCE(', '+NULLIF([CTF2_bionb_rsntoday1_fu__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF2_bionb_rsntoday2_fu__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF2_bionb_rsntoday3_fu__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS changeReasons
	   ,CASE WHEN [CTF2_bionb_status_fu]='Changes Prescribed' AND [CTF2_bionb_presdose_fu]='Other' AND ISNUMERIC([CTF2_other_bionb_presdoseunits_fu])=1 THEN [CTF2_other_bionb_presdoseunits_fu] + ' ' + [CTF2_bionb_presdoseunits_fu]
	    WHEN [CTF2_bionb_status_fu]='Changes Prescribed' AND [CTF2_bionb_presdose_fu]='Other' AND ISNUMERIC([CTF2_other_bionb_presdoseunits_fu])=0 THEN [CTF2_other_bionb_presdoseunits_fu]
		WHEN [CTF2_bionb_status_fu]='Changes Prescribed' AND  [CTF2_bionb_presdose_fu]<>'Other' THEN [CTF2_bionb_presdose_fu] + ' ' + [CTF2_bionb_presdoseunits_fu]
	    ELSE ''
	    END AS Dose

	   ,CASE WHEN [CTF2_bionb_status_fu]='Changes Prescribed' AND [CTF2_bionb_presfreqweeks_fu]<>'' AND [CTF2_bionb_presfreq_fu] LIKE 'q_%' THEN 'q' + ' ' + [CTF2_bionb_presfreqweeks_fu] + ' '  + REPLACE([CTF2_bionb_presfreq_fu], 'q_', '')
	    WHEN [CTF2_bionb_status_fu]='Changes Prescribed' AND [CTF2_bionb_presfreqweeks_fu]<>'' AND [CTF2_bionb_presfreq_fu] NOT LIKE 'q_%' THEN [CTF2_bionb_presfreqweeks_fu]
		WHEN [CTF2_bionb_status_fu]='Changes Prescribed' AND [CTF2_bionb_presfreqweeks_fu]='' THEN [CTF2_bionb_presfreq_fu]
	    ELSE ''
		END AS Frequency

	  ,'' AS stopDate
	  ,'' AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF2_bionb_name_fu]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF2_bionb_status_fu]='Changes Prescribed'

UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  ,[CTF2_bionb_name_fu] AS Treatment
	  ,CASE WHEN [CTF2_bionb_name_fu] LIKE 'Other%' AND [CTF2_other_bionb_specify_fu]<>'' THEN [CTF2_other_bionb_specify_fu]
            WHEN [CTF2_bionb_name_fu] LIKE 'Other%' AND [CTF2_biosim_oth_name]<>'' THEN [CTF2_biosim_oth_name]
			ELSE ''
			END AS otherTreatment
      ,[CTF2_bionb_status_fu] AS TreatmentStatus
      ,[CTF2_rx_today_1stdose_rcvd_fu] AS FirstDoseToday
	  ,'' AS firstUse
	  ,'' AS StartDate
	  ,'' AS StartReasons
	  ,'' AS changeDate
	  ,'' AS changeReasons
	   ,'' AS Dose
	   ,'' AS Frequency

	  ,CASE WHEN [CTF2_bionb_status_fu]='Stopped Today' THEN [Visit Object VisitDate] 
	   ELSE ''
	   END AS stopDate

	  ,CASE WHEN [CTF2_bionb_status_fu]='Stopped Today' THEN STUFF(COALESCE(', '+NULLIF([CTF2_bionb_rsntoday1_fu__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF2_bionb_rsntoday2_fu__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF2_bionb_rsntoday3_fu__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF2_bionb_name_fu]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF2_bionb_status_fu]='Stopped Today'

UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF3_bio_name_fu2 AS Treatment, 
		CASE WHEN LEN(BIOF3_oth_bio_use_fu2)=0 THEN BIOF3_biosim_oth_name2
		ELSE BIOF3_oth_bio_use_fu2
		END AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF3_bio_name_fu2<>''
		AND [BIOF3_bio_chg_no change_fu2]=1 

UNION
		
SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF3_bio_name_fu2 AS Treatment, 
		CASE WHEN LEN(BIOF3_oth_bio_use_fu2)=0 THEN BIOF3_biosim_oth_name2
		ELSE BIOF3_oth_bio_use_fu2
		END AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([BIOF3_bio_st_dt_fu4], 1)='/' AND LEN([BIOF3_bio_st_dt_fu4])=8 THEN LEFT([BIOF3_bio_st_dt_fu4], 7) + '/01' 
		ELSE [BIOF3_bio_st_dt_fu4] 
		END AS startDate,			
		STUFF(COALESCE(', '+NULLIF(BIOF3_bio_rsn1_fu4__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF3_bio_rsn2_fu4__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF3_bio_rsn3_fu4__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN [BIOF3_bio_dose_fu4]='Other' THEN [BIOF3_oth_bio_doseunits_fu4] + ' ' + [BIOF3_bio_unit_fu4]
	    ELSE [BIOF3_bio_dose_fu4] + ' ' + [BIOF3_bio_unit_fu4]
	    END AS Dose,
		CASE WHEN BIOF3_bio_freqdays_weeks_fu4<>'' AND BIOF3_bio_freqdays_weeks_fu4<>'' THEN 'q' + ' ' + BIOF3_bio_freqdays_weeks_fu4 + ' '  + REPLACE(BIOF3_bio_freq_fu4, 'q_', '')
		ELSE BIOF3_bio_freq_fu4
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF3_bio_name_fu2<>''
		AND [BIOF3_bio_chg_startdrug_fu2]=1

UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF3_bio_name_fu2 AS Treatment, 
		CASE WHEN LEN(BIOF3_oth_bio_use_fu2)=0 THEN BIOF3_biosim_oth_name2
		ELSE BIOF3_oth_bio_use_fu2
		END AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		[BIOF3_bio_st_dt_fu5] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(BIOF3_bio_rsn1_fu5__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF3_bio_rsn2_fu5__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF3_bio_rsn3_fu5__C, ''), '')
			, 1, 1, '') AS changeReasons,

		CASE WHEN [BIOF3_bio_dose_fu5]='Other' THEN [BIOF3_oth_bio_doseunits_fu5] + ' ' + [BIOF3_bio_unit_fu5]
	    ELSE [BIOF3_bio_dose_fu5] + ' ' + [BIOF3_bio_unit_fu5]
	    END AS Dose,
		CASE WHEN BIOF3_bio_freqdays_weeks_fu5<>'' AND BIOF3_bio_freqdays_weeks_fu5<>'' THEN 'q' + ' ' + BIOF3_bio_freqdays_weeks_fu5 + ' '  + REPLACE(BIOF3_bio_freq_fu5, 'q_', '')
		ELSE BIOF3_bio_freq_fu5
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF3_bio_name_fu2<>''
		AND [BIOF3_bio_chg_dosechange_fu2]=1

UNION

SELECT  VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF3_bio_name_fu2 AS Treatment, 
		CASE WHEN LEN(BIOF3_oth_bio_use_fu2)=0 THEN BIOF3_biosim_oth_name2
		ELSE BIOF3_oth_bio_use_fu2
		END AS otherTreatment ,
       'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		[BIOF3_bio_st_dt_fu6] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([BIOF3_bio_rsn1_fu6__C], ''), '')
			+ COALESCE(', '+NULLIF([BIOF3_bio_rsn2_fu6__C], ''), '')
			+ COALESCE(', '+NULLIF([BIOF3_bio_rsn3_fu6__C], ''), '')
			, 1, 1, '') AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF3_bio_name_fu2<>''
		AND [BIOF3_bio_chg_stopdrug_fu2]=1

UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
      ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
      ,[CTF3_bionb_name_fu2] AS Treatment
	  ,CASE WHEN [CTF3_bionb_name_fu2] LIKE 'Other%' AND [CTF3_other_bionb_specify_fu2]<>'' THEN [CTF3_other_bionb_specify_fu2]
            WHEN [CTF3_bionb_name_fu2] LIKE 'Other%' AND [CTF3_biosim_oth_name2]<>'' THEN [CTF3_biosim_oth_name2]
			ELSE ''
			END AS otherTreatment
      ,[CTF3_bionb_status_fu2] AS TreatmentStatus
      ,[CTF3_rx_today_1stdose_rcvd_fu2] AS FirstDoseToday
	  ,'' AS firstUse

	  ,CASE WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_rx_today_1stdose_rcvd_fu2]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS StartDate
	  ,CASE WHEN [CTF3_bionb_status_fu2]='Prescribed Today' THEN STUFF(COALESCE(', '+NULLIF([CTF3_bionb_rsntoday1_fu2__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF3_bionb_rsntoday2_fu2__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF3_bionb_rsntoday3_fu2__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS startReasons

	  ,'' AS changeDate
	  ,'' AS changeReasons


	   ,CASE WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_bionb_presdose_fu2]='Other' AND ISNUMERIC([CTF3_other_bionb_presdoseunits_fu2])=1 THEN [CTF3_other_bionb_presdoseunits_fu2] + ' ' + [CTF3_bionb_presdoseunits_fu2]
	    WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_bionb_presdose_fu2]='Other' AND ISNUMERIC([CTF3_other_bionb_presdoseunits_fu2])=0 THEN [CTF3_other_bionb_presdoseunits_fu2]
	    WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_bionb_presdose_fu2] NOT LIKE 'Other%' THEN [CTF3_bionb_presdose_fu2] + ' ' + [CTF3_bionb_presdoseunits_fu2]
		ELSE ''
	    END AS Dose
	   ,CASE WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_bionb_presfreqweeks_fu2]<>'' AND [CTF3_bionb_presfreq_fu2] LIKE 'q_%' THEN 'q' + ' ' + [CTF2_bionb_presfreqweeks_fu] + ' '  + REPLACE([CTF3_bionb_presfreq_fu2], 'q_', '')
	    WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_bionb_presfreqweeks_fu2]<>'' AND [CTF3_bionb_presfreq_fu2] NOT LIKE 'q_%' THEN [CTF3_bionb_presfreqweeks_fu2]
		WHEN [CTF3_bionb_status_fu2]='Prescribed Today' AND [CTF3_bionb_presfreqweeks_fu2]='' THEN [CTF3_bionb_presfreq_fu2]
	    ELSE ''
		END AS Frequency

	  ,'' AS stopDate
	  ,'' AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF3_bionb_name_fu2]<>''
  AND  ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF3_bionb_status_fu2]='Prescribed Today'

UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  ,[CTF3_bionb_name_fu2] AS Treatment
	  ,CASE WHEN [CTF3_bionb_name_fu2] LIKE 'Other%' AND [CTF3_other_bionb_specify_fu2]<>'' THEN [CTF3_other_bionb_specify_fu2]
            WHEN [CTF3_bionb_name_fu2] LIKE 'Other%' AND [CTF3_biosim_oth_name2]<>'' THEN [CTF3_biosim_oth_name2]
			ELSE ''
			END AS otherTreatment
      ,[CTF3_bionb_status_fu2] AS TreatmentStatus
      ,[CTF3_rx_today_1stdose_rcvd_fu2] AS FirstDoseToday
	  ,'' AS firstUse

	  ,'' AS StartDate
	  ,'' AS startReasons

	  ,CASE WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS changeDate
	  ,CASE WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' THEN STUFF(COALESCE(', '+NULLIF([CTF3_bionb_rsntoday1_fu2__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF3_bionb_rsntoday2_fu2__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF3_bionb_rsntoday3_fu2__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS changeReasons
		
	   ,CASE WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' AND [CTF3_bionb_presdose_fu2]='Other' AND ISNUMERIC([CTF3_other_bionb_presdoseunits_fu2])=1 THEN [CTF3_other_bionb_presdoseunits_fu2] + ' ' + [CTF3_bionb_presdoseunits_fu2]
	    WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' AND [CTF3_bionb_presdose_fu2]='Other' AND ISNUMERIC([CTF3_other_bionb_presdoseunits_fu2])=0 THEN [CTF3_other_bionb_presdoseunits_fu2]
	    WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' AND [CTF3_bionb_presdose_fu2] NOT LIKE 'Other%' THEN [CTF3_bionb_presdose_fu2] + ' ' + [CTF3_other_bionb_presdoseunits_fu2]
		ELSE ''
	    END AS Dose
	   ,CASE WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' AND [CTF3_bionb_presfreqweeks_fu2]<>'' AND [CTF3_bionb_presfreq_fu2] LIKE 'q_%' THEN 'q' + ' ' + [CTF3_bionb_presfreqweeks_fu2] + ' '  + REPLACE([CTF3_bionb_presfreq_fu2], 'q_', '')
	    WHEN [CTF3_bionb_status_fu2]='Changes Prescribed'AND [CTF3_bionb_presfreqweeks_fu2]<>'' AND [CTF3_bionb_presfreq_fu2] NOT LIKE 'q_%' THEN [CTF3_bionb_presfreqweeks_fu2]
		WHEN [CTF3_bionb_status_fu2]='Changes Prescribed' AND [CTF3_bionb_presfreqweeks_fu2]='' THEN [CTF3_bionb_presfreq_fu2]
	    ELSE ''
		END AS Frequency

	  ,'' AS stopDate
	  ,'' AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF3_bionb_name_fu2]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF3_bionb_status_fu2]='Changes Prescribed'
  
  
UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  	  ,[CTF3_bionb_name_fu2] AS Treatment
	  ,CASE WHEN [CTF3_bionb_name_fu2] LIKE 'Other%' AND [CTF3_other_bionb_specify_fu2]<>'' THEN [CTF3_other_bionb_specify_fu2]
            WHEN [CTF3_bionb_name_fu2] LIKE 'Other%' AND [CTF3_biosim_oth_name2]<>'' THEN [CTF3_biosim_oth_name2]
			ELSE ''
			END AS otherTreatment
      ,[CTF3_bionb_status_fu2] AS TreatmentStatus
      ,[CTF3_rx_today_1stdose_rcvd_fu2] AS FirstDoseToday
	  ,'' AS firstUse

	  ,'' AS StartDate
	  ,'' AS startReasons

	  ,'' AS changeDate
	  ,'' AS changeReasons
		
	   ,'' AS Dose
	   ,'' AS Frequency

	  ,CASE WHEN [CTF3_bionb_status_fu2]='Stopped Today' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS stopDate
	  ,CASE WHEN [CTF3_bionb_status_fu2]='Stopped Today' THEN STUFF(COALESCE(', '+NULLIF([CTF3_bionb_rsntoday1_fu2__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF3_bionb_rsntoday2_fu2__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF3_bionb_rsntoday3_fu2__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF3_bionb_name_fu2]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF3_bionb_status_fu2]='Stopped Today'
  
UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF4_bio_name_fu3 AS Treatment, 
		CASE WHEN LEN(BIOF4_oth_bio_use_fu3)=0 THEN BIOF4_biosim_oth_name3
		ELSE BIOF4_oth_bio_use_fu3
		END AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([BIOF4_bio_st_dt_fu7], 1)='/' AND LEN([BIOF4_bio_st_dt_fu7])=8 THEN LEFT([BIOF4_bio_st_dt_fu7], 7) + '/01' 
		ELSE [BIOF4_bio_st_dt_fu7] 
		END AS startDate,
		STUFF(COALESCE(', '+NULLIF(BIOF4_bio_rsn1_fu7__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF4_bio_rsn2_fu7__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF4_bio_rsn3_fu7__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN [BIOF4_bio_dose_fu7]='Other' THEN [BIOF4_oth_bio_doseunits_fu7] + ' ' + [BIOF4_bio_unit_fu7]
	    ELSE [BIOF4_bio_dose_fu7] + ' ' + [BIOF4_bio_unit_fu7]
	    END AS Dose,
		CASE WHEN BIOF4_bio_freqdays_weeks_fu7<>'' AND BIOF4_bio_freqdays_weeks_fu7<>'' THEN 'q' + ' ' + BIOF4_bio_freqdays_weeks_fu7 + ' '  + REPLACE(BIOF4_bio_freq_fu7, 'q_', '')
		ELSE BIOF4_bio_freq_fu7
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF4_bio_name_fu3<>''
		AND [BIOF4_bio_chg_startdrug_fu3]=1

UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF4_bio_name_fu3 AS Treatment, 
		CASE WHEN LEN(BIOF4_oth_bio_use_fu3)=0 THEN BIOF4_biosim_oth_name3
		ELSE BIOF4_oth_bio_use_fu3
		END AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		[BIOF4_bio_st_dt_fu8] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(BIOF4_bio_rsn1_fu8__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF4_bio_rsn2_fu8__C, ''), '')
			+ COALESCE(', '+NULLIF(BIOF4_bio_rsn3_fu8__C, ''), '')
			, 1, 1, '') AS changeReasons,

		CASE WHEN [BIOF4_bio_dose_fu8]='Other' THEN [BIOF4_oth_bio_doseunits_fu8] + ' ' + [BIOF4_bio_unit_fu8]
	    ELSE [BIOF4_bio_dose_fu8] + ' ' + [BIOF4_bio_unit_fu8]
	    END AS Dose,
		CASE WHEN BIOF4_bio_freqdays_weeks_fu8<>'' AND BIOF4_bio_freqdays_weeks_fu8<>'' THEN 'q' + ' ' + BIOF4_bio_freqdays_weeks_fu8 + ' '  + REPLACE(BIOF4_bio_freq_fu8, 'q_', '')
		ELSE BIOF4_bio_freq_fu8
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF4_bio_name_fu3<>''
		AND [BIOF4_bio_chg_dosechange_fu3]=1

UNION

SELECT  VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF4_bio_name_fu3 AS Treatment, 
		CASE WHEN LEN(BIOF4_oth_bio_use_fu3)=0 THEN BIOF4_biosim_oth_name3
		ELSE BIOF4_oth_bio_use_fu3
		END AS otherTreatment,
       'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		[BIOF4_bio_st_dt_fu9] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([BIOF4_bio_rsn1_fu9__C], ''), '')
			+ COALESCE(', '+NULLIF([BIOF4_bio_rsn2_fu9__C], ''), '')
			+ COALESCE(', '+NULLIF([BIOF4_bio_rsn3_fu9__C], ''), '')
			, 1, 1, '') AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF4_bio_name_fu3<>''
		AND [BIOF4_bio_chg_stopdrug_fu3]=1
		
UNION

SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF4_bio_name_fu3 AS Treatment, 
		CASE WHEN LEN(BIOF4_oth_bio_use_fu3)=0 THEN BIOF4_biosim_oth_name3
		ELSE BIOF4_oth_bio_use_fu3
		END AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF4_bio_name_fu3<>''
		AND [BIOF4_bio_chg_no change_fu3]=1 
		
UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
      ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
      ,[CTF4_bionb_name_fu3] AS Treatment
	  ,CASE WHEN [CTF4_bionb_name_fu3] LIKE 'Other%' AND [CTF4_other_bionb_specify_fu3]<>'' THEN [CTF4_other_bionb_specify_fu3]
            WHEN [CTF4_bionb_name_fu3] LIKE 'Other%' AND [CTF4_biosim_oth_name3]<>'' THEN [CTF4_biosim_oth_name3]
			ELSE ''
			END AS otherTreatment
      ,[CTF4_bionb_status_fu3] AS TreatmentStatus
      ,[CTF4_rx_today_1stdose_rcvd_fu3] AS FirstDoseToday
	  ,'' AS firstUse

	  ,CASE WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_rx_today_1stdose_rcvd_fu3]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS StartDate
	  ,CASE WHEN [CTF4_bionb_status_fu3]='Prescribed Today' THEN 
	    STUFF(COALESCE(', '+NULLIF([CTF4_bionb_rsntoday1_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF4_bionb_rsntoday2_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF4_bionb_rsntoday3_fu3__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS startReasons

	  ,'' AS changeDate
	  ,'' AS changeReasons

	   ,CASE WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_bionb_presdose_fu3]='Other' AND ISNUMERIC([CTF4_other_bionb_presdoseunits_fu3])=1 THEN [CTF4_other_bionb_presdoseunits_fu3] + ' ' + [CTF4_bionb_presdoseunits_fu3]
	    WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_bionb_presdose_fu3]='Other' AND ISNUMERIC([CTF4_other_bionb_presdoseunits_fu3])=0 THEN [CTF4_other_bionb_presdoseunits_fu3]
	    WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_bionb_presdose_fu3] NOT LIKE 'Other%' THEN [CTF4_bionb_presdose_fu3] + ' ' + [CTF4_bionb_presdoseunits_fu3]
		ELSE ''
	    END AS Dose
	   ,CASE WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_bionb_presfreqweeks_fu3]<>'' AND [CTF4_bionb_presfreq_fu3] LIKE 'q_%' THEN 'q' + ' ' + [CTF4_bionb_presfreqweeks_fu3] + ' '  + REPLACE([CTF4_bionb_presfreq_fu3], 'q_', '')
	    WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_bionb_presfreqweeks_fu3]<>'' AND [CTF4_bionb_presfreq_fu3] NOT LIKE 'q_%' THEN [CTF4_bionb_presfreqweeks_fu3]
		WHEN [CTF4_bionb_status_fu3]='Prescribed Today' AND [CTF4_bionb_presfreqweeks_fu3]='' THEN [CTF4_bionb_presfreq_fu3]
	    ELSE ''
		END AS Frequency

	  ,'' AS stopDate
	  ,'' AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF4_bionb_name_fu3]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF4_bionb_status_fu3]='Prescribed Today'


UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  ,[CTF4_bionb_name_fu3] AS Treatment
	  ,CASE WHEN [CTF4_bionb_name_fu3] LIKE 'Other%' AND [CTF4_other_bionb_specify_fu3]<>'' THEN [CTF4_other_bionb_specify_fu3]
            WHEN [CTF4_bionb_name_fu3] LIKE 'Other%' AND [CTF4_biosim_oth_name3]<>'' THEN [CTF4_biosim_oth_name3]
			ELSE ''
			END AS otherTreatment
      ,[CTF4_bionb_status_fu3] AS TreatmentStatus
      ,[CTF4_rx_today_1stdose_rcvd_fu3] AS FirstDoseToday
	  ,'' AS firstUse

	  ,'' AS StartDate
	  ,'' AS startReasons

	  ,CASE WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_rx_today_1stdose_rcvd_fu3]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS changeDate
	  ,CASE WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' THEN 
	    STUFF(COALESCE(', '+NULLIF([CTF4_bionb_rsntoday1_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF4_bionb_rsntoday2_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF4_bionb_rsntoday3_fu3__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS changeReasons
		
	   ,CASE WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_bionb_presdose_fu3]='Other' AND ISNUMERIC([CTF4_other_bionb_presdoseunits_fu3])=1 THEN [CTF4_other_bionb_presdoseunits_fu3] + ' ' + [CTF4_bionb_presdoseunits_fu3]
	    WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_bionb_presdose_fu3]='Other' AND ISNUMERIC([CTF4_other_bionb_presdoseunits_fu3])=0 THEN [CTF4_other_bionb_presdoseunits_fu3]
	    WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_bionb_presdose_fu3] NOT LIKE 'Other%' THEN [CTF4_bionb_presdose_fu3] + ' ' + [CTF4_bionb_presdoseunits_fu3]
		ELSE ''
	    END AS Dose
	   ,CASE WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_bionb_presfreqweeks_fu3]<>'' AND [CTF4_bionb_presfreq_fu3] LIKE 'q_%' THEN 'q' + ' ' + [CTF4_bionb_presfreqweeks_fu3] + ' '  + REPLACE([CTF4_bionb_presfreq_fu3], 'q_', '')
	    WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_bionb_presfreqweeks_fu3]<>'' AND [CTF4_bionb_presfreq_fu3] NOT LIKE 'q_%' THEN [CTF4_bionb_presfreqweeks_fu3]
		WHEN [CTF4_bionb_status_fu3]='Changes Prescribed' AND [CTF4_bionb_presfreqweeks_fu3]='' THEN [CTF4_bionb_presfreq_fu3]
	    ELSE ''
		END AS Frequency

	  ,'' AS stopDate
	  ,'' AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF4_bionb_name_fu3]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF4_bionb_status_fu3]='Changes Prescribed'
  
  
UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,[PatientId]
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,[Form Object Caption] AS crfName
      ,[Form Object Status] AS crfStatus
	  ,[CTF4_bionb_name_fu3] AS Treatment
	  ,CASE WHEN [CTF4_bionb_name_fu3] LIKE 'Other%' AND [CTF4_other_bionb_specify_fu3]<>'' THEN [CTF4_other_bionb_specify_fu3]
            WHEN [CTF4_bionb_name_fu3] LIKE 'Other%' AND [CTF4_biosim_oth_name3]<>'' THEN [CTF4_biosim_oth_name3]
			ELSE ''
			END AS otherTreatment
      ,[CTF4_bionb_status_fu3] AS TreatmentStatus
      ,[CTF4_rx_today_1stdose_rcvd_fu3] AS FirstDoseToday
	  ,'' AS firstUse
	  ,'' AS StartDate
	  ,'' AS startReasons
	  ,'' AS changeDate
	  ,'' AS changeReasons
	   ,'' AS Dose
	   ,'' AS Frequency

	  ,CASE WHEN [CTF4_bionb_status_fu3]='Stopped Today' AND [CTF4_rx_today_1stdose_rcvd_fu3]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS stopDate
	  ,CASE WHEN [CTF4_bionb_status_fu3]='Stopped Today' THEN 
	    STUFF(COALESCE(', '+NULLIF([CTF4_bionb_rsntoday1_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF4_bionb_rsntoday2_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([CTF4_bionb_rsntoday3_fu3__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS stopReasons

  FROM [OMNICOMM_PSO].[inbound].[CTF]
  WHERE [CTF4_bionb_name_fu3]<>''
  AND ([CTF_bio_nonbio_Today_fu]='Yes' OR [Form Object Status]='No Data')
  AND [Site Object SiteNo] NOT IN (997, 998, 999)
  AND [CTF4_bionb_status_fu3]='Stopped Today'
 
UNION 

SELECT VisitID,
       [Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF2_bio_name_fu AS Treatment, 
		CASE WHEN LEN(BIOF2_oth_bio_use_fu)=0 THEN BIOF2_biosim_oth_name
		ELSE BIOF2_oth_bio_use_fu
		END AS otherTreatment,
				
		'Unknown' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF2_bio_name_fu<>''
		AND (ISNULL([BIOF2_bio_chg_no change_fu], '')=''
		AND ISNULL([BIOF2_bio_chg_startdrug_fu], '')=''
		AND ISNULL([BIOF2_bio_chg_dosechange_fu], '')=''
		AND ISNULL([BIOF2_bio_chg_stopdrug_fu], '')='')

		
UNION

SELECT VisitID,
       [Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF3_bio_name_fu2 AS Treatment, 
		CASE WHEN LEN(BIOF3_oth_bio_use_fu2)=0 THEN BIOF3_biosim_oth_name2
		ELSE BIOF3_oth_bio_use_fu2
		END AS otherTreatment,
		
		'Unknown' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons
				
FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF3_bio_name_fu2<>''
		AND (ISNULL([BIOF3_bio_chg_no change_fu2], '')=''
		AND ISNULL([BIOF3_bio_chg_startdrug_fu2], '')=''
		AND ISNULL([BIOF3_bio_chg_dosechange_fu2], '')=''
		AND ISNULL([BIOF3_bio_chg_stopdrug_fu2], '')='')
				
UNION

SELECT VisitID,
       [Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		BIOF4_bio_name_fu3 AS Treatment, 
		CASE WHEN LEN(BIOF4_oth_bio_use_fu3)=0 THEN BIOF4_biosim_oth_name3
		ELSE BIOF4_oth_bio_use_fu3
		END AS otherTreatment,
		
		'Unknown' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,				
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons
				
FROM OMNICOMM_PSO.inbound.[BIOF]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND BIOF4_bio_name_fu3<>''
		AND (ISNULL([BIOF4_bio_chg_no change_fu3], '')=''
		AND ISNULL([BIOF4_bio_chg_startdrug_fu3], '')=''
		AND ISNULL([BIOF4_bio_chg_dosechange_fu3], '')=''
		AND ISNULL([BIOF4_bio_chg_stopdrug_fu3], '')='')

UNION

	SELECT NBF.VisitID,
        NBF.[Site Object SiteNo] AS SiteID,
		NBF.PatientId,
		NBF.[Patient Object PatientNo] AS SubjectID,
		NBF.[Visit Object Description] AS VisitType,
		NBF.[Visit Object VisitDate] AS VisitDate,
		'No Treatment at Follow Up' AS crfName, 
		NBF.[Form Object Status] AS crfStatus,
		'No Treatment' AS Treatment,
		'' AS otherTreatment,
		'' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate, 
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
		'' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons	

	FROM OMNICOMM_PSO.inbound.NBF NBF
	JOIN OMNICOMM_PSO.inbound.[BIOF] BIOF ON BIOF.VisitID=NBF.VisitID
	WHERE NBF.[NBF1_no_nonbio_fu]=1 AND BIOF.[BIOF_no_bio_sm_fu]=1
	AND NBF.[Site Object SiteNo] NOT IN (997, 998, 999)

UNION
		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF2_nbio_use_fu] AS Treatment, 
		[NBF2_oth_nbio_use_fu] AS otherTreatment, 
		'No changes'AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
		'' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF2_nbio_use_fu]<>''
		AND [NBF2_nbio_chg_no change_fu]=1

UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF2_nbio_use_fu] AS Treatment, 
		[NBF2_oth_nbio_use_fu] AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([NBF2_nbio_st_dt_fu], 1)='/' AND LEN([NBF2_nbio_st_dt_fu])=8 THEN LEFT([NBF2_nbio_st_dt_fu], 7) + '/01' 
		ELSE [NBF2_nbio_st_dt_fu] 
		END AS startDate,
		STUFF(COALESCE(', '+NULLIF(NBF2_nbio_rsn1_fu__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF2_nbio_rsn2_fu__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF2_nbio_rsn3_fu__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN [NBF2_nbio_dose_fu]='Other' AND [NBF2_other_nonbio_doseunits_fu]<>'' AND [NBF2_nbio_unit_fu]<>'Other' THEN [NBF2_other_nonbio_doseunits_fu] + ' ' + [NBF2_nbio_unit_fu]
		WHEN [NBF2_nbio_dose_fu]='Other' AND [NBF2_other_nonbio_doseunits_fu]<>'' AND [NBF2_nbio_unit_fu]='Other' THEN [NBF2_other_nonbio_doseunits_fu]
	    ELSE [NBF2_nbio_dose_fu] + ' ' + [NBF2_nbio_unit_fu]
	    END AS Dose,
		CASE WHEN NBF2_nbio_freqdays_weeks_fu<>'' AND NBF2_nbio_freq_fu<>'Other' THEN NBF2_nbio_freqdays_weeks_fu + ' '+  NBF2_nbio_freq_fu
		WHEN NBF2_nbio_freqdays_weeks_fu<>'' AND NBF2_nbio_freq_fu='Other' THEN NBF2_nbio_freqdays_weeks_fu
		ELSE NBF2_nbio_freq_fu
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF2_nbio_use_fu]<>''
		AND [NBF2_nbio_chg_startdrug_fu]=1
		
UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF2_nbio_use_fu] AS Treatment, 
		[NBF2_oth_nbio_use_fu] AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		[NBF2_nbio_st_dt_fu2] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(NBF2_nbio_rsn1_fu2__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF2_nbio_rsn2_fu2__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF2_nbio_rsn3_fu2__C, ''), '')
			, 1, 1, '') AS changeReasons,
		CASE WHEN [NBF2_nbio_dose_fu2]='Other' AND NBF2_nbio_unit_fu2<>'Other' AND [NBF2_other_nonbio_doseunits_fu2]<>'' THEN [NBF2_other_nonbio_doseunits_fu2] + ' ' + NBF2_nbio_unit_fu2
		WHEN [NBF2_nbio_dose_fu2]='Other' AND NBF2_nbio_unit_fu2='Other' AND [NBF2_other_nonbio_doseunits_fu2]<>'' THEN [NBF2_other_nonbio_doseunits_fu2]
		ELSE [NBF2_nbio_dose_fu2] + ' ' + [NBF2_nbio_unit_fu2]
	    END AS Dose,
		CASE WHEN NBF2_nbio_freqdays_weeks_fu2<>'' AND NBF2_nbio_freq_fu2='Other' THEN NBF2_nbio_freqdays_weeks_fu2
		WHEN NBF2_nbio_freqdays_weeks_fu2<>'' AND NBF2_nbio_freq_fu2<>'Other' THEN NBF2_nbio_freqdays_weeks_fu2 + ' '  + NBF2_nbio_freq_fu2
		ELSE NBF2_nbio_freq_fu2
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF2_nbio_use_fu]<>''
		AND [NBF2_nbio_chg_dosechange_fu]=1
		
UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF2_nbio_use_fu] AS Treatment, 
		[NBF2_oth_nbio_use_fu] AS otherTreatment, 
		'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
		'' AS Dose,
		'' AS Frequency,
		[NBF2_nbio_st_dt_fu3] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([NBF2_nbio_rsn1_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF2_nbio_rsn2_fu3__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF2_nbio_rsn3_fu3__C], ''), '')
			, 1, 1, '') AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF2_nbio_use_fu]<>''
		AND [NBF2_nbio_chg_stopdrug_fu]=1
				
	UNION

		SELECT VisitID, 
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF3_nbio_use_fu2] AS Treatment, 
		[NBF3_oth_nbio_use_fu2] AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
		'' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF3_nbio_use_fu2]<>''
		AND [NBF3_nbio_chg_no change_fu2]=1
		
UNION

		SELECT VisitID, 
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF3_nbio_use_fu2] AS Treatment, 
		[NBF3_oth_nbio_use_fu2] AS otherTreatment, 
		'Start drug'  AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([NBF3_nbio_st_dt_fu4], 1)='/' AND LEN([NBF3_nbio_st_dt_fu4])=8 THEN LEFT([NBF3_nbio_st_dt_fu4], 7) + '/01' 
		ELSE [NBF3_nbio_st_dt_fu4] 
		END AS startDate,

		STUFF(COALESCE(', '+NULLIF(NBF3_nbio_rsn1_fu4__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF3_nbio_rsn2_fu4__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF3_nbio_rsn3_fu4__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN [NBF3_nbio_dose_fu4]='Other' AND [NBF3_nbio_unit_fu4]<>'Other' AND [NBF3_other_nonbio_doseunits_fu4]<>'' THEN [NBF3_other_nonbio_doseunits_fu4] + ' ' + [NBF3_nbio_unit_fu4]
		WHEN [NBF3_nbio_dose_fu4]='Other' AND [NBF3_nbio_unit_fu4]='Other' AND [NBF3_other_nonbio_doseunits_fu4]<>'' THEN [NBF3_other_nonbio_doseunits_fu4]
	    ELSE [NBF3_nbio_dose_fu4] + ' ' + [NBF3_nbio_unit_fu4]
	    END AS Dose,
		CASE WHEN NBF3_nbio_freqdays_weeks_fu4<>'' AND NBF3_nbio_freq_fu4<>'Other' THEN NBF3_nbio_freqdays_weeks_fu4 + ' ' +  NBF3_nbio_freq_fu4
		WHEN NBF3_nbio_freqdays_weeks_fu4<>'' AND NBF3_nbio_freq_fu4='Other' THEN NBF3_nbio_freqdays_weeks_fu4
		ELSE NBF3_nbio_freq_fu4
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF3_nbio_use_fu2]<>''
		AND [NBF3_nbio_chg_startdrug_fu2]=1

UNION

		SELECT VisitID, 
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF3_nbio_use_fu2] AS Treatment, 
		[NBF3_oth_nbio_use_fu2] AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		[NBF3_nbio_st_dt_fu5] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(NBF3_nbio_rsn1_fu5__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF3_nbio_rsn2_fu5__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF3_nbio_rsn3_fu5__C, ''), '')
			, 1, 1, '') AS changeReasons,
		CASE WHEN [NBF3_nbio_dose_fu5]='Other' AND [NBF3_nbio_unit_fu5]<>'Other' AND [NBF3_other_nonbio_doseunits_fu5]<>'' THEN [NBF3_other_nonbio_doseunits_fu5] + ' ' + [NBF3_nbio_unit_fu5]
		WHEN [NBF3_nbio_dose_fu5]='Other' AND [NBF3_nbio_unit_fu5]='Other' AND [NBF3_other_nonbio_doseunits_fu5]<>'' THEN [NBF3_other_nonbio_doseunits_fu5]
	    ELSE [NBF3_nbio_dose_fu5] + ' ' + [NBF3_nbio_unit_fu5]
	    END AS Dose,
		CASE WHEN NBF3_nbio_freqdays_weeks_fu5<>'' AND NBF3_nbio_freq_fu5='Other' THEN NBF3_nbio_freqdays_weeks_fu5
		WHEN NBF3_nbio_freqdays_weeks_fu5<>'' AND NBF3_nbio_freq_fu5<>'Other' THEN NBF3_nbio_freqdays_weeks_fu5 + ' '  + NBF3_nbio_freq_fu5
		ELSE NBF3_nbio_freq_fu5
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF3_nbio_use_fu2]<>''
		AND [NBF3_nbio_chg_dosechange_fu2]=1
		
UNION

		SELECT VisitID, 
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF3_nbio_use_fu2] AS Treatment, 
		[NBF3_oth_nbio_use_fu2] AS otherTreatment, 
		'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
		'' AS Dose,
		'' AS Frequency,
		[NBF3_nbio_st_dt_fu6] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([NBF3_nbio_rsn1_fu6__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF3_nbio_rsn2_fu6__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF3_nbio_rsn3_fu6__C], ''), '')
			, 1, 1, '') AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF3_nbio_use_fu2]<>''
		AND [NBF3_nbio_chg_stopdrug_fu2]=1

	UNION

	   	SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF4_nbio_use_fu3] AS Treatment, 
		[NBF4_oth_nbio_use_fu3] AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' as Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF4_nbio_use_fu3]<>''
		AND [NBF4_nbio_chg_no change_fu3]=1
		

UNION

	   	SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF4_nbio_use_fu3] AS Treatment, 
		[NBF4_oth_nbio_use_fu3] AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([NBF4_nbio_st_dt_fu7], 1)='/' AND LEN([NBF4_nbio_st_dt_fu7])=8 THEN LEFT([NBF4_nbio_st_dt_fu7], 7) + '/01' 
		ELSE [NBF4_nbio_st_dt_fu7] 
		END AS startDate,
		STUFF(COALESCE(', '+NULLIF(NBF4_nbio_rsn1_fu7__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF4_nbio_rsn2_fu7__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF4_nbio_rsn3_fu7__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN [NBF4_nbio_dose_fu7]='Other' AND [NBF4_other_nonbio_doseunits_fu7]<>'' AND [NBF4_nbio_unit_fu7]<>'Other' THEN [NBF4_other_nonbio_doseunits_fu7] + ' ' + [NBF4_nbio_unit_fu7]
		WHEN [NBF4_nbio_dose_fu7]='Other' AND [NBF4_other_nonbio_doseunits_fu7]<>'' AND [NBF4_nbio_unit_fu7]='Other' THEN [NBF4_other_nonbio_doseunits_fu7]
	    ELSE [NBF4_nbio_dose_fu7] + ' ' + [NBF4_nbio_unit_fu7]
	    END AS Dose,
		CASE WHEN NBF4_nbio_freqdays_weeks_fu7<>'' AND NBF4_nbio_freq_fu7<>'Other' THEN NBF4_nbio_freqdays_weeks_fu7 + ' ' +  NBF4_nbio_freq_fu7
		WHEN NBF4_nbio_freqdays_weeks_fu7<>'' AND NBF4_nbio_freq_fu7='Other' THEN NBF4_nbio_freqdays_weeks_fu7
		ELSE NBF4_nbio_freq_fu7
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF4_nbio_use_fu3]<>''
		AND [NBF4_nbio_chg_startdrug_fu3]=1

UNION

	   	SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF4_nbio_use_fu3] AS Treatment, 
		[NBF4_oth_nbio_use_fu3] AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		[NBF4_nbio_st_dt_fu8] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(NBF4_nbio_rsn1_fu8__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF4_nbio_rsn2_fu8__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF4_nbio_rsn3_fu8__C, ''), '')
			, 1, 1, '') AS changeReasons,
	    CASE WHEN [NBF4_nbio_dose_fu8]<>'Other' AND [NBF4_nbio_unit_fu8]<>'Other' THEN [NBF4_nbio_dose_fu8] + ' ' + [NBF4_nbio_unit_fu8]
		WHEN [NBF4_nbio_dose_fu8]='Other' AND [NBF4_other_nonbio_doseunits_fu8]<>'' AND [NBF4_nbio_unit_fu8]<>'Other' THEN [NBF4_other_nonbio_doseunits_fu8] + ' ' + [NBF4_nbio_unit_fu8]
		WHEN [NBF4_nbio_dose_fu8]='Other' AND [NBF4_other_nonbio_doseunits_fu8]<>'' AND [NBF4_nbio_unit_fu8]='Other' THEN [NBF4_other_nonbio_doseunits_fu8]
	    ELSE [NBF4_nbio_dose_fu8] + ' ' + [NBF4_nbio_unit_fu8]
	    END AS Dose,
		CASE WHEN NBF4_nbio_freqdays_weeks_fu8<>'' AND NBF4_nbio_freq_fu8='Other' THEN NBF4_nbio_freqdays_weeks_fu8
		WHEN NBF4_nbio_freqdays_weeks_fu8<>'' AND NBF4_nbio_freq_fu8<>'Other' THEN NBF4_nbio_freqdays_weeks_fu8 + ' '  + NBF4_nbio_freq_fu8
		ELSE NBF4_nbio_freq_fu8
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF4_nbio_use_fu3]<>''
		AND [NBF4_nbio_chg_dosechange_fu3]=1

UNION

	   	SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF4_nbio_use_fu3] AS Treatment, 
		[NBF4_oth_nbio_use_fu3] AS otherTreatment, 
		'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		[NBF4_nbio_st_dt_fu9] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([NBF4_nbio_rsn1_fu9__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF4_nbio_rsn2_fu9__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF4_nbio_rsn3_fu9__C], ''), '')
			, 1, 1, '') AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF4_nbio_use_fu3]<>''
		AND [NBF4_nbio_chg_stopdrug_fu3]=1

	UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF5_nbio_use_fu4] AS Treatment, 
		[NBF5_oth_nbio_use_fu4] AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF5_nbio_use_fu4]<>''
		AND [NBF5_nbio_chg_no change_fu4]=1
		
UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF5_nbio_use_fu4] AS Treatment, 
		[NBF5_oth_nbio_use_fu4] AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([NBF5_nbio_st_dt_fu10], 1)='/' AND LEN([NBF5_nbio_st_dt_fu10])=8 THEN LEFT([NBF5_nbio_st_dt_fu10], 7) + '/01' 
		ELSE [NBF5_nbio_st_dt_fu10]
		END AS startDate,
	
		STUFF(COALESCE(', '+NULLIF(NBF5_nbio_rsn1_fu10__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF5_nbio_rsn2_fu10__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF5_nbio_rsn3_fu10__C, ''), '')
			, 1, 1, '') AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN [NBF5_nbio_dose_fu10]='Other' AND [NBF5_other_nonbio_doseunits_fu10]<>'' AND [NBF5_nbio_unit_fu10]<>'Other' THEN [NBF5_other_nonbio_doseunits_fu10] + ' ' + [NBF5_nbio_unit_fu10]
		WHEN [NBF5_nbio_dose_fu10]='Other' AND [NBF5_other_nonbio_doseunits_fu10]<>'' AND [NBF5_nbio_unit_fu10]='Other' THEN [NBF5_other_nonbio_doseunits_fu10]
	    ELSE [NBF5_nbio_dose_fu10] + ' ' + [NBF5_nbio_unit_fu10]
	    END AS Dose,
		CASE WHEN NBF5_nbio_freqdays_weeks_fu10<>'' AND NBF5_nbio_freq_fu10<>'Other' THEN NBF5_nbio_freqdays_weeks_fu10 + ' ' +  NBF5_nbio_freq_fu10
		WHEN NBF5_nbio_freqdays_weeks_fu10<>'' AND NBF5_nbio_freq_fu10='Other' THEN NBF5_nbio_freqdays_weeks_fu10
		ELSE NBF5_nbio_freq_fu10
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF5_nbio_use_fu4]<>''
		AND [NBF5_nbio_chg_no change_fu4]=1	
		AND [NBF5_nbio_chg_startdrug_fu4]=1
		
UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF5_nbio_use_fu4] AS Treatment, 
		[NBF5_oth_nbio_use_fu4] AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		[NBF5_nbio_st_dt_fu11] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(NBF5_nbio_rsn1_fu11__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF5_nbio_rsn2_fu11__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF5_nbio_rsn3_fu11__C, ''), '')
			, 1, 1, '') AS changeReasons,
	    CASE WHEN [NBF5_nbio_dose_fu11]<>'Other' AND [NBF5_nbio_unit_fu11]<>'Other' THEN [NBF5_nbio_dose_fu11] + ' ' + [NBF5_nbio_unit_fu11]
		WHEN [NBF5_nbio_dose_fu11]='Other' AND [NBF5_other_nonbio_doseunits_fu11]<>'' AND [NBF5_nbio_unit_fu11]<>'Other' THEN [NBF5_other_nonbio_doseunits_fu11] + ' ' + [NBF5_nbio_unit_fu11]
		WHEN [NBF5_nbio_dose_fu11]='Other' AND [NBF5_other_nonbio_doseunits_fu11]<>'' AND [NBF5_nbio_unit_fu11]='Other' THEN [NBF5_other_nonbio_doseunits_fu11]
	    ELSE [NBF5_nbio_dose_fu11] + ' ' + [NBF5_nbio_unit_fu11]
	    END AS Dose,
		CASE WHEN NBF5_nbio_freqdays_weeks_fu11<>'' AND NBF5_nbio_freq_fu11='Other' THEN NBF5_nbio_freqdays_weeks_fu11
		WHEN NBF5_nbio_freqdays_weeks_fu11<>'' AND NBF5_nbio_freq_fu11<>'Other' THEN NBF5_nbio_freqdays_weeks_fu11 + ' '  + NBF5_nbio_freq_fu11
		ELSE NBF5_nbio_freq_fu11
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF5_nbio_use_fu4]<>''
		AND [NBF5_nbio_chg_dosechange_fu4]=1

UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF5_nbio_use_fu4] AS Treatment, 
		[NBF5_oth_nbio_use_fu4] AS otherTreatment, 
		'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		[NBF5_nbio_st_dt_fu12] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([NBF5_nbio_rsn1_fu12__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF5_nbio_rsn2_fu12__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF5_nbio_rsn3_fu12__C], ''), '')
			, 1, 1, '') AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF5_nbio_use_fu4]<>''
		AND [NBF5_nbio_chg_stopdrug_fu4]=1

	UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF6_nbio_use_fu5] AS Treatment, 
		[NBF6_oth_nbio_use_fu5] AS otherTreatment, 
		'No changes' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF6_nbio_use_fu5]<>''
		AND [NBF6_nbio_chg_no change_fu5]=1
		
UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF6_nbio_use_fu5] AS Treatment, 
		[NBF6_oth_nbio_use_fu5] AS otherTreatment, 
		'Start drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		CASE WHEN RIGHT([NBF6_nbio_st_dt_fu13], 1)='/' AND LEN([NBF6_nbio_st_dt_fu13])=8 THEN LEFT([NBF6_nbio_st_dt_fu13], 7) + '/01' 
		ELSE [NBF6_nbio_st_dt_fu13] 
		END AS startDate,

		STUFF(COALESCE(', '+NULLIF(NBF6_nbio_rsn1_fu13__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF6_nbio_rsn2_fu13__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF6_nbio_rsn3_fu13__C, ''), '')
			, 1, 1, '') AS startReasons,

		'' changeDate,
		'' AS changeReasons,
	    CASE WHEN [NBF6_nbio_dose_fu13]='Other' AND [NBF6_other_nonbio_doseunits_fu13]<>'' AND [NBF6_nbio_unit_fu13]<>'Other' THEN [NBF6_other_nonbio_doseunits_fu13] + ' ' + [NBF6_nbio_unit_fu13]
		WHEN [NBF6_nbio_dose_fu13]='Other' AND [NBF6_other_nonbio_doseunits_fu13]<>'' AND [NBF6_nbio_unit_fu13]='Other' THEN [NBF6_other_nonbio_doseunits_fu13]
	    ELSE [NBF6_nbio_dose_fu13] + ' ' + [NBF6_nbio_unit_fu13]
	    END AS Dose,
		CASE WHEN NBF6_nbio_freqdays_weeks_fu13<>'' AND NBF6_nbio_freq_fu13<>'Other' THEN NBF6_nbio_freqdays_weeks_fu13 + ' ' +  NBF6_nbio_freq_fu13
		WHEN NBF6_nbio_freqdays_weeks_fu13<>'' AND NBF6_nbio_freq_fu13='Other' THEN NBF6_nbio_freqdays_weeks_fu13
		ELSE NBF6_nbio_freq_fu13
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF6_nbio_use_fu5]<>''
		AND [NBF6_nbio_chg_startdrug_fu5]=1

UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF6_nbio_use_fu5] AS Treatment, 
		[NBF6_oth_nbio_use_fu5] AS otherTreatment, 
		'Change dose' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		[NBF6_nbio_st_dt_fu14] AS changeDate,
		STUFF(COALESCE(', '+NULLIF(NBF6_nbio_rsn1_fu14__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF6_nbio_rsn2_fu14__C, ''), '')
			+ COALESCE(', '+NULLIF(NBF6_nbio_rsn3_fu14__C, ''), '')
			, 1, 1, '') AS changeReasons,
	    CASE WHEN [NBF6_nbio_dose_fu14]<>'Other' AND [NBF6_nbio_unit_fu14]<>'Other' THEN [NBF6_nbio_dose_fu14] + ' ' + [NBF6_nbio_unit_fu14]
		WHEN [NBF6_nbio_dose_fu14]='Other' AND [NBF6_other_nonbio_doseunits_fu14]<>'' AND [NBF6_nbio_unit_fu14]<>'Other' THEN [NBF6_other_nonbio_doseunits_fu14] + ' ' + [NBF6_nbio_unit_fu14]
		WHEN [NBF6_nbio_dose_fu14]='Other' AND [NBF6_other_nonbio_doseunits_fu14]<>'' AND [NBF6_nbio_unit_fu14]='Other' THEN [NBF6_other_nonbio_doseunits_fu14]
	    ELSE [NBF6_nbio_dose_fu14] + ' ' + [NBF6_nbio_unit_fu14]
	    END AS Dose,
		CASE WHEN NBF6_nbio_freqdays_weeks_fu14<>'' AND NBF6_nbio_freq_fu14='Other' THEN NBF6_nbio_freqdays_weeks_fu14
		WHEN NBF6_nbio_freqdays_weeks_fu14<>'' AND NBF6_nbio_freq_fu14<>'Other' THEN NBF6_nbio_freqdays_weeks_fu14 + ' '  + NBF6_nbio_freq_fu14
		ELSE NBF6_nbio_freq_fu14
	    END AS Frequency,
		'' AS stopDate,
		'' AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF6_nbio_use_fu5]<>''
		AND [NBF6_nbio_chg_dosechange_fu5]=1

UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		REPLACE([Form Object Caption], '_Page 1', '') AS crfName,
		[Form Object Status] AS crfStatus,
		[NBF6_nbio_use_fu5] AS Treatment, 
		[NBF6_oth_nbio_use_fu5] AS otherTreatment, 
		'Stop drug' AS TreatmentStatus,
		'' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,	
		'' AS startReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    '' AS Dose,
		'' AS Frequency,
		[NBF6_nbio_st_dt_fu15] AS stopDate,
		STUFF(COALESCE(', '+NULLIF([NBF6_nbio_rsn1_fu15__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF6_nbio_rsn2_fu15__C], ''), '')
			+ COALESCE(', '+NULLIF([NBF6_nbio_rsn3_fu15__C], ''), '')
			, 1, 1, '') AS stopReasons

		FROM OMNICOMM_PSO.[inbound].[NBF]
		WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
		AND [NBF6_nbio_use_fu5]<>''
		AND [NBF6_nbio_chg_stopdrug_fu5]=1




--ORDER BY SiteID, SubjectID, VisitDate, Treatment, otherTreatment



GO
