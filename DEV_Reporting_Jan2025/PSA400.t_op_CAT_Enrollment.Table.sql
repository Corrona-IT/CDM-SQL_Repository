USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_CAT_Enrollment]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_CAT_Enrollment](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[VisitType] [nvarchar](50) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL,
	[YearofBirth] [int] NULL,
	[YearOfDiagnosis] [int] NULL,
	[Diagnosis] [nvarchar](30) NULL,
	[EligibilityVersion] [nvarchar](10) NULL,
	[DrugHierarchy] [int] NULL,
	[PageDescription] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[TreatmentStartYear] [int] NULL,
	[TreatmentStartMonth] [int] NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[CurrentDose] [nvarchar](150) NULL,
	[PastDose] [nvarchar](150) NULL,
	[DrugOfInterest] [nvarchar](350) NULL,
	[AdditionalDOI] [nvarchar](1000) NULL,
	[PageStatus] [nvarchar](150) NULL,
	[DOIInitiationStatus] [varchar](150) NULL,
	[SubscriberDOI] [varchar](10) NULL,
	[DrugReqSatisfied] [nvarchar](10) NULL,
	[FirstTimeUse] [nvarchar](50) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[Cohort] [nvarchar](200) NULL,
	[INELIGIBLE_DEC] [nvarchar](30) NULL,
	[INELIGIBLE_EXCEPTION_DEC] [nvarchar](30) NULL,
	[RegistryEnrollmentStatus] [nvarchar](50) NULL,
	[ReviewOutcome] [nvarchar](75) NULL
) ON [PRIMARY]
GO
