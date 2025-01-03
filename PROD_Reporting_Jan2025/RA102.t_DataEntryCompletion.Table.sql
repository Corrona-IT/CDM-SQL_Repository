USE [Reporting]
GO
/****** Object:  Table [RA102].[t_DataEntryCompletion]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_DataEntryCompletion](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[PageName] [varchar](500) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NOT NULL,
	[CompletionInMinutes] [int] NULL,
	[CompletionInHours] [decimal](20, 2) NULL
) ON [PRIMARY]
GO
