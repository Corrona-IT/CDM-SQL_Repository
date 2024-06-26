USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_RegistryCounts]    Script Date: 5/1/2024 1:26:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:	Kevin Soe
-- Create date: 9-Jan-2022
-- Description:	Update table for Registry Counts with a new download date row for each registry
-- =============================================
			  --EXECUTE
CREATE PROCEDURE [MULTI].[usp_op_RegistryCounts] AS
--SELECT * FROM MULTI.t_op_RegistryCounts

--Use #RAFullVisitLog to combine current live visit log with static visit log for RAMP Sites

IF OBJECT_ID('tempdb.dbo.#RAFullVisitLog') IS NOT NULL BEGIN DROP TABLE #RAFullVisitLog END

SELECT
	 [SiteID]
	,[SubjectID]
	,[VisitDate]
	,[VisitType]
   --SELECT * FROM
INTO #RAFullVisitLog 
   --SELECT *
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
   --SELECT *
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
   --SELECT *
FROM [RA100].[v_pv_TAEQCListing]
INSERT INTO #RATAEQCListing
SELECT *
FROM [RA100].[t_op_RAMPTAEQCListingClosedSites]


--ALTER TABLE #RATAEQCListing
--DROP COLUMN VisitId, FormID;
---
----User #RAFullTAEQCListing to combine current live TAE QC Listing with static TAE QC Listing for RAMP Sites
--
--IF OBJECT_ID('tempdb.dbo.#RAFullTAEQCListing') IS NOT NULL BEGIN DROP TABLE #RAFullTAEQCListing END
--
--SELECT *
--   --SELECT * FROM
--INTO #RAFullTAEQCListing
--   --SELECT *
--FROM #RATAEQCListing
--UNION
--SELECT *
--FROM [RA100].[t_op_RAMPTAEQCListingClosedSites]

---------------------------------------------------------------------------------------------------------
--Use #Visits to get total counts of all ENs, FUs, and Exits

IF OBJECT_ID('tempdb.dbo.#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT DISTINCT
	'AD' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
   --SELECT * FROM
INTO #Visits
	--SELECT *
FROM [AD550].[t_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
AND [SiteID] <> '1440'
--AND [SFSiteStatus] <> 'Closed / Completed'

UNION

SELECT DISTINCT
	'AA' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
	--SELECT *
FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
--AND [SFSiteStatus] <> 'Closed / Completed'

UNION

SELECT DISTINCT
	'IBD' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
	--SELECT *
FROM [IBD600].[v_op_VisitLog_V2] V
		--SELECT * FROM
--LEFT JOIN [IBD600].[v_SiteStatus] S ON V.SiteID = S.SiteID
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
--AND [SFSiteStatus] <> 'Closed / Completed'

UNION

SELECT DISTINCT
	'MS' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
	--SELECT *
FROM [MS700].[v_op_VisitLog] V
		--SELECT * FROM
--LEFT JOIN [MS700].[v_SiteStatus] S ON V.SiteID = S.SiteID
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] <> '1440'
--AND [SFSiteStatus] <> 'Closed / Completed'

UNION

SELECT DISTINCT
	'SPHERES' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
   --SELECT *
FROM [NMO750].[t_op_VisitLog] V
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] <> '1440'
AND [SiteID] NOT LIKE '99%'
--AND [SFSiteStatus] <> 'Closed / Completed'

UNION

SELECT DISTINCT
	'PSA' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
   --SELECT *
FROM [PSA400].[v_op_VisitLog] V
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)'

UNION

SELECT DISTINCT
	'PSO' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
   --SELECT *
FROM [PSO500].[v_op_VisitLog] V
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE[VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Psoriasis (PSO-500)'

UNION

SELECT DISTINCT
	'RA US' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
   --SELECT *
FROM #RAVisitLogTerminalExitsOnly V --Use RA Visit Log with Terminal Exits because report definitions indicate that only Temrinal Exits will be counted
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Rheumatoid Arthritis (RA-100,02-021)'

UNION

SELECT DISTINCT
	'RA Japan' AS [Registry]
	,[VisitType]
	,COUNT(*) OVER (PARTITION BY VisitType) AS [VisitCounts]
   --SELECT *
FROM [RA102].[v_op_VisitLog] V
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Japan RA Registry (RA-102)'



--Use #TAEs to get total counts of all TAEs
---------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#TAEs') IS NOT NULL BEGIN DROP TABLE #TAEs END

SELECT 
	 'AD' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEs]
   --SELECT * FROM
