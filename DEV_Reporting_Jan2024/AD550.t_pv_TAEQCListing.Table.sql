USE [Reporting]
GO
/****** Object:  Table [AD550].[t_pv_TAEQCListing]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_pv_TAEQCListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[reviewConfirmed] [nvarchar](50) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](50) NULL,
	[FUVisitDate] [date] NULL,
	[EventType] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[EventTerm] [nvarchar](350) NULL,
	[SpecifyEvent] [nvarchar](350) NULL,
	[EventOnsetDate] [date] NULL,
	[MDConfirmed] [nvarchar](30) NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[noEventExplain] [nvarchar](500) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[Serious] [nvarchar](10) NULL,
	[SeriousReason] [nvarchar](350) NULL,
	[IVAntiInfect] [nvarchar](10) NULL,
	[FUVisitTreatments] [nvarchar](1500) NULL,
	[OtherFUVisitTreatments] [nvarchar](1500) NULL,
	[EventTreatments] [nvarchar](1200) NULL,
	[OtherEventTreatments] [nvarchar](1200) NULL,
	[gender] [nvarchar](25) NULL,
	[yearOfBirth] [int] NULL,
	[race] [nvarchar](300) NULL,
	[ethnicity] [nvarchar](50) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](25) NULL,
	[SupportDocumentsNotUploadedReason] [nvarchar](500) NULL,
	[SupportDocsApproved] [nvarchar](20) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[PayEligibleStatus] [nvarchar](30) NULL,
	[DataEntryStatus] [nvarchar](50) NULL,
	[auditType] [nvarchar](25) NULL,
	[DateCreated] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[AD Drug Exposure] [datetime] NULL,
	[Other concurrent Drugs] [datetime] NULL,
	[Data Entry Completion] [datetime] NULL,
	[Supporting Documents Approval] [datetime] NULL
) ON [PRIMARY]
GO
