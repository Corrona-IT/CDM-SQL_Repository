USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_BiorepForms]    Script Date: 1/3/2025 4:53:49 PM ******/
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
	[CollectionType] [varchar](12) NOT NULL,
	[AssocVisitDate] [date] NULL,
	[crfOccurrence] [int] NOT NULL,
	[CollectionAttempted] [nvarchar](217) NULL,
	[CollectionDate] [date] NULL,
	[BiospecimenShipped] [nvarchar](217) NULL,
	[ReasonNotShipped] [nvarchar](262) NULL
) ON [PRIMARY]
GO
