USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard_EER]    Script Date: 1/31/2024 10:27:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_EligDashboard_EER](
	[Site ID] [int] NOT NULL,
	[Subject ID] [bigint] NULL,
	[Eligible Treatment] [nvarchar](250) NULL,
	[Enrollment Date] [date] NULL
) ON [PRIMARY]
GO
