USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_LastVisits]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_LastVisits](
	[ROWNUM] [int] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [nvarchar](25) NOT NULL,
	[LastVisitDate] [date] NOT NULL
) ON [PRIMARY]
GO
