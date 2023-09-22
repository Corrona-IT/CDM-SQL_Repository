USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_HBMissingIDs_V1]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_HBMissingIDs_V1](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[ConsentType] [varchar](12) NULL,
	[SubjectIDNotFoundIn] [varchar](15) NULL
) ON [PRIMARY]
GO
