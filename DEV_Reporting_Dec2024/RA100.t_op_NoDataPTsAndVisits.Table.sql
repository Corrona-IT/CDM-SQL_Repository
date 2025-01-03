USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_NoDataPTsAndVisits]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_NoDataPTsAndVisits](
	[SiteID] [int] NULL,
	[currentStatus] [nvarchar](100) NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[DaysSinceCreation] [int] NULL,
	[IssueType] [nvarchar](50) NULL
) ON [PRIMARY]
GO
