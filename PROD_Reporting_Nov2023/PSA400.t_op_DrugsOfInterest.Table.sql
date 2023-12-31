USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_DrugsOfInterest]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_DrugsOfInterest](
	[RegistryNumber] [int] NULL,
	[RegistryName] [nvarchar](10) NULL,
	[DrugName] [nvarchar](500) NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[ProtocolVersion] [int] NULL,
	[REVNUM] [int] NULL
) ON [PRIMARY]
GO
