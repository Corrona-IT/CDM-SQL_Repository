USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_AllMedsENRandFU]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_AllMedsENRandFU](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](250) NULL,
	[CRF Name] [nvarchar](350) NULL,
	[Treatment] [nvarchar](300) NULL,
	[If Other specify] [nvarchar](300) NULL,
	[First Use Start Date] [nvarchar](20) NULL,
	[Current User Current Dose] [nvarchar](50) NULL,
	[Current User Current Dose specify] [nvarchar](25) NULL,
	[Current User Frequency] [nvarchar](50) NULL,
	[Current User Frequency specify] [nvarchar](25) NULL,
	[Past But Not Current User Most Recent Dose] [nvarchar](50) NULL,
	[Past But Not Current User Most Recent Dose specify] [nvarchar](25) NULL,
	[Past But Not Current User Most Recent Use] [nvarchar](20) NULL,
	[Changes Planned Today] [nvarchar](50) NULL,
	[Reason Code 1] [nvarchar](5) NULL,
	[Reason Code 2] [nvarchar](5) NULL,
	[Reason Code 3] [nvarchar](5) NULL
) ON [PRIMARY]
GO
