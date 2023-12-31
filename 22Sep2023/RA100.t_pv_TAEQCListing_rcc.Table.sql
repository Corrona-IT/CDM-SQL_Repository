USE [Reporting]
GO
/****** Object:  Table [RA100].[t_pv_TAEQCListing_rcc]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_pv_TAEQCListing_rcc](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](35) NULL,
	[DateReported] [date] NULL,
	[EventType] [nvarchar](500) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[EventName] [nvarchar](350) NULL,
	[EventOnsetDate] [date] NULL,
	[MDConfirmed] [nvarchar](300) NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](150) NULL,
	[SupportDocsApproved] [nvarchar](20) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[DateCreated] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[AD Drug Exposure] [datetime] NULL,
	[Other concurrent Drugs] [datetime] NULL,
	[Data Entry Completion] [datetime] NULL,
	[Supporting Documents Approval] [datetime] NULL
) ON [PRIMARY]
GO
