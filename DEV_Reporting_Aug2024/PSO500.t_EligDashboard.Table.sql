USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_EligDashboard](
	[Site ID] [int] NOT NULL,
	[Subject ID] [nvarchar](30) NULL,
	[Eligible Treatment] [nvarchar](50) NULL,
	[Enrollment Date] [date] NULL
) ON [PRIMARY]
GO
