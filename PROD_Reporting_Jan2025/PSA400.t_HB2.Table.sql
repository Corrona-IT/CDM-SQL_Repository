USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_HB2]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_HB2](
	[TRNAME] [varchar](50) NULL,
	[TRNO] [varchar](50) NULL,
	[TRCAP] [varchar](50) NULL,
	[STNAME] [varchar](255) NULL,
	[STNO] [int] NOT NULL,
	[SITEC] [varchar](255) NULL,
	[SUBJID] [varchar](50) NOT NULL,
	[VISITN] [varchar](50) NULL,
	[VISITDT] [date] NULL,
	[CRFNAME] [varchar](255) NULL,
	[CRFSTAT] [varchar](50) NULL,
	[CPHID] [int] NULL,
	[PSAV2EN] [varchar](50) NULL,
	[DATECNST] [date] NULL,
	[GAVEPII] [varchar](50) NULL,
	[GAVEAUTH] [varchar](50) NULL,
	[PARTWD] [varchar](50) NULL,
	[PARTWDDT] [date] NULL,
	[FULLWD] [varchar](50) NULL,
	[FULLWDDT] [date] NULL,
	[ADM_WDRW] [varchar](50) NULL,
	[WDRW_RSN] [varchar](255) NULL,
	[ADM_WDDT] [date] NULL,
	[TRIALID] [bigint] NULL,
	[SITEID] [bigint] NULL,
	[PATIENTID] [bigint] NULL,
	[VISITID] [int] NULL,
	[FORMID] [int] NULL,
	[DATAMIN] [datetime] NULL,
	[DATAMAX] [datetime] NULL,
	[STATMIN] [datetime] NULL,
	[STATMAX] [datetime] NULL,
 CONSTRAINT [PK_PSA400_t_HB] PRIMARY KEY CLUSTERED 
(
	[SUBJID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
