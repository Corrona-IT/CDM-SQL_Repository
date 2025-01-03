USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectVisits2]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectVisits2](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](30) NULL,
	[TrlObjectSiteID] [int] NULL,
	[Site_TrlObjectId] [int] NULL,
	[PatientId] [bigint] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[YOB] [int] NULL,
	[OnsetYear] [int] NULL,
	[TrlObjectPatientID] [bigint] NULL,
	[Subject_TrlObjectId] [bigint] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[EnrollingProviderID] [int] NULL,
	[VisitProviderID] [int] NULL,
	[VisitID] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[OrderNo] [int] NULL,
	[TrlObjectId] [bigint] NULL,
	[LastChangeDateTime] [datetime] NULL,
	[VisitSigned] [int] NULL
) ON [PRIMARY]
GO
