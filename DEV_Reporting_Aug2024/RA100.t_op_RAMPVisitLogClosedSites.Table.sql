USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RAMPVisitLogClosedSites]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_RAMPVisitLogClosedSites](
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
