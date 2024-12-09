USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_DrugReference]    Script Date: 12/5/2024 12:48:32 PM ******/
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
