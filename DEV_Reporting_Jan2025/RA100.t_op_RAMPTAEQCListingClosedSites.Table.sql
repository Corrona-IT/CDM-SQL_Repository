USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RAMPTAEQCListingClosedSites]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_RAMPTAEQCListingClosedSites](
	[SiteID] [int] NULL,
	[SubjectID] [nvarchar](255) NULL,
	[VisitName] [nvarchar](255) NULL,
	[ProviderID] [int] NULL,
	[EventType] [nvarchar](255) NULL,
	[Event] [nvarchar](255) NULL,
	[EventOnsetDate] [date] NULL,
	[FollowupVisitDate] [date] NULL,
	[EventOutcome] [nvarchar](255) NULL,
	[Hospitalized] [nvarchar](255) NULL,
	[ConfirmedEvent] [nvarchar](255) NULL,
	[IfNoEvent] [nvarchar](255) NULL,
	[Page1CRFStatus] [nvarchar](255) NULL,
	[Page2CRFStatus] [nvarchar](255) NULL,
	[TAEISAttest] [nvarchar](255) NULL,
	[TAEISAttestDate] [nvarchar](255) NULL,
	[Page1LastModDate] [date] NULL,
	[Page2LastModDate] [date] NULL,
	[BiologicAtEvent] [nvarchar](255) NULL,
	[BiologicAtEventOther] [nvarchar](255) NULL,
	[SourceDocuments] [nvarchar](255) NULL,
	[FileAttached] [nvarchar](255) NULL,
	[AcknowledgementofReceipt] [float] NULL,
	[ReasonNoSource] [nvarchar](255) NULL
) ON [PRIMARY]
GO
