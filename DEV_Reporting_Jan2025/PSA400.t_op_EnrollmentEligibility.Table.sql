USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_EnrollmentEligibility]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_EnrollmentEligibility](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[Diagnosis] [nvarchar](100) NULL,
	[EligibilityVersion] [nvarchar](10) NULL,
	[EligibilityStatus] [nvarchar](100) NULL,
	[EligibleDrug] [nvarchar](600) NULL,
	[DrugOfInterest] [nvarchar](300) NULL,
	[Cohort] [nvarchar](450) NULL,
	[ReviewOutcome] [nvarchar](350) NULL,
	[Hierarchy_DATA] [int] NULL
) ON [PRIMARY]
GO
