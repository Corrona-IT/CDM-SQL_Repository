USE [Reporting]
GO
/****** Object:  Table [MS700].[ResponseSets]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[ResponseSets](
	[Response Set Label] [nvarchar](255) NULL,
	[Response Set Values] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
