USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_SubjectIDChecks]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_SubjectIDChecks](
	[Registry] [varchar](10) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [nvarchar](20) NULL,
	[IDErrorType] [varchar](20) NULL,
	[Status] [varchar](20) NULL,
	[Notes] [varchar](500) NULL,
	[LastStatusChangeDate] [date] NULL
) ON [PRIMARY]
GO
