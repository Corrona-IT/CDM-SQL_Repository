USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_TAEListing]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_op_TAEListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[DateCompleted] [date] NULL,
	[DateReported] [date] NULL,
	[EventType] [varchar](500) NULL,
	[Event] [varchar](500) NULL,
	[EventId] [int] NULL,
	[EventOccurrence] [int] NULL,
	[crfName] [varchar](500) NULL,
	[eventCrfId] [bigint] NULL,
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
	[LastModifiedDate] [date] NULL,
	[tae_reviewer_confirmation] [int] NULL,
	[eventStatus] [varchar](150) NULL
) ON [PRIMARY]
GO
