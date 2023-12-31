USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_IDErrors]    Script Date: 9/22/2023 10:25:04 AM ******/
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
