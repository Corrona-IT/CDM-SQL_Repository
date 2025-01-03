USE [Reporting]
GO
/****** Object:  StoredProcedure [POWER].[usp_op_UAT_CaseMgmtCompliance]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 8/23/2018
-- Description:	Procedure to create table for Other Drugs at Enrollment and Follow-up
-- ==================================================================================

CREATE PROCEDURE [POWER].[usp_op_UAT_CaseMgmtCompliance] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [Reporting].[POWER].[t_op_UAT_CaseMgmtCompliance]
(
PatientID [bigint] NOT NULL,
StudyStartDate [date] NULL,
MedicationStartDate [date] NULL,
Medication [nvarchar] (500) NULL,
PatientStatus [nvarchar] (50) NULL,
StudyStateID [int] NULL,
AssessmentWeek [int] NULL,
LastAdmitDate [date] NULL,
NumberOfAssessments [bigint] NULL,
StudyOrMedStartDate [date] NULL,
AssessmentWeekStart [date] NULL,
PreviousAssessmentComplete  [nvarchar] (10) NULL,
CurrentAssessmentComplete [nvarchar] (10) NULL,
ReportRunWeekday [nvarchar] (25) NULL,
Compliant [nvarchar](10) NULL

);

*/

IF OBJECT_ID('tempdb.dbo.#EnrollDate') IS NOT NULL BEGIN DROP TABLE #EnrollDate END;

SELECT SP.patient_id AS PatientID
      ,SP.study_start_date AS StudyStartDate
	  ,SP.drug_start_date AS MedicationStartDate
	  ,SP.study_drug_name AS Medication
	  ,CASE WHEN SP.study_state_id=1 THEN 'First time'
	   WHEN SP.study_state_id=2 THEN 'Predose'
	   WHEN SP.study_state_id=3 THEN 'Postdose'
	   WHEN SP.study_state_id=4 THEN 'Non-eligible'
	   WHEN SP.study_state_id=5 THEN 'Complete'
	   ELSE ''
	   END AS PatientStatus
	  ,SP.study_state_id AS StudyStateID

INTO #EnrollDate
FROM [APowerUAT].[dbo].[study_participation] SP

--SELECT * FROM #EnrollDate ORDER BY PatientID


/*****All Encounters*****/

IF OBJECT_ID('tempdb.dbo.#AllEncounters') IS NOT NULL BEGIN DROP TABLE #AllEncounters END;

SELECT DISTINCT ED.PatientID
      ,StudyStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,StudyStateID
	  ,PatientStatus
      ,[admit_date] AS AdmitDate

INTO #AllEncounters 
FROM #EnrollDate ED 
LEFT JOIN [APowerUAT].[dbo].[encounter] E ON ED.PatientID=E.patient_id

--SELECT * FROM #AllEncounters ORDER BY PatientID, AdmitDate


/******Last Admit Date and Number of Assessments by PatientID***********/

IF OBJECT_ID('tempdb.dbo.#LastEncounter') IS NOT NULL BEGIN DROP TABLE #LastEncounter END;

SELECT DISTINCT ED.PatientID
      ,StudyStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,StudyStateID
	  ,PatientStatus
      ,MAX([admit_date]) AS LastAdmitDate
	  ,COUNT([admit_date]) AS NbrAssess

INTO #LastEncounter
FROM #EnrollDate ED 
LEFT JOIN [APower].[dbo].[encounter] E ON ED.PatientID=E.patient_id
GROUP BY PatientID, StudyStartDate, MedicationStartDate, Medication, StudyStateID, PatientStatus

--SELECT * FROM #LastEncounter ORDER BY PatientID


/*********Visit Registration Information*************/

IF OBJECT_ID('tempdb.dbo.#VisitRegistration') IS NOT NULL BEGIN DROP TABLE #VisitRegistration END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY C.PatientID ORDER BY C.PatientID, C.StudyStartDate, C.MedicationStartDate, AE.AdmitDate DESC) AS ROWNUM
	  ,C.PatientID
	  ,C.StudyStartDate
	  ,C.MedicationStartDate
	  ,C.Medication
	  ,C.PatientStatus
	  ,C.StudyStateID
	  ,AE.AdmitDate
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN C.StudyStartDate
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN C.MedicationStartDate
	   ELSE CAST(NULL AS date) 
	   END AS StudyOrMedStartDate
 
      ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 7, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 7, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek1
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 14, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 14, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek2
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 21, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 21, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek3
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 28, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 28, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek4
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 35, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 35, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek5
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 42, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 42, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek6
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 49, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 49, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek7
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 56, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 56, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek8
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 63, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 63, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek9
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 70, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 70, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek10
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 77, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 77, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek11
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 84, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 84, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek12
	   ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN DATEADD(DD, 91, C.StudyStartDate)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN DATEADD(DD, 91, C.MedicationStartDate)
	   ELSE NULL
	   END AS AssessmentWeek13

	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN FLOOR(DATEDIFF(DD, C.StudyStartDate, GETDATE())/7)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN FLOOR(DATEDIFF(DD, C.MedicationStartDate, GETDATE())/7)
	   ELSE CAST(NULL AS int)
	   END AS CurrentAssessmentWeek

	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN FLOOR(DATEDIFF(DD, C.StudyStartDate, DATEADD(DD, -7, GETDATE()))/7)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN FLOOR(DATEDIFF(DD, C.MedicationStartDate, DATEADD(DD, -7, GETDATE()))/7)
	   ELSE CAST(NULL AS int)
	   END AS LastAssessmentWeek


