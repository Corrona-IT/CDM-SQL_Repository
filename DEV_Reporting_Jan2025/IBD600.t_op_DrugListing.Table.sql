USE [Reporting]
GO
/****** Object:  Table [IBD600].[t_op_DrugListing]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IBD600].[t_op_DrugListing](
	[ROWNUM] [int] NULL,
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[Gender] [nvarchar](10) NULL,
	[YOB] [int] NULL,
	[Eligible] [nvarchar](10) NULL,
	[Diagnosis] [nvarchar](100) NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](50) NULL,
	[CalcVisitSequence] [int] NULL,
	[BioRepositoryAssoc] [nvarchar](10) NULL,
	[BioRepositoryVisitType] [nvarchar](70) NULL,
	[NonSterNonAntiBactTrxt] [nvarchar](10) NULL,
	[DrugType] [nvarchar](200) NULL,
	[DrugName] [nvarchar](350) NULL,
	[OtherDrugSpecify] [nvarchar](350) NULL,
	[NoPriorUse] [nvarchar](10) NULL,
	[PastUse] [nvarchar](10) NULL,
	[CurrentUse] [nvarchar](10) NULL,
	[ChangesAtVisit] [nvarchar](200) NULL,
	[FirstDoseAdminTodayVisit] [nvarchar](10) NULL,
	[StartDate] [nvarchar](20) NULL,
	[StopDate] [nvarchar](20) NULL,
	[Dose] [nvarchar](40) NULL,
	[Freq] [nvarchar](40) NULL
) ON [PRIMARY]
GO
