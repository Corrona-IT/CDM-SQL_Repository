USE [Reporting]
GO
/****** Object:  Table [NMO750].[t_op_PersonalInformation]    Script Date: 6/6/2024 9:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [NMO750].[t_op_PersonalInformation](
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](12) NULL,
	[PatientID] [bigint] NULL,
	[EnrollmentDate] [date] NULL,
	[MissingInfo] [nvarchar](100) NULL
) ON [PRIMARY]
GO
