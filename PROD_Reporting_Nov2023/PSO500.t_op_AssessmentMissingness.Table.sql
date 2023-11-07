USE [Reporting]
GO
/****** Object:  Table [PSO500].[t_op_AssessmentMissingness]    Script Date: 11/7/2023 11:31:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSO500].[t_op_AssessmentMissingness](
	[SiteID] [int] NULL,
	[SubjectID] [nvarchar](11) NULL,
	[VisitType] [nvarchar](20) NULL,
	[VisitDate] [date] NULL,
	[VisitCode] [nvarchar](100) NULL,
	[BSA] [int] NULL,
	[IGA] [int] NULL,
	[PASI] [int] NULL,
	[PGA] [int] NULL,
	[EQ5D] [int] NULL,
	[DLQI] [int] NULL
) ON [PRIMARY]
GO
