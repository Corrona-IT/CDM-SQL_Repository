USE [Reporting]
GO
/****** Object:  StoredProcedure [POWER].[usp_op_CaseMgmtCompliance]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





















-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 8/23/2018
-- Description:	Procedure to create table for Other Drugs at Enrollment and Follow-up
-- ==================================================================================

CREATE PROCEDURE [POWER].[usp_op_CaseMgmtCompliance] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 
CREATE TABLE [Reporting].[POWER].[t_op_CaseMgmtCompliance]
(
PatientID [bigint] NOT NULL,
StudyStartDate [date] NULL,
MedicationStartDate [date] NULL,
Medication [nvarchar] (500) NULL,
PatientStatus [nvarchar] (50) NULL,
StudyStateID [int] NULL,
AssessmentWeek [int] NULL,
Day3Date [date] NULL,
LastAdmitDate [date] NULL,
NumberOfAssessments [bigint] NULL,
StudyOrMedStartDate [date] NULL,
AssessmentWeekStart [date] NULL,
PreviousAssessmentComplete  [nvarchar] (10) NULL,
CurrentAssessmentComplete [nvarchar] (10) NULL,
ReportRunWeekday [nvarchar] (25) NULL,
Compliant [nvarchar](50) NULL
);
*/




/*****Get SubjectID to filter out test subjects entered by Sites (999)*****/

IF OBJECT_ID('tempdb.dbo.#SubjectID') IS NOT NULL BEGIN DROP TABLE #SubjectID END;

SELECT DISTINCT session_id
	  ,meta_value AS SubjectID
	  ,entry_date
	  ,meta_key
INTO #SubjectID
FROM [APower].[dbo].[eligibility]
WHERE meta_key='corronaIDNumber'

--SELECT * FROM #SubjectID

IF OBJECT_ID('tempdb.dbo.#SiteNbr') IS NOT NULL BEGIN DROP TABLE #SiteNbr END;

SELECT DISTINCT session_id
      ,meta_value AS SiteID
	  ,entry_date
	  ,meta_key
INTO #SiteNbr
FROM [APower].[dbo].[eligibility]
WHERE meta_key='corronaSiteID'

--SELECT * FROM #SiteNbr


IF OBJECT_ID('tempdb.dbo.#SiteSubject') IS NOT NULL BEGIN DROP TABLE #SiteSubject END;

SELECT DISTINCT A.SiteID
      ,B.SubjectID
	  ,A.session_id AS SiteSession
	  ,B.session_id AS SubjectSession
INTO #SiteSubject
FROM #SiteNbr A
JOIN #SubjectID B ON B.session_id=A.session_id
--WHERE SiteID<>999
--AND SUBSTRING(CAST(SubjectID AS varchar), 1, 3)<>'999'

--SELECT * FROM #SiteSubject


/*****Get Registration/Enrollment Information*****/

IF OBJECT_ID('tempdb.dbo.#EnrollDate') IS NOT NULL BEGIN DROP TABLE #EnrollDate END;

SELECT DISTINCT SS.SiteID
      ,SP.subject_id AS SubjectID
      ,SP.patient_id AS PatientID
      ,SP.study_start_date AS StudyStartDate
	  ,DATEADD(DD, 1, SP.study_start_date) AS PreDoseStartDate 
	  ,SP.drug_start_date AS MedicationStartDate
	  ,SP.study_drug_name AS Medication
	  ,CASE WHEN ISNULL(INELIG.RegistryStatus, '')<>'' AND INELIG.RegistryStatus='Not participating' THEN 'Never started'
	   WHEN ISNULL(INELIG.RegistryStatus, '') NOT IN ('', 'Not participating') THEN INELIG.RegistryStatus
	   WHEN DATEDIFF(dd, SP.study_start_date, GETDATE()) >= 85 AND SP.study_state_id=1 THEN 'Never started'
	   WHEN DATEDIFF(dd, SP.drug_start_date, GETDATE()) >= 85 AND SP.study_state_id<>1 THEN 'Finished'
	   WHEN SP.subject_id IN (100206734, 101010990) THEN 'Medication stopped'
	   WHEN SP.study_state_id=1 THEN 'First time'
	   WHEN SP.study_state_id=2 THEN 'Predose'
	   WHEN SP.study_state_id=3 THEN 'Postdose'
	   WHEN SP.study_state_id=4 THEN 'Medication stopped'
	   WHEN SP.study_state_id=5 THEN 'Finished'
	   WHEN SP.drug_start_date >= SP.study_start_date AND DATEDIFF(DD,SP.drug_start_date, GETDATE())>=85 THEN 'Finished'
	   WHEN ISNULL(SP.drug_start_date, '')='' AND DATEDIFF(DD, SP.study_start_date, GETDATE())>=85 THEN 'Finished'
	   ELSE ''
	   END AS PatientStatus
	  ,SP.study_state_id AS StudyStateID

