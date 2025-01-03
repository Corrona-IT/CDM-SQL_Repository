USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_IDErrors_V2]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =========================================================
-- Author: Kevin Soe
-- Create date: 13-Nov-2020
-- Description:	Create table for ID Errors Report
-- Updated: Kevin Soe
-- Updated Date: 16-Dec-2020
-- V3 Description: Add First Entry Dates for RCC Registries
-- ========================================================

			  
CREATE PROCEDURE [MULTI].[usp_IDErrors_V2] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




			 	
TRUNCATE TABLE [Reporting].[MULTI].[t_IDErrors]

--Implement ID checks for each registry and combine results

IF OBJECT_ID('tempdb..#Subjects') IS NOT NULL BEGIN DROP TABLE #Subjects END

SELECT Registry,
       SiteID,
	   CAST(SubjectID AS nvarchar) AS SubjectID,
	   IDErrorType,
	   Importance
INTO #Subjects
FROM (

--RA102
SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance] 
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry

FROM [Reporting].[RA102].[v_op_VisitLog] VL 
LEFT JOIN [Reporting].[RA102].[t_op_109_DataEntryLag] FE ON CAST(FE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE SUBSTRING(CAST(VL.SubjectID AS nvarchar), 1, 4) <> VL.SiteID
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[RA102].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[RA102].[t_op_109_DataEntryLag] FE ON CAST(FE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND FE.VisitType LIKE 'Enrollment%'
 WHERE CAST(SUBSTRING(CAST(VL.SubjectID as nvarchar), 5, 2) as INT) <> SUBSTRING(cast(VL.ProviderID as nvarchar), 1, 2)
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION 

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'ID Length' AS [IDErrorType]
	  ,5 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[RA102].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[RA102].[t_op_109_DataEntryLag] FE ON CAST(FE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE LEN(VL.SubjectID) <> 11
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

--PSA400---
SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Registry ID' AS [IDErrorType]
	  ,2 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[PSA400].[v_op_VisitLog] VL 
LEFT JOIN [Reporting].[PSA400].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE LEFT(VL.SubjectID, 1) <> 3
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  -- SITE ID ERROR for PSO
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.[FirstEntry]
FROM [Reporting].[PSA400].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSA400].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
---- SiteID = 1 is Errored. Substring expresion. Need to remove precending 00s from '001'
WHERE CAST(SUBSTRING(VL.SubjectID, 2, 3) as nvarchar(10)) <> CAST(VL.SiteID AS nvarchar(10))
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'
-----

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  --Error in Provider ID
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry

FROM [Reporting].[PSA400].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSA400].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS VARCHAR) AND FE.VisitType LIKE 'Enrollment%'
WHERE CAST(SUBSTRING(CAST(VL.SubjectID as nvarchar), 5, 2) AS varchar) <> SUBSTRING(cast(VL.ProviderID as varchar), 1, 2)
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION 

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'ID Length' AS [IDErrorType]
	  ,5 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[PSA400].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSA400].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE LEN(VL.SubjectID) <> 10
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

--PSO500
SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Registry ID' AS [IDErrorType]
	  ,2 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.CompletionDate AS FirstEntry
FROM [Reporting].[PSO500].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE LEFT(VL.SubjectID, 1) <> '4'
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.CompletionDate AS FirstEntry
FROM [Reporting].[PSO500].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE SUBSTRING(CAST(VL.SubjectID AS varchar), 2, 3) <> CAST(SiteID AS varchar)
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.CompletionDate AS FirstEntry

