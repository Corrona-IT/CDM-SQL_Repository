USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_op_AllDrugs]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_op_AllDrugs](
	[Registry] [nvarchar](15) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[SiteID] [int] NOT NULL,
	[SFSiteStatus] [nvarchar](200) NULL,
	[EDCSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[eventCrfId] [bigint] NULL,
	[birthYear] [bigint] NULL,
	[ProviderID] [bigint] NULL,
	[VisitType] [nvarchar](100) NULL,
	[eventDefinitionId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[VisitDate] [date] NULL,
	[NextVisitDate] [date] NULL,
	[PreviousVisitDate] [date] NULL,
	[Treatment] [nvarchar](250) NULL,
	[OtherTreatment] [nvarchar](300) NULL,
	[crfOccurrence] [bigint] NULL,
	[DrugStatus] [nvarchar](300) NULL,
	[DateStarted] [date] NULL,
	[DateStopped] [date] NULL,
	[DatePrescribed] [date] NULL,
	[DosingStatus] [nvarchar](300) NULL,
	[drugConfirmation] [nvarchar](100) NULL,
	[indication] [nvarchar](300) NULL,
	[ReasonStarted] [nvarchar](60) NULL,
	[ReasonStopped] [nvarchar](200) NULL,
	[ReasonNotStarted] [nvarchar](200) NULL,
	[drugDose] [nvarchar](200) NULL,
	[drugDoseOther] [nvarchar](200) NULL,
	[drugDoseTaperHigh] [nvarchar](200) NULL,
	[drugDoseTaperLow] [nvarchar](200) NULL,
	[drugFrequency] [nvarchar](200) NULL,
	[drugFrequencyOther] [nvarchar](250) NULL,
	[CompletionStatus] [nvarchar](100) NULL
) ON [PRIMARY]
GO
