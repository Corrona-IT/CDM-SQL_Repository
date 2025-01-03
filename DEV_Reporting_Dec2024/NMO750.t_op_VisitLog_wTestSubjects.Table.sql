USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_op_VisitLog_wTestSubjects]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_op_VisitLog_wTestSubjects](
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](10) NOT NULL,
	[patientId] [bigint] NOT NULL,
	[birthYear] [int] NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](200) NULL,
	[eventDefinitionId] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[EDCVisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](20) NULL,
	[VisitYear] [int] NULL,
	[hasData] [nvarchar](10) NULL,
	[CompletionStatus] [nvarchar](50) NULL,
	[Registry] [nvarchar](20) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[pay_enr_eligible] [int] NULL,
	[pay_enr_exception_granted] [int] NULL,
	[pay_visit_confirmed_incomplete] [int] NULL,
	[visitRescheduled] [int] NULL,
	[subjectFormNotDone] [int] NULL,
	[TSQM9NotDone] [int] NULL,
	[EDSSPermIncomplete] [int] NULL,
	[pay_earlyfu_oow] [int] NULL,
	[pay_earlyfu_status] [int] NULL,
	[pay_earlyfu_pay_exception] [int] NULL,
	[IncompleteVisit] [nvarchar](20) NULL,
	[EligibleVisit] [nvarchar](20) NULL
) ON [PRIMARY]
GO
