USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard_EER]    Script Date: 7/15/2024 12:41:07 PM ******/
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
