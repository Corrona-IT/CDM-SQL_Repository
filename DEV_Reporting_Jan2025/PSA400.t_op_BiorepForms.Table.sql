USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_BiorepForms]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_BiorepForms](
	[SiteID] [bigint] NULL,
	[SiteStatus] [varchar](20) NULL,
	[SubjectID] [nvarchar](100) NULL,
	[Cohort] [nvarchar](76) NULL,
	[CollectionType] [varchar](12) NOT NULL,
	[AssocVisitDate] [date] NULL,
	[CollectionAttempted] [nvarchar](3) NULL,
	[CollectionDate] [date] NULL,
	[BiospecimenShipped] [nvarchar](3) NULL,
	[ReasonNotShipped] [nvarchar](207) NULL
) ON [PRIMARY]
GO
