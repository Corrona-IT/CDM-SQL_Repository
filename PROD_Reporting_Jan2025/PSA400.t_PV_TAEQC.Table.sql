USE [Reporting]
GO
/****** Object:  Table [PSA400].[t_PV_TAEQC]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PSA400].[t_PV_TAEQC](
	[vID] [bigint] NOT NULL,
	[Site ID] [bigint] NOT NULL,
	[Subject ID] [nvarchar](50) NOT NULL,
	[Provider ID] [smallint] NULL,
	[PAGEDESC] [nvarchar](255) NOT NULL,
	[Event Type] [nvarchar](255) NOT NULL,
	[Event Term] [nvarchar](50) NULL,
	[OtherEventSpecify] [nvarchar](50) NULL,
	[Date of Event Onset] [date] NULL,
	[Visit Date] [date] NULL,
	[Event Outcome] [nvarchar](33) NULL,
	[Seious outcome] [varchar](16) NULL,
	[In Utero or Neonatal Outcomes] [nvarchar](4000) NULL,
	[IV antibiotics_TAE INF] [nvarchar](50) NULL,
	[Event Confirmation Status/Can you confirm the Event?] [nvarchar](68) NULL,
	[Not an Event (explanation)] [nvarchar](301) NULL,
	[Supporting documents] [nvarchar](28) NULL,
	[file attached] [varchar](3) NOT NULL,
	[Supporting documents received by Corrona?] [nvarchar](4000) NULL,
	[Reason if no supporting documents provided] [varchar](46) NOT NULL,
	[Hospital would not fax or release documents because] [nvarchar](150) NULL,
	[Reason if no source provided = Other, specify] [nvarchar](150) NULL,
	[Form status] [varchar](10) NOT NULL,
	[Last Page Updated – Name] [nvarchar](100) NULL,
	[Last Page Updated – Date] [datetime] NULL,
	[Last Page Updated – User] [nvarchar](200) NULL
) ON [PRIMARY]
GO
