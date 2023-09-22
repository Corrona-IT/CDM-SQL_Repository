USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_HB]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_HB](
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
	[DLPES] [varchar](50) NULL,
	[DATECNST] [varchar](50) NULL,
	[GAVEPII] [varchar](50) NULL,
	[GAVEAUTH] [varchar](50) NULL,
	[PARTWD] [varchar](50) NULL,
	[PARTWDDT] [date] NULL,
	[FULLWD2] [varchar](50) NULL,
	[FULLWDDT] [date] NULL,
	[ADM_WDRW] [varchar](50) NULL,
	[WDRW_RSN] [int] NULL,
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
 CONSTRAINT [PK_IBD600_t_HB] PRIMARY KEY CLUSTERED 
(
	[SUBJID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
