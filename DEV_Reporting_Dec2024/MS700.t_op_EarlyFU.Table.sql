USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_EarlyFU]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_op_EarlyFU](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [varchar](50) NULL,
	[eventOccurrence] [int] NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[DaysSinceLastVisit] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[EligibleVisit] [varchar](10) NULL,
	[OutOfWindow] [varchar](150) NULL,
	[EarlyVisitRulesSatisfied] [varchar](100) NULL,
	[ExceptionGranted] [varchar](100) NULL,
	[ExceptionReason] [varchar](250) NULL,
	[PermanentlyIncomplete] [varchar](10) NULL,
	[IneligibleVirtualVisit] [varchar](10) NULL
) ON [PRIMARY]
GO
