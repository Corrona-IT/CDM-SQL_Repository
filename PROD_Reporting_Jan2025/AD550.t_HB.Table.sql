USE [Reporting]
GO
/****** Object:  Table [AD550].[t_HB]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_HB](
	[TRNAME] [varchar](4000) NULL,
	[TRNO] [varchar](4000) NULL,
	[TRCAP] [varchar](4000) NULL,
	[STNAME] [varchar](4000) NULL,
	[STNO] [varchar](4000) NULL,
	[SITEC] [varchar](4000) NULL,
	[SUBJID] [varchar](4000) NULL,
	[VISITN] [varchar](4000) NULL,
	[VISITDT] [date] NULL,
	[CRFNAME] [varchar](4000) NULL,
	[CRFSTAT] [varchar](4000) NULL,
	[CPHID] [varchar](4000) NULL,
	[DLPES] [varchar](4000) NULL,
	[DATECNST] [varchar](4000) NULL,
	[GAVEPII] [varchar](4000) NULL,
	[GAVEAUTH] [varchar](4000) NULL,
	[PARTWD] [varchar](4000) NULL,
	[PARTWDDT] [varchar](4000) NULL,
	[FULLWD2] [varchar](4000) NULL,
	[FULLWDDT] [varchar](4000) NULL,
	[ADM_WDRW] [varchar](4000) NULL,
	[WDRW_RSN] [varchar](4000) NULL,
	[ADM_WDDT] [varchar](4000) NULL,
	[TRIALID] [varchar](4000) NULL,
	[SITEID] [varchar](4000) NULL,
	[PATIENTID] [varchar](4000) NULL,
	[VISITID] [varchar](4000) NULL,
	[FORMID] [varchar](4000) NULL,
	[DATAMIN] [varchar](4000) NULL,
	[DATAMAX] [varchar](4000) NULL,
	[STATMIN] [varchar](4000) NULL,
	[STATMAX] [varchar](4000) NULL
) ON [PRIMARY]
GO
