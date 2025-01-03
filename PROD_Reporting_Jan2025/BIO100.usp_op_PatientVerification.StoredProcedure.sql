USE [Reporting]
GO
/****** Object:  StoredProcedure [BIO100].[usp_op_PatientVerification]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















-- ==========================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 10/6/2021
-- Description:	BIO-100 Patient Verification verifies eligibility criteria for the Bio Repository team
-- ==========================================================================================================



CREATE PROCEDURE [BIO100].[usp_op_PatientVerification] AS



BEGIN

  SET NOCOUNT ON;


/*
CREATE TABLE [BIO100].[t_op_PatientVerification](
	[VisitId] [bigint] NOT NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[PatientId] [bigint] NOT NULL,
	[SiteStatus] [nvarchar](100) NULL,
	[Gender] [nvarchar](30) NULL,
	[ProviderID] [int] NULL,
	[YOB] [int] NULL,
	[VisitType] [nvarchar](30) NOT NULL,
	[LastVisitDate] [date] NULL,
	[StartDate] [nvarchar](50) NULL,
	[StartDateCheck] [nvarchar] (10) NULL,
	[TreatmentName] [nvarchar](100) NULL,
	[TreatmentNameCheck] [nvarchar](100) NULL,
	[ChangesToday] [nvarchar](100) NULL,
	[CurrentPastEligible] [nvarchar](1000) NULL,
	[CurrentPastOther] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
*/


/**Get last visit and demographics for all active patients, RowNum 1 will be last visit**/

IF OBJECT_ID('tempdb.dbo.#LastVisit') IS NOT NULL BEGIN DROP TABLE #LastVisit END;

SELECT DISTINCT VisitID,
       SiteID,
       SubjectID,
	   PatientId,
	   SiteStatus,
	   VisitType,
	   VisitDate,
	   YOB,
	   Gender,
	   VisitProviderID AS ProviderID,
	   ROW_NUMBER() OVER(PARTITION BY PatientId ORDER BY SiteID, SubjectID, VisitDate DESC) AS RowNum
INTO #LastVisit
FROM [RA100].[t_op_SubjectVisits] SV 
WHERE UPPER(VisitType) IN ('ENROLLMENT', 'FOLLOW-UP', 'EXIT')
AND SiteStatus='Active'

--SELECT * FROM #LastVisit where SubjectID=220012002 ORDER BY SiteID, SubjectID, RowNum



/**Get treatments started at all visits**/

IF OBJECT_ID('tempdb.dbo.#Treatment') IS NOT NULL BEGIN DROP TABLE #Treatment END;

SELECT VisitID,
       SiteID,
	   SubjectID,
	   PatientId,
	   VisitType,
	   VisitDate,
	   TreatmentName,
	   EligibleMedication,
	   StartDate,
	   CalcStartDate,
	   ChangesToday,
	   CurrentDose,
	   MostRecentDoseNotCurrentDose,
	   MostRecentPastUseDate