FROM [Reporting].[PSO500].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE VL.Visittype='Enrollment'
AND CAST(SUBSTRING(CAST(VL.SubjectID as varchar), 5, 2) as varchar) <> SUBSTRING(cast(VL.ProviderID as varchar), 1, 2)
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,cast(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'ID Length' AS [IDErrorType]
	  ,5 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.CompletionDate AS FirstEntry
FROM [Reporting].[PSO500].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE LEN(VL.SubjectID) <> 11
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

--IBD600
SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[IBD600].[v_op_VisitLog] VL
LEFT JOIN [IBD600].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE CAST(SUBSTRING(CAST(VL.SubjectID AS nvarchar), 1, 4) AS varchar) <> CAST(VL.SiteID AS varchar)
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[IBD600].[v_op_VisitLog] VL
LEFT JOIN [IBD600].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE VL.VisitType='Enrollment'
AND cast(SUBSTRING(CAST(VL.SubjectID AS nvarchar), 5, 3) as varchar) NOT IN (SELECT DISTINCT cast([ProviderIDIBD600] as varchar) FROM [Salesforce].[dbo].[registryContact] RC WHERE RC.Registry='Inflammatory Bowel Disease (IBD-600)' AND cast(RC.contact_SiteNumber as varchar)=CAST(VL.SiteID AS varchar) AND RC.[ProviderIDIBD600] IS NOT NULL)
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'ID Length' AS [IDErrorType]
	  ,5 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[IBD600].[v_op_VisitLog] VL
LEFT JOIN [IBD600].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE LEN(VL.SubjectID) <> 11
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

--MS700
SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Site ID' AS [IDErrorType]
	  ,3 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry

FROM [Reporting].[MS700].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE VL.VisitType='Enrollment'
AND SUBSTRING(CAST(VL.SubjectID AS varchar), 1, 4) <> CAST(VL.SiteID AS varchar)
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Provider ID' AS [IDErrorType]
	  ,4 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[MS700].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE cast(SUBSTRING(CAST(VL.SubjectID AS varchar), 5, 3)as varchar) NOT IN (SELECT cast([ProviderIDMS700] as varchar) FROM [Salesforce].[dbo].[registryContact] RC WHERE RC.contact_SiteNumber=CAST(VL.SiteID AS varchar)) 
AND VL.VisitType='Enrollment'
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectIDError AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'Non-Numeric ID' AS [IDErrorType]
	  ,1 AS [Importance] 
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[MS700].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE VL.VisitType='Enrollment'
AND ISNULL(SubjectIDError, '')<>''
AND VL.SiteID<>1440
AND VL.SiteStatus='Active'

UNION

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectIDError as nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'ID Length' AS [IDErrorType]
	  ,1 AS [Importance] 
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[MS700].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE VL.VisitType='Enrollment'
AND LEN(SubjectIDError)<>11
AND VL.SiteID<>1440
AND VL.SiteStatus='Active'

UNION 

SELECT DISTINCT VL.Registry
	  ,VL.RegistryName
	  ,VL.SiteID
	  ,CAST(VL.SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(VL.ProviderID AS varchar) AS ProviderID
	  ,'ID Length' AS [IDErrorType]
	  ,5 AS [Importance]
	  ,VL.VisitDate AS EnrollmentDate
	  ,FE.FirstEntry
FROM [Reporting].[MS700].[v_op_VisitLog] VL
LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] FE ON CAST(FE.SubjectID AS varchar)=CAST(VL.SubjectID AS varchar) AND FE.VisitType LIKE 'Enrollment%'
WHERE VL.VisitType='Enrollment'
AND LEN(VL.SubjectID) <> 11
AND VL.SiteID<>1440
AND VL.SiteStatus='Active'

) S

/*Obtain First Entry Dates from respective DE Lag reports only for subjects identified via the error checks
and combine results. All Subject IDs identified via the ID checks are converted to NVARCHAR before linking to
the Subject IDs on the DE Lag reports. In addition, if the ID has dashes, dashes are eliminated before converting to NVARCHAR. */

IF OBJECT_ID('tempdb.dbo.#FirstEntries') IS NOT NULL BEGIN DROP TABLE #FirstEntries END

