USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_DataEntryCompletion]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_DataEntryCompletion](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](10) NULL,
	[SubjectID] [varchar](20) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletedDate] [datetime] NOT NULL,
	[CompletionInMinutes] [decimal](20, 2) NULL,
	[CompletionInHours] [decimal](20, 2) NULL
) ON [PRIMARY]
GO
