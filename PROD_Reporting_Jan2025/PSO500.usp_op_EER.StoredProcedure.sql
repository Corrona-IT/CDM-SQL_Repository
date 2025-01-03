USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_EER]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: June 1, 2022
-- Updated:     Nov 14, 2023; Mar 21, 2024
-- ===========================================================================

			  
CREATE PROCEDURE [PSO500].[usp_op_EER] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;


/*

CREATE TABLE [PSO500].[t_op_EER](
	[VisitId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[Country] [nvarchar] (50) NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[ProviderID] [int] NULL,
	[BirthYear] [int] NULL,
	[AgeAtEnroll] [int] NULL,
	[EnrollDate] [date] NULL,
	[DiagnosisYear] [int] NULL,
	[crfStatus] [nvarchar](200) NULL,
	[Treatment] [nvarchar](350) NULL,
	[otherTreatment] [nvarchar](350) NULL,
	[TreatmentName] [nvarchar](500) NULL,
	[EligibleTreatment] [nvarchar] (25) NULL,
	[FirstDoseToday] [nvarchar](10) NULL,
	[firstUse] [nvarchar](10) NULL,
	[calcFirstUse] [nvarchar](10) NULL,
	[AllowedPreviousUse] [nvarchar](10) NULL,
	[BiologicNaive] [nvarchar](10) NULL,
	[additionalStartDate] [nvarchar](5) NULL,
	[DrugCohort] [nvarchar](150) NULL,
	[TreatmentStatus] [nvarchar](150) NULL,
	[TwelveMonthInitiationRule] [nvarchar](25) NULL,
	[enteredStartDate] [nvarchar] (12) NULL,
	[startDate] [date] NULL,
	[stopDate] [date] NULL,
	[pastUseStartDate] [date] NULL,
	[pastUseStopDate] [date] NULL,
	[MonthsSinceStart] [bigint] NULL,
	[DaysSinceStart] [bigint] NULL,
	[DaysInterrupted] [bigint] NULL,
	[trxmtBetween] [nvarchar](20) NULL,
	[MonthsSincePastUseStart] [bigint] NULL,
	[RegistryEnrollmentStatus] [nvarchar](100) NULL,
	[EligibilityReview] [nvarchar](100) NULL
) ON [PRIMARY]
GO

CREATE TABLE [PSO500].[t_EligDashboard_EER]
(
	[Site ID] [int] NOT NULL,
	[Subject ID] [nvarchar] (20) NULL,
	[Eligible Treatment] [nvarchar](250) NULL,
	[Enrollment Date] [date] NULL,

) ON [PRIMARY]
GO
*/



/**Get subject enrollment information**/

IF OBJECT_ID('tempdb.dbo.#ENROLL') IS NOT NULL BEGIN DROP TABLE #ENROLL END;

/*Enrollment from visit log combined with diagnosis year*/
SELECT DISTINCT VL.VisitId
      ,VL.SiteID
	  ,VL.SiteStatus
	  ,SIT.[Country__C] AS Country
      ,VL.SubjectID
	  ,VL.ProviderID
	  ,SUB.SUB_BirthDate
	  ,SUB.SUB_Age
	  ,CASE WHEN ISNULL(PE3_yr_ps_dx, '')='' THEN CAST(NULL AS int)
	   ELSE CAST(PE3_yr_ps_dx AS int)
	   END AS DiagnosisYear
	  ,VL.VisitType
	  ,CAST(VL.VisitDate AS date) AS VisitDate
	  ,CASE WHEN CAST(VL.VisitDate AS date) < '2016-06-20' THEN 1
	   WHEN CAST(VL.VisitDate AS date) BETWEEN '2016-06-20' AND '2020-04-30' THEN 2
	   WHEN CAST(VL.VisitDate AS date) BETWEEN '2020-05-01' AND '2021-12-31' THEN 3
	   WHEN CAST(VL.VisitDate AS date) > '2022-01-01' THEN 4
	   ELSE NULL
	   END AS EligVersion

INTO #ENROLL 
FROM PSO500.v_op_VisitLog VL 
LEFT JOIN OMNICOMM_PSO.inbound.[G_Site Information] SIT ON SIT.[Sys. SiteNo]=VL.SiteID
LEFT JOIN OMNICOMM_PSO.inbound.PE PE ON PE.[Patient Object PatientNo]=VL.SubjectID AND PE.[Visit Object ProCaption]='Enrollment'
LEFT JOIN
(SELECT DISTINCT subject_id AS SubjectID
      ,[Enroll Date]
	  ,SUBSTRING([Enroll Date], 1, 4) AS EnrollYear
      ,birthdate_pat AS SUB_BirthDate
	  ,PatientId AS PatientId
	  ,CASE WHEN ISNULL([birthdate_pat], '')='' THEN CAST(NULL AS int)
	   WHEN ISNULL([Enroll Date], '')='' THEN CAST(NULL AS int)
	   ELSE CAST(SUBSTRING([Enroll Date], 1, 4) AS int)-birthdate_pat
	   END AS SUB_Age
	  ,[Sys. SiteNo] SiteID
FROM OMNICOMM_PSO.inbound.[G_Subject Information] SUB
WHERE ISNULL(subject_id, '')<>'' AND subject_id<>'MSW001'
) SUB ON SUB.SubjectID=VL.SubjectID

WHERE ISNULL(VL.VisitDate, '') <> ''
AND VL.VisitType IN ('Enrollment')
AND [Site Number] NOT IN (997, 998, 999)

--SELECT * FROM #ENROLL WHERE SubjectID IN (49980039112)

/**Get treatment at Enrollment**/

IF OBJECT_ID('tempdb.dbo.#DA') IS NOT NULL BEGIN DROP TABLE #DA END;

