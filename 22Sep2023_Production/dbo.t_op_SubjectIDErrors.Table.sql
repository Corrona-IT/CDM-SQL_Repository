USE [Reporting]
GO
/****** Object:  Table [dbo].[t_op_SubjectIDErrors]    Script Date: 9/22/2023 11:21:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_op_SubjectIDErrors](
	[Registry] [nvarchar](255) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [nvarchar](25) NULL,
	[ProviderID] [int] NULL,
	[IDErrorType] [nvarchar](300) NULL,
	[EnrollmentDate] [date] NULL,
	[FirstEntryDate] [date] NULL,
	[EnrollmentOnly] [nvarchar](25) NULL
) ON [PRIMARY]
GO
