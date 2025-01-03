USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_pv_SAEDetection]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_pv_SAEDetection](
	[vID] [bigint] NOT NULL,
	[Site ID] [int] NOT NULL,
	[Subject ID] [nvarchar](50) NOT NULL,
	[Provider ID] [smallint] NULL,
	[Page Description] [nvarchar](255) NULL,
	[Event Type] [nvarchar](255) NULL,
	[Event Term] [nvarchar](50) NULL,
	[Event Specify] [nvarchar](50) NULL,
	[Date of Event Onset] [date] NULL,
	[Visit Date] [date] NULL,
	[Age] [bigint] NULL,
	[Gender] [nvarchar](50) NULL,
	[Ethnicity] [nvarchar](300) NULL,
	[RA Disease Duration] [bigint] NULL,
	[Outcome] [nvarchar](33) NULL,
	[Death] [varchar](16) NULL,
	[Report Type] [nvarchar](250) NULL,
	[No Event(specify)] [nvarchar](250) NULL,
	[S Docs status] [nvarchar](28) NULL,
	[Hospitalized] [nvarchar](40) NULL,
	[Bio/Sm Mol - Change Today] [varchar](350) NULL,
	[Bio/Sm Mol - As of Yesterday] [varchar](350) NULL,
	[Attribution to Drug(s) y/n] [nvarchar](15) NULL,
	[Attributed drug(s)] [varchar](350) NULL,
	[Form status] [nvarchar](300) NULL,
	[Last Page Updated – Name] [nvarchar](100) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](200) NULL
) ON [PRIMARY]
GO
