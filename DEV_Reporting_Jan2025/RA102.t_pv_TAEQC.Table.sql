USE [Reporting]
GO
/****** Object:  Table [RA102].[t_pv_TAEQC]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA102].[t_pv_TAEQC](
	[vID] [bigint] NOT NULL,
	[Site ID] [bigint] NOT NULL,
	[Subject ID] [bigint] NOT NULL,
	[Provider ID] [bigint] NULL,
	[PAGEDESC] [nvarchar](400) NOT NULL,
	[Event Type] [nvarchar](400) NOT NULL,
	[Event Term] [nvarchar](200) NULL,
	[Event Specify] [nvarchar](400) NULL,
	[Date of Event Onset] [date] NULL,
	[Visit Date] [date] NULL,
	[Event Outcome] [nvarchar](400) NULL,
	[Serious outcome] [varchar](100) NULL,
	[IV antibiotics_TAE INF] [nvarchar](100) NULL,
	[Report Type] [nvarchar](400) NULL,
	[No Event(specify)] [nvarchar](400) NULL,
	[Supporting documents] [nvarchar](250) NULL,
	[file attached] [varchar](10) NOT NULL,
	[Supporting documents received by Corrona?] [nvarchar](4000) NULL,
	[Reason if no source provided] [varchar](400) NOT NULL,
	[Reason if no source provided = Other, specify] [varchar](500) NULL,
	[Hospital would not fax or release documents because] [nvarchar](400) NULL,
	[Form status] [varchar](100) NOT NULL,
	[Last Page Updated – Name] [nvarchar](200) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](300) NULL
) ON [PRIMARY]
GO
