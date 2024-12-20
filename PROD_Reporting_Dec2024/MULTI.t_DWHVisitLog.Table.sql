USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_DWHVisitLog]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_DWHVisitLog](
	[source] [nvarchar](32) NULL,
	[registry] [nvarchar](32) NULL,
	[site_id] [int] NULL,
	[visit_name] [nvarchar](256) NULL,
	[subject_id] [nvarchar](32) NULL,
	[visit_type] [nvarchar](256) NULL,
	[visit_sequence] [bigint] NULL,
	[visit_date] [date] NULL,
	[visit_provider_id] [nvarchar](2048) NULL
) ON [PRIMARY]
GO
