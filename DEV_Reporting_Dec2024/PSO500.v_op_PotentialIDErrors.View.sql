USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_PotentialIDErrors]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [PSO500].[v_op_PotentialIDErrors] AS

WITH SUBJECTS AS
(

SELECT PAT.[Sys. SiteNo] AS [SiteID]
	  ,PAT.[Sys. PatientNo] AS [SubjectID]
	  ,'Potential Registry ID Error' AS [PotentialIDError]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
WHERE EXISTS (SELECT PAT2.[Sys. PatientNo] FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT2
              WHERE PAT2.[Sys. PatientNo]=PAT.[Sys. PatientNo] 
			  AND SUBSTRING(PAT2.[Sys. PatientNo], 1, 1) <> 4)
---AND PAT.[Sys. SiteNo] NOT IN (998, 999)

UNION

SELECT PAT.[Sys. SiteNo] AS [SiteID]
	  ,PAT.[Sys. PatientNo] AS [SubjectID]
	  ,'Potential Site ID Error' AS [PotentialIDError]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
WHERE EXISTS (SELECT PAT2.[Sys. PatientNo] FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT2
              WHERE PAT2.[Sys. PatientNo]=PAT.[Sys. PatientNo] 
			  AND SUBSTRING(PAT2.[Sys. PatientNo], 2, 3) <> PAT2.[Sys. SiteNo])
---AND PAT.[Sys. SiteNo] NOT IN (998, 999)

UNION

SELECT PAT.[Sys. SiteNo] AS [SiteID]
	  ,PAT.[Sys. PatientNo] AS [SubjectID]
      ,'Potential Patient ID Range Error' AS [PotentialIDError]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
WHERE SUBSTRING(PAT.[Sys. PatientNo], 8, 4) > (SELECT (COUNT(DISTINCT PAT2.[Sys. PatientNo]) + 30) FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT2
              WHERE PAT2.[Sys. SiteNo]=PAT.[Sys. SiteNo]) 
---AND PAT.[Sys. SiteNo] NOT IN (998, 999)

UNION

SELECT PAT.[Sys. SiteNo] AS [SiteID]
	  ,PAT.[Sys. PatientNo] AS [SubjectID]
	  ,'Potential Provider ID Error' AS [PotentialIDError]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] PAT
WHERE NOT EXISTS (SELECT SIT2.[SITE2_INVID] FROM [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[SITE_SITE2] SIT2
              WHERE SIT2.[Site Object SiteNo]=PAT.[Sys. SiteNo] 
			  AND SUBSTRING(PAT.[Sys. PatientNo], 5, 3) = SIT2.[SITE2_INVID])

---AND PAT.[Sys. SiteNo] NOT IN (998, 999)

---order by SiteID, SubjectID
)

SELECT CAST(SiteID AS int) AS SiteID
      ,CAST(SubjectID AS bigint) AS SubjectID
	  ,PotentialIDError
FROM SUBJECTS
WHERE SiteID NOT IN (998, 999)
GO
