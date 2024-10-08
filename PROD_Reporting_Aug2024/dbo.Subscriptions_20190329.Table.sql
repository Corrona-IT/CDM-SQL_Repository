USE [Reporting]
GO
/****** Object:  Table [dbo].[Subscriptions_20190329]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subscriptions_20190329](
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[Report_OID] [uniqueidentifier] NOT NULL,
	[Locale] [nvarchar](128) NOT NULL,
	[InactiveFlags] [int] NOT NULL,
	[ExtensionSettings] [ntext] NULL,
	[ModifiedByID] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[Description] [nvarchar](512) NULL,
	[LastStatus] [nvarchar](260) NULL,
	[EventType] [nvarchar](260) NOT NULL,
	[MatchData] [ntext] NULL,
	[LastRunTime] [datetime] NULL,
	[Parameters] [ntext] NULL,
	[DataSettings] [ntext] NULL,
	[DeliveryExtension] [nvarchar](260) NULL,
	[Version] [int] NOT NULL,
	[ReportZone] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
