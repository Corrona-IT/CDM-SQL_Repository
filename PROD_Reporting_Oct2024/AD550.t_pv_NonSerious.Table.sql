USE [Reporting]
GO
/****** Object:  Table [AD550].[t_pv_NonSerious]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_pv_NonSerious](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[eventName] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[VisitDate] [date] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [bigint] NULL,
	[statusCode] [nvarchar](100) NULL,
	[hasData] [nvarchar](10) NULL,
	[eventType] [nvarchar](500) NULL,
	[specifyEvent] [nvarchar](500) NULL,
	[specifyLocation] [nvarchar](500) NULL,
	[specifyEventLocation] [nvarchar](500) NULL,
	[Serious] [nvarchar](10) NULL,
	[IVAntibiotics] [nvarchar](10) NULL,
	[Pathogen] [nvarchar](500) NULL,
	[VisitTreatments] [nvarchar](2000) NULL,
	[OtherVisitTreatments] [nvarchar](2000) NULL,
	[OnsetDate] [date] NULL,
	[auditDate] [datetime] NULL
) ON [PRIMARY]
GO
