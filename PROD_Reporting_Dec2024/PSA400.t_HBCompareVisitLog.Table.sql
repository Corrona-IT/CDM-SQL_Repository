USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_HBCompareVisitLog]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_HBCompareVisitLog](
	[SiteID] [int] NULL,
	[SubjectID] [nvarchar](25) NULL,
	[VisitType] [nvarchar](255) NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL
) ON [PRIMARY]
GO
