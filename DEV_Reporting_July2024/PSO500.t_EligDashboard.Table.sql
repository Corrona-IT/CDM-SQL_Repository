USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_EligDashboard]    Script Date: 8/1/2024 11:10:03 AM ******/
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
