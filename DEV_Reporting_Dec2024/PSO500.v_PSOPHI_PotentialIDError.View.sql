USE [Reporting]
GO
/****** Object:  View [PSO500].[v_PSOPHI_PotentialIDError]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [PSO500].[v_PSOPHI_PotentialIDError] AS

---Convert Site and Subject IDs to appropriate data type
WITH PRESUBJCONV AS
(
SELECT CAST(SiteID as int) AS SiteID
      ,CAST(SubjectID as bigint) as SubjectID
FROM Reporting.PSO500.t_PSOPHISubjects
)

,SUBJCONV AS
(
SELECT SiteID
      ,CAST(SubjectID AS varchar(20)) as SubjectID
FROM PRESUBJCONV
)

,FINDERRORS AS
(
---Find any Registry Errors
SELECT SiteID AS [Site ID]
	  ,SubjectID AS [Subject ID]
	  ,'Potential Registry ID Error' AS [Potential ID Error]
FROM SUBJCONV PHI
WHERE EXISTS (SELECT SubjectID FROM SUBJCONV PHI2
              WHERE PHI2.SubjectID=PHI.SubjectID 
			  AND SUBSTRING(PHI2.SubjectID, 1, 1) <> 4)

UNION

---Find any Subject ID errors
SELECT SiteID AS [Site ID]
	  ,SubjectID AS [Subject ID]
	  ,'Potential Site ID Error' AS [Potential ID Error]
FROM SUBJCONV PHI
WHERE EXISTS (SELECT SubjectID FROM SUBJCONV PHI2
              WHERE PHI2.SubjectID=PHI.SubjectID 
			  AND SUBSTRING(PHI2.SubjectID, 2, 3) <> PHI2.SiteID)

UNION

---Find any Patient number range errors
SELECT SiteID AS [Site ID]
	  ,SubjectID AS [Subject ID]
      ,'Potential Patient ID Range Error' AS [Potential ID Error]
FROM SUBJCONV PHI
WHERE SUBSTRING(SubjectID, 8, 4) > (SELECT (COUNT(DISTINCT PHI2.SubjectID) + 30) FROM SUBJCONV PHI2
              WHERE PHI2.SiteID=PHI.SiteID) 


-----------THIS UNION COMMENTED OUT IN DEV AS THERE IS NO LINKED SERVER
/*UNION

---Find any Provider ID errors
SELECT SiteID AS [Site ID]
	  ,SubjectID AS [Subject ID]
	  ,'Potential Provider ID Error' AS [Potential ID Error]
FROM SUBJCONV PHI
WHERE NOT EXISTS (SELECT SIT2.[SITE2_INVID] FROM [172.16.81.24].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[SITE_SITE2] SIT2
              WHERE SIT2.[Site Object SiteNo]=PHI.SiteID 
			  AND SUBSTRING(PHI.SubjectID, 5, 3) = SIT2.[SITE2_INVID])

*/
)

SELECT CAST([Site ID] as int) AS [Site ID]
      ,CAST([Subject ID] AS bigint) AS [Subject ID]
	  ,[Potential ID Error]
FROM FINDERRORS

---ORDER BY [Site ID], [Subject ID]










GO
