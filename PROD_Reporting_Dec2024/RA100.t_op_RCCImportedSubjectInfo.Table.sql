USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RCCImportedSubjectInfo]    Script Date: 12/9/2024 2:46:41 PM ******/
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
