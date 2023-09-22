USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_DataEntryLag]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_DataEntryLag](
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](15) NULL,
	[eventCrfId] [bigint] NULL,
	[crfCaption] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[eventOccurrence] [int] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
) ON [PRIMARY]
GO
