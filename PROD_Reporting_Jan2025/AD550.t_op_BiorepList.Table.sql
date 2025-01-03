USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_BiorepList]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_BiorepList](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](60) NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[gender] [nvarchar](217) NULL,
	[YOB] [int] NULL,
	[ProviderID] [int] NULL,
	[OrderNbr] [bigint] NULL,
	[Cohort] [nvarchar](217) NULL,
	[ShortCohort] [nvarchar](8) NULL,
	[FormSection] [varchar](12) NOT NULL,
	[CollectionAttempted] [nvarchar](217) NULL,
	[CollectionDate] [date] NULL,
	[BiospecimenShipped] [nvarchar](217) NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](200) NULL,
	[eventId] [int] NULL,
	[eventOccurrence] [int] NULL,
	[DrugHierarchy] [int] NULL,
	[Treatment] [nvarchar](502) NULL,
	[TreatmentStatus] [nvarchar](100) NULL,
	[DrugStarted] [nvarchar](30) NULL,
	[StartDate] [date] NULL,
	[OtherTreatments] [nvarchar](max) NULL,
	[PhototopicalTreatment] [nvarchar](4000) NULL,
	[crfName] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
