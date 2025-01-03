USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_SubjectLog]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_SubjectLog](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar](500) NULL,
	[ExitReasonDetails] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
