USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_VisitLog]    Script Date: 9/22/2023 10:25:04 AM ******/
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
