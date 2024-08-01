USE [Reporting]
GO
/****** Object:  Table [AD550].[t_op_EASI]    Script Date: 8/1/2024 11:24:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD550].[t_op_EASI](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[VisitType] [nvarchar](40) NULL,
	[eventId] [int] NULL,
	[eventOccurrence] [int] NULL,
	[crfName] [nvarchar](250) NULL,
	[crfId] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[crfOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[bsaface] [float] NULL,
	[bsascalp] [float] NULL,
	[bsaneck] [float] NULL,
	[bsatrunkanterior] [float] NULL,
	[bsaback] [float] NULL,
	[bsagenitals] [float] NULL,
	[bsaarms] [float] NULL,
	[bsadorsalhands] [float] NULL,
	[bsapalmarhands] [float] NULL,
	[bsabuttocks] [float] NULL,
	[bsalowerlimbs] [float] NULL,
	[bsadorsalfeet] [float] NULL,
	[bsaplantarfeet] [float] NULL,
	[headneckerythema] [float] NULL,
	[headneckedema] [float] NULL,
	[headneckexoriation] [float] NULL,
	[headnecklichenification] [float] NULL,
	[trunkbackerythema] [float] NULL,
	[trunkbackedema] [float] NULL,
	[trunkbackexoriation] [float] NULL,
	[trunkbacklichenification] [float] NULL,
	[armserythema] [float] NULL,
	[armsedema] [float] NULL,
	[armsexoriation] [float] NULL,
	[armslichenification] [float] NULL,
	[legsbuttockserythema] [float] NULL,
	[legsbuttocksedema] [float] NULL,
	[legsbuttocksexoriation] [float] NULL,
	[legsbuttockslichenification] [float] NULL,
	[headneck_handprint] [float] NULL,
	[trunkback_handprint] [float] NULL,
	[arms_handprint] [float] NULL,
	[legsbuttocks_handprint] [float] NULL,
	[headneck_bsa] [float] NULL,
	[trunkback_bsa] [float] NULL,
	[arms_bsa] [float] NULL,
	[legsbuttocks_bsa] [float] NULL,
	[headneck_areascore] [float] NULL,
	[trunkback_areascore] [float] NULL,
	[arms_areascore] [float] NULL,
	[legsbuttocks_areascore] [float] NULL,
	[headneck_regionscore] [float] NULL,
	[trunkback_regionscore] [float] NULL,
	[arms_regionscore] [float] NULL,
	[legsbuttocks_regionscore] [float] NULL,
	[EASI] [float] NULL
) ON [PRIMARY]
GO
