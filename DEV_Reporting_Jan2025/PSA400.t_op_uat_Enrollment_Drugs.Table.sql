USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_uat_Enrollment_Drugs]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_uat_Enrollment_Drugs](
	[VisitID] [bigint] NULL,
	[SiteID] [bigint] NULL,
	[SiteStatus] [varchar](8) NOT NULL,
	[SubjectID] [nvarchar](100) NULL,
	[VisitType] [nvarchar](100) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [tinyint] NULL,
	[YearOfBirth] [smallint] NULL,
	[YearOfDiagnosis] [smallint] NULL,
	[Diagnosis] [nvarchar](max) NULL,
	[EligibilityVersion] [varchar](3) NOT NULL,
	[DrugHierarchy] [bigint] NULL,
	[PageDescription] [nvarchar](100) NULL,
	[TreatmentName] [nvarchar](72) NULL,
	[TreatmentStartYear] [smallint] NULL,
	[TreatmentStartMonth] [smallint] NULL,
	[TreatmentStartDate] [date] NULL,
	[TreatmentStopYear] [smallint] NULL,
	[TreatmentStopMonth] [smallint] NULL,
	[CurrentDose] [nvarchar](30) NULL,
	[PastDose] [nvarchar](30) NULL,
	[DrugOfInterest] [nvarchar](72) NULL,
	[AdditionalDOI] [nvarchar](max) NULL,
	[PageStatus] [nvarchar](18) NULL,
	[DrugReqSatisfied] [varchar](3) NULL,
	[FirstTimeUse] [varchar](3) NULL,
	[ChangesToday] [nvarchar](22) NULL,
	[Cohort] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