INTO #VisitRegistration	  
FROM #EnrollDate C
JOIN #AllEncounters AE ON AE.PatientID=C.PatientID

--SELECT * FROM #VisitRegistration ORDER BY PatientID, ROWNUM



IF OBJECT_ID('tempdb.dbo.#LastVisitRegistration') IS NOT NULL BEGIN DROP TABLE #LastVisitRegistration END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY C.PatientID ORDER BY C.PatientID, C.StudyStartDate, C.MedicationStartDate) AS ROWNUM
	  ,AE.PatientID
	  ,C.StudyStartDate
	  ,C.MedicationStartDate
	  ,C.Medication
	  ,C.PatientStatus
	  ,C.StudyStateID
	  ,NbrAssess
	  ,CASE WHEN AE.LastAdmitDate=C.StudyOrMedStartDate THEN CAST(NULL AS date)
	   ELSE LastAdmitDate
	   END AS LastAdmitDate
	  ,StudyOrMedStartDate
	  ,CurrentAssessmentWeek
	  ,LastAssessmentWeek

INTO #LastVisitRegistration	  
FROM #LastEncounter AE 
LEFT JOIN #VisitRegistration C ON AE.PatientID=C.PatientID and C.AdmitDate=AE.LastAdmitDate
WHERE CurrentAssessmentWeek<13


--SELECT * FROM #LastVisitRegistration ORDER BY PatientID


IF OBJECT_ID('tempdb.dbo.#CurrentAssessment') IS NOT NULL BEGIN DROP TABLE #CurrentAssessment END;

SELECT ROWNUM
      ,PatientID
	  ,StudyStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus
	  ,StudyStateID
	  ,StudyOrMedStartDate
	  ,LastAdmitDate
	  ,NbrAssess
	  ,CurrentAssessmentWeek
	  ,LastAssessmentWeek

	  ,CASE WHEN DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate) <  DATEADD(DD, 7, StudyOrMedStartDate) THEN CAST(NULL AS date)
	   ELSE DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate)
	   END AS CurrentAssessmentWeekStartDate

	  ,CASE WHEN DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate) <  DATEADD(DD, 6, StudyOrMedStartDate) THEN 'n/a'
	   WHEN LastAdmitDate >= (DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate)) AND CurrentAssessmentWeek>0 THEN 'Yes'
	   WHEN LastAdmitDate < DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate) AND CurrentAssessmentWeek>0 THEN 'No'
	   WHEN ISNULL(LastAdmitDate, '')='' AND CurrentAssessmentWeek>0 THEN 'No'
	   ELSE ''
	   END AS CurrentAssessmentComplete

INTO #CurrentAssessment
FROM #LastVisitRegistration LVR
WHERE StudyStateID IN (1, 2, 3)

--SELECT * FROM #CurrentAssessment ORDER BY PatientID


IF OBJECT_ID('tempdb.dbo.#LastAssessment') IS NOT NULL BEGIN DROP TABLE #LastAssessment END;

SELECT DISTINCT ROWNUM
      ,PatientID
	  ,StudyStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus
	  ,StudyStateID
	  ,StudyOrMedStartDate
	  ,CASE WHEN AdmitDate=StudyOrMedStartDate THEN CAST(NULL AS date)
	   ELSE AdmitDate
	   END AS PreviousAdmitDate
	  ,LastAssessmentWeek AS PreviousAssessmentWeek

	  ,CASE WHEN LastAssessmentWeek=0 THEN CAST(NULL AS date)
	   ELSE DATEADD(DD, 7*LastAssessmentWeek, StudyOrMedStartDate) 
	   END AS PreviousAssessmentWeekStartDate

	  ,CASE WHEN LastAssessmentWeek=0 THEN 'n/a'
	   WHEN AdmitDate >= (DATEADD(DD, 7*LastAssessmentWeek, StudyOrMedStartDate)) THEN 'Yes'
	   WHEN AdmitDate < DATEADD(DD, 7*LastAssessmentWeek, StudyOrMedStartDate) THEN 'No'
	   ELSE ''
	   END AS PreviousAssessmentComplete

