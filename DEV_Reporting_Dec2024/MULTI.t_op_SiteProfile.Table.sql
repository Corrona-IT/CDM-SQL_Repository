USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_op_SiteProfile]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_op_SiteProfile](
	[Registry] [varchar](7) NOT NULL,
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](1024) NULL,
	[SalesforceStatus] [varchar](20) NULL,
	[TopEnrollingSite] [nvarchar](80) NULL,
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
	[DataContributionAllTime] [numeric](10, 8) NULL,
	[RunningDataContributionAllTime] [numeric](10, 8) NULL,
	[Top80AllTime] [nvarchar](10) NULL,
	[DataContribution12Mos] [numeric](10, 8) NULL,
	[RunningDataContribution12Mos] [numeric](10, 8) NULL,
	[Top8012Mos] [nvarchar](10) NULL,
	[ConductedICCVs] [int] NULL
) ON [PRIMARY]
GO
