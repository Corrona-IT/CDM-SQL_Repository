USE [Reporting]
GO
/****** Object:  View [POWER].[v_op_CaseManagementLookup]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE VIEW [POWER].[v_op_CaseManagementLookup]  AS

WITH CMLOOKUP AS
(
SELECT *
FROM
(
SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY patient_id, first_name, last_name, preferredcontact DESC, preferredemail DESC, bestphone DESC, preferredTime DESC, timezone_code DESC, city, [state]) AS ROWNUM
      ,patient_id AS PatientID
      ,first_name AS firstName
	  ,last_name AS lastName
	  ,preferredcontact AS preferredContactMethod
	  ,preferredemail AS emailAddress
	  ,bestphone AS phoneNumber
	  ,preferredTime AS preferredContactTimeOfDay
	  ,timezone_code AS timeZone
	  ,city AS City
	  ,[state] AS [State]

FROM [APower].[dbo].[case_management]
WHERE UPPER(first_name) NOT LIKE '%TEST%'

) A
WHERE ROWNUM=1
)



,PatientStatus AS
(
SELECT DISTINCT SP.patient_id AS PatientID
      ,subject_id
	  ,CASE WHEN SP.patient_id IN (45379) THEN 'Ineligible'
	   WHEN SP.patient_id IN (45408, 45409, 45298) THEN 'Not participating'
	   WHEN ISNULL(CMC.PatientStatus, '')<>'' THEN CMC.PatientStatus
	   WHEN SP.patient_id NOT IN  (45379, 45408, 45409, 45298) AND SP.study_state_id=1 THEN 'First time'
	   WHEN SP.patient_id NOT IN  (45379, 45408, 45409, 45298) AND SP.study_state_id=2 THEN 'Predose'
	   WHEN SP.patient_id NOT IN  (45379, 45408, 45409, 45298) AND SP.study_state_id=3 THEN 'Postdose'
	   WHEN SP.patient_id NOT IN  (45379, 45408, 45409, 45298) AND SP.study_state_id=4 THEN 'Medication stopped'
	   WHEN SP.patient_id NOT IN  (45379, 45408, 45409, 45298) AND SP.study_state_id=5 THEN 'Complete'
	   ELSE 'No status'
	   END AS PatientStatus

FROM [APower].[dbo].[study_participation] SP
LEFT JOIN [Reporting].[POWER].[t_op_CaseMgmtCompliance] CMC ON CMC.PatientID=SP.patient_id
--WHERE subject_id NOT LIKE '999%'
--ORDER BY PatientID
)




SELECT cml.ROWNUM,
       cml.PatientID,
	   PS.subject_id,
	   PS.PatientStatus,
	   cmc.StudyStateID,
	   CASE WHEN ISNULL(cmc.AssessmentWeek, '')='' THEN 99
	   ELSE cmc.AssessmentWeek
	   END AS AssessmentWeek,
	   cml.firstName,
	   cml.lastName,
	   cml.preferredContactMethod,
	   cml.emailAddress,
	   cml.phoneNumber,
	   cml.preferredContactTimeOfDay,
	   cml.timeZone, 
	   cml.City,
	   cml.[State]

FROM CMLOOKUP cml
LEFT JOIN PatientStatus PS ON PS.PatientID=cml.PatientID
LEFT JOIN [Reporting].[POWER].[t_op_CaseMgmtCompliance] cmc ON cml.patientID=cmc.PatientID
WHERE PS.subject_id NOT LIKE '999%'
--AND cml.PatientID NOT IN (SELECT PatientID FROM [Reporting].[POWER].[t_op_IneligibleSubjects])
--ORDER BY PatientID



GO
