USE [Reporting]
GO
/****** Object:  Table [RA102].[t_LastEligibleVisit]    Script Date: 7/15/2024 12:41:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_LastEligibleVisit](
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](50) NOT NULL,
	[VisitDate] [date] NULL,
	[LastEligibleVisitDate] [date] NULL
) ON [PRIMARY]
GO
