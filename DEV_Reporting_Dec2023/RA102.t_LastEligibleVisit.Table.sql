USE [Reporting]
GO
/****** Object:  Table [RA102].[t_LastEligibleVisit]    Script Date: 12/22/2023 12:23:44 PM ******/
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
