USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_pv_FPRO_03_SAE]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_pv_FPRO_03_SAE](
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
	[INF_JOINT_BURSA_DT_DY] [smallint] NULL,
	[INF_JOINT_BURSA_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_JOINT_BURSA_DT_MO] [smallint] NULL,
	[INF_JOINT_BURSA_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_JOINT_BURSA_DT_YR] [smallint] NULL,
	[INF_JOINT_BURSA_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_JOINT_BURSA_CODE_1] [nvarchar](2) NULL,
	[INF_JOINT_BURSA_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_JOINT_BURSA_CODE_2] [nvarchar](2) NULL,
	[INF_JOINT_BURSA_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_JOINT_BURSA_CODE_3] [nvarchar](2) NULL,
	[INF_JOINT_BURSA_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_JOINT_BURSA_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_JOINT_BURSA_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_JOINT_BURSA] [nvarchar](1) NULL,
	[IV_JOINT_BURSA] [nvarchar](1) NULL,
	[INF_CELLULITIS] [nvarchar](1) NULL,
	[INF_CELLULITIS_DT_DY] [smallint] NULL,
	[INF_CELLULITIS_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_CELLULITIS_DT_MO] [smallint] NULL,
	[INF_CELLULITIS_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_CELLULITIS_DT_YR] [smallint] NULL,
	[INF_CELLULITIS_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_CELLULITIS_CODE_1] [nvarchar](2) NULL,
	[INF_CELLULITIS_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_CELLULITIS_CODE_2] [nvarchar](2) NULL,
	[INF_CELLULITIS_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_CELLULITIS_CODE_3] [nvarchar](2) NULL,
	[INF_CELLULITIS_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_CELLULITIS_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_CELLULITIS_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_CELLULITIS] [nvarchar](1) NULL,
	[IV_CELLULITIS] [nvarchar](1) NULL,
	[INF_SINUSITIS] [nvarchar](1) NULL,
	[INF_SINUSITIS_DT_DY] [smallint] NULL,
	[INF_SINUSITIS_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_SINUSITIS_DT_MO] [smallint] NULL,
	[INF_SINUSITIS_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_SINUSITIS_DT_YR] [smallint] NULL,
	[INF_SINUSITIS_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_SINUSITIS_CODE_1] [nvarchar](2) NULL,
	[INF_SINUSITIS_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_SINUSITIS_CODE_2] [nvarchar](2) NULL,
	[INF_SINUSITIS_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_SINUSITIS_CODE_3] [nvarchar](2) NULL,
	[INF_SINUSITIS_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_SINUSITIS_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_SINUSITIS_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_SINUSITIS] [nvarchar](1) NULL,
	[IV_SINUSITIS] [nvarchar](1) NULL,
	[INF_CANDIDA] [nvarchar](1) NULL,
	[INF_CANDIDA_TYPE] [smallint] NULL,
	[INF_CANDIDA_TYPE_DEC] [nvarchar](20) NULL,
	[INF_CANDIDA_DT_DY] [smallint] NULL,
	[INF_CANDIDA_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_CANDIDA_DT_MO] [smallint] NULL,
	[INF_CANDIDA_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_CANDIDA_DT_YR] [smallint] NULL,
	[INF_CANDIDA_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_CANDIDA_CODE_1] [nvarchar](2) NULL,
	[INF_CANDIDA_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_CANDIDA_CODE_2] [nvarchar](2) NULL,
	[INF_CANDIDA_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_CANDIDA_CODE_3] [nvarchar](2) NULL,
	[INF_CANDIDA_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_CANDIDA_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_CANDIDA_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_CANDIDA] [nvarchar](1) NULL,
	[IV_CANDIDA] [nvarchar](1) NULL,
	[INF_DIV] [nvarchar](1) NULL,
	[INF_DIV_DT_DY] [smallint] NULL,
	[INF_DIV_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_DIV_DT_MO] [smallint] NULL,
	[INF_DIV_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_DIV_DT_YR] [smallint] NULL,
	[INF_DIV_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_DIV_CODE_1] [nvarchar](2) NULL,
	[INF_DIV_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_DIV_CODE_2] [nvarchar](2) NULL,
	[INF_DIV_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_DIV_CODE_3] [nvarchar](2) NULL,
	[INF_DIV_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_DIV_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_DIV_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_DIV] [nvarchar](1) NULL,
	[IV_DIV] [nvarchar](1) NULL,
	[INF_SEPSIS] [nvarchar](1) NULL,
	[INF_SEPSIS_DT_DY] [smallint] NULL,
	[INF_SEPSIS_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_SEPSIS_DT_MO] [smallint] NULL,
	[INF_SEPSIS_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_SEPSIS_DT_YR] [smallint] NULL,
	[INF_SEPSIS_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_SEPSIS_CODE_1] [nvarchar](2) NULL,
	[INF_SEPSIS_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_SEPSIS_CODE_2] [nvarchar](2) NULL,
	[INF_SEPSIS_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_SEPSIS_CODE_3] [nvarchar](2) NULL,
	[INF_SEPSIS_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_SEPSIS_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_SEPSIS_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_SEPSIS] [nvarchar](1) NULL,
	[IV_SEPSIS] [nvarchar](1) NULL,
	[INF_PNEUMONIA] [nvarchar](1) NULL,
	[INF_PNEUMONIA_DT_DY] [smallint] NULL,
	[INF_PNEUMONIA_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_PNEUMONIA_DT_MO] [smallint] NULL,
	[INF_PNEUMONIA_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_PNEUMONIA_DT_YR] [smallint] NULL,
	[INF_PNEUMONIA_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_PNEUMONIA_CODE_1] [nvarchar](2) NULL,
	[INF_PNEUMONIA_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_PNEUMONIA_CODE_2] [nvarchar](2) NULL,
	[INF_PNEUMONIA_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_PNEUMONIA_CODE_3] [nvarchar](2) NULL,
	[INF_PNEUMONIA_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_PNEUMONIA_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_PNEUMONIA_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_PNEUMONIA] [nvarchar](1) NULL,
	[IV_PNEUMONIA] [nvarchar](1) NULL,
	[INF_BRONCH] [nvarchar](1) NULL,
	[INF_BRONCH_DT_DY] [smallint] NULL,
	[INF_BRONCH_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_BRONCH_DT_MO] [smallint] NULL,
	[INF_BRONCH_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_BRONCH_DT_YR] [smallint] NULL,
	[INF_BRONCH_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_BRONCH_CODE_1] [nvarchar](2) NULL,
	[INF_BRONCH_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_BRONCH_CODE_2] [nvarchar](2) NULL,
	[INF_BRONCH_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_BRONCH_CODE_3] [nvarchar](2) NULL,
	[INF_BRONCH_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_BRONCH_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_BRONCH_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_BRONCH] [nvarchar](1) NULL,
	[IV_BRONCH] [nvarchar](1) NULL,
	[INF_GASTRO] [nvarchar](1) NULL,
	[INF_GASTRO_DT_DY] [smallint] NULL,
	[INF_GASTRO_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_GASTRO_DT_MO] [smallint] NULL,
	[INF_GASTRO_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_GASTRO_DT_YR] [smallint] NULL,
	[INF_GASTRO_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_GASTRO_CODE_1] [nvarchar](2) NULL,
	[INF_GASTRO_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_GASTRO_CODE_2] [nvarchar](2) NULL,
	[INF_GASTRO_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_GASTRO_CODE_3] [nvarchar](2) NULL,
	[INF_GASTRO_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_GASTRO_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_GASTRO_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_GASTRO] [nvarchar](1) NULL,
	[IV_GASTRO] [nvarchar](1) NULL,
	[INF_MENING] [nvarchar](1) NULL,
	[INF_MENING_DT_DY] [smallint] NULL,
	[INF_MENING_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_MENING_DT_MO] [smallint] NULL,
	[INF_MENING_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_MENING_DT_YR] [smallint] NULL,
	[INF_MENING_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_MENING_CODE_1] [nvarchar](2) NULL,
	[INF_MENING_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_MENING_CODE_2] [nvarchar](2) NULL,
	[INF_MENING_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_MENING_CODE_3] [nvarchar](2) NULL,
	[INF_MENING_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_MENING_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_MENING_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_MENING] [nvarchar](1) NULL,
	[IV_MENING] [nvarchar](1) NULL,
	[INF_UTI] [nvarchar](1) NULL,
	[INF_UTI_DT_DY] [smallint] NULL,
	[INF_UTI_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_UTI_DT_MO] [smallint] NULL,
	[INF_UTI_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_UTI_DT_YR] [smallint] NULL,
	[INF_UTI_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_UTI_CODE_1] [nvarchar](2) NULL,
	[INF_UTI_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_UTI_CODE_2] [nvarchar](2) NULL,
	[INF_UTI_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_UTI_CODE_3] [nvarchar](2) NULL,
	[INF_UTI_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_UTI_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_UTI_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_UTI] [nvarchar](1) NULL,
	[IV_UTI] [nvarchar](1) NULL,
	[INF_URI] [nvarchar](1) NULL,
	[INF_URI_DT_DY] [smallint] NULL,
	[INF_URI_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_URI_DT_MO] [smallint] NULL,
	[INF_URI_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_URI_DT_YR] [smallint] NULL,
	[INF_URI_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_URI_CODE_1] [nvarchar](2) NULL,
	[INF_URI_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_URI_CODE_2] [nvarchar](2) NULL,
	[INF_URI_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_URI_CODE_3] [nvarchar](2) NULL,
	[INF_URI_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_URI_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_URI_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_URI] [nvarchar](1) NULL,
	[IV_URI] [nvarchar](1) NULL,
	[INF_TB] [nvarchar](1) NULL,
	[INF_TB_STATUS] [smallint] NULL,
	[INF_TB_STATUS_DEC] [nvarchar](9) NULL,
	[INF_TB_SPECIFY] [nvarchar](20) NULL,
	[INF_TB_DT_DY] [smallint] NULL,
	[INF_TB_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_TB_DT_MO] [smallint] NULL,
	[INF_TB_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_TB_DT_YR] [smallint] NULL,
	[INF_TB_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_TB_CODE_1] [nvarchar](2) NULL,
	[INF_TB_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_TB_CODE_2] [nvarchar](2) NULL,
	[INF_TB_CODE_2_DEC] [nvarchar](89) NULL,
	[INF_TB_CODE_3] [nvarchar](2) NULL,
	[INF_TB_CODE_3_DEC] [nvarchar](89) NULL,
	[INF_TB_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_TB_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_TB] [nvarchar](1) NULL,
	[IV_TB] [nvarchar](1) NULL,
	[INF_OTHER] [nvarchar](1) NULL,
	[INF_OTHER_SPECIFY] [nvarchar](20) NULL,
	[INF_OTHER_DT_DY] [smallint] NULL,
	[INF_OTHER_DT_DY_DEC] [nvarchar](2) NULL,
	[INF_OTHER_DT_MO] [smallint] NULL,
	[INF_OTHER_DT_MO_DEC] [nvarchar](3) NULL,
	[INF_OTHER_DT_YR] [smallint] NULL,
	[INF_OTHER_DT_YR_DEC] [nvarchar](4) NULL,
	[INF_OTHER_CODE_1] [nvarchar](2) NULL,
	[INF_OTHER_CODE_1_DEC] [nvarchar](89) NULL,
	[INF_OTHER_CODE_2] [nvarchar](2) NULL,
	[INF_OTHER_CODE_2_DEC] [nvarchar](46) NULL,
	[INF_OTHER_CODE_3] [nvarchar](2) NULL,
	[INF_OTHER_CODE_3_DEC] [nvarchar](46) NULL,
	[INF_OTHER_OTHER_MYCO] [nvarchar](40) NULL,
	[INF_OTHER_OTHER_OPP] [nvarchar](40) NULL,
	[SER_INF_OTHER] [nvarchar](1) NULL,
	[IV_OTHER] [nvarchar](1) NULL,
	[ANY_EVENT_NONE] [nvarchar](1) NULL,
	[ANY_EVENT_LIFE_THREAT] [nvarchar](1) NULL,
	[ANY_EVENT_HOSP] [nvarchar](1) NULL,
	[ANY_EVENT_PERSISTENT] [nvarchar](1) NULL,
	[ANY_EVENT_BIRTH_DEF] [nvarchar](1) NULL,
	[ANY_EVENT_IMP_MED_EVENT] [nvarchar](1) NULL,
	[ANY_EVENT_DATE1] [nvarchar](40) NULL,
	[ANY_EVENT_DATE2] [nvarchar](40) NULL,
	[ANY_EVENT_DATE3] [nvarchar](40) NULL,
	[DELETED] [nvarchar](1) NULL
) ON [PRIMARY]
GO
