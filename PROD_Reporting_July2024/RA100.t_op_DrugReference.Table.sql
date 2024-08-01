USE [Reporting]
GO
/****** Object:  Table [RA100].[t_op_DrugReference]    Script Date: 8/1/2024 11:24:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RA100].[t_op_DrugReference](
	[TreatmentName] [nvarchar](500) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[NeedsReview] [nvarchar](10) NULL
) ON [PRIMARY]
GO
