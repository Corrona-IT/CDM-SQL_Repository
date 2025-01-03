USE [Reporting]
GO
/****** Object:  Table [POWER].[t_op_POWERPaymentReport]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [POWER].[t_op_POWERPaymentReport](
	[Site ID] [int] NULL,
	[Subject ID] [bigint] NULL,
	[Patient ID] [bigint] NULL,
	[Gender] [varchar](30) NULL,
	[YOB] [int] NULL,
	[Registry Visit Type] [varchar](15) NULL,
	[Registry Visit Date] [date] NULL,
	[Power Enrollment Date] [date] NULL,
	[Medication Start Date] [date] NULL,
	[Medication] [varchar](100) NULL,
	[Patient Status] [varchar](100) NULL,
	[Medication Listed at Visit] [varchar](10) NULL,
	[Medication Listed as Started] [varchar](40) NULL,
	[Gender and YOB Confirmed] [varchar](40) NULL,
	[Amount Paid] [float] NULL,
	[Previously Paid] [varchar](30) NULL,
	[Paid in Quarter] [varchar](30) NULL,
	[Payment Comments] [varchar](500) NULL,
	[Paid] [varchar](20) NULL
) ON [PRIMARY]
GO
