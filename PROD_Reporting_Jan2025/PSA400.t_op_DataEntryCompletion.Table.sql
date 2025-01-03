USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_DataEntryCompletion]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_DataEntryCompletion](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[VisitType] [nvarchar](150) NULL,
	[VisitSequence] [int] NOT NULL,
	[VisitDate] [date] NULL,
	[IncompleteMDForms] [nvarchar](600) NULL,
	[IncompleteSUForms] [nvarchar](600) NULL
) ON [PRIMARY]
GO
