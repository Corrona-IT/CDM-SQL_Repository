USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_DataEntryCompletion]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_DataEntryCompletion](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](20) NULL,
	[PageName] [varchar](500) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NOT NULL,
	[CompletionInMinutes] [decimal](20, 2) NULL,
	[CompletionInHours] [decimal](20, 2) NULL
) ON [PRIMARY]
GO
