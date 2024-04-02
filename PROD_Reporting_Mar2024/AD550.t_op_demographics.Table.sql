USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_demographics]    Script Date: 4/2/2024 11:30:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_demographics](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[yearOfBirth] [int] NULL,
	[gender] [nvarchar](25) NULL,
	[race] [nvarchar](500) NULL,
	[ethnicity] [nvarchar](50) NULL
) ON [PRIMARY]
GO
