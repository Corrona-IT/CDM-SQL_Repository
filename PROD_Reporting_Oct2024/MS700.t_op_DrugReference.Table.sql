USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_DrugReference]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_op_DrugReference](
	[TreatmentName] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[SubscriberDOI] [nvarchar](255) NULL
) ON [PRIMARY]
GO
