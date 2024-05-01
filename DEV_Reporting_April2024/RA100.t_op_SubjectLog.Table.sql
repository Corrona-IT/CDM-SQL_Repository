USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectLog]    Script Date: 5/1/2024 1:26:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectLog](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitDate] [nvarchar](10) NULL,
	[VisitType] [date] NULL,
	[YOB] [int] NULL,
	[ExitDate] [nvarchar](10) NULL,
	[ExitReason] [nvarchar](500) NULL,
	[ExitReasonDetails] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
