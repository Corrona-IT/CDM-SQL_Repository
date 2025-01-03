USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_op_RegistryCounts]    Script Date: 12/5/2024 12:48:32 PM ******/
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
