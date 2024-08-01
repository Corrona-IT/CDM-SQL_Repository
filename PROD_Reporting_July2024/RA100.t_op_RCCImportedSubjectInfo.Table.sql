USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RCCImportedSubjectInfo]    Script Date: 8/1/2024 11:24:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_RCCImportedSubjectInfo](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[Imported] [int] NULL
) ON [PRIMARY]
GO
