USE [Reporting]
GO
/****** Object:  Table [MS700].[t_op_E&E]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MS700].[t_op_E&E](
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar](50) NOT NULL,
	[ProviderID] [int] NULL,
	[PatientYOB] [int] NULL,
	[AgeAtEnrollment] [float] NULL,
	[VisitDate] [date] NULL,
	[DateofDiagnosis] [date] NULL,
	[TreatmentName] [nvarchar](255) NULL,
	[OtherTreatment] [nvarchar](255) NULL,
	[TreatmentNameFull] [nvarchar](255) NULL,
	[EligibleTreatment] [nvarchar](20) NULL,
	[TreatmentStatus] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[enteredStartDate] [nvarchar](30) NULL,
	[DataCollectionType] [nvarchar](200) NULL,
	[RegistryEnrollmentStatus] [nvarchar](255) NULL,
	[EligibilityReview] [nvarchar](100) NULL,
	[VisitCompletion] [nvarchar](255) NULL
) ON [PRIMARY]
GO
