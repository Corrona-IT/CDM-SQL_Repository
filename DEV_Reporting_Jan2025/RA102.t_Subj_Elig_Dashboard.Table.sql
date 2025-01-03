USE [Reporting]
GO
/****** Object:  Table [RA102].[t_Subj_Elig_Dashboard]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_Subj_Elig_Dashboard](
	[SiteID] [int] NULL,
	[ProviderID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [varchar](50) NOT NULL,
	[AGE] [int] NULL,
	[AtLeast18] [int] NULL,
	[YR_ONSET_RA] [int] NULL,
	[Diagnosed] [int] NULL,
	[Cohort] [nvarchar](50) NULL,
	[Drug] [varchar](85) NULL,
	[EligibleDrug] [int] NULL,
	[PrescAtVisit] [int] NULL,
	[PriorUse] [int] NULL,
	[EligPresc_woPriorUse] [int] NULL
) ON [PRIMARY]
GO
