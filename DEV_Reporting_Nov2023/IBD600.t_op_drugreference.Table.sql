USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_op_drugreference]    Script Date: 11/7/2023 12:08:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_op_drugreference](
	[EnrollmentDateStart] [date] NULL,
	[EnrollmentDateEnd] [date] NULL,
	[DrugCohort_DrugType] [nvarchar](255) NULL,
	[DrugName] [nvarchar](255) NULL,
	[Diagnosis] [nvarchar](255) NULL
) ON [PRIMARY]
GO