INTO #EnrollDate
FROM [APower].[dbo].[study_participation] SP
LEFT JOIN [Reporting].[POWER].[t_op_IneligibleSubjects] INELIG ON INELIG.PatientID=SP.patient_id
LEFT JOIN #SiteSubject SS ON SS.SubjectID=SP.subject_id 
WHERE SS.SiteID<>999
AND SUBSTRING(CAST(SP.subject_id AS varchar), 1, 3)<>'999'

--SELECT * FROM #EnrollDate WHERE PatientID=52153 ORDER BY PatientID desc



/*****Get custom question responses and dates*****/

IF OBJECT_ID('tempdb.dbo.#CustomQuestions') IS NOT NULL BEGIN DROP TABLE #CustomQuestions END;

SELECT DISTINCT CQPR.[patient_id]
	  ,CAST(CQPR.[entry_date] AS date) AS entry_date
      ,CQPR.[form_id]
      ,CQPR.[question_id]
	  ,CQL.[content] AS Question
      ,CQPR.[patient_response_id]
      ,CQPR.[response_id]
	  ,CRL.[content] AS Response

  INTO #CustomQuestions

  FROM [APower].[dbo].[custom_question_patient_response] CQPR
  LEFT JOIN [APower].[dbo].[custom_question_lookup] CQL ON CQL.question_id=CQPR.question_id 
  LEFT JOIN [APower].[dbo].[custom_response_lookup] CRL ON CRL.response_id=cqpr.response_id
  WHERE CQPR.question_id IN (27, 33) --AND CQPR.response_id=1
  
--SELECT * FROM #CustomQuestions ORDER BY patient_id, entry_date, question_id


/*****Get Information on All Encounters*****/

IF OBJECT_ID('tempdb.dbo.#AllEncounters') IS NOT NULL BEGIN DROP TABLE #AllEncounters END;

SELECT DISTINCT PatientID
      ,StudyStartDate
	  ,PreDoseStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,StudyStateID
	  ,PatientStatus
      ,AdmitDate

INTO #AllEncounters

FROM
(
SELECT DISTINCT ED.PatientID
      ,StudyStartDate
	  ,PreDoseStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,StudyStateID
	  ,PatientStatus
      ,CASE WHEN PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS date)
	   ELSE [admit_date]
	   END AS AdmitDate


FROM #EnrollDate ED 
LEFT JOIN [APower].[dbo].[encounter] E ON ED.PatientID=E.patient_id AND ((E.admit_date=ED.StudyStartDate AND E.coh=0) OR (E.admit_date<>ED.StudyStartDate AND E.coh=66))

UNION

SELECT DISTINCT ED.PatientID
      ,StudyStartDate
	  ,PreDoseStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,StudyStateID
	  ,PatientStatus
      ,CASE WHEN PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS date)
	   ELSE [entry_date] 
	   END AS AdmitDate

FROM #EnrollDate ED 
JOIN #CustomQuestions CQ ON ED.PatientID=CQ.patient_id AND CQ.entry_date<>ED.StudyStartDate AND ISNULL(CQ.[entry_date], '')<>''
) AE

--SELECT * FROM #AllEncounters ORDER BY PatientID DESC


/******Last Admit Date and Number of Assessments by PatientID***********/

IF OBJECT_ID('tempdb.dbo.#LastEncounter') IS NOT NULL BEGIN DROP TABLE #LastEncounter END;

SELECT DISTINCT PatientID
      ,StudyStartDate
	  ,PreDoseStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,StudyStateID
	  ,PatientStatus
      ,CASE WHEN PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS date)
	   ELSE MAX(AdmitDate) 
	   END AS LastAdmitDate
	  ,CASE WHEN PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS int)
	   ELSE COUNT(AdmitDate)-1 
	   END AS NbrAssess

