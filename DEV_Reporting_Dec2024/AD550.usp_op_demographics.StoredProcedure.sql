USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_demographics]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 2/24/2020, Updated: 7/11/2022
-- Description:	Procedure for Data Entry Lag Table
-- =================================================


CREATE PROCEDURE [AD550].[usp_op_demographics] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_op_demographics](
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar](15) NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[yearOfBirth] [int] NULL,
	[gender] [nvarchar](25) NULL,
	[race] [nvarchar](500) NULL,
	[ethnicity] [nvarchar](50) NULL,
) ON [PRIMARY]
GO
*/

IF OBJECT_ID('tempdb.dbo.#SubjectSite') IS NOT NULL BEGIN DROP TABLE #SubjectSite END

SELECT SiteID,
       SubjectID,
	   patientId,
	   [status],
	   CASE WHEN gender=0 THEN 'male'
	   WHEN gender=1 THEN 'female'
	   ELSE CAST(gender AS varchar)
	   END AS gender,
	   yearOfBirth,
	   race,
	   ethnicity
INTO #SubjectSite
FROM
(
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'American Indian or Alaskan Native' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND [status]='Enrolled'
AND S2.race_native_am=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Asian' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND S2.race_asian=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Black/African American' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND [status]='Enrolled'
AND S2.race_black=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Native Hawaiian or Other Pacific Islander' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND [status]='Enrolled'
AND S2.race_pacific=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'White' AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND [status]='Enrolled'
AND S2.race_white=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,'Other' + ': ' + S2.race_oth_txt AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND [status]='Enrolled'
AND S2.race_other=1
UNION
SELECT DISTINCT S.[SiteID]
      ,S.[SubjectID]
	  ,S.[patientId]
	  ,S.[status]
	  ,S2.sex AS gender
	  ,S2.birthdate AS yearOfBirth
	  ,CAST(NULL AS varchar) AS race
	  ,CASE WHEN S2.ethnicity_hispanic=0 THEN 'Not Hispanic or Latino'
	   WHEN S2.ethnicity_hispanic=1 THEN 'Hispanic or Latino'
	   ELSE CAST(S2.ethnicity_hispanic AS nvarchar)
	   END AS ethnicity
FROM [Reporting].[AD550].[v_op_subjects] S 
LEFT JOIN [RCC_AD550].[staging].[subject] S2 ON S2.subjectId=S.patientId AND S2.eventId=8031
WHERE ISNULL(S.[SiteID], '')<>'' --NOT IN ('', 1440) AND 
AND [status]='Enrolled'
AND (ISNULL(S2.race_other, '')='' AND ISNULL(S2.race_white, '')='' AND ISNULL(S2.race_pacific, '')='' AND ISNULL(S2.race_black, '')='' AND ISNULL(S2.race_asian, '')='' AND ISNULL(S2.race_native_am, '')='')
) subjects


--SELECT * FROM #SubjectSite ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb.dbo.#SubjectDemographics') IS NOT NULL BEGIN DROP TABLE #SubjectDemographics END


TRUNCATE TABLE [Reporting].[AD550].[t_op_demographics];

INSERT INTO [Reporting].[AD550].[t_op_demographics]
(
SiteID,
SubjectID,
patientId,
gender,
yearOfBirth,
race,
ethnicity
)
/**group multiple race responses to one line**/

SELECT DISTINCT SiteID,
       SubjectID,
	   patientId,
	   gender,
	   yearOfBirth,
	   STUFF((
	   SELECT DISTINCT ', ' + race
	   FROM #SubjectSite S
	   WHERE S.patientId=#SubjectSite.patientId
	   FOR XML PATH('')
        )
        ,1,1,'') AS race,
	  ethnicity
	  
FROM #SubjectSite

--SELECT * FROM AD550.t_op_demographics ORDER BY SiteID, SubjectID

END

GO
