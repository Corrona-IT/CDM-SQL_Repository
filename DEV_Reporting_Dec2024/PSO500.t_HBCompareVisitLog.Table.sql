USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_HBCompareVisitLog]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_HBCompareVisitLog](
	[SiteID] [float] NULL,
	[SubjectID] [float] NULL,
	[VisitDate] [nvarchar](255) NULL,
	[Month] [nvarchar](255) NULL,
	[Year] [float] NULL,
	[VisitType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
