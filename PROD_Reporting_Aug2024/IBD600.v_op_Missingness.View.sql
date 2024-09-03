USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_Missingness]    Script Date: 9/3/2024 3:31:57 PM ******/
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
CREATE VIEW [IBD600].[v_op_Missingness] AS

SELECT  
	 VIS.[vID]
	,VIS.[SITENUM] AS [SiteID]
	,VIS.[SUBNUM] AS [SubjectID]
	,VIS.[VISNAME] AS [VisitType]
	,CAST(VIS.[VISITDATE] AS DATE) AS [VisitDate]
	,VIS.[VIR_3_1000_DEC] AS [VisitCode]
	,[MDX].[DX_IBD_DEC] AS [Diagnosis]
	,CASE 
		WHEN [MDX].[DX_IBD] <> 5 OR [MDX].[DX_IBD] IS NULL THEN NULL
		WHEN [MDX].[DX_IBD] = 5 AND [MDC].[HBI_WELL_BEING] IS NULL AND [MDC].[HBI_ABD_PAIN] IS NULL AND [MDC].[HBI_NUM_STOOL] IS NULL AND [MDC].[HBI_ABD_MASS] IS NULL AND [MDC].[HBI_COMPLICAT_NONE] IS NULL AND [MDC].[HBI_COMPLICAT_ARTHRALGIA] IS NULL AND [MDC].[HBI_COMPLICAT_UVEITIS] IS NULL AND [MDC].[HBI_COMPLICAT_ERYTHEMA] IS NULL AND [MDC].[HBI_COMPLICAT_APTHOUS_ULCER] IS NULL AND [MDC].[HBI_COMPLICAT_PYODERMA_GANG] IS NULL AND [MDC].[HBI_COMPLICAT_ANAL_FISSURE] IS NULL AND [MDC].[HBI_COMPLICAT_NEW_FISTULA] IS NULL AND [MDC].[HBI_COMPLICAT_ABSCESS] IS NULL
		THEN 1
		ELSE 0
	END AS [HBI]
	,CASE 
		WHEN [MDX].[DX_IBD] <> 1 OR [MDX].[DX_IBD] IS NULL THEN NULL
		WHEN [MDX].[DX_IBD] = 1 AND [MDC].[SCCAI_BOWEL_FREQ_DAY] IS NULL AND [MDC].[SCCAI_BOWEL_FREQ_NIGHT] IS NULL AND [MDC].[SCCAI_URGENCY_DEFECAT] IS NULL AND [MDC].[SCCAI_BLOOD_IN_STOOL] IS NULL AND [MDC].[SCCAI_WELL_BEING] IS NULL AND [MDC].[SCCAI_EXTRA_COLONIC_FEAT] IS NULL
		THEN 1
		ELSE 0
	END AS [SCCAI]
	,CASE 
		WHEN [MDX].[DX_IBD] <> 1 OR [MDX].[DX_IBD] IS NULL THEN NULL
		WHEN [MDX].[DX_IBD] = 1 AND [MDC].[MAYO_STOOL_NUM] IS NULL AND [MDC].[MAYO_STOOL] IS NULL AND [MDC].[MAYO_BLEED] IS NULL AND  [MDC].[MAYO_PGA] IS NULL 
		THEN 1
		ELSE 0
	END AS [MAYO]
	,CASE WHEN [PTP].[PROMIS_ANX_FEAR] IS NULL AND [PTP].[PROMIS_ANX_FOCUS] IS NULL AND [PTP].[PROMIS_ANX_WORRIES] IS NULL AND  [PTP].[PROMIS_ANX_UNEASY] IS NULL 
		AND [PTP].[PROMIS_DEPRESS_WORTHLESS] IS NULL AND [PTP].[PROMIS_DEPRESS_HELPLESS] IS NULL AND [PTP].[PROMIS_DEPRESS] IS NULL 
		AND [PTP].[PROMIS_DEPRESS_HOPELESS] IS NULL AND [PTP].[PROMIS_FATIGUE] IS NULL AND [PTP].[PROMIS_FATIGUE_TRBL] IS NULL AND [PTP].[PROMIS_FATIGUE_RUNDOWN] IS NULL 
		AND [PTP].[PROMIS_FATIGUE_AVG] IS NULL AND [PTP].[PROMIS_FATIGUE_BOTHER_AVG] IS NULL AND [PTP].[PROMIS_FATIGUE_PHYS] IS NULL AND [PTP].[PROMIS_SLP_DIST_QUALITY] IS NULL 
		AND [PTP].[PROMIS_SLP_DIST_REFRESH] IS NULL AND [PTP].[PROMIS_SLP_DIST_PROBLEM] IS NULL  AND [PTP].[PROMIS_SLP_DIST_FALL_ASLP] IS NULL  AND [PTP].[PROMIS_PAIN_INTERF_D2D_ACTIV] IS NULL  AND [PTP].[PROMIS_PAIN_INTERF_WK_HOUSE] IS NULL  AND [PTP].[PROMIS_PAIN_INTERF_DYACT] IS NULL  AND [PTP].[PROMIS_PAIN_INTERF_HWK] IS NULL
		THEN 1
		ELSE 0
	END AS [PROMIS] --SELECT * 
FROM [MERGE_IBD].[staging].[VISIT] VIS
 LEFT JOIN -- SELECT TOP 10 * FROM 
 [MERGE_IBD].[staging].[MD_DX] MDX ON MDX.vID = VIS.vID
 LEFT JOIN -- SELECT TOP 10 * FROM 
 [MERGE_IBD].[staging].[MD_CLINRO] MDC ON MDC.vID = VIS.vID
 LEFT JOIN -- SELECT TOP 10 * FROM 
 [MERGE_IBD].[staging].[PT_PRO] PTP ON PTP.vID = VIS.vID
 WHERE ISNULL(VIS.[VISITDATE],'')<>''





 
 






















 





















GO
