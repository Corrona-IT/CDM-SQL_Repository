USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_SubjectLog]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_SubjectLog](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[VisitType] [nvarchar](100) NULL,
	[ExitDate] [date] NULL,
	[ExitProviderID] [int] NULL,
	[ExitReason] [nvarchar](500) NULL,
	[ExitReasonDetails] [nvarchar](1000) NULL,
	[DeathInfection] [nvarchar](1000) NULL,
	[DateofDeath] [date] NULL,
	[ExitComments] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
