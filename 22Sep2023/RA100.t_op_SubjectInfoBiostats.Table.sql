USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SubjectInfoBiostats]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SubjectInfoBiostats](
	[site_id] [int] NULL,
	[optional_id] [bigint] NULL,
	[TMImmutableID] [bigint] NULL,
	[Enrollment_date] [date] NULL,
	[Year_of_birth] [float] NULL,
	[Gender_sex] [nvarchar](255) NULL,
	[RA_onset_year] [nvarchar](255) NULL,
	[Diagnosis] [nvarchar](255) NULL,
	[optional_id_not_found] [bigint] NULL
) ON [PRIMARY]
GO
