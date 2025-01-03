USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectVisits_wNoDates]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectVisits_wNoDates](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](30) NULL,
	[PatientId] [bigint] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[YOB] [int] NULL,
	[OnsetYear] [int] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL,
	[VisitID] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[OrderNo] [int] NULL,
	[LastChangeDateTime] [datetime] NULL,
	[VisitSigned] [int] NULL
) ON [PRIMARY]
GO
