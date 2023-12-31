USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_PatientVisitTracker]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_PatientVisitTracker](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NOT NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
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
