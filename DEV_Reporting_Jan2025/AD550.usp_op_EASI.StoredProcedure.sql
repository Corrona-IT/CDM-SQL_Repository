USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_EASI]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/28/2020
-- Description:	Procedure to create table for All Drugs for MS
-- ==================================================================================

CREATE PROCEDURE [AD550].[usp_op_EASI] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [Reporting].[AD550].[t_op_EASI]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar] (30) NOT NULL,
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
);

*/

/*****Get handprint score*****/

IF OBJECT_ID('tempdb.dbo.#handprint') IS NOT NULL BEGIN DROP TABLE #handprint END;

SELECT DISTINCT [subNum] AS SubjectID
      ,[subjectId] AS PatientID
      ,[eventName] AS VisitType
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[visit_dt] AS VisitDate

      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]

	  ,CASE WHEN bsaface IS NOT NULL AND bsascalp IS NOT NULL AND bsaneck IS NOT NULL THEN CAST((bsaface + bsascalp + bsaneck) AS float)
	   ELSE CAST(NULL AS float)
	   END AS headneck_handprint

	  ,CASE WHEN bsatrunkanterior IS NOT NULL AND bsaback IS NOT NULL AND bsagenitals IS NOT NULL THEN cast((bsatrunkanterior + bsaback + bsagenitals) AS float)
	   ELSE CAST(NULL AS float)
	   END AS trunkback_handprint

	  ,CASE WHEN [bsaarms] IS NOT NULL AND [bsadorsalhands] IS NOT NULL AND [bsapalmarhands] IS NOT NULL THEN CAST(([bsaarms] + bsadorsalhands + bsapalmarhands) AS float)
	   ELSE CAST(NULL AS float)
	   END AS arms_handprint

	  ,CASE WHEN bsabuttocks IS NOT NULL AND bsalowerlimbs IS NOT NULL AND bsadorsalfeet IS NOT NULL AND bsaplantarfeet IS NOT NULL THEN CAST((bsabuttocks + bsalowerlimbs + bsadorsalfeet + bsaplantarfeet) AS float)
	   ELSE CAST(NULL AS float)
	   END AS legsbuttocks_handprint

INTO #handprint
FROM [RCC_AD550].[staging].[provider] PROV

--SELECT * FROM #handprint WHERE SubjectID=55141280003



/*****Get BSA score*****/

IF OBJECT_ID('tempdb.dbo.#bsa_areascores') IS NOT NULL BEGIN DROP TABLE #bsa_areascores END;

SELECT DISTINCT  [SubjectID]
      ,[PatientID]
      ,[VisitType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[VisitDate]
      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]
	  ,[headneck_handprint]
	  ,[trunkback_handprint]
	  ,[arms_handprint]
	  ,[legsbuttocks_handprint]
	  ,[headneck_bsa]
	  ,[trunkback_bsa]
	  ,[arms_bsa]
	  ,[legsbuttocks_bsa]

	  ,CASE WHEN [headneck_bsa]=0 THEN 0
	   WHEN [headneck_bsa] > 0 AND  [headneck_bsa] < 0.1 THEN 1
	   WHEN [headneck_bsa] >= 0.1 AND [headneck_bsa] < 0.3 THEN 2
	   WHEN [headneck_bsa] >= 0.3 AND [headneck_bsa] < 0.5 THEN 3
	   WHEN [headneck_bsa] >= 0.5 AND [headneck_bsa] < 0.7 THEN 4
	   WHEN [headneck_bsa] >= 0.7 AND [headneck_bsa] < 0.9 THEN 5
	   WHEN [headneck_bsa] >= 0.9 AND [headneck_bsa] <= 1 THEN 6
	   ELSE [headneck_bsa]
	   END AS [headneck_areascore]

	  ,CASE WHEN [trunkback_bsa]=0 THEN 0
	   WHEN [trunkback_bsa] > 0 AND  [trunkback_bsa] < 0.1 THEN 1
	   WHEN [trunkback_bsa] >= 0.1 AND [trunkback_bsa] < 0.3 THEN 2
	   WHEN [trunkback_bsa] >= 0.3 AND [trunkback_bsa] < 0.5 THEN 3
	   WHEN [trunkback_bsa] >= 0.5 AND [trunkback_bsa] < 0.7 THEN 4
	   WHEN [trunkback_bsa] >= 0.7 AND [trunkback_bsa] < 0.9 THEN 5
	   WHEN [trunkback_bsa] >= 0.9 AND [trunkback_bsa] <= 1 THEN 6
	   ELSE [trunkback_bsa]
	   END AS [trunkback_areascore]

	  ,CASE WHEN [arms_bsa]=0 THEN 0
	   WHEN [arms_bsa] > 0 AND  [arms_bsa] < 0.1 THEN 1
	   WHEN [arms_bsa] >= 0.1 AND [arms_bsa] < 0.3 THEN 2
	   WHEN [arms_bsa] >= 0.3 AND [arms_bsa] < 0.5 THEN 3
	   WHEN [arms_bsa] >= 0.5 AND [arms_bsa] < 0.7 THEN 4
	   WHEN [arms_bsa] >= 0.7 AND [arms_bsa] < 0.9 THEN 5
	   WHEN [arms_bsa] >= 0.9 AND [arms_bsa] <= 1 THEN 6
	   ELSE [arms_bsa]
	   END AS [arms_areascore]

	  ,CASE WHEN [legsbuttocks_bsa] > 0 AND  [legsbuttocks_bsa] < 0.1 THEN 1
	   WHEN [legsbuttocks_bsa] >= 0.1 AND [legsbuttocks_bsa] < 0.3 THEN 2
	   WHEN [legsbuttocks_bsa] >= 0.3 AND [legsbuttocks_bsa] < 0.5 THEN 3
	   WHEN [legsbuttocks_bsa] >= 0.5 AND [legsbuttocks_bsa] < 0.7 THEN 4
	   WHEN [legsbuttocks_bsa] >= 0.7 AND [legsbuttocks_bsa] < 0.9 THEN 5
	   WHEN [legsbuttocks_bsa] >= 0.9 AND [legsbuttocks_bsa] <= 1 THEN 6
	   ELSE [legsbuttocks_bsa]
	   END AS [legsbuttocks_areascore]

