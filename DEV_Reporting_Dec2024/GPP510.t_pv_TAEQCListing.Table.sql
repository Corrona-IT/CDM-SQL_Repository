USE [Reporting]
GO
/****** Object:  Table [GPP510].[t_pv_TAEQCListing]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GPP510].[t_pv_TAEQCListing](
	[vID] [bigint] NULL,
	[SITENUM] [nvarchar](10) NOT NULL,
	[SiteStatus] [nvarchar](100) NULL,
	[SUBID] [bigint] NOT NULL,
	[SUBNUM] [nvarchar](25) NOT NULL,
	[PROVID] [bigint] NULL,
	[VISNAME] [nvarchar](75) NULL,
	[VISITSEQ] [bigint] NULL,
	[EventType] [nvarchar](150) NULL,
	[EventTerm] [nvarchar](200) NULL,
	[specifyOtherEvent] [nvarchar](250) NULL,
	[OnsetDate] [date] NULL,
	[EventFirstReported] [nvarchar](150) NULL,
	[RptVisitDate] [date] NULL,
	[confirmationStatus] [nvarchar](75) NULL,
	[notAnEventExplain] [nvarchar](500) NULL,
	[OUTCOME_DEC] [nvarchar](250) NULL,
	[SERIOUS_DEC] [nvarchar](250) NULL,
	[seriousCriteria] [nvarchar](750) NULL,
	[IV_antiInfective] [nvarchar](10) NULL,
	[drugLogTreatments] [nvarchar](750) NULL,
	[otherDrugLogTreatments] [nvarchar](750) NULL,
	[drugExposure] [nvarchar](750) NULL,
	[otherDrugExposure] [nvarchar](750) NULL,
	[gender] [nvarchar](30) NULL,
	[YearOfBirth] [nvarchar](10) NULL,
	[race] [nvarchar](750) NULL,
	[Ethnicity] [nvarchar](50) NULL,
	[suppDocs] [nvarchar](50) NULL,
	[suppdocsUpload] [nvarchar](50) NULL,
	[suppDocsNotSubmReas] [nvarchar](250) NULL,
	[suppDocsApproved] [nvarchar](150) NULL,
	[eventPaid] [nvarchar](20) NULL,
	[suppDocspaid] [nvarchar](20) NULL,
	[HasData] [nvarchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LMDT_confirmationStatus] [datetime] NULL,
	[LMDT_eventInformation] [datetime] NULL,
	[LMDT_eventDetails] [datetime] NULL,
	[LMDT_drugExposure] [datetime] NULL,
	[LMDT_otherConcurrentDrugs] [datetime] NULL,
	[LMDT_flareVisits] [datetime] NULL,
	[LMDT_subjectForm] [datetime] NULL,
	[LMDT_testResults] [datetime] NULL,
	[LMDT_eventCompletion] [datetime] NULL,
	[LMDT_CaseProcessing] [datetime] NULL,
	[eventPaymentEligibility] [nvarchar](100) NULL,
	[EventDataEntryStatus] [nvarchar](50) NULL
) ON [PRIMARY]
GO
