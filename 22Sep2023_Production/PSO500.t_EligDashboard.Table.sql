USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_EligDashboard](
	[Site ID] [int] NOT NULL,
	[Subject ID] [bigint] NULL,
	[Eligible Treatment] [nvarchar](250) NULL,
	[Enrollment Date] [date] NULL
) ON [PRIMARY]
GO
