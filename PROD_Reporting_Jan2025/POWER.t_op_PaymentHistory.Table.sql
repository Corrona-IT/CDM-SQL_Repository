USE [Reporting]
GO
/****** Object:  Table [POWER].[t_op_PaymentHistory]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [POWER].[t_op_PaymentHistory](
	[Site ID] [int] NULL,
	[Subject ID] [bigint] NULL,
	[Patient ID] [bigint] NULL,
	[Gender] [nvarchar](255) NULL,
	[YOB] [int] NULL,
	[Registry Visit Type] [nvarchar](255) NULL,
	[Registry Visit Date] [datetime] NULL,
	[Power Enrollment Date] [datetime] NULL,
	[Medication Start Date] [datetime] NULL,
	[Medication] [nvarchar](255) NULL,
	[Patient Status] [nvarchar](255) NULL,
	[Medication Listed at Visit] [nvarchar](255) NULL,
	[Medication Listed as Started] [nvarchar](255) NULL,
	[Gender and YOB Confirmed] [nvarchar](255) NULL,
	[Amount Paid] [float] NULL,
	[Previously Paid] [nvarchar](255) NULL,
	[Paid in Quarter] [nvarchar](255) NULL,
	[Payment Comments] [nvarchar](255) NULL
) ON [PRIMARY]
GO