INTO #LastEncounter
FROM #AllEncounters 
GROUP BY PatientID, StudyStartDate, PreDoseStartDate, MedicationStartDate, Medication, StudyStateID, PatientStatus

--SELECT * FROM #LastEncounter ORDER BY PatientID DESC


/*********Visit Registration Information*************/

IF OBJECT_ID('tempdb.dbo.#VisitRegistration') IS NOT NULL BEGIN DROP TABLE #VisitRegistration END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY C.PatientID ORDER BY C.PatientID, C.StudyStartDate, C.MedicationStartDate, LE.LastAdmitDate DESC) AS ROWNUM
	  ,C.PatientID
	  ,C.StudyStartDate
	  ,C.PreDoseStartDate 
	  ,C.MedicationStartDate
	  ,C.Medication
	  ,C.PatientStatus
	  ,C.StudyStateID
	  ,LE.LastAdmitDate AS AdmitDate
	  ,CASE WHEN ISNULL(C.MedicationStartDate, '')='' THEN C.StudyStartDate
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' THEN C.MedicationStartDate
	   ELSE CAST(NULL AS date) 
	   END AS StudyOrMedStartDate

	  ,CASE WHEN C.PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Complete', 'Finished', 'Medication stopped') THEN 99
	   WHEN C.StudyStateID IN (1, 2, 3) AND FLOOR(DATEDIFF(DD, COALESCE(C.MedicationStartDate, C.StudyStartDate), GETDATE())/7)>12 THEN 99
	   WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN FLOOR(DATEDIFF(DD, C.PreDoseStartDate, GETDATE())/7)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN FLOOR(DATEDIFF(DD, C.MedicationStartDate, GETDATE())/7)
	   ELSE CAST(NULL AS int)
	   END AS CurrentAssessmentWeek

	  ,CASE WHEN C.PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS int)
	   WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) AND FLOOR(DATEDIFF(DD, C.PreDoseStartDate, GETDATE())/7)=0 THEN CAST(NULL AS int)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 AND FLOOR(DATEDIFF(DD, C.MedicationStartDate, GETDATE())/7)=0 THEN CAST(NULL AS int)
	   WHEN C.StudyStateID IN (1, 2, 3) AND FLOOR(DATEDIFF(DD, COALESCE(C.MedicationStartDate, C.StudyStartDate), GETDATE())/7)>12 THEN CAST(NULL AS int)
	   WHEN ISNULL(C.MedicationStartDate, '')='' AND C.StudyStateID IN (1, 2) THEN FLOOR(DATEDIFF(DD, C.PreDoseStartDate, DATEADD(DD, -7, GETDATE()))/7)
	   WHEN ISNULL(C.MedicationStartDate, '')<>'' AND C.StudyStateID=3 THEN FLOOR(DATEDIFF(DD, C.MedicationStartDate, DATEADD(DD, -7, GETDATE()))/7)
	   ELSE CAST(NULL AS int)
	   END AS LastAssessmentWeek
	   
INTO #VisitRegistration	  
FROM #EnrollDate C
JOIN #LastEncounter LE ON LE.PatientID=C.PatientID

--SELECT * FROM #VisitRegistration WHERE PatientID=52153 ORDER BY PatientID DESC


IF OBJECT_ID('tempdb.dbo.#LastVisitRegistration') IS NOT NULL BEGIN DROP TABLE #LastVisitRegistration END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY C.PatientID ORDER BY C.PatientID, C.StudyStartDate, C.MedicationStartDate) AS ROWNUM
	  ,LE.PatientID
	  ,C.StudyStartDate
	  ,C.PreDoseStartDate
	  ,C.MedicationStartDate
	  ,C.Medication
	  ,C.PatientStatus
	  ,C.StudyStateID
	  ,NbrAssess
	  ,CASE WHEN LE.LastAdmitDate=C.StudyOrMedStartDate THEN CAST(NULL AS date)
	   WHEN C.PatientStatus IN ('Ineligible', 'Never started', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS date)
	   ELSE LastAdmitDate
	   END AS LastAdmitDate
	  ,StudyOrMedStartDate
	  ,CurrentAssessmentWeek
	  ,LastAssessmentWeek

