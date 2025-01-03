USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectInfoROMRetrievedData]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectInfoROMRetrievedData](
	[site_id] [int] NOT NULL,
	[optional_id] [bigint] NOT NULL,
	[md_cod] [int] NOT NULL,
	[FirstFuVisitDate] [date] NULL,
	[Need] [nvarchar](100) NULL,
	[ROMEnrollDate] [date] NULL,
	[Notes] [nvarchar](100) NULL,
	[ROMEnrollDateNotes] [nvarchar](100) NULL,
	[ROMSex] [nvarchar](25) NULL,
	[ROMYOB] [int] NULL,
	[2ndRequest] [date] NULL,
	[VanessasCall] [date] NULL,
	[3rdRequest] [nvarchar](100) NULL
) ON [PRIMARY]
GO
