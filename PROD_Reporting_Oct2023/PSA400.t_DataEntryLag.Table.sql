USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_DataEntryLag]    Script Date: 10/16/2023 4:13:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_DataEntryLag](
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](25) NULL,
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
