USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_HBCompareVisitLog]    Script Date: 8/1/2024 11:24:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_HBCompareVisitLog](
	[SiteID] [float] NULL,
	[SubjectID] [float] NULL,
	[VisitDate] [date] NULL,
	[Month] [nvarchar](255) NULL,
	[Year] [float] NULL,
	[VisitType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
