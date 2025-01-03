USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_DrugListing]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: October 24, 2022
-- ===========================================================================

			  
CREATE PROCEDURE [IBD600].[usp_op_DrugListing] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;

/*

CREATE TABLE [IBD600].[t_op_DrugListing]
(
    [ROWNUM] [int] NULL,
	[vID] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar] (20)  NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[Gender] [nvarchar](10) NULL,
	[YOB] [int] NULL,
	[Eligible] [nvarchar] (10) NULL,
	[Diagnosis] [nvarchar] (100) NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar] (50) NULL,
	[CalcVisitSequence] [int] NULL,
	[BioRepositoryAssoc] [nvarchar] (10) NULL,
	[BioRepositoryVisitType] [nvarchar] (70) NULL,
	[NonSterNonAntiBactTrxt] [nvarchar](10) NULL,
	[DrugType] [nvarchar] (200) NULL,
	[DrugName] [nvarchar](350) NULL,
	[OtherDrugSpecify] [nvarchar](350) NULL,
	[NoPriorUse] [nvarchar] (10) NULL,
	[PastUse] [nvarchar](10) NULL,
	[CurrentUse] [nvarchar] (10) NULL,
	[ChangesAtVisit] [nvarchar] (200) NULL,
	[FirstDoseAdminTodayVisit] [nvarchar](10) NULL,
	[StartDate] [nvarchar] (20) NULL,
	[StopDate] [nvarchar] (20) NULL,
	[Dose] [nvarchar] (40) NULL,
	[Freq] [nvarchar] (40) NULL
) ON [PRIMARY]
GO
*/

/**Get listing of drugs at all visits except Exit**/

IF OBJECT_ID('tempdb.dbo.#Drugs') IS NOT NULL BEGIN DROP TABLE #Drugs END;

SELECT V.vID
      ,V.SiteID
	  ,V.SiteStatus
	  ,V.SFSiteStatus
  	  ,V.SubjectID
	  ,V.SUBID AS PatientID
	  ,V.Gender
	  ,V.YOB
	  ,DX.DX_IBD_DEC AS Diagnosis
	  ,CAST(V.VisitDate AS date) AS VisitDate
	  ,V.VisitType
	  ,V.CalcVisitSequence
	  ,V.BioRepositoryAssoc
	  ,CASE WHEN V.BioRepositoryVisitType='prevalent' THEN 'Prevalent Patient Visit Collection'
	   WHEN V.BioRepositoryVisitType='new_med_init' THEN 'Initiator Patient – Visit 1 New Medication Initiation Collection'
	   WHEN V.BioRepositoryVisitType='new_med_fu' THEN 'Initiator Patient – Visit 2 New Medication Follow Up Visit Collection'
	   ELSE BioRepositoryVisitType
	   END AS BioRepositoryVisitType
	  ,COALESCE(MDS.DRUG_CLASS123_USE_EN_DEC, MDS.DRUG_CLASS123_USE_FU_DEC) AS NonSterNonAntiBactTrxt
	  ,D.NOT_DRUG_CLASS123_DEC AS DrugType
	  ,COALESCE(D.P__G__10_USE_DEC, D.P__G__20_USE_DEC, D.P__G__30_USE_DEC) AS DrugName
	  ,D.GX___C__OTH_NAME_TXT AS OtherDrugSpecify
	  ,D.GX__USE_NONE AS NoPriorUse
	  ,D.GX__USE_PAST AS PastUse
	  ,D.GX__USE_CUR AS CurrentUse
	  ,D.GX__RX_TDY_DEC AS ChangesAtVisit
	  ,D.GX__DOSE_RCVD_TDY_DEC AS FirstDoseAdminTodayVisit
	  ,D.GX__ST_DT AS StartDate
	  ,D.GX__STP_DT AS StopDate
	  ,CASE WHEN D.GX__DOSE_OTH IS NOT NULL AND D.G__10_DOSE_DEC IS NOT NULL THEN CAST(CAST(D.GX__DOSE_OTH AS float) AS nvarchar) + ' ' + REPLACE(D.G__10_DOSE_DEC, '___', '')
	   ELSE D.G__10_DOSE_DEC
	   END AS BiologicDose
	  ,CAST(CAST(D.G__20_DOSE AS float) AS nvarchar) + ' mg'  AS ImmunosupressantDose
	  ,CASE WHEN D.GX__DOSE_OTH IS NOT NULL AND D.G__30_DOSE_DEC IS NOT NULL THEN CAST(CAST(D.GX__DOSE_OTH AS float) AS nvarchar) + ' ' + REPLACE(D.G__30_DOSE_DEC, '__ ', '')
	   ELSE D.G__30_DOSE_DEC
	   END AS MesaASADose
	  ,CASE WHEN D.G__10_FRQ_DEC LIKE '%__%' AND GX__FRQ_OTH IS NOT NULL THEN REPLACE(D.G__10_FRQ_DEC, ' __ ', D.GX__FRQ_OTH) 
	   ELSE D.G__10_FRQ_DEC
	   END AS BioFreq
	  ,CASE WHEN D.G__20_G__30_FRQ_DEC LIKE '__ %' THEN CAST(D.GX__FRQ_OTH AS nvarchar) + ' ' + REPLACE(D.G__20_G__30_FRQ_DEC, '__', '')
	   ELSE D.G__20_G__30_FRQ_DEC
	   END AS ImmMesaFreq
