USE [Reporting]
GO
/****** Object:  Table [dbo].[t_op_MULTIREG_VisitAccruals]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_op_MULTIREG_VisitAccruals](
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
