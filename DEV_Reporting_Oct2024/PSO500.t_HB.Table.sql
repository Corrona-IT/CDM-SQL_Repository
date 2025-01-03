USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_HB]    Script Date: 11/13/2024 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_HB](
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
	[PIIDAT] [datetime] NULL,
	[ICFDAT] [datetime] NULL,
	[PMRSIGN] [float] NULL,
	[MR_UP2] [float] NULL,
	[ADMWDRW] [nvarchar](255) NULL,
	[STWDRWDT] [nvarchar](255) NULL,
	[PTWDRWDT] [nvarchar](255) NULL,
	[WDRWRSN] [nvarchar](255) NULL,
	[PARTWD] [nvarchar](255) NULL,
	[PARTWDDT] [nvarchar](255) NULL,
	[FULLWD] [nvarchar](255) NULL,
	[FULLWDDT] [nvarchar](255) NULL,
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
