USE [Reporting]
GO
/****** Object:  Table [PSA400].[EventTypeBU]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[EventTypeBU](
	[REVNUM] [int] NULL,
	[VISITID] [float] NULL,
	[PAGEID] [float] NULL,
	[POBJNAME] [nvarchar](255) NULL,
	[PAGENAME] [nvarchar](255) NULL,
	[PORDER] [float] NULL,
	[PAGEDESC] [nvarchar](255) NULL,
	[FirstPage] [float] NULL,
	[LastPage] [float] NULL,
	[EventType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
