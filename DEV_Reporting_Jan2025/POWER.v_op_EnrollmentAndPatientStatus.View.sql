USE [Reporting]
GO
/****** Object:  View [POWER].[v_op_EnrollmentAndPatientStatus]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [POWER].[v_op_EnrollmentAndPatientStatus] AS


WITH Subjects AS
(
SELECT session_id
	  ,meta_value AS SubjectID
	  ,entry_date
	  ,meta_key

FROM [APower].[dbo].[eligibility]
WHERE meta_key='corronaIDNumber'
)


,Sites AS
(
SELECT session_id
      ,meta_value AS SiteID
	  ,entry_date
	  ,meta_key

FROM [APower].[dbo].[eligibility]
WHERE meta_key='corronaSiteID'
)



,SiteSubject AS
(
SELECT DISTINCT A.SiteID
      ,B.SubjectID
	  ,A.session_id AS SiteSession
	  ,B.session_id AS SubjectSession

FROM Sites A
JOIN Subjects B ON B.session_id=A.session_id
WHERE SiteID<>999
AND SUBSTRING(CAST(SubjectID AS varchar), 1, 3)<>'999'

--ORDER BY SiteID, SubjectID, SubjectSession, SubjectEntryDate
)

/*****Subject 100206734 is hard-coded to stopped medication per email from DBB on 10/13/2021*****/

,EnrollDate AS
(
SELECT DISTINCT SS.SiteID
      ,SP.subject_id AS SubjectID
	  ,SP.patient_id AS PatientID
	  ,P.year_of_birth AS BirthYear
	  ,CASE WHEN P.sex='M' THEN 'Male'
	   WHEN P.sex='F' THEN 'Female'
	   ELSE P.sex
	   END AS Gender
      ,SP.study_start_date AS RegistrationDate
	  ,SP.drug_start_date AS MedicationStartDate
	  ,SP.study_drug_name AS Medication
	  ,CASE WHEN SP.study_state_id=1 THEN 'First time'
	   WHEN SP.subject_id IN (100206734, 101010990) THEN 'Medication stopped'
	   WHEN SP.study_state_id=2 THEN 'Predose'
	   WHEN SP.study_state_id=3 THEN 'Postdose'
	   WHEN SP.study_state_id=4 THEN 'Medication stopped'
	   WHEN SP.study_state_id=5 THEN 'Complete'
	   ELSE ''
	   END AS PatientStatus

FROM [APower].[dbo].[study_participation] SP
LEFT JOIN SiteSubject SS ON SS.SubjectID=sp.subject_id
LEFT JOIN [APower].[dbo].[patient] P ON p.patient_id=SP.patient_id
WHERE SiteID<>999
AND SUBSTRING(CAST(SP.subject_id AS varchar), 1, 3)<>'999'
--ORDER BY SiteID, subject_id
)
--select * from [APower].[dbo].[patient] P

,NoVisitMatch AS
(
SELECT CASE WHEN ISNULL(C.SiteID, '')='' THEN 'Null value'
       ELSE C.SiteID
	   END AS SiteID
      ,C.SubjectID
	  ,C.PatientID
	  ,C.BirthYear
	  ,C.Gender
	  ,C.RegistrationDate AS POWEREnrollmentDate
	  ,C.MedicationStartDate
	  ,C.Medication
	  ,CASE WHEN C.PatientStatus='First time' THEN CMC.PatientStatus
	   ELSE C.PatientStatus
	   END AS PatientStatus
FROM EnrollDate C
LEFT JOIN [Reporting].[POWER].[t_op_CaseMgmtCompliance] CMC ON CMC.PatientID=c.PatientID
WHERE SubjectID NOT IN (SELECT DISTINCT SubjectID FROM [Reporting].[RA100].[v_op_VisitLog])
AND SiteID<>999
AND SUBSTRING(CAST(C.SubjectID AS varchar), 1, 3)<>'999'
)

,VisitRegistrationMatch AS
(
SELECT CASE WHEN ISNULL(C.SiteID, '')='' THEN 'Null value'
       ELSE C.SiteID
	   END AS SiteID
      ,C.SubjectID
	  ,C.PatientID
	  ,C.BirthYear
	  ,C.Gender
	  ,C.RegistrationDate AS POWEREnrollmentDate
	  ,VL.VisitType
	  ,VL.VisitDate
	  ,CASE WHEN ISNULL(VL.VisitDate, '')='' THEN CAST(NULL AS int)
	   ELSE DATEDIFF(DD, VL.VisitDate, C.RegistrationDate) 
	   END AS Compare
	  ,CASE WHEN ISNULL(VL.VisitDate, '')='' THEN CAST(NULL AS int)
	   ELSE ABS(DATEDIFF(DD, VL.VisitDate, C.RegistrationDate))
	   END AS DaysFromVisit
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus
	  
FROM EnrollDate C
LEFT JOIN [Reporting].[RA100].[v_op_VisitLog] VL ON VL.SubjectID=C.SubjectID
WHERE VisitType<>'Exit'
AND C.SiteID<>999
AND SUBSTRING(CAST(C.SubjectID AS varchar), 1, 3)<>'999'

)



,CLOSESTVISIT AS
(
SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, DaysFromVisit) AS ROWNUM
      ,SiteID
      ,SubjectID
	  ,VRM.PatientID
	  ,BirthYear
	  ,Gender
	  ,POWEREnrollmentDate
	  ,VisitType AS RegistryVisitType
	  ,VisitDate AS RegistryVisitDate
	  ,DaysFromVisit
	  ,VRM.MedicationStartDate
	  ,VRM.Medication
	  ,CASE WHEN VRM.PatientStatus='First time' THEN CMC.PatientStatus
	   ELSE VRM.PatientStatus
	   END AS PatientStatus
FROM VisitRegistrationMatch VRM
LEFT JOIN [Reporting].[POWER].[t_op_CaseMgmtCompliance] CMC ON CMC.PatientID=VRM.PatientID

)


SELECT SiteID
      ,SubjectID
	  ,PatientID
	  ,BirthYear
	  ,Gender
	  ,POWEREnrollmentDate
	  ,RegistryVisitType
	  ,RegistryVisitDate
	  ,DaysFromVisit
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus

FROM CLOSESTVISIT
WHERE ROWNUM=1
AND SiteID<>999
AND SUBSTRING(CAST(SubjectID AS varchar), 1, 3)<>'999'
AND PatientID NOT IN (SELECT PatientID FROM [Reporting].[POWER].[t_op_IneligibleSubjects])

UNION

SELECT DISTINCT SiteID
      ,SubjectID
	  ,PatientID
	  ,BirthYear
	  ,Gender
	  ,PowerEnrollmentDate
	  ,'No match in EDC' AS RegistryVisitType
	  ,CAST(NULL AS date) AS RegistryVisitDate
	  ,CAST(NULL AS bigint) AS DaysFromVisit
	  ,MedicationStartDate
	  ,Medication
	  ,PatientStatus

FROM NoVisitMatch
WHERE SiteID<>999
AND SUBSTRING(CAST(SubjectID AS varchar), 1, 3)<>'999'
AND PatientID NOT IN (SELECT PatientID FROM [Reporting].[POWER].[t_op_IneligibleSubjects])



--SELECT * FROM [Reporting].[POWER].[t_op_IneligibleSubjects]



GO
