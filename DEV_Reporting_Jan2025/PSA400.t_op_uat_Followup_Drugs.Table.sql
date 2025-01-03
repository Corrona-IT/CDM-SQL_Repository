USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_uat_Followup_Drugs]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_uat_Followup_Drugs](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](20) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitOrder] [int] NULL,
	[VisitDate] [date] NULL,
	[NextVisit] [int] NULL,
	[PageDescription] [nvarchar](250) NULL,
	[PageSequence] [int] NULL,
	[PageStatus] [nvarchar](250) NULL,
	[Cohort] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[TreatmentStartYear] [int] NULL,
	[TreatmentStartMonth] [int] NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[ChangeSinceLastVisit] [nvarchar](100) NULL,
	[CurrentDose] [nvarchar](150) NULL,
	[PastDose] [nvarchar](150) NULL,
	[FirstTimeUse] [nvarchar](10) NULL
) ON [PRIMARY]
GO
