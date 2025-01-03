USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_subjects]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/*****This view corrects the SiteID on the api call for api.subjects table*****/

CREATE VIEW [MS700].[v_op_subjects] AS

WITH SITEID AS (
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
  FROM [RCC_MS700].[api].[study_sites]
)

,Subjects AS (
SELECT S.[status] AS SubjectStatus
      ,CASE WHEN SS.SiteStatus='true' THEN 'Active'
	   ELSE 'Inactive'
	   END AS SiteStatus
      ,S.studySiteID AS InternalSiteID
	  ,SS.SiteID
	  ,S.[uniqueIdentifier] AS SubjectID
	  ,S.studySiteName
	  ,S.[id] AS patientId 

  FROM [RCC_MS700].[api].[subjects] S
  LEFT JOIN SITEID SS ON SS.SiteName=S.studySiteName
  --WHERE ISNULL(SS.SiteID, '') NOT IN ('', 1440)
  )

 ,RACE AS (

 SELECT S.SubjectID,
        S.patientId,
		CASE WHEN SD.race_white=1 THEN 'White' ELSE NULL END AS race
 FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
 WHERE SD.race_white=1

UNION

SELECT S.SubjectID,
        S.patientId,
		CASE WHEN SD.race_nativeamerican=1 THEN 'American Indian or Alaskan Native' ELSE NULL END AS race
 FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
 WHERE SD.race_nativeamerican=1

 UNION

  SELECT S.SubjectID,
        S.patientId,
		CASE WHEN SD.race_asian=1 THEN 'Asian' ELSE NULL END AS race
 FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
 WHERE SD.race_asian=1

 UNION

  SELECT S.SubjectID,
        S.patientId,
		CASE WHEN SD.race_black=1 THEN 'Black/African American' ELSE NULL END AS race
 FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
 WHERE SD.race_black=1
 
 UNION

  SELECT S.SubjectID,
        S.patientId,
		CASE WHEN SD.race_hawaiian=1 THEN 'Native Hawaiian or Other Pacific Islander' ELSE NULL END AS race
 FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
 WHERE SD.race_hawaiian=1

 UNION

  SELECT S.SubjectID,
        S.patientId,
		CASE WHEN SD.race_other=1 AND ISNULL(SD.race_oth_txt, '')<>'' THEN CONCAT('Other: ', SD.race_oth_txt)
		WHEN SD.race_other=1 AND ISNULL(SD.race_oth_txt, '')='' THEN 'Other: Not specified'
		ELSE NULL
		END AS race
 FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
 WHERE SD.race_other=1 
 )

 
 ,SubjectInfo AS (
SELECT S.SubjectID,
       S.patientId,
	   SD.birthdate AS yearOfBirth,
	   SD.sex_dec AS gender,
	   SD.race_hispanic_dec AS ethnicity
FROM Subjects S
 LEFT JOIN [RCC_MS700].[staging].[subjectdemography] SD ON SD.subNum=S.SubjectID AND SD.eventId=3042
)



 ,SubjectForm AS (
 SELECT S.SubjectStatus,
        S.SiteStatus,
		S.SiteID,
		S.SubjectID,
		S.patientId,
		SI.gender,
		SI.yearOfBirth,
		STUFF((
		SELECT ', ' + RACE
		FROM Race B
		WHERE SI.patientId=B.patientId
		FOR XML PATH('')
		),1,1,'') AS race,
		SI.ethnicity

FROM Subjects S
LEFT JOIN SubjectInfo SI ON SI.patientId=S.patientId
)

SELECT SubjectStatus,
       SiteStatus,
	   CASE WHEN S.SiteID = 1440 THEN 'Approved / Active'
	   ELSE RS.[currentStatus] 
	   END AS SFSiteStatus,
	   S.SiteID,
	   SubjectID,
	   patientId,
	   gender,
	   yearOfBirth,
	   race,
	   ethnicity
FROM SubjectForm S
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=S.SiteID AND RS.[name]='Multiple Sclerosis (MS-700)'


GO
