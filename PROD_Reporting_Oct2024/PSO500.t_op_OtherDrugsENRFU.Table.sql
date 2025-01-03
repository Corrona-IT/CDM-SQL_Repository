USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_OtherDrugsENRFU]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_OtherDrugsENRFU](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[VisitId] [bigint] NULL,
	[TrlObjectVisitId] [bigint] NULL,
	[VisitName] [nvarchar](100) NULL,
	[EnrollingProviderID] [int] NULL,
	[VisitDate] [date] NULL,
	[CRFName] [nvarchar](250) NULL,
	[DrugName] [nvarchar](150) NULL,
	[OtherSpecify] [nvarchar](300) NULL
) ON [PRIMARY]
GO
