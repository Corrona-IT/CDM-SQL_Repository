USE [Reporting]
GO
/****** Object:  Table [dbo].[BiologicNaive]    Script Date: 1/31/2024 10:11:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BiologicNaive](
	[VisitID] [nvarchar](20) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[NumberOfBiologics] [int] NULL
) ON [PRIMARY]
GO