INTO #TAEs
	--SELECT *
FROM [AD550].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.SiteID = S.siteNumber
WHERE ConfirmationStatus = 'Confirmed event'
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Atopic Dermatitis (AD-550)'

UNION

SELECT 
	 'AA' AS [Registry]
	,COUNT([SubjectID]) AS [TAEs]
	--SELECT *
FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[Site ID] = S.siteNumber
WHERE [ConfirmationStatus] = 'Confirmed event'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Inflammatory Bowel Disease (IBD-600)'

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
	--SELECT *
FROM [MS700].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.SiteID = S.siteNumber
WHERE ConfirmationStatus IN ('Confirmed event', 'Report of pregnancy')
AND [SiteID] <> '1440'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Multiple Sclerosis (MS-700)'

UNION

SELECT 
	 'SPHERES' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEs]
	--SELECT *
FROM [NMO750].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.SiteID = S.siteNumber
WHERE EventConfirmationStatus = 'Confirmed event'
AND [SiteID] <> '1440'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)'

UNION

SELECT 
	 'PSA' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEs]
	--SELECT *
FROM [PSA400].[t_PV_TAEQC] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[Site ID] = S.siteNumber
WHERE [Event Confirmation Status/Can you confirm the Event?] IN ('Confirmed event', 'Report of pregnancy')
AND [Site ID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)'

UNION

SELECT 
	 'PSO' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEs]
	--SELECT *
FROM [PSO500].[v_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[SiteID] = S.siteNumber
WHERE [ReportType] IN ('Confirmed event report', 'Report of pregnancy')
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Psoriasis (PSO-500)'

UNION

SELECT 
	 'RA US' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEs]
	--SELECT *
FROM #RATAEQCListing T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[SiteID] = S.siteNumber
WHERE [ConfirmedEvent] = 'Yes'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Rheumatoid Arthritis (RA-100,02-021)'

UNION

SELECT 
	 'RA Japan' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEs]
	--SELECT *
FROM [RA102].[t_pv_TAEQC] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[Site ID] = S.siteNumber
WHERE [Report Type] IN ('Confirmed event', 'Report of pregnancy')
AND [Site ID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Japan RA Registry (RA-102)'

--Use #TAEDocs to get total counts of all TAEs that have had their supporting docs reviewed by PV
-----------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#TAEDocs') IS NOT NULL BEGIN DROP TABLE #TAEDocs END

SELECT 
	 'AD' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEDocs]
   --SELECT * FROM
INTO #TAEDocs
	--SELECT *
FROM [AD550].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.SiteID = S.siteNumber
WHERE ConfirmationStatus = 'Confirmed event'
AND SupportDocsApproved = 'Yes'
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Atopic Dermatitis (AD-550)'

UNION

SELECT 
	 'AA' AS [Registry]
	,COUNT([SubjectID]) AS [TAEDocs]
	--SELECT *
FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[Site ID] = S.siteNumber
WHERE ConfirmationStatus = 'Confirmed event'
AND SupportDocsApproved = 'Yes'
AND SiteID NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Inflammatory Bowel Disease (IBD-600)'

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
	--SELECT *
FROM [MS700].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.SiteID = S.siteNumber
WHERE ConfirmationStatus IN ('Confirmed event', 'Report of pregnancy')
AND SupportingDocsApproved = 'Yes'
AND [SiteID] NOT LIKE '1440%'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Multiple Sclerosis (MS-700)'

UNION

SELECT 
	 'SPHERES' AS [Registry]
	,COUNT(T.SubjectID) AS [TAEDocs]
	--SELECT *
FROM [NMO750].[t_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.SiteID = S.siteNumber
WHERE EventConfirmationStatus = 'Confirmed event'
AND SupportDocsApproved = 'Yes'
AND [SiteID] <> '1440'
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)'

UNION

SELECT 
	 'PSA' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEDocs]
	--SELECT *
FROM [PSA400].[t_PV_TAEQC] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[Site ID] = S.siteNumber
WHERE [Event Confirmation Status/Can you confirm the Event?] IN ('Confirmed event', 'Report of pregnancy')
AND [Supporting documents received by Corrona?] = 'YES'
AND [Site ID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)'

UNION

SELECT 
	 'PSO' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEDocs]
	--SELECT *
FROM [PSO500].[v_pv_TAEQCListing] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[SiteID] = S.siteNumber
WHERE [ReportType] IN ('Confirmed event report', 'Report of pregnancy')
AND [DocsReceivedByCorrona] = 1
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Psoriasis (PSO-500)'

