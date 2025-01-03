USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_BiorepList]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_BiorepList](
	[SiteID] [bigint] NULL,
	[SubjectID] [nvarchar](100) NULL,
	[gender] [nvarchar](6) NULL,
	[YOB] [smallint] NULL,
	[OrderNbr] [bigint] NULL,
	[Cohort] [nvarchar](76) NULL,
	[FormSection] [varchar](12) NOT NULL,
	[CollectionAttempted] [nvarchar](3) NULL,
	[CollectionDate] [date] NULL,
	[BiospecimenShipped] [nvarchar](3) NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](100) NULL,
	[Treatment] [nvarchar](350) NULL,
	[TreatmentStatus] [nvarchar](50) NULL,
	[StartDate] [date] NULL,
	[OtherTreatments] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
