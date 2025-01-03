USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_UAT_CAT_Enrollment]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_UAT_CAT_Enrollment](
	[VisitID] [bigint] NULL,
	[SiteID] [bigint] NULL,
	[SiteStatus] [varchar](8) NOT NULL,
	[SubjectID] [nvarchar](100) NULL,
	[VisitType] [nvarchar](100) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [tinyint] NULL,
	[YearOfBirth] [smallint] NULL,
	[YearOfDiagnosis] [smallint] NULL,
	[Diagnosis] [nvarchar](max) NULL,
	[EligibilityVersion] [varchar](3) NOT NULL,
	[DrugHierarchy] [bigint] NULL,
	[PageDescription] [nvarchar](100) NULL,
	[TreatmentName] [nvarchar](72) NULL,
	[TreatmentStartYear] [smallint] NULL,
	[TreatmentStartMonth] [smallint] NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [smallint] NULL,
	[TreatmentStopMonth] [smallint] NULL,
	[CurrentDose] [nvarchar](30) NULL,
	[PastDose] [nvarchar](30) NULL,
	[DrugOfInterest] [nvarchar](72) NULL,
	[AdditionalDOI] [nvarchar](max) NULL,
	[PageStatus] [nvarchar](18) NULL,
	[DOIInitiationStatus] [varchar](26) NOT NULL,
	[SubscriberDOI] [varchar](3) NOT NULL,
	[DrugReqSatisfied] [varchar](3) NULL,
	[FirstTimeUse] [varchar](3) NULL,
	[ChangesToday] [nvarchar](22) NULL,
	[Cohort] [varchar](50) NULL,
	[INELIGIBLE_DEC] [nvarchar](26) NULL,
	[INELIGIBLE_EXCEPTION_DEC] [nvarchar](3) NULL,
	[RegistryEnrollmentStatus] [varchar](24) NOT NULL,
	[ReviewOutcome] [varchar](32) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