INTO #Drugs
FROM [IBD600].[v_op_VisitLog] V
LEFT JOIN [MERGE_IBD].[staging].[MD_DX] DX ON V.SUBID=DX.SUBID AND V.vID=DX.vID
LEFT JOIN [MERGE_IBD].[staging].[DRUG] D ON V.vID=D.vID AND V.SUBID=D.SUBID
LEFT JOIN [MERGE_IBD].[staging].[MD_SUMMARY] MDS ON V.vID=MDS.vID AND V.SUBID=MDS.SUBID
--WHERE V.BioRepositoryAssoc='Yes'
WHERE VisitType<>'Exit'
ORDER BY V.SiteID, V.SubjectID, V.CalcVisitSequence

--select * from #Drugs WHERE BioRepositoryVisitType is not null SubjectID IN (60121440120, 60502350011, 60833480022) ORDER BY SiteID, SubjectID, VisitDate
--SELECT * FROM [MERGE_IBD].[staging].[MD_DX] WHERE SUBNUM IN (60121440120) ORDER BY SITENUM, SUBNUM, vID


IF OBJECT_ID('tempdb.dbo.#DrugsByVisit') IS NOT NULL BEGIN DROP TABLE #DrugsByVisit END;

SELECT DISTINCT vID,
       SiteID,
	   SiteStatus,
	   SFSiteStatus,
	   SubjectID,
	   PatientID,
	   Gender,
	   YOB,
	   CASE WHEN D.VisitDate BETWEEN CAST(DR.EnrollmentDateStart AS date) AND CAST(DR.EnrollmentDateEnd AS date) AND ChangesAtVisit IN ('Start', 'No changes (current use)', 'Modify') THEN 'Yes' 
	   WHEN D.VisitDate BETWEEN CAST(DR.EnrollmentDateStart AS date) AND CAST(DR.EnrollmentDateEnd AS date) AND ChangesAtVisit IN ('Stop', 'N/A - no longer in use') THEN 'No'
	   WHEN D.VisitDate < '2019-01-01' AND D.DrugName IN (SELECT DISTINCT DrugName FROM IBD600.t_op_drugreference) THEN 'Yes'
	   ELSE 'No' 
	   END AS Eligible,
	   D.Diagnosis,
	   DR.Diagnosis AS DRDiagnosis,
	   VisitDate,
	   VisitType,
	   CalcVisitSequence,
	   BioRepositoryAssoc,
	   BioRepositoryVisitType,
	   NonSterNonAntiBactTrxt,
	   DrugType,
	   D.DrugName,
	   DR.DrugName AS DRDrug,
	   OtherDrugSpecify,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   ChangesAtVisit,
	   FirstDoseAdminTodayVisit,
	   StartDate,
	   StopDate,
	   COALESCE(BiologicDose, ImmunosupressantDose, MesaASADose) AS Dose,
	   COALESCE(BioFreq, ImmMesaFreq) AS Freq
INTO #DrugsByVisit
FROM #Drugs D
LEFT JOIN IBD600.t_op_drugreference DR ON D.DrugName=DR.DrugName AND D.Diagnosis=DR.Diagnosis

--SELECT * FROM #DrugsByVisit WHERE SubjectID=60121440120 ORDER BY SiteID, SubjectID, VisitDate

TRUNCATE TABLE [Reporting].[IBD600].[t_op_DrugListing] ;

INSERT INTO [Reporting].[IBD600].[t_op_DrugListing]
(
       ROWNUM,
       vID,
       SiteID,
	   SiteStatus,
	   SFSiteStatus,
	   SubjectID,
	   PatientID,
	   Gender,
	   YOB,
	   Eligible,
	   Diagnosis,
	   VisitDate,
	   VisitType,
	   CalcVisitSequence,
	   BioRepositoryAssoc,
	   BioRepositoryVisitType,
	   NonSterNonAntiBactTrxt,
	   DrugType,
	   DrugName,
	   OtherDrugSpecify,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   ChangesAtVisit,
	   FirstDoseAdminTodayVisit,
	   StartDate,
	   StopDate,
	   Dose,
	   Freq
)

SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY SiteID, SubjectID, vID ORDER BY SiteID, SubjectID, Eligible DESC, DrugType, DrugName, OtherDrugSpecify) AS ROWNUM,
       vID,
       SiteID,
	   SiteStatus,
	   SFSiteStatus,
	   SubjectID,
	   PatientID,
	   Gender,
	   YOB,
	   Eligible,
	   Diagnosis,
	   VisitDate,
	   VisitType,
	   CalcVisitSequence,
	   BioRepositoryAssoc,
	   BioRepositoryVisitType,
	   NonSterNonAntiBactTrxt,
	   DrugType,
	   DrugName,
	   OtherDrugSpecify,
	   NoPriorUse,
	   PastUse,
	   CurrentUse,
	   ChangesAtVisit,
	   FirstDoseAdminTodayVisit,
	   StartDate,
	   StopDate,
	   Dose,
	   Freq

FROM #DrugsByVisit DV
ORDER BY SiteID, SubjectID, VisitDate DESC, CalcVisitSequence DESC, ROWNUM, DrugName, OtherDrugSpecify


	   
--SELECT * FROM [Reporting].[IBD600].[t_op_DrugListing] WHERE SubjectID IN (60121440120, 60502350011, 60833480022) ORDER BY SiteID, SubjectID, VisitDate DESC, CalcVisitSequence DESC, ROWNUM, DrugName, OtherDrugSpecify
--SELECT DISTINCT DrugType FROM [Reporting].[IBD600].[t_op_DrugListing]
--BioRepositoryAssoc='Yes'


END
GO