INTO #bsa_areascores
FROM
(
SELECT DISTINCT [SubjectID]
      ,[PatientID]
      ,[VisitType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[VisitDate]
      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]
	  ,[headneck_handprint]
	  ,[trunkback_handprint]
	  ,[arms_handprint]
	  ,[legsbuttocks_handprint]

	  ,CASE WHEN [headneck_handprint] IS NOT NULL THEN CAST([headneck_handprint]/9 AS DEC(6,2))
	   ELSE NULL
	   END AS [headneck_bsa]

	  ,CASE WHEN [trunkback_handprint] IS NOT NULL THEN CAST([trunkback_handprint]/27 AS DEC (6,2))
	   ELSE NULL
	   END AS [trunkback_bsa]

	  ,CASE WHEN [arms_handprint] IS NOT NULL THEN CAST([arms_handprint]/19 AS DEC(6,2))
	   ELSE NULL
	   END AS [arms_bsa]

	  ,CASE WHEN [legsbuttocks_handprint] IS NOT NULL THEN CAST([legsbuttocks_handprint]/45 AS DEC(6,2))
	   ELSE NULL
	   END AS [legsbuttocks_bsa]

FROM #handprint

) A

--SELECT * FROM #bsa_areascores WHERE SubjectID=55141280003


IF OBJECT_ID('tempdb.dbo.#regionspecificscores') IS NOT NULL BEGIN DROP TABLE #regionspecificscores END;

SELECT DISTINCT [SubjectID]
      ,[PatientID]
      ,[VisitType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[VisitDate]
      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]
	  ,[headneck_handprint]
	  ,[trunkback_handprint]
	  ,[arms_handprint]
	  ,[legsbuttocks_handprint]
	  ,[headneck_bsa]
	  ,[trunkback_bsa]
	  ,[arms_bsa]
	  ,[legsbuttocks_bsa]
	  ,[headneck_areascore]
	  ,[trunkback_areascore]
	  ,[arms_areascore]
	  ,[legsbuttocks_areascore]

	  ,CASE WHEN [headneckerythema] IS NOT NULL AND [headneckedema] IS NOT NULL AND [headneckexoriation] IS NOT NULL AND [headnecklichenification] IS NOT NULL AND [headneck_areascore] IS NOT NULL THEN (([headneckerythema] + [headneckedema] + [headneckexoriation] + [headnecklichenification])*[headneck_areascore])
	   ELSE CAST(NULL AS float)
	   END AS headneck_regionscore

	  ,CASE WHEN [trunkbackerythema] IS NOT NULL AND [trunkbackedema] IS NOT NULL AND [trunkbackexoriation] IS NOT NULL AND[trunkbacklichenification] IS NOT NULL AND [trunkback_areascore] IS NOT NULL THEN (([trunkbackerythema] + [trunkbackedema] +[trunkbackexoriation] + [trunkbacklichenification])*[trunkback_areascore])
	   ELSE CAST(NULL AS float)
	   END AS trunkback_regionscore

	  ,CASE WHEN [armserythema] IS NOT NULL AND [armsedema] IS NOT NULL AND [armsexoriation] IS NOT NULL AND [armslichenification] IS NOT NULL AND [arms_areascore] IS NOT NULL THEN (([armserythema] + [armsedema] + [armsexoriation] + [armslichenification])*[arms_areascore])
	   ELSE CAST(NULL AS float)
	   END AS arms_regionscore

	  ,CASE WHEN [legsbuttockserythema] IS NOT NULL AND [legsbuttocksedema] IS NOT NULL AND [legsbuttocksexoriation] IS NOT NULL AND [legsbuttockslichenification] IS NOT NULL AND [legsbuttocks_areascore] IS NOT NULL THEN (([legsbuttockserythema] + [legsbuttocksedema] + [legsbuttocksexoriation] + [legsbuttockslichenification])*[legsbuttocks_areascore])
	   ELSE CAST(NULL AS float)
	   END AS legsbuttocks_regionscore

