USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_RAMP_PatInfo_Audit]    Script Date: 11/13/2024 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_RAMP_PatInfo_Audit](
	[TRNAME] [nvarchar](50) NOT NULL,
	[TRNO] [datetime2](7) NOT NULL,
	[TRIALID] [int] NOT NULL,
	[STNAME] [nvarchar](max) NOT NULL,
	[STNO] [int] NOT NULL,
	[SITEID] [int] NOT NULL,
	[SUBJINIT] [nvarchar](1) NULL,
	[SUBJID] [int] NOT NULL,
	[PATIENTID] [int] NOT NULL,
	[VISITN] [nvarchar](1) NULL,
	[VISITNO] [nvarchar](1) NULL,
	[VISITID] [nvarchar](1) NULL,
	[CRFName] [nvarchar](max) NOT NULL,
	[CRFInsNo] [nvarchar](50) NOT NULL,
	[FORMID] [int] NOT NULL,
	[Group] [nvarchar](50) NOT NULL,
	[GRPINSNO] [nvarchar](50) NOT NULL,
	[QuestNa] [nvarchar](50) NOT NULL,
	[QuestTxt] [nvarchar](max) NOT NULL,
	[OrderNo] [nvarchar](50) NOT NULL,
	[CRFStat] [nvarchar](50) NOT NULL,
	[zVersion] [nvarchar](50) NOT NULL,
	[IsMonit] [nvarchar](50) NOT NULL,
	[zRespVal] [nvarchar](max) NULL,
	[zRespDat] [datetime2](7) NOT NULL,
	[zUTCDat] [datetime2](7) NOT NULL,
	[zUserNam] [nvarchar](50) NOT NULL,
	[zRoleNam] [nvarchar](50) NOT NULL,
	[Thread] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
