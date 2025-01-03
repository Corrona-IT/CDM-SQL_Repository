USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_VisitLog]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_VisitLog](
	[VisitID] [bigint] NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](60) NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[patientId] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[eventCrfId] [bigint] NULL,
	[VisitType] [nvarchar](200) NULL,
	[DataCollectionType] [nvarchar](250) NULL,
	[eventId] [int] NULL,
	[VisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](20) NULL,
	[VisitYear] [int] NULL,
	[SubjectIDError] [nvarchar](20) NULL,
	[Registry] [nvarchar](20) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[EligibleVisit] [nvarchar](75) NULL
) ON [PRIMARY]
GO
