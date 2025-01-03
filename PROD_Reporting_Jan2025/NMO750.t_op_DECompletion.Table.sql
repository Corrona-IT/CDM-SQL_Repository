USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_op_DECompletion]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_op_DECompletion](
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](12) NULL,
	[PatientID] [bigint] NULL,
	[VisitType] [nvarchar](300) NULL,
	[EventType] [nvarchar](300) NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[eventCompletion] [nvarchar](100) NULL,
	[statusCode] [nvarchar](100) NULL,
	[CompletionStatus] [nvarchar](100) NULL
) ON [PRIMARY]
GO
