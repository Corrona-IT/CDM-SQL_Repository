USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_op_DAYSBETWEENVISIT]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_op_DAYSBETWEENVISIT](
	[ROWNUM] [int] NOT NULL,
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](12) NOT NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[VisitType] [nvarchar](30) NULL,
	[Visit] [nvarchar](10) NULL,
	[VisitDate] [date] NULL,
	[PriorvisitDate] [date] NULL,
	[Dayssincelastvisit] [int] NULL,
	[MonthsSinceLastVisit] [float] NULL
) ON [PRIMARY]
GO
