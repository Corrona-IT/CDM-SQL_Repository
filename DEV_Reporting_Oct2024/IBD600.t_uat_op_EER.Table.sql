USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_uat_op_EER]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_uat_op_EER](
	[ROWNUM] [int] NULL,
	[vID] [bigint] NOT NULL,
	[VisitType] [nvarchar](50) NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar](16) NOT NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NOT NULL,
	[EligibilityVersion] [int] NULL,
	[YOB] [int] NULL,
	[AgeAtVisit] [int] NULL,
	[Diagnosis] [nvarchar](150) NULL,
	[DRUG_CLASS123_USE_EN] [int] NULL,
	[DrugClass] [nvarchar](200) NULL,
	[DrugName] [nvarchar](200) NULL,
	[EligibleDrug] [nvarchar](200) NULL,
	[PastUse] [nvarchar](5) NULL,
	[CurrentUse] [nvarchar](5) NULL,
	[ChangesToday] [nvarchar](200) NULL,
	[NoPriorUse] [nvarchar](5) NULL,
	[FirstDoseAdminTodayVisit] [nvarchar](5) NULL,
	[StartDate] [nvarchar](20) NULL,
	[ModPriorCurrStartDate] [date] NULL,
	[MonthsSinceDrugStart] [int] NULL,
	[InitiatedWithin12MoEnroll] [nvarchar](20) NULL,
	[BiologicNaive] [nvarchar](10) NULL,
	[EligibilityStatus] [nvarchar](100) NULL,
	[ReviewOutcome] [nvarchar](100) NULL,
	[VisitCompletionStatus] [nvarchar](50) NULL
) ON [PRIMARY]
GO
