USE [Reporting]
GO
/****** Object:  Table [RA102].[t_op_EarlyFU]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_op_EarlyFU](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [varchar](50) NULL,
	[CalcVisitSequence] [int] NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[DaysSinceLastVisit] [bigint] NULL,
	[vID] [bigint] NULL,
	[OutOfWindow] [varchar](150) NULL,
	[EarlyVisitRulesSatisfied] [varchar](100) NULL,
	[ExceptionGranted] [varchar](100) NULL,
	[ExceptionReason] [varchar](250) NULL
) ON [PRIMARY]
GO
