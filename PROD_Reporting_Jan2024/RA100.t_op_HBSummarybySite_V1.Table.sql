USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_HBSummarybySite_V1]    Script Date: 1/31/2024 10:27:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_HBSummarybySite_V1](
	[SiteID] [int] NOT NULL,
	[NbrinClinEDC] [int] NOT NULL,
	[NbrInHBEDC] [int] NULL,
	[NbrMatching] [int] NULL,
	[ActionRequired] [varchar](4) NULL
) ON [PRIMARY]
GO
