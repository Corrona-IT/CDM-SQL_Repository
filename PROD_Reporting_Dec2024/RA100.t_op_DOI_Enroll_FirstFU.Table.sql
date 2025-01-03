USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_DOI_Enroll_FirstFU]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_DOI_Enroll_FirstFU](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](30) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [nvarchar](30) NULL,
	[ProviderID] [varchar](10) NULL,
	[YearofBirth] [int] NULL,
	[VisitDate] [date] NULL,
	[OnsetYear] [int] NULL,
	[EligibilityVersion] [int] NULL,
	[DrugOfInterest] [nvarchar](300) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[StartDate] [nvarchar](10) NULL,
	[DOIInitiationStatus] [varchar](150) NULL,
	[AdditionalDOI] [varchar](1000) NULL,
	[SubscriberDOI] [varchar](10) NULL,
	[TwelveMonthInitiationRule] [varchar](25) NULL,
	[PriorJAKiUse] [varchar](10) NULL,
	[FirstTimeUse] [varchar](30) NULL,
	[RegistryEnrollmentStatus] [varchar](300) NULL,
	[ConfirmationVisitDate] [date] NULL,
	[InitiationStatus] [nvarchar](200) NULL,
	[SubscriberDOIAccrual] [nvarchar](200) NULL,
	[CsdmardCount] [int] NULL
) ON [PRIMARY]
GO
