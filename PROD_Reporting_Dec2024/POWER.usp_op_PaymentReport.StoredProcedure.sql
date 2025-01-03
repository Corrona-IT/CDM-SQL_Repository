USE [Reporting]
GO
/****** Object:  StoredProcedure [POWER].[usp_op_PaymentReport]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 3/5/2021
-- Description:	Procedure to create POWER Payment Report
-- ==================================================================================

CREATE PROCEDURE [POWER].[usp_op_PaymentReport] AS


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 
CREATE TABLE [Reporting].[POWER].[t_op_POWERPaymentReport]
(
       [Site ID] [int] NULL
      ,[Subject ID] [bigint] NULL
      ,[Patient ID] [bigint] NOT NULL
      ,[Gender] [varchar] (30) NULL
      ,[YOB] [int] NULL
      ,[Registry Visit Type] [varchar] (15) NULL
      ,[Registry Visit Date] [date] NULL
      ,[Power Enrollment Date] [date] NULL
      ,[Medication Start Date] [date] NULL
      ,[Medication] [varchar] (100) NULL
      ,[Patient Status] [varchar] (100) NULL
      ,[Medication Listed at Visit] [varchar] (10) NULL
      ,[Medication Listed as Started] [varchar] (40) NULL
      ,[Gender and YOB Confirmed] [varchar] (40) NULL
      ,[Previously Paid] [varchar] (30) NULL
      ,[Amount Paid] [bigint] NULL
      ,[Paid in Quarter] [varchar] (30) NULL
      ,[Payment Comments] [varchar] (500) NULL
	  ,[Paid] [varchar] (20) NULL
);
*/



/*****Get Year of Birth and Gender (Demographics) from RA 100 Subject List *****/


IF OBJECT_ID('tempdb.dbo.#DEM') IS NOT NULL BEGIN DROP TABLE #DEM END;

SELECT DISTINCT SiteID,
       SiteStatus,
	   SubjectID,
	   YOB,
	   Gender
INTO #DEM
FROM [RA100].[t_op_SubjectVisits] 



/*****Get Drug Listing from RA100 EDC*****/
--[Reporting].[RA100].[t_op_AllMedsENRandFU] **Doesn't have changes today so use union below

IF OBJECT_ID('tempdb.dbo.#Drugs') IS NOT NULL BEGIN DROP TABLE #Drugs END;

SELECT SiteID,
       SubjectID,
	   VisitType,
	   VisitDate,
	   TreatmentName,
	   StartDate,
	   ChangesToday
INTO #Drugs
FROM
(
SELECT DISTINCT D.SiteID,
       D.SubjectID,
	   'Enrollment' AS VisitType,
	   D.VisitDate,
	   CASE WHEN UPPER(D.TreatmentName) LIKE '%XELJANZ%' THEN 'XELJANZ'
	   WHEN UPPER(D.TreatmentName) LIKE '%OLUMIANT%' THEN 'OLUMIANT'
	   WHEN UPPER(D.TreatmentName) LIKE '%RINVOQ%' THEN 'RINVOQ'
	   ELSE 'No match'
	   END AS TreatmentName,
	   D.CalcStartDate AS StartDate,
	   D.ChangesToday
FROM [RA100].[t_op_Enrollment_Drugs] D
WHERE ISNULL(MostRecentDoseNotCurrentDose, '')='' AND ISNULL(MostRecentPastUseDate, '')=''

UNION

SELECT DISTINCT D.SiteID,
       D.SubjectID,
	   'Follow-Up' AS VisitType,
	   D.VisitDate,
	   CASE WHEN UPPER(D.TreatmentName) LIKE '%XELJANZ%' THEN 'XELJANZ'
	   WHEN UPPER(D.TreatmentName) LIKE '%OLUMIANT%' THEN 'OLUMIANT'
	   WHEN UPPER(D.TreatmentName) LIKE '%RINVOQ%' THEN 'RINVOQ'
	   ELSE 'No match'
	   END AS TreatmentName,
	   D.CalcStartDate AS StartDate,
	   D.ChangesToday
FROM [RA100].[t_op_FollowUp_Drugs] D
WHERE ISNULL(MostRecentDoseNotCurrentDose, '')='' AND ISNULL(MostRecentPastUseDate, '')=''
) A