INTO #Treatment
FROM
(
SELECT VisitID,
       SiteID,
       SubjectID,
	   PatientId,
	   VisitType, 
	   VisitDate,
	   TreatmentName, 
	   CASE WHEN ISNULL(TreatmentName, '') IN ('tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)', 'baricitinib (Olumiant)', 'upadacitinib (Rinvoq)', 'tocilizumab (Actemra)', 'sarilumab (Kevzara)', 'adalimumab (Humira)', 'Amjevita (adalimumab-atto)', 'certolizumab (Cimzia)', 'etanercept (Enbrel)', 'Erelzi (etanercept-szzs)', 'golimumab (Simponi)', 'golimumab (Simponi Aria)', 'infliximab (Remicade)', 'Inflectra (infliximab-dyyb)', 'Renflexis (infliximab-abda)', 'infliximab biosimilar (other)', 'anakinra (Kineret)', 'rituximab (Rituxan)', 'abatacept (Orencia)', 'adalimumab biosimilar (other): Adalimimab', 'infliximab biosimilar (other): Renflexis') THEN 1
	   WHEN ISNULL(TreatmentName, '') LIKE '%infliximab biosimilar (other)%' THEN 1
	   ELSE 2
	   END AS EligibleMedication,
	   FirstUseDate,
	   SUBSTRING(DATENAME(month, CalcStartDate), 1, 3) + '-' + CAST(DATEPART(year, CalcStartDate) AS varchar) AS StartDate,
	   CalcStartDate,
	   ChangesToday,
	   CurrentDose,
	   MostRecentDoseNotCurrentDose,
	   MostRecentPastUseDate
FROM [Reporting].[RA100].[t_op_Enrollment_Drugs]

UNION

SELECT VisitID,
       SiteID,
       SubjectID,
	   PatientId,
	   VisitType, 
	   VisitDate,
	   TreatmentName, 
	   CASE WHEN ISNULL(TreatmentName, '') IN ('tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)', 'baricitinib (Olumiant)', 'upadacitinib (Rinvoq)', 'tocilizumab (Actemra)', 'sarilumab (Kevzara)', 'adalimumab (Humira)', 'Amjevita (adalimumab-atto)', 'certolizumab (Cimzia)', 'etanercept (Enbrel)', 'Erelzi (etanercept-szzs)', 'golimumab (Simponi)', 'golimumab (Simponi Aria)', 'infliximab (Remicade)', 'Inflectra (infliximab-dyyb)', 'Renflexis (infliximab-abda)', 'anakinra (Kineret)', 'rituximab (Rituxan)', 'abatacept (Orencia)', 'infliximab biosimilar (other): Renflexis', 'adalimumab biosimilar (other): Adalimimab') THEN 1
	   WHEN ISNULL(TreatmentName, '') LIKE '%infliximab biosimilar (other)%' THEN 1
	   ELSE 2
	   END AS EligibleMedication,
	   FirstUseDate,
	   SUBSTRING(DATENAME(month, CalcStartDate), 1, 3) + '-' + CAST(DATEPART(year, CalcStartDate) AS varchar) AS StartDate,
	   CalcStartDate,
	   ChangesToday,
	   CurrentDose,
	   MostRecentDoseNotCurrentDose,
	   MostRecentPastUseDate
FROM [Reporting].[RA100].[t_op_FollowUp_Drugs]
) A

--SELECT * FROM #Treatment WHERE SubjectID=178130057 ORDER BY SiteID, SubjectID, VisitDate DESC, TreatmentName


/**Get treatment started at last visit (RowNum=1)**/

IF OBJECT_ID('tempdb.dbo.#Medications') IS NOT NULL BEGIN DROP TABLE #Medications END;

SELECT ROW_NUMBER() OVER(PARTITION BY PatientId ORDER BY SiteID, SubjectID, VisitDate, EligibleMedication, DRUGORDER) AS RowNum
      ,VisitID
	  ,SiteID
	  ,SubjectID
	  ,PatientId
	  ,SiteStatus
	  ,VisitType
	  ,VisitDate
	  ,YOB
	  ,Gender
	  ,ProviderID
	  ,CASE WHEN TreatmentName IS NULL THEN ''
	   ELSE StartDate
	   END AS StartDate
	  ,StartDate AS StartDateCheck
	  ,CalcStartDate
	  ,TreatmentName
	  ,TreatmentNameCheck
	  ,EligibleMedication
	  ,DRUGORDER
	  ,ChangesToday
INTO #Medications
FROM 
(
SELECT DISTINCT LV.VisitID,
       LV.SiteID,
       LV.SubjectID,
	   LV.PatientId,
	   LV.SiteStatus,
	   LV.VisitType,
	   LV.VisitDate,
	   LV.YOB,
	   LV.Gender,
	   LV.ProviderID,
	   T.StartDate,
	   T.CalcStartDate,
	   CASE WHEN T.EligibleMedication = 1 AND T.ChangesToday IN ('Start drug') THEN T.TreatmentName
	   WHEN T.EligibleMedication = 1 AND T.CalcStartDate=LV.VisitDate THEN T.TreatmentName
	   ELSE NULL
	   END AS TreatmentName,
	   TreatmentName AS TreatmentNameCheck,
	   EligibleMedication,
	   CASE WHEN T.ChangesToday IN ('Start drug') THEN 10
	   WHEN T.CalcStartDate=LV.VisitDate THEN 20
	   WHEN T.ChangesToday IN ('Change dose') THEN 30
	   WHEN ISNULL(T.CurrentDose, '')<>'' AND ChangesToday<>'Start drug' THEN 33
	   WHEN T.ChangesToday<>'Start drug' AND ISNULL(T.StartDate, '')='' THEN 35
	   WHEN T.ChangesToday IN ('Stop drug') OR ISNULL(T.MostRecentPastUseDate, '')<>'' THEN 40
	   ELSE 99
	   END AS DRUGORDER,
	   CASE WHEN ISNULL(StartDate, '')='' AND ISNULL(ChangesToday, '') IN ('Change dose', '') THEN 'Current'
	   WHEN ISNULL(T.MostRecentPastUseDate, '')<>'' THEN 'Stop drug'
	   ELSE T.ChangesToday
	   END AS ChangesToday

FROM #LastVisit LV
LEFT JOIN #Treatment T ON T.PatientId=LV.PatientId AND T.VisitId=LV.VisitID
WHERE LV.RowNum=1
) A


