USE [Reporting]
GO
/****** Object:  Table [dbo].[t_op_SubjectIDErrors]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_op_SubjectIDErrors](
	[Registry] [nvarchar](255) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[SiteID] [nvarchar](10) NULL,
	[SubjectID] [nvarchar](300) NULL,
	[ProviderID] [nvarchar](300) NULL,
	[IDErrorType] [nvarchar](300) NULL,
	[EnrollmentDate] [date] NULL,
	[FirstEntryDate] [date] NULL,
	[EnrollmentOnly] [nvarchar](25) NULL
) ON [PRIMARY]
GO
