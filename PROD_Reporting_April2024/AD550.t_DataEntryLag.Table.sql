USE [Reporting]
GO
/****** Object:  Table [AD550].[t_DataEntryLag]    Script Date: 5/1/2024 2:06:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_DataEntryLag](
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](40) NULL,
	[vID] [bigint] NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[DataCollectionType] [varchar](300) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[FirstEntry] [datetime] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
) ON [PRIMARY]
GO
