USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_AllDrugs]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_op_AllDrugs](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](35) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitCompletion] [nvarchar](30) NULL,
	[eventId] [bigint] NULL,
	[crfName] [nvarchar](350) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[otherTreatment] [nvarchar](350) NULL,
	[NoPriorUse] [int] NULL,
	[PastUse] [int] NULL,
	[CurrentUse] [int] NULL,
	[StartedDrug] [int] NULL,
	[StartDate] [date] NULL,
	[rawStartDate] [nvarchar](20) NULL,
	[enteredStartDate] [nvarchar](25) NULL,
	[StartReason] [nvarchar](100) NULL,
	[StoppedDrug] [int] NULL,
	[StopDate] [date] NULL,
	[StopReason] [nvarchar](100) NULL,
	[RestartDate] [date] NULL,
	[ModifiedDrug] [int] NULL,
	[ModifiedDate] [date] NULL,
	[ModifyReason] [nvarchar](100) NULL,
	[MostRecentInfusionDate] [date] NULL,
	[NoChanges] [int] NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[CTStartReason] [nvarchar](100) NULL,
	[CTStopReason] [nvarchar](100) NULL,
	[CTModifyReason] [nvarchar](100) NULL,
	[CurrentDose] [nvarchar](50) NULL,
	[CurrentFrequency] [nvarchar](50) NULL,
	[PastDose] [nvarchar](50) NULL,
	[PastFrequency] [nvarchar](50) NULL,
	[PrescribedDose] [nvarchar](50) NULL,
	[MostRecentRituxanDose] [nvarchar](50) NULL,
	[PastCycles] [int] NULL,
	[FirstDoseReceivedToday] [nvarchar](5) NULL
) ON [PRIMARY]
GO
