USE [Reporting]
GO
/****** Object:  Table [RA100].[t_HB_Hidden]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_HB_Hidden](
	[TRNAME] [varchar](50) NULL,
	[TRNO] [varchar](50) NULL,
	[TRCAP] [varchar](50) NULL,
	[STNAME] [varchar](255) NULL,
	[STNO] [int] NULL,
	[SITEC] [varchar](255) NULL,
	[SUBJID] [bigint] NULL,
	[VISITN] [varchar](50) NULL,
	[VISITDT] [date] NULL,
	[CRFNAME] [varchar](255) NULL,
	[CRFSTAT] [varchar](50) NULL,
	[CPHID] [int] NULL,
	[V14CNSNT] [int] NULL,
	[DATECNST] [date] NULL,
	[TYPECNST] [int] NULL,
	[ELIG_GRP] [int] NULL,
	[ADM_WDRW] [varchar](50) NULL,
	[PHIDAT] [date] NULL,
	[MR_SIGN] [int] NULL,
	[NOMR_RSN] [varchar](255) NULL,
	[PARTWD] [int] NULL,
	[PARTWDDT] [date] NULL,
	[FULLWD] [varchar](50) NULL,
	[FULLWDDT] [date] NULL,
	[ADM_WDDT] [date] NULL,
	[TRIALID] [bigint] NULL,
	[SITEID] [bigint] NULL,
	[PATIENTID] [bigint] NULL,
	[VISITID] [int] NULL,
	[FORMID] [int] NULL,
	[DATAMIN] [datetime] NULL,
	[DATAMAX] [datetime] NULL,
	[STATMIN] [datetime] NULL,
	[STATMAX] [datetime] NULL
) ON [PRIMARY]
GO
