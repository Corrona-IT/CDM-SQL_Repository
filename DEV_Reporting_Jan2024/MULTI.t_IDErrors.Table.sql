USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_IDErrors]    Script Date: 1/31/2024 10:11:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_IDErrors](
	[Registry] [nvarchar](255) NULL,
	[SiteID] [float] NULL,
	[SubjectID] [nvarchar](25) NULL,
	[ProviderID] [float] NULL,
	[IDErrorType] [nvarchar](255) NULL,
	[EnrollmentDate] [date] NULL,
	[FirstEntryDate] [date] NULL
) ON [PRIMARY]
GO
