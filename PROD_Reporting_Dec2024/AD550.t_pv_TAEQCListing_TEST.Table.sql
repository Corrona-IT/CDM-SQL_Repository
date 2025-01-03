USE [Reporting]
GO
/****** Object:  Table [AD550].[t_pv_TAEQCListing_TEST]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_pv_TAEQCListing_TEST](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
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
	[MDConfirmed] [nvarchar](30) NULL,
	[ConfirmationStatus] [nvarchar](200) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](300) NULL,
	[SupportingDocuments] [nvarchar](250) NULL,
	[SupportingDocumentsUploaded] [nvarchar](150) NULL,
	[EventPaid] [nvarchar](20) NULL,
	[SourceDocsPaid] [nvarchar](20) NULL,
	[DateCreated] [datetime] NULL,
	[Event Info Last Modified Date] [datetime] NULL,
	[Event Info Question] [nvarchar](500) NULL,
	[Event Info New Value] [nvarchar](350) NULL,
	[Event Details Last Modified Date] [datetime] NULL,
	[Event Details Question] [nvarchar](500) NULL,
	[Event Details New Value] [nvarchar](350) NULL,
	[AD Drug Exposure Last Modified Date] [datetime] NULL,
	[AD Drug Exposure Question] [nvarchar](500) NULL,
	[AD Drug Exposure New Value] [nvarchar](350) NULL,
	[Other Concurrent Drugs Last Modified Date] [datetime] NULL,
	[Other Concurrent Drugs Question] [nvarchar](500) NULL,
	[Other Concurrent Drugs New Value] [nvarchar](350) NULL,
	[Data Entry Completion Last Modified Date] [datetime] NULL,
	[Data Entry Completion Question] [nvarchar](500) NULL,
	[Data Entry Completion New Value] [nvarchar](350) NULL,
	[Supporting Documents Approval Last Modified Date] [datetime] NULL,
	[Supporting Documents Approval Question] [nvarchar](500) NULL,
	[Supporting Documents Approval New Value] [nvarchar](350) NULL
) ON [PRIMARY]
GO
