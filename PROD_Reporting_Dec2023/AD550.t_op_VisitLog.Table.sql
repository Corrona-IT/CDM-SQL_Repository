USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_VisitLog]    Script Date: 12/22/2023 12:56:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_VisitLog](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](60) NULL,
	[SubjectID] [bigint] NOT NULL,
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
	[EligibleVisit] [nvarchar](50) NULL
) ON [PRIMARY]
GO
