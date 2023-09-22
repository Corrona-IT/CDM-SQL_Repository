USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard_V2]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_EligDashboard_V2](
	[Site ID] [int] NOT NULL,
	[Subject ID] [bigint] NULL,
	[Eligible Treatment] [nvarchar](50) NULL,
	[Enrollment Date] [date] NULL
) ON [PRIMARY]
GO
