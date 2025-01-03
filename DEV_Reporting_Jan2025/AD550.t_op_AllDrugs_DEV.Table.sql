USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_AllDrugs_DEV]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_AllDrugs_DEV](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](25) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[VisitEventOccurrence] [int] NULL,
	[VisitCompletion] [nvarchar](30) NULL,
	[eventId] [int] NULL,
	[eventOccurrence] [int] NULL,
	[crfName] [nvarchar](200) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[TreatmentName] [nvarchar](250) NULL,
	[OtherTreatment] [nvarchar](250) NULL,
	[TreatmentStatus] [nvarchar](100) NULL,
	[NoPriorUse] [int] NULL,
	[PastUse] [int] NULL,
	[CurrentUse] [int] NULL,
	[DrugStarted] [int] NULL,
	[StartDate] [date] NULL,
	[StartReason] [nvarchar](10) NULL,
	[DrugStopped] [int] NULL,
	[StopDate] [date] NULL,
	[StopReason] [nvarchar](10) NULL,
	[Modified] [int] NULL,
	[RestartDate] [date] NULL,
	[ChangeDate] [date] NULL,
	[ChangeReason] [nvarchar](10) NULL,
	[NoChanges] [int] NULL,
	[CurrentDose] [nvarchar](50) NULL,
	[CurrentFrequency] [nvarchar](50) NULL,
	[PastDose] [nvarchar](50) NULL,
	[PastFrequency] [nvarchar](50) NULL,
	[FirstDoseReceivedToday] [nvarchar](10) NULL
) ON [PRIMARY]
GO
