USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_HBCompareVisitLog]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_HBCompareVisitLog](
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](255) NULL,
	[VisitYear] [int] NULL,
	[VisitType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
