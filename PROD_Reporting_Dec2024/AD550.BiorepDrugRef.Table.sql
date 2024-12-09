USE [Reporting]
GO
/****** Object:  Table [AD550].[BiorepDrugRef]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[BiorepDrugRef](
	[DrugName] [nvarchar](255) NULL,
	[DrugCohort] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Cohort1] [nvarchar](255) NULL,
	[Cohort2] [nvarchar](255) NULL
) ON [PRIMARY]
GO
