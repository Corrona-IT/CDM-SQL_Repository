USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_op_IncompleteVisits]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_op_IncompleteVisits](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](20) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar](30) NULL,
	[SUBID] [varchar](30) NULL,
	[VisitType] [nvarchar](50) NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[CompletionStatus] [nvarchar](30) NULL
) ON [PRIMARY]
GO