--SELECT * FROM #Drugs WHERE SubjectID=1040768 ORDER BY SiteID, SubjectID, VisitDate


/*****Get POWER Enrollment Information from POWER view*****/

IF OBJECT_ID('tempdb.dbo.#PE') IS NOT NULL BEGIN DROP TABLE #PE END;

SELECT EPS.SiteID
      ,EPS.SubjectID
	  ,EPS.PatientID
	  ,EPS.Gender
	  ,EPS.BirthYear
	  ,EPS.RegistryVisitType
	  ,EPS.RegistryVisitDate
	  ,EPS.POWEREnrollmentDate
	  ,EPS.DaysFromVisit
	  ,EPS.MedicationStartDate
	  ,EPS.Medication
	  ,EPS.PatientStatus
	  ,DEM.Gender AS RegistryGender
	  ,DEM.YOB AS RegistryBirthYear
INTO #PE
FROM [Reporting].[POWER].[v_op_EnrollmentAndPatientStatus_payments] EPS
LEFT JOIN #DEM DEM ON DEM.SubjectID=EPS.SubjectID

--SELECT * FROM #PE ORDER BY SiteID, SubjectID, POWEREnrollmentDate

/*****EDC Data Check against POWER Data*****/

IF OBJECT_ID('tempdb.dbo.#Check') IS NOT NULL BEGIN DROP TABLE #Check END;

SELECT DISTINCT PE.SiteID AS [Site ID]
      ,PE.SubjectID AS [Subject ID]
	  ,PE.PatientID AS [Patient ID]
	  ,PE.Gender AS [Gender]
	  ,PE.BirthYear AS [YOB]
	  ,PE.RegistryVisitType AS [Registry Visit Type]
	  ,PE.RegistryVisitDate AS [Registry Visit Date]
	  ,PE.POWEREnrollmentDate AS [POWER Enrollment Date]
	  ,PE.MedicationStartDate AS [Medication Start Date]
	  ,PE.Medication AS [Medication]
	  ,PE.PatientStatus AS [Patient Status]
	  ,CASE WHEN ISNULL(D.TreatmentName, '')<>'' THEN 'Yes'
	   WHEN RegistryVisitType='No match in EDC' then 'na'
	   WHEN RegistryVisitType IN ('Enrollment', 'Follow-Up') AND ISNULL(D.TreatmentName, '')='' THEN 'No'
	   ELSE ''
	   END AS [Medication Listed at Visit]
	  ,CASE WHEN RegistryVisitType='No match in EDC' THEN ''
	   WHEN RegistryVisitType IN ('Enrollment', 'Follow-Up') AND ISNULL(D.TreatmentName, '')='' THEN ''
	   WHEN ChangesToday='Start drug' THEN 'Start indicated'
	   WHEN ISNULL(StartDate, '')<>'' THEN CAST(FORMAT(StartDate, 'MMM-yyyy') AS varchar)
	   WHEN ISNULL(D.TreatmentName,'')<>'' AND ChangesToday<>'Start drug' AND ISNULL(StartDate, '')='' THEN 'Current'
	   ELSE ''
	   END AS [Medication Listed as Started]
	  ,CASE WHEN RegistryVisitType='No match in EDC' THEN ''
	   WHEN Gender=RegistryGender AND BirthYear=RegistryBirthYear THEN 'Yes'
	   WHEN Gender=RegistryGender AND ISNULL(RegistryBirthYear, '')='' THEN 'Gender only'
	   WHEN ISNULL(RegistryGender, '')='' AND BirthYear=RegistryBirthYear THEN 'YOB only'
	   WHEN (ISNULL(RegistryGender, '')<>'' AND Gender<>RegistryGender) AND (ISNULL(RegistryBirthYear, '')<>'' AND BirthYear<>RegistryBirthYear) THEN 'No'
	   WHEN (ISNULL(RegistryGender, '')<>'' AND Gender<>RegistryGender) AND BirthYear=RegistryBirthYear THEN 'Gender mismatch' 
	   WHEN (ISNULL(RegistryBirthYear, '')<>'' AND BirthYear<>RegistryBirthYear) AND Gender=RegistryGender THEN 'YOB mismatch'
	   WHEN RegistryGender='' AND ISNULL(RegistryBirthYear, '')='' THEN 'Incomplete entry in EDC'
	   WHEN ISNULL(RegistryGender, '')=''AND ISNULL(RegistryBirthYear, '')='' THEN 'Enrollment visit not present'
	   ELSE ''
	   END AS [Gender and YOB Confirmed]
