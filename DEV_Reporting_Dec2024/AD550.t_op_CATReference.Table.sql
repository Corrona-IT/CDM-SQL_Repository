USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_CATReference]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_CATReference](
	[TreatmentName] [nvarchar](350) NOT NULL,
	[EligStartDate] [date] NOT NULL,
	[EligEndDate] [date] NOT NULL,
	[DOIType] [nvarchar](150) NULL
) ON [PRIMARY]
GO
