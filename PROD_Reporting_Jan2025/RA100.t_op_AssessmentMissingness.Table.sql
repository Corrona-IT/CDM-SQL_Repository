USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_AssessmentMissingness]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_AssessmentMissingness](
	[SiteID] [int] NULL,
	[SubjectID] [nvarchar](9) NULL,
	[VisitType] [nvarchar](20) NULL,
	[VisitDate] [date] NULL,
	[VisitCode] [nvarchar](100) NULL,
	[28S] [int] NULL,
	[28T] [int] NULL,
	[PGA] [int] NULL,
	[HAQ] [int] NULL,
	[PGV] [int] NULL,
	[EQ5] [int] NULL
) ON [PRIMARY]
GO
