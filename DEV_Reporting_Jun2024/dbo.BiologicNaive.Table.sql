USE [Reporting]
GO
/****** Object:  Table [dbo].[BiologicNaive]    Script Date: 7/15/2024 11:18:58 AM ******/
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