SELECT DISTINCT E.VisitId
	  ,E.SiteID
	  ,E.SiteStatus
	  ,E.Country
	  ,E.SubjectID
	  ,E.ProviderID
	  ,E.SUB_BirthDate
	  ,E.VisitDate
	  ,E.VisitType
	  ,SUB_Age
	  ,E.DiagnosisYear

	  ,CASE WHEN ISNULL(T.crfStatus, '')='' THEN 'No data'
	   ELSE T.crfStatus
	   END AS crfStatus

	  ,CASE WHEN E.VisitDate <= '2023-12-31' AND ISNULL(T.otherTreatment, '')<>'' AND ((UPPER(T.otherTreatment) LIKE '%DEUCRAVACITINIB%') OR (UPPER(T.otherTreatment) LIKE '%SOTYKTU%')) THEN 'deucravacitinib {Sotyktu}'
	   ELSE T.Treatment
	   END AS Treatment

	  ,CASE WHEN E.VisitDate <= '2023-12-31' AND ISNULL(T.otherTreatment, '')<>'' AND ((UPPER(T.otherTreatment) LIKE '%DEUCRAVACITINIB%') OR (UPPER(T.otherTreatment) LIKE '%SOTYKTU%')) THEN ''
	   ELSE T.otherTreatment
	   END AS otherTreatment

	  ,CASE WHEN E.VisitDate <= '2023-12-31' AND ISNULL(T.otherTreatment, '')<>'' AND ((UPPER(T.otherTreatment) LIKE '%DEUCRAVACITINIB%') OR (UPPER(T.otherTreatment) LIKE '%SOTYKTU%')) THEN 'deucravacitinib {Sotyktu}'
	   WHEN E.VisitDate <= '2023-12-31' AND ISNULL(T.otherTreatment, '')<>'' AND ((UPPER(T.otherTreatment) NOT LIKE '%DEUCRAVACITINIB%') AND (UPPER(T.otherTreatment) NOT LIKE '%SOTYKTU%')) THEN T.Treatment + ': ' + T.otherTreatment
	   WHEN ISNULL(T.otherTreatment, '')<>'' THEN T.Treatment + ': ' + T.otherTreatment
	   WHEN T.Treatment='No Treatment' THEN 'No treatment'
	   WHEN ISNULL(T.Treatment, '')='' AND crfStatus<>'Incomplete' THEN 'No data'
	   WHEN T.Treatment='No data' THEN 'No data'
	   ELSE T.Treatment
	   END AS TreatmentName


	  ,T.TreatmentStatus
	  ,T.FirstDoseToday
	  ,T.firstUse
	  ,enteredStartDate
	  ,CASE WHEN TreatmentStatus='Prescribed Today' AND FirstDoseToday='Yes' THEN E.VisitDate
	   ELSE CAST(T.startDate AS date)
	   END AS startDate
	  ,StartReasons
	  ,CASE WHEN ISNULL(T.changeDate, '')='' then CAST(NULL AS date)
	   ELSE CAST(T.changeDate AS date)
	   END AS changeDate
	  ,changeReasons
	  ,CASE WHEN ISNULL(T.stopDate, '')='' then CAST(NULL AS date)
	   ELSE CAST(T.stopDate AS date)
	   END AS stopDate
	  ,StopReasons
	  ,CASE WHEN T.TreatmentStatus IN ('Past', 'Past use') AND ISNULL(T.stopDate, '')<>'' THEN DATEDIFF(dd, T.stopDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS DaysSincePastUse
	  ,CASE WHEN T.TreatmentStatus='Current' AND ISNULL(T.startDate, '')<>'' THEN DATEDIFF(mm, T.startDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS MonthsSinceStart
	  ,CASE WHEN T.TreatmentStatus='Current' AND ISNULL(T.startDate, '')<>'' THEN DATEDIFF(DD, T.startDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS DaysSinceStart
INTO #DA
FROM #ENROLL E
LEFT JOIN [Reporting].[PSO500].[t_op_AllDrugs] T ON T.VisitID=E.VisitId AND T.VisitType='Enrollment' AND E.SubjectID=T.SubjectID

--SELECT * FROM #DA WHERE SubjectID IN (49980039112) ORDER BY SubjectID, TreatmentStatus DESC


/**Get past use**/

IF OBJECT_ID('tempdb.dbo.#ET') IS NOT NULL BEGIN DROP TABLE #ET END;

SELECT DISTINCT DA.VisitId
	  ,SiteID
	  ,SiteStatus
	  ,Country
	  ,SubjectID
	  ,ProviderID
	  ,SUB_BirthDate
	  ,VisitDate
	  ,SUB_Age
	  ,DiagnosisYear
	  ,crfStatus
	  ,Treatment
	  ,otherTreatment
	  ,TreatmentName
	  ,FirstDoseToday
	  ,firstUse
	  ,enteredStartDate
	  ,startDate
	  ,StartReasons
	  ,changeDate
	  ,changeReasons
	  ,stopDate
	  ,StopReasons
	  ,DaysSincePastUse
	  ,MonthsSinceStart
	  ,DaysSinceStart

	  ,CASE WHEN TreatmentStatus IN ('Start drug', 'Prescribed Today') THEN 'Prescribed at visit'
	   WHEN TreatmentStatus='Current' AND EXISTS(SELECT stopDate FROM #DA T2 WHERE T2.SubjectID=DA.SubjectID AND T2.VisitID=DA.VisitID AND T2.VisitDate=DA.VisitDate AND T2.TreatmentName=DA.TreatmentName AND T2.TreatmentStatus='Stopped Today' AND T2.stopDate=VisitDate) THEN 'Stopped Today'

	   WHEN TreatmentStatus IN ('Stopped Today', 'Stop drug') AND stopDate=VisitDate THEN 'Stopped Today'
	   WHEN TreatmentStatus IN ('Current', 'Changes Prescribed', 'No changes', 'Change dose') THEN 'Current'
	   WHEN ISNULL(TreatmentStatus, '') IN ('', 'Unknown') THEN 'Unknown'
	   WHEN TreatmentStatus IN ('Past', 'Past use') THEN 'Past use'
	   WHEN TreatmentStatus='Stopped Today' AND StopReasons LIKE '%TI%' THEN 'Needs review-TI'
	   WHEN TreatmentStatus IN ('Stop drug', 'Stopped Today') THEN 'Stopped Today'
	   WHEN crfStatus='No data' THEN 'n/a'
	   WHEN Treatment='No treatment' THEN 'n/a'
	   WHEN Treatment='' THEN 'n/a'
	   ELSE CAST(TreatmentStatus AS nvarchar)
	   END AS TreatmentStatus

	  ,(SELECT DISTINCT [Drug Cohort] FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment) AS DrugCohort

	  ,CASE WHEN VisitDate > '2023-11-05' AND EXISTS(SELECT TreatmentName FROM #DA D2 WHERE D2.SubjectID=DA.SubjectID AND D2.TreatmentName=DA.TreatmentName AND D2.TreatmentStatus<>DA.TreatmentStatus AND D2.TreatmentStatus IN ('Past', 'Past use')) THEN 'Not eligible'

       WHEN VisitDate > '2023-11-05' AND firstUse='No' THEN 'Not eligible'

	   WHEN VisitDate >= '2022-09-09' AND TreatmentName='deucravacitinib {Sotyktu}' AND TreatmentStatus IN ('Start drug', 'Prescribed Today')  THEN 'Eligible'
	   WHEN VisitDate >= '2022-09-09' AND Treatment='apremilast {Otezla}' AND TreatmentStatus IN ('Start drug', 'Prescribed Today')  THEN 'Eligible'
	   WHEN VisitDate >= '2022-09-09' AND TreatmentName='deucravacitinib {Sotyktu}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') AND startDate<>VisitDate THEN 'Not eligible'
	   WHEN VisitDate >= '2022-09-09' AND Treatment='apremilast {Otezla}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') AND startDate<>VisitDate THEN 'Not eligible'
	   WHEN VisitDate >= '2022-09-09' AND TreatmentName='deucravacitinib {Sotyktu}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') AND startDate=VisitDate THEN 'Needs review'
	   WHEN VisitDate >= '2022-09-09' AND Treatment='apremilast {Otezla}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') AND startDate=VisitDate THEN 'Needs review'

	   WHEN VisitDate < '2023-11-06' AND Treatment IN (SELECT TreatmentName FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment AND VisitDate BETWEEN DR.[Start Date] AND DR.[End Date]) AND TreatmentStatus IN ('Current', 'Changes Prescribed', 'Prescribed Today') THEN 'Eligible'

	   WHEN VisitDate >= '2023-11-06' AND (Treatment IN (SELECT TreatmentName FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment AND VisitDate BETWEEN DR.[Start Date] AND DR.[End Date]) AND TreatmentStatus IN ('Current', 'Changes Prescribed', 'Prescribed Today')) AND (NOT EXISTS(SELECT TreatmentName FROM #DA VE WHERE VE.SubjectID=DA.SubjectID AND VE.TreatmentName=DA.TreatmentName AND VE.TreatmentStatus IN ('Past', 'Past use'))) THEN 'Eligible'

	   WHEN VisitDate >= '2023-11-06' AND (Treatment IN (SELECT TreatmentName FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment AND VisitDate BETWEEN DR.[Start Date] AND DR.[End Date]) AND TreatmentStatus IN ('Current', 'Changes Prescribed', 'Prescribed Today')) AND (EXISTS(SELECT TreatmentName FROM #DA VE WHERE VE.SubjectID=DA.SubjectID AND VE.TreatmentName=DA.TreatmentName AND VE.TreatmentStatus IN ('Past', 'Past use'))) THEN 'Not eligible'

	   WHEN Treatment NOT IN (SELECT TreatmentName FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment AND VisitDate BETWEEN DR.[Start Date] AND DR.[End Date]) THEN 'Not eligible'

	   WHEN Treatment='No Treatment' THEN 'Not eligible'
	   WHEN Treatment LIKE 'Other%' THEN 'Needs review'
	   WHEN Treatment='Investigational Agent' THEN 'Not eligible'
	   WHEN TreatmentStatus IN ('Past', 'Stopped Today', 'Past use') THEN 'Not eligible'

	   WHEN Treatment IN (SELECT TreatmentName FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment AND VisitDate BETWEEN DR.[Start Date] AND DR.[End Date]) AND TreatmentStatus IN ('Current', 'Changes Prescribed', 'Prescribed Today') THEN 'Eligible'

	   WHEN Treatment IN (SELECT TreatmentName FROM [PSO500].[t_op_EER_DrugRef] DR WHERE DR.TreatmentName=Treatment AND VisitDate BETWEEN DR.[Start Date] AND DR.[End Date]) AND TreatmentStatus IN ('', 'Unknown') THEN 'Needs review'
	   WHEN crfStatus='No data' THEN 'Pending'
	   ELSE ''
	   END AS EligibleTreatment

--As of Nov 6, Past use of treatment is not eligible

	,CASE WHEN VisitDate > '2023-11-05' AND EXISTS(SELECT Treatment FROM #DA DA2 WHERE DA2.SubjectID=DA.SubjectID AND DA2.TreatmentName=DA.TreatmentName AND (DA2.TreatmentStatus IN ('Past', 'Past use'))) THEN 'Not eligible'

	 WHEN VisitDate > '2023-11-05' AND firstUse='No' THEN 'Not eligible'
	
	  WHEN VisitDate >= '2022-09-09' AND TreatmentName='deucravacitinib {Sotyktu}' AND TreatmentStatus IN ('Start drug', 'Prescribed Today')  THEN 'Eligible'
	  WHEN VisitDate >= '2022-09-09' AND Treatment='apremilast {Otezla}' AND TreatmentStatus IN ('Start drug', 'Prescribed Today')  THEN 'Eligible'
	  WHEN VisitDate >= '2022-09-09' AND TreatmentName='deucravacitinib {Sotyktu}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') THEN 'Not eligible'
	  WHEN VisitDate >= '2022-09-09' AND Treatment='apremilast {Otezla}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') THEN 'Not eligible'
	  WHEN VisitDate >= '2022-09-09' AND TreatmentName='deucravacitinib {Sotyktu}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') AND startDate=VisitDate THEN 'Needs review'
	  WHEN VisitDate >= '2022-09-09' AND Treatment='apremilast {Otezla}' AND TreatmentStatus NOT IN ('Start drug', 'Prescribed Today') AND startDate=VisitDate THEN 'Needs review'

	  WHEN TreatmentStatus IN ('Current') THEN 'Eligible'
	  WHEN TreatmentStatus IN ('Prescribed Today', 'Changes Prescribed', 'Start drug', 'Change dose', 'No changes') THEN 'Eligible'
	  WHEN TreatmentStatus='Stopped Today' AND StopReasons LIKE '%TI%' THEN 'Needs review-TI'
	  WHEN TreatmentStatus='Stopped Today' AND StopReasons NOT LIKE '%TI%' THEN 'Not eligible'
	  WHEN TreatmentStatus='' THEN 'Needs review'
	  WHEN crfStatus='No data' THEN 'Pending'
	  WHEN TreatmentStatus IN ('Past', 'Stopped Today', 'Past use') THEN 'Not eligible'
	  ELSE ''
	  END AS EligibleTreatmentStatus

INTO #ET 
FROM #DA DA

--SELECT * FROM #ET WHERE SubjectID IN (49980039112) ORDER BY SubjectID, EligibleTreatment


--SELECT * FROM #ET WHERE SubjectID IN (49980039104, 49980039105) ORDER BY SubjectID


/**Add Hierarchies for choosing Eligible Treatment**/

IF OBJECT_ID('tempdb.dbo.#ET2') IS NOT NULL BEGIN DROP TABLE #ET2 END;

SELECT DISTINCT ET.VisitId
	  ,ET.SiteID
	  ,ET.SiteStatus
	  ,ET.Country
	  ,ET.SubjectID
	  ,ET.ProviderID
	  ,ET.SUB_BirthDate
	  ,ET.VisitDate
	  ,ET.SUB_Age
	  ,ET.DiagnosisYear
	  ,ET.crfStatus
	  ,ET.Treatment
	  ,ET.otherTreatment
	  ,ET.TreatmentName
	  ,ET.DrugCohort
	  ,ET.FirstDoseToday
	  ,ET.firstUse
	  ,CASE WHEN ET.TreatmentStatus NOT IN ('Past use', 'Past') AND ISNULL(T.Treatment, '')<>'' THEN 'No'
	   WHEN ET.TreatmentStatus NOT IN ('Past use', 'Past') AND ISNULL(T.Treatment, '')='' THEN 'Yes'
	   ELSE ''
	   END AS calcFirstUse
	  ,ET.TreatmentStatus
	  ,T.Treatment AS DrugTableTreatment
	  ,ET.EligibleTreatment
	  ,ET.EligibleTreatmentStatus
	  ,ET.enteredStartDate
	  ,ET.startDate
	  ,ET.changeDate
	  ,ET.stopDate
	  ,ET.DaysSincePastUse
	  ,ET.MonthsSinceStart
	  ,ET.DaysSinceStart
	  ,(SELECT COUNT(*) FROM [PSO500].[t_op_AllDrugs] ET2 WHERE ET2.SubjectID=ET.SubjectID AND ET2.VisitID=ET.VisitId AND ET2.crfName='Biologic Medications_MDEN') AS 'BiologicCount'
	  ,CASE WHEN ET.VisitDate>'2020-04-30' AND ET.DrugCohort='Non Biologic' AND (SELECT COUNT(*) FROM [PSO500].[t_op_AllDrugs] ET2 WHERE ET2.SubjectID=ET.SubjectID AND ET2.VisitID=ET.VisitId AND ET2.crfName='Biologic Medications_MDEN')=0 THEN 'Yes'
	   WHEN ET.VisitDate>'2020-04-30' AND ET.DrugCohort='Non Biologic' AND (SELECT COUNT(*) FROM [PSO500].[t_op_AllDrugs] ET2 WHERE ET2.SubjectID=ET.SubjectID AND ET2.VisitID=ET.VisitId AND ET2.crfName='Biologic Medications_MDEN')>0  THEN 'No'
	   ELSE '-'
	   END AS BiologicNaive

INTO #ET2
FROM #ET ET
LEFT JOIN [Reporting].[PSO500].[t_op_AllDrugs] T ON T.VisitId=ET.VisitId AND T.VisitType='Enrollment' AND T.Treatment=ET.Treatment AND T.otherTreatment=ET.otherTreatment AND T.TreatmentStatus IN ('Past use', 'Past') 

--SELECT * FROM #ET2 WHERE SubjectID IN (49980039112) ORDER BY SubjectID

/**Find Previous Use and Length of Interruption**/

IF OBJECT_ID('tempdb.dbo.#INTERRUPT') IS NOT NULL BEGIN DROP TABLE #INTERRUPT END;

SELECT DISTINCT E.VisitId
	  ,E.SiteID
	  ,E.SiteStatus
	  ,E.Country
	  ,E.SubjectID
	  ,E.ProviderID
	  ,E.SUB_BirthDate
	  ,E.VisitDate
	  ,CAST(E.SUB_Age AS int) AS SUB_Age
	  ,E.DiagnosisYear
	  ,E.crfStatus
	  ,E.Treatment AS currentTreatment
	  ,E.otherTreatment AS otherCurrentTreatment
	  ,E.FirstDoseToday
	  ,E.firstUse
	  ,CASE WHEN T.Treatment IS NOT NULL THEN 'No'
	   ELSE ''
	   END AS calcFirstUse
	  ,T.Treatment AS pastTreatment
	  ,T.otherTreatment AS otherPastTreatment
	  ,E.TreatmentStatus
	  ,T.enteredStartDate
	  ,CAST(E.startDate AS date) AS startDate
	  ,E.stopDate
	  ,CAST(T.startDate AS date) AS pastUseStartDate
	  ,CAST(T.stopDate AS date) AS pastUseStopDate
	  ,CASE WHEN ISNULL(T.stopDate, '')<>'' THEN DATEDIFF(mm, T.stopDate, E.VisitDate)
	   ELSE CAST(NULL AS int)
	   END AS MonthsSincePreviousStop
	  ,E.MonthsSinceStart
	  ,E.DaysSinceStart
	  ,E.BiologicNaive

	  ,CASE WHEN ISNULL(E.startDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.startDate >= T.stopDate
	     THEN DATEDIFF(dd, T.stopDate, E.startDate) 
       WHEN ISNULL(E.startDate, '')='' AND E.TreatmentStatus='Prescribed at visit' THEN DATEDIFF(dd, T.stopDate, E.VisitDate)
		ELSE CAST(NULL AS bigint) 
		END AS DaysInterrupted
	 ,CASE WHEN ISNULL(T.startDate, '')<>'' THEN DATEDIFF(mm, T.startDate, E.VisitDate)
	  ELSE CAST(NULL AS bigint)
	  END AS MonthsSincePastUseStart

	 ,CASE WHEN E.VisitDate >= '2022-04-30' THEN '-'
	   WHEN E.VisitDate < '2017-06-12' THEN '-'
	   WHEN ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND DATEDIFF(dd, T.stopDate, E.VisitDate) >= 365 THEN 'Yes'
       WHEN E.TreatmentStatus='Current' AND ISNULL(E.startDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.startDate > T.stopDate AND DATEDIFF(dd, T.stopDate, E.startDate)<= 180 AND DATEDIFF(dd, T.stopDate, E.VisitDate) < 365 THEN 'Yes'
	   WHEN E.TreatmentStatus='Current' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.startDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.startDate)>180 AND DATEDIFF(dd, T.stopDate, E.VisitDate) < 365 THEN 'No'
	   WHEN E.TreatmentStatus='Current' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '') <> '' AND E.startDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.startDate)<=180 AND DATEDIFF(dd, T.startDate, E.VisitDate) >= 365 THEN 'No'
       WHEN E.TreatmentStatus='Prescribed at visit' AND ISNULL(E.VisitDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate  AND DATEDIFF(dd, T.stopDate, E.VisitDate)<=180 THEN 'Yes'
	   WHEN E.TreatmentStatus='Prescribed at visit' AND ISNULL(E.VisitDate, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate  AND DATEDIFF(dd, T.stopDate, E.VisitDate)>180 THEN 'No'
	   WHEN E.TreatmentStatus='Prescribed at visit' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate AND DATEDIFF(dd, T.stopDate, E.VisitDate) >= 365 THEN 'No'
	   WHEN E.TreatmentStatus='Prescribed at visit' AND ISNULL(T.Treatment, '')<>'' AND ISNULL(T.stopDate, '')<>'' AND E.VisitDate > T.stopDate AND  DATEDIFF(dd, T.stopDate, E.VisitDate)<=180 AND DATEDIFF(dd, T.startDate, E.VisitDate) >= 365 THEN 'No'
	   WHEN ISNULL(T.Treatment, '')<>'' AND (ISNULL(T.stopDate, '')='' OR ISNULL(T.startDate, '')='') THEN 'Unknown'
	   ELSE ''
	   END AS AllowedPreviousUse
 
INTO #INTERRUPT
FROM #ET2 E 
LEFT JOIN [Reporting].[PSO500].[t_op_AllDrugs] T ON T.VisitId=E.VisitId AND T.VisitType='Enrollment' AND T.Treatment=E.Treatment AND T.otherTreatment=E.otherTreatment AND T.TreatmentStatus IN ('Past' , 'Past use')
WHERE E.TreatmentStatus IN ('Current', 'Prescribed at visit', 'Changes Prescribed') AND ISNULL(T.Treatment, '')<>''

--SELECT * FROM #INTERRUPT


/**Determine if treatments were started during interruption if interruption was less than 180 days**/

IF OBJECT_ID('tempdb.dbo.#TRXMTBETWEEN') IS NOT NULL BEGIN DROP TABLE #TRXMTBETWEEN END;

SELECT DISTINCT I.VisitId
	  ,I.SiteID
	  ,I.SiteStatus
	  ,I.Country
	  ,I.SubjectID
	  ,I.ProviderID
	  ,I.SUB_BirthDate
	  ,I.VisitDate
	  ,I.SUB_Age
	  ,I.DiagnosisYear
	  ,I.crfStatus
	  ,I.currentTreatment AS Treatment
	  ,I.otherCurrentTreatment AS otherTreatment
	  ,I.FirstDoseToday
	  ,I.firstUse
	  ,I.calcFirstUse
	  ,I.TreatmentStatus
	  ,I.enteredStartDate
	  ,I.startDate
	  ,I.pastUseStartDate
	  ,I.MonthsSinceStart
	  ,I.DaysSinceStart
	  ,I.BiologicNaive
	  ,I.stopDate
	  ,I.pastUseStopDate
	  ,I.DaysInterrupted
	  ,I.MonthsSincePastUseStart
	  ,I.AllowedPreviousUse
	  ,CASE WHEN EXISTS (SELECT T.Treatment FROM [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=I.VisitID AND T.Treatment<>I.currentTreatment AND I.DaysInterrupted < 180 AND ISNULL(T.startDate, '')<>'' AND I.TreatmentStatus IN ('Current', 'Prescribed at visit') AND CAST(T.startDate AS date) BETWEEN I.stopDate AND I.startDate) THEN 'Yes'
	   ELSE 'No'
	   END AS trxmtBetween
	  ,(SELECT T.Treatment FROM [Reporting].[PSO500].[t_op_AllDrugs] T WHERE T.VisitID=I.VisitID AND T.Treatment<>I.currentTreatment AND I.DaysInterrupted < 180 AND ISNULL(T.startDate, '')<>'' AND I.TreatmentStatus IN ('Current', 'Prescribed at visit') AND CAST(T.startDate AS date) BETWEEN I.stopDate AND I.startDate) AS TreatmentBetweenName

INTO #TRXMTBETWEEN
FROM #INTERRUPT I
WHERE DaysInterrupted<=180

--SELECT * FROM #TRXMTBETWEEN WHERE SubjectID IN (49980039104, 49980039105) ORDER BY SubjectID


/**Determine drug eligibility**/

IF OBJECT_ID('tempdb.dbo.#DrugElig') IS NOT NULL BEGIN DROP TABLE #DrugElig END;

SELECT DISTINCT ET.VisitId
	  ,ET.SiteID
	  ,ET.SiteStatus
	  ,ET.Country
	  ,ET.SubjectID
	  ,ET.ProviderID
	  ,ET.SUB_BirthDate
	  ,ET.VisitDate
	  ,ET.SUB_Age
	  ,ET.DiagnosisYear
	  ,ET.crfStatus
	  ,ET.Treatment
	  ,ET.otherTreatment
	  ,ET.FirstDoseToday
	  ,ET.firstUse
	  ,ET.calcFirstUse
	  ,ET.[DrugCohort]
	  ,ET.TreatmentStatus
	  ,ET.EligibleTreatmentStatus
	  ,CASE WHEN ET.VisitDate BETWEEN '2020-05-01' AND '2022-09-08' AND ET.EligibleTreatment='Eligible' AND ET.[DrugCohort]='Non Biologic' AND ET.BiologicNaive='No' THEN 'Not eligible'
       ELSE ET.EligibleTreatment	  
	   END AS EligibleTreatment
	  ,ET.enteredStartDate
	  ,ET.startDate
	  ,I.pastUseStartDate
	  ,ET.MonthsSinceStart
	  ,ET.DaysSinceStart
	  ,ET.BiologicNaive
	  ,ET.stopDate
	  ,I.pastUseStopDate
	  ,I.MonthsSincePreviousStop
	  ,I.DaysInterrupted
  	  ,I.MonthsSincePastUseStart
	  ,I.AllowedPreviousUse
	  ,TB.trxmtBetween

INTO #DrugElig
FROM #ET2 ET 
LEFT JOIN #INTERRUPT I ON I.VisitId=ET.VisitId AND I.currentTreatment=ET.Treatment AND I.otherCurrentTreatment=ET.otherTreatment AND I.TreatmentStatus=ET.TreatmentStatus
LEFT JOIN #TRXMTBETWEEN TB ON TB.VisitId=ET.VisitId AND TB.Treatment=ET.Treatment AND TB.otherTreatment=ET.otherTreatment AND TB.TreatmentStatus=ET.TreatmentStatus

--SELECT * FROM #DrugElig WHERE SubjectID IN (49980039104, 49980039105) ORDER BY SubjectID

/**Determine Subject Eligibility**/

IF OBJECT_ID('tempdb.dbo.#EnrollEligibility') IS NOT NULL BEGIN DROP TABLE #EnrollEligibility END;

SELECT DISTINCT A.VisitId
	  ,A.SiteID
	  ,A.SiteStatus
	  ,A.Country
	  ,A.SubjectID
	  ,A.ProviderID
	  ,A.BirthYear
	  ,A.VisitDate
	  ,A.AgeAtEnroll
	  ,A.DiagnosisYear
	  ,A.crfStatus
	  ,A.Treatment
	  ,A.otherTreatment
	  ,A.TreatmentName
  	  ,CASE WHEN A.VisitDate BETWEEN '2017-06-12' AND '2022-04-30' AND A.EligibleTreatment='Eligible' AND UPPER(A.Treatment) NOT LIKE '%OTHER%' AND A.TreatmentStatus='Prescribed at visit' AND A.DrugCohort='Biologic or Biosimilar' AND A.EligibleTreatmentStatus='Eligible' AND AllowedPreviousUse='No' THEN 52
	   WHEN A.VisitDate BETWEEN '2017-06-12' AND '2022-04-30' AND A.EligibleTreatment='Eligible' AND UPPER(A.Treatment) LIKE '%OTHER%' AND A.TreatmentStatus='Prescribed at visit' AND A.DrugCohort='Non Biologic' AND A.EligibleTreatmentStatus='Eligible' AND AllowedPreviousUse='No' THEN 53
	   WHEN A.EligibleTreatment='Eligible' AND UPPER(A.Treatment) NOT LIKE '%OTHER%' AND A.TreatmentStatus='Prescribed at visit' AND A.DrugCohort='Biologic or Biosimilar' AND A.EligibleTreatmentStatus='Eligible' THEN 10
	   WHEN A.EligibleTreatment='Eligible' AND UPPER(A.Treatment) NOT LIKE '%OTHER%' AND A.TreatmentStatus='Current' AND A.DrugCohort='Biologic or Biosimilar' AND A.EligibleTreatmentStatus='Eligible' AND A.TwelveMonthInitiationRule='Met' THEN 20
	   WHEN A.EligibleTreatment='Eligible' AND UPPER(A.Treatment) NOT LIKE '%OTHER%' AND A.TreatmentStatus='Current' AND A.DrugCohort='Biologic or Biosimilar' AND A.EligibleTreatmentStatus='Eligible' AND A.TwelveMonthInitiationRule='Unknown' THEN 25
	   WHEN A.EligibleTreatment='Eligible' AND A.TreatmentStatus='Current' AND A.DrugCohort='Biologic or Biosimilar' AND A.EligibleTreatmentStatus='Eligible' AND A.TwelveMonthInitiationRule='Not met' THEN 70
	   WHEN A.TreatmentStatus='Prescribed at visit' AND A.EligibleTreatment='Eligible' AND A.DrugCohort='Non Biologic' AND A.EligibleTreatmentStatus='Eligible' THEN 30 
	   WHEN A.TreatmentStatus='Current' AND A.EligibleTreatment='Eligible' AND A.DrugCohort='Non Biologic' AND A.EligibleTreatmentStatus='Eligible' AND TwelveMonthInitiationRule='Met' THEN 35
	   WHEN A.EligibleTreatment='Eligible' AND A.TreatmentStatus='Current' AND A.DrugCohort='Non Biologic' AND A.EligibleTreatmentStatus='Eligible' AND A.TwelveMonthInitiationRule='Not met' THEN 75
	   WHEN A.Treatment='Other BIOSIMILAR' AND A.TreatmentStatus='Current' AND A.EligibleTreatment='Eligible' AND TwelveMonthInitiationRule='Met' THEN 37
	   WHEN A.TreatmentStatus IN ('Prescribed at visit', 'Current') AND UPPER(A.Treatment) LIKE '%OTHER%' AND EligibleTreatment='Needs review' THEN 40
	   WHEN A.TreatmentStatus = 'Stopped Today' AND EligibleTreatmentStatus='Needs review-TI' THEN 40
	   WHEN A.TreatmentStatus IN ('Unknown', '') THEN 45
	   WHEN A.crfStatus='No Data' THEN 50
	   WHEN A.EligibleTreatment='Not eligible' AND A.TreatmentStatus='Prescribed at visit' THEN 55
	   WHEN A.EligibleTreatment='Not eligible' AND A.TreatmentStatus='Current' THEN 57
	   WHEN A.TreatmentStatus = 'Stopped Today' AND EligibleTreatmentStatus<>'Needs review-TI' THEN 60
	   WHEN A.TreatmentStatus='Prescribed at visit' AND  A.EligibleTreatment='Not eligible' THEN 70
	   WHEN A.TreatmentStatus='Current' AND A.EligibleTreatment='Not eligible' THEN 75
		ELSE 90
		END AS DrugHierarchy
	  ,A.FirstDoseToday
	  ,A.firstUse
	  ,A.calcFirstUse
	  ,A.AllowedPreviousUse
	  ,A.BiologicNaive
	  ,A.DrugCohort
	  ,A.TreatmentStatus
	  ,A.EligibleTreatmentStatus
	  ,A.EligibleTreatment
	  ,A.enteredStartDate
	  ,A.startDate
	  ,A.pastUseStartDate
	  ,A.MonthsSinceStart
	  ,A.DaysSinceStart
	  ,A.stopDate
	  ,A.pastUseStopDate
	  ,A.DaysInterrupted
	  ,A.MonthsSincePastUseStart
	  ,A.MonthsSincePreviousStop
	  ,A.trxmtBetween
	  ,A.TwelveMonthInitiationRule

INTO #EnrollEligibility
FROM
(SELECT DISTINCT DE.VisitId
	  ,DE.SiteID
	  ,DE.SiteStatus
	  ,DE.Country
	  ,DE.SubjectID
	  ,DE.ProviderID
	  ,DE.SUB_BirthDate AS BirthYear
	  ,DE.VisitDate
	  ,DE.SUB_Age AS AgeAtEnroll
	  ,DE.DiagnosisYear
	  ,DE.crfStatus
	  ,CASE WHEN DE.crfStatus='No Data' THEN 'No data'
	   WHEN DE.TreatmentStatus='Past use' THEN 'Past use only'
	   ELSE DE.Treatment
	   END AS Treatment
	  ,DE.otherTreatment
	  ,CASE WHEN ISNULL(DE.otherTreatment,'')<>'' THEN DE.Treatment + ': ' + DE.otherTreatment 
	   ELSE DE.Treatment
	   END AS TreatmentName
	  ,DE.FirstDoseToday
	  ,DE.firstUse
	  ,DE.calcFirstUse
	  ,DE.AllowedPreviousUse
	  ,BiologicNaive
	  ,DE.DrugCohort
	  ,DE.TreatmentStatus
	  ,DE.EligibleTreatmentStatus
	  ,CASE WHEN ISNULL(DE.EligibleTreatmentStatus, '')='Not eligible' THEN 'Not eligible'
	   ELSE DE.EligibleTreatment
	   END AS EligibleTreatment
	  ,DE.enteredStartDate
	  ,DE.startDate
	  ,DE.pastUseStartDate
	  ,DE.MonthsSinceStart
	  ,DE.DaysSinceStart
	  ,DE.stopDate
	  ,DE.pastUseStopDate
	  ,DE.DaysInterrupted
	  ,DE.MonthsSincePastUseStart
	  ,DE.MonthsSincePreviousStop
	  ,DE.trxmtBetween
	  ,CASE WHEN DE.TreatmentStatus='Current' AND DE.DaysSinceStart<=365 THEN 'Met'
	   WHEN DE.TreatmentStatus='Current' AND DE.DaysSinceStart > 365 THEN 'Not met'
	   WHEN DE.TreatmentStatus='Current' AND DE.DaysSinceStart IS NULL THEN 'Unknown'
	   WHEN DE.TreatmentStatus<>'Current' THEN '-'
	   ELSE ''
	   END AS TwelveMonthInitiationRule
FROM #DrugElig DE
) A

--SELECT * FROM #EnrollEligibility WHERE SubjectID IN (49980039104, 49980039105) ORDER BY SiteID, SubjectID, DrugHierarchy



/**Find Exited Subjects**/

IF OBJECT_ID('tempdb.dbo.#EX') IS NOT NULL BEGIN DROP TABLE #EX END;

SELECT DISTINCT [Site ID]
      ,[SubjectID]
      ,VisitDate AS [ExitDate]
      ,[Exit Reason]
INTO #EX
FROM [Reporting].[PSO500].[v_op_ExitReport]

--SELECT * FROM [Reporting].[PSO500].[v_op_ExitReport]


/**Find Registry Enrollment Status**/

IF OBJECT_ID('tempdb.dbo.#RES') IS NOT NULL BEGIN DROP TABLE #RES END;

SELECT DISTINCT EE.VisitId
	   ,EE.SiteID
	   ,EE.SiteStatus
	   ,EE.Country
	   ,EE.SubjectID
	   ,EE.ProviderID
	   ,EE.BirthYear
	   ,EE.VisitDate AS EnrollDate
	   ,EE.AgeAtEnroll
	   ,EE.DiagnosisYear
	   ,EE.crfStatus
	   ,EE.Treatment
	   ,EE.otherTreatment
	   ,CASE WHEN EE.Treatment='No data' THEN 'No data'
	    ELSE EE.TreatmentName
		END AS TreatmentName
	   ,EE.DrugHierarchy
	   ,EE.FirstDoseToday
	   ,EE.firstUse
	   ,EE.calcFirstUse
	   ,EE.AllowedPreviousUse
	   ,EE.BiologicNaive
	   ,EE.DrugCohort
	   ,EE.TreatmentStatus
	  ,CASE WHEN EE.EligibleTreatment='Eligible' AND EE.TreatmentStatus='Prescribed at visit' THEN 10
	   WHEN EE.TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' THEN 20
	   WHEN EE.TreatmentStatus='Unknown' THEN 30
	   WHEN EE.TreatmentStatus='Current' AND TwelveMonthInitiationRule='Not met' THEN 35
	   WHEN EE.TreatmentStatus IN ('Past use', 'Past') THEN 40
	   ELSE 90
	   END AS TreatmentStatusHierarchy

	   ,EE.EligibleTreatment
	   ,EE.enteredStartDate
	   ,EE.startDate
	   ,EE.stopDate
	   ,EE.pastUseStartDate
	   ,EE.pastUseStopDate
	   ,EE.MonthsSinceStart
	   ,EE.DaysSinceStart
	   ,EE.DaysInterrupted
	   ,EE.trxmtBetween
	   ,EE.MonthsSincePastUseStart
	   ,EE.TwelveMonthInitiationRule
	   ,CASE WHEN EE.TreatmentStatus='Current' AND EE.TwelveMonthInitiationRule='Not met' THEN 'Not eligible'
	    WHEN EE.TreatmentStatus='Current' AND EE.TwelveMonthInitiationRule='Unknown' THEN 'Needs review'
		ELSE EE.EligibleTreatmentStatus
		END AS EligibleTreatmentStatus
	  ,DATEDIFF(MM, pastUseStopDate, EE.VisitDate) AS MonthsSinceStop

	  ,CASE WHEN EE.Treatment='Investigational Agent' THEN 'Not eligible'
	   --WHEN EE.Treatment='bimekizumab' AND EE.Country='USA' THEN 'Needs review'
	   WHEN EE.Treatment='No data' THEN 'Needs review'
	   WHEN EligibleTreatment='Not eligible' THEN 'Not eligible'
	   WHEN ISNULL(AgeAtEnroll, '')='' THEN 'Needs review'
	   WHEN EE.TreatmentStatus='Unknown' THEN 'Needs Review'
	   WHEN EE.EligibleTreatmentStatus='Not eligible' THEN 'Not eligible'
	   WHEN EE.EligibleTreatmentStatus='Pending' THEN 'Needs review'
	   WHEN EE.EligibleTreatmentStatus IN ('Needs review-TI', 'Needs review') THEN 'Needs review'
	   WHEN EE.Treatment LIKE '%Other%' THEN 'Needs review'
	   WHEN EE.Treatment='No data' THEN 'Needs review'
	   WHEN EE.TreatmentStatus='Current' AND EE.EligibleTreatmentStatus='Eligible' AND EE.TwelveMonthInitiationRule='Unknown ' THEN 'Needs review'
	   WHEN TreatmentStatus='Current' AND TwelveMonthInitiationRule='Not met' THEN 'Not eligible'
	   WHEN EE.Treatment='Past use only' THEN 'Not eligible'
	   WHEN EE.Treatment='No treatment' THEN 'Not eligible'
	   WHEN EE.TreatmentStatus='Stopped Today' THEN 'Not eligible'
	   WHEN EE.TreatmentStatus IN ('Past use', 'Past') THEN 'Not eligible'
	   WHEN EE.VisitDate BETWEEN '2017-06-12' AND '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' AND (firstUse='Yes') OR (firstUse='' AND calcFirstUse='Yes') OR (calcfirstUse='No' AND AllowedPreviousUse='Yes') THEN 'Eligible'
	   WHEN EE.VisitDate < '2017-06-12' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' THEN 'Eligible'
	   WHEN EE.VisitDate BETWEEN '2017-06-12' AND '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' AND (firstUse='Yes') OR (firstUse='' AND calcFirstUse='Yes') OR (calcfirstUse='No' AND AllowedPreviousUse='Unknown') THEN 'Needs review'
	   WHEN EE.VisitDate BETWEEN '2017-06-12' AND '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' AND calcfirstUse='No' AND AllowedPreviousUse='' THEN 'Needs review'
	   WHEN EE.VisitDate <= '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' AND calcFirstUse='Yes' THEN 'Eligible'
	   WHEN EE.VisitDate > '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' THEN 'Eligible'
	   WHEN AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' THEN 'Eligible'
	   WHEN EE.VisitDate <= '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed at visit' AND calcFirstUse='No' AND AllowedPreviousUse='Yes' THEN 'Eligible'
	   WHEN AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' AND firstUse='No' AND calcFirstUse='Yes' THEN 'Eligible'
	   WHEN EE.VisitDate <= '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Prescribed Today' AND calcFirstUse='No' AND AllowedPreviousUse='Unknown' THEN 'Needs review'
	   WHEN EE.VisitDate <= '2022-04-30' AND AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' AND firstUse='No' AND calcFirstUse='No' AND AllowedPreviousUse='Unknown' THEN 'Needs review'
	   WHEN AgeAtEnroll>17 AND EligibleTreatment='Eligible' AND TreatmentStatus='Current' AND TwelveMonthInitiationRule='Unknown' THEN 'Needs review'
	   WHEN EE.VisitDate <= '2022-04-30' AND calcfirstUse='No' AND AllowedPreviousUse='No' THEN 'Not eligible'
	   WHEN AgeAtEnroll <=17 THEN 'Not eligible'
	   WHEN TwelveMonthInitiationRule='Not met' THEN 'Not eligible'
	   ELSE '' 
	   END AS RegistryEnrollmentStatus

INTO #RES 
FROM #EnrollEligibility EE

--SELECT * FROM #RES WHERE SubjectID IN (49980039104, 49980039105) ORDER BY SiteID, SubjectID, DrugHierarchy


/******************Determine Eligibility Hierarchy**************************/

IF OBJECT_ID('tempdb.dbo.#EligHierarchy') IS NOT NULL BEGIN DROP TABLE #EligHierarchy END;

SELECT VisitId
	  ,SiteID
	  ,SiteStatus
	  ,Country
	  ,SubjectID
	  ,ProviderID
	  ,BirthYear
	  ,EnrollDate
	  ,AgeAtEnroll
	  ,DiagnosisYear
	  ,crfStatus
	  ,Treatment
	  ,otherTreatment
	  ,TreatmentName
	  ,FirstDoseToday
	  ,firstUse
	  ,calcFirstUse
	  ,AllowedPreviousUse
	  ,BiologicNaive
	  ,DrugCohort
	  ,EligibleTreatment
	  ,TreatmentStatus
	  ,EligibleTreatmentStatus
	  ,TreatmentStatusHierarchy
	  ,enteredStartDate
	  ,startDate
	  ,stopDate
	  ,pastUseStartDate
	  ,pastUseStopDate
	  ,MonthsSinceStart
	  ,DaysSinceStart
	  ,DaysInterrupted
	  ,trxmtBetween
	  ,MonthsSincePastUseStart
	  ,TwelveMonthInitiationRule
	  ,RegistryEnrollmentStatusOrder
	  ,CASE WHEN RegistryEnrollmentStatus IN ('Eligible', 'Not eligible', 'Needs review') AND EligibilityReview='Not eligible - Exception granted' THEN 'Eligible - Review decision'
	   WHEN RegistryEnrollmentStatus IN ('Not eligible', 'Needs review') AND EligibilityReview='Eligible' THEN 'Eligible - Review decision'
	   WHEN RegistryEnrollmentStatus='Eligible' AND EligibilityReview='Eligible' THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus='Eligible' AND EligibilityReview='Not eligible' THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus='Needs review' AND EligibilityReview='Not eligible' THEN 'Not eligible'
	   WHEN RegistryEnrollmentStatus='Needs review' AND EligibilityReview IN ('Eligible', 'Not eligible - Exception granted') THEN 'Eligible'
	   WHEN RegistryEnrollmentStatus='Not eligible' AND EligibilityReview='Not eligible' THEN 'Not eligible - Confirmed'
	   WHEN RegistryEnrollmentStatus='' AND EligibilityReview='Eligible' THEN 'Eligible'
	   ELSE RegistryEnrollmentStatus
	   END AS RegistryEnrollmentStatus
	  ,DrugHierarchy
	  ,EnrollStatusHierarchy
	  ,EligibilityReview

INTO #EligHierarchy
FROM
(
SELECT  DISTINCT RES.VisitId
	   ,RES.SiteID
	   ,RES.SiteStatus
	   ,RES.Country
	   ,RES.SubjectID
	   ,RES.ProviderID
	   ,RES.BirthYear
	   ,RES.EnrollDate
	   ,RES.AgeAtEnroll
	   ,RES.DiagnosisYear
	   ,RES.crfStatus
	   ,RES.Treatment
	   ,RES.otherTreatment
	   ,RES.TreatmentName
	   ,RES.FirstDoseToday
	   ,RES.firstUse
	   ,RES.calcFirstUse
	   ,RES.AllowedPreviousUse
	   ,RES.BiologicNaive
	   ,RES.DrugCohort
	   ,RES.EligibleTreatment
	   ,RES.TreatmentStatus
	   ,RES.EligibleTreatmentStatus
	   ,RES.TreatmentStatusHierarchy
	   ,RES.enteredStartDate
	   ,RES.startDate
	   ,RES.stopDate
	   ,RES.pastUseStartDate
	   ,RES.pastUseStopDate
	   ,RES.MonthsSinceStart
	   ,RES.DaysSinceStart
	   ,RES.DaysInterrupted
	   ,RES.trxmtBetween
	   ,RES.MonthsSincePastUseStart
	   ,RES.TwelveMonthInitiationRule
	   ,RegistryEnrollmentStatus
	   ,RegistryEnrollmentStatus AS RegistryEnrollmentStatusOrder
	   ,RES.DrugHierarchy

	   ,CASE WHEN RES.EligibleTreatment='Eligible' AND RES.TreatmentStatus='Prescribed at visit' THEN 10
	    WHEN RES.EligibleTreatment='Eligible' AND RES.TreatmentStatus='Current' AND TwelveMonthInitiationRule='Met' THEN 20
		WHEN RES.EligibleTreatment='Eligible' AND RES.TreatmentStatus='Unknown' THEN 30
		WHEN RES.EligibleTreatment='Needs review' AND RES.TreatmentStatus='Prescribed at visit' THEN 40
		WHEN RES.EligibleTreatment='Needs review' AND RES.TreatmentStatus='Current' THEN 45
		WHEN RES.EligibleTreatment='Needs review' AND RES.TreatmentStatus='Unknown' THEN 50
		WHEN RES.EligibleTreatment='Eligible' AND RES.TreatmentStatus='Current' AND TwelveMonthInitiationRule='Not met' THEN 55
		WHEN RES.EligibleTreatment='Eligible' AND RES.TreatmentStatus IN ('Past use', 'Past') THEN 55
		WHEN RES.EligibleTreatment='Needs review' AND RES.TreatmentStatus IN ('Past use', 'Past') THEN 60
		WHEN RES.EligibleTreatment='Not eligible' AND RES.TreatmentStatus ='Prescribed at visit' THEN 65
		WHEN RES.EligibleTreatment='Not eligible' AND RES.TreatmentStatus ='Current' THEN 67
		WHEN RES.EligibleTreatment='Not eligible' AND RES.TreatmentStatus ='Unknown' THEN 69
		WHEN RES.EligibleTreatment='Not eligible' AND RES.TreatmentStatus IN ('Past use', 'Past') THEN 75
		ELSE 90
		END AS EnrollStatusHierarchy

	  ,CASE WHEN ELG.[ELGEN_ineligible_en]='No' AND ELG.[ELGEN_ineligible_en_exception]='Yes' THEN 'Not eligible - Exception granted'
	   WHEN ELG.[ELGEN_ineligible_en]='Under Review (Outcome TBD)' THEN 'Under Review (Outcome TBD)'
	   WHEN ELG.[ELGEN_ineligible_en]='No' AND ELG.[ELGEN_ineligible_en_exception] IN ('No', '') THEN 'Not eligible'
	   WHEN ELG.[ELGEN_ineligible_en]='Yes' THEN 'Eligible'
	   WHEN ISNULL(ELG.[ELGEN_ineligible_en], '')='' THEN 'NULL'
	   ELSE''
	   END AS EligibilityReview

FROM #RES RES
LEFT JOIN [OMNICOMM_PSO].[inbound].[ELG] ELG ON RES.SiteID=ELG.[Site Object SiteNo] AND RES.SubjectID=ELG.[Patient Object PatientNo] AND ELG.[Visit Object ProCaption]='Enrollment' AND ELG.VisitId=RES.VisitId /*AND ELG.[Site Object SiteNo] NOT IN (997, 998, 999)*/
) B

--SELECT * FROM #EligHierarchy WHERE SubjectID IN (49980039104, 49980039105) ORDER BY SiteID, SubjectID


/******************Determine Eligibility**************************/

IF OBJECT_ID('tempdb.dbo.#FinalElig') IS NOT NULL BEGIN DROP TABLE #FinalElig END;

SELECT DISTINCT EH.VisitID
	  ,EH.SiteID
	  ,EH.SiteStatus
	  ,EH.Country
	  ,EH.SubjectID
	  ,EH.ProviderID
	  ,EH.BirthYear
	  ,EH.EnrollDate
	  ,EH.AgeAtEnroll
	  ,EH.DiagnosisYear
	  ,EH.crfStatus
	  ,EH.Treatment
	  ,EH.otherTreatment
	  ,EH.TreatmentName
	  ,EH.FirstDoseToday
	  ,EH.firstUse
	  ,EH.calcFirstUse
	  ,EH.AllowedPreviousUse
	  ,EH.BiologicNaive
	  ,CASE WHEN EXISTS (SELECT startDate FROM #EligHierarchy E WHERE E.VisitId=EH.VisitId AND E.Treatment<>EH.Treatment AND E.DrugCohort='Biologic' AND E.startDate>EH.startDate AND EH.RegistryEnrollmentStatus IN ('Eligible', 'Needs Review')) THEN 'Yes'
	   ELSE ''
	   END AS additionalStartDate
	  ,EH.DrugCohort
	  ,EH.TreatmentStatus
	  ,EH.EligibleTreatment
	  ,EH.EligibleTreatmentStatus
	  ,EH.enteredStartDate
	  ,EH.startDate
	  ,EH.stopDate
	  ,EH.pastUseStartDate
	  ,EH.pastUseStopDate
	  ,EH.MonthsSinceStart
	  ,EH.DaysSinceStart
	  ,EH.DaysInterrupted
	  ,EH.trxmtBetween
	  ,EH.MonthsSincePastUseStart
	  ,EH.TwelveMonthInitiationRule
 	  ,EH.TreatmentStatusHierarchy 
	  ,EH.DrugHierarchy
	  ,EH.EnrollStatusHierarchy
  	  ,EH.RegistryEnrollmentStatus	
	  ,EH.RegistryEnrollmentStatusOrder
	  ,EH.EligibilityReview

INTO #FinalElig
FROM #EligHierarchy EH


/*****Table for PSO Enrollment Eligibility Report*****/
		 
TRUNCATE TABLE [Reporting].[PSO500].[t_op_EER];

INSERT INTO [Reporting].[PSO500].[t_op_EER]
(
VisitID,
FE.SiteID,
FE.SiteStatus,
Country,
SubjectID,
ProviderID,
BirthYear,
AgeAtEnroll,
EnrollDate,
DiagnosisYear,
crfStatus,
Treatment,
otherTreatment,
TreatmentName,
EligibleTreatment,
FirstDoseToday,
firstUse,
calcFirstUse,
AllowedPreviousUse,
BiologicNaive,
additionalStartDate,
DrugCohort,
TreatmentStatus,
TwelveMonthInitiationRule,
enteredStartDate,
startDate,
stopDate,
pastUseStartDate,
pastUseStopDate,
MonthsSinceStart,
DaysSinceStart,
DaysInterrupted,
trxmtBetween,
MonthsSincePastUseStart,
RegistryEnrollmentStatus,
EligibilityReview
)

SELECT DISTINCT VisitID,
SiteID,
SiteStatus,
Country,
SubjectID,
ProviderID,
BirthYear,
AgeAtEnroll,
EnrollDate,
DiagnosisYear,
crfStatus,
Treatment,
otherTreatment,
TreatmentName,
EligibleTreatment,
FirstDoseToday,
firstUse,
calcFirstUse,
AllowedPreviousUse,
BiologicNaive,
additionalStartDate,
DrugCohort,
TreatmentStatus,
TwelveMonthInitiationRule,
enteredStartDate,
startDate,
stopDate,
pastUseStartDate,
pastUseStopDate,
MonthsSinceStart,
DaysSinceStart,
DaysInterrupted,
trxmtBetween,
MonthsSincePastUseStart,
RegistryEnrollmentStatus,
EligibilityReview
FROM
(
SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY FE.VisitId, FE.SiteID, FE.SubjectID ORDER BY FE.SiteID, FE.SubjectID, FE.RegistryEnrollmentStatusOrder, FE.EligibleTreatment, FE.DrugHierarchy, FE.EnrollStatusHierarchy, FE.StartDate DESC, FE.Treatment) AS ROWNUM,
VisitID,
FE.SiteID,
FE.SiteStatus,
Country,
SubjectID,
ProviderID,
BirthYear,
AgeAtEnroll,
EnrollDate,
DiagnosisYear,
crfStatus,
Treatment,
otherTreatment,
TreatmentName,
EligibleTreatment,
FirstDoseToday,
firstUse,
calcFirstUse,
AllowedPreviousUse,
BiologicNaive,
additionalStartDate,
DrugCohort,
TreatmentStatus,
TwelveMonthInitiationRule,
REPLACE(enteredStartDate, '/', '-') AS enteredStartDate,
startDate,
stopDate,
pastUseStartDate,
pastUseStopDate,
MonthsSinceStart,
DaysSinceStart,
DaysInterrupted,
trxmtBetween,
MonthsSincePastUseStart,
CASE WHEN additionalStartDate='Yes' AND EligibilityReview IN ('Under Review (Outcome TBD)') THEN 'Under Review (Outcome TBD)'
     WHEN ISNULL(RegistryEnrollmentStatus, '')='' THEN 'NULL'
     ELSE RegistryEnrollmentStatus
	 END AS RegistryEnrollmentStatus,
RegistryEnrollmentStatusOrder,
EligibilityReview
FROM #FinalElig FE
) FINAL
WHERE ROWNUM=1

--SELECT * FROM [Reporting].[PSO500].[t_op_EER] WHERE SubjectID IN (49980039112) ORDER BY SubjectID


/*****TABLE FOR PSO DASHBOARD*****/

TRUNCATE TABLE [Reporting].[PSO500].[t_EligDashboard_EER];

INSERT INTO [Reporting].[PSO500].[t_EligDashboard_EER]
(
	[Site ID],
	[Subject ID],
	[Eligible Treatment],
	[Enrollment Date]
)



 SELECT DISTINCT [SiteID] AS [Site ID]  
	   ,[SubjectID] AS [Subject ID]
	   ,[TreatmentName] AS [Eligible Treatment]
	   ,[EnrollDate] AS [Enrollment Date]
FROM [Reporting].[PSO500].[t_op_EER]
WHERE (RegistryEnrollmentStatus LIKE 'Eligible%')
AND [SiteID] not in (998, 999)

TRUNCATE TABLE [Reporting].[PSO500].[t_EligDashboard];

INSERT INTO [Reporting].[PSO500].[t_EligDashboard]
(
	[Site ID],
	[Subject ID],
	[Eligible Treatment],
	[Enrollment Date]
)

 SELECT DISTINCT [SiteID] AS [Site ID]  
	   ,[SubjectID] AS [Subject ID]
	   ,[TreatmentName] AS [Eligible Treatment]
	   ,[EnrollDate] AS [Enrollment Date]
FROM [Reporting].[PSO500].[t_op_EER]
WHERE (RegistryEnrollmentStatus LIKE 'Eligible%')
AND [SiteID] not in (998, 999)


/*****TABLE FOR PSO VISITLOG FOR DASHBOARD*****/


 
TRUNCATE TABLE [Reporting].[PSO500].[t_VisitLog];

INSERT INTO [Reporting].[PSO500].[t_VisitLog] 
(
	   [SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[Month]
      ,[Year]
      ,[VisitType]
  )

SELECT DISTINCT [SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[Month]
      ,[Year]
      ,[VisitType]

FROM [Reporting].[PSO500].[v_op_VisitLog]
WHERE ISNULL(VisitDate, '') <> ''
AND VisitType IN ('Enrollment', 'Follow-up', 'Exit')
AND SiteID not in (997, 998, 999)
;



END
GO