INTO #regionspecificscores
FROM #bsa_areascores

--SELECT * FROM #regionspecificscores

IF OBJECT_ID('tempdb.dbo.#EASI_calc') IS NOT NULL BEGIN DROP TABLE #EASI_calc END;

SELECT DISTINCT [SubjectID]
      ,[PatientID]
      ,[VisitType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[VisitDate]
      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]
	  ,[headneck_handprint]
	  ,[trunkback_handprint]
	  ,[arms_handprint]
	  ,[legsbuttocks_handprint]
	  ,[headneck_bsa]
	  ,[trunkback_bsa]
	  ,[arms_bsa]
	  ,[legsbuttocks_bsa]
	  ,[headneck_areascore]
	  ,[trunkback_areascore]
	  ,[arms_areascore]
	  ,[legsbuttocks_areascore]
	  ,[headneck_regionscore]
	  ,[trunkback_regionscore]
	  ,[arms_regionscore]
	  ,[legsbuttocks_regionscore]

	  ,CASE WHEN [headneck_regionscore] IS NULL AND [trunkback_regionscore] IS NULL AND [arms_regionscore] IS NULL AND [legsbuttocks_regionscore] IS NULL THEN CAST(NULL AS FLOAT)
	   ELSE CAST(((ISNULL([headneck_regionscore], 0)*0.1) + (ISNULL([trunkback_regionscore], 0)*0.3) + (ISNULL([arms_regionscore], 0)*0.2) + (ISNULL([legsbuttocks_regionscore], 0)*0.4)) AS float) 
	   END AS EASI

INTO #EASI_calc
FROM #regionspecificscores

--SELECT * FROM #EASI_calc WHERE SubjectID=55141280003


TRUNCATE TABLE [Reporting].[AD550].[t_op_EASI];

INSERT INTO [Reporting].[AD550].[t_op_EASI]
(
       [SiteID]
	  ,[SubjectID]
      ,[PatientID]
      ,[VisitType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[VisitDate]
      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]
	  ,[headneck_handprint]
	  ,[trunkback_handprint]
	  ,[arms_handprint]
	  ,[legsbuttocks_handprint]
	  ,[headneck_bsa]
	  ,[trunkback_bsa]
	  ,[arms_bsa]
	  ,[legsbuttocks_bsa]
	  ,[headneck_areascore]
	  ,[trunkback_areascore]
	  ,[arms_areascore]
	  ,[legsbuttocks_areascore]
	  ,[headneck_regionscore]
	  ,[trunkback_regionscore]
	  ,[arms_regionscore]
	  ,[legsbuttocks_regionscore]
	  ,[EASI]
)


SELECT DISTINCT SUB.SiteID
      ,EASI.[SubjectID]
      ,EASI.[PatientID]
      ,[VisitType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[crfId]
      ,[eventCrfId]
      ,[crfOccurrence]
      ,[VisitDate]
      ,[bsaface]
      ,[bsascalp]
      ,[bsaneck]
      ,[bsatrunkanterior]
      ,[bsaback]
      ,[bsagenitals]
      ,[bsaarms]
      ,[bsadorsalhands]
      ,[bsapalmarhands]
      ,[bsabuttocks]
      ,[bsalowerlimbs]
      ,[bsadorsalfeet]
      ,[bsaplantarfeet]
      ,[headneckerythema]
      ,[headneckedema]
      ,[headneckexoriation]
      ,[headnecklichenification]
      ,[trunkbackerythema]
      ,[trunkbackedema]
      ,[trunkbackexoriation]
      ,[trunkbacklichenification]
      ,[armserythema]
      ,[armsedema]
      ,[armsexoriation]
      ,[armslichenification]
      ,[legsbuttockserythema]
      ,[legsbuttocksedema]
      ,[legsbuttocksexoriation]
      ,[legsbuttockslichenification]
	  ,[headneck_handprint]
	  ,[trunkback_handprint]
	  ,[arms_handprint]
	  ,[legsbuttocks_handprint]
	  ,[headneck_bsa]
	  ,[trunkback_bsa]
	  ,[arms_bsa]
	  ,[legsbuttocks_bsa]
	  ,[headneck_areascore]
	  ,[trunkback_areascore]
	  ,[arms_areascore]
	  ,[legsbuttocks_areascore]
	  ,[headneck_regionscore]
	  ,[trunkback_regionscore]
	  ,[arms_regionscore]
	  ,[legsbuttocks_regionscore]
	  ,[EASI]

FROM #EASI_calc EASI
LEFT JOIN [Reporting].[AD550].[v_op_subjects] SUB ON SUB.[patientId]=EASI.PatientID
WHERE ISNULL(SUB.SiteID, '') NOT IN ('', 1440)

--SELECT * FROM [Reporting].[AD550].[t_op_EASI] order by siteid, subjectid


END



GO
