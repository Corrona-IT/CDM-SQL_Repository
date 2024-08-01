USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_pv_ModifyFPRO_03DataForTAEReportToATable]    Script Date: 8/1/2024 11:24:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		J. LING
-- Create date: 3/29/2016
-- Description:	Add a table to update the information for SAE Non
-- =============================================
CREATE PROCEDURE [PSA400].[usp_pv_ModifyFPRO_03DataForTAEReportToATable]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF OBJECT_ID('[Reporting].[PSA400].[t_pv_FPRO_03_SAE]') IS NOT NULL DROP TABLE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]

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
      ,[INF_JOINT_BURSA_DT_DY]
      ,[INF_JOINT_BURSA_DT_DY_DEC]
      ,[INF_JOINT_BURSA_DT_MO]
      ,[INF_JOINT_BURSA_DT_MO_DEC]
      ,[INF_JOINT_BURSA_DT_YR]
      ,[INF_JOINT_BURSA_DT_YR_DEC]
      ,[INF_JOINT_BURSA_CODE_1]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE_1] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE_1] = 'OO' THEN [INF_JOINT_BURSA_CODE_1_DEC] + ' - ' + [INF_JOINT_BURSA_OTHER_MYCO]
			 WHEN [INF_JOINT_BURSA_CODE_1] = 'NO' THEN [INF_JOINT_BURSA_CODE_1_DEC] + ' - ' + [INF_JOINT_BURSA_OTHER_OPP]
		ELSE [INF_JOINT_BURSA_CODE_1_DEC] END
		) AS [INF_JOINT_BURSA_CODE_1_DEC]
      ,[INF_JOINT_BURSA_CODE_2]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE_2] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE_2] = 'OO' THEN [INF_JOINT_BURSA_CODE_2_DEC] + ' - ' + [INF_JOINT_BURSA_OTHER_MYCO]
			 WHEN [INF_JOINT_BURSA_CODE_2] = 'NO' THEN [INF_JOINT_BURSA_CODE_2_DEC] + ' - ' + [INF_JOINT_BURSA_OTHER_OPP]
		ELSE [INF_JOINT_BURSA_CODE_2_DEC] END
		) AS [INF_JOINT_BURSA_CODE_2_DEC]
      ,[INF_JOINT_BURSA_CODE_3]
      ,(CASE WHEN [INF_JOINT_BURSA_CODE_3] IS NULL THEN NULL
			 WHEN [INF_JOINT_BURSA_CODE_3] = 'OO' THEN [INF_JOINT_BURSA_CODE_3_DEC] + ' - ' + [INF_JOINT_BURSA_OTHER_MYCO]
			 WHEN [INF_JOINT_BURSA_CODE_3] = 'NO' THEN [INF_JOINT_BURSA_CODE_3_DEC] + ' - ' + [INF_JOINT_BURSA_OTHER_OPP]
		ELSE [INF_JOINT_BURSA_CODE_3_DEC] END
		) AS [INF_JOINT_BURSA_CODE_3_DEC]
      ,[INF_JOINT_BURSA_OTHER_MYCO]
      ,[INF_JOINT_BURSA_OTHER_OPP]
      ,[SER_INF_JOINT_BURSA]
      ,[IV_JOINT_BURSA]
      ,[INF_CELLULITIS]
      ,[INF_CELLULITIS_DT_DY]
      ,[INF_CELLULITIS_DT_DY_DEC]
      ,[INF_CELLULITIS_DT_MO]
      ,[INF_CELLULITIS_DT_MO_DEC]
      ,[INF_CELLULITIS_DT_YR]
      ,[INF_CELLULITIS_DT_YR_DEC]
      ,[INF_CELLULITIS_CODE_1]
      ,(CASE WHEN [INF_CELLULITIS_CODE_1] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE_1] = 'OO' THEN [INF_CELLULITIS_CODE_1_DEC] + ' - ' + [INF_CELLULITIS_OTHER_MYCO]
			 WHEN [INF_CELLULITIS_CODE_1] = 'NO' THEN [INF_CELLULITIS_CODE_1_DEC] + ' - ' + [INF_CELLULITIS_OTHER_OPP]
		ELSE [INF_CELLULITIS_CODE_1_DEC] END
		) AS [INF_CELLULITIS_CODE_1_DEC]
      ,[INF_CELLULITIS_CODE_2]
      ,(CASE WHEN [INF_CELLULITIS_CODE_2] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE_2] = 'OO' THEN [INF_CELLULITIS_CODE_2_DEC] + ' - ' + [INF_CELLULITIS_OTHER_MYCO]
			 WHEN [INF_CELLULITIS_CODE_2] = 'NO' THEN [INF_CELLULITIS_CODE_2_DEC] + ' - ' + [INF_CELLULITIS_OTHER_OPP]
		ELSE [INF_CELLULITIS_CODE_2_DEC] END
		) AS [INF_CELLULITIS_CODE_2_DEC]
      ,[INF_CELLULITIS_CODE_3]
      ,(CASE WHEN [INF_CELLULITIS_CODE_3] IS NULL THEN NULL
			 WHEN [INF_CELLULITIS_CODE_3] = 'OO' THEN [INF_CELLULITIS_CODE_3_DEC] + ' - ' + [INF_CELLULITIS_OTHER_MYCO]
			 WHEN [INF_CELLULITIS_CODE_3] = 'NO' THEN [INF_CELLULITIS_CODE_3_DEC] + ' - ' + [INF_CELLULITIS_OTHER_OPP]
		ELSE [INF_CELLULITIS_CODE_3_DEC] END
		) AS [INF_CELLULITIS_CODE_3_DEC]
      ,[INF_CELLULITIS_OTHER_MYCO]
      ,[INF_CELLULITIS_OTHER_OPP]
      ,[SER_INF_CELLULITIS]
      ,[IV_CELLULITIS]
      ,[INF_SINUSITIS]
      ,[INF_SINUSITIS_DT_DY]
      ,[INF_SINUSITIS_DT_DY_DEC]
      ,[INF_SINUSITIS_DT_MO]
      ,[INF_SINUSITIS_DT_MO_DEC]
      ,[INF_SINUSITIS_DT_YR]
      ,[INF_SINUSITIS_DT_YR_DEC]
      ,[INF_SINUSITIS_CODE_1]
      ,(CASE WHEN [INF_SINUSITIS_CODE_1] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE_1] = 'OO' THEN [INF_SINUSITIS_CODE_1_DEC] + ' - ' + [INF_SINUSITIS_OTHER_MYCO]
			 WHEN [INF_SINUSITIS_CODE_1] = 'NO' THEN [INF_SINUSITIS_CODE_1_DEC] + ' - ' + [INF_SINUSITIS_OTHER_OPP]
		ELSE [INF_SINUSITIS_CODE_1_DEC] END
		) AS [INF_SINUSITIS_CODE_1_DEC]
      ,[INF_SINUSITIS_CODE_2]
      ,(CASE WHEN [INF_SINUSITIS_CODE_2] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE_2] = 'OO' THEN [INF_SINUSITIS_CODE_2_DEC] + ' - ' + [INF_SINUSITIS_OTHER_MYCO]
			 WHEN [INF_SINUSITIS_CODE_2] = 'NO' THEN [INF_SINUSITIS_CODE_2_DEC] + ' - ' + [INF_SINUSITIS_OTHER_OPP]
		ELSE [INF_SINUSITIS_CODE_2_DEC] END
		) AS [INF_SINUSITIS_CODE_2_DEC]
      ,[INF_SINUSITIS_CODE_3]
      ,(CASE WHEN [INF_SINUSITIS_CODE_3] IS NULL THEN NULL
			 WHEN [INF_SINUSITIS_CODE_3] = 'OO' THEN [INF_SINUSITIS_CODE_3_DEC] + ' - ' + [INF_SINUSITIS_OTHER_MYCO]
			 WHEN [INF_SINUSITIS_CODE_3] = 'NO' THEN [INF_SINUSITIS_CODE_3_DEC] + ' - ' + [INF_SINUSITIS_OTHER_OPP]
		ELSE [INF_SINUSITIS_CODE_3_DEC] END
		) AS [INF_SINUSITIS_CODE_3_DEC]
      ,[INF_SINUSITIS_OTHER_MYCO]
      ,[INF_SINUSITIS_OTHER_OPP]
      ,[SER_INF_SINUSITIS]
      ,[IV_SINUSITIS]
      ,[INF_CANDIDA]
      ,[INF_CANDIDA_TYPE]
      ,[INF_CANDIDA_TYPE_DEC]
      ,[INF_CANDIDA_DT_DY]
      ,[INF_CANDIDA_DT_DY_DEC]
      ,[INF_CANDIDA_DT_MO]
      ,[INF_CANDIDA_DT_MO_DEC]
      ,[INF_CANDIDA_DT_YR]
      ,[INF_CANDIDA_DT_YR_DEC]
      ,[INF_CANDIDA_CODE_1]
      ,(CASE WHEN [INF_CANDIDA_CODE_1] IS NULL THEN NULL
			 WHEN [INF_CANDIDA_CODE_1] = 'OO' THEN [INF_CANDIDA_CODE_1_DEC] + ' - ' + [INF_CANDIDA_OTHER_MYCO]
			 WHEN [INF_CANDIDA_CODE_1] = 'NO' THEN [INF_CANDIDA_CODE_1_DEC] + ' - ' + [INF_CANDIDA_OTHER_OPP]
		ELSE [INF_CANDIDA_CODE_1_DEC] END
		) AS [INF_CANDIDA_CODE_1_DEC]
      ,[INF_CANDIDA_CODE_2]
      ,(CASE WHEN [INF_CANDIDA_CODE_2] IS NULL THEN NULL
			 WHEN [INF_CANDIDA_CODE_2] = 'OO' THEN [INF_CANDIDA_CODE_2_DEC] + ' - ' + [INF_CANDIDA_OTHER_MYCO]
			 WHEN [INF_CANDIDA_CODE_2] = 'NO' THEN [INF_CANDIDA_CODE_2_DEC] + ' - ' + [INF_CANDIDA_OTHER_OPP]
		ELSE [INF_CANDIDA_CODE_2_DEC] END
		) AS [INF_CANDIDA_CODE_2_DEC]
      ,[INF_CANDIDA_CODE_3]
      ,(CASE WHEN [INF_CANDIDA_CODE_3] IS NULL THEN NULL
			 WHEN [INF_CANDIDA_CODE_3] = 'OO' THEN [INF_CANDIDA_CODE_3_DEC] + ' - ' + [INF_CANDIDA_OTHER_MYCO]
			 WHEN [INF_CANDIDA_CODE_3] = 'NO' THEN [INF_CANDIDA_CODE_3_DEC] + ' - ' + [INF_CANDIDA_OTHER_OPP]
		ELSE [INF_CANDIDA_CODE_3_DEC] END
		) AS [INF_CANDIDA_CODE_3_DEC]
      ,[INF_CANDIDA_OTHER_MYCO]
      ,[INF_CANDIDA_OTHER_OPP]
      ,[SER_INF_CANDIDA]
      ,[IV_CANDIDA]
      ,[INF_DIV]
      ,[INF_DIV_DT_DY]
      ,[INF_DIV_DT_DY_DEC]
      ,[INF_DIV_DT_MO]
      ,[INF_DIV_DT_MO_DEC]
      ,[INF_DIV_DT_YR]
      ,[INF_DIV_DT_YR_DEC]
      ,[INF_DIV_CODE_1]
      ,(CASE WHEN [INF_DIV_CODE_1] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE_1] = 'OO' THEN [INF_DIV_CODE_1_DEC] + ' - ' + [INF_DIV_OTHER_MYCO]
			 WHEN [INF_DIV_CODE_1] = 'NO' THEN [INF_DIV_CODE_1_DEC] + ' - ' + [INF_DIV_OTHER_OPP]
		ELSE [INF_DIV_CODE_1_DEC] END
		) AS [INF_DIV_CODE_1_DEC]
      ,[INF_DIV_CODE_2]
      ,(CASE WHEN [INF_DIV_CODE_2] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE_2] = 'OO' THEN [INF_DIV_CODE_2_DEC] + ' - ' + [INF_DIV_OTHER_MYCO]
			 WHEN [INF_DIV_CODE_2] = 'NO' THEN [INF_DIV_CODE_2_DEC] + ' - ' + [INF_DIV_OTHER_OPP]
		ELSE [INF_DIV_CODE_2_DEC] END
		) AS [INF_DIV_CODE_2_DEC]
      ,[INF_DIV_CODE_3]
      ,(CASE WHEN [INF_DIV_CODE_3] IS NULL THEN NULL
			 WHEN [INF_DIV_CODE_3] = 'OO' THEN [INF_DIV_CODE_3_DEC] + ' - ' + [INF_DIV_OTHER_MYCO]
			 WHEN [INF_DIV_CODE_3] = 'NO' THEN [INF_DIV_CODE_3_DEC] + ' - ' + [INF_DIV_OTHER_OPP]
		ELSE [INF_DIV_CODE_3_DEC] END
		) AS [INF_DIV_CODE_3_DEC]
      ,[INF_DIV_OTHER_MYCO]
      ,[INF_DIV_OTHER_OPP]
      ,[SER_INF_DIV]
      ,[IV_DIV]
      ,[INF_SEPSIS]
      ,[INF_SEPSIS_DT_DY]
      ,[INF_SEPSIS_DT_DY_DEC]
      ,[INF_SEPSIS_DT_MO]
      ,[INF_SEPSIS_DT_MO_DEC]
      ,[INF_SEPSIS_DT_YR]
      ,[INF_SEPSIS_DT_YR_DEC]
      ,[INF_SEPSIS_CODE_1]
      ,(CASE WHEN [INF_SEPSIS_CODE_1] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE_1] = 'OO' THEN [INF_SEPSIS_CODE_1_DEC] + ' - ' + [INF_SEPSIS_OTHER_MYCO]
			 WHEN [INF_SEPSIS_CODE_1] = 'NO' THEN [INF_SEPSIS_CODE_1_DEC] + ' - ' + [INF_SEPSIS_OTHER_OPP]
		ELSE [INF_SEPSIS_CODE_1_DEC] END
		) AS [INF_SEPSIS_CODE_1_DEC]
      ,[INF_SEPSIS_CODE_2]
      ,(CASE WHEN [INF_SEPSIS_CODE_2] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE_2] = 'OO' THEN [INF_SEPSIS_CODE_2_DEC] + ' - ' + [INF_SEPSIS_OTHER_MYCO]
			 WHEN [INF_SEPSIS_CODE_2] = 'NO' THEN [INF_SEPSIS_CODE_2_DEC] + ' - ' + [INF_SEPSIS_OTHER_OPP]
		ELSE [INF_SEPSIS_CODE_2_DEC] END
		) AS [INF_SEPSIS_CODE_2_DEC]
      ,[INF_SEPSIS_CODE_3]
      ,(CASE WHEN [INF_SEPSIS_CODE_3] IS NULL THEN NULL
			 WHEN [INF_SEPSIS_CODE_3] = 'OO' THEN [INF_SEPSIS_CODE_3_DEC] + ' - ' + [INF_SEPSIS_OTHER_MYCO]
			 WHEN [INF_SEPSIS_CODE_3] = 'NO' THEN [INF_SEPSIS_CODE_3_DEC] + ' - ' + [INF_SEPSIS_OTHER_OPP]
		ELSE [INF_SEPSIS_CODE_3_DEC] END
		) AS [INF_SEPSIS_CODE_3_DEC]
      ,[INF_SEPSIS_OTHER_MYCO]
      ,[INF_SEPSIS_OTHER_OPP]
      ,[SER_INF_SEPSIS]
      ,[IV_SEPSIS]
      ,[INF_PNEUMONIA]
      ,[INF_PNEUMONIA_DT_DY]
      ,[INF_PNEUMONIA_DT_DY_DEC]
      ,[INF_PNEUMONIA_DT_MO]
      ,[INF_PNEUMONIA_DT_MO_DEC]
      ,[INF_PNEUMONIA_DT_YR]
      ,[INF_PNEUMONIA_DT_YR_DEC]
      ,[INF_PNEUMONIA_CODE_1]
      ,(CASE WHEN [INF_PNEUMONIA_CODE_1] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE_1] = 'OO' THEN [INF_PNEUMONIA_CODE_1_DEC] + ' - ' + [INF_PNEUMONIA_OTHER_MYCO]
			 WHEN [INF_PNEUMONIA_CODE_1] = 'NO' THEN [INF_PNEUMONIA_CODE_1_DEC] + ' - ' + [INF_PNEUMONIA_OTHER_OPP]
		ELSE [INF_PNEUMONIA_CODE_1_DEC] END
		) AS [INF_PNEUMONIA_CODE_1_DEC]
      ,[INF_PNEUMONIA_CODE_2]
      ,(CASE WHEN [INF_PNEUMONIA_CODE_2] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE_2] = 'OO' THEN [INF_PNEUMONIA_CODE_2_DEC] + ' - ' + [INF_PNEUMONIA_OTHER_MYCO]
			 WHEN [INF_PNEUMONIA_CODE_2] = 'NO' THEN [INF_PNEUMONIA_CODE_2_DEC] + ' - ' + [INF_PNEUMONIA_OTHER_OPP]
		ELSE [INF_PNEUMONIA_CODE_2_DEC] END
		) AS [INF_PNEUMONIA_CODE_2_DEC]
      ,[INF_PNEUMONIA_CODE_3]
      ,(CASE WHEN [INF_PNEUMONIA_CODE_3] IS NULL THEN NULL
			 WHEN [INF_PNEUMONIA_CODE_3] = 'OO' THEN [INF_PNEUMONIA_CODE_3_DEC] + ' - ' + [INF_PNEUMONIA_OTHER_MYCO]
			 WHEN [INF_PNEUMONIA_CODE_3] = 'NO' THEN [INF_PNEUMONIA_CODE_3_DEC] + ' - ' + [INF_PNEUMONIA_OTHER_OPP]
		ELSE [INF_PNEUMONIA_CODE_3_DEC] END
		) AS [INF_PNEUMONIA_CODE_3_DEC]
      ,[INF_PNEUMONIA_OTHER_MYCO]
      ,[INF_PNEUMONIA_OTHER_OPP]
      ,[SER_INF_PNEUMONIA]
      ,[IV_PNEUMONIA]
      ,[INF_BRONCH]
      ,[INF_BRONCH_DT_DY]
      ,[INF_BRONCH_DT_DY_DEC]
      ,[INF_BRONCH_DT_MO]
      ,[INF_BRONCH_DT_MO_DEC]
      ,[INF_BRONCH_DT_YR]
      ,[INF_BRONCH_DT_YR_DEC]
      ,[INF_BRONCH_CODE_1]
      ,(CASE WHEN [INF_BRONCH_CODE_1] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE_1] = 'OO' THEN [INF_BRONCH_CODE_1_DEC] + ' - ' + [INF_BRONCH_OTHER_MYCO]
			 WHEN [INF_BRONCH_CODE_1] = 'NO' THEN [INF_BRONCH_CODE_1_DEC] + ' - ' + [INF_BRONCH_OTHER_OPP]
		ELSE [INF_JOINT_BURSA_CODE_1_DEC] END
		) AS [INF_BRONCH_CODE_1_DEC]
      ,[INF_BRONCH_CODE_2]
      ,(CASE WHEN [INF_BRONCH_CODE_2] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE_2] = 'OO' THEN [INF_BRONCH_CODE_2_DEC] + ' - ' + [INF_BRONCH_OTHER_MYCO]
			 WHEN [INF_BRONCH_CODE_2] = 'NO' THEN [INF_BRONCH_CODE_2_DEC] + ' - ' + [INF_BRONCH_OTHER_OPP]
		ELSE [INF_JOINT_BURSA_CODE_2_DEC] END
		) AS [INF_BRONCH_CODE_2_DEC]
      ,[INF_BRONCH_CODE_3]
      ,(CASE WHEN [INF_BRONCH_CODE_3] IS NULL THEN NULL
			 WHEN [INF_BRONCH_CODE_3] = 'OO' THEN [INF_BRONCH_CODE_3_DEC] + ' - ' + [INF_BRONCH_OTHER_MYCO]
			 WHEN [INF_BRONCH_CODE_3] = 'NO' THEN [INF_BRONCH_CODE_3_DEC] + ' - ' + [INF_BRONCH_OTHER_OPP]
		ELSE [INF_JOINT_BURSA_CODE_3_DEC] END
		) AS [INF_BRONCH_CODE_3_DEC]
      ,[INF_BRONCH_OTHER_MYCO]
      ,[INF_BRONCH_OTHER_OPP]
      ,[SER_INF_BRONCH]
      ,[IV_BRONCH]
      ,[INF_GASTRO]
      ,[INF_GASTRO_DT_DY]
      ,[INF_GASTRO_DT_DY_DEC]
      ,[INF_GASTRO_DT_MO]
      ,[INF_GASTRO_DT_MO_DEC]
      ,[INF_GASTRO_DT_YR]
      ,[INF_GASTRO_DT_YR_DEC]
      ,[INF_GASTRO_CODE_1]
      ,(CASE WHEN [INF_GASTRO_CODE_1] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE_1] = 'OO' THEN [INF_GASTRO_CODE_1_DEC] + ' - ' + [INF_GASTRO_OTHER_MYCO]
			 WHEN [INF_GASTRO_CODE_1] = 'NO' THEN [INF_GASTRO_CODE_1_DEC] + ' - ' + [INF_GASTRO_OTHER_OPP]
		ELSE [INF_GASTRO_CODE_1_DEC] END
		) AS [INF_GASTRO_CODE_1_DEC]
      ,[INF_GASTRO_CODE_2]
      ,(CASE WHEN [INF_GASTRO_CODE_2] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE_2] = 'OO' THEN [INF_GASTRO_CODE_2_DEC] + ' - ' + [INF_GASTRO_OTHER_MYCO]
			 WHEN [INF_GASTRO_CODE_2] = 'NO' THEN [INF_GASTRO_CODE_2_DEC] + ' - ' + [INF_GASTRO_OTHER_OPP]
		ELSE [INF_GASTRO_CODE_2_DEC] END
		) AS [INF_GASTRO_CODE_2_DEC]
      ,[INF_GASTRO_CODE_3]
      ,(CASE WHEN [INF_GASTRO_CODE_3] IS NULL THEN NULL
			 WHEN [INF_GASTRO_CODE_3] = 'OO' THEN [INF_GASTRO_CODE_3_DEC] + ' - ' + [INF_GASTRO_OTHER_MYCO]
			 WHEN [INF_GASTRO_CODE_3] = 'NO' THEN [INF_GASTRO_CODE_3_DEC] + ' - ' + [INF_GASTRO_OTHER_OPP]
		ELSE [INF_GASTRO_CODE_3_DEC] END
		) AS [INF_GASTRO_CODE_3_DEC]
      ,[INF_GASTRO_OTHER_MYCO]
      ,[INF_GASTRO_OTHER_OPP]
      ,[SER_INF_GASTRO]
      ,[IV_GASTRO]
      ,[INF_MENING]
      ,[INF_MENING_DT_DY]
      ,[INF_MENING_DT_DY_DEC]
      ,[INF_MENING_DT_MO]
      ,[INF_MENING_DT_MO_DEC]
      ,[INF_MENING_DT_YR]
      ,[INF_MENING_DT_YR_DEC]
      ,[INF_MENING_CODE_1]
      ,(CASE WHEN [INF_MENING_CODE_1] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE_1] = 'OO' THEN [INF_MENING_CODE_1_DEC] + ' - ' + [INF_MENING_OTHER_MYCO]
			 WHEN [INF_MENING_CODE_1] = 'NO' THEN [INF_MENING_CODE_1_DEC] + ' - ' + [INF_MENING_OTHER_OPP]
		ELSE [INF_MENING_CODE_1_DEC] END
		) AS [INF_MENING_CODE_1_DEC]
      ,[INF_MENING_CODE_2]
      ,(CASE WHEN [INF_MENING_CODE_2] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE_2] = 'OO' THEN [INF_MENING_CODE_2_DEC] + ' - ' + [INF_MENING_OTHER_MYCO]
			 WHEN [INF_MENING_CODE_2] = 'NO' THEN [INF_MENING_CODE_2_DEC] + ' - ' + [INF_MENING_OTHER_OPP]
		ELSE [INF_MENING_CODE_2_DEC] END
		) AS [INF_MENING_CODE_2_DEC]
      ,[INF_MENING_CODE_3]
      ,(CASE WHEN [INF_MENING_CODE_3] IS NULL THEN NULL
			 WHEN [INF_MENING_CODE_3] = 'OO' THEN [INF_MENING_CODE_3_DEC] + ' - ' + [INF_MENING_OTHER_MYCO]
			 WHEN [INF_MENING_CODE_3] = 'NO' THEN [INF_MENING_CODE_3_DEC] + ' - ' + [INF_MENING_OTHER_OPP]
		ELSE [INF_MENING_CODE_3_DEC] END
		) AS [INF_MENING_CODE_3_DEC]
      ,[INF_MENING_OTHER_MYCO]
      ,[INF_MENING_OTHER_OPP]
      ,[SER_INF_MENING]
      ,[IV_MENING]
      ,[INF_UTI]
      ,[INF_UTI_DT_DY]
      ,[INF_UTI_DT_DY_DEC]
      ,[INF_UTI_DT_MO]
      ,[INF_UTI_DT_MO_DEC]
      ,[INF_UTI_DT_YR]
      ,[INF_UTI_DT_YR_DEC]
      ,[INF_UTI_CODE_1]
      ,(CASE WHEN [INF_UTI_CODE_1] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE_1] = 'OO' THEN [INF_UTI_CODE_1_DEC] + ' - ' + [INF_UTI_OTHER_MYCO]
			 WHEN [INF_UTI_CODE_1] = 'NO' THEN [INF_UTI_CODE_1_DEC] + ' - ' + [INF_UTI_OTHER_OPP]
		ELSE [INF_UTI_CODE_1_DEC] END
		) AS [INF_UTI_CODE_1_DEC]
      ,[INF_UTI_CODE_2]
      ,(CASE WHEN [INF_UTI_CODE_2] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE_2] = 'OO' THEN [INF_UTI_CODE_2_DEC] + ' - ' + [INF_UTI_OTHER_MYCO]
			 WHEN [INF_UTI_CODE_2] = 'NO' THEN [INF_UTI_CODE_2_DEC] + ' - ' + [INF_UTI_OTHER_OPP]
		ELSE [INF_UTI_CODE_2_DEC] END
		) AS [INF_UTI_CODE_2_DEC]
      ,[INF_UTI_CODE_3]
      ,(CASE WHEN [INF_UTI_CODE_3] IS NULL THEN NULL
			 WHEN [INF_UTI_CODE_3] = 'OO' THEN [INF_UTI_CODE_3_DEC] + ' - ' + [INF_UTI_OTHER_MYCO]
			 WHEN [INF_UTI_CODE_3] = 'NO' THEN [INF_UTI_CODE_3_DEC] + ' - ' + [INF_UTI_OTHER_OPP]
		ELSE [INF_UTI_CODE_3_DEC] END
		) AS [INF_UTI_CODE_3_DEC]
      ,[INF_UTI_OTHER_MYCO]
      ,[INF_UTI_OTHER_OPP]
      ,[SER_INF_UTI]
      ,[IV_UTI]
      ,[INF_URI]
      ,[INF_URI_DT_DY]
      ,[INF_URI_DT_DY_DEC]
      ,[INF_URI_DT_MO]
      ,[INF_URI_DT_MO_DEC]
      ,[INF_URI_DT_YR]
      ,[INF_URI_DT_YR_DEC]
      ,[INF_URI_CODE_1]
      ,(CASE WHEN [INF_URI_CODE_1] IS NULL THEN NULL
			 WHEN [INF_URI_CODE_1] = 'OO' THEN [INF_URI_CODE_1_DEC] + ' - ' + [INF_URI_OTHER_MYCO]
			 WHEN [INF_URI_CODE_1] = 'NO' THEN [INF_URI_CODE_1_DEC] + ' - ' + [INF_URI_OTHER_OPP]
		ELSE [INF_URI_CODE_1_DEC] END
		) AS [INF_URI_CODE_1_DEC]
      ,[INF_URI_CODE_2]
      ,(CASE WHEN [INF_URI_CODE_1] IS NULL THEN NULL
			 WHEN [INF_URI_CODE_1] = 'OO' THEN [INF_URI_CODE_1_DEC] + ' - ' + [INF_URI_OTHER_MYCO]
			 WHEN [INF_URI_CODE_1] = 'NO' THEN [INF_URI_CODE_1_DEC] + ' - ' + [INF_URI_OTHER_OPP]
		ELSE [INF_URI_CODE_1_DEC] END
		) AS [INF_URI_CODE_2_DEC]
      ,[INF_URI_CODE_3]
      ,(CASE WHEN [INF_URI_CODE_3] IS NULL THEN NULL
			 WHEN [INF_URI_CODE_3] = 'OO' THEN [INF_URI_CODE_3_DEC] + ' - ' + [INF_URI_OTHER_MYCO]
			 WHEN [INF_URI_CODE_3] = 'NO' THEN [INF_URI_CODE_3_DEC] + ' - ' + [INF_URI_OTHER_OPP]
		ELSE [INF_URI_CODE_3_DEC] END
		) AS [INF_URI_CODE_3_DEC]
      ,[INF_URI_OTHER_MYCO]
      ,[INF_URI_OTHER_OPP]
      ,[SER_INF_URI]
      ,[IV_URI]
      ,[INF_TB]
      ,[INF_TB_STATUS]
      ,[INF_TB_STATUS_DEC]
      ,[INF_TB_SPECIFY]
      ,[INF_TB_DT_DY]
      ,[INF_TB_DT_DY_DEC]
      ,[INF_TB_DT_MO]
      ,[INF_TB_DT_MO_DEC]
      ,[INF_TB_DT_YR]
      ,[INF_TB_DT_YR_DEC]
      ,[INF_TB_CODE_1]
      ,(CASE WHEN [INF_TB_CODE_1] IS NULL THEN NULL
			 WHEN [INF_TB_CODE_1] = 'OO' THEN [INF_TB_CODE_1_DEC] + ' - ' + [INF_TB_OTHER_MYCO]
			 WHEN [INF_TB_CODE_1] = 'NO' THEN [INF_TB_CODE_1_DEC] + ' - ' + [INF_TB_OTHER_OPP]
		ELSE [INF_TB_CODE_1_DEC] END
		) AS [INF_TB_CODE_1_DEC]
      ,[INF_TB_CODE_2]
      ,(CASE WHEN [INF_TB_CODE_2] IS NULL THEN NULL
			 WHEN [INF_TB_CODE_2] = 'OO' THEN [INF_TB_CODE_2_DEC] + ' - ' + [INF_TB_OTHER_MYCO]
			 WHEN [INF_TB_CODE_2] = 'NO' THEN [INF_TB_CODE_2_DEC] + ' - ' + [INF_TB_OTHER_OPP]
		ELSE [INF_TB_CODE_2_DEC] END
		) AS [INF_TB_CODE_2_DEC]
      ,[INF_TB_CODE_3]
      ,(CASE WHEN [INF_TB_CODE_3] IS NULL THEN NULL
			 WHEN [INF_TB_CODE_3] = 'OO' THEN [INF_TB_CODE_3_DEC] + ' - ' + [INF_TB_OTHER_MYCO]
			 WHEN [INF_TB_CODE_3] = 'NO' THEN [INF_TB_CODE_3_DEC] + ' - ' + [INF_TB_OTHER_OPP]
		ELSE [INF_TB_CODE_3_DEC] END
		) AS [INF_TB_CODE_3_DEC]
      ,[INF_TB_OTHER_MYCO]
      ,[INF_TB_OTHER_OPP]
      ,[SER_INF_TB]
      ,[IV_TB]
      ,[INF_OTHER]
      ,[INF_OTHER_SPECIFY]
      ,[INF_OTHER_DT_DY]
      ,[INF_OTHER_DT_DY_DEC]
      ,[INF_OTHER_DT_MO]
      ,[INF_OTHER_DT_MO_DEC]
      ,[INF_OTHER_DT_YR]
      ,[INF_OTHER_DT_YR_DEC]
      ,[INF_OTHER_CODE_1]
      ,(CASE WHEN [INF_OTHER_CODE_1] IS NULL THEN NULL
			 WHEN [INF_OTHER_CODE_1] = 'OO' THEN [INF_OTHER_CODE_1_DEC] + ' - ' + [INF_OTHER_OTHER_MYCO]
			 WHEN [INF_OTHER_CODE_1] = 'NO' THEN [INF_OTHER_CODE_1_DEC] + ' - ' + [INF_OTHER_OTHER_OPP]
		ELSE [INF_OTHER_CODE_1_DEC] END
		) AS [INF_OTHER_CODE_1_DEC]
      ,[INF_OTHER_CODE_2]
      ,[INF_OTHER_CODE_2_DEC]
      ,[INF_OTHER_CODE_3]
      ,[INF_OTHER_CODE_3_DEC]
      ,[INF_OTHER_OTHER_MYCO]
      ,[INF_OTHER_OTHER_OPP]
      ,[SER_INF_OTHER]
      ,[IV_OTHER]
      ,[ANY_EVENT_NONE]
      ,[ANY_EVENT_LIFE_THREAT]
      ,[ANY_EVENT_HOSP]
      ,[ANY_EVENT_PERSISTENT]
      ,[ANY_EVENT_BIRTH_DEF]
      ,[ANY_EVENT_IMP_MED_EVENT]
      ,[ANY_EVENT_DATE1]
      ,[ANY_EVENT_DATE2]
      ,[ANY_EVENT_DATE3]
      ,[DELETED]
      INTO [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
  FROM [MERGE_SpA].[staging].[FPRO_03]
	WHERE
	[INF_JOINT_BURSA] = 'X' 
	 OR [INF_CELLULITIS] = 'X'
	 OR [INF_SINUSITIS] = 'X' 
	 OR [INF_CANDIDA] = 'X'
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
		 
	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_JOINT_BURSA] = NULL
	, [INF_JOINT_BURSA_DT_MO] = NULL
	, [INF_JOINT_BURSA_DT_YR] = NULL
	 WHERE [IV_JOINT_BURSA] = 'X'-- OR [SER_JOIN_BURSA] = 'X'
	 
	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_CELLULITIS] = NULL
	, [INF_CELLULITIS_DT_MO] = NULL
	, [INF_CELLULITIS_DT_YR] = NULL
	WHERE [SER_INF_CELLULITIS] = 'X' OR [IV_CELLULITIS] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_SINUSITIS]= NULL
	, [INF_SINUSITIS_DT_MO]= NULL
	, [INF_SINUSITIS_DT_YR]= NULL
	WHERE [SER_INF_SINUSITIS] = 'X' OR [IV_SINUSITIS] = 'X'


	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_CANDIDA]= NULL
	, [INF_CANDIDA_DT_MO]= NULL
	, [INF_CANDIDA_DT_YR]= NULL
	WHERE [SER_INF_CANDIDA] = 'X' OR [IV_CANDIDA] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_DIV]= NULL
	, [INF_DIV_DT_MO]= NULL
	, [INF_DIV_DT_YR]= NULL
	WHERE [SER_INF_DIV] = 'X' OR [IV_DIV] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_SEPSIS]= NULL
	, [INF_SEPSIS_DT_MO]= NULL
	, [INF_SEPSIS_DT_YR]= NULL
	WHERE [SER_INF_SEPSIS] = 'X' OR [IV_SEPSIS] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_PNEUMONIA]= NULL
	, [INF_PNEUMONIA_DT_MO]= NULL
	, [INF_PNEUMONIA_DT_YR]= NULL
	WHERE [SER_INF_PNEUMONIA] = 'X' OR [IV_PNEUMONIA] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_BRONCH]= NULL
	, [INF_BRONCH_DT_MO]= NULL
	, [INF_BRONCH_DT_YR]= NULL
	WHERE [SER_INF_BRONCH] = 'X' OR [IV_BRONCH] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_GASTRO]= NULL
	, [INF_GASTRO_DT_MO]= NULL
	, [INF_GASTRO_DT_YR]= NULL
	WHERE [SER_INF_GASTRO] = 'X' OR [IV_GASTRO] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_MENING]= NULL
	, [INF_MENING_DT_MO]= NULL
	, [INF_MENING_DT_YR]= NULL
	WHERE [SER_INF_MENING] = 'X' OR [IV_MENING] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_UTI]= NULL
	, [INF_UTI_DT_MO]= NULL
	, [INF_UTI_DT_YR]= NULL
	WHERE [SER_INF_UTI] = 'X' OR [IV_UTI] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_URI]= NULL
	, [INF_URI_DT_MO]= NULL
	, [INF_URI_DT_YR]= NULL
	WHERE [SER_INF_URI] = 'X' OR [IV_URI] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_TB]= NULL
	, [INF_TB_DT_MO]= NULL
	, [INF_TB_DT_YR]= NULL
	WHERE [SER_INF_TB] = 'X' OR [IV_TB] = 'X'

	UPDATE [Reporting].[PSA400].[t_pv_FPRO_03_SAE]
	SET [INF_OTHER]= NULL
	, [INF_OTHER_SPECIFY]= NULL
	, [INF_OTHER_DT_MO]= NULL
	, [INF_OTHER_DT_YR]= NULL
	WHERE [SER_INF_OTHER] = 'X' OR [IV_OTHER] = 'X'

END







GO
