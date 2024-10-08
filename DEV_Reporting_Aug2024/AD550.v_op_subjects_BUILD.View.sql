USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_subjects_BUILD]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*****This view corrects the SiteID on the api call for api.subjects table*****/

CREATE VIEW [AD550].[v_op_subjects_BUILD] AS

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
      ,[enabled]
  FROM [RCC_AD550_Build].[api].[study_sites]
)

SELECT S.[status]
      ,S.studySiteID AS InternalSiteID
	  ,SS.SiteID
	  ,S.[uniqueIdentifier] AS SubjectID
	  ,S.studySiteName
	  ,S.[id] AS patientId 

  FROM [RCC_AD550_Build].[api].[subjects] S
  LEFT JOIN SITEID SS ON SS.SiteName=S.studySiteName
  WHERE ISNULL(S.[uniqueIdentifier], '')<>''


GO
