USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_subjects_rcc]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/*****This view corrects the SiteID on the api call for api.subjects table*****/

CREATE VIEW [RA100].[v_op_subjects_rcc] AS

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
  FROM [RCC_RA100].[api].[study_sites]
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

  FROM [RCC_RA100].[api].[subjects] S --SELECT * FROM [RCC_RA100].[api].[subjects]
  LEFT JOIN SITEID SS ON SS.SiteName=S.studySiteName --SELECT * FROM [Salesforce].[dbo].[registryStatus] 
  LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.siteNumber=SS.SiteID AND SF.[name]='Rheumatoid Arthritis (RA-100,02-021)'
  --WHERE ISNULL(SS.SiteID, '') NOT IN ('', 1440)
)

,RACE AS 
(
SELECT S.SubjectID,
       S.patientId,
	   CASE WHEN SF.demg_1_1200_1=1 THEN 'American Indian or Alaskan Native' ELSE NULL END AS race
FROM Subjects S --SELECT * FROM [RCC_RA100].[staging].[subjectform]
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
WHERE SF.demg_1_1200_1=1

UNION

SELECT 	S.SubjectID,
		S.patientId,
		CASE WHEN SF.demg_1_1200_2=1 THEN 'Asian' ELSE NULL END AS race
FROM Subjects S --SELECT * FROM [RCC_AD550].[staging].[subject] WHERE eventId=8031
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
WHERE SF.demg_1_1200_2=1

UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.demg_1_1200_3=1 THEN 'Black/African American' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
WHERE SF.demg_1_1200_3=1

UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.demg_1_1200_4=1 THEN 'Native Hawaiian or Other Pacific Islander' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
WHERE SF.demg_1_1200_4=1

UNION

SELECT S.SubjectID,
	   S.patientId,
	   CASE WHEN SF.demg_1_1200_5=1 THEN 'White' ELSE NULL END AS race
FROM Subjects S
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
WHERE SF.demg_1_1200_5=1

UNION

SELECT S.SubjectID,
		S.patientId,
		CASE WHEN SF.demg_1_1200_99=1 AND ISNULL(SF.demg_1_1290, '')<>'' THEN CONCAT('Other: ', SF.demg_1_1290)
		WHEN SF.demg_1_1200_99=1 AND ISNULL(SF.demg_1_1290, '')='' THEN 'Other: Not specified'
		ELSE NULL
		END AS race
FROM Subjects S
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
WHERE SF.demg_1_1200_99=1

--SELECT * FROM [RCC_RA100].[staging].[subjectpersonalinformation] 
)


SELECT DISTINCT S.[status],
       S.SiteStatus,
	   S.SFSiteStatus,
	   S.SiteID,
	   S.SubjectID,
	   S.patientId,
	   CASE WHEN SF.demg_1_1000=0 THEN 'Male'
		WHEN SF.demg_1_1000=1 THEN 'Female'
		ELSE CAST(SF.demg_1_1000 AS nvarchar)
		END AS gender,
	   SF.demg_3_1100 AS yearOfBirth,
	   STUFF((
        SELECT ', ' + race
        FROM RACE B
		WHERE SF.subNum=B.SubjectID
        FOR XML PATH('')
        ),1,1,'') AS race,
	   CASE WHEN SF.demg_1_1300=0 THEN 'Not Hispanic or Latino'
		WHEN SF.demg_1_1300=1 THEN 'Hispanic or Latino'
		ELSE CAST(SF.demg_1_1300 AS nvarchar)
		END AS ethnicity
FROM Subjects S
LEFT JOIN [RCC_RA100].[staging].[subjectform] SF ON SF.subNum=S.SubjectID AND SF.eventId=9285
--ORDER BY SubjectID

GO
