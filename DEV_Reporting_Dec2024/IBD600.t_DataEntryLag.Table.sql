USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_DataEntryLag]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_DataEntryLag](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](15) NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[DataCollectionType] [varchar](300) NULL,
	[VisitDate] [date] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
) ON [PRIMARY]
GO
