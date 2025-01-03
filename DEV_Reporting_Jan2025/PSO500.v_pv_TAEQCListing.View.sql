USE [Reporting]
GO
/****** Object:  View [PSO500].[v_pv_TAEQCListing]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [PSO500].[v_pv_TAEQCListing] AS


WITH PTINFO AS
(
SELECT
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	DM.PatientId,
	DM.[DM1_gender] AS [Gender],
	DM.[DM1_birthdate] AS [YearOfBirth],
	(CASE WHEN DM.[DM2_race_other] = '1' THEN 'Other: '+ ISNULL(DM.[DM2_race_other_spec] + ', ', '') ELSE '' END
				   + 
	CASE WHEN DM.[DM2_race_white] = '1' THEN 'White, ' ELSE '' END
				   +
	CASE WHEN DM.[DM2_race_black] = '1' THEN 'Black/African American, ' ELSE '' END
				   +
	CASE WHEN DM.[DM2_race_pacific] = '1' THEN 'Native Hawaiian or Pacific Islander, ' ELSE '' END
				   +
	CASE WHEN DM.[DM2_race_asian] = '1' THEN 'Asian, ' ELSE '' END
				   +
	CASE WHEN DM.[DM2_race_native_am] = '1' THEN 'American Indian or Alaska Native' ELSE '' END) AS [Race],
	DM.[DM3_race_hispanic] AS [Ethnicity]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
INNER JOIN [OMNICOMM_PSO].[inbound].[DM] DM ON DM.PatientId = PAT.PatientId

--WHERE PAT.[Caption]=45712540263
) 

,BIO1 AS
(
	SELECT [BIOF2_bio_name_fu] AS [Bio1], 
	[BIOF2_bio_dose_fu] AS [Bio1Dose], [BIOF2_bio_freq_fu] AS [Bio1Freq], [BIOF2_bio_st_dt_fu] AS [Bio1StartDate], [VisitId]
	FROM [OMNICOMM_PSO].[inbound].BIOF
	WHERE BIOF2_bio_name_fu <> ''	
)

,BIO2 AS
(
	SELECT [BIOF3_bio_name_fu2] AS [Bio2], 
	[BIOF3_bio_dose_fu4] AS [Bio2Dose], 
	[BIOF3_bio_freq_fu4] AS [Bio2Freq], 
	[BIOF3_bio_st_dt_fu4] AS [Bio2StartDate], 
	[VisitID]
	FROM [OMNICOMM_PSO].[inbound].BIOF
	WHERE BIOF3_bio_name_fu2 <> ''	
)

,BIO3 AS
(
	SELECT [BIOF4_bio_name_fu3] AS [Bio3], [BIOF4_bio_dose_fu7] AS [Bio3Dose], [BIOF4_bio_freq_fu7] AS [Bio3Freq], [BIOF4_bio_st_dt_fu7] AS [Bio3StartDate], [VisitID]
	FROM [OMNICOMM_PSO].[inbound].BIOF
	WHERE BIOF4_bio_name_fu3 <> ''	
)

,CTF1 AS
(
	SELECT 
	[CTF2_bionb_name_fu] AS [ChangeToday1], [CTF2_bionb_status_fu] AS [ChangeToday1Plan], 
	[CTF2_bionb_presdose_fu] AS [ChangeToday1Dose], [CTF2_bionb_presfreq_fu] AS [ChangeToday1Freq],
	[Visit Object VisitDate] AS [VisitDate], [VisitID]
	FROM [OMNICOMM_PSO].[inbound].CTF
	WHERE [CTF2_bionb_name_fu] <> ''
)

,CTF2 AS
(	
	SELECT 
	[CTF3_bionb_name_fu2] AS [ChangeToday2], [CTF3_bionb_status_fu2] AS [ChangeToday2Plan],
	[CTF3_bionb_presdose_fu2] AS [ChangeToday2Dose], [CTF3_bionb_presfreq_fu2] AS [ChangeToday2Freq],
	[Visit Object VisitDate] AS [VisitDate], [VisitID]
	FROM [OMNICOMM_PSO].[inbound].CTF
	WHERE [CTF3_bionb_name_fu2] <> ''
)

,CTF3 AS
(
	SELECT 
	[CTF4_bionb_name_fu3] AS [ChangeToday3], [CTF4_bionb_status_fu3] AS [ChangeToday3Plan],
	 [CTF4_bionb_presdose_fu3] AS [ChangeToday3Dose], [CTF4_bionb_presfreq_fu3] AS [ChangeToday3Freq],
	[Visit Object VisitDate] AS [VisitDate], [VisitID]
	FROM [OMNICOMM_PSO].[inbound].CTF
	WHERE [CTF4_bionb_name_fu3] <> ''
)

,AES AS
(
SELECT DISTINCT
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(ANA1.VisitId AS int) AS [VisitID],
	CAST([ANA1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(ANA1.[Form Object Caption],9,(LEN(ANA1.[Form Object Caption]))) AS [FormCaption],
	'Severe Reaction TAE (ANA)' AS [EventType],
	[ANA2_ana_flag_event] AS [EventTerm],
	'' AS [EventSpecify],
	[ANA2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[ANA6_ae_outcome] AS [Outcome],
	CASE WHEN ANA1.[ANA6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[ANA4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[ANA1_report_type] AS [ReportType],
	[ANA1_report_Noevent_exp] AS [NoEventExplanation],
	[ANA5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN ANA5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN ANA5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[ANA4B_ser_outcome_hosp] AS [Hospitalized],
	[ANA1_documents_received] AS [DocsReceivedByCorrona],
	[ANA5B_ae_nosource_rsn] AS [ReasonNoSource],
	[ANA5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[ANA5B_reason_nosourceother] AS [ReasonNoSourceOther],
	ANA1.[Form Object Status] AS [Page1Status],
	ANA2.[Form Object Status] AS [Page2Status],
	ANA1.[Form Object LastChange] AS [Page1LastModDate],
	ANA2.[Form Object LastChange] AS [Page2LastModDate],
	ANA1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[ANA1] ON ANA1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[ANA2] ON ANA2.[VisitId] = ANA1.[VisitId] AND ANA2.[PatientId] =ANA1.[PatientID] 
    AND ANA1.[ANA2_ana_flag_event] = ANA2.[TAEHD_AETERM] AND ANA1.[ANA2_lm_ae_dt_event] = ANA2.[TAEHD_AESTDAT]
	AND ANA1.[Form Object InstanceNo] = ANA2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = ANA1.VisitId

--SELECT * FROM [OMNICOMM_PSO].[inbound].[ANA2] ORDER BY [Site Object SiteNo], [Patient Object Caption], [Form Object Description], [Visit Object InstanceNo]
UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(CM1.VisitId AS int) AS [VisitID],
	CAST([CM1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(CM1.[Form Object Caption],9,(LEN(CM1.[Form Object Caption]))) AS [FormCaption],
	'Cancer or Malignancy TAE (CM)' AS [EventType],
	[CM2_cm_flag_event] AS [EventTerm],
	[CM2_cm_event_specify] AS [EventSpecify],
	[CM2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[CM6_ae_outcome] AS [Outcome],
	CASE WHEN CM1.[CM6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[CM4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[CM1_report_type] AS [ReportType],
	[CM1_report_Noevent_exp] AS [NoEventExplanation],
	[CM5B_ae_source_docs] AS [SDocStatus],
    CASE WHEN CM5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN CM5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[CM4B_ser_outcome_hosp] AS [Hospitalized],
	[CM1_documents_received] AS [DocsReceivedByCorrona],
	[CM5B_ae_nosource_rsn] AS [ReasonNoSource],
	[CM5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[CM5B_reason_nosourceother] AS [ReasonNoSourceOther],
	CM1.[Form Object Status] AS [Page1Status],
	CM2.[Form Object Status] AS [Page2Status],
	CM1.[Form Object LastChange] AS [Page1LastModDate],
	CM2.[Form Object LastChange] AS [Page2LastModDate],
	CM1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[CM1] ON CM1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CM2] CM2 ON CM2.[VisitId] = CM1.[VisitId] AND CM2.[PatientId] =CM1.[PatientID] 
    AND CM1.[CM2_cm_flag_event] = CM2.[TAEHD_AETERM] AND CM1.[CM2_lm_ae_dt_event] = CM2.[TAEHD_AESTDAT]
	AND CM1.[Form Object InstanceNo] = CM2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = CM1.VisitId



UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(CVD1.VisitId AS int) AS [VisitID],
	CAST([CVD1_TAE_md_cod] AS int)AS [ProviderID],
	SUBSTRING(CVD1.[Form Object Caption],9,(LEN(CVD1.[Form Object Caption]))) AS [FormCaption],
	'Cardiovascular TAE (CVD)' AS [EventType],
	[CVD2_cvd_flag_event] AS [EventTerm],
	[CVD2_cvd_event_specify] AS [EventSpecify],
	[CVD2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[CVD6_ae_outcome] AS [Outcome],
	CASE WHEN CVD1.[CVD6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[CVD4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[CVD1_report_type] AS [ReportType],
	[CVD1_report_Noevent_exp] AS [NoEventExplanation],
	[CVD5B_ae_source_docs] AS [SDocStatus],
    CASE WHEN CVD5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN CVD5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[CVD4B_ser_outcome_hosp] AS [Hospitalized],
	[CVD1_documents_received] AS [DocsReceivedByCorrona],
	[CVD5B_ae_nosource_rsn] AS [ReasonNoSource],
	[CVD5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[CVD5B_reason_nosourceother] AS [ReasonNoSourceOther],
	CVD1.[Form Object Status] AS [Page1Status],
	CVD2.[Form Object Status] AS [Page2Status],
	CVD1.[Form Object LastChange] AS [Page1LastModDate],
	CVD2.[Form Object LastChange] AS [Page2LastModDate],
	CVD1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[CVD1] ON CVD1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CVD2] ON CVD2.[VisitId] = CVD1.[VisitId] AND CVD2.[PatientId] =CVD1.[PatientID] 
	AND CVD1.[CVD2_cvd_flag_event] = CVD2.[TAEHD_AETERM] AND CVD1.[CVD2_lm_ae_dt_event] = CVD2.[TAEHD_AESTDAT]
	AND CVD1.[Form Object InstanceNo] = CVD2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = CVD1.VisitId
--WHERE PAT.[Caption]='45712540263'


UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(INF1.VisitId AS int) AS [VisitID],
	CAST([INF1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(INF1.[Form Object Caption],9,(LEN(INF1.[Form Object Caption]))) AS [FormCaption],
	'Serious Infection TAE (INF)' AS [EventType],
	[INF2_inf_flag_event] AS [EventTerm],
	[INF2_inf_event_specify] AS [EventSpecify],
	[INF2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[INF6_ae_outcome] AS [Outcome],
	CASE WHEN INF1.[INF6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[INF4A_serious_outcome] AS [SeriousOutcome],
	[INF10_INF_lm_ae_iv_abx] AS [IVAntibioticsTAEINF],
	[INF1_report_type] AS [ReportType],
	[INF1_report_Noevent_exp] AS [NoEventExplanation],
	[INF5B_ae_source_docs] AS [SDocStatus],
    CASE WHEN INF5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN INF5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[INF4B_ser_outcome_hosp] AS [Hospitalized],
	[INF1_documents_received] AS [DocsReceivedByCorrona],
	[INF5B_ae_nosource_rsn] AS [ReasonNoSource],
	[INF5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[INF5B_reason_nosourceother] AS [ReasonNoSourceOther],
	INF1.[Form Object Status] AS [Page1Status],
	INF2.[Form Object Status] AS [Page2Status],
	INF1.[Form Object LastChange] AS [Page1LastModDate],
	INF2.[Form Object LastChange] AS [Page2LastModDate],
	INF1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[INF1] ON INF1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[INF2] ON INF2.[VisitId] = INF1.[VisitId] AND INF2.[PatientId] =INF1.[PatientID] 
    AND INF1.[INF2_inf_flag_event] = INF2.[TAEHD_AETERM] AND INF1.[INF2_lm_ae_dt_event] = INF2.[TAEHD_AESTDAT]
	AND INF1.[Form Object InstanceNo] = INF2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = INF1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(GI1.VisitId AS int) AS [VisitID],
	CAST([GI1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(GI1.[Form Object Caption],9,(LEN(GI1.[Form Object Caption]))) AS [FormCaption],
	'Perforation TAE (GI)' AS [EventType],
	[GI2_gi_flag_event] AS [EventTerm],
	'' AS [EventSpecify],
	[GI2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[GI6_ae_outcome] AS [Outcome],
	CASE WHEN GI1.[GI6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[GI4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[GI1_report_type] AS [ReportType],
	[GI1_report_Noevent_exp] AS [NoEventExplanation],
	[GI5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN GI5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN GI5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[GI4B_ser_outcome_hosp] AS [Hospitalized],
	[GI1_documents_received] AS [DocsReceivedByCorrona],
	[GI5B_ae_nosource_rsn] AS [ReasonNoSource],
	[GI5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[GI5B_reason_nosourceother] AS [ReasonNoSourceOther],
	GI1.[Form Object Status] AS [Page1Status],
	GI2.[Form Object Status] AS [Page2Status],
	GI1.[Form Object LastChange] AS [Page1LastModDate],
	GI2.[Form Object LastChange] AS [Page2LastModDate],
	GI1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[GI1] ON GI1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[GI2] ON GI2.[VisitId] = GI1.[VisitId] AND GI2.[PatientId] =GI1.[PatientID] 
    AND GI1.[GI2_gi_flag_event] = GI2.[TAEHD_AETERM] AND GI1.[GI2_lm_ae_dt_event] = GI2.[TAEHD_AESTDAT]
	AND GI1.[Form Object InstanceNo] = GI2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = GI1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(HEP1.VisitId AS int) AS [VisitID],
	CAST([HEP1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(HEP1.[Form Object Caption],9,(LEN(HEP1.[Form Object Caption]))) AS [FormCaption],
	'Hepatic TAE (HEP)' AS [EventType],
	[HEP2_hep_flag_event] AS [EventTerm],
	[HEP2_hep_event_specify] AS [EventSpecify],
	[HEP2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[HEP6_ae_outcome] AS [Outcome],
	CASE WHEN HEP1.[HEP6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[HEP4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[HEP1_report_type] AS [ReportType],
	[HEP1_report_Noevent_exp] AS [NoEventExplanation],
	[HEP5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN HEP5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN HEP5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[HEP4B_ser_outcome_hosp] AS [Hospitalized],
	[HEP1_documents_received] AS [DocsReceivedByCorrona],
	[HEP5B_ae_nosource_rsn] AS [ReasonNoSource],
	[HEP5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[HEP5B_reason_nosourceother] AS [ReasonNoSourceOther],
	HEP1.[Form Object Status] AS [Page1Status],
	HEP2.[Form Object Status] AS [Page2Status],
	HEP1.[Form Object LastChange] AS [Page1LastModDate],
	HEP2.[Form Object LastChange] AS [Page2LastModDate],
	HEP1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[HEP1] ON HEP1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[HEP2] ON HEP2.[VisitId] = HEP1.[VisitId] AND HEP2.[PatientId] =HEP1.[PatientID] 
    AND HEP1.[HEP2_HEP_flag_event] = HEP2.[TAEHD_AETERM] AND HEP1.[HEP2_lm_ae_dt_event] = HEP2.[TAEHD_AESTDAT]
	AND HEP1.[Form Object InstanceNo] = HEP2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = HEP1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(NEU1.VisitId AS int) AS [VisitID],
	CAST([NEU1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(NEU1.[Form Object Caption],9,(LEN(NEU1.[Form Object Caption]))) AS [FormCaption],
	'Neurologic TAE (NEU)' AS [EventType],
	[NEU2_neu_flag_event] AS [EventTerm],
	[NEU2_neu_event_specify] AS [EventSpecify],
	[NEU2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[NEU6_ae_outcome] AS [Outcome],
	CASE WHEN NEU1.[NEU6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[NEU4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[NEU1_report_type] AS [ReportType],
	[NEU1_report_Noevent_exp] AS [NoEventExplanation],
	[NEU5B_ae_source_docs] AS [SDocStatus],
    CASE WHEN NEU5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN NEU5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[NEU4B_ser_outcome_hosp] AS [Hospitalized],
	[NEU1_documents_received] AS [DocsReceivedByCorrona],
	[NEU5B_ae_nosource_rsn] AS [ReasonNoSource],
	[NEU5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[NEU5B_reason_nosourceother] AS [ReasonNoSourceOther],
	NEU1.[Form Object Status] AS [Page1Status],
	NEU2.[Form Object Status] AS [Page2Status],
	NEU1.[Form Object LastChange] AS [Page1LastModDate],
	NEU2.[Form Object LastChange] AS [Page2LastModDate],
	NEU1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[NEU1] ON NEU1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[NEU2] ON NEU2.[VisitId] = NEU1.[VisitId] AND NEU2.[PatientId] =NEU1.[PatientID] 
    AND NEU1.[NEU2_NEU_flag_event] = NEU2.[TAEHD_AETERM] AND NEU1.[NEU2_lm_ae_dt_event] = NEU2.[TAEHD_AESTDAT]
	AND NEU1.[Form Object InstanceNo] = NEU2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = NEU1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(SSB1.VisitId AS int) AS [VisitID],
	CAST([SSB1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(SSB1.[Form Object Caption],9,(LEN(SSB1.[Form Object Caption]))) AS [FormCaption],
	'Serious Spontaneous Bleed TAE (SSB)' AS [EventType],
	[SSB2_ssb_flag_event] AS [EventTerm],
	[SSB2_ssb_event_specify] AS [EventSpecify],
	[SSB2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[SSB6_ae_outcome] AS [Outcome],
	CASE WHEN SSB1.[SSB6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[SSB4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[SSB1_report_type] AS [ReportType],
	[SSB1_report_Noevent_exp] AS [NoEventExplanation],
	[SSB5B_ae_source_docs] AS [SDocStatus],
    CASE WHEN SSB5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN SSB5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[SSB4B_ser_outcome_hosp] AS [Hospitalized],
	[SSB1_documents_received] AS [DocsReceivedByCorrona],
	[SSB5B_ae_nosource_rsn] AS [ReasonNoSource],
	[SSB5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[SSB5B_reason_nosourceother] AS [ReasonNoSourceOther],
	SSB1.[Form Object Status] AS [Page1Status],
	SSB2.[Form Object Status] AS [Page2Status],
	SSB1.[Form Object LastChange] AS [Page1LastModDate],
	SSB2.[Form Object LastChange] AS [Page2LastModDate],
	SSB1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[SSB1] ON SSB1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[SSB2] ON SSB2.[VisitId] = SSB1.[VisitId] AND SSB2.[PatientId] =SSB1.[PatientID] 
    AND SSB1.[SSB2_SSB_flag_event] = SSB2.[TAEHD_AETERM] AND SSB1.[SSB2_lm_ae_dt_event] = SSB2.[TAEHD_AESTDAT]
	AND SSB1.[Form Object InstanceNo] = SSB2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = SSB1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(IBD1.VisitId AS int) AS [VisitID],
	CAST([IBD1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(IBD1.[Form Object Caption],9,(LEN(IBD1.[Form Object Caption]))) AS [FormCaption],
	'Inflammatory Bowel Disease TAE (IBD)' AS [EventType],
	[IBD2_ibd_flag_event] AS [EventTerm],
	'' AS [EventSpecify],
	[IBD2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[IBD6_ae_ibd_outcome] AS [Outcome],
	CASE WHEN IBD1.[IBD6_ae_ibd_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[IBD4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[IBD1_report_type] AS [ReportType],
	[IBD1_report_Noevent_exp] AS [NoEventExplanation],
	[IBD5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN IBD5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN IBD5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[IBD4B_ser_outcome_hosp] AS [Hospitalized],
	[IBD1_documents_received] AS [DocsReceivedByCorrona],
	[IBD5B_ae_nosource_rsn] AS [ReasonNoSource],
	[IBD5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[IBD5B_reason_nosourceother] AS [ReasonNoSourceOther],
	IBD1.[Form Object Status] AS [Page1Status],
	IBD2.[Form Object Status] AS [Page2Status],
	IBD1.[Form Object LastChange] AS [Page1LastModDate],
	IBD2.[Form Object LastChange] AS [Page2LastModDate],
	IBD1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[IBD1] ON IBD1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[IBD2] ON IBD2.[VisitId] = IBD1.[VisitId] AND IBD2.[PatientId] =IBD1.[PatientID] 
    AND IBD1.[IBD2_IBD_flag_event] = IBD2.[TAEHD_AETERM] AND IBD1.[IBD2_lm_ae_dt_event] = IBD2.[TAEHD_AESTDAT]
	AND IBD1.[Form Object InstanceNo] = IBD2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = IBD1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(LAI1.VisitId AS int) AS [VisitID],
	CAST([LAI1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(LAI1.[Form Object Caption],9,(LEN(LAI1.[Form Object Caption]))) AS [FormCaption],
	'Laboratory Abnormality Investigation (LAI)' AS [EventType],
	[LAI2_lai_flag_event] AS [EventTerm],
	'' AS [EventSpecify],
	[LAI2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[LAI6_ae_outcome] AS [Outcome],
	CASE WHEN LAI1.[LAI6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[LAI4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[LAI1_report_type] AS [ReportType],
	[LAI1_report_Noevent_exp] AS [NoEventExplanation],
	[LAI5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN LAI5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN LAI5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[LAI4B_ser_outcome_hosp] AS [Hospitalized],
	[LAI1_documents_received] AS [DocsReceivedByCorrona],
	[LAI5B_ae_nosource_rsn] AS [ReasonNoSource],
	[LAI5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[LAI5B_reason_nosourceother] AS [ReasonNoSourceOther],
	LAI1.[Form Object Status] AS [Page1Status],
	LAI2.[Form Object Status] AS [Page2Status],
	LAI1.[Form Object LastChange] AS [Page1LastModDate],
	LAI2.[Form Object LastChange] AS [Page2LastModDate],
	LAI1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[LAI1] ON LAI1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[LAI2] ON LAI2.[VisitId] = LAI1.[VisitId] AND LAI2.[PatientId] =LAI1.[PatientID] 
    AND LAI1.[LAI2_lai_flag_event] = LAI2.[TAEHD_AETERM] AND LAI1.[LAI2_lm_ae_dt_event] = LAI2.[TAEHD_AESTDAT]
	AND LAI1.[Form Object InstanceNo] = LAI2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = LAI1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(SIB1.VisitId AS int) AS [VisitID],
	CAST([SIB1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(SIB1.[Form Object Caption],9,(LEN(SIB1.[Form Object Caption]))) AS [FormCaption],
	'Suicidal Ideation and Behavior TAE (SIB)' AS [EventType],
	[SIB2_sib_flag_event] AS [EventTerm],
	'' AS [EventSpecify],
	[SIB2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[SIB6_ae_outcome] AS [Outcome],
	CASE WHEN SIB1.[SIB6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[SIB4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[SIB1_report_type] AS [ReportType],
	[SIB1_report_Noevent_exp] AS [NoEventExplanation],
	[SIB5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN SIB5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN SIB5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[SIB4B_ser_outcome_hosp] AS [Hospitalized],
	[SIB1_documents_received] AS [DocsReceivedByCorrona],
	[SIB5B_ae_nosource_rsn] AS [ReasonNoSource],
	[SIB5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[SIB5B_reason_nosourceother] AS [ReasonNoSourceOther],
	SIB1.[Form Object Status] AS [Page1Status],
	SIB2.[Form Object Status] AS [Page2Status],
	SIB1.[Form Object LastChange] AS [Page1LastModDate],
	SIB2.[Form Object LastChange] AS [Page2LastModDate],
	SIB1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[SIB1] ON SIB1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[SIB2] ON SIB2.[VisitId] = SIB1.[VisitId] AND SIB2.[PatientId] =SIB1.[PatientID] 
    AND SIB1.[SIB2_sib_flag_event] = SIB2.[TAEHD_AETERM] AND SIB1.[SIB2_lm_ae_dt_event] = SIB2.[TAEHD_AESTDAT]
	AND SIB1.[Form Object InstanceNo] = SIB2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = SIB1.VisitId

UNION

SELECT DISTINCT
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	CAST(GEN1.VisitId AS int) AS [VisitID],
	CAST([GEN1_TAE_md_cod] AS int) AS [ProviderID],
	SUBSTRING(GEN1.[Form Object Caption],9,(LEN(GEN1.[Form Object Caption]))) AS [FormCaption],
	'General Serious TAE (GEN)' AS [EventType],
	'General Serious Event' AS [EventTerm],
	[GEN2_gen_event_specify] AS [EventSpecify],
	[GEN2_lm_ae_dt_event] AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	[GEN6_ae_outcome] AS [Outcome],
	CASE WHEN GEN1.[GEN6_ae_outcome] = 'Death' THEN 'Yes' ELSE '' END AS [Death],
	[GEN4A_serious_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[GEN1_report_type] AS [ReportType],
	[GEN1_report_Noevent_exp] AS [NoEventExplanation],
	[GEN5B_ae_source_docs] AS [SDocStatus],
	CASE WHEN GEN5B_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN GEN5B_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[GEN4B_ser_outcome_hosp] AS [Hospitalized],
	[GEN1_documents_received] AS [DocsReceivedByCorrona],
	[GEN5B_ae_nosource_rsn] AS [ReasonNoSource],
	[GEN5B_reason_hosp_not_fax_y] AS [HospNoFaxReason],
	[GEN5B_reason_nosourceother] AS [ReasonNoSourceOther],
	GEN1.[Form Object Status] AS [Page1Status],
	GEN2.[Form Object Status] AS [Page2Status],
	GEN1.[Form Object LastChange] AS [Page1LastModDate],
	GEN2.[Form Object LastChange] AS [Page2LastModDate],
	GEN1.[Form Object InstanceNo] 
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[GEN1] ON GEN1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[GEN2] ON GEN2.[VisitId] = GEN1.[VisitId] AND GEN2.[PatientId] =GEN1.[PatientID] 
    AND GEN1.[GEN2_gen_event_specify] = GEN2.[TAEHD_AETERM] AND GEN1.[GEN2_lm_ae_dt_event] = GEN2.[TAEHD_AESTDAT]
	AND GEN1.[Form Object InstanceNo] = GEN2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = GEN1.VisitId

UNION

SELECT DISTINCT
	
	SIT.[Site Number] AS [SiteID],
	CAST(PAT.[Caption] AS nvarchar(50)) AS [SubjectID],
	PAT.PatientId,
	cAST(PG1.VisitId AS int) AS [VisitID],
	CAST([PG1_PG_md_cod] AS int) AS [ProviderID],
	SUBSTRING(PG1.[Form Object Caption],9,(LEN(PG1.[Form Object Caption]))) AS [FormCaption],
	'Pregnancy (PG)' AS [EventType],
	'Pregnancy' AS [EventTerm],
	'' AS [EventSpecify],
	'' AS [EventOnset],
	CTF.[Visit Object VisitDate] AS [VisitDate],
	'' AS [Outcome],
	'' AS [Death],
	[PG3A_preg_outcome] AS [SeriousOutcome],
	'' AS [IVAntibioticsTAEINF],
	[PG1_PG_report_type] AS [ReportType],
	[PG1_Notevent_specify] AS [NoEventExplanation],
	[PG2_ae_docs] AS [SDocStatus],
	CASE WHEN PG2_ae_docs_attach LIKE '#PDF#' THEN 'No'
             WHEN PG2_ae_docs_attach = '' THEN 'No'
             ELSE 'Yes'
       END AS [FileAttached],
	[PG3B_preg_outcome_hosp] AS [Hospitalized],
	[PG1_documents_received] AS [DocsReceivedByCorrona],
	[PG2_specify_notsubmit] AS [ReasonNoSource],
	'' AS [HospNoFaxReason],
	'' AS [ReasonNoSourceOther],
	PG1.[Form Object Status] AS [Page1Status],
	PG2.[Form Object Status] AS [Page2Status],
	PG1.[Form Object LastChange] AS [Page1LastModDate],
	PG2.[Form Object LastChange] AS [Page2LastModDate],
	PG1.[Form Object InstanceNo]
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
	INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_PSO].[inbound].[PG1] ON PG1.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[PG2] ON PG2.[VisitId] = PG1.[VisitId] AND PG2.[PatientId] =PG1.[PatientID] 
    AND PG1.[Form Object InstanceNo] = PG2.[Form Object InstanceNo]
	LEFT JOIN [OMNICOMM_PSO].[inbound].[CTF] ON CTF.VisitId = PG1.VisitId
)

SELECT DISTINCT

	AES.[SiteID],
	SStatus.[SiteStatus],
	AES.[SubjectID],
	AES.[VisitID],
	AES.[ProviderID],
	AES.[FormCaption],
	AES.[EventType],
	AES.[EventTerm],
	AES.[EventSpecify],
	AES.[EventOnset],
	AES.[VisitDate],
	AES.[Outcome],
	AES.[Death],
	AES.[SeriousOutcome],
	AES.[IVAntibioticsTAEINF],
	AES.[ReportType],
	AES.[NoEventExplanation],
	AES.[Hospitalized],
	PTINFO.[Gender],
	PTINFO.[YearOfBirth],
	PTINFO.[Race],
	PTINFO.[Ethnicity],
	CTF1.[ChangeToday1],
	CTF1.[ChangeToday1Plan],
	CTF1.[ChangeToday1Dose],
	CTF1.[ChangeToday1Freq],
	CTF2.[ChangeToday2],
	CTF2.[ChangeToday2Plan],
	CTF2.[ChangeToday2Dose],
	CTF2.[ChangeToday2Freq],
	CTF3.[ChangeToday3],
	CTF3.[ChangeToday3Plan],
	CTF3.[ChangeToday3Dose],
	CTF3.[ChangeToday3Freq],
	BIO1.[Bio1],
	BIO1.[Bio1StartDate],
	BIO1.[Bio1Dose],
	BIO1.[Bio1Freq],
	BIO2.[Bio2],
	BIO2.[Bio2StartDate],
	BIO2.[Bio2Dose],
	BIO2.[Bio2Freq],
	BIO3.[Bio3],
	BIO3.[Bio3StartDate],
	BIO3.[Bio3Dose],
	BIO3.[Bio3Freq],
	AES.[SDocStatus],
	AES.[FileAttached],
	AES.[DocsReceivedByCorrona],
	AES.[ReasonNoSource],
	AES.[HospNoFaxReason],
	AES.[ReasonNoSourceOther],
	AES.[Page1Status],
	AES.[Page2Status],
	CAST(AES.[Page1LastModDate] AS date) AS [Page1LastModDate],
	CAST(AES.[Page2LastModDate] AS date) AS [Page2LastModDate],
	AES.[Form Object InstanceNo]

FROM AES
LEFT JOIN [PSO500].[v_op_SiteListing] SStatus ON SStatus.[SiteID]=AES.[SiteID]
LEFT JOIN PTINFO ON PTINFO.[SiteID]=AES.[SiteID] AND PTINFO.[SubjectID]=AES.[SubjectID]
LEFT JOIN CTF1 ON CTF1.[VisitID]=AES.[VisitID]
LEFT JOIN CTF2 ON CTF2.[VisitID]=AES.[VisitID]
LEFT JOIN CTF3 ON CTF3.[VisitID]=AES.[VisitID]
LEFT JOIN BIO1 ON BIO1.[VisitID]=AES.[VisitID]
LEFT JOIN BIO2 ON BIO2.[VisitID]=AES.[VisitID]
LEFT JOIN BIO3 ON BIO3.[VisitID]=AES.[VisitID]







GO
