USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_op_FullDataEntryLag]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_op_FullDataEntryLag](
	[Registry] [varchar](15) NOT NULL,
	[FullRegName] [varchar](100) NOT NULL,
	[vID] [varchar](200) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [varchar](15) NULL,
	[VisitDate] [date] NULL,
	[VisitType] [varchar](30) NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL
) ON [PRIMARY]
GO
