USE [Reporting]
GO
/****** Object:  Table [RA102].[t_op_PatientVisitTracker]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_op_PatientVisitTracker](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NOT NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[YOB] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[LastVisitDate] [date] NULL,
	[VisitType] [nvarchar](30) NULL,
	[MonthsSinceLastVisit] [float] NULL,
	[VisitStatus] [nvarchar](15) NULL,
	[EarliestEligNextFU] [date] NULL,
	[TargetNextFUVisitDate] [date] NULL
) ON [PRIMARY]
GO