INTO #LastVisitRegistration	  
FROM #LastEncounter LE 
LEFT JOIN #VisitRegistration C ON LE.PatientID=C.PatientID --AND C.AdmitDate=LE.LastAdmitDate

--SELECT * FROM #LastVisitRegistration ORDER BY PatientID DESC


IF OBJECT_ID('tempdb.dbo.#CurrentAssessment') IS NOT NULL BEGIN DROP TABLE #CurrentAssessment END;

SELECT DISTINCT ROWNUM
      ,PatientID
	  ,StudyStartDate
	  ,PreDoseStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus
	  ,StudyStateID
	  ,StudyOrMedStartDate
	  ,LastAdmitDate
	  ,NbrAssess
	  ,CurrentAssessmentWeek
	  ,LastAssessmentWeek

	  ,CASE --WHEN CurrentAssessmentWeek=0 THEN StudyOrMedStartDate
	   WHEN PatientStatus IN ('Complete', 'Non-eligible', 'Medication stopped', 'Ineligible', 'Finished', 'Never started', 'Not participating') THEN CAST(NULL AS date)
	   WHEN StudyStateID IN (1, 2) THEN DATEADD(DD, 7*CurrentAssessmentWeek, PreDoseStartDate)
	   ELSE DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate)
	   END AS CurrentAssessmentWeekStartDate

	 ,DATEADD(DD, 7*CurrentAssessmentWeek, PreDoseStartDate) AS Interesting

	  ,CASE WHEN PatientStatus IN ('Complete', 'Non-eligible', 'Medication stopped', 'Ineligible', 'Finished', 'Never started', 'Not participating') THEN 'n/a'
	   WHEN StudyStateID IN (1, 2) AND LastAdmitDate >= DATEADD(DD, 7*CurrentAssessmentWeek, PreDoseStartDate) THEN 'Yes'
	   WHEN StudyStateID IN (1, 2) AND LastAdmitDate < DATEADD(DD, 7*CurrentAssessmentWeek, PreDoseStartDate) THEN 'No'
	   WHEN StudyStateID=3 AND LastAdmitDate >= DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate) THEN 'Yes'
	   WHEN LastAdmitDate < DATEADD(DD, 7*CurrentAssessmentWeek, StudyOrMedStartDate) AND CurrentAssessmentWeek>0 THEN 'No'
	   WHEN ISNULL(LastAdmitDate, '')='' THEN 'No'
	   ELSE ''
	   END AS CurrentAssessmentComplete

INTO #CurrentAssessment
FROM #LastVisitRegistration LVR
--WHERE StudyStateID IN (1, 2, 3)  ----STUDY STATE OF Non-eligible (Medication Stopped) AND Complete are not included

--SELECT * FROM #CurrentAssessment WHERE PatientID= 52153 ORDER BY PatientID DESC


IF OBJECT_ID('tempdb.dbo.#LastAssessment') IS NOT NULL BEGIN DROP TABLE #LastAssessment END;

SELECT DISTINCT ROWNUM
      ,PatientID
	  ,StudyStartDate
	  ,PreDoseStartDate
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus
	  ,StudyStateID
	  ,StudyOrMedStartDate
	  ,CASE WHEN AdmitDate=StudyOrMedStartDate THEN CAST(NULL AS date)
	   ELSE AdmitDate
	   END AS PreviousAdmitDate
	  ,LastAssessmentWeek AS PreviousAssessmentWeek

	  ,CASE WHEN CurrentAssessmentWeek=0 THEN CAST(NULL AS date)
	   WHEN PatientStatus IN ('Complete', 'Non-eligible', 'Medication stopped', 'Ineligible', 'Finished', 'Never started', 'Not participating') THEN CAST(NULL AS date)
	   WHEN StudyStateID IN (1, 2) THEN DATEADD(DD, 7*LastAssessmentWeek, DATEADD(DD, 1, StudyStartDate))
	   ELSE DATEADD(DD, 7*LastAssessmentWeek, StudyOrMedStartDate)
	   END AS PreviousAssessmentWeekStartDate 

	  ,CASE WHEN PatientStatus IN ('Complete', 'Non-eligible', 'Medication stopped', 'Ineligible', 'Finished', 'Never started', 'Not participating') THEN 'n/a'
	   WHEN StudyStateID IN (1, 2) AND AdmitDate >= (DATEADD(DD, 7*LastAssessmentWeek, DATEADD(DD, 1, StudyStartDate))) THEN 'Yes'
	   WHEN StudyStateID IN (1, 2) AND AdmitDate < (DATEADD(DD, 7*LastAssessmentWeek, DATEADD(DD, 1, StudyStartDate))) THEN 'No'
	   WHEN StudyStateID=3 AND AdmitDate >= (DATEADD(DD, 7*LastAssessmentWeek, StudyOrMedStartDate)) THEN 'Yes'
	   WHEN StudyStateID=3 AND AdmitDate < DATEADD(DD, 7*LastAssessmentWeek, StudyOrMedStartDate) THEN 'No'
	   END AS PreviousAssessmentComplete

