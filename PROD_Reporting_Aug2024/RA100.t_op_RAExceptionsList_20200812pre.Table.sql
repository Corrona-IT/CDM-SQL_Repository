USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RAExceptionsList_20200812pre]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_RAExceptionsList_20200812pre](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[EnrollmentDate] [date] NULL,
	[PatientEligible] [varchar](50) NULL,
	[IneligibleReason] [varchar](600) NULL,
	[ExceptionGranted] [varchar](50) NULL,
	[ExceptionReason] [varchar](500) NULL,
	[ReviewDate] [date] NULL,
	[UpdateDate] [date] NULL,
	[DQCDate] [date] NULL,
	[Notes] [varchar](500) NULL
) ON [PRIMARY]
GO
