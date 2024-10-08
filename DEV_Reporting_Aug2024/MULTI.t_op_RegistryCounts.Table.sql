USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_op_RegistryCounts]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_op_RegistryCounts](
	[Registry] [nvarchar](255) NULL,
	[ActivePts] [int] NULL,
	[InactivePts] [int] NULL,
	[ENVisits] [int] NULL,
	[FUVisits] [int] NULL,
	[ExitVisits] [int] NULL,
	[TAEs] [int] NULL,
	[TAEDocs] [int] NULL,
	[DownloadDate] [date] NULL
) ON [PRIMARY]
GO
