USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectVisits]    Script Date: 11/13/2024 1:41:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectVisits](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](30) NULL,
	[PatientId] [bigint] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[YOB] [int] NULL,
	[Gender] [varchar](30) NULL,
	[OnsetYear] [int] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[EnrollingProviderID] [int] NULL,
	[VisitProviderID] [int] NULL,
	[VisitID] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[OrderNo] [int] NULL,
	[LastChangeDateTime] [datetime] NULL,
	[VisitSigned] [int] NULL
) ON [PRIMARY]
GO
