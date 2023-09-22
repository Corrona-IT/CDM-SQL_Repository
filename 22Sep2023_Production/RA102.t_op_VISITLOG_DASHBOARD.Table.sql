USE [Reporting]
GO
/****** Object:  Table [RA102].[t_op_VISITLOG_DASHBOARD]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_op_VISITLOG_DASHBOARD](
	[Site ID] [bigint] NULL,
	[Subject ID] [nvarchar](50) NULL,
	[Visit Type] [nvarchar](100) NULL,
	[Visit Date] [date] NULL,
	[Month] [varchar](3) NOT NULL,
	[Year] [int] NULL
) ON [PRIMARY]
GO
