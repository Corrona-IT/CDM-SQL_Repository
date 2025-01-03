USE [Reporting]
GO
/****** Object:  Table [MS700].[t_pv_TAEQCListing]    Script Date: 11/13/2024 1:41:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_pv_TAEQCListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](15) NOT NULL,
	[PatientID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[DateCompleted] [date] NULL,
	[DateReported] [date] NULL,
	[EventType] [varchar](500) NULL,
	[Event] [varchar](500) NULL,
	[OnsetDate] [date] NULL,
	[ConfirmationStatus] [varchar](500) NULL,
	[Outcome] [varchar](500) NULL,
	[SupportingDocuments] [varchar](250) NULL,
	[SupportingDocumentsUploaded] [varchar](150) NULL,
	[SupportingDocsApproved] [varchar](25) NULL,
	[EventPaid] [int] NULL,
	[SourceDocsPaid] [int] NULL,
	[DateCreated] [datetime] NULL,
	[VisitType] [int] NULL,
	[eventSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[LastModifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
