USE [Reporting]
GO
/****** Object:  Table [AD550].[t_HBCompareVisitLog]    Script Date: 6/6/2024 9:28:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_HBCompareVisitLog](
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[VisitSequence] [int] NULL,
	[EDCVisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](20) NULL,
	[VisitYear] [int] NULL,
	[VisitType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
