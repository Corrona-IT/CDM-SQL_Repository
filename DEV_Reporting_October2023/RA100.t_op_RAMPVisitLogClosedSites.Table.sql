USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RAMPVisitLogClosedSites]    Script Date: 10/16/2023 4:13:18 PM ******/
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
