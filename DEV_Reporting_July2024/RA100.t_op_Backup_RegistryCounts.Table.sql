USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_Backup_RegistryCounts]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_Backup_RegistryCounts](
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
