USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_DataEntryCompletion]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_DataEntryCompletion](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitEventType] [nvarchar](150) NULL,
	[VisitSequence] [int] NOT NULL,
	[VisitDate] [date] NULL,
	[IncompleteMDForms] [nvarchar](600) NULL,
	[IncompleteSUForms] [nvarchar](600) NULL
) ON [PRIMARY]
GO
