USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RAExceptionsList]    Script Date: 6/6/2024 9:28:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_RAExceptionsList](
	[SiteID] [float] NULL,
	[SubjectID] [float] NULL,
	[EnrollmentDate] [datetime] NULL,
	[PatientEligible] [nvarchar](255) NULL,
	[IneligibleReason] [nvarchar](255) NULL,
	[ExceptionGranted] [nvarchar](255) NULL,
	[ExceptionReason] [nvarchar](255) NULL,
	[ReviewDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DQCDate] [datetime] NULL,
	[Notes] [nvarchar](255) NULL
) ON [PRIMARY]
GO
