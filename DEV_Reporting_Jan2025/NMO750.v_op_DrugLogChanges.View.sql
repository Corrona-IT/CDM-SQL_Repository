USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_DrugLogChanges]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [NMO750].[v_op_DrugLogChanges] as 

With DemoView As
( 

SELECT DISTINCT S.SiteID,
	   ss.SFSiteStatus,
       d.subNum,
	   CASE WHEN d.drug_other_specify IS NULL THEN d.drug_use_dec 
	   ELSE d.drug_other_specify
	   END AS Treatment,
	   d.crfName,
	   AI.variableName,
	   AI.stagingVariable,
	   AI.questionText,
	   AI.stagingTable,
	   AI.eventType,
	   AI.crfOccurrence,
	   AI.oldValue,
	   AI.newValue,
	   AI.deleted,
	   CASE WHEN stagingVariable='drug_use' THEN CAST(d.drug_use_dec AS varchar) --use dec output for all variables that have dec versions
	   WHEN stagingVariable='drug_use_dec' THEN CAST(d.drug_use_dec AS varchar)
	   WHEN stagingVariable='drug_other_specify' THEN CAST(d.drug_other_specify AS varchar)
	   WHEN stagingVariable='drug_confirmation' THEN CAST(d.drug_confirmation_dec AS varchar)
	   WHEN stagingVariable='drug_confirmation_dec' THEN CAST(d.drug_confirmation_dec AS varchar)
	   WHEN stagingVariable='drug_indication' THEN CAST(d.drug_indication_dec AS varchar)
	   WHEN stagingVariable='drug_indication_dec' THEN CAST(d.drug_indication_dec AS varchar)
	   WHEN stagingVariable='drug_st_reason' THEN CAST(d.drug_st_reason_dec AS varchar)
	   WHEN stagingVariable='drug_st_reason_dec' THEN CAST(d.drug_st_reason_dec AS varchar)
	   WHEN stagingVariable='drug_initiation_status' THEN CAST(d.drug_initiation_status_dec AS varchar)
	   WHEN stagingVariable='drug_initiation_status_dec' THEN CAST(d.drug_initiation_status_dec AS varchar)
	   WHEN stagingVariable='drug_pres_dt' THEN CAST(d.drug_pres_dt AS varchar)
	   WHEN stagingVariable='drug_no_start_reason' THEN CAST(d.drug_no_start_reason_dec AS varchar)
	   WHEN stagingVariable='drug_no_start_reason_dec' THEN CAST(d.drug_no_start_reason_dec AS varchar)
	   WHEN stagingVariable='drug_st_dt' THEN CAST(d.drug_st_dt AS varchar)
	   WHEN stagingVariable='drug_dose' THEN CAST(d.drug_dose_dec AS varchar) 
	   WHEN stagingVariable='drug_dose_dec' THEN CAST(d.drug_dose_dec AS varchar)
	   WHEN stagingVariable='drug_dose_other' THEN CAST(d.drug_dose_other AS varchar)
	   WHEN stagingVariable='drug_dose_taper_high' THEN CAST(d.drug_dose_taper_high AS varchar)
	   WHEN stagingVariable='drug_dose_taper_low' THEN CAST(d.drug_dose_taper_low AS varchar)
	   WHEN stagingVariable='drug_freq' THEN CAST(d.drug_freq_dec AS varchar)
	   WHEN stagingVariable='drug_freq_dec' THEN CAST(d.drug_freq_dec AS varchar)
	   WHEN stagingVariable='drug_freq_other' THEN CAST(d.drug_freq_other AS varchar)
	   WHEN stagingVariable='drug_stp_dt' THEN CAST(d.drug_stp_dt AS varchar)
	   WHEN stagingVariable='drug_stp_reason' THEN CAST(d.drug_stp_reason_dec AS varchar)
	   WHEN stagingVariable='drug_stp_reason_dec' THEN CAST(d.drug_stp_reason_dec AS varchar)
	   WHEN stagingVariable='drug_status' THEN CAST(d.drug_status AS varchar)
	   ELSE ''
	   END AS currentEDCValue,

	   LAG (auditDate) OVER (PARTITION BY AI.subNum, AI.crfOccurrence, AI.eventCrfId, AI.questionText ORDER BY AI.subNum, AI.crfOccurrence, AI.questionText, auditDate, auditId) 
	   AS PriorUpdatedDate,
	     
	   auditdate AS UpdatedDate

FROM [RCC_NMOSD750].[staging].[drug] d
LEFT JOIN [RCC_NMOSD750].[api].[v_auditlogs_items] AI ON AI.eventCrfId = d.eventCrfId
LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.SubjectID = AI.subNum
LEFT JOIN [Reporting].[NMO750].[v_SiteStatus] ss ON S.SiteID = ss.SiteID
WHERE AI.eventType IN ('Item Deleted', 'Item Inserted', 'Item Updated') AND
  AI.stagingVariable LIKE ('%drug%')
  AND AI.stagingVariable NOT IN ('drug_st_estimated_dt_part', 'drug_review_dt')
  AND AI.stagingVariable NOT LIKE '%estimated%'
  AND AI.crfName = 'Drug'
  AND d.hasData = '1'

)

SELECT 
	   SiteID,
       SFSiteStatus,
       subNum,
	   Treatment,
	  crfOccurrence,
	  eventType,
	  questionText,
	  oldValue,
	  newValue,
	  currentEDCValue,
	  PriorUpdatedDate,
	  UpdatedDate,
	  DATEDIFF(D, PriorUpdatedDate, UpdatedDate) AS DaysSinceChange
FROM DemoView
WHERE 1=1
AND eventType IN ('Item Deleted', 'Item Updated') 
AND SiteID<>1440
AND DATEDIFF(D, PriorUpdatedDate, UpdatedDate)>0
--ORDER BY subNum, crfOccurrence, questionText, UpdatedDate

GO
