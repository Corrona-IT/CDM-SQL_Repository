USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_pv_TAEQCListing]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_pv_TAEQCListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[statusCode] [nvarchar](30) NULL,
	[gender] [nvarchar](15) NULL,
	[yearOfBirth] [int] NULL,
	[race] [nvarchar](250) NULL,
	[ethnicity] [nvarchar](100) NULL,
	[ProviderID] [int] NULL,
	[firstReportedVia] [nvarchar](40) NULL,
	[DateReported] [date] NULL,
	[EventType] [nvarchar](100) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[crfName] [nvarchar](250) NULL,
	[eventCrfId] [bigint] NULL,
	[EventName] [nvarchar](250) NULL,
	[EventSpecify] [nvarchar](300) NULL,
	[EventOnsetDate] [date] NULL,
	[EventConfirmationStatus] [nvarchar](100) NULL,
	[hasData] [nvarchar](10) NULL,
	[Outcome] [nvarchar](200) NULL,
	[Serious] [nvarchar](30) NULL,
	[SeriousCriteria] [nvarchar](500) NULL,
	[IVAntiInfective] [nvarchar](10) NULL,
	[SupportingDocuments] [nvarchar](100) NULL,
	[SupportingDocumentsUploaded] [nvarchar](500) NULL,
	[ReasonSourceDocsNotSubmitted] [nvarchar](750) NULL,
	[SupportDocsApproved] [nvarchar](50) NULL,
	[EventPaid] [nvarchar](50) NULL,
	[SourceDocsPaid] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[Confirmation Status] [datetime] NULL,
	[Event Info] [datetime] NULL,
	[Event Details] [datetime] NULL,
	[NMOSD Drug Exposure] [datetime] NULL,
	[EDSS-NMOSD Module] [datetime] NULL,
	[Infections] [datetime] NULL,
	[Comorbidities/AEs] [datetime] NULL,
	[Other Concurrent Drugs] [datetime] NULL,
	[Event Completion] [datetime] NULL,
	[Case Processing] [datetime] NULL
) ON [PRIMARY]
GO