INTO #LastAssessment
FROM #VisitRegistration LVR
--WHERE StudyStateID IN (2, 3)  ----STUDY STATE OF Non-eligible (Medication Stopped) AND Complete are not included

--SELECT * FROM #LastAssessment WHERE PatientID=52153 ORDER BY PatientID  DESC

IF OBJECT_ID('tempdb.dbo.#CurrentAndLastAssessments') IS NOT NULL BEGIN DROP TABLE #CurrentAndLastAssessments END;

SELECT DISTINCT CA.ROWNUM
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
	  ,CASE WHEN CurrentAssessmentWeek=0 AND CA.PatientStatus IN ('First time', 'Predose') THEN CAST(NULL AS date)
	   ELSE LA.PreviousAdmitDate
	   END AS PreviousAdmitDate

	  ,CASE WHEN CurrentAssessmentWeek=0 AND CA.PatientStatus='Predose' THEN CAST(NULL AS int)
	   WHEN CurrentAssessmentWeek=1 AND CA.PatientStatus='Predose' THEN 0
	   ELSE LA.PreviousAssessmentWeek
	   END AS PreviousAssessmentWeek

	  ,CASE WHEN CurrentAssessmentWeek=0 THEN CAST(NULL AS date)
	   ELSE LA.PreviousAssessmentWeekStartDate
	   END AS PreviousAssessmentWeekStartDate

	  ,CASE WHEN CurrentAssessmentWeek=0 THEN 'n/a'
	   ELSE LA.PreviousAssessmentComplete
	   END AS PreviousAssessmentComplete

INTO #CurrentAndLastAssessments
FROM #CurrentAssessment CA
LEFT JOIN #LastAssessment LA ON LA.PatientID=CA.PatientID

--SELECT * FROM #CurrentAndLastAssessments WHERE PatientID=45248 ORDER BY PatientID  DESC


/******Assessment Calculations for next step below*******/

IF OBJECT_ID('tempdb.dbo.#DateCalcsLastEncounter') IS NOT NULL BEGIN DROP TABLE #DateCalcsLastEncounter END;

