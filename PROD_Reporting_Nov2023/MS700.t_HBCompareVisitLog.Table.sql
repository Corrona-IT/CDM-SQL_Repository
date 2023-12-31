USE [Reporting]
GO
/****** Object:  Table [MS700].[t_HBCompareVisitLog]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_HBCompareVisitLog](
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitType] [nvarchar](255) NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL
) ON [PRIMARY]
GO
