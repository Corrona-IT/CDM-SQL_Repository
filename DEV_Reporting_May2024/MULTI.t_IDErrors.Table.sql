USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_IDErrors]    Script Date: 6/6/2024 8:58:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_IDErrors](
	[Registry] [nvarchar](255) NULL,
	[SiteID] [nvarchar](25) NULL,
	[SubjectID] [nvarchar](25) NULL,
	[ProviderID] [nvarchar](25) NULL,
	[IDErrorType] [nvarchar](255) NULL,
	[EnrollmentDate] [date] NULL,
	[FirstEntryDate] [date] NULL
) ON [PRIMARY]
GO
