USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_IDErrors]    Script Date: 11/7/2023 12:08:57 PM ******/
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