SELECT DISTINCT CA.PatientID
	  ,CA.StudyStartDate
	  ,CA.MedicationStartDate
	  ,CA.StudyOrMedStartDate
	  ,CA.Medication
	  ,CA.PatientStatus
	  ,CA.StudyStateID
	  ,CA.LastAssessmentWeek AS PreviousAssessmentWeek
	  ,CA.CurrentAssessmentWeek AS AssessmentWeek
	  ,LE.LastAdmitDate
	  ,CASE WHEN CA.CurrentAssessmentWeek=99 AND CA.PatientStatus IN ('Complete', 'Finished') THEN LE.NbrAssess
	   WHEN CA.CurrentAssessmentWeek=99 AND CA.PatientStatus IN ('Ineligible', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS int)
	   ELSE LE.NbrAssess 
	   END AS NumberOfAssessments
	  ,CA.CurrentAssessmentComplete
	  ,CLA.PreviousAssessmentComplete
	  ,CA.CurrentAssessmentWeekStartDate AS AssessmentWeekStart

	  ,DATENAME(WEEKDAY, GETDATE()) AS ReportRunWeekday

	  ,CASE WHEN CA.CurrentAssessmentWeek=0 AND CA.PatientStatus IN ('Predose', 'First time') AND CLA.NbrAssess>=1 THEN 'Yes'
	   WHEN CA.CurrentAssessmentWeek=0 AND CA.PatientStatus IN ('Predose', 'First time') AND CLA.NbrAssess=0 THEN 'n/a'
	   WHEN CA.CurrentAssessmentWeek=0 AND CA.StudyStartDate=CA.MedicationStartDate AND CLA.NbrAssess=0 THEN 'n/a'
	   WHEN CA.CurrentAssessmentWeek=0 AND CA.StudyStartDate<>CA.MedicationStartDate AND CLA.NbrAssess >= DATEDIFF(WW, CA.StudyStartDate, CA.MedicationStartDate) THEN 'Yes'
	   WHEN CA.PatientStatus IN ('Complete', 'Finished') AND CA.NbrAssess >=12 THEN 'Yes'
	   WHEN CA.PatientStatus IN ('Complete', 'Finished') AND CA.NbrAssess >=8 THEN 'Partial'
	   WHEN CA.PatientStatus IN ('Complete', 'Finished') AND CA.NbrAssess < 8 THEN 'No'
	   WHEN CA.PatientStatus IN ('Ineligible', 'Not participating', 'Never started', 'Medication stopped') THEN 'n/a'
	   WHEN CA.CurrentAssessmentWeek>0 AND CLA.PreviousAssessmentComplete='Yes' AND CLA.NbrAssess>=PreviousAssessmentWeek THEN 'Yes'
	   WHEN CA.CurrentAssessmentWeek>0 AND CLA.PreviousAssessmentComplete='Yes' AND CLA.NbrAssess<PreviousAssessmentWeek THEN 'Partial'
	   WHEN CA.CurrentAssessmentWeek>0 AND CLA.PreviousAssessmentComplete='No' AND CLA.NbrAssess=0 THEN 'No'
	   WHEN CA.CurrentAssessmentWeek>0 AND CLA.PreviousAssessmentComplete='No' AND CA.NbrAssess <= PreviousAssessmentWeek-3 THEN 'No'
	   WHEN CA.CurrentAssessmentWeek>0 AND CLA.PreviousAssessmentComplete='No' AND CA.NbrAssess>0 AND (CA.NbrAssess >= (CA.CurrentAssessmentWeek-3)) THEN 'Partial'
	   ELSE ''
	   END AS Compliant

INTO #DateCalcsLastEncounter
FROM #CurrentAssessment CA
LEFT JOIN #LastEncounter LE ON CA.PatientID=LE.PatientID
LEFT JOIN #CurrentAndLastAssessments CLA ON CLA.PatientID=CA.PatientID


--SELECT * FROM #DateCalcsLastEncounter ORDER BY PatientID  DESC

TRUNCATE TABLE [Reporting].[POWER].[t_op_CaseMgmtCompliance];

INSERT INTO [Reporting].[POWER].[t_op_CaseMgmtCompliance]
(
PatientID,
StudyStartDate,
MedicationStartDate,
Medication,
PatientStatus,
StudyStateID,
AssessmentWeek,
Day3Date,
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
	  ,CASE WHEN PatientStatus IN ('Complete', 'Ineligible', 'Not participating', 'Never started', 'Medication stopped') THEN CAST(NULL AS date)
	   WHEN ISNULL(AssessmentWeekStart, '')='' THEN CAST(NULL AS date)
	   ELSE DATEADD(DD, 2, AssessmentWeekStart) 
	   END AS Day3Date
	  ,LastAdmitDate
	  ,NumberOfAssessments
	  ,StudyOrMedStartDate
	  ,AssessmentWeekStart
	  ,PreviousAssessmentComplete
	  ,CurrentAssessmentComplete
	  ,DATENAME(WEEKDAY, GETDATE()) AS ReportRunWeekday
	  ,Compliant

FROM #DateCalcsLastEncounter
WHERE SUBSTRING(CAST(PatientID AS varchar), 1, 3)<>999

--SELECT * FROM #DateCalcsLastEncounter ORDER BY PatientID DESC


/*
SELECT * FROM [Reporting].[POWER].[t_op_CaseMgmtCompliance] WHERE PatientID=52153 ORDER BY PatientID DESC 
*/


END


GO
