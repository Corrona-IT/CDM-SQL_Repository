USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_HBMissingIDs]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_op_HBMissingIDs](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](8) NULL,
	[SFSiteStatus] [varchar](20) NULL,
	[SubjectID] [bigint] NULL,
	[DateofEnrollment] [date] NULL,
	[MissingInformation] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
