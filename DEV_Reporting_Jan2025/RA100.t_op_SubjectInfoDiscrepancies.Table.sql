USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectInfoDiscrepancies]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectInfoDiscrepancies](
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[TrialMasterID] [bigint] NULL,
	[TMEnrollDate] [date] NULL,
	[BSEnrollDate] [date] NULL,
	[EnrollDateDiscrepancy] [nvarchar](255) NULL,
	[RESEnrollDate] [date] NULL,
	[TMYOB] [int] NULL,
	[BSYOB] [int] NULL,
	[YOBDiscrepancy] [nvarchar](255) NULL,
	[RESYOB] [int] NULL,
	[TMSex] [nvarchar](255) NULL,
	[BSSex] [nvarchar](255) NULL,
	[SexDiscrepancy] [nvarchar](255) NULL,
	[RESSex] [nvarchar](255) NULL,
	[TMOnsetYear] [int] NULL,
	[BSOnsetYear] [int] NULL,
	[OnsetYearDiscrepancy] [nvarchar](255) NULL,
	[RESOnsetYear] [int] NULL,
	[TMDiagnosis] [nvarchar](255) NULL,
	[BSDiagnosis] [nvarchar](255) NULL,
	[DiagnosisDiscrepancy] [nvarchar](255) NULL,
	[RESDiagnosis] [nvarchar](255) NULL
) ON [PRIMARY]
GO