INTO #LastAssessment
FROM #VisitRegistration LVR
WHERE StudyStateID IN (1, 2, 3)

--SELECT * FROM #LastAssessment ORDER BY PatientID

IF OBJECT_ID('tempdb.dbo.#CurrentAndLastAssessments') IS NOT NULL BEGIN DROP TABLE #CurrentAndLastAssessments END;

SELECT CA.ROWNUM
      ,CA.PatientID
	  ,CA.StudyStartDate
	  ,CA.MedicationStartDate
	  ,CA.Medication
	  ,CA.PatientStatus
	  ,CA.StudyStateID
	  ,CA.StudyOrMedStartDate
	  ,CA.LastAdmitDate
	  ,CA.NbrAssess
	  ,CA.CurrentAssessmentWeek
	  ,CA.CurrentAssessmentWeekStartDate
	  ,CA.CurrentAssessmentComplete
	  ,CASE WHEN CurrentAssessmentWeek IN (0, 1) THEN CAST(NULL AS date)
	   ELSE LA.PreviousAdmitDate
	   END AS PreviousAdmitDate

	  ,CASE WHEN CurrentAssessmentWeek=0 THEN CAST(NULL AS int)
	   WHEN CurrentAssessmentWeek=1 THEN 0
	   ELSE LA.PreviousAssessmentWeek
	   END AS PreviousAssessmentWeek

	  ,CASE WHEN CurrentAssessmentWeek IN (0, 1) THEN CAST(NULL AS date)
	   ELSE LA.PreviousAssessmentWeekStartDate
	   END AS PreviousAssessmentWeekStartDate

	  ,CASE WHEN CurrentAssessmentWeek IN (0, 1) THEN 'n/a'
	   ELSE LA.PreviousAssessmentComplete
	   END AS PreviousAssessmentComplete

INTO #CurrentAndLastAssessments
FROM #CurrentAssessment CA
LEFT JOIN #LastAssessment LA ON LA.PatientID=CA.PatientID

--SELECT * FROM #CurrentAndLastAssessments

/****************************************************************************************************/

IF OBJECT_ID('tempdb.dbo.#CompletedVisits') IS NOT NULL BEGIN DROP TABLE #CompletedVisits END;

SELECT DISTINCT
	   PatientID
	  ,StudyStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,AdmitDate
	  ,StudyOrMedStartDate
	  ,StudyStateID
	  ,PatientStatus

	  ,CASE  WHEN AdmitDate < AssessmentWeek1 OR ISNULL(AdmitDate, '')='' THEN 0
	   WHEN AdmitDate >= AssessmentWeek1 AND AdmitDate < AssessmentWeek2 THEN 1
	   WHEN AdmitDate >= AssessmentWeek2 AND AdmitDate < AssessmentWeek3 THEN 2
	   WHEN AdmitDate >= AssessmentWeek3 AND AdmitDate < AssessmentWeek4 THEN 3
	   WHEN AdmitDate >= AssessmentWeek4 AND AdmitDate < AssessmentWeek5 THEN 4
	   WHEN AdmitDate >= AssessmentWeek5 AND AdmitDate < AssessmentWeek6 THEN 5
	   WHEN AdmitDate >= AssessmentWeek6 AND AdmitDate < AssessmentWeek7 THEN 6
	   WHEN AdmitDate >= AssessmentWeek7 AND AdmitDate < AssessmentWeek8 THEN 7
	   WHEN AdmitDate >= AssessmentWeek8 AND AdmitDate < AssessmentWeek9 THEN 8
	   WHEN AdmitDate >= AssessmentWeek9 AND AdmitDate < AssessmentWeek10 THEN 9
	   WHEN AdmitDate >= AssessmentWeek10 AND AdmitDate < AssessmentWeek11 THEN 10
	   WHEN AdmitDate >= AssessmentWeek11 AND AdmitDate < AssessmentWeek12 THEN 11
	   WHEN AdmitDate >= AssessmentWeek12 AND AdmitDate < AssessmentWeek13 THEN 12
	   ELSE ''
	   END AS AssessmentWeek

    ,CASE WHEN AdmitDate < VR.AssessmentWeek1 OR ISNULL(AdmitDate, '')='' THEN 'n/a'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek1 AND VR.AssessmentWeek2 THEN 'Yes'
     WHEN AdmitDate BETWEEN VR.AssessmentWeek2 AND VR.AssessmentWeek3 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek3 AND VR.AssessmentWeek4 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek4 AND VR.AssessmentWeek5 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek5 AND VR.AssessmentWeek6 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek6 AND VR.AssessmentWeek7 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek7 AND VR.AssessmentWeek8 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek8 AND VR.AssessmentWeek9 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek9 AND VR.AssessmentWeek10 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek10 AND VR.AssessmentWeek11 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek11 AND VR.AssessmentWeek12 THEN 'Yes'
	 WHEN AdmitDate BETWEEN VR.AssessmentWeek12 AND VR.AssessmentWeek13 THEN 'Yes'
	 ELSE ''
	  END AS AssessmentComplete

