USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_FollowUp_Drugs]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_FollowUp_Drugs](
	[VisitOrder] [int] NULL,
	[VisitId] [nvarchar](20) NULL,
	[PatientId] [nvarchar](20) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[PageDescription] [nvarchar](100) NULL,
	[Page4FormStatus] [nvarchar](30) NULL,
	[Page5FormStatus] [nvarchar](30) NULL,
	[NoTreatment] [int] NULL,
	[RowID] [int] NULL,
	[Treatment] [nvarchar](300) NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[CalcStartDate] [date] NULL,
	[CurrentDose] [nvarchar](100) NULL,
	[CurrentFrequency] [nvarchar](150) NULL,
	[MostRecentDoseNotCurrentDose] [nvarchar](100) NULL,
	[MostRecentPastUseDate] [nvarchar](20) NULL
) ON [PRIMARY]
GO
