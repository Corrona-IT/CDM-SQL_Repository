USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_NoDataPTsAndVisits]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author: Kevin Soe
-- Create date: 8-Jun-2022
-- Description:	Procedure to create list of all Subjects with No Visits Entered and all visits with no data entered
-- =============================================
		 --SELECT * FROM [RA100].[t_op_NoDataPTsAndVisits]
		 --DROP TABLE [RA100].[t_op_NoDataPTsAndVisits]
			   --EXECUTE
CREATE PROCEDURE [RA100].[usp_op_NoDataPTsAndVisits] AS

/*
			 SELECT * FROM
CREATE TABLE [RA100].[t_op_NoDataPTsAndVisits]
(
	[SiteID] [int] NULL,
	[currentStatus] [nvarchar](100) NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[DaysSinceCreation] [int] NULL,
	[IssueType] [nvarchar](50) NULL,
);
*/

TRUNCATE TABLE [Reporting].[RA100].[t_op_NoDataPTsAndVisits];


if object_id('tempdb..#PTCreateDate') is not null begin drop table #PTCreateDate end


--Use #PTcreatedate to determine when pt was initially created
SELECT * --FROM #PTCreateDate
INTO #PTCreateDate
FROM  (
		SELECT *
			  ,ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY t1.[AuditDate] asc) as SignOrder
		FROM (
				SELECT a.AuditId
				      ,CAST(a.[StateChangeDateTime] AS DATE) AS [AuditDate]
					  ,a.[TrlObjectFormId]
					  ,a.[TrlObjectTypeId]
					  ,a.[TrlObjectStateBitMask]
					  ,a.[TrlObjectId]
					  ,a.[TrlObjectPatientId]
					  ,p.[PatientId]
					  ,a.[TrlObjectVisitId]
				FROM --		select top 100 * from 
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits] a
				LEFT JOIN 
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Patient Information] p
				ON
						a.[TrlObjectPatientId] = p.[TrlObjectPatientId] 
				WHERE a.[TrlObjectFormId] is not null
					AND a.[TrlObjectTypeId] = 11   --[TrlObjectTypeId] = 11 means Patient/Subject, [TrlObjectTypeId] = 12 means Visit
					AND ((ISNULL(a.[TrlObjectStateBitmask], 0) & (8|4|2)) <> 0)
					--AND DATEDIFF(DD, a.[StateChangeDateTime], GetDate()) <= 730.0
				
			) t1
		 ) t2 WHERE SignOrder = 1		

		--SELECT * FROM #RowOrder WHERE [PatientId] IS NULL
		--SELECT * FROM #PTCreateDate	

if object_id('tempdb..#VisitLog') is not null begin drop table #VisitLog end

SELECT * 
INTO #VisitLog
FROM (SELECT DISTINCT [SubjectID] FROM [Reporting].[RA100].[v_op_VisitLog]) A

if object_id('tempdb..#TAEQCListing') is not null begin drop table #TAEQCListing end

SELECT * 
INTO #TAEQCListing
FROM (SELECT DISTINCT [SubjectID] FROM [Reporting].[RA100].[v_pv_TAEQCListing]) B

if object_id('tempdb..#SFStatus') is not null begin drop table #SFStatus end

SELECT 
	CAST([siteNumber] AS INT) AS [SiteNumber]
   ,[currentStatus] 
INTO #SFStatus
FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)'

INSERT INTO [Reporting].[RA100].[t_op_NoDataPTsAndVisits]
(
	 [SiteID]
	,[currentStatus]
	,[SubjectID]
	,[VisitDate]
	,[VisitType]
	,[CreatedDate]
	,[DaysSinceCreation]
	,[IssueType]
)

SELECT
	   P.[Site Number] AS [SiteID]
	  ,S.[currentStatus] AS [SiteStatus]
      --,P.[TrlObjectPatientId]
      ,P.[Patient Number] AS [SubjectID]
	  ,'' AS [VisitDate]
	  ,'' AS [VisitType]
	  ,DATEADD(Day, DATEDIFF(Day, 0,C.[AuditDate]),0) AS [CreatedDate]
	  ,DATEDIFF(DD, DATEADD(Day, DATEDIFF(Day, 0,C.[AuditDate]),0), DATEADD(Day, DATEDIFF(Day, 0,GETDATE()),0)) AS [DaysSinceCreation]
	  ,'No Data Subject' AS [IssueType]

  FROM  [172.16.81.24].[DataModel_TMCORe_production].[dbo].[GL_Patient Information] P
  LEFT JOIN #PTCreateDate C ON P.[TrlObjectPatientId] = C.[TrlObjectPatientId]
  LEFT JOIN #SFStatus S ON P.[Site Number] = S.[siteNumber]
  WHERE CAST(P.[Patient Number] AS bigint) NOT IN (SElECT * FROM #VisitLog)
  AND P.[Patient Number] NOT IN (SElECT * FROM #TAEQCListing)
  AND P.[Site Number] NOT LIKE '99%'
  --If Patients are not found in Visit Log or TAE QC Listing, it  means no events are entered in for them.
  UNION

SELECT
	 N.[Site Object SiteNo] AS [SiteID]
	,S.[currentStatus] AS [SiteStatus]
	,N.[Patient Object PatientNo] AS [SubjectID]
	,N.[Visit Object VisitDate] AS [VisitDate]
	,N.[Visit Object ProCaption] AS [VisitType]
	,DATEADD(Day, DATEDIFF(Day, 0,N.[Visit_EarliestDataChange]),0) AS [CreatedDate]
	,DATEDIFF(DD, DATEADD(Day, DATEDIFF(Day, 0,N.[Visit_EarliestDataChange]),0), DATEADD(Day, DATEDIFF(Day, 0,GETDATE()),0)) AS [DaysSinceCreation]
		,'No Data Visit' AS [IssueType]

  FROM [Reporting].[RA100].[v_op_NoDataVisits] N 
  LEFT JOIN #SFStatus S ON N.[Site Object SiteNo] = S.[siteNumber]--If a visit is found on this view, it means ALL associated CRFs with the visit are in a status of 'No Data'
GO
