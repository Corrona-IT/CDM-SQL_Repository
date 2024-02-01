USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectInfo]    Script Date: 1/31/2024 10:27:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectInfo](
	[SiteID] [int] NULL,
	[SiteStatus] [varchar](20) NULL,
	[SubjectID] [bigint] NULL,
	[SubIDL0s] [varchar](25) NULL,
	[TrialMasterID] [int] NOT NULL,
	[CreatedDate] [date] NULL,
	[VisitType] [varchar](250) NULL,
	[TMEnrollDate] [date] NULL,
	[BSEnrollDate] [date] NULL,
	[EnrollDateDiscrepancy] [varchar](250) NOT NULL,
	[RESEnrollDate] [date] NULL,
	[EnrollDate] [date] NULL,
	[TMYOB] [int] NULL,
	[BSYOB] [float] NULL,
	[YOBDiscrepancy] [varchar](7) NOT NULL,
	[RESYOB] [int] NULL,
	[YOB] [float] NULL,
	[TMSex] [nvarchar](1024) NULL,
	[BSSex] [nvarchar](255) NULL,
	[SexDiscrepancy] [varchar](7) NOT NULL,
	[RESSex] [nvarchar](25) NULL,
	[Sex] [nvarchar](1024) NULL,
	[TMOnsetYear] [nvarchar](1024) NULL,
	[BSOnsetYear] [nvarchar](255) NULL,
	[OnsetYearDiscrepancy] [varchar](7) NOT NULL,
	[RESOnsetYear] [int] NULL,
	[OnsetYear] [int] NULL,
	[TMDiagnosis] [varchar](2) NULL,
	[BSDiagnosis] [nvarchar](255) NULL,
	[DiagnosisDiscrepancy] [varchar](35) NOT NULL,
	[RESDiagnosis] [nvarchar](25) NULL,
	[Diagnosis] [nvarchar](25) NULL,
	[TMEthnicity] [varchar](255) NULL,
	[BSEthnicity] [nvarchar](255) NULL,
	[EthnicityDiscrepancy] [varchar](35) NOT NULL,
	[RESEthnicity] [nvarchar](25) NULL,
	[Ethnicity] [nvarchar](25) NULL,
	[LastVisitDate] [date] NULL,
	[ExitDate] [date] NULL,
	[MonthsSinceLastVisit] [decimal](8, 2) NULL,
	[SubjectStatus] [varchar](22) NULL,
	[Imported] [int] NULL,
	[RecordsInTM] [varchar](3) NOT NULL,
	[TotalFollowUps] [int] NULL,
	[TotalTAEs] [int] NULL,
	[InLegacy] [varchar](3) NOT NULL,
	[PTWDiscrepancies] [int] NULL,
	[FullyResolvedPTs] [int] NULL,
	[TotalDiscrepancies] [int] NULL,
	[TotalResolved] [int] NULL,
	[Discrepancies] [nvarchar](max) NULL,
	[EnrollDateDiscrepancyCount] [int] NULL,
	[YOBDiscrepancyCount] [int] NULL,
	[SexDiscrepancyCount] [int] NULL,
	[OnsetYearDiscrepancyCount] [int] NULL,
	[DiagnosisDiscrepancyCount] [int] NULL,
	[RESEnrollDateCount] [int] NULL,
	[RESYOBCount] [int] NULL,
	[RESSexCount] [int] NULL,
	[RESOnsetYearCount] [int] NULL,
	[RESDiagnosisCount] [int] NULL,
	[EligibleForImport] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
