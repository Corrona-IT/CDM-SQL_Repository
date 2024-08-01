USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_CATReference]    Script Date: 8/1/2024 11:24:26 AM ******/
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
