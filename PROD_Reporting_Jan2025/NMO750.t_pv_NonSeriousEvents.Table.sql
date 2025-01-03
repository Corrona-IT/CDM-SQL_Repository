USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_pv_NonSeriousEvents]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_pv_NonSeriousEvents](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[eventName] [nvarchar](350) NULL,
	[eventId] [bigint] NULL,
	[VisitDate] [date] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[statusCode] [nvarchar](50) NULL,
	[hasData] [int] NULL,
	[eventType] [nvarchar](350) NULL,
	[specifyEvent] [nvarchar](350) NULL,
	[Pathogen] [nvarchar](350) NULL,
	[OnsetDate] [date] NULL,
	[auditDate] [datetime] NULL
) ON [PRIMARY]
GO
