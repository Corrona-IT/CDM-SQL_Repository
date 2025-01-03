USE [Reporting]
GO
/****** Object:  Table [RA100].[t_pv_NonSerious_rcc]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_pv_NonSerious_rcc](
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
	[VisitTreatments] [nvarchar](2000) NULL,
	[OtherVisitTreatments] [nvarchar](2000) NULL,
	[OnsetDate] [date] NULL,
	[auditDate] [datetime] NULL
) ON [PRIMARY]
GO
