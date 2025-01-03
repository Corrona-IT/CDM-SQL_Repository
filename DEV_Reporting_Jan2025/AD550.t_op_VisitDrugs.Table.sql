USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_VisitDrugs]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_VisitDrugs](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[ProviderID] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](25) NULL,
	[eventId] [int] NULL,
	[eventOccurrence] [int] NULL,
	[crfName] [nvarchar](200) NULL,
	[crfOccurrence] [int] NULL,
	[TreatmentName] [nvarchar](250) NULL,
	[OtherTreatment] [nvarchar](250) NULL,
	[TreatmentStatus] [nvarchar](100) NULL,
	[DrugStarted] [int] NULL,
	[StartDate] [date] NULL,
	[StopDate] [date] NULL,
	[PhototopicalTreatment] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
