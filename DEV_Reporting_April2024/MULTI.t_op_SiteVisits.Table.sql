USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_op_SiteVisits]    Script Date: 5/1/2024 1:26:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_op_SiteVisits](
	[Registry] [varchar](7) NOT NULL,
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](1024) NULL,
	[TopEnrollingSite] [nvarchar](80) NULL,
	[VisitType] [varchar](50) NULL,
	[Total] [int] NULL
) ON [PRIMARY]
GO
