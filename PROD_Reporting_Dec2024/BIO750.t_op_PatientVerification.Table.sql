USE [Reporting]
GO
/****** Object:  Table [BIO750].[t_op_PatientVerification]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BIO750].[t_op_PatientVerification](
	[RowNum] [int] NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](20) NOT NULL,
	[EDCSiteStatus] [nvarchar](100) NULL,
	[SFSiteStatus] [nvarchar](150) NULL,
	[eventDefinitionId] [bigint] NULL,
	[VisitType] [nvarchar](30) NULL,
	[eventOccurrence] [int] NULL,
	[LastVisitDate] [date] NULL,
	[birthYear] [int] NULL,
	[gender] [nvarchar](20) NULL,
	[ProviderID] [int] NULL,
	[DateStarted] [nvarchar](50) NULL,
	[DrugStatus] [nvarchar](100) NULL,
	[StartCurrEligible] [nvarchar](200) NULL,
	[AddlStartCurrEligible] [nvarchar](800) NULL,
	[PastEligible] [nvarchar](800) NULL,
	[CurrPastOther] [nvarchar](800) NULL
) ON [PRIMARY]
GO
