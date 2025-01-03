USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_PV_SAE_DetectionReport]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_PV_SAE_DetectionReport](
	[vID] [bigint] NULL,
	[Site ID] [bigint] NOT NULL,
	[Subject ID] [nvarchar](50) NOT NULL,
	[Provider ID] [smallint] NULL,
	[Page Description] [nvarchar](255) NOT NULL,
	[Event Type] [nvarchar](255) NOT NULL,
	[Event Term] [nvarchar](50) NULL,
	[OtherEventSpecify] [nvarchar](50) NULL,
	[Date of Event Onset (TAE)] [date] NULL,
	[Visit Date] [date] NULL,
	[Age] [int] NULL,
	[YOB] [nvarchar](4) NULL,
	[Gender] [nvarchar](6) NULL,
	[Ethnicity] [nvarchar](24) NULL,
	[Race] [nvarchar](157) NULL,
	[SPA Disease Duration] [int] NULL,
	[Event Outcome] [nvarchar](33) NULL,
	[Death] [varchar](3) NOT NULL,
	[Event Confirmation Status/Can you confirm the Event?] [nvarchar](68) NULL,
	[Not an Event (explanation)] [nvarchar](301) NULL,
	[Supporting documents] [nvarchar](28) NULL,
	[Serious outcomes] [varchar](16) NULL,
	[Hospitalized] [varchar](3) NOT NULL,
	[Exposed Bio/Sm Mol - Follow-Up] [nvarchar](max) NULL,
	[Changes made today] [varchar](24) NULL,
	[Attribution to Drug(s) y/n] [varchar](98) NULL,
	[Attributed Drug(s)] [nvarchar](2318) NULL,
	[Additional Comments or Narrative] [nvarchar](4000) NULL,
	[Form status] [varchar](10) NOT NULL,
	[Last Page Updated – Name] [nvarchar](100) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
