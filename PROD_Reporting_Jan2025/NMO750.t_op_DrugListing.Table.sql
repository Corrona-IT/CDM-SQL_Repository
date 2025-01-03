USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_op_DrugListing]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_op_DrugListing](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[eventName] [nvarchar](100) NULL,
	[eventId] [bigint] NULL,
	[crfName] [nvarchar](100) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[statusCode] [nvarchar](100) NULL,
	[Treatment] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[OtherTreatment] [nvarchar](300) NULL,
	[DrugStatus] [nvarchar](300) NULL,
	[drugconfirmation] [nvarchar](100) NULL,
	[indication] [nvarchar](300) NULL,
	[ReasonStarted] [nvarchar](60) NULL,
	[DatePrescribed] [date] NULL,
	[DateStarted] [date] NULL,
	[DosingStatus] [nvarchar](300) NULL,
	[ReasonNotStarted] [nvarchar](200) NULL,
	[drugDose] [nvarchar](200) NULL,
	[drugDoseOther] [nvarchar](200) NULL,
	[drugDoseTaperHigh] [nvarchar](200) NULL,
	[drugDoseTaperLow] [nvarchar](200) NULL,
	[drugFrequency] [nvarchar](200) NULL,
	[drugFrequencyOther] [nvarchar](250) NULL,
	[DateStopped] [date] NULL,
	[ReasonStopped] [nvarchar](200) NULL
) ON [PRIMARY]
GO
