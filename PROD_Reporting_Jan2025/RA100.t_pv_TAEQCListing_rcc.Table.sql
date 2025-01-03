USE [Reporting]
GO
/****** Object:  Table [RA100].[t_pv_TAEQCListing_rcc]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_pv_TAEQCListing_rcc](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[TAEVersion] [nvarchar](5) NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](100) NULL,
	[DateReported] [date] NULL,
	[EventType] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[EventName] [nvarchar](350) NULL,
	[SpecifyEvent] [nvarchar](500) NULL,
	[EventOnsetDate] [date] NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[noEventExplain] [nvarchar](500) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[Serious] [nvarchar](10) NULL,
	[SeriousReason] [nvarchar](500) NULL,
	[IVAntiInfect] [nvarchar](10) NULL,
	[FUVisitTreatments] [nvarchar](1500) NULL,
	[OtherFUVisitTreatments] [nvarchar](1500) NULL,
	[EventTreatments] [nvarchar](1200) NULL,
	[OtherEventTreatments] [nvarchar](1200) NULL,
	[gender] [nvarchar](10) NULL,
	[yearOfbirth] [int] NULL,
	[race] [nvarchar](500) NULL,
	[ethnicity] [nvarchar](100) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](150) NULL,
	[ReasonNoSupportDocs] [nvarchar](500) NULL,
	[SupportDocsApproved] [nvarchar](20) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[crfCaption] [nvarchar](300) NULL,
	[payEligibility] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[auditType] [nvarchar](100) NULL,
	[LastModifiedDate] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[RA Drug Exposure] [datetime] NULL,
	[Other Concurrent Drugs] [datetime] NULL,
	[Event Completion] [datetime] NULL,
	[Case Processing] [datetime] NULL,
	[Confirmation Status] [datetime] NULL
) ON [PRIMARY]
GO
