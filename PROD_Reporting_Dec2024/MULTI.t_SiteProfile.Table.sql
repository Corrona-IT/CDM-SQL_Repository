USE [Reporting]
GO
/****** Object:  Table [MULTI].[t_SiteProfile]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MULTI].[t_SiteProfile](
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
	[ConsistencyRating] [varchar](13) NULL
) ON [PRIMARY]
GO