SELECT * 
INTO #FirstEntries
FROM (

SELECT 'IBD-600' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [IBD600].[t_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(S.SubjectID AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR)
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'MS-700' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [MS700].[t_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(REPLACE(S.SubjectID,'-','') AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR)
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'AD-550' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [AD550].[t_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(REPLACE(S.SubjectID,'-','') AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR)
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'PSA-400' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [PSA400].[t_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(REPLACE(S.SubjectID,'-','') AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR)
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'PSO-500' AS [Registry], DE.[SiteNumber] AS [SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], DE.[CompletionDate] AS [FirstEntry] --SELECT *
FROM [PSO500].[v_op_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(REPLACE(S.SubjectID,'-','') AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR)
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'RA-100' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], DE.[CompletionDate] AS [FirstEntry] --SELECT *
FROM [RA100].[t_op_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(REPLACE(S.SubjectID,'-','') AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR)
WHERE VisitType LIKE '%Enrollment%'

UNION

SELECT 'RA-102' AS [Registry], DE.[SiteID], CAST(DE.SubjectID AS NVARCHAR(20)) AS [SubjectID], [VisitType], [VisitDate], [FirstEntry] --SELECT *
FROM [RA102].[t_op_109_DataEntryLag] DE INNER JOIN #SUBJECTS S ON CAST(REPLACE(S.SubjectID,'-','') AS NVARCHAR) = CAST(DE.SubjectID AS NVARCHAR(20))
WHERE VisitType LIKE '%Enrollment%'

--NEED TO ADD AD DE LAG
) FE

--Create full table of all ID Errors with First Entry Dates

IF OBJECT_ID('tempdb.dbo.#Errors') IS NOT NULL BEGIN DROP TABLE #Errors END

SELECT * 
INTO #Errors
FROM (

SELECT DISTINCT 
	   S1.[Registry]
	  ,S1.[SiteID]
      ,S1.[SubjectID]
	  ,S1.[IDErrorType]
	  ,FE.[FirstEntry] AS [FirstEntryDate]

FROM #SUBJECTS S1 
LEFT JOIN #FirstEntries FE ON  CAST(REPLACE(S1.SubjectID,'-','') AS NVARCHAR) = CAST(FE.SubjectID AS NVARCHAR)
WHERE S1.SiteID NOT LIKE '99%'
--AND S1.[SubjectID] <> ''
) E

--Obtain list of associated Provider IDs for each identified Subject ID with an error

IF OBJECT_ID('tempdb.dbo.#Providers') IS NOT NULL BEGIN DROP TABLE #Providers END

SELECT Registry,
       CAST(SubjectID AS varchar) AS SubjectID,
	   CAST(ProviderID AS varchar) AS ProviderID,
	   EnrollmentDate,
	   SubjectIDError
INTO #Providers
FROM (

SELECT
	 'AD-550' AS Registry
	,CAST(SubjectID AS varchar) AS SubjectID
	,CAST(ProviderID AS varchar) AS ProviderID
	,VisitDate AS [EnrollmentDate]
	,SubjectIDError
FROM [AD550].[t_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'IBD-600' AS Registry
	,CAST(SubjectID AS varchar) AS SubjectID
	,CAST(ProviderID AS varchar) AS ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [IBD600].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'MS-700' AS Registry
	,CAST(SubjectID AS varchar) AS SubjectID
	,CAST(ProviderID AS varchar) AS ProviderID
	,VisitDate AS [EnrollmentDate]
	,SubjectIDError -- SELECT *
FROM [MS700].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'PSA-400' AS Registry
	,CAST(SubjectID AS varchar) AS SubjectID
	,CAST(ProviderID AS varchar) AS ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [PSA400].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'PSO-500' AS Registry
	,CAST(SubjectID AS varchar) AS SubjectID
	,CAST(ProviderID AS varchar) AS ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [PSO500].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

UNION

SELECT
	 'RA-102' AS Registry
	,CAST(SubjectID AS varchar) AS SubjectID
	,CAST(ProviderID AS varchar) AS ProviderID
	,VisitDate AS [EnrollmentDate]
	,NULL AS [SubjectIDError]
FROM [RA102].[v_op_VisitLog]
WHERE [VisitType] = 'Enrollment'

) P

--Have all identified ID Error types concatenated into a single cell for each identified Subject ID with an error

INSERT INTO [Reporting].[MULTI].[t_IDErrors]

SELECT DISTINCT
	 E.[Registry]
	,E.[SiteID]
	,CAST(E.[SubjectID] AS NVARCHAR) AS [SubjectID]
	,P.[ProviderID]
	,LTRIM(STUFF((SELECT ', ' + [IDErrorType] FROM #SUBJECTS S WHERE S.[SubjectID] = E.[SubjectID] ORDER BY [Registry], [SiteID], [Importance] FOR XML PATH('')),1,1, '')) AS [IDErrorType]
	,P.[EnrollmentDate]
	,E.[FirstEntryDate]
FROM #ERRORS E
LEFT JOIN #PROVIDERS P ON P.Registry = E.Registry AND (CAST(P.SubjectID AS NVARCHAR) = CAST(E.SubjectID AS NVARCHAR) OR CAST(P.SubjectIDError AS NVARCHAR) = CAST(E.SubjectID AS NVARCHAR) OR CAST(REPLACE(E.SubjectID,'-','') AS NVARCHAR) = CAST(P.SubjectID AS NVARCHAR) )
WHERE [EnrollmentDate] <> ''
AND E.[SubjectID] NOT IN (SELECT [SubjectID] FROM [MULTI].[t_op_IDErrors_ExcludedSubjects])


END

--SELECT REPLACE('7016-140-0026','-','')







GO
