USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_Enrollment_Drugs]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_Enrollment_Drugs](
	[VisitId] [nvarchar](20) NULL,
	[PatientId] [nvarchar](20) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitType] [nvarchar](40) NULL,
	[VisitDate] [date] NULL,
	[PageDescription] [nvarchar](150) NULL,
	[Page4FormStatus] [nvarchar](40) NULL,
	[Page5FormStatus] [nvarchar](40) NULL,
	[NoTreatment] [int] NULL,
	[Treatment] [nvarchar](350) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[CalcStartDate] [date] NULL,
	[CurrentDose] [nvarchar](100) NULL,
	[CurrentFrequency] [nvarchar](250) NULL,
	[MostRecentDoseNotCurrentDose] [nvarchar](200) NULL,
	[MostRecentPastUseDate] [nvarchar](20) NULL
) ON [PRIMARY]
GO
