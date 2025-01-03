USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_pv_SAEDetectionNonSerious]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_pv_SAEDetectionNonSerious](
	[vID] [bigint] NULL,
	[Site ID] [bigint] NOT NULL,
	[Subject ID] [nvarchar](50) NOT NULL,
	[Visit Date] [date] NULL,
	[Event Type] [varchar](33) NOT NULL,
	[Event Term] [nvarchar](4000) NULL,
	[Specified Other] [nvarchar](50) NULL,
	[Pathogen Code] [varchar](255) NULL,
	[Day of Onset] [varchar](2) NULL,
	[Month of Onset] [varchar](2) NULL,
	[Year of Onset] [varchar](4) NULL,
	[Last Page Updated - User] [nvarchar](200) NOT NULL,
	[Last Page Updated - Date] [datetime] NULL
) ON [PRIMARY]
GO
