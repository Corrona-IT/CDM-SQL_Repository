USE [Reporting]
GO
/****** Object:  Table [RA100].[t_HBCompareVisitLog]    Script Date: 4/2/2024 11:07:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_HBCompareVisitLog](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitDate] [date] NULL,
	[VisitType] [varchar](250) NULL,
	[ProviderID] [int] NULL,
	[VisitSequence] [int] NULL
) ON [PRIMARY]
GO
