USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_Exits]    Script Date: 7/15/2024 11:18:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_Exits](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[ExitDate] [date] NOT NULL,
	[ExitReason] [nvarchar](500) NULL,
	[ExitReasonDetails] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
