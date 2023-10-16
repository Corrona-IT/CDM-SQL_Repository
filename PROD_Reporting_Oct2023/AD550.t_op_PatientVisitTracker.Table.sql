USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_PatientVisitTracker]    Script Date: 10/16/2023 4:13:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_PatientVisitTracker](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [bigint] NOT NULL,
	[YOB] [int] NULL,
	[EnrollingProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[LastFollowUpProviderID] [int] NULL,
	[LastVisitDate] [date] NULL,
	[VisitType] [nvarchar](30) NULL,
	[MonthsSinceLastVisit] [float] NULL,
	[VisitStatus] [nvarchar](15) NULL,
	[EarliestEligNextFU] [date] NULL,
	[TargetNextFUVisitDate] [date] NULL
) ON [PRIMARY]
GO
