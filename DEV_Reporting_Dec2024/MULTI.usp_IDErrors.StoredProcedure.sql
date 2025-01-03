USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_IDErrors]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--=============================================
--Author: Kevin Soe
--Created date: 13-Nov-2020
--Description:	Create table for ID Errors Report
--Updated by Kaye Mowrey on 02June2021 using Subject ID Errors Review WI and Visit Logs instead of subject tables
--=============================================


/*

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[t_op_SubjectIDErrors](
	[Registry] [nvarchar](255) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[SiteID] [nvarchar] (10) NULL,
	[SubjectID] [nvarchar](25) NULL,
	[ProviderID] [nvarchar] (10) NULL,
	[IDErrorType] [nvarchar](300) NULL,
	[EnrollmentDate] [date] NULL,
	[FirstEntryDate] [date] NULL,
	[EnrollmentOnly] [nvarchar](25) NULL
) ON [PRIMARY]

GO

*/

CREATE PROCEDURE [MULTI].[usp_IDErrors] AS

BEGIN
	SET NOCOUNT ON;

--Determine deleted subjects from IBM Registries

IF OBJECT_ID('tempdb..#Deleted') IS NOT NULL BEGIN DROP TABLE #Deleted END

SELECT SiteID,
       SubjectID
INTO #Deleted
FROM
(
SELECT SITENUM AS SiteID,
       CAST(SUBNUM AS nvarchar) AS SubjectID
FROM [MERGE_SPA].[dbo].[DAT_SUB] DS
WHERE [DELETED] = 't'

UNION 

SELECT SITENUM AS SiteID,
       CAST(SUBNUM AS nvarchar) AS SubjectID
FROM [MERGE_RA_Japan].[dbo].[DAT_SUB] DS
WHERE [DELETED] = 't'

UNION

SELECT SITENUM AS SiteID,
       CAST(SUBNUM AS nvarchar) AS SubjectID
FROM [MERGE_IBD].[dbo].[DAT_SUB] DS
WHERE [DELETED] = 't'
) DeletedSubjects


--Determine subjects that have a follow up or exit visit after enrollment

IF OBJECT_ID('tempdb..#FUExit') IS NOT NULL BEGIN DROP TABLE #FUExit END

SELECT *
INTO #FUExit
FROM 
(SELECT ROW_NUMBER() OVER (PARTITION BY ARVL.RegistryName, ARVL.SiteID, ARVL.SubjectID ORDER BY ARVL.RegistryName, ARVL.SiteID, ARVL.SubjectID, ARVL.VisitDate DESC, ARVL.VisitType) AS ROWNUM
      ,ARVL.Registry
      ,ARVL.RegistryName
      ,ARVL.SiteID
      ,CAST(ARVL.SubjectID AS nvarchar) AS SubjectID
	  ,ARVL.VisitType
	  ,ARVL.VisitDate
	  ,CASE WHEN RS.currentStatus='Closed / Completed' THEN 'Closed site'
	   WHEN ARVL.VisitType='Exit' THEN 'Subject Exit'
	   WHEN ARVL.VisitType='Follow-up' THEN 'Follow-up visit'
	   WHEN ARVL.VisitType='Enrollment' THEN 'Enrollment only'
	   ELSE ''
	   END AS EnrollmentOnly

FROM [Reporting].[dbo].[v_AllRegistryVisitLogs] ARVL 
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]=ARVL.RegistryName AND ISNULL(RS.siteNumber, 0)=ARVL.SiteID
WHERE ARVL.VisitType IN ('Enrollment', 'Follow-up', 'Exit')) A
WHERE ROWNUM=1



--Set up pool of provider ID's for PSA400 from Salesforce

IF OBJECT_ID('tempdb..#SFProviderIDs') IS NOT NULL BEGIN DROP TABLE #SFProviderIDs END

SELECT DISTINCT CAST(contact_SiteNumber AS int) AS SiteID, 
[ProviderIDRA100SPA400] AS ProviderID ,
Registry
INTO #SFProviderIDs
FROM [Salesforce].[dbo].[registryContact] 
WHERE --Status='Approved / Active' AND
[ProviderIDRA100SPA400] IS NOT NULL 
AND [contact_SiteNumber] IS NOT NULL
AND Registry='Psoriatic Arthritis & Spondyloarthritis (PSA-400)'

--SELECT * FROM #SFProviderIDs ORDER BY SiteID, ProviderID


--Get listing of Subject ID errors at enrollment visits

IF OBJECT_ID('tempdb..#Subjects') IS NOT NULL BEGIN DROP TABLE #Subjects END

SELECT DISTINCT Registry
      ,RegistryName
	  ,SiteID
	  ,CAST(SubjectID AS nvarchar(25)) AS SubjectID
	  ,CAST(ProviderID as varchar) AS ProviderID
	  ,IDErrorType
	  ,Importance
	  ,EnrollmentDate
	  ,FirstEntry
INTO #Subjects
FROM 
(

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
WHERE SubjectID NOT IN (SELECT SubjectID FROM #Deleted D WHERE D.SiteID=S.SiteID AND CAST(D.SubjectID as varchar)=CAST(S.SubjectID AS varchar))

--Have all identified ID Error types concatenated into a single cell for each identified Subject ID with an error

TRUNCATE TABLE [Reporting].[dbo].[t_op_SubjectIDErrors]

INSERT INTO [Reporting].[dbo].[t_op_SubjectIDErrors]

SELECT DISTINCT S.[Registry]
    ,S.RegistryName
	,S.SiteID
	,CAST(S.SubjectID AS NVARCHAR(25)) AS [SubjectID]
	,S.[ProviderID]
	,LTRIM(STUFF((SELECT ', ' + [IDErrorType] FROM #SUBJECTS S2 WHERE S2.[SubjectID] = S.[SubjectID] ORDER BY [Registry], [SiteID], [Importance] FOR XML PATH('')),1,1, '')) AS [IDErrorType]
	,S.EnrollmentDate
	,S.FirstEntry
	,FU.EnrollmentOnly
FROM #Subjects S
LEFT JOIN #FUExit FU ON FU.Registry=S.Registry AND CAST(FU.SubjectID AS nvarchar(25))=CAST(S.SubjectID AS nvarchar(25))
WHERE ISNULL(EnrollmentDate, '') <> ''


--SELECT * FROM [Reporting].[dbo].[t_op_SubjectIDErrors] ORDER BY Registry, SiteID, SubjectID



END


GO
