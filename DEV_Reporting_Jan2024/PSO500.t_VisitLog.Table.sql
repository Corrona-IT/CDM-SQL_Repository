USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_VisitLog]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_VisitLog](
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NOT NULL,
	[Month] [varchar](3) NULL,
	[Year] [int] NULL,
	[VisitType] [nvarchar](50) NULL
) ON [PRIMARY]
GO
