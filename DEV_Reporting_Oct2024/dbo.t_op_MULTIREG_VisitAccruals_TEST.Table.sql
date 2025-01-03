USE [Reporting]
GO
/****** Object:  Table [dbo].[t_op_MULTIREG_VisitAccruals_TEST]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_op_MULTIREG_VisitAccruals_TEST](
	[Registry] [nvarchar](255) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](70) NULL,
	[SFSiteStatus] [nvarchar](80) NULL,
	[SubjectID] [nvarchar](25) NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](50) NULL,
	[DataCollectionType] [nvarchar](150) NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [bigint] NULL
) ON [PRIMARY]
GO
