USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_CATReference]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_CATReference](
	[TreatmentType] [nvarchar](255) NOT NULL,
	[TreatmentName] [nvarchar](350) NOT NULL,
	[DOIType] [nvarchar](150) NULL,
	[Version] [int] NULL
) ON [PRIMARY]
GO
