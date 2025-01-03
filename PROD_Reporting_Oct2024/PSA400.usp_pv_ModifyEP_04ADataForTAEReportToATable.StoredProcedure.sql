USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_pv_ModifyEP_04ADataForTAEReportToATable]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		J. LING
-- Create date: 3/29/2016
-- Description:	Add a table to update the information for SAE Non
-- =============================================
CREATE PROCEDURE [PSA400].[usp_pv_ModifyEP_04ADataForTAEReportToATable]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF OBJECT_ID('[Reporting].[PSA400].[t_pv_EP_04_SAE]') IS NOT NULL DROP TABLE [Reporting].[PSA400].[t_pv_EP_04_SAE]

SELECT [vID]
      ,[SITENUM]
      ,[SUBID]
      ,[SUBNUM]
      ,[VISNAME]
      ,[PAGENAME]
      ,[VISITID]
      ,[VISITSEQ]
      ,[PAGEID]
      ,[PAGESEQ]
      ,[STATUSID]
      ,[STATUSID_DEC]
      ,[PAGELMBY]
      ,[PAGELMDT]
      ,[DATALMBY]
      ,[DATALMDT]
      ,[INF_NONE]
      ,[INF_JOINT_BURSA]
      ,[INF_JOINT_BURSA_DT]
      ,[INF_JOINT_BURSA_CODE]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE] = 'OO' THEN [INF_JOINT_BURSA_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_JOINT_BURSA_CODE] = 'NO' THEN [INF_JOINT_BURSA_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_JOINT_BURSA_CODE_DEC] END
		) AS [INF_JOINT_BURSA_CODE_DEC]
      ,[HOSP_INF_JOINT_BURSA]
      ,[IV_JOINT_BURSA]
      ,[INF_CELLULITIS]
      ,[INF_CELLULITIS_DT]
      ,[INF_CELLULITIS_CODE]
      ,(CASE WHEN [INF_CELLULITIS_CODE] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE] = 'OO' THEN [INF_CELLULITIS_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_CELLULITIS_CODE] = 'NO' THEN [INF_CELLULITIS_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_CELLULITIS_CODE_DEC] END
		) AS [INF_CELLULITIS_CODE_DEC]
      ,[HOSP_INF_CELLULITIS]
      ,[IV_CELLULITIS]
      ,[INF_SINUSITIS]
      ,[INF_SINUSITIS_DT]
      ,[INF_SINUSITIS_CODE]
      ,(CASE WHEN [INF_SINUSITIS_CODE] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE] = 'OO' THEN [INF_SINUSITIS_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_SINUSITIS_CODE] = 'NO' THEN [INF_SINUSITIS_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_SINUSITIS_CODE_DEC] END
		) AS [INF_SINUSITIS_CODE_DEC]
      ,[HOSP_INF_SINUSITIS]
      ,[IV_SINUSITIS]
      ,[INF_DIV]
      ,[INF_DIV_DT]
      ,[INF_DIV_CODE]
      ,(CASE WHEN [INF_DIV_CODE] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE] = 'OO' THEN [INF_DIV_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_DIV_CODE] = 'NO' THEN [INF_DIV_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_DIV_CODE_DEC] END
		) AS [INF_DIV_CODE_DEC]
      ,[HOSP_INF_DIV]
      ,[IV_DIV]
      ,[INF_SEPSIS]
      ,[INF_SEPSIS_DT]
      ,[INF_SEPSIS_CODE]
      ,(CASE WHEN [INF_SEPSIS_CODE] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE] = 'OO' THEN [INF_SEPSIS_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_SEPSIS_CODE] = 'NO' THEN [INF_SEPSIS_CODE_DEC]+ ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_SEPSIS_CODE_DEC] END
		) AS [INF_SEPSIS_CODE_DEC]
      ,[HOSP_INF_SEPSIS]
      ,[IV_SEPSIS]
      ,[INF_PNEUMONIA]
      ,[INF_PNEUMONIA_DT]
      ,[INF_PNEUMONIA_CODE]
      ,(CASE WHEN [INF_PNEUMONIA_CODE] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE] = 'OO' THEN [INF_PNEUMONIA_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_PNEUMONIA_CODE] = 'NO' THEN [INF_PNEUMONIA_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_PNEUMONIA_CODE_DEC] END
		) AS [INF_PNEUMONIA_CODE_DEC]
      ,[HOSP_INF_PNEUMONIA]
      ,[IV_PNEUMONIA]
      ,[INF_BRONCH]
      ,[INF_BRONCH_DT]
      ,[INF_BRONCH_CODE]
      ,(CASE WHEN [INF_BRONCH_CODE] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE] = 'OO' THEN [INF_BRONCH_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_BRONCH_CODE] = 'NO' THEN [INF_BRONCH_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_BRONCH_CODE_DEC] END
		) AS [INF_BRONCH_CODE_DEC]
      ,[HOSP_INF_BRONCH]
      ,[IV_BRONCH]
      ,[INF_GASTRO]
      ,[INF_GASTRO_DT]
      ,[INF_GASTRO_CODE]
      ,(CASE WHEN [INF_GASTRO_CODE] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE] = 'OO' THEN [INF_GASTRO_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_GASTRO_CODE] = 'NO' THEN [INF_GASTRO_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_GASTRO_CODE_DEC] END
		) AS [INF_GASTRO_CODE_DEC]
      ,[HOSP_INF_GASTRO]
      ,[IV_GASTRO]
      ,[INF_MENING]
      ,[INF_MENING_DT]
      ,[INF_MENING_CODE]
      ,(CASE WHEN [INF_MENING_CODE] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE] = 'OO' THEN [INF_MENING_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_MENING_CODE] = 'NO' THEN [INF_MENING_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_MENING_CODE_DEC] END
		) AS [INF_MENING_CODE_DEC]
      ,[HOSP_INF_MENING]
      ,[IV_MENING]
      ,[INF_UTI]
      ,[INF_UTI_DT]
      ,[INF_UTI_CODE]
      ,(CASE WHEN [INF_UTI_CODE] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE] = 'OO' THEN [INF_UTI_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_UTI_CODE] = 'NO' THEN [INF_UTI_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_UTI_CODE_DEC] END
		) AS [INF_UTI_CODE_DEC]
      ,[HOSP_INF_UTI]
      ,[IV_UTI]
      ,[INF_TB]
      ,[INF_TB_SPECIFY]
      ,[INF_TB_DT]
      ,[INF_TB_CODE]
      ,(CASE WHEN [INF_TB_CODE] IS NULL THEN NULL
			 WHEN [INF_TB_CODE] = 'OO' THEN [INF_TB_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_TB_CODE] = 'NO' THEN [INF_TB_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_TB_CODE_DEC] END
		) AS [INF_TB_CODE_DEC]
      ,[HOSP_INF_TB]
      ,[IV_TB]
      ,[INF_TB_STATUS]
      ,[INF_TB_STATUS_DEC]
      ,[INF_OTHER]
      ,[INF_OTHER_SPECIFY]
      ,[INF_OTHER_DT]
      ,[INF_OTHER_CODE]
      ,(CASE WHEN [INF_OTHER_CODE] IS NULL THEN NULL
			 WHEN [INF_OTHER_CODE] = 'OO' THEN [INF_OTHER_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_OTHER_CODE] = 'NO' THEN [INF_OTHER_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_OTHER_CODE_DEC] END
		) AS [INF_OTHER_CODE_DEC]
      ,[HOSP_INF_OTHER]
      ,[IV_OTHER]
      ,[INF_X_NO_MICROB]
      ,[INF_X_OO_MICROB]
      ,[INF_JOINT_BURSA_DT_MO]
      ,[INF_JOINT_BURSA_DT_MO_DEC]
      ,[INF_JOINT_BURSA_DT_YR]
      ,[INF_CELLULITIS_DT_MO]
      ,[INF_CELLULITIS_DT_MO_DEC]
      ,[INF_CELLULITIS_DT_YR]
      ,[INF_SINUSITIS_DT_MO]
      ,[INF_SINUSITIS_DT_MO_DEC]
      ,[INF_SINUSITIS_DT_YR]
      ,[INF_DIV_DT_MO]
      ,[INF_DIV_DT_MO_DEC]
      ,[INF_DIV_DT_YR]
      ,[INF_SEPSIS_DT_MO]
      ,[INF_SEPSIS_DT_MO_DEC]
      ,[INF_SEPSIS_DT_YR]
      ,[INF_PNEUMONIA_DT_MO]
      ,[INF_PNEUMONIA_DT_MO_DEC]
      ,[INF_PNEUMONIA_DT_YR]
      ,[INF_BRONCH_DT_MO]
      ,[INF_BRONCH_DT_MO_DEC]
      ,[INF_BRONCH_DT_YR]
      ,[INF_GASTRO_DT_MO]
      ,[INF_GASTRO_DT_MO_DEC]
      ,[INF_GASTRO_DT_YR]
      ,[INF_MENING_DT_MO]
      ,[INF_MENING_DT_MO_DEC]
      ,[INF_MENING_DT_YR]
      ,[INF_UTI_DT_MO]
      ,[INF_UTI_DT_MO_DEC]
      ,[INF_UTI_DT_YR]
      ,[INF_URI]
      ,[INF_URI_DT_MO]
      ,[INF_URI_DT_MO_DEC]
      ,[INF_URI_DT_YR]
      ,[INF_URI_CODE]
      ,(CASE WHEN [INF_URI_CODE] IS NULL THEN NULL
			 WHEN [INF_URI_CODE] = 'OO' THEN [INF_URI_CODE_DEC] + ' - ' + [INF_X_OO_MICROB]
			 WHEN [INF_URI_CODE] = 'NO' THEN [INF_URI_CODE_DEC] + ' - ' + [INF_X_NO_MICROB]
		ELSE [INF_URI_CODE_DEC] END
		) AS [INF_URI_CODE_DEC]
      ,[HOSP_INF_URI]
      ,[IV_URI]
      ,[INF_TB_DT_MO]
      ,[INF_TB_DT_MO_DEC]
      ,[INF_TB_DT_YR]
      ,[INF_OTHER_DT_MO]
      ,[INF_OTHER_DT_MO_DEC]
      ,[INF_OTHER_DT_YR]
      ,[DELETED]
      INTO [Reporting].[PSA400].[t_pv_EP_04_SAE]
  FROM [MERGE_SpA].[staging].[EP_04]
	WHERE
			[INF_JOINT_BURSA] = 'X' 
	 OR [INF_CELLULITIS] = 'X'
	 OR [INF_SINUSITIS] = 'X' 
	 OR [INF_DIV] = 'X' 
	 OR [INF_SEPSIS] = 'X'
	 OR [INF_PNEUMONIA] = 'X'
	 OR [INF_BRONCH] = 'X'
	 OR [INF_GASTRO] = 'X'
	 OR [INF_MENING] = 'X'
	 OR [INF_UTI] = 'X'
	 OR [INF_URI] = 'X'
	 OR [INF_TB] = 'X'
	 OR [INF_OTHER] = 'X'
		 
	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_JOINT_BURSA] = NULL
	, [INF_JOINT_BURSA_DT_MO] = NULL
	, [INF_JOINT_BURSA_DT_YR] = NULL
	 WHERE [HOSP_INF_JOINT_BURSA] = 'X' OR [IV_JOINT_BURSA] = 'X'
	 
	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_CELLULITIS] = NULL
	, [INF_CELLULITIS_DT_MO] = NULL
	, [INF_CELLULITIS_DT_YR] = NULL
	WHERE [HOSP_INF_CELLULITIS] = 'X'  OR[IV_CELLULITIS]  = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_SINUSITIS]= NULL
	, [INF_SINUSITIS_DT_MO]= NULL
	, [INF_SINUSITIS_DT_YR]= NULL
	WHERE [HOSP_INF_SINUSITIS] = 'X' OR [IV_SINUSITIS] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_DIV]= NULL
	, [INF_DIV_DT_MO]= NULL
	, [INF_DIV_DT_YR]= NULL
	WHERE [HOSP_INF_DIV] = 'X' OR [IV_DIV] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_SEPSIS]= NULL
	, [INF_SEPSIS_DT_MO]= NULL
	, [INF_SEPSIS_DT_YR]= NULL
	WHERE [HOSP_INF_SEPSIS] = 'X' OR [IV_SEPSIS] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_PNEUMONIA]= NULL
	, [INF_PNEUMONIA_DT_MO]= NULL
	, [INF_PNEUMONIA_DT_YR]= NULL
	WHERE [HOSP_INF_PNEUMONIA] = 'X' OR [IV_PNEUMONIA]  = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_BRONCH]= NULL
	, [INF_BRONCH_DT_MO]= NULL
	, [INF_BRONCH_DT_YR]= NULL
	WHERE [HOSP_INF_BRONCH] = 'X' OR [IV_BRONCH] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_GASTRO]= NULL
	, [INF_GASTRO_DT_MO]= NULL
	, [INF_GASTRO_DT_YR]= NULL
	WHERE [HOSP_INF_GASTRO] = 'X' OR [IV_GASTRO] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_MENING]= NULL
	, [INF_MENING_DT_MO]= NULL
	, [INF_MENING_DT_YR]= NULL
	WHERE [HOSP_INF_MENING] = 'X' OR [IV_MENING] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_UTI]= NULL
	, [INF_UTI_DT_MO]= NULL
	, [INF_UTI_DT_YR]= NULL
	WHERE [HOSP_INF_UTI] = 'X' OR [IV_UTI] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_URI]= NULL
	, [INF_URI_DT_MO]= NULL
	, [INF_URI_DT_YR]= NULL
	WHERE [HOSP_INF_URI] = 'X' OR [IV_URI] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_TB]= NULL
	, [INF_TB_DT_MO]= NULL
	, [INF_TB_DT_YR]= NULL
	WHERE [HOSP_INF_TB] = 'X' OR [IV_TB] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_EP_04_SAE]
	SET [INF_OTHER]= NULL
	, [INF_OTHER_SPECIFY]= NULL
	, [INF_OTHER_DT_MO]= NULL
	, [INF_OTHER_DT_YR]= NULL
	WHERE [HOSP_INF_OTHER] = 'X' OR [IV_OTHER] = 'X'

END






GO
