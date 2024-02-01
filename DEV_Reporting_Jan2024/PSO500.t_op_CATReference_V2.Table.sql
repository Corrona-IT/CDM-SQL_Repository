USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_CATReference_V2]    Script Date: 1/31/2024 10:11:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_CATReference_V2](
	[TreatmentType] [nvarchar](255) NULL,
	[TreatmentName] [nvarchar](255) NULL,
	[DOIType] [nvarchar](255) NULL,
	[Version] [float] NULL
) ON [PRIMARY]
GO
