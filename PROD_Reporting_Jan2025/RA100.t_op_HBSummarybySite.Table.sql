USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_HBSummarybySite]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_HBSummarybySite](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar](10) NULL,
	[NbrinClinEDC] [int] NOT NULL,
	[NbrInHBEDC] [int] NULL,
	[NbrMatching] [int] NULL,
	[ActionRequired] [varchar](4) NULL
) ON [PRIMARY]
GO
