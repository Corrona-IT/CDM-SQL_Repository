USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_EER_DrugRef]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_EER_DrugRef](
	[Drug Cohort] [nvarchar](255) NULL,
	[TreatmentName] [nvarchar](255) NULL,
	[Start Date] [date] NULL,
	[End Date] [date] NULL,
	[SubscriberType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
