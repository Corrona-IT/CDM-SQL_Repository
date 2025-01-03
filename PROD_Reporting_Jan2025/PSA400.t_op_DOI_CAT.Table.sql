USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_DOI_CAT]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_DOI_CAT](
	[VisitID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](20) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[NextVisitDrugOrder] [int] NULL,
	[VisitOrder] [int] NULL,
	[NextVisit] [int] NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL,
	[YearofBirth] [int] NULL,
	[YearOfDiagnosis] [int] NULL,
	[Diagnosis] [nvarchar](250) NULL,
	[EligibilityVersion] [nvarchar](25) NULL,
	[DrugHierarchy] [int] NULL,
	[PageDescription] [nvarchar](250) NULL,
	[PageStatus] [nvarchar](250) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[TreatmentStartYear] [int] NULL,
	[TreatmentStartMonth] [int] NULL,
	[TreatmentStopYear] [int] NULL,
	[TreatmentStopMonth] [int] NULL,
	[ChangeSinceLastVisit] [varchar](100) NULL,
	[CurrentDose] [varchar](75) NULL,
	[PastDose] [varchar](75) NULL,
	[DrugOfInterest] [nvarchar](350) NULL,
	[AdditionalDOI] [nvarchar](1000) NULL,
	[DOIInitiationStatus] [nvarchar](150) NULL,
	[SubscriberDOI] [nvarchar](50) NULL,
	[DrugReqSatisfied] [nvarchar](50) NULL,
	[FirstTimeUse] [nvarchar](10) NULL,
	[ChangesToday] [nvarchar](150) NULL,
	[Cohort] [nvarchar](250) NULL,
	[RegistryEnrollmentStatus] [nvarchar](250) NULL,
	[ReviewOutcome] [nvarchar](250) NULL,
	[DOIFUMatch] [nvarchar](100) NULL,
	[NextVisitDrugHierarchy] [int] NULL,
	[NextVisitTreatmentName] [nvarchar](350) NULL,
	[NextVisitDate] [date] NULL,
	[NextVisitChanges] [nvarchar](50) NULL,
	[NextVisitStatus] [nvarchar](150) NULL,
	[InitiationStatus] [nvarchar](250) NULL,
	[ConfirmationVisitDate] [date] NULL,
	[SubscriberDOIAccrual] [nvarchar](25) NULL
) ON [PRIMARY]
GO
