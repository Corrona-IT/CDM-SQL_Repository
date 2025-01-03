USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_op_VisitDrugs]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_op_VisitDrugs](
	[SiteID] [bigint] NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](100) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[TreatmentStatus] [nvarchar](50) NULL,
	[StartDate] [date] NULL,
	[StopDate] [date] NULL
) ON [PRIMARY]
GO
