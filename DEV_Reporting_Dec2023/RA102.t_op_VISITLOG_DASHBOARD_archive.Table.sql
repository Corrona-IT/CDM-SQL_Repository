USE [Reporting]
GO
/****** Object:  Table [RA102].[t_op_VISITLOG_DASHBOARD_archive]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_op_VISITLOG_DASHBOARD_archive](
	[Site ID] [bigint] NULL,
	[Subject ID] [nvarchar](50) NULL,
	[Visit Type] [nvarchar](100) NULL,
	[Visit Date] [date] NULL,
	[Month] [varchar](3) NOT NULL,
	[Year] [int] NULL
) ON [PRIMARY]
GO
