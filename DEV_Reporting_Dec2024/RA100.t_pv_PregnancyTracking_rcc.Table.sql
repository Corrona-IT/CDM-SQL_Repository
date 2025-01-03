USE [Reporting]
GO
/****** Object:  Table [RA100].[t_pv_PregnancyTracking_rcc]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_pv_PregnancyTracking_rcc](
	[SiteID] [int] NOT NULL,
	[subjectId] [bigint] NOT NULL,
	[subNum] [nvarchar](25) NULL,
	[EventName] [nvarchar](350) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[VisitDate] [datetime] NULL,
	[crfOccurrence] [bigint] NULL,
	[hasData] [nvarchar](10) NULL,
	[gender] [nvarchar](10) NULL,
	[eventCrfId] [bigint] NULL,
	[auditId] [bigint] NULL,
	[questionText] [nvarchar](500) NULL,
	[oldValue] [nvarchar](1000) NULL,
	[newValue] [nvarchar](1000) NULL,
	[VisitTreatments] [nvarchar](1000) NULL,
	[OtherVisitTreatments] [nvarchar](1000) NULL,
	[LastModifiedDate] [datetime] NULL,
	[current] [int] NULL,
	[columnOrder] [int] NULL
) ON [PRIMARY]
GO
