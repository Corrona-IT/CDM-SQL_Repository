USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectInfoBiostatsRAOnly]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectInfoBiostatsRAOnly](
	[site_id] [int] NULL,
	[optional_id] [bigint] NULL,
	[TMImmutableID] [bigint] NULL,
	[Enrollment_date] [date] NULL,
	[Year_of_birth] [float] NULL,
	[Gender_sex] [nvarchar](255) NULL,
	[RA_onset_year] [nvarchar](255) NULL,
	[exit_date] [date] NULL,
	[Diagnosis] [nvarchar](255) NULL,
	[optional_id_not_found] [bigint] NULL,
	[first_visit_date] [date] NULL,
	[last_visit_date] [date] NULL
) ON [PRIMARY]
GO
