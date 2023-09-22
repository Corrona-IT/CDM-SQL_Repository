USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_pv_EP_04_SAE]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_pv_EP_04_SAE](
	[vID] [bigint] NULL,
	[SITENUM] [bigint] NULL,
	[SUBID] [bigint] NOT NULL,
	[SUBNUM] [nvarchar](100) NULL,
	[VISNAME] [nvarchar](100) NULL,
	[PAGENAME] [nvarchar](100) NULL,
	[VISITID] [int] NOT NULL,
	[VISITSEQ] [smallint] NOT NULL,
	[PAGEID] [int] NOT NULL,
	[PAGESEQ] [smallint] NOT NULL,
	[STATUSID] [int] NULL,
	[STATUSID_DEC] [nvarchar](18) NULL,
	[PAGELMBY] [nvarchar](200) NULL,
	[PAGELMDT] [datetime] NULL,
	[DATALMBY] [nvarchar](200) NULL,
	[DATALMDT] [datetime] NULL,
	[INF_NONE] [nvarchar](1) NULL,
	[INF_JOINT_BURSA] [nvarchar](1) NULL,
	[INF_JOINT_BURSA_DT] [tinyint] NULL,
	[INF_JOINT_BURSA_CODE] [nvarchar](2) NULL,
	[INF_JOINT_BURSA_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_JOINT_BURSA] [nvarchar](1) NULL,
	[IV_JOINT_BURSA] [nvarchar](1) NULL,
	[INF_CELLULITIS] [nvarchar](1) NULL,
	[INF_CELLULITIS_DT] [tinyint] NULL,
	[INF_CELLULITIS_CODE] [nvarchar](2) NULL,
	[INF_CELLULITIS_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_CELLULITIS] [nvarchar](1) NULL,
	[IV_CELLULITIS] [nvarchar](1) NULL,
	[INF_SINUSITIS] [nvarchar](1) NULL,
	[INF_SINUSITIS_DT] [tinyint] NULL,
	[INF_SINUSITIS_CODE] [nvarchar](2) NULL,
	[INF_SINUSITIS_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_SINUSITIS] [nvarchar](1) NULL,
	[IV_SINUSITIS] [nvarchar](1) NULL,
	[INF_DIV] [nvarchar](1) NULL,
	[INF_DIV_DT] [tinyint] NULL,
	[INF_DIV_CODE] [nvarchar](2) NULL,
	[INF_DIV_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_DIV] [nvarchar](1) NULL,
	[IV_DIV] [nvarchar](1) NULL,
	[INF_SEPSIS] [nvarchar](1) NULL,
	[INF_SEPSIS_DT] [tinyint] NULL,
	[INF_SEPSIS_CODE] [nvarchar](2) NULL,
	[INF_SEPSIS_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_SEPSIS] [nvarchar](1) NULL,
	[IV_SEPSIS] [nvarchar](1) NULL,
	[INF_PNEUMONIA] [nvarchar](1) NULL,
	[INF_PNEUMONIA_DT] [tinyint] NULL,
	[INF_PNEUMONIA_CODE] [nvarchar](2) NULL,
	[INF_PNEUMONIA_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_PNEUMONIA] [nvarchar](1) NULL,
	[IV_PNEUMONIA] [nvarchar](1) NULL,
	[INF_BRONCH] [nvarchar](1) NULL,
	[INF_BRONCH_DT] [tinyint] NULL,
	[INF_BRONCH_CODE] [nvarchar](2) NULL,
	[INF_BRONCH_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_BRONCH] [nvarchar](1) NULL,
	[IV_BRONCH] [nvarchar](1) NULL,
	[INF_GASTRO] [nvarchar](1) NULL,
	[INF_GASTRO_DT] [tinyint] NULL,
	[INF_GASTRO_CODE] [nvarchar](2) NULL,
	[INF_GASTRO_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_GASTRO] [nvarchar](1) NULL,
	[IV_GASTRO] [nvarchar](1) NULL,
	[INF_MENING] [nvarchar](1) NULL,
	[INF_MENING_DT] [tinyint] NULL,
	[INF_MENING_CODE] [nvarchar](2) NULL,
	[INF_MENING_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_MENING] [nvarchar](1) NULL,
	[IV_MENING] [nvarchar](1) NULL,
	[INF_UTI] [nvarchar](1) NULL,
	[INF_UTI_DT] [tinyint] NULL,
	[INF_UTI_CODE] [nvarchar](2) NULL,
	[INF_UTI_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_UTI] [nvarchar](1) NULL,
	[IV_UTI] [nvarchar](1) NULL,
	[INF_TB] [nvarchar](1) NULL,
	[INF_TB_SPECIFY] [nvarchar](50) NULL,
	[INF_TB_DT] [tinyint] NULL,
	[INF_TB_CODE] [nvarchar](2) NULL,
	[INF_TB_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_TB] [nvarchar](1) NULL,
	[IV_TB] [nvarchar](1) NULL,
	[INF_TB_STATUS] [smallint] NULL,
	[INF_TB_STATUS_DEC] [nvarchar](6) NULL,
	[INF_OTHER] [nvarchar](1) NULL,
	[INF_OTHER_SPECIFY] [nvarchar](50) NULL,
	[INF_OTHER_DT] [tinyint] NULL,
	[INF_OTHER_CODE] [nvarchar](2) NULL,
	[INF_OTHER_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_OTHER] [nvarchar](1) NULL,
	[IV_OTHER] [nvarchar](1) NULL,
	[INF_X_NO_MICROB] [nvarchar](50) NULL,
	[INF_X_OO_MICROB] [nvarchar](50) NULL,
	[INF_JOINT_BURSA_DT_MO] [smallint] NULL,
	[INF_JOINT_BURSA_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_JOINT_BURSA_DT_YR] [smallint] NULL,
	[INF_CELLULITIS_DT_MO] [smallint] NULL,
	[INF_CELLULITIS_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_CELLULITIS_DT_YR] [smallint] NULL,
	[INF_SINUSITIS_DT_MO] [smallint] NULL,
	[INF_SINUSITIS_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_SINUSITIS_DT_YR] [smallint] NULL,
	[INF_DIV_DT_MO] [smallint] NULL,
	[INF_DIV_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_DIV_DT_YR] [smallint] NULL,
	[INF_SEPSIS_DT_MO] [smallint] NULL,
	[INF_SEPSIS_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_SEPSIS_DT_YR] [smallint] NULL,
	[INF_PNEUMONIA_DT_MO] [smallint] NULL,
	[INF_PNEUMONIA_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_PNEUMONIA_DT_YR] [smallint] NULL,
	[INF_BRONCH_DT_MO] [smallint] NULL,
	[INF_BRONCH_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_BRONCH_DT_YR] [smallint] NULL,
	[INF_GASTRO_DT_MO] [smallint] NULL,
	[INF_GASTRO_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_GASTRO_DT_YR] [smallint] NULL,
	[INF_MENING_DT_MO] [smallint] NULL,
	[INF_MENING_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_MENING_DT_YR] [smallint] NULL,
	[INF_UTI_DT_MO] [smallint] NULL,
	[INF_UTI_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_UTI_DT_YR] [smallint] NULL,
	[INF_URI] [nvarchar](1) NULL,
	[INF_URI_DT_MO] [smallint] NULL,
	[INF_URI_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_URI_DT_YR] [smallint] NULL,
	[INF_URI_CODE] [nvarchar](2) NULL,
	[INF_URI_CODE_DEC] [nvarchar](83) NULL,
	[HOSP_INF_URI] [nvarchar](1) NULL,
	[IV_URI] [nvarchar](1) NULL,
	[INF_TB_DT_MO] [smallint] NULL,
	[INF_TB_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_TB_DT_YR] [smallint] NULL,
	[INF_OTHER_DT_MO] [smallint] NULL,
	[INF_OTHER_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_OTHER_DT_YR] [smallint] NULL,
	[DELETED] [nvarchar](1) NULL
) ON [PRIMARY]
GO
