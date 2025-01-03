USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_RegistryCounts]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:	Kevin Soe, Create date: 9-Jan-2022
-- Updated date: 28-May-2024 DG
-- Description:	Update table for Registry Counts with a new download date row for each registry
-- =============================================

CREATE PROCEDURE [MULTI].[usp_op_RegistryCounts] AS

/*

REMOVING RA-100 FROM THIS LISTING. DATA IS IN DATA WAREHOUSE.

--Use #RAFullVisitLog to combine current live visit log with static visit log for RAMP Sites

IF OBJECT_ID('tempdb.dbo.#RAFullVisitLog') IS NOT NULL BEGIN DROP TABLE #RAFullVisitLog END

SELECT
	 [SiteID]
	,[SubjectID]
	,[VisitDate]
	,[VisitType]

INTO #RAFullVisitLog 
FROM [RA100].[v_op_VisitLog]
UNION ALL
SELECT 
	 [SiteID]
	,[SubjectID]
	,[VisitDate]
	,[VisitType]
FROM [RA100].[t_op_RAMPVisitLogClosedSites]

--Use #RATerminalExits to determine list of terminal exits (Exit Visit = Last Visit for Patient)

IF OBJECT_ID('tempdb.dbo.#RATerminalExits') IS NOT NULL BEGIN DROP TABLE #RATerminalExits END

SELECT 
	 [SiteID]
	,[SubjectID]
	,[VisitDate]
	,[VisitType]
INTO #RATerminalExits 
FROM (SELECT
	 ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitType]) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,CASE WHEN V.[VisitType] LIKE '%Exit%' THEN 'Exit' ELSE V.[VisitType] END AS [VisitType]
	,V.[VisitDate]

FROM #RAFullVisitLog V) R
WHERE [Row] = 1
AND [VisitType] LIKE '%Exit%'

--Use #RAVisitLogTerminalExitsOnly to create a full visit log where only Terminal Exits are listed on the log.

IF OBJECT_ID('tempdb.dbo.#RAVisitLogTerminalExitsOnly') IS NOT NULL BEGIN DROP TABLE #RAVisitLogTerminalExitsOnly END

SELECT * 
INTO #RAVisitLogTerminalExitsOnly
FROM #RAFullVisitLog
WHERE [VisitType] <> 'Exit'
UNION 
SELECT * 
FROM #RATerminalExits


--Use #RAAEQCListing to combine current live TAE QC Listing with static TAE QC Listing for RAMP Sites
--VisitID and FormID from TAE QC Listing view need to be excluded to insert without running into an error

IF OBJECT_ID('tempdb.dbo.#RATAEQCListing') IS NOT NULL BEGIN DROP TABLE #RATAEQCListing END

SELECT 
	 [SiteID]
	,[SubjectID]
	,[VisitName]
	,[ProviderID]
	,[EventType]
	,[Event]
	,[EventOnsetDate]
	,[FollowupVisitDate]
	,[EventOutcome]
	,[Hospitalized]
	,[ConfirmedEvent]
	,[IfNoEvent]
	,[Page1CRFStatus]
	,[Page2CRFStatus]
	,[TAEISAttest]
	,[TAEISAttestDate]
	,[Page1LastModDate]
	,[Page2LastModDate]
	,[BiologicAtEvent]
	,[BiologicAtEventOther]
	,[SourceDocuments]
	,[FileAttached]
	,[AcknowledgementofReceipt]
	,[ReasonNoSource]
INTO #RATAEQCListing
FROM [RA100].[v_pv_TAEQCListing]

INSERT INTO #RATAEQCListing
SELECT *
FROM [RA100].[t_op_RAMPTAEQCListingClosedSites]

*/


---------------------------------------------------------------------------------------------------------
--Use #Visits to get total counts of all ENs, FUs, and Exits

