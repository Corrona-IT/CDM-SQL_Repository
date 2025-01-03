USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_FUWithStartsAndNextFU]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_FUWithStartsAndNextFU](
	[VisitOrder] [int] NOT NULL,
	[NextVisitNumber] [int] NOT NULL,
	[VisitId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](30) NULL,
	[SubjectID] [bigint] NOT NULL,
	[ProviderID] [varchar](10) NULL,
	[YearofBirth] [int] NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[OnsetYear] [int] NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[CalcChangesToday] [nvarchar](300) NULL,
	[DrugOfInterest] [nvarchar](300) NULL,
	[StartDate] [date] NULL,
	[CalcStartDate] [nvarchar](6) NULL,
	[FirstUseDate] [nvarchar](6) NULL,
	[DOIInitiationStatus] [varchar](150) NULL,
	[SubscriberDOI] [varchar](10) NULL,
	[EligibilityVersion] [int] NULL,
	[TwelveMonthInitiationRule] [varchar](25) NULL,
	[FirstTimeUse] [varchar](30) NULL,
	[PriorJAKiUse] [varchar](10) NULL,
	[NextVisitStatus] [nvarchar](50) NULL,
	[NextVisitOrder] [int] NULL,
	[NextVisitDate] [date] NULL,
	[NextVisitNoTreatment] [int] NULL,
	[ExitDate] [date] NULL,
	[NextVisitDOIStatus] [nvarchar](50) NULL,
	[NextVisitFirstUseDate] [nvarchar](6) NULL,
	[NextVisitTreatmentName] [nvarchar](300) NULL,
	[NextVisitChanges] [nvarchar](50) NULL,
	[NextVisitCalcChangesToday] [nvarchar](300) NULL,
	[NextVisitCalcStartDate] [date] NULL,
	[NextVisitDose] [nvarchar](50) NULL,
	[NextVisitLastNotCurrentDose] [nvarchar](50) NULL,
	[NextVisitPastUseDate] [nvarchar](10) NULL,
	[ConfirmationVisitDate] [date] NULL,
	[InitiationStatus] [nvarchar](150) NULL,
	[SubscriberDOIAccrual] [nvarchar](200) NULL
) ON [PRIMARY]
GO
