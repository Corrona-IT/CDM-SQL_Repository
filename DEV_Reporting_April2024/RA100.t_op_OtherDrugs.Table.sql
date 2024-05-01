USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_OtherDrugs]    Script Date: 5/1/2024 1:26:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_OtherDrugs](
	[VisitId] [bigint] NULL,
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[SpecifyOther] [nvarchar](300) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL
) ON [PRIMARY]
GO
