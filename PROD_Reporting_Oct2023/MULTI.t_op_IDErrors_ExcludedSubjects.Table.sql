USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_op_IDErrors_ExcludedSubjects]    Script Date: 10/16/2023 4:13:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_op_IDErrors_ExcludedSubjects](
	[Registry] [nvarchar](255) NULL,
	[SubjectID] [nvarchar](20) NULL,
	[CurrentSite] [int] NULL,
	[OldSite] [int] NULL,
	[ExclusionReason] [nvarchar](255) NULL
) ON [PRIMARY]
GO
