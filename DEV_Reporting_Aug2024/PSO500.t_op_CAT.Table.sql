USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_CAT]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_CAT](
	[EnrollVisitId] [bigint] NOT NULL,
	[PatientId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[VisitType] [nvarchar](40) NULL,
	[ProviderID] [int] NULL,
	[BirthDate] [int] NULL,
	[EnrollDate] [date] NULL,
	[DiagnosisYear] [int] NULL,
	[EligVersion] [int] NULL,
	[crfStatus] [nvarchar](200) NULL,
	[Treatment] [nvarchar](350) NULL,
	[otherTreatment] [nvarchar](350) NULL,
	[DOI] [nvarchar](500) NULL,
	[EligibleTreatment] [nvarchar](40) NULL,
	[FirstDoseToday] [nvarchar](10) NULL,
	[firstUse] [nvarchar](10) NULL,
	[calcFirstUse] [nvarchar](10) NULL,
	[AllowedPreviousUse] [nvarchar](10) NULL,
	[BiologicNaive] [nvarchar](10) NULL,
	[additionalStartDate] [nvarchar](5) NULL,
	[TreatmentType] [nvarchar](150) NULL,
	[DOIType] [nvarchar](50) NULL,
	[TreatmentStatus] [nvarchar](150) NULL,
	[TwelveMonthInitiationRule] [nvarchar](25) NULL,
	[startDate] [date] NULL,
	[stopDate] [date] NULL,
	[pastUseStartDate] [date] NULL,
	[pastUseStopDate] [date] NULL,
	[MonthsSinceStart] [bigint] NULL,
	[DaysSinceStart] [bigint] NULL,
	[DaysInterrupted] [bigint] NULL,
	[trxmtBetween] [nvarchar](20) NULL,
	[MonthsSincePastUseStart] [bigint] NULL,
	[FUVisitId] [bigint] NULL,
	[InitiationStatus] [nvarchar](300) NULL,
	[DrugStartDateConfirmation] [date] NULL,
	[RegistryEnrollmentStatus] [nvarchar](100) NULL,
	[EligibilityReview] [nvarchar](100) NULL
) ON [PRIMARY]
GO
