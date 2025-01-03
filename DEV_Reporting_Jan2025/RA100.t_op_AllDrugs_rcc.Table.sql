USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_AllDrugs_rcc]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_AllDrugs_rcc](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](50) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[VisitEventOccurrence] [int] NULL,
	[VisitCompletion] [nvarchar](50) NULL,
	[eventId] [int] NULL,
	[eventOccurrence] [int] NULL,
	[crfName] [nvarchar](200) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[TreatmentName] [nvarchar](250) NULL,
	[OtherTreatment] [nvarchar](250) NULL,
	[TreatmentStatus] [nvarchar](200) NULL,
	[NoPriorUse] [int] NULL,
	[PastUse] [int] NULL,
	[CurrentUse] [int] NULL,
	[DrugStarted] [int] NULL,
	[StartDate] [date] NULL,
	[StartReason] [nvarchar](100) NULL,
	[DrugStopped] [int] NULL,
	[StopDate] [date] NULL,
	[StopReason] [nvarchar](100) NULL,
	[Modified] [int] NULL,
	[ChangeReason] [nvarchar](100) NULL,
	[NoChanges] [int] NULL,
	[CurrentDose] [nvarchar](100) NULL,
	[CurrentFrequency] [nvarchar](100) NULL,
	[PastDose] [nvarchar](100) NULL,
	[PastFrequency] [nvarchar](100) NULL,
	[FirstDoseReceivedToday] [nvarchar](10) NULL
) ON [PRIMARY]
GO
