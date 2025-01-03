USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_DOI_Enrollment]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_DOI_Enrollment](
	[ROWNUM] [int] NOT NULL,
	[VisitId] [nvarchar](20) NOT NULL,
	[PatientId] [nvarchar](20) NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [nvarchar](30) NULL,
	[ProviderID] [varchar](10) NULL,
	[YearofBirth] [int] NULL,
	[Age] [int] NULL,
	[VisitDate] [date] NULL,
	[OnsetYear] [int] NULL,
	[JuvenileRA] [nvarchar](25) NULL,
	[YearsSinceOnset] [int] NULL,
	[EligibilityVersion] [int] NULL,
	[PageDescription] [nvarchar](100) NULL,
	[Page4FormStatus] [nvarchar](30) NULL,
	[Page5FormStatus] [nvarchar](30) NULL,
	[NoTreatment] [int] NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[StartDate] [nvarchar](10) NULL,
	[MonthsSinceStartToVisit] [int] NULL,
	[CurrentDose] [nvarchar](100) NULL,
	[CurrentFrequency] [nvarchar](150) NULL,
	[MostRecentDoseNotCurrentDose] [nvarchar](100) NULL,
	[MostRecentPastUseDate] [nvarchar](20) NULL,
	[DrugOfInterest] [nvarchar](300) NULL,
	[DrugHierarchy] [int] NULL,
	[DOIInitiationStatus] [varchar](150) NULL,
	[AdditionalDOI] [varchar](1000) NULL,
	[SubscriberDOI] [varchar](10) NULL,
	[TwelveMonthInitiationRule] [varchar](25) NULL,
	[PriorJAKiUse] [varchar](10) NULL,
	[FirstTimeUse] [varchar](30) NULL,
	[RegistryEnrollmentStatus] [varchar](300) NULL
) ON [PRIMARY]
GO
