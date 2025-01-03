USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_subjects]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/*****This view corrects the SiteID on the api call for api.subjects table*****/

CREATE VIEW [AD550].[v_op_subjects] AS

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
  FROM [RCC_AD550].[api].[study_sites]
)

,Subjects AS (
SELECT S.[status]
      ,CASE WHEN SS.SiteStatus='true' THEN 'Active'
	   ELSE 'Inactive'
	   END AS SiteStatus
	  ,SF.currentStatus AS SFSiteStatus
      ,S.studySiteID AS InternalSiteID
	  ,SS.SiteID
	  ,S.[uniqueIdentifier] AS SubjectID
	  ,S.studySiteName
	  ,S.[id] AS patientId 

  FROM [RCC_AD550].[api].[subjects] S
  LEFT JOIN SITEID SS ON SS.[id]=S.studySiteId
  LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.siteNumber=SS.SiteID AND SF.[name]='Atopic Dermatitis (AD-550)'
  --WHERE ISNULL(SS.SiteID, '') NOT IN ('', 1440)
)

,RACE AS 
(
SELECT S.SubjectID,
       S.patientId,
	   CASE WHEN SF.race_native_am=1 THEN 'American Indian or Alaskan Native' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
WHERE SF.race_native_am=1

UNION

SELECT 	S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_asian=1 THEN 'Asian' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
WHERE SF.race_asian=1

UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_black=1 THEN 'Black/African American' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
WHERE SF.race_black=1

UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_pacific=1 THEN 'Native Hawaiian or Other Pacific Islander' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
WHERE SF.race_pacific=1

UNION

SELECT S.SubjectID,
	   S.patientId,
	   CASE WHEN SF.race_white=1 THEN 'White' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
WHERE SF.race_white=1

UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.race_other=1 AND ISNULL(SF.race_oth_txt, '')<>'' THEN CONCAT('Other: ', SF.race_oth_txt)
		WHEN SF.race_other=1 AND ISNULL(SF.race_oth_txt, '')='' THEN 'Other: Not specified'
		ELSE NULL
		END AS race
FROM Subjects S
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
WHERE SF.race_other=1
)


SELECT DISTINCT S.[status],
       S.SiteStatus,
	   S.SFSiteStatus,
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
LEFT JOIN [RCC_AD550].[staging].[subject] SF ON SF.subNum=S.SubjectID AND SF.eventId=8031
--ORDER BY SubjectID

GO
