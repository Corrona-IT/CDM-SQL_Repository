USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_VisitLog]    Script Date: 4/2/2024 11:30:01 AM ******/
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
	[VisitType] [nvarchar](200) NULL
) ON [PRIMARY]
GO
