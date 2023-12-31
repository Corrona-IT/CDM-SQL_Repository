USE [Reporting]
GO
/****** Object:  Table [POWER].[t_op_CaseMgmtCompliance]    Script Date: 10/16/2023 4:13:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [POWER].[t_op_CaseMgmtCompliance](
	[PatientID] [bigint] NOT NULL,
	[StudyStartDate] [date] NULL,
	[MedicationStartDate] [date] NULL,
	[Medication] [nvarchar](500) NULL,
	[PatientStatus] [nvarchar](50) NULL,
	[StudyStateID] [int] NULL,
	[AssessmentWeek] [int] NULL,
	[Day3Date] [date] NULL,
	[LastAdmitDate] [date] NULL,
	[NumberOfAssessments] [bigint] NULL,
	[StudyOrMedStartDate] [date] NULL,
	[AssessmentWeekStart] [date] NULL,
	[PreviousAssessmentComplete] [nvarchar](10) NULL,
	[CurrentAssessmentComplete] [nvarchar](10) NULL,
	[ReportRunWeekday] [nvarchar](25) NULL,
	[Compliant] [nvarchar](10) NULL
) ON [PRIMARY]
GO
