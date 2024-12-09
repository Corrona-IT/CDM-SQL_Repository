USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_BiorepDrugRef]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_BiorepDrugRef](
	[DrugName] [nvarchar](255) NULL,
	[DrugCohort] [nvarchar](255) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Cohort] [nvarchar](255) NULL
) ON [PRIMARY]
GO
