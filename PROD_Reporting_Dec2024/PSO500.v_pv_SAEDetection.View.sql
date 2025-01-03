USE [Reporting]
GO
/****** Object:  View [PSO500].[v_pv_SAEDetection]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [PSO500].[v_pv_SAEDetection] AS
SELECT 
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(ANA1.VisitId AS int) AS [VisitID],
	CAST([ANA1_TAE_md_cod] AS int) AS [ProviderID],
	'Severe Reaction TAE (ANA)' AS [EventType],
	[ANA2_ana_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[ANA6_ae_outcome] AS [Outcome],
	CASE WHEN ANA1.[ANA6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[ANA1_report_type] AS [Confirmed],
	[ANA1_report_noevent_exp] AS [NoEventSpecify],
	[ANA5B_ae_source_docs] AS [SDocStatus],
	[ANA4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	ANA1.[Form Object Status] AS [Page1Status],
	ANA2.[Form Object Status] AS [Page2Status],
	ANA1.[Form Object LastChange] AS [Page1LastModDate],
	ANA2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[ANA1] ON ANA1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[ANA2] ON ANA2.[VisitId] = ANA1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = ANA1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = ANA1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = ANA1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(CM1.VisitId AS int) AS [VisitID],
	CAST([CM1_TAE_md_cod] AS int) AS [ProviderID],
	'Cancer or Malignancy TAE (CM)' AS [EventType],
	[CM2_cm_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[CM6_ae_outcome] AS [Outcome],
	CASE WHEN CM1.[CM6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[CM1_report_type] AS [Confirmed],
	[CM1_report_noevent_exp] AS [NoEventSpecify],
	[CM5B_ae_source_docs] AS [SDocStatus],
	[CM4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	CM1.[Form Object Status] AS [Page1Status],
	CM2.[Form Object Status] AS [Page2Status],
	CM1.[Form Object LastChange] AS [Page1LastModDate],
	CM2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CM1] ON CM1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CM2] ON CM2.[VisitId] = CM1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = CM1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = CM1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = CM1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(CVD1.VisitId AS int) AS [VisitID],
	CAST([CVD1_TAE_md_cod] AS int)AS [ProviderID],
	'Cardiovascular TAE (CVD)' AS [EventType],
	[CVD2_cvd_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[CVD6_ae_outcome] AS [Outcome],
	CASE WHEN CVD1.[CVD6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[CVD1_report_type] AS [Confirmed],
	[CVD1_report_noevent_exp] AS [NoEventSpecify],
	[CVD5B_ae_source_docs] AS [SDocStatus],
	[CVD4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	CVD1.[Form Object Status] AS [Page1Status],
	CVD2.[Form Object Status] AS [Page2Status],
	CVD1.[Form Object LastChange] AS [Page1LastModDate],
	CVD2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CVD1] ON CVD1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CVD2] ON CVD2.[VisitId] = CVD1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = CVD1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = CVD1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = CVD1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(INF1.VisitId AS int) AS [VisitID],
	CAST([INF1_TAE_md_cod] AS int) AS [ProviderID],
	'Serious Infection TAE (INF)' AS [EventType],
	[INF2_inf_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[INF6_ae_outcome] AS [Outcome],
	CASE WHEN INF1.[INF6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[INF1_report_type] AS [Confirmed],
	[INF1_report_noevent_exp] AS [NoEventSpecify],
	[INF5B_ae_source_docs] AS [SDocStatus],
	[INF4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	INF1.[Form Object Status] AS [Page1Status],
	INF2.[Form Object Status] AS [Page2Status],
	INF1.[Form Object LastChange] AS [Page1LastModDate],
	INF2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[INF1] ON INF1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[INF2] ON INF2.[VisitId] = INF1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = INF1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = INF1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = INF1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(GI1.VisitId AS int) AS [VisitID],
	CAST([GI1_TAE_md_cod] AS int) AS [ProviderID],
	'Perforation TAE (GI)' AS [EventType],
	[GI2_gi_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[GI6_ae_outcome] AS [Outcome],
	CASE WHEN GI1.[GI6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[GI1_report_type] AS [Confirmed],
	[GI1_report_noevent_exp] AS [NoEventSpecify],
	[GI5B_ae_source_docs] AS [SDocStatus],
	[GI4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	GI1.[Form Object Status] AS [Page1Status],
	GI2.[Form Object Status] AS [Page2Status],
	GI1.[Form Object LastChange] AS [Page1LastModDate],
	GI2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[GI1] ON GI1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[GI2] ON GI2.[VisitId] = GI1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = GI1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = GI1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = GI1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(HEP1.VisitId AS int) AS [VisitID],
	CAST([HEP1_TAE_md_cod] AS int) AS [ProviderID],
	'Hepatic TAE (HEP)' AS [EventType],
	[HEP2_hep_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[HEP6_ae_outcome] AS [Outcome],
	CASE WHEN HEP1.[HEP6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[HEP1_report_type] AS [Confirmed],
	[HEP1_report_noevent_exp] AS [NoEventSpecify],
	[HEP5B_ae_source_docs] AS [SDocStatus],
	[HEP4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	HEP1.[Form Object Status] AS [Page1Status],
	HEP2.[Form Object Status] AS [Page2Status],
	HEP1.[Form Object LastChange] AS [Page1LastModDate],
	HEP2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[HEP1] ON HEP1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[HEP2] ON HEP2.[VisitId] = HEP1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = HEP1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = HEP1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = HEP1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(NEU1.VisitId AS int) AS [VisitID],
	CAST([NEU1_TAE_md_cod] AS int) AS [ProviderID],
	'Neurologic TAE (NEU)' AS [EventType],
	[NEU2_neu_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[NEU6_ae_outcome] AS [Outcome],
	CASE WHEN NEU1.[NEU6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[NEU1_report_type] AS [Confirmed],
	[NEU1_report_noevent_exp] AS [NoEventSpecify],
	[NEU5B_ae_source_docs] AS [SDocStatus],
	[NEU4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	NEU1.[Form Object Status] AS [Page1Status],
	NEU2.[Form Object Status] AS [Page2Status],
	NEU1.[Form Object LastChange] AS [Page1LastModDate],
	NEU2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[NEU1] ON NEU1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[NEU2] ON NEU2.[VisitId] = NEU1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = NEU1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = NEU1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = NEU1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(SSB1.VisitId AS int) AS [VisitID],
	CAST([SSB1_TAE_md_cod] AS int) AS [ProviderID],
	'Serious Spontaneous Bleed TAE (SSB)' AS [EventType],
	[SSB2_ssb_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[SSB6_ae_outcome] AS [Outcome],
	CASE WHEN SSB1.[SSB6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[SSB1_report_type] AS [Confirmed],
	[SSB1_report_noevent_exp] AS [NoEventSpecify],
	[SSB5B_ae_source_docs] AS [SDocStatus],
	[SSB4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	SSB1.[Form Object Status] AS [Page1Status],
	SSB2.[Form Object Status] AS [Page2Status],
	SSB1.[Form Object LastChange] AS [Page1LastModDate],
	SSB2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[SSB1] ON SSB1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[SSB2] ON SSB2.[VisitId] = SSB1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = SSB1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = SSB1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = SSB1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(IBD1.VisitId AS int) AS [VisitID],
	CAST([IBD1_TAE_md_cod] AS int) AS [ProviderID],
	'Inflammatory Bowel Disease TAE (IBD)' AS [EventType],
	[IBD2_ibd_flag_event] AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[IBD6_ae_ibd_outcome] AS [Outcome],
	CASE WHEN IBD1.[IBD6_ae_ibd_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[IBD1_report_type] AS [Confirmed],
	[IBD1_report_noevent_exp] AS [NoEventSpecify],
	[IBD5B_ae_source_docs] AS [SDocStatus],
	[IBD4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	IBD1.[Form Object Status] AS [Page1Status],
	IBD2.[Form Object Status] AS [Page2Status],
	IBD1.[Form Object LastChange] AS [Page1LastModDate],
	IBD2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[IBD1] ON IBD1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[IBD2] ON IBD2.[VisitId] = IBD1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = IBD1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = IBD1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = IBD1.VisitId
UNION
SELECT
	
	SIT.[Site Number] AS [SiteNumber],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	CAST(GEN1.VisitId AS int) AS [VisitID],
	CAST([GEN1_TAE_md_cod] AS int) AS [ProviderID],
	'General Serious TAE (GEN)' AS [EventType],
	'' AS [EventTerm],
	CASE WHEN CF1_2.[CF2_comor] LIKE '%other%' THEN CF1_2.[CF2_comor_other] ELSE '' END AS [EventSpecify],
	CF1_2.[CF2_onset_md_yr] AS MDEventOnset,
	CF1_2.[Visit Object VisitDate] AS [VisitDate],
	[GEN6_ae_outcome] AS [Outcome],
	CASE WHEN GEN1.[GEN6_ae_outcome] = 'Death' THEN 'YES' ELSE 'NO' END AS [Death],
	[GEN1_report_type] AS [Confirmed],
	[GEN1_report_noevent_exp] AS [NoEventSpecify],
	[GEN5B_ae_source_docs] AS [SDocStatus],
	[GEN4B_ser_outcome_hosp] AS [Hospitalized],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_name_fu] ELSE '' END AS [ChangeToday],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_status_fu] ELSE '' END AS [ChangeTodayPlan],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presfreq_fu] ELSE '' END AS [ChangeTodayFreq],
	CASE WHEN CTF.[CTF2_bionb_name_fu] <> '' THEN CTF.[CTF2_bionb_presdose_fu] ELSE '' END AS [ChangeTodayDose],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_name_fu2] ELSE '' END AS [ChangeToday2],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_status_fu2] ELSE '' END AS [ChangeToday2Plan],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presfreq_fu2] ELSE '' END AS [ChangeToday2Freq],
	CASE WHEN CTF.[CTF3_bionb_name_fu2] <> '' THEN CTF.[CTF3_bionb_presdose_fu2] ELSE '' END AS [ChangeToday2Dose],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_name_fu3] ELSE '' END AS [ChangeToday3],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_status_fu3] ELSE '' END AS [ChangeToday3Plan],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presfreq_fu3] ELSE '' END AS [ChangeToday3Freq],
	CASE WHEN CTF.[CTF4_bionb_name_fu3] <> '' THEN CTF.[CTF4_bionb_presdose_fu3] ELSE '' END AS [ChangeToday3Dose],
	PrevBio.bio_name AS [Bio],
	PrevBio.startdate AS [BioStartDate],
	PrevBio.dose AS [BioDose],
	PrevBio.freq AS [BioFreq],
	GEN1.[Form Object Status] AS [Page1Status],
	GEN2.[Form Object Status] AS [Page2Status],
	GEN1.[Form Object LastChange] AS [Page1LastModDate],
	GEN2.[Form Object LastChange] AS [Page2LastModDate]
FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[G_Site Information] SIT 
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[GEN1] ON GEN1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[GEN2] ON GEN2.[VisitId] = GEN1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CF_CF2] CF1_2 ON CF1_2.[VisitId] = GEN1.[VisitId]
	LEFT JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[CTF] ON CTF.VisitId = GEN1.VisitId
	LEFT JOIN
	(
		SELECT startdate, bio_name, dose, freq, VisitId FROM
		(
			SELECT BIOF2_bio_name_fu AS bio_name, BIOF2_bio_dose_fu as dose, BIOF2_bio_freq_fu as freq, BIOF2_bio_st_dt_fu AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF3_bio_name_fu2 AS bio_name, BIOF3_bio_dose_fu4 as dose, BIOF3_bio_freq_fu4 as freq, BIOF3_bio_st_dt_fu4 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			UNION
			SELECT BIOF4_bio_name_fu3 AS bio_name, BIOF4_bio_dose_fu7 as dose, BIOF4_bio_freq_fu7 as freq, BIOF4_bio_st_dt_fu7 AS startdate, VisitId FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].BIOF
			) AS BIOFP
		WHERE bio_name <> ''
	) AS PrevBio ON PrevBio.VisitId = GEN1.VisitId


GO
