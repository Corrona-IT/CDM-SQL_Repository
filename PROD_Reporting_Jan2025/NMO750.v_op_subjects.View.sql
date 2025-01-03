USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_subjects]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











/*****This view corrects the SiteID on the api call for api.subjects table*****/

CREATE VIEW [NMO750].[v_op_subjects] AS

WITH SITEID AS
(
SELECT [jsonId]
      ,[name]
	  ,RTRIM(SUBSTRING([name], 1, CHARINDEX('-', [name])-1)) AS SiteID
	  ,LTRIM(SUBSTRING([name], CHARINDEX('-', [name])+1, LEN([name]))) AS SiteName
      ,[siteType]
      ,[principalInvestigator]
      ,[studyId]
      ,[siteId] AS systemSiteID
      ,[facilityName]
      ,[id]
      ,[enabled] AS SiteStatus
  FROM [RCC_NMOSD750].[api].[study_sites]
)

,Subjects AS (
SELECT S.[status]
      ,CASE WHEN SS.SiteStatus='true' THEN 'Active'
	   ELSE 'Inactive'
	   END AS SiteStatus
      ,S.studySiteID AS InternalSiteID
	  ,SS.SiteID
	  ,S.[uniqueIdentifier] AS SubjectID
	  ,CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(S.[dateScreened] AS bigint)/1000 ,'1970/1/1'), 120) AS [calcDateScreened]
	  ,S.studySiteName
	  ,S.[id] AS patientId 

  FROM [RCC_NMOSD750].[api].[subjects] S
  LEFT JOIN SITEID SS ON SS.SiteName=S.studySiteName
  WHERE status='Enrolled'
 )

 ,RACE AS (
 SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_native_am=1 THEN 'American Indian or Alaskan Native' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
WHERE SF.race_native_am=1
UNION

SELECT 	S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_asian=1 THEN 'Asian' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
WHERE SF.race_asian=1
UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_black=1 THEN 'Black/African American' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
WHERE SF.race_black=1
UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_pacific=1 THEN 'Native Hawaiian or Other Pacific Islander' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
WHERE SF.race_pacific=1
UNION

SELECT S.SubjectID,
	   S.patientId,
	   CASE WHEN SF.race_white=1 THEN 'White' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
WHERE SF.race_white=1
UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_other=1 AND ISNULL(SF.race_other_specify, '')<>'' THEN CONCAT('Other: ', SF.race_other_specify)
		WHEN SF.race_other=1 AND ISNULL(SF.race_other_specify, '')='' THEN 'Other: Not specified'
		ELSE NULL
		END AS race
FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
WHERE SF.race_other=1 
)

,SubjectInfo AS (
SELECT S.SubjectID,
       S.patientId,
	   subject_yob AS yearOfBirth,
	   CASE WHEN subject_sex=0 THEN 'Male'
	   when subject_sex=1 THEN 'Female'
	   ELSE NULL
	   END AS gender

FROM Subjects S
LEFT JOIN [RCC_NMOSD750].[staging].[subjectinfo] SI ON SI.subNum=S.SubjectID

)

,SubjectForm AS (
 SELECT S.[status],
		S.SiteStatus,
		S.SiteID,
		S.SubjectID,
		S.patientId,
		CASE WHEN SF.sex=0 THEN 'Male'
		WHEN SF.sex=1 THEN 'Female'
		ELSE CAST(SF.sex AS nvarchar)
		END AS gender,
		SF.birthdate AS yearOfBirth,
		STUFF((
        SELECT ', ' + race
        FROM RACE B
		WHERE SF.subNum=B.SubjectID
        FOR XML PATH('')
        ),1,1,'') AS race,

		CASE WHEN SF.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
		WHEN SF.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
		ELSE CAST(SF.ethnicity_hispanic AS nvarchar)
		END AS ethnicity

 FROM Subjects S
 LEFT JOIN [RCC_NMOSD750].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventName='Enrollment'
 )

 SELECT DISTINCT SF.[status],
        SF.SiteStatus,
		SF.SiteID,
		SF.SubjectID,
		SF.patientId,
		COALESCE(SF.gender, SI.gender) AS gender,
		COALESCE(SF.yearOfBirth, SI.yearOfBirth) AS yearOfBirth,
		SF.race,
		SF.ethnicity
 FROM SubjectForm SF
 LEFT JOIN SubjectInfo SI ON SI.patientId=SF.patientId
 --ORDER BY SF.SubjectID
GO
