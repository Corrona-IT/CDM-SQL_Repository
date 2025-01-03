USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_SiteScorecard]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_SiteScorecard](
	[SiteID] [int] NULL,
	[SiteStatus] [varchar](8) NULL,
	[SalesforceStatus] [varchar](20) NULL,
	[TopEnrollingSite] [varchar](3) NULL,
	[MonthsActive] [float] NULL,
	[NonExited] [int] NULL,
	[Exited] [int] NULL,
	[TotalVisits] [int] NULL,
	[AvgVisitsPerMonth] [decimal](5, 1) NULL,
	[NineMonthActiveCount] [int] NULL,
	[ConfirmedEvents] [int] NULL,
	[ExpectedEvents] [int] NULL,
	[RetrievedDocs] [int] NULL,
	[DocRetrievalPercent] [float] NULL,
	[AllTimeConfirmedEvents] [int] NULL,
	[AllTimeRetrievedDocs] [int] NULL,
	[AllTimeDocRetrievalPercent] [float] NULL,
	[ActivePercent] [float] NULL,
	[ConsistencyRating] [varchar](13) NULL,
	[DataContributionAllTime] [numeric](37, 19) NULL,
	[RunningDataContributionAllTime] [numeric](37, 19) NULL,
	[Top80AllTime] [nvarchar](10) NULL,
	[DataContribution12Mos] [numeric](37, 19) NULL,
	[RunningDataContribution12Mos] [numeric](37, 19) NULL,
	[Top8012Mos] [nvarchar](10) NULL,
	[ConductedICCVs] [int] NULL
) ON [PRIMARY]
GO
