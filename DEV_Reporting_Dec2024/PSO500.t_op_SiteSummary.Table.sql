USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_SiteSummary]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_SiteSummary](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NOT NULL,
	[SubjectsEnrolled] [bigint] NOT NULL,
	[NotDueCount] [bigint] NULL,
	[NowDueCount] [bigint] NULL,
	[OVERDUE1Count] [bigint] NULL,
	[OVERDUE2Count] [bigint] NULL,
	[OVERDUE3Count] [bigint] NULL
) ON [PRIMARY]
GO
