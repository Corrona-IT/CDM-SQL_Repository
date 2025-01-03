USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_HB]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_HB](
	[TRNAME] [nvarchar](255) NULL,
	[TRNO] [nvarchar](255) NULL,
	[TRCAP] [nvarchar](255) NULL,
	[STNAME] [nvarchar](255) NULL,
	[STNO] [float] NULL,
	[SITEC] [nvarchar](255) NULL,
	[SUBJID] [nvarchar](255) NULL,
	[VISITN] [nvarchar](255) NULL,
	[VISITDT] [datetime] NULL,
	[CRFNAME] [nvarchar](255) NULL,
	[CRFSTAT] [nvarchar](255) NULL,
	[CPHID] [float] NULL,
	[PSAV2EN] [float] NULL,
	[DATECNST] [datetime] NULL,
	[MR_UPL1] [float] NULL,
	[GAVEPII] [float] NULL,
	[GAVEAUTH] [float] NULL,
	[PARTWD] [nvarchar](255) NULL,
	[PARTWDDT] [nvarchar](255) NULL,
	[FULLWD] [nvarchar](255) NULL,
	[FULLWDDT] [nvarchar](255) NULL,
	[ADM_WDRW] [nvarchar](255) NULL,
	[WDRW_RSN] [nvarchar](255) NULL,
	[ADM_WDDT] [nvarchar](255) NULL,
	[TRIALID] [float] NULL,
	[SITEID] [float] NULL,
	[PATIENTID] [float] NULL,
	[VISITID] [float] NULL,
	[FORMID] [float] NULL,
	[DATAMIN] [datetime] NULL,
	[DATAMAX] [datetime] NULL,
	[STATMIN] [datetime] NULL,
	[STATMAX] [datetime] NULL
) ON [PRIMARY]
GO
