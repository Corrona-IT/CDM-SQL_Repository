USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_EER]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_EER](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](60) NULL,
	[SubjectID] [bigint] NOT NULL,
	[ProviderID] [bigint] NULL,
	[YearofBirth] [int] NULL,
	[Age] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[OnsetYear] [int] NULL,
	[JuvenileRA] [nvarchar](20) NULL,
	[EligibilityVersion] [int] NULL,
	[TreatmentName] [nvarchar](500) NULL,
	[EligibleMedication] [nvarchar](500) NULL,
	[TreatmentStatus] [nvarchar](200) NULL,
	[StartDate] [nvarchar](10) NULL,
	[AdditionalMedications] [nvarchar](750) NULL,
	[TwelveMonthInitiationRule] [nvarchar](50) NULL,
	[PriorJAKiUse] [nvarchar](20) NULL,
	[FirstTimeUse] [nvarchar](30) NULL,
	[RegistryEnrollmentStatus] [nvarchar](50) NULL
) ON [PRIMARY]
GO
