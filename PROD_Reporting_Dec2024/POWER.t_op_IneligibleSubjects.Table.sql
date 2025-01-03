USE [Reporting]
GO
/****** Object:  Table [POWER].[t_op_IneligibleSubjects]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [POWER].[t_op_IneligibleSubjects](
	[SubjectID] [bigint] NULL,
	[PatientID] [bigint] NOT NULL,
	[RegistryStatus] [nvarchar](30) NULL,
	[IneligibleReason] [nvarchar](500) NULL
) ON [PRIMARY]
GO
