USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_Exits]    Script Date: 12/5/2024 12:48:32 PM ******/
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
