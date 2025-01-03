USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_Missingness]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =================================================
-- Author:		Dominic Grant
-- Create date: 06/26/2024
-- Description:	Determine critical assesments are missing. 1=Missing 0=Not Missing
-- =================================================

		 --SELECT * FROM
CREATE VIEW [GPP510].[v_op_Missingness] AS

SELECT 
	 VL.SiteID
	,VL.SubjectID
	--,VL.[VisitType]
	,CASE
	   WHEN SB.VISNAME = 'GPP Flare (Populated)' OR SB.VISNAME = 'GPP Flare (Manual)'
	   THEN SB.VISNAME + ' ' + SB.PAGENAME
	   ELSE VL.[VisitType]
	END AS [VisitType]
	,VL.EventOccurance
	,VL.VisitDate
	,VL.DataCollectionType
	,CASE 
		WHEN FR.flr_bsa IS NULL THEN 1
		ELSE 0
	 END AS [BSA]
	,CASE 
		WHEN MD.worst_curr_erythema IS NULL AND 
		     FR.flr_erythem_worst IS NULL AND 
			 MD.worst_curr_pustulation IS NULL AND 
			 FR.flr_pustulation_worst IS NULL AND 
			 MD.worst_curr_scaling IS NULL AND 
			 FR.flr_scaling_worst IS NULL AND 
			 MD.worst_gppga IS NULL AND 
			 FR.flr_gppga IS NULL 
		THEN 1
		ELSE 0
	 END AS [GPPGA]
	,CASE 
		WHEN MD.gppga_head_pct IS NULL AND
			 MD.gppga_head_redness IS NULL AND
			 MD.gppga_head_pustulation IS NULL AND
			 MD.gppga_head_scaling IS NULL AND
			 MD.gppga_uplimb_pct IS NULL AND
			 MD.gppga_uplimb_redness IS NULL AND
			 MD.gppga_uplimb_pustulation IS NULL AND
			 MD.gppga_uplimb_scaling IS NULL AND
			 MD.gppga_trunk_pct IS NULL AND
			 MD.gppga_trunk_redness IS NULL AND
			 MD.gppga_trunk_pustulation IS NULL AND
			 MD.gppga_trunk_scaling IS NULL AND
			 MD.gppga_lowlimb_pct IS NULL AND
			 MD.gppga_lowlimb_redness IS NULL AND
			 MD.gppga_lowlimb_pustulation IS NULL AND
			 MD.gppga_lowlimb_scaling IS NULL
		THEN 1
		ELSE 0
	 END AS [GPPASI]
	,CASE 
		WHEN SB.eq5d_health_state IS NULL
		THEN 1
		ELSE 0
	 END AS [EQ-VAS]
	,CASE 
		WHEN SB.eq5d_mobility IS NULL AND
             SB.eq5d_activities IS NULL AND
             SB.eq5d_selfcare IS NULL AND
             SB.eq5d_pain IS NULL AND
             SB.eq5d_anxiety_depression IS NULL
        THEN 1
		ELSE 0
	 END AS [EQ-5D-3L]
	,CASE 
		WHEN SB.dlqi_probs_pain IS NULL AND
             SB.dlqi_probs_embarras IS NULL AND
             SB.dlqi_probs_shop_home IS NULL AND
             SB.dlqi_probs_clothes IS NULL AND
             SB.dlqi_probs_social IS NULL AND
             SB.dlqi_probs_sports IS NULL AND
             SB.dlqi_probs_work_prevent IS NULL AND
             SB.dlqi_probs_work_problem IS NULL AND
             SB.dlqi_probs_people IS NULL AND
             SB.dlqi_probs_sex IS NULL AND
             SB.dlqi_treatment IS NULL
		THEN 1
		ELSE 0
	 END AS [DLQI]
	,CASE 
		WHEN SB.ps_pheno_pust_gen IS NULL AND
             SB.pt_pain IS NULL AND
             SB.pt_pain_skin IS NULL AND
             SB.pt_itch IS NULL AND
             SB.med_probs_burning IS NULL AND
             SB.med_probs_fatigue IS NULL AND
             (Select SA.vas_joint_pain FROM [ZELTA_GPP].staging.SUB_A SA WHERE SA.PAGENAME != 'Event Completion' AND SA.VID = VL.VID) IS NULL
        THEN 1
		ELSE 0
	 END AS [NRS] --SELECT *
 --select * 
 FROM [Reporting].GPP510.v_op_VisitLog VL
 --WHERE ISNULL(VL.[visitDate],'')<>'' AND VL.[SiteID] IS NOT NULL
--  AND VL.[VisitType] IN ('Enrollment','Follow-Up (Non-flaring)','GPP Flare (Manual)','GPP Flare (Populated)')
  LEFT JOIN [ZELTA_GPP].staging.FLR FR ON FR.vid = VL.vid 
  AND NOT (FR.PAGENAME = 'Confirmation Status' AND (FR.VISNAME = 'GPP Flare (Populated)' OR FR.VISNAME = 'GPP Flare (Manual)'))
  LEFT JOIN [ZELTA_GPP].staging.MD_DX MD ON MD.vid = VL.vid AND MD.PAGENAME = 'Provider Form B'
  LEFT JOIN [ZELTA_GPP].staging.SUB_B SB ON SB.vid = VL.vid
  WHERE ISNULL(VL.[visitDate],'')<>''
 -- AND VL.SubjectID = 'GPP-9900-0011'
 -- AND SA.PAGENAME = 'Event Completion'
  AND VL.[SiteID] IS NOT NULL
  AND VL.[VisitType] IN ('Enrollment','Follow-Up (Non-flaring)','GPP Flare (Manual)','GPP Flare (Populated)')
 -- ORDER BY SubjectID
GO