INTO #CompletedVisits
FROM #VisitRegistration VR


--SELECT * FROM #CompletedVisits ORDER BY PatientID, StudyStartDate, AdmitDate


/******Assessment Calculations for next step below*******/

IF OBJECT_ID('tempdb.dbo.#DateCalcsLastEncounter') IS NOT NULL BEGIN DROP TABLE #DateCalcsLastEncounter END;

SELECT DISTINCT CA.PatientID
	  ,CA.StudyStartDate
	  ,CA.MedicationStartDate
	  ,CA.StudyOrMedStartDate
	  ,CA.Medication
	  ,CA.PatientStatus
	  ,CA.StudyStateID
	  ,CA.CurrentAssessmentWeek AS AssessmentWeek
	  ,LE.LastAdmitDate
	  ,LE.NbrAssess AS NumberOfAssessments
	  ,CA.CurrentAssessmentComplete
	  ,CLA.PreviousAssessmentComplete
	  ,CA.CurrentAssessmentWeekStartDate AS AssessmentWeekStart

	  ,DATENAME(WEEKDAY, GETDATE()) AS ReportRunWeekday

	  ,CASE WHEN CA.CurrentAssessmentWeek=1 THEN 'n/a'
	   WHEN CA.CurrentAssessmentWeek>1 AND CLA.PreviousAssessmentComplete='Yes' AND CLA.NbrAssess=PreviousAssessmentWeek THEN 'Yes'
	   WHEN CA.CurrentAssessmentWeek>1 AND CLA.PreviousAssessmentComplete='No' AND CLA.NbrAssess=0 THEN 'No'
	   WHEN CA.CurrentAssessmentWeek>1 AND CLA.PreviousAssessmentComplete='No' AND CA.NbrAssess <= CA.CurrentAssessmentWeek-4 THEN 'No'
	   WHEN CA.CurrentAssessmentWeek>1 AND CLA.PreviousAssessmentComplete='No' AND CA.NbrAssess>0 AND (CA.NbrAssess >= (CA.CurrentAssessmentWeek-3)) THEN 'Partial'
	   ELSE ''
	   END AS Compliant

INTO #DateCalcsLastEncounter
FROM #CurrentAssessment CA
LEFT JOIN #LastEncounter LE ON CA.PatientID=LE.PatientID
LEFT JOIN #CurrentAndLastAssessments CLA ON CLA.PatientID=CA.PatientID
AND CA.StudyStateID IN (1, 2, 3)

--SELECT * FROM #DateCalcsLastEncounter ORDER BY PatientID

TRUNCATE TABLE [Reporting].[POWER].[t_op_UAT_CaseMgmtCompliance];

INSERT INTO [Reporting].[POWER].[t_op_UAT_CaseMgmtCompliance]
(
PatientID,
StudyStartDate,
MedicationStartDate,
Medication,
PatientStatus,
StudyStateID,
AssessmentWeek,
LastAdmitDate,
NumberOfAssessments,
StudyOrMedStartDate,
AssessmentWeekStart,
PreviousAssessmentComplete,
CurrentAssessmentComplete,
ReportRunWeekday,
Compliant
)

SELECT DISTINCT PatientID
      ,StudyStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus
	  ,StudyStateID
	  ,AssessmentWeek
	  ,LastAdmitDate
	  ,NumberOfAssessments
	  ,StudyOrMedStartDate
	  ,AssessmentWeekStart
	  ,PreviousAssessmentComplete
	  ,CurrentAssessmentComplete
	  ,DATENAME(WEEKDAY, GETDATE()) AS ReportRunWeekday
	  ,Compliant

FROM #DateCalcsLastEncounter


--SELECT * FROM [Reporting].[POWER].[t_op_UAT_CaseMgmtCompliance] ORDER BY PatientID, LastAdmitDate


END



GO
