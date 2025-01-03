USE [Reporting]
GO
/****** Object:  Table [RA100].[t_pv_NonSerious]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_pv_NonSerious](
	[Site ID] [int] NULL,
	[SiteStatus] [nvarchar](1024) NULL,
	[Subject ID] [nvarchar](1024) NULL,
	[VisitID] [bigint] NULL,
	[Visit Date] [date] NULL,
	[Visit Name] [nvarchar](1024) NULL,
	[Co-M/Tox/Inf] [nvarchar](1024) NULL,
	[Specified Other] [nvarchar](1024) NULL,
	[Onset Date] [nvarchar](1024) NULL,
	[DOI At Visit] [nvarchar](1024) NULL,
	[Other Specify] [nvarchar](1024) NULL,
	[Last Modification Date] [date] NULL
) ON [PRIMARY]
GO
