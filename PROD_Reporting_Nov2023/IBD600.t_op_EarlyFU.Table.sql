USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_op_EarlyFU]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_op_EarlyFU](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](20) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [bigint] NOT NULL,
	[SUBID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](50) NULL,
	[CalcVisitSequence] [int] NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[PreviousVisitDate] [date] NULL,
	[EligibleVisit] [nvarchar](10) NULL,
	[DaysSinceLastVisit] [bigint] NULL,
	[BioRepositoryAssoc] [nvarchar](10) NULL,
	[BioRepositoryVisitType] [nvarchar](200) NULL,
	[OutOfWindow] [nvarchar](50) NULL,
	[EarlyVisitRulesSatisfied] [nvarchar](50) NULL,
	[ExceptionGranted] [nvarchar](50) NULL,
	[ExceptionReason] [nvarchar](250) NULL,
	[VisitPaid] [nvarchar](10) NULL
) ON [PRIMARY]
GO
