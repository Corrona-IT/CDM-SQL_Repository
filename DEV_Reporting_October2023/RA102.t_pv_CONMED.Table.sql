USE [Reporting]
GO
/****** Object:  Table [RA102].[t_pv_CONMED]    Script Date: 10/16/2023 4:13:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_pv_CONMED](
	[vID] [bigint] NULL,
	[PAGEID] [nvarchar](8) NULL,
	[Y/N] [varchar](4) NOT NULL,
	[DrugName] [nvarchar](41) NOT NULL
) ON [PRIMARY]
GO
