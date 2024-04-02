USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_DataEntryCompletion]    Script Date: 4/2/2024 11:07:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_DataEntryCompletion](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitID] [bigint] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NOT NULL,
	[CompletionInMinutes] [decimal](20, 2) NULL,
	[CompletionInHours] [decimal](20, 2) NULL
) ON [PRIMARY]
GO
