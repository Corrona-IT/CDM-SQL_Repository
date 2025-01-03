USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard_EER]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_EligDashboard_EER](
	[Site ID] [int] NOT NULL,
	[Subject ID] [nvarchar](20) NULL,
	[Eligible Treatment] [nvarchar](250) NULL,
	[Enrollment Date] [date] NULL
) ON [PRIMARY]
GO
