USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_Enrollment_Drugs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_Enrollment_Drugs](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](25) NULL,
	[SubjectID] [nvarchar](25) NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL,
	[YearOfBirth] [int] NULL,
	[YearOfDiagnosis] [int] NULL,
	[Diagnosis] [nvarchar](50) NULL,
	[EligibilityVersion] [nvarchar](12) NULL,
	[DrugHierarchy] [int] NULL,
	[PageDescription] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[TreatmentStartYear] [int] NULL,
	[TreatmentStartMonth] [nvarchar](10) NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[CurrentDose] [nvarchar](150) NULL,
	[PastDose] [nvarchar](150) NULL,
	[DrugOfInterest] [nvarchar](350) NULL,
	[AdditionalDOI] [nvarchar](1000) NULL,
	[PageStatus] [nvarchar](150) NULL,
	[DrugReqSatisfied] [nvarchar](10) NULL,
	[FirstTimeUse] [nvarchar](50) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[Cohort] [nvarchar](250) NULL
) ON [PRIMARY]
GO
