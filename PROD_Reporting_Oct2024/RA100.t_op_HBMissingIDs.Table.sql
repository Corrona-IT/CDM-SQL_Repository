USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_HBMissingIDs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_HBMissingIDs](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[DateOfEnrollment] [date] NULL,
	[SubjectIDNotFoundIn] [nvarchar](15) NULL
) ON [PRIMARY]
GO
