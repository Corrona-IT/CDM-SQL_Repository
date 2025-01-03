USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_Missingness]    Script Date: 11/13/2024 12:16:32 PM ******/
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
CREATE VIEW [AD550].[v_op_Missingness] AS

SELECT 
	 CAST(sub.[SiteID] AS INT) AS [SiteID]
	,pro.[subNum] AS [SubjectID]
	,pro.[eventName] AS [VisitType]
	,CAST(pro.[visit_dt] AS DATE) AS [VisitDate]
	,CASE
		WHEN pro.[visit_virtual_md] = 1 THEN 'In-person'
		WHEN pro.[visit_virtual_md] = 2 THEN 'Virtually'
		ELSE NULL
		END AS [VisitCode]
	,CASE
		WHEN pro.[visit_virtual_pt] = 1 THEN 'Yes'
		WHEN pro.[visit_virtual_pt] = 0 THEN 'No'
		ELSE NULL 
		END AS [PTVirtualVisit]
	,CASE 
		WHEN pro.[vigaad] IS NULL THEN 1
		ELSE 0
	 END AS [IGA]
	,CASE 
		WHEN CAST(pro.[bsaface] AS int) IS NULL AND CAST(pro.[bsascalp] AS int) IS NULL AND  CAST(pro.[bsaneck] AS int) IS NULL AND CAST(pro.[bsatrunkanterior] AS int) IS NULL AND CAST(pro.[bsaback] AS int) IS NULL AND CAST(pro.[bsagenitals] AS int) IS NULL AND CAST(pro.[bsaarms] AS int) IS NULL AND CAST(pro.[bsadorsalhands] AS int) IS NULL AND CAST(pro.[bsapalmarhands] AS int) IS NULL AND CAST(pro.[bsabuttocks] AS int) IS NULL AND CAST(pro.[bsalowerlimbs] AS int) IS NULL AND CAST(pro.[bsadorsalfeet] AS int) IS NULL AND CAST(pro.[bsaplantarfeet] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [BSA]
	,CASE 
		WHEN CAST(pro.[headneckerythema] AS int) IS NULL AND CAST(pro.[headneckedema] AS int) IS NULL AND  CAST(pro.[headneckexoriation] AS int) IS NULL AND CAST(pro.[headnecklichenification] AS int) IS NULL AND CAST(pro.[trunkbackerythema] AS int) IS NULL AND CAST(pro.[trunkbackedema] AS int) IS NULL AND CAST(pro.[trunkbackexoriation] AS int) IS NULL AND CAST(pro.[trunkbacklichenification] AS int) IS NULL AND CAST(pro.[armserythema] AS int) IS NULL AND CAST(pro.[armsedema] AS int) IS NULL AND CAST(pro.[armslichenification] AS int) IS NULL AND CAST(pro.[armsexoriation] AS int) IS NULL AND CAST(pro.[legsbuttockserythema] AS int) IS NULL AND CAST(pro.[legsbuttocksedema] AS int) IS NULL  AND CAST(pro.[legsbuttocksexoriation] AS int) IS NULL  AND CAST(pro.[legsbuttockslichenification] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [EASI]
	,CASE 
		WHEN CAST(pro.[scoraderythema] AS int) IS NULL AND CAST(pro.[scoradedema] AS int) IS NULL AND  CAST(pro.[scoradexoriation] AS int) IS NULL AND CAST(pro.[scoradlichenification] AS int) IS NULL AND CAST(pro.[scoradoozingcrusting] AS int) IS NULL AND CAST(pro.[scoraddryness] AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [SCORAD]
	,CASE 
		WHEN sbj.[ptseverity_ad] IS NULL AND sbj.[ptcontrol_ad] IS NULL THEN 1
		ELSE 0
	 END AS [PGA]
	,CASE 
		WHEN CAST(sbj.[dlqi_probs_pain] AS int) IS NULL AND CAST(sbj.[dlqi_probs_embarras] AS int) IS NULL AND  CAST(sbj.[dlqi_probs_shop_home] AS int) IS NULL AND CAST(sbj.[dlqi_probs_clothes] AS int) IS NULL AND CAST(sbj.[dlqi_probs_social] AS int) IS NULL AND CAST(sbj.[dlqi_probs_sports] AS int) IS NULL AND CAST(sbj.[dlqi_probs_work_prevent] AS int) IS NULL AND CAST(sbj.[dlqi_probs_work_problem] AS int) IS NULL AND CAST(sbj.[dlqi_probs_people]AS int) IS NULL AND CAST(sbj.[dlqi_probs_sex]AS int) IS NULL AND CAST(sbj.[dlqi_probs_treatment]AS int) IS NULL
		THEN 1
		ELSE 0
	 END AS [DLQI]
	,CASE 
		WHEN CAST(sbj.[adct_symptoms] AS int) IS NULL AND CAST(sbj.[adct_itch] AS int) IS NULL AND  CAST(sbj.[adct_bother] AS int) IS NULL AND CAST(sbj.[adct_troublesleeping] AS int) IS NULL AND CAST(sbj.[adct_dailyactivities] AS int) IS NULL AND CAST(sbj.[adct_mood] AS int) IS NULL 
		THEN 1
		ELSE 0
	 END AS [ADCT] --SELECT *
  FROM [RCC_AD550].[staging].[provider] pro
  LEFT JOIN --SELECT * FROM
  [Reporting].[AD550].[v_op_subjects] sub ON pro.subjectId=sub.patientId
  LEFT JOIN --SELECT * FROM
  [RCC_AD550].[staging].[subject] sbj ON pro.subjectId=sbj.subjectId AND pro.[eventId] = sbj.[eventId] AND pro.[eventOccurrence] = sbj.[eventOccurrence]
  WHERE ISNULL(pro.[visit_dt],'')<>''
  AND sub.[SiteID] IS NOT NULL

  
GO