IF OBJECT_ID('tempdb.dbo.#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT DISTINCT
	'AD' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

INTO #Visits
FROM [AD550].[t_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
AND [SiteID] <> '1440'

UNION

SELECT DISTINCT
	'AA' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'

UNION

SELECT DISTINCT
	'IBD' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM [IBD600].[v_op_VisitLog_V2] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()

UNION

SELECT DISTINCT
	'MS' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM [MS700].[v_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] <> '1440'

UNION

SELECT DISTINCT
	'SPHERES' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM [NMO750].[t_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] <> '1440'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT DISTINCT
	'PSA' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM [PSA400].[v_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'

UNION

SELECT DISTINCT
	'PSO' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM [PSO500].[v_op_VisitLog] V
WHERE[VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'

UNION

/*  REMOVING RA-100 AS DATA IS IN DATA WAREHOUSE

SELECT DISTINCT
	'RA US' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]

FROM #RAVisitLogTerminalExitsOnly V --Use RA Visit Log with Terminal Exits because report definitions indicate that only Temrinal Exits will be counted
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'

UNION
*/

SELECT DISTINCT
	'RA Japan' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
FROM [RA102].[v_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'

UNION

SELECT DISTINCT
	'GPP' AS [Registry]
	,VISNAME AS VisitType
	,COUNT(*) OVER (PARTITION BY [VISNAME]) AS [VisitCounts]

FROM [GPP510].[v_op_VisitLog_simple] V
WHERE 1=1
AND [VISDAT] <> ''
AND [VISDAT] <= GETDATE()


--Use #TAEs to get total counts of all TAEs
---------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#TAEs') IS NOT NULL BEGIN DROP TABLE #TAEs END

SELECT 
	 'AD' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEs]

INTO #TAEs
FROM [AD550].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus = 'Confirmed event'
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT 
	 'AA' AS [Registry]
	,COUNT([SubjectID]) AS [TAEs]

FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing] T
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT 
	 'IBD' AS [Registry]
	,COUNT([SubjectID]) AS [TAEs]
FROM [IBD600].[v_pv_TAEQCListing] T
WHERE EventReportStatus IN ('Confirmed event', 'Report of pregnancy')


UNION

SELECT 
	 'MS' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEs]

FROM [MS700].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus IN ('Confirmed event', 'Report of pregnancy')
AND [SiteID] <> '1440'

UNION

SELECT 
	 'SPHERES' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEs]

FROM [NMO750].[t_pv_TAEQCListing] T
WHERE EventConfirmationStatus = 'Confirmed event'
AND [SiteID] <> '1440'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT 
	 'PSA' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEs]

FROM [PSA400].[t_PV_TAEQC] T
WHERE [Event Confirmation Status/Can you confirm the Event?] IN ('Confirmed event', 'Report of pregnancy')
AND [Site ID] NOT LIKE '99%'

UNION

SELECT 
	 'PSO' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEs]

FROM [PSO500].[v_pv_TAEQCListing] T
WHERE [ReportType] IN ('Confirmed event report', 'Report of pregnancy')
AND [SiteID] NOT LIKE '99%'

/*
REMOVING US-100 AS DATA IS IN DATA WAREHOUSE

UNION

SELECT 
	 'RA US' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEs]

FROM #RATAEQCListing T
WHERE [ConfirmedEvent] = 'Yes'
AND [SiteID] NOT LIKE '99%'
*/

UNION

SELECT 
	 'RA Japan' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEs]

FROM [RA102].[t_pv_TAEQC] T
WHERE [Report Type] IN ('Confirmed event', 'Report of pregnancy')
AND [Site ID] NOT LIKE '99%'

UNION

SELECT 
	 'GPP' AS [Registry]
	,COUNT(SUBNUM) AS [TAEs]

FROM [GPP510].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus = 'Confirmed event'

--Use #TAEDocs to get total counts of all TAEs that have had their supporting docs reviewed by PV
-----------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#TAEDocs') IS NOT NULL BEGIN DROP TABLE #TAEDocs END

SELECT 
	 'AD' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEDocs]

INTO #TAEDocs
FROM [AD550].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus = 'Confirmed event'
AND SupportDocsApproved = 'Yes'
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT 
	 'AA' AS [Registry]
	,COUNT([SubjectID]) AS [TAEDocs]

FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus = 'Confirmed event'
AND SupportDocsApproved = 'Yes'
AND SiteID NOT LIKE '99%'

UNION

SELECT 
	 'IBD' AS [Registry]
	,COUNT([SubjectID]) AS [TAEDocs]

FROM [IBD600].[v_pv_TAEQCListing] T
WHERE EventReportStatus IN ('Confirmed event', 'Report of pregnancy')
AND SupportingDocumentsReceived = 'Yes'

UNION