UNION

SELECT 
	 'RA US' AS [Registry]
	,COUNT(T.[SubjectID]) AS [TAEDocs]
	--SELECT *
FROM #RATAEQCListing T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[SiteID] = S.siteNumber
WHERE [ConfirmedEvent] = 'Yes'
AND [AcknowledgementofReceipt] = 1
AND [SiteID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Rheumatoid Arthritis (RA-100,02-021)'

UNION

SELECT 
	 'RA Japan' AS [Registry]
	,COUNT(T.[Subject ID]) AS [TAEDocs]
	--SELECT *
FROM [RA102].[t_pv_TAEQC] T
		--SELECT * FROM
--LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON T.[Site ID] = S.siteNumber
WHERE [Report Type] IN ('Confirmed event', 'Report of pregnancy')
AND [Supporting documents received by Corrona?] = 'YES'
AND [Site ID] NOT LIKE '99%'
--AND S.[currentStatus] <> 'Closed / Completed'
--AND [name] = 'Japan RA Registry (RA-102)'

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
   --SELECT *
FROM (
SELECT 
	'AD' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
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
   --SELECT *
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
   --SELECT *
FROM (
SELECT 
	'IBD' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,CASE WHEN V.[VisitType] LIKE '%Exit%' THEN 'Exit' ELSE V.[VisitType] END AS [VisitType]
	,V.[VisitDate]
   --SELECT *
FROM [IBD600].[v_op_VisitLog_V2] V
--SELECT * FROM 
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
   --SELECT *
FROM (
SELECT 
	'MS' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
FROM  [MS700].[v_op_VisitLog] V
		--SELECT * FROM
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
   --SELECT *
FROM (
SELECT 
	'SPHERES' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
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
   --SELECT *
FROM (
SELECT 
	'PSA' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [CalcVisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
FROM [PSA400].[v_op_VisitLog] V
		--SELECT * FROM
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
   --SELECT *
FROM (
SELECT 
	'PSO' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [CalcVisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
FROM [PSO500].[v_op_VisitLog] V
		--SELECT * FROM
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Psoriasis (PSO-500)'
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
   --SELECT *
FROM (
SELECT 
	'RA US' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [VisitType] ASC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
FROM #RAFullVisitLog V
		--SELECT * FROM
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Rheumatoid Arthritis (RA-100,02-021)'
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
   --SELECT *
FROM (
SELECT 
	'RA Japan' AS [Registry]
	,ROW_NUMBER() OVER ( PARTITION BY V.[SiteID], V.[SubjectID] ORDER BY V.[VisitDate] DESC, [CalcVisitSequence] DESC) AS [Row]
	,V.[SiteID]
	,V.[SubjectID]
	,V.[VisitType]
	,V.[VisitDate]
   --SELECT *
FROM [RA102].[v_op_VisitLog] V
		--SELECT * FROM
LEFT JOIN [Salesforce].[dbo].[registryStatus] S ON V.SiteID = S.siteNumber
WHERE S.[currentStatus] <> 'Closed / Completed'
AND [VisitDate] <> ''
AND [VisitDate] <= GETDATE()
AND [name] = 'Japan RA Registry (RA-102)'
AND V.[SiteID] NOT LIKE '99%') V
WHERE V.[Row] = 1 AND V.[VisitType] <> 'Exit'
GROUP BY V.[Registry], V.[SiteID], V.[SubjectID], V.[VisitType]

--Use #ActivePts to get count of active patients by filtering #LastVisits to only PTs with <= 18 Months Since Last Visit
---------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#ActivePts') IS NOT NULL BEGIN DROP TABLE #ActivePts END

SELECT 
	 [Registry]
	,COUNT([SubjectID]) AS [ActivePts]
INTO #ActivePts
   --SELECT * 
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
   --SELECT * 
FROM #LastVisits
WHERE [DaysSinceLastVisit] > 540
GROUP BY [Registry]

--Combine all counts and insert into the table that the SSRS report will use as its data source
---------------------------------------------------------------------------------------------------------
--DELETE FROM MULTI.t_op_RegistryCounts WHERE [DownloadDate] = '7-5-2023'
	      --SELECT * FROM 
INSERT INTO MULTI.t_op_RegistryCounts
--SELECT * FROM MULTI.t_op_RegistryCounts ORDER BY Registry, DownloadDate Desc
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



GO
