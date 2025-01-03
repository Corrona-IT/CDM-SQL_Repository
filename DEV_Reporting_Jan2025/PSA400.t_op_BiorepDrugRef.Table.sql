USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_BiorepDrugRef]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_BiorepDrugRef](
	[DrugName] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Cohort] [nvarchar](255) NULL
) ON [PRIMARY]
GO
