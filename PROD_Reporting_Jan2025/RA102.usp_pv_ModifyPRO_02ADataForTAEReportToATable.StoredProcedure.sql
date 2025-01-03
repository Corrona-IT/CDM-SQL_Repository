USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_pv_ModifyPRO_02ADataForTAEReportToATable]    Script Date: 1/3/2025 4:53:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		J. LING
-- Create date: 3/29/2016
-- Description:	Add a table to update the information for SAE Non
-- =============================================
CREATE PROCEDURE [RA102].[usp_pv_ModifyPRO_02ADataForTAEReportToATable]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF OBJECT_ID('[Reporting].[RA102].[t_pv_PRO_02A_SAE]') IS NOT NULL DROP TABLE [Reporting].[RA102].[t_pv_PRO_02A_SAE]

	SELECT 
		[vID]
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
      ,[PAGELMBY]
      ,[PAGELMDT]
      ,[DATALMBY]
      ,[DATALMDT]
      ,[NO_INFECTIONS]
      ,[INF_JOINT_BURSA]
      ,[INF_JOINT_BURSA_DT_DY]
      ,[INF_JOINT_BURSA_DT_MO]
      ,[INF_JOINT_BURSA_DT_YR]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE_1] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE_1] = 'OO' THEN 'OO: '+[INF_JOINT_BURSA_OO_MICROB]
			 WHEN [INF_JOINT_BURSA_CODE_1] = 'ON' THEN 'ON: '+[INF_JOINT_BURSA_NO_MICROB]
		ELSE [INF_JOINT_BURSA_CODE_1] END
		) AS [INF_JOINT_BURSA_CODE_1]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE_2] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE_2] = 'OO' THEN 'OO: '+[INF_JOINT_BURSA_OO_MICROB]
			 WHEN [INF_JOINT_BURSA_CODE_2] = 'ON' THEN 'ON: '+[INF_JOINT_BURSA_NO_MICROB]
		ELSE [INF_JOINT_BURSA_CODE_2] END
		) AS [INF_JOINT_BURSA_CODE_2]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE_3] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE_3] = 'OO' THEN 'OO: '+[INF_JOINT_BURSA_OO_MICROB]
			 WHEN [INF_JOINT_BURSA_CODE_3] = 'ON' THEN 'ON: '+[INF_JOINT_BURSA_NO_MICROB]
		ELSE [INF_JOINT_BURSA_CODE_3] END
		) AS [INF_JOINT_BURSA_CODE_3]
      ,[INF_JOINT_BURSA_OO_MICROB]
      ,[INF_JOINT_BURSA_NO_MICROB]
      ,[SER_INF_JOINT_BURSA]
      ,[IV_JOINT_BURSA]
      ,[INF_CELLULITIS]
      ,[INF_CELLULITIS_DT_DY]
      ,[INF_CELLULITIS_DT_MO]
      ,[INF_CELLULITIS_DT_YR]
      ,(CASE WHEN [INF_CELLULITIS_CODE_1] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE_1] = 'OO' THEN 'OO: '+[INF_CELLULITIS_OO_MICROB]
			 WHEN [INF_CELLULITIS_CODE_1] = 'ON' THEN 'ON: '+[INF_CELLULITIS_NO_MICROB]
		ELSE [INF_CELLULITIS_CODE_1] END
		) AS [INF_CELLULITIS_CODE_1]
      ,(CASE WHEN [INF_CELLULITIS_CODE_2] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE_2] = 'OO' THEN 'OO: '+[INF_CELLULITIS_OO_MICROB]
			 WHEN [INF_CELLULITIS_CODE_2] = 'ON' THEN 'ON: '+[INF_CELLULITIS_NO_MICROB]
		ELSE [INF_CELLULITIS_CODE_2] END
		) AS [INF_CELLULITIS_CODE_2]
      ,(CASE WHEN [INF_CELLULITIS_CODE_3] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE_3] = 'OO' THEN 'OO: '+[INF_CELLULITIS_OO_MICROB]
			 WHEN [INF_CELLULITIS_CODE_3] = 'ON' THEN 'ON: '+[INF_CELLULITIS_NO_MICROB]
		ELSE [INF_CELLULITIS_CODE_3] END
		) AS [INF_CELLULITIS_CODE_3]
      ,[INF_CELLULITIS_OO_MICROB]
      ,[INF_CELLULITIS_NO_MICROB]
      ,[SER_INF_CELLULITIS]
      ,[IV_CELLULITIS]
      ,[INF_SINUSITIS]
      ,[INF_SINUSITIS_DT_DY]
      ,[INF_SINUSITIS_DT_MO]
      ,[INF_SINUSITIS_DT_YR]
      ,(CASE WHEN [INF_SINUSITIS_CODE_1] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE_1] = 'OO' THEN 'OO: '+[INF_SINUSITIS_OO_MICROB]
			 WHEN [INF_SINUSITIS_CODE_1] = 'ON' THEN 'ON: '+[INF_SINUSITIS_NO_MICROB]
		ELSE [INF_SINUSITIS_CODE_1] END
		) AS [INF_SINUSITIS_CODE_1]
      ,(CASE WHEN [INF_SINUSITIS_CODE_2] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE_2] = 'OO' THEN 'OO: '+[INF_SINUSITIS_OO_MICROB]
			 WHEN [INF_SINUSITIS_CODE_2] = 'ON' THEN 'ON: '+[INF_SINUSITIS_NO_MICROB]
		ELSE [INF_SINUSITIS_CODE_2] END
		) AS [INF_SINUSITIS_CODE_2]
      ,(CASE WHEN [INF_SINUSITIS_CODE_3] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE_3] = 'OO' THEN 'OO: '+[INF_SINUSITIS_OO_MICROB]
			 WHEN [INF_SINUSITIS_CODE_3] = 'ON' THEN 'ON: '+[INF_SINUSITIS_NO_MICROB]
		ELSE [INF_SINUSITIS_CODE_3] END
		) AS [INF_SINUSITIS_CODE_3]
      ,[INF_SINUSITIS_OO_MICROB]
      ,[INF_SINUSITIS_NO_MICROB]
      ,[SER_INF_SINUSITIS]
      ,[IV_SINUSITIS]
      ,[INF_DIV]
      ,[INF_DIV_DT_DY]
      ,[INF_DIV_DT_MO]
      ,[INF_DIV_DT_YR]
      ,(CASE WHEN [INF_DIV_CODE_1] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE_1] = 'OO' THEN 'OO: '+[INF_DIV_OO_MICROB]
			 WHEN [INF_DIV_CODE_1] = 'ON' THEN 'ON: '+[INF_DIV_NO_MICROB]
		ELSE [INF_DIV_CODE_1] END
		) AS [INF_DIV_CODE_1]
      ,(CASE WHEN [INF_DIV_CODE_2] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE_2] = 'OO' THEN 'OO: '+[INF_DIV_OO_MICROB]
			 WHEN [INF_DIV_CODE_2] = 'ON' THEN 'ON: '+[INF_DIV_NO_MICROB]
		ELSE [INF_DIV_CODE_2] END
		) AS [INF_DIV_CODE_2]
      ,(CASE WHEN [INF_DIV_CODE_3] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE_3] = 'OO' THEN 'OO: '+[INF_DIV_OO_MICROB]
			 WHEN [INF_DIV_CODE_3] = 'ON' THEN 'ON: '+[INF_DIV_NO_MICROB]
		ELSE [INF_DIV_CODE_3] END
		) AS [INF_DIV_CODE_3]
      ,[INF_DIV_OO_MICROB]
      ,[INF_DIV_NO_MICROB]
      ,[SER_INF_DIV]
      ,[IV_DIV]
      ,[INF_SEPSIS]
      ,[INF_SEPSIS_DT_DY]
      ,[INF_SEPSIS_DT_MO]
      ,[INF_SEPSIS_DT_YR]
      ,(CASE WHEN [INF_SEPSIS_CODE_1] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE_1] = 'OO' THEN 'OO: '+[INF_SEPSIS_OO_MICROB]
			 WHEN [INF_SEPSIS_CODE_1] = 'ON' THEN 'ON: '+[INF_SEPSIS_NO_MICROB]
		ELSE [INF_SEPSIS_CODE_1] END
		) AS [INF_SEPSIS_CODE_1]
      ,(CASE WHEN [INF_SEPSIS_CODE_2] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE_2] = 'OO' THEN 'OO: '+[INF_SEPSIS_OO_MICROB]
			 WHEN [INF_SEPSIS_CODE_2] = 'ON' THEN 'ON: '+[INF_SEPSIS_NO_MICROB]
		ELSE [INF_SEPSIS_CODE_2] END
		) AS [INF_SEPSIS_CODE_2]
      ,(CASE WHEN [INF_SEPSIS_CODE_3] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE_3] = 'OO' THEN 'OO: '+[INF_SEPSIS_OO_MICROB]
			 WHEN [INF_SEPSIS_CODE_3] = 'ON' THEN 'ON: '+[INF_SEPSIS_NO_MICROB]
		ELSE [INF_SEPSIS_CODE_3] END
		) AS [INF_SEPSIS_CODE_3]
      ,[INF_SEPSIS_OO_MICROB]
      ,[INF_SEPSIS_NO_MICROB]
      ,[SER_INF_SEPSIS]
      ,[IV_SEPSIS]
      ,[INF_PNEUMONIA]
      ,[INF_PNEUMONIA_DT_DY]
      ,[INF_PNEUMONIA_DT_MO]
      ,[INF_PNEUMONIA_DT_YR]
      ,(CASE WHEN [INF_PNEUMONIA_CODE_1] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE_1] = 'OO' THEN 'OO: '+[INF_PNEUMONIA_OO_MICROB]
			 WHEN [INF_PNEUMONIA_CODE_1] = 'ON' THEN 'ON: '+[INF_PNEUMONIA_NO_MICROB]
		ELSE [INF_PNEUMONIA_CODE_1] END
		) AS [INF_PNEUMONIA_CODE_1]
      ,(CASE WHEN [INF_PNEUMONIA_CODE_2] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE_2] = 'OO' THEN 'OO: '+[INF_PNEUMONIA_OO_MICROB]
			 WHEN [INF_PNEUMONIA_CODE_2] = 'ON' THEN 'ON: '+[INF_PNEUMONIA_NO_MICROB]
		ELSE [INF_PNEUMONIA_CODE_2] END
		) AS [INF_PNEUMONIA_CODE_2]
      ,(CASE WHEN [INF_PNEUMONIA_CODE_3] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE_3] = 'OO' THEN 'OO: '+[INF_PNEUMONIA_OO_MICROB]
			 WHEN [INF_PNEUMONIA_CODE_3] = 'ON' THEN 'ON: '+[INF_PNEUMONIA_NO_MICROB]
		ELSE [INF_PNEUMONIA_CODE_3] END
		) AS [INF_PNEUMONIA_CODE_3]
      ,[INF_PNEUMONIA_OO_MICROB]
      ,[INF_PNEUMONIA_NO_MICROB]
      ,[SER_INF_PNEUMONIA]
      ,[IV_PNEUMONIA]
      ,[INF_BRONCH]
      ,[INF_BRONCH_DT_DY]
      ,[INF_BRONCH_DT_MO]
      ,[INF_BRONCH_DT_YR]
      ,(CASE WHEN [INF_BRONCH_CODE_1] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE_1] = 'OO' THEN 'OO: '+[INF_BRONCH_OO_MICROB]
			 WHEN [INF_BRONCH_CODE_1] = 'ON' THEN 'ON: '+[INF_BRONCH_NO_MICROB]
		ELSE [INF_BRONCH_CODE_1] END
		) AS [INF_BRONCH_CODE_1]
      ,(CASE WHEN [INF_BRONCH_CODE_2] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE_2] = 'OO' THEN 'OO: '+[INF_BRONCH_OO_MICROB]
			 WHEN [INF_BRONCH_CODE_2] = 'ON' THEN 'ON: '+[INF_BRONCH_NO_MICROB]
		ELSE [INF_BRONCH_CODE_2] END
		) AS [INF_BRONCH_CODE_2]
      ,(CASE WHEN [INF_BRONCH_CODE_3] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE_3] = 'OO' THEN 'OO: '+[INF_BRONCH_OO_MICROB]
			 WHEN [INF_BRONCH_CODE_3] = 'ON' THEN 'ON: '+[INF_BRONCH_NO_MICROB]
		ELSE [INF_BRONCH_CODE_3] END
		) AS [INF_BRONCH_CODE_3]
      ,[INF_BRONCH_OO_MICROB]
      ,[INF_BRONCH_NO_MICROB]
      ,[SER_INF_BRONCH]
      ,[IV_BRONCH]
      ,[INF_GASTRO]
      ,[INF_GASTRO_DT_DY]
      ,[INF_GASTRO_DT_MO]
      ,[INF_GASTRO_DT_YR]
      ,(CASE WHEN [INF_GASTRO_CODE_1] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE_1] = 'OO' THEN 'OO: '+[INF_GASTRO_OO_MICROB]
			 WHEN [INF_GASTRO_CODE_1] = 'ON' THEN 'ON: '+[INF_GASTRO_NO_MICROB]
		ELSE [INF_GASTRO_CODE_1] END
		) AS [INF_GASTRO_CODE_1]
      ,(CASE WHEN [INF_GASTRO_CODE_2] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE_2] = 'OO' THEN 'OO: '+[INF_GASTRO_OO_MICROB]
			 WHEN [INF_GASTRO_CODE_2] = 'ON' THEN 'ON: '+[INF_GASTRO_NO_MICROB]
		ELSE [INF_GASTRO_CODE_2] END
		) AS [INF_GASTRO_CODE_2]
      ,(CASE WHEN [INF_GASTRO_CODE_3] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE_3] = 'OO' THEN 'OO: '+[INF_GASTRO_OO_MICROB]
			 WHEN [INF_GASTRO_CODE_3] = 'ON' THEN 'ON: '+[INF_GASTRO_NO_MICROB]
		ELSE [INF_GASTRO_CODE_3] END
		) AS [INF_GASTRO_CODE_3]
      ,[INF_GASTRO_OO_MICROB]
      ,[INF_GASTRO_NO_MICROB]
      ,[SER_INF_GASTRO]
      ,[IV_GASTRO]
      ,[INF_MENING]
      ,[INF_MENING_DT_DY]
      ,[INF_MENING_DT_MO]
      ,[INF_MENING_DT_YR]
      ,(CASE WHEN [INF_MENING_CODE_1] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE_1] = 'OO' THEN 'OO: '+[INF_MENING_OO_MICROB]
			 WHEN [INF_MENING_CODE_1] = 'ON' THEN 'ON: '+[INF_MENING_NO_MICROB]
		ELSE [INF_MENING_CODE_1] END
		) AS [INF_MENING_CODE_1]
      ,(CASE WHEN [INF_MENING_CODE_2] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE_2] = 'OO' THEN 'OO: '+[INF_MENING_OO_MICROB]
			 WHEN [INF_MENING_CODE_2] = 'ON' THEN 'ON: '+[INF_MENING_NO_MICROB]
		ELSE [INF_MENING_CODE_2] END
		) AS [INF_MENING_CODE_2]
      ,(CASE WHEN [INF_MENING_CODE_3] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE_3] = 'OO' THEN 'OO: '+[INF_MENING_OO_MICROB]
			 WHEN [INF_MENING_CODE_3] = 'ON' THEN 'ON: '+[INF_MENING_NO_MICROB]
		ELSE [INF_MENING_CODE_3] END
		) AS [INF_MENING_CODE_3]
      ,[INF_MENING_OO_MICROB]
      ,[INF_MENING_NO_MICROB]
      ,[SER_INF_MENING]
      ,[IV_MENING]
      ,[INF_UTI]
      ,[INF_UTI_DT_DY]
      ,[INF_UTI_DT_MO]
      ,[INF_UTI_DT_YR]
      ,(CASE WHEN [INF_UTI_CODE_1] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE_1] = 'OO' THEN 'OO: '+[INF_UTI_OO_MICROB]
			 WHEN [INF_UTI_CODE_1] = 'ON' THEN 'ON: '+[INF_UTI_NO_MICROB]
		ELSE [INF_UTI_CODE_1] END
		) AS [INF_UTI_CODE_1]
      ,(CASE WHEN [INF_UTI_CODE_2] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE_2] = 'OO' THEN 'OO: '+[INF_UTI_OO_MICROB]
			 WHEN [INF_UTI_CODE_2] = 'ON' THEN 'ON: '+[INF_UTI_NO_MICROB]
		ELSE [INF_UTI_CODE_2] END
		) AS [INF_UTI_CODE_2]
      ,(CASE WHEN [INF_UTI_CODE_3] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE_3] = 'OO' THEN 'OO: '+[INF_UTI_OO_MICROB]
			 WHEN [INF_UTI_CODE_3] = 'ON' THEN 'ON: '+[INF_UTI_NO_MICROB]
		ELSE [INF_UTI_CODE_3] END
		) AS [INF_UTI_CODE_3]
      ,[INF_UTI_OO_MICROB]
      ,[INF_UTI_NO_MICROB]
      ,[SER_INF_UTI]
      ,[IV_UTI]
      ,[INF_URI]
      ,[INF_URI_DT_DY]
      ,[INF_URI_DT_MO]
      ,[INF_URI_DT_YR]
      ,(CASE WHEN [INF_URI_CODE_1] IS NULL THEN NULL
			 WHEN [INF_URI_CODE_1] = 'OO' THEN 'OO: '+[INF_URI_OO_MICROB]
			 WHEN [INF_URI_CODE_1] = 'ON' THEN 'ON: '+[INF_URI_NO_MICROB]
		ELSE [INF_URI_CODE_1] END
		) AS [INF_URI_CODE_1]
      ,(CASE WHEN [INF_URI_CODE_2] IS NULL THEN NULL
			 WHEN [INF_URI_CODE_2] = 'OO' THEN 'OO: '+[INF_URI_OO_MICROB]
			 WHEN [INF_URI_CODE_2] = 'ON' THEN 'ON: '+[INF_URI_NO_MICROB]
		ELSE [INF_URI_CODE_2] END
		) AS [INF_URI_CODE_2]
      ,(CASE WHEN [INF_URI_CODE_3] IS NULL THEN NULL
			 WHEN [INF_URI_CODE_3] = 'OO' THEN 'OO: '+[INF_URI_OO_MICROB]
			 WHEN [INF_URI_CODE_3] = 'ON' THEN 'ON: '+[INF_URI_NO_MICROB]
		ELSE [INF_URI_CODE_3] END
		) AS [INF_URI_CODE_3]
      ,[INF_URI_OO_MICROB]
      ,[INF_URI_NO_MICROB]
      ,[SER_INF_URI]
      ,[IV_URI]
      ,[INF_TB]
      ,[INF_TB_DT_DY]
      ,[INF_TB_DT_MO]
      ,[INF_TB_DT_YR]
      ,[INF_TB_STATUS]
      ,[INF_TB_SPECIFY]
      ,(CASE WHEN [INF_TB_CODE_1] IS NULL THEN NULL
			 WHEN [INF_TB_CODE_1] = 'OO' THEN 'OO: '+[INF_TB_OO_MICROB]
			 WHEN [INF_TB_CODE_1] = 'ON' THEN 'ON: '+[INF_TB_NO_MICROB]
		ELSE [INF_TB_CODE_1] END
		) AS [INF_TB_CODE_1]
      ,(CASE WHEN [INF_TB_CODE_2] IS NULL THEN NULL
			 WHEN [INF_TB_CODE_2] = 'OO' THEN 'OO: '+[INF_TB_OO_MICROB]
			 WHEN [INF_TB_CODE_2] = 'ON' THEN 'ON: '+[INF_TB_NO_MICROB]
		ELSE [INF_TB_CODE_2] END
		) AS [INF_TB_CODE_2]
      ,(CASE WHEN [INF_TB_CODE_3] IS NULL THEN NULL
			 WHEN [INF_TB_CODE_3] = 'OO' THEN 'OO: '+[INF_TB_OO_MICROB]
			 WHEN [INF_TB_CODE_3] = 'ON' THEN 'ON: '+[INF_TB_NO_MICROB]
		ELSE [INF_TB_CODE_3] END
		) AS [INF_TB_CODE_3]
      ,[INF_TB_OO_MICROB]
      ,[INF_TB_NO_MICROB]
      ,[SER_INF_TB]
      ,[IV_TB]
      ,[INF_OTHER]
      ,[INF_OTHER_SPECIFY]
      ,[INF_OTHER_DT_DY]
      ,[INF_OTHER_DT_MO]
      ,[INF_OTHER_DT_YR]
      ,(CASE WHEN [INF_OTHER_CODE_1] IS NULL THEN NULL
			 WHEN [INF_OTHER_CODE_1] = 'OO' THEN 'OO: '+[INF_OTHER_OO_MICROB]
			 WHEN [INF_OTHER_CODE_1] = 'ON' THEN 'ON: '+[INF_OTHER_NO_MICROB]
		ELSE [INF_TB_CODE_1] END
		) AS [INF_OTHER_CODE_1]
      ,(CASE WHEN [INF_OTHER_CODE_2] IS NULL THEN NULL
			 WHEN [INF_OTHER_CODE_2] = 'OO' THEN 'OO: '+[INF_OTHER_OO_MICROB]
			 WHEN [INF_OTHER_CODE_2] = 'ON' THEN 'ON: '+[INF_OTHER_NO_MICROB]
		ELSE [INF_TB_CODE_2] END
		) AS [INF_OTHER_CODE_2]
      ,(CASE WHEN [INF_OTHER_CODE_3] IS NULL THEN NULL
			 WHEN [INF_OTHER_CODE_3] = 'OO' THEN 'OO: '+[INF_OTHER_OO_MICROB]
			 WHEN [INF_OTHER_CODE_3] = 'ON' THEN 'ON: '+[INF_OTHER_NO_MICROB]
		ELSE [INF_TB_CODE_3] END
		) AS [INF_OTHER_CODE_3]
      ,[INF_OTHER_OO_MICROB]
      ,[INF_OTHER_NO_MICROB]
      ,[SER_INF_OTHER]
      ,[IV_OTHER]
      ,[INF_DRUG_RELATE]
      ,[INF_DRUG_EVENT1]
      ,[INF_EVENT_DRUG1]
      ,[INF_DRUG_EVENT2]
      ,[INF_EVENT_DRUG2]
      ,[INF_DRUG_EVENT3]
      ,[INF_EVENT_DRUG3]
      ,[INF_DRUG_EVENT4]
      ,[INF_EVENT_DRUG4]
      ,[DELETED]
		INTO [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	FROM 
	  [MERGE_RA_Japan].[staging].[PRO_02A] PRO02A
	WHERE
			PRO02A.[INF_JOINT_BURSA] = 'X' 
	 OR PRO02A.[INF_CELLULITIS] = 'X'
	 OR PRO02A.[INF_SINUSITIS] = 'X' 
	 OR PRO02A.[INF_DIV] = 'X' 
	 OR PRO02A.[INF_SEPSIS] = 'X'
	 OR PRO02A.[INF_PNEUMONIA] = 'X'
	 OR PRO02A.[INF_BRONCH] = 'X'
	 OR PRO02A.[INF_GASTRO] = 'X'
	 OR PRO02A.[INF_MENING] = 'X'
	 OR PRO02A.[INF_UTI] = 'X'
	 OR PRO02A.[INF_URI] = 'X'
	 OR PRO02A.[INF_TB] = 'X'
	 OR PRO02A.[INF_OTHER] = 'X'
		 
	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_JOINT_BURSA] = NULL
	, [INF_JOINT_BURSA_DT_MO] = NULL
	, [INF_JOINT_BURSA_DT_YR] = NULL
	 WHERE [SER_INF_JOINT_BURSA] = 'X' OR [IV_JOINT_BURSA] = 'X'
	 
	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_CELLULITIS] = NULL
	, [INF_CELLULITIS_DT_MO] = NULL
	, [INF_CELLULITIS_DT_YR] = NULL
	WHERE [SER_INF_CELLULITIS] = 'X' OR [IV_CELLULITIS] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_SINUSITIS]= NULL
	, [INF_SINUSITIS_DT_MO]= NULL
	, [INF_SINUSITIS_DT_YR]= NULL
	WHERE [SER_INF_SINUSITIS] = 'X' OR [IV_SINUSITIS] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_DIV]= NULL
	, [INF_DIV_DT_MO]= NULL
	, [INF_DIV_DT_YR]= NULL
	WHERE [SER_INF_DIV] = 'X' OR [IV_DIV] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_SEPSIS]= NULL
	, [INF_SEPSIS_DT_MO]= NULL
	, [INF_SEPSIS_DT_YR]= NULL
	WHERE [SER_INF_SEPSIS] = 'X' OR [IV_SEPSIS] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_PNEUMONIA]= NULL
	, [INF_PNEUMONIA_DT_MO]= NULL
	, [INF_PNEUMONIA_DT_YR]= NULL
	WHERE [SER_INF_PNEUMONIA] = 'X' OR [IV_PNEUMONIA] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_BRONCH]= NULL
	, [INF_BRONCH_DT_MO]= NULL
	, [INF_BRONCH_DT_YR]= NULL
	WHERE [SER_INF_BRONCH] = 'X' OR [IV_BRONCH] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_GASTRO]= NULL
	, [INF_GASTRO_DT_MO]= NULL
	, [INF_GASTRO_DT_YR]= NULL
	WHERE [SER_INF_GASTRO] = 'X' OR [IV_GASTRO] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_MENING]= NULL
	, [INF_MENING_DT_MO]= NULL
	, [INF_MENING_DT_YR]= NULL
	WHERE [SER_INF_MENING] = 'X' OR [IV_MENING] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_UTI]= NULL
	, [INF_UTI_DT_MO]= NULL
	, [INF_UTI_DT_YR]= NULL
	WHERE [SER_INF_UTI] = 'X' OR [IV_UTI] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_URI]= NULL
	, [INF_URI_DT_MO]= NULL
	, [INF_URI_DT_YR]= NULL
	WHERE [SER_INF_URI] = 'X' OR [IV_URI] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_TB]= NULL
	, [INF_TB_DT_MO]= NULL
	, [INF_TB_DT_YR]= NULL
	WHERE [SER_INF_TB] = 'X' OR [IV_TB] = 'X'

	UPDATE [MERGE_RA_JAPAN].[Jen].[PRO_02A_SAE]
	SET [INF_OTHER]= NULL
	, [INF_OTHER_SPECIFY]= NULL
	, [INF_OTHER_DT_MO]= NULL
	, [INF_OTHER_DT_YR]= NULL
	WHERE [SER_INF_OTHER] = 'X' OR [IV_OTHER] = 'X'

END


GO