--SELECT * FROM #Medications WHERE SubjectID in (178130057) ORDER BY SiteID, SubjectID, VisitDate DESC


/**Get current or past eligible treatments or 'other' treatments**/

IF OBJECT_ID('tempdb.dbo.#PastUse') IS NOT NULL BEGIN DROP TABLE #PastUse END;

SELECT DISTINCT SiteID,
       SubjectID,
	   PatientId,
	   PageDescription,
	   TreatmentName
INTO #PastUse
FROM
(
SELECT VisitID,
       SiteID,
       SubjectID,
	   PatientId,
	   VisitType, 
	   VisitDate,
	   PageDescription,
	   TreatmentName, 
	   FirstUseDate,
	   ChangesToday,
	   MostRecentDoseNotCurrentDose,
	   MostRecentPastUseDate
FROM [Reporting].[RA100].[t_op_Enrollment_Drugs] ED
WHERE (ISNULL(TreatmentName, '') IN ('tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)', 'baricitinib (Olumiant)', 'upadacitinib (Rinvoq)', 'tocilizumab (Actemra)', 'sarilumab (Kevzara)', 'adalimumab (Humira)', 'Amjevita (adalimumab-atto)', 'certolizumab (Cimzia)', 'etanercept (Enbrel)', 'Erelzi (etanercept-szzs)', 'golimumab (Simponi)', 'golimumab (Simponi Aria)', 'infliximab (Remicade)', 'Inflectra (infliximab-dyyb)', 'Renflexis (infliximab-abda)', 'anakinra (Kineret)', 'rituximab (Rituxan)','infliximab biosimilar (other): Renflexis',  'abatacept (Orencia)', 'adalimumab biosimilar (other): Adalimimab') OR UPPER(TreatmentName) LIKE '%OTHER:%')
AND ((CalcStartDate < VisitDate) OR (ISNULL(ChangesToday, '') IN ('Stop drug', 'Change dose')) OR (ISNULL(MostRecentPastUseDate, '')<>'') OR (ISNULL(MostRecentDoseNotCurrentDose, '')<>'') OR (VisitDate < (SELECT VisitDate FROM #Medications M WHERE M.SiteID=ED.SiteID and M.SubjectID=ED.SubjectID AND M.VisitID<>ED.VisitID AND M.RowNum=1)) OR (ISNULL(ChangesToday, '')<>'Start drug' AND ISNULL(CurrentDose, '')<>''))
AND SubjectID NOT IN (SELECT SubjectID FROM [RA100].[v_op_Exits])


UNION

SELECT VisitID,
       SiteID,
       SubjectID,
	   PatientId,
	   VisitType, 
	   VisitDate,
	   PageDescription,
	   TreatmentName, 
	   FirstUseDate,
	   ChangesToday,
	   MostRecentDoseNotCurrentDose,
	   MostRecentPastUseDate
FROM [Reporting].[RA100].[t_op_FollowUp_Drugs] FD
WHERE (ISNULL(TreatmentName, '') IN ('tofacitinib (Xeljanz)', 'tofacitinib (Xeljanz XR)', 'baricitinib (Olumiant)', 'upadacitinib (Rinvoq)', 'tocilizumab (Actemra)', 'sarilumab (Kevzara)', 'adalimumab (Humira)', 'Amjevita (adalimumab-atto)', 'certolizumab (Cimzia)', 'etanercept (Enbrel)', 'Erelzi (etanercept-szzs)', 'golimumab (Simponi)', 'golimumab (Simponi Aria)', 'infliximab (Remicade)', 'Inflectra (infliximab-dyyb)', 'Renflexis (infliximab-abda)', 'anakinra (Kineret)', 'rituximab (Rituxan)','infliximab biosimilar (other): Renflexis',  'abatacept (Orencia)', 'adalimumab biosimilar (other): Adalimimab') OR UPPER(TreatmentName) LIKE '%OTHER:%')
AND ((CalcStartDate < VisitDate) OR (ISNULL(ChangesToday, '') IN ('Stop drug', 'Change dose')) OR (ISNULL(MostRecentPastUseDate, '')<>'') OR (ISNULL(MostRecentDoseNotCurrentDose, '')<>'') OR (VisitDate < (SELECT VisitDate FROM #Medications M WHERE M.SiteID=FD.SiteID and M.SubjectID=FD.SubjectID AND M.VisitID<>FD.VisitID AND M.RowNum=1)) OR (ISNULL(ChangesToday, '')<>'Start drug' AND ISNULL(CurrentDose, '')<>''))
AND SubjectID NOT IN (SELECT SubjectID FROM [RA100].[v_op_Exits])
) A



TRUNCATE TABLE [Reporting].[BIO100].[t_op_PatientVerification]

INSERT INTO [Reporting].[BIO100].[t_op_PatientVerification]
(
VisitID,
SiteID,
SubjectID,
PatientId,
SiteStatus,
VisitType,
LastVisitDate,
YOB,
Gender,
ProviderID,
StartDate,
StartDateCheck,
TreatmentName,
TreatmentNameCheck,
ChangesToday,
CurrentPastEligible,
CurrentPastOther
)

SELECT DISTINCT VisitID,
       SiteID,
	   SubjectID,
	   PatientId,
	   SiteStatus,
	   VisitType,
	   VisitDate AS LastVisitDate,
	   YOB,
	   Gender,178130057
	   ProviderID,
	   CASE WHEN M.TreatmentName IN (SELECT TreatmentName FROM #PastUse PU WHERE PU.SiteID=M.SiteID AND PU.SubjectID=M.SubjectID) AND ISNULL(ChangesToday, '')<>'Start drug' THEN NULL
	   WHEN ISNULL(TreatmentName, '')<>'' AND ISNULL(StartDate, '')='' THEN ChangesToday
	   WHEN ISNULL(TreatmentName, '')<>'' AND ISNULL(StartDate, '')<>'' THEN StartDate
	   ELSE StartDate
	   END AS StartDate,
	   StartDateCheck,
	   --TreatmentName,
	   CASE WHEN M.TreatmentName IN (SELECT TreatmentName FROM #PastUse PU WHERE PU.SiteID=M.SiteID AND PU.SubjectID=M.SubjectID) AND ISNULL(ChangesToday, '')<>'Start drug' THEN NULL
	   ELSE M.TreatmentName
	   END AS TreatmentName,
	   TreatmentNameCheck,
	   ChangesToday,

	  STUFF((
        SELECT DISTINCT ', '+ TreatmentName
        FROM #PastUse PU
		WHERE M.SubjectID=PU.SubjectID
		AND PageDescription LIKE '(Page 4)%'
		AND UPPER(TreatmentName) NOT LIKE '%OTHER:%'
        FOR XML PATH('')
        )
        ,1,1,'') AS CurrentPastEligible,

		STUFF((
        SELECT DISTINCT ', ' + TreatmentName
        FROM #PastUse PU
		WHERE M.SubjectID=PU.SubjectID
		AND PageDescription LIKE '(Page 4)%'
		AND UPPER(TreatmentName) LIKE '%OTHER:%'
        FOR XML PATH('')
        )
        ,1,1,'') AS CurrentPastOther

FROM #Medications M
WHERE ChangesToday='Start drug' OR (ISNULL(ChangesToday, '')<>'Start drug' AND RowNum=1)

--SELECT * FROM [Reporting].[BIO100].[t_op_PatientVerification] ORDER BY SiteID, SubjectID


END

GO
