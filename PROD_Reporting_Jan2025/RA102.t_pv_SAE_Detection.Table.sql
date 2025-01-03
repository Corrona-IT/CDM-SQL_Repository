USE [Reporting]
GO
/****** Object:  Table [RA102].[t_pv_SAE_Detection]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_pv_SAE_Detection](
	[vID] [bigint] NOT NULL,
	[Site ID] [int] NOT NULL,
	[Subject ID] [bigint] NOT NULL,
	[Provider ID] [int] NULL,
	[Page Description] [nvarchar](255) NOT NULL,
	[Event Type] [nvarchar](255) NOT NULL,
	[Event Term] [nvarchar](255) NULL,
	[Event Specify] [nvarchar](255) NULL,
	[Date of Event Onset] [date] NULL,
	[Visit Date] [date] NULL,
	[Age] [int] NULL,
	[Gender] [nvarchar](33) NULL,
	[Ethnicity] [nvarchar](100) NULL,
	[RA Disease Duration] [int] NULL,
	[Outcome] [nvarchar](50) NULL,
	[Death] [varchar](16) NULL,
	[Report Type] [nvarchar](300) NULL,
	[No Event(specify)] [nvarchar](1500) NULL,
	[S Docs] [nvarchar](1500) NULL,
	[Hospitalized] [nvarchar](10) NULL,
	[Bio/Sm Mol - Change Today] [nvarchar](4000) NULL,
	[Bio/Sm Mol - As of Yesterday] [nvarchar](4000) NULL,
	[Attribution to Drug(s) y/n] [nvarchar](2000) NULL,
	[Attributed Drug(s)] [nvarchar](4000) NULL,
	[Form status] [varchar](10) NOT NULL,
	[Last Page Updated – Name] [nvarchar](250) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](300) NULL
) ON [PRIMARY]
GO
