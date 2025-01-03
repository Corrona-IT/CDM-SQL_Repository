USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_BiorepForms]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_BiorepForms](
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](60) NULL,
	[SubjectID] [varchar](32) NULL,
	[Cohort] [nvarchar](217) NULL,
	[ShortCohort] [nvarchar](8) NULL,
	[AssocVisitDate1] [date] NULL,
	[RegistryVisitDate1] [date] NULL,
	[RegistryVisitType1] [nvarchar](200) NULL,
	[RegistryEventOccurrence1] [int] NULL,
	[crfOccurrence] [int] NOT NULL,
	[CollectionAttempted1] [nvarchar](217) NULL,
	[AssocVisitDate2] [date] NULL,
	[RegistryVisitDate2] [date] NULL,
	[RegistryVisitType2] [nvarchar](200) NULL,
	[RegistryEventOccurrence2] [int] NULL,
	[CollectionAttempted2] [nvarchar](217) NULL
) ON [PRIMARY]
GO