INTO #Check
FROM #PE PE
LEFT JOIN #Drugs D on D.SubjectID=PE.SubjectID AND D.VisitDate=PE.RegistryVisitDate
     AND (PE.Medication = D.TreatmentName)

--SELECT * FROM #Check ORDER BY [Site ID], [Subject ID]

TRUNCATE TABLE [Reporting].[POWER].[t_op_POWERPaymentReport]; 

INSERT INTO [Reporting].[POWER].[t_op_POWERPaymentReport]
(
       [Site ID]
      ,[Subject ID]
      ,[Patient ID]
      ,[Gender]
      ,[YOB]
      ,[Registry Visit Type]
      ,[Registry Visit Date]
      ,[Power Enrollment Date]
      ,[Medication Start Date]
      ,[Medication] 
      ,[Patient Status]
      ,[Medication Listed at Visit]
      ,[Medication Listed as Started]
      ,[Gender and YOB Confirmed]
      ,[Amount Paid]
      ,[Previously Paid]
      ,[Paid in Quarter]
      ,[Payment Comments]
	  ,[Paid]
)

SELECT DISTINCT C.[Site ID]
      ,C.[Subject ID]
      ,C.[Patient ID]
      ,C.[Gender]
      ,C.[YOB]
      ,C.[Registry Visit Type]
      ,C.[Registry Visit Date]
      ,C.[Power Enrollment Date]
      ,C.[Medication Start Date]
      ,C.[Medication] 
      ,C.[Patient Status]
      ,C.[Medication Listed at Visit]
      ,C.[Medication Listed as Started]
      ,C.[Gender and YOB Confirmed]
	  --,PH.[PREVIOUSLY PAID]
	  ,PH.[Amount Paid]
	  ,CASE WHEN ISNULL(PH.[Previously Paid], '')<>'' THEN PH.[Previously Paid]
	   WHEN (ISNULL(PH.[Amount Paid], '')<>'' AND ISNULL(PH.[Paid in Quarter], '')<>'' AND ISNULL(PH.[Previously Paid], '')='') 
	   AND (CAST(DATEPART(YEAR, DATEADD(MM, -1, GETDATE())) AS nvarchar) + 'Q' + CAST(DATEPART(QUARTER, DATEADD(MM, -1, GETDATE())) AS nvarchar)) > PH.[Paid in Quarter] THEN 'Previously Paid'
	   ELSE ''
	   END AS [Previously Paid] 
	  ,PH.[Paid in Quarter]
	  ,PH.[Payment Comments]
	  ,CASE WHEN [Paid in Quarter] IS NULL AND [Payment Comments] IS NULL THEN 'Not Paid'
	   WHEN [Paid in Quarter] IS NOT NULL OR [Payment Comments] IS NOT NULL THEN 'Paid'
	   ELSE ''
	   END AS Paid

FROM #Check C
LEFT JOIN [Reporting].[POWER].[t_op_PaymentHistory] PH ON PH.[Subject ID]=C.[Subject ID]


--SELECT * FROM [Reporting].[POWER].[t_op_POWERPaymentReport] WHERE [Paid in Quarter] IS NOT NULL OR [Payment Comments] IS NOT NULL

END

GO
