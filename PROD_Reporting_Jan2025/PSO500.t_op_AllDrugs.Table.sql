USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_AllDrugs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_AllDrugs](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[PatientId] [bigint] NOT NULL,
	[SubjectID] [varchar](30) NOT NULL,
	[VisitType] [nvarchar](150) NULL,
	[VisitDate] [date] NULL,
	[crfName] [nvarchar](250) NULL,
	[crfStatus] [nvarchar](150) NULL,
	[Treatment] [nvarchar](250) NULL,
	[otherTreatment] [nvarchar](250) NULL,
	[TreatmentStatus] [nvarchar](150) NULL,
	[FirstDoseToday] [nvarchar](150) NULL,
	[firstUse] [nvarchar](25) NULL,
	[enteredStartDate] [nvarchar](12) NULL,
	[startDate] [date] NULL,
	[StartReasons] [nvarchar](30) NULL,
	[changeDate] [date] NULL,
	[changeReasons] [nvarchar](150) NULL,
	[Dose] [nvarchar](150) NULL,
	[Frequency] [nvarchar](150) NULL,
	[stopDate] [date] NULL,
	[StopReasons] [nvarchar](30) NULL
) ON [PRIMARY]
GO