SELECT 
	 'MS' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEDocs]

FROM [MS700].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus IN ('Confirmed event', 'Report of pregnancy')
AND SupportingDocsApproved = 'Yes'
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT 
	 'SPHERES' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEDocs]

FROM [NMO750].[t_pv_TAEQCListing] T
WHERE EventConfirmationStatus = 'Confirmed event'
AND SupportDocsApproved = 'Yes'
AND [SiteID] <> '1440'
AND [SiteID] NOT LIKE '99%'

UNION

SELECT 
	 'PSA' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEDocs]

FROM [PSA400].[t_PV_TAEQC] T
WHERE [Event Confirmation Status/Can you confirm the Event?] IN ('Confirmed event', 'Report of pregnancy')
AND [Supporting documents received by Corrona?] = 'YES'
AND [Site ID] NOT LIKE '99%'

UNION

SELECT 
	 'PSO' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEDocs]

FROM [PSO500].[v_pv_TAEQCListing] T
WHERE [ReportType] IN ('Confirmed event report', 'Report of pregnancy')
AND [DocsReceivedByCorrona] = 1
AND [SiteID] NOT LIKE '99%'

UNION

/*
REMOVING RA-100 AS DATA IS IN DATAWAREHOUSE

SELECT 
	 'RA US' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEDocs]

FROM #RATAEQCListing T
WHERE [ConfirmedEvent] = 'Yes'
AND [AcknowledgementofReceipt] = 1
AND [SiteID] NOT LIKE '99%'

UNION
*/

SELECT 
	 'RA Japan' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEDocs]

FROM [RA102].[t_pv_TAEQC] T
WHERE [Report Type] IN ('Confirmed event', 'Report of pregnancy')
AND [Supporting documents received by Corrona?] = 'YES'
AND [Site ID] NOT LIKE '99%'

UNION

SELECT 
	 'GPP' AS [Registry]
	,COUNT(SUBNUM) AS [TAEDocs]

FROM [GPP510].[t_pv_TAEQCListing] T
WHERE ConfirmationStatus = 'Confirmed event'
AND suppdocsUpload = 'Yes'


--Use #LastVisits to create list of all Non-exited patients for each registry. 
--The subquery for each registry will give a row number of 1 for the last visit for each subject.
--The main query for each registry will return the most current visit for each subject.
--The main query will exclude subjects who's most recent visit is an Exit Visit (Terminal Exit for RA).
---------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#LastVisits') IS NOT NULL BEGIN DROP TABLE #LastVisits END

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]
INTO #LastVisits

