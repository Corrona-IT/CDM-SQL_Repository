USE [Reporting]
GO
/****** Object:  View [dbo].[v_op_MULTIREG_IDErrors_V2]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















--NEED TO ADD AD DE LAG


CREATE VIEW --SELECT * FROM
[dbo].[v_op_MULTIREG_IDErrors_V2] AS

WITH SUBJECTS AS
(
SELECT DISTINCT
	  'RA-102' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance] --SELECT *
FROM [MERGE_RA_Japan].[dbo].[DAT_SUB] VL1
WHERE SUBSTRING(CAST([SUBNUM] AS NVARCHAR(11)), 1, 4) <> [SITENUM]
AND CONCAT([SITENUM],SUBSTRING(CAST(VL1.[SUBNUM] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDRA102]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDRA102] IS NOT NULL) 
AND [DELETED] = 'f'


--UNION
--
--SELECT DISTINCT
--	  'RA-102' AS [Registry]
--	  ,[SiteID]
--	  ,[SubjectID]
--	  ,'Patient ID Range' AS [IDErrorType]
--FROM [MERGE_RA_Japan].[dbo].[DAT_SUB]VL1
--WHERE SUBSTRING(VL1.[SubjectID], 8, 4) > (SELECT (COUNT(DISTINCT VL2.[SubjectID]) + 100) FROM [MERGE_RA_Japan].[dbo].[DAT_SUB]VL2
--              WHERE VL1.SiteID = VL2.SiteID 
--			  AND VisitType = 'Enrollment') 

UNION

SELECT DISTINCT
	  'RA-102' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
FROM [MERGE_RA_Japan].[dbo].[DAT_SUB] VL1
WHERE CONCAT([SITENUM],SUBSTRING(CAST(VL1.[SUBNUM] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDRA102]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDRA102] IS NOT NULL) 
AND [DELETED] = 'f'

UNION 

SELECT DISTINCT
	  'RA-102' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance]
FROM [MERGE_RA_Japan].[dbo].[DAT_SUB]VL1
WHERE ISNUMERIC([SUBNUM]) <> 1
AND [DELETED] = 'f'

UNION

SELECT DISTINCT
	  'PSA-400' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Registry ID' AS [IDErrorType]
	  ,2 AS [Importance]
FROM [MERGE_SPA].[dbo].[DAT_SUB]
WHERE LEFT(CAST([SUBNUM] AS NVARCHAR(11)), 1) <> 3
AND [DELETED] = 'f'

UNION

SELECT DISTINCT
	  'PSA-400' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]
FROM [MERGE_SPA].[dbo].[DAT_SUB] VL1
WHERE SUBSTRING(CAST([SUBNUM] AS NVARCHAR(11)), 2, 3) <> [SITENUM]
--AND CONCAT([SITENUM],REPLACE(LTRIM(REPLACE(SUBSTRING(CAST(VL1.[SUBNUM] AS NVARCHAR(11)), 5, 2),'0',' ')), ' ', '0')) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDRA100SPA400]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDRA100SPA400] IS NOT NULL) 
AND [DELETED] = 'f'

--UNION
--
--SELECT DISTINCT
--	  'PSA-400' AS [Registry]
--	  ,[SiteID]
--	  ,[SubjectID]
--	  ,'Patient ID Range' AS [IDErrorType]
--FROM [MERGE_SPA].[dbo].[DAT_SUB]VL1
--WHERE SUBSTRING(VL1.[SubjectID], 8, 4) > (SELECT (COUNT(DISTINCT VL2.[SubjectID]) + 100) FROM [MERGE_SPA].[dbo].[DAT_SUB]VL2
--              WHERE VL1.SiteID = VL2.SiteID 
--			  AND VisitType = 'Enrollment') 

UNION

SELECT DISTINCT
	  'PSA-400' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
FROM [MERGE_SPA].[dbo].[DAT_SUB] VL1
WHERE CONCAT([SITENUM],REPLACE(LTRIM(REPLACE(SUBSTRING(CAST(VL1.[SUBNUM] AS NVARCHAR(11)), 5, 2),'0',' ')), ' ', '0')) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDRA100SPA400]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDRA100SPA400] IS NOT NULL) 
AND [DELETED] = 'f'

UNION 

SELECT DISTINCT
	  'PSA-400' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance]
FROM [MERGE_SPA].[dbo].[DAT_SUB]
WHERE ISNUMERIC([SUBNUM]) <> 1
AND [DELETED] = 'f'

UNION

SELECT DISTINCT
	  'PSO-500' AS [Registry]
	  ,[Sys. SiteNo] AS [SiteID]
	  ,CAST([subject_id] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Registry ID' AS [IDErrorType]
	  ,2 AS [Importance]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information]
WHERE LEFT(CAST([subject_id] AS NVARCHAR(11)), 1) <> '4'

UNION

SELECT DISTINCT
	  'PSO-500' AS [Registry]
	  ,[Sys. SiteNo] AS [SiteID]
	  ,CAST([subject_id] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance] -- SELECT *
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] VL1
WHERE SUBSTRING(CAST([subject_id] AS NVARCHAR(11)), 2, 3) <> [Sys. SiteNo]
AND CONCAT([Sys. SiteNo],SUBSTRING(CAST(VL1.[subject_id] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],CAST([ProviderIDPSO500] AS VARCHAR(3))) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDPSO500] IS NOT NULL) 

--UNION
--
--SELECT DISTINCT
--	  'PSO-500' AS [Registry]
--	  ,[SiteID]
--	  ,[SubjectID]
--	  ,'Patient ID Range' AS [IDErrorType]
--FROM [Reporting].[PSO500].[v_op_VisitLog] VL1
--WHERE SUBSTRING(CAST([SubjectID] AS VARCHAR(15)), 8, 4) > (SELECT (COUNT(DISTINCT VL2.[SubjectID]) + 100) FROM [Reporting].[PSO500].[v_op_VisitLog] VL2
--              WHERE VL1.SiteID = VL2.SiteID 
--			  AND VisitType = 'Enrollment') 

UNION

SELECT DISTINCT
	  'PSO-500' AS [Registry]
	  ,[Sys. SiteNo] AS [SiteID]
	  ,CAST([subject_id] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] VL1
WHERE CONCAT([Sys. SiteNo],SUBSTRING(CAST(VL1.[subject_id] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],CAST([ProviderIDPSO500] AS VARCHAR(3))) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDPSO500] IS NOT NULL) 


UNION

SELECT DISTINCT
	  'PSO-500' AS [Registry]
	  ,[Sys. SiteNo] AS [SiteID]
	  ,CAST([subject_id] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance]
FROM [OMNICOMM_PSO].[inbound].[G_Subject Information] 
WHERE ISNUMERIC([subject_id]) <> 1

UNION

SELECT DISTINCT
	  'IBD-600' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]
FROM [MERGE_IBD].[dbo].[DAT_SUB] VL1
WHERE SUBSTRING(CAST([SUBNUM] AS NVARCHAR(11)), 1, 4) <> [SITENUM] 
AND CONCAT([SITENUM],SUBSTRING(CAST(VL1.[SUBNUM] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDIBD600]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDIBD600] IS NOT NULL)
AND [DELETED] = 'f'

--UNION
--
--SELECT DISTINCT
--	  'IBD-600' AS [Registry]
--	  ,[SiteID]
--	  ,[SubjectID]
--	  ,'Patient ID Range' AS [IDErrorType]
--FROM [Reporting].[IBD600].[v_op_VisitLog] VL1
--WHERE SUBSTRING(VL1.[SubjectID], 8, 4) > (SELECT (COUNT(DISTINCT VL2.[SubjectID]) + 100) FROM [Reporting].[IBD600].[v_op_VisitLog] VL2
--              WHERE VL1.SiteID = VL2.SiteID 
--			  AND VisitType = 'Enrollment') 

UNION

SELECT DISTINCT
	  'IBD-600' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
FROM [MERGE_IBD].[dbo].[DAT_SUB] VL1
WHERE CONCAT([SITENUM],SUBSTRING(CAST(VL1.[SUBNUM] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDIBD600]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDIBD600] IS NOT NULL)
AND [DELETED] = 'f'

UNION

SELECT DISTINCT
	  'IBD-600' AS [Registry]
	  ,[SITENUM] AS [SiteID]
	  ,CAST([SUBNUM] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance]
FROM [MERGE_IBD].[dbo].[DAT_SUB]
WHERE ISNUMERIC([SUBNUM]) <> 1
AND [DELETED] = 'f'

UNION

SELECT DISTINCT
	  'MS-700' AS [Registry]
	  ,[studySiteName] AS [SiteID]
	  ,CAST([uniqueIdentifier] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]--SELECT *
FROM [RCC_MS700].[api].[subjects] VL1
WHERE SUBSTRING(CAST([uniqueIdentifier] AS NVARCHAR(11)), 1, 4) <> [studySiteName]
AND CONCAT([studySiteName],SUBSTRING(CAST(VL1.[uniqueIdentifier] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDMS700]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDMS700] IS NOT NULL) 
AND [studySiteName] <> 'Corrona'

--UNION

--SELECT DISTINCT
--	  'MS-700' AS [Registry]
--	  ,[SiteID]
--	  ,[SubjectID]
--	  ,'Patient ID Range' AS [IDErrorType]
--FROM [Reporting].[MS700].[v_op_VisitLog] VL1
--WHERE SUBSTRING(VL1.[SubjectID], 8, 4) > (SELECT (COUNT(DISTINCT VL2.[SubjectID]) + 100) FROM [Reporting].[MS700].[v_op_VisitLog] VL2
--              WHERE VL1.SiteID = VL2.SiteID 
--			  AND VisitType = 'Enrollment') 

UNION

SELECT DISTINCT
	  'MS-700' AS [Registry]
	  ,[studySiteName] AS [SiteID]
	  ,CAST([uniqueIdentifier] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance] --SELECT *
FROM [RCC_MS700].[api].[subjects] VL1
WHERE CONCAT([studySiteName],SUBSTRING(CAST(VL1.[uniqueIdentifier] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDMS700]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDMS700] IS NOT NULL) 
AND [studySiteName] <> 'Corrona'

UNION

SELECT DISTINCT
	  'MS-700' AS [Registry]
	  ,[studySiteName] AS [SiteID]
	  ,CAST([uniqueIdentifier] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance] --SELECT *
FROM [RCC_MS700].[api].[subjects]
WHERE ISNUMERIC([uniqueIdentifier]) <> 1
AND [studySiteName] <> 'Corrona'
--ORDER BY [Registry], [SiteID], [Importance]
---order by SiteID, SubjectID

UNION 

SELECT DISTINCT
   'MS-700' AS [Registry]
  ,CAST(MS700.v_op_VisitLog.SiteID AS int) AS [SiteID]
  ,MS700.v_op_VisitLog.SubjectIDError AS [SubjectID]
  ,'Non-Numeric ID' AS [IDErrorType]
  ,1 AS [Importance]
FROM
  MS700.v_op_VisitLog
  WHERE SubjectIDError IS NOT NULL

UNION

SELECT DISTINCT
	  'AD-550' AS [Registry]
	  ,[SiteID] AS [SiteID]
	  ,CAST([SubjectID] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]--SELECT *
FROM [AD550].[v_op_subjects] VL1
WHERE SUBSTRING(CAST([SubjectID] AS NVARCHAR(11)), 2, 3) <> [SiteID]
AND CONCAT([SiteID],SUBSTRING(CAST(VL1.[SubjectID] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDPSO500]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDPSO500] IS NOT NULL) 
AND [SiteID] NOT LIKE '%1440 - Corrona%'


--UNION

--SELECT DISTINCT
--	  'MS-700' AS [Registry]
--	  ,[SiteID]
--	  ,[SubjectID]
--	  ,'Patient ID Range' AS [IDErrorType]
--FROM [Reporting].[MS700].[v_op_VisitLog] VL1
--WHERE SUBSTRING(VL1.[SubjectID], 8, 4) > (SELECT (COUNT(DISTINCT VL2.[SubjectID]) + 100) FROM [Reporting].[MS700].[v_op_VisitLog] VL2
--              WHERE VL1.SiteID = VL2.SiteID 
--			  AND VisitType = 'Enrollment') 

UNION

SELECT DISTINCT
	  'AD-550' AS [Registry]
	  ,[SiteID] AS [SiteID]
	  ,CAST([SubjectID] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance] --SELECT *
FROM [AD550].[v_op_subjects] VL1
WHERE CONCAT([SiteID],SUBSTRING(CAST(VL1.[SubjectID] AS NVARCHAR(11)), 5, 3)) NOT IN (SELECT CONCAT([contact_SiteNumber],[ProviderIDPSO500]) FROM [Salesforce].[dbo].[registryContact] WHERE [ProviderIDPSO500] IS NOT NULL) 
AND [SiteID] NOT LIKE '%1440 - Corrona%'

UNION

SELECT DISTINCT
	  'AD-550' AS [Registry]
	  ,[SiteID] AS [SiteID]
	  ,CAST([SubjectID] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance] --SELECT *
FROM [AD550].[v_op_subjects]
WHERE ISNUMERIC([SubjectID]) <> 1
AND [SiteID] NOT LIKE '%1440 - Corrona%'
--ORDER BY [Registry], [SiteID], [Importance]
---order by SiteID, SubjectID

UNION

SELECT DISTINCT
	  'AD-550' AS [Registry]
	  ,[SiteID] AS [SiteID]
	  ,CAST([SubjectID] AS NVARCHAR(11)) AS [SubjectID]
	  ,'Registry ID' AS [IDErrorType]
	  ,2 AS [Importance] --SELECT *
FROM [AD550].[v_op_subjects]
WHERE LEFT(CAST([SubjectID] AS NVARCHAR(11)), 1) <> '5'

UNION 

SELECT DISTINCT
   'AD-550' AS [Registry]
  ,CAST(AD550.v_op_VisitLog.SiteID AS int) AS [SiteID]
  ,AD550.v_op_VisitLog.SubjectIDError AS [SubjectID]
  ,'Non-Numeric ID' AS [IDErrorType]
  ,1 AS [Importance]
FROM
  AD550.v_op_VisitLog
  WHERE SubjectIDError IS NOT NULL
),

FirstEntries AS
(
SELECT 'IBD-600' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(11)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [IBD600].[t_DataEntryLag] DE INNER JOIN SUBJECTS S ON S.SubjectID = CAST(DE.SubjectID AS NVARCHAR(11))
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'MS-700' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(11)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [MS700].[t_DataEntryLag] DE INNER JOIN SUBJECTS S ON S.SubjectID = CAST(DE.SubjectID AS NVARCHAR(11))
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'PSA-400' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(11)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [PSA400].[t_DataEntryLag] DE INNER JOIN SUBJECTS S ON S.SubjectID = CAST(DE.SubjectID AS NVARCHAR(11))
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'PSO-500' AS [Registry], DE.[SiteNumber] AS [SiteID], CAST(DE.SubjectID AS NVARCHAR(11)) AS [SubjectID], [VisitType], [VisitDate], DE.[CompletionDate] AS [FirstEntry] --SELECT *
FROM [PSO500].[v_op_DataEntryLag] DE INNER JOIN SUBJECTS S ON S.SubjectID = CAST(DE.SubjectID AS NVARCHAR(11))
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'RA-100' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(11)) AS [SubjectID], [VisitType], [VisitDate], DE.[CompletionDate] AS [FirstEntry] --SELECT *
FROM [RA100].[t_op_DataEntryLag] DE INNER JOIN SUBJECTS S ON S.SubjectID = CAST(DE.SubjectID AS NVARCHAR(11))
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'RA-102' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(11)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [RA102].[t_op_109_DataEntryLag] DE INNER JOIN SUBJECTS S ON S.SubjectID = CAST(DE.SubjectID AS NVARCHAR(11))
WHERE VisitType LIKE '%Enrollment%'

--NEED TO ADD AD DE LAG

),

Errors AS 
(
SELECT DISTINCT 
	   S1.[Registry]
	  ,S1.[SiteID]
      ,S1.[SubjectID]
	  ,S1.[IDErrorType]
	  --,FE.[VisitDate] AS [EnrollmentDate]
	  ,FE.[FirstEntry] AS [FirstEntryDate]
	  --,STUFF((SELECT ', ' + IDErrorType FROM SUBJECTS S2 WHERE S2.SubjectID = S1.SubjectID AND IDErrorType <> '' FOR XML PATH('')),1,1, '') AS [IDErrorTypeStuff]
	  --,CASE WHEN ID.[Status] IS NULL THEN 'New' 
	  -- ELSE ID.[Status]
	  -- END AS [Status]
	  --,ID.[Notes] AS [Notes]
	  --,ID.[LastStatusChangeDate] AS [Last Status Change Date]
FROM SUBJECTS S1 
LEFT JOIN FirstEntries FE ON FE.SubjectID = S1.SubjectID AND FE.Registry = S1.Registry
WHERE S1.SiteID NOT LIKE '99%'
--AND S1.[SubjectID] <> ''
),

PROVIDERS AS 
(
SELECT
	 'AD-550' AS Registry
	,SubjectID
	,ProviderID
	,VisitDate AS [EnrollmentDate]
	,SubjectIDError
FROM [AD550].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'IBD-600' AS Registry
	,SubjectID
	,ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [IBD600].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'MS-700' AS Registry
	,SubjectID
	,ProviderID
	,VisitDate AS [EnrollmentDate]
	,SubjectIDError -- SELECT *
FROM [MS700].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'PSA-400' AS Registry
	,SubjectID
	,ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [PSA400].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'PSO-500' AS Registry
	,SubjectID
	,ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [PSO500].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'RA-102' AS Registry
	,SubjectID
	,ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [RA102].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'
)
	 
SELECT DISTINCT
	 E.[Registry]
	,E.[SiteID]
	,E.[SubjectID]
	,P.[ProviderID]
	,LTRIM(STUFF((SELECT ', ' + [IDErrorType] FROM SUBJECTS S WHERE S.[SubjectID] = E.[SubjectID] ORDER BY [Registry], [SiteID], [Importance] FOR XML PATH('')),1,1, '')) AS [IDErrorType]
	,P.[EnrollmentDate]
	,E.[FirstEntryDate]
FROM ERRORS E
LEFT JOIN PROVIDERS P ON P.Registry = E.Registry AND (P.SubjectID = E.SubjectID OR P.SubjectIDError = E.SubjectID)
WHERE [EnrollmentDate] <> ''












GO
