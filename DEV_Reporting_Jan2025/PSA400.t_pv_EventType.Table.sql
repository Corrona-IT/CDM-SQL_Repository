USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_pv_EventType]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_pv_EventType](
	[REVNUM] [int] NULL,
	[VISITID] [int] NULL,
	[PAGEID] [int] NULL,
	[POBJNAME] [nvarchar](100) NULL,
	[PAGENAME] [nvarchar](100) NULL,
	[PORDER] [int] NULL,
	[PAGEDESC] [nvarchar](100) NULL,
	[FirstPage] [int] NULL,
	[LastPage] [int] NULL,
	[EVENTYPE] [nvarchar](30) NULL
) ON [PRIMARY]
GO
