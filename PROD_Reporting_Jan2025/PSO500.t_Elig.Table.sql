USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_Elig]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_Elig](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[Age and Diagnosis Criteria] [varchar](100) NULL,
	[Biologic Criteria] [varchar](250) NULL,
	[Non-biologic Criteria] [varchar](250) NULL,
	[Eligible Treatment] [nvarchar](1024) NULL,
	[YearofBirth] [nvarchar](1024) NULL,
	[AtLeast18] [varchar](3) NULL,
	[PsODiagnosis] [int] NULL,
	[PsADiagnosis] [int] NULL,
	[Clinical Diagnosis Form Status] [nvarchar](50) NULL,
	[Non-Bio Form Status] [nvarchar](50) NULL,
	[CRF Name - Current Non Biologic] [nvarchar](1024) NULL,
	[Start date - Current Non-Biologic] [date] NULL,
	[Current Non-Biologic] [nvarchar](1024) NULL,
	[Current Non-Biologic - Other] [nvarchar](1024) NULL,
	[Days Since Current Non-Biologic Start to Enrollment Date] [int] NULL,
	[Current Non-Biologic - First Ever Use] [nvarchar](1024) NULL,
	[CRF Name - Past Non-Biologic] [nvarchar](1024) NULL,
	[Stop date - Past Non-Biologic] [smalldatetime] NULL,
	[Days Since Past Non-Biologic Stop to Current Non-Biologic Start] [int] NULL,
	[Days Since Past NonBio Stop to NonBio Initiated] [int] NULL,
	[Past Non-Biologic] [nvarchar](1024) NULL,
	[Past Non-Biologic - Other] [nvarchar](1024) NULL,
	[Past Non-Biologic - First Ever Use] [nvarchar](1024) NULL,
	[Past Non-Biologic Same as Current Non-Biologic] [varchar](3) NULL,
	[Current NonBio Same as NonBio Start Today] [varchar](3) NULL,
	[Bio Form Status] [nvarchar](50) NULL,
	[CRF Name - Current Biologic] [nvarchar](1024) NULL,
	[Start date - Current Biologic] [date] NULL,
	[Days Since Current Biologic Start to Enrollment] [int] NULL,
	[Current Biologic] [nvarchar](1024) NULL,
	[Current Biologic - Other] [nvarchar](1024) NULL,
	[Current Biologic - First Ever Use] [nvarchar](1024) NULL,
	[CRF Name - Past Biologic] [nvarchar](1024) NULL,
	[Stop date - Past Biologic] [smalldatetime] NULL,
	[Past Biologic] [nvarchar](1024) NULL,
	[Past Biologic - Other] [nvarchar](1024) NULL,
	[Past Biologic - First Ever Use] [nvarchar](1024) NULL,
	[Current Bio Same as Past Bio] [varchar](3) NULL,
	[Days Since Past Bio Stop to Current Bio Start] [int] NULL,
	[Bio Prescribed Today Same as Past Bio] [varchar](3) NULL,
	[Days Since Past Bio Stop to Initiated Bio] [int] NULL,
	[Current Bio Stopped Today] [varchar](3) NULL,
	[Changes Today Form Status] [nvarchar](50) NULL,
	[TreatmentStartedAtENRVis] [varchar](3) NULL,
	[TreatmentStopped AtENRVis] [varchar](3) NULL,
	[PSO Treatment initiated at ENR visit1] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit1 - Other] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit2] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit2 - Other] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit3] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit3 - Other] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit1] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit1 - Other] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit2] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit2 - Other] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit3] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit3 - Other] [nvarchar](1024) NULL
) ON [PRIMARY]
GO
