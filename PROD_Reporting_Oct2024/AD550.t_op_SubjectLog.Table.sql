USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_SubjectLog]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_SubjectLog](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar](500) NULL,
	[ExitReasonDetails] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
