USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_Exits]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_Exits](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[ExitDate] [date] NOT NULL,
	[ExitReason] [nvarchar](500) NULL,
	[ExitReasonDetails] [nvarchar](1500) NULL
) ON [PRIMARY]
GO
