USE [Reporting]
GO
/****** Object:  Table [PSA400].[EventType]    Script Date: 7/15/2024 11:18:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[EventType](
	[REVNUM] [float] NULL,
	[VISITID] [float] NULL,
	[PORDER] [float] NULL,
	[PAGENAME] [nvarchar](255) NULL,
	[POBJNAME] [nvarchar](255) NULL,
	[PAGEID] [float] NULL,
	[EVENTTYPE] [nvarchar](255) NULL,
	[PAGEDESC] [nvarchar](255) NULL,
	[FirstPage] [float] NULL
) ON [PRIMARY]
GO
