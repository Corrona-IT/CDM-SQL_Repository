USE [Reporting]
GO
/****** Object:  Table [dbo].[BiologicNaive]    Script Date: 11/13/2024 12:16:33 PM ******/
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
