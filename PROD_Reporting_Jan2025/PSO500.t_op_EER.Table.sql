USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_EER]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_EER](
	[VisitId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[Country] [nvarchar](50) NULL,
	[SubjectID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[BirthYear] [int] NULL,
	[AgeAtEnroll] [int] NULL,
	[EnrollDate] [date] NULL,
	[DiagnosisYear] [int] NULL,
	[crfStatus] [nvarchar](200) NULL,
	[Treatment] [nvarchar](350) NULL,
	[otherTreatment] [nvarchar](350) NULL,
	[TreatmentName] [nvarchar](500) NULL,
	[EligibleTreatment] [nvarchar](25) NULL,
	[FirstDoseToday] [nvarchar](10) NULL,
	[firstUse] [nvarchar](10) NULL,
	[calcFirstUse] [nvarchar](10) NULL,
	[AllowedPreviousUse] [nvarchar](10) NULL,
	[BiologicNaive] [nvarchar](10) NULL,
	[additionalStartDate] [nvarchar](5) NULL,
	[DrugCohort] [nvarchar](150) NULL,
	[TreatmentStatus] [nvarchar](150) NULL,
	[TwelveMonthInitiationRule] [nvarchar](25) NULL,
	[enteredStartDate] [nvarchar](12) NULL,
	[startDate] [date] NULL,
	[stopDate] [date] NULL,
	[pastUseStartDate] [date] NULL,
	[pastUseStopDate] [date] NULL,
	[MonthsSinceStart] [bigint] NULL,
	[DaysSinceStart] [bigint] NULL,
	[DaysInterrupted] [bigint] NULL,
	[trxmtBetween] [nvarchar](20) NULL,
	[MonthsSincePastUseStart] [bigint] NULL,
	[RegistryEnrollmentStatus] [nvarchar](100) NULL,
	[EligibilityReview] [nvarchar](100) NULL
) ON [PRIMARY]
GO
