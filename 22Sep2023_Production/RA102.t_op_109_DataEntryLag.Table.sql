USE [Reporting]
GO
/****** Object:  Table [RA102].[t_op_109_DataEntryLag]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_op_109_DataEntryLag](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
) ON [PRIMARY]
GO
