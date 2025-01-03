USE [Reporting]
GO
/****** Object:  Table [BIO100].[t_op_PatientVerification]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BIO100].[t_op_PatientVerification](
	[VisitId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[PatientId] [bigint] NOT NULL,
	[SiteStatus] [nvarchar](100) NULL,
	[Gender] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[YOB] [int] NULL,
	[VisitType] [nvarchar](30) NOT NULL,
	[LastVisitDate] [date] NULL,
	[StartDate] [nvarchar](50) NULL,
	[StartDateCheck] [nvarchar](10) NULL,
	[TreatmentName] [nvarchar](100) NULL,
	[TreatmentNameCheck] [nvarchar](100) NULL,
	[ChangesToday] [nvarchar](100) NULL,
	[CurrentPastEligible] [nvarchar](1000) NULL,
	[CurrentPastOther] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