FROM (
SELECT 
	'AD' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM [AD550].[t_op_VisitLog] V
WHERE [SFSiteStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'AA' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=V.[SiteID] AND RS.[name]='Alopecia Areata (AA-560)'
WHERE [currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'IBD' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,CASE WHEN V.[VisitType] LIKE '%Exit%' THEN 'Exit' ELSE V.[VisitType] END AS [VisitType]
	,V.[VisitDate]

FROM [IBD600].[v_op_VisitLog_V2] V
LEFT JOIN [IBD600].[v_SiteStatus] S ON V.SiteID = S.SiteID
WHERE S.[SFSiteStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()) V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'MS' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM  [MS700].[v_op_VisitLog] V
LEFT JOIN [MS700].[v_SiteStatus] S ON V.SiteID = S.SiteID
WHERE S.[SFSiteStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND V.[SiteID] NOT LIKE '1440%'
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'SPHERES' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM [NMO750].[t_op_VisitLog] V
WHERE [SFSiteStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'PSA' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [CalcVisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM [PSA400].[v_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)'
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'PSO' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [CalcVisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM [PSO500].[v_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Psoriasis (PSO-500)'
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

/*
REMOVING RA-100 AS DATA IS IN DATA WAREHOUSE

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]
   --SELECT *
FROM (
SELECT 
	'RA US' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitType] ASC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM #RAFullVisitLog V
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Rheumatoid Arthritis (RA-100,02-021)'
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION
*/

SELECT DISTINCT
	 V.[Registry]
	,V.[SiteID]
	,CAST(V.[SubjectID] AS nvarchar) AS [SubjectID]
	,V.[VisitType]
	,MAX(V.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'RA Japan' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [CalcVisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]

FROM [RA102].[v_op_VisitLog] V
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Japan RA Registry (RA-102)'
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

UNION

SELECT DISTINCT
	 V2.[Registry]
	,V2.[SiteID]
	,CAST(V2.[SubjectID] AS nvarchar) AS [SubjectID]
	,V2.[VisitType]
	,MAX(V2.[VisitDate]) AS [VisitDate]
	,CAST(DATEDIFF(DD, MAX(V2.VisitDate), GetDate()) AS int) AS [DaysSinceLastVisit]

FROM (
SELECT 
	'GPP' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[sitenum], V.[SUBNUM] ORDER BY V.[VISDAT] DESC, [Visitseq] DESC) AS [Row]
	,V.[SITENUM] AS SiteID
	,V.[SUBNUM] as SubjectID
	,V.[VISNAME] AS [VisitType]
	,V.[VISDAT] AS VisitDate

FROM [GPP510].[v_op_VisitLog_simple] V
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SITENUM = S.siteNumber AND S.[name] ='Generalized Pustular Psoriasis (GPP-510)'
WHERE 1=1
--AND [SFSiteStatus] <> 'Closed / Completed'
AND [VISDAT] <> ''
AND [VISDAT] <= GETDATE()

) V2
WHERE V2.[Row] = 1 AND V2.[VisitType] <> 'Exit'
GROUP BY V2.[Registry], V2.[SiteID], V2.[SubjectID], V2.[VisitType]


--Use #ActivePts to get count of active patients by filtering #LastVisits to only PTs with <= 18 Months Since Last Visit
---------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#ActivePts') IS NOT NULL BEGIN DROP TABLE #ActivePts END

SELECT 
	 [Registry]
	,COUNT([SubjectID]) AS [ActivePts]
INTO #ActivePts
FROM #LastVisits
WHERE [DaysSinceLastVisit] <= 540
GROUP BY [Registry]

--Use #InactivePts to get count of inactive patients by filtering #LastVisits to only PTs with > 18 Months Since Last Visit
---------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#InactivePts') IS NOT NULL BEGIN DROP TABLE #InactivePts END

SELECT 
	 [Registry]
	,COUNT([SubjectID]) AS [InactivePts]
INTO #InactivePts
FROM #LastVisits
WHERE [DaysSinceLastVisit] > 540
GROUP BY [Registry]


--Combine all counts and insert into the table that the SSRS report will use as its data source
---------------------------------------------------------------------------------------------------------
		  
INSERT INTO MULTI.t_op_RegistryCounts

SELECT DISTINCT
	 V.[Registry]
	,CASE WHEN A.[ActivePts] IS NULL THEN 0 ELSE A.[ActivePts] END AS [ActivePts]
	,CASE WHEN I.[InactivePts] IS NULL THEN 0 ELSE I.[InactivePts] END AS [InactivePts]
	,CASE WHEN E.[VisitCounts] IS NULL THEN 0 ELSE E.[VisitCounts] END AS [ENVisits]
	,CASE WHEN F.[VisitCounts] IS NULL THEN 0 ELSE F.[VisitCounts] END AS [FUVisits]
	,CASE WHEN X.[VisitCounts] IS NULL THEN 0 ELSE X.[VisitCounts] END AS [EXVisits]
	,T.[TAEs]
	,D.[TAEDocs]
	,CAST(GETDATE() AS DATE) [DownloadDate]
FROM #Visits V
LEFT JOIN #TAEs T ON V.Registry = T.Registry
LEFT JOIN #TAEDocs D ON V.Registry = D.Registry
LEFT JOIN #ActivePts A ON V.Registry = A.Registry
LEFT JOIN #InactivePts I ON V.Registry = I.Registry
LEFT JOIN
(SELECT Registry, VisitCounts FROM #Visits WHERE VisitTYpe = 'Enrollment') E ON V.Registry = E.Registry
LEFT JOIN
(SELECT Registry, VisitCounts FROM #Visits WHERE VisitTYpe = 'Follow-Up') F ON V.Registry = F.Registry
LEFT JOIN
(SELECT Registry, VisitCounts FROM #Visits WHERE VisitTYpe LIKE '%Exit%') X ON V.Registry = X.Registry

--SELECT * FROM MULTI.t_op_RegistryCounts ORDER BY Registry, DownloadDate

GO
