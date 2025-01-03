USE [Reporting]
GO
/****** Object:  View [MULTI].[v_op_FollowUpBreakdown]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =================================================
-- Author:		Kevin Soe
-- Create date: 11/17/2022
-- Description:	View for FollowUpBreakdown Report
-- V2 Create Date: 3/7/2023
-- V2 Author: Kevin Soe
-- =================================================

CREATE VIEW [MULTI].[v_op_FollowUpBreakdown] AS


WITH PTS AS

(
 SELECT 
	 'AD-550' AS [Registry]
	,'Atopic Dermatitis (AD-550)' AS [SFRegistry]
	,[SiteID]
	,[SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]
 FROM [AD550].[t_op_PatientVisitTracker]

 UNION

 SELECT 
	 'IBD-600' AS [Registry]
	,'Inflammatory Bowel Disease (IBD-600)' AS [SFRegistry]
	,[SiteID]
	,[SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]
 FROM [IBD600].[t_op_PatientVisitTracker]

 UNION

 SELECT 
	 'GPP-510' AS [Registry]
	,'Generalized Pustular Psoriasis  (GPP-510)' AS [SFRegistry]
	,FU.[SiteID]
	,FU.[SiteStatus] AS [SFSiteStatus]
	,FU.[SubjectID]
	,FU.[YOB]
	,VI.[EnrollmentDate]
	,FU.[LastEligibleVisitDate]
	,FU.[LastEligibleVisitType]
	,FU.[MonthsSinceLastVisit]
	,FU.[VisitStatus]
	,FU.[EarliestEligNextFU]
	,FU.[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]
 FROM [GPP510].[v_op_SubjectFollowupTracker] FU
 LEFT JOIN [GPP510].[v_op_subjectlog] VI ON VI.SubjectID = FU.SubjectID

 UNION

 SELECT 
	 'MS-700' AS [Registry]
	,'Multiple Sclerosis (MS-700)' AS [SFRegistry]
	,[SiteID]
	,[SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]
 FROM [MS700].[t_op_PatientVisitTracker]
 
 UNION

 SELECT 
	 'NMO-750' AS [Registry]
    ,'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)' AS [SFRegistry]
	,[SiteID]
	,[SFSiteStatus]
	,REPLACE([SubjectID],'-','') AS [SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]
 FROM [NMO750].[t_op_PatientVisitTracker]

 UNION

 SELECT 
	 'PSA-400' AS [Registry]
	,'Psoriatic Arthritis & Spondyloarthritis (PSA-400)' AS [SFRegistry]
	,[SiteID]
	,[currentStatus] AS [SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]--SELECT *
 FROM [PSA400].[t_op_PatientVisitTracker]  PT
 LEFT JOIN (SELECT [name], [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)') RS ON PT.[SiteID] = RS.[siteNumber]

 UNION

 SELECT 
	 'PSO-500' AS [Registry]
	,'Psoriasis (PSO-500)' AS [SFRegistry]
	,[SiteID]
	,[currentStatus] AS [SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]--SELECT *
 FROM [PSO500].[t_op_PatientVisitTracker]  PT
 LEFT JOIN (SELECT [name], [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Psoriasis (PSO-500)') RS ON PT.[SiteID] = RS.[siteNumber]

 /* REMOVING RA-100 - DATA IN DATAWAREHOUSE
 UNION

 SELECT 
	 'RA-100' AS [Registry]
	,'Rheumatoid Arthritis (RA-100,02-021)' AS [SFRegistry]
	,[SiteID]
	,[currentStatus] AS [SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]--SELECT *
 FROM [RA100].[t_op_PatientVisitTracker]  PT
 LEFT JOIN (SELECT [name], [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Rheumatoid Arthritis (RA-100,02-021)') RS ON PT.[SiteID] = RS.[siteNumber]
*/
 UNION

 SELECT 
	 'RA-102' AS [Registry]
	,'Japan RA Registry (RA-102)' AS [SFRegistry]
	,[SiteID]
	,[currentStatus] AS [SFSiteStatus]
	,[SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroup]--SELECT *
 FROM [RA102].[t_op_PatientVisitTracker]  PT
 LEFT JOIN (SELECT [name], [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Japan RA Registry (RA-102)') RS ON PT.[SiteID] = RS.[siteNumber]

 UNION

  SELECT 
	 'AA-560' AS [Registry]
	,'Alopecia Areata (AA-560)' AS [SFRegistry]
	,[SiteID]
	,[currentStatus] AS [SFSiteStatus]
	,REPLACE([SubjectID],'-','') AS [SubjectID]
	,[YOB]
	,[EnrollmentDate]
	,[LastVisitDate]
	,[VisitType]
	,[MonthsSinceLastVisit]
	,[VisitStatus]
	,[EarliestEligNextFU]
	,[TargetNextFuVisitDate]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]
 FROM [regetlprod].[Reporting].[AA560].[t_op_PatientVisitTracker]  PT --SELECT * FROM [Salesforce].[dbo].[registryStatus]
 LEFT JOIN (SELECT [name], [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Alopecia Areata (AA-560)') RS ON PT.[SiteID] = RS.[siteNumber]
 WHERE [SiteID] NOT LIKE '99%'
 ),

 NonExited AS 
 (
 SELECT 
  [Registry]
 ,[SiteID]
 ,COUNT([SubjectID]) AS [TotalNonExited]
 FROM PTS 
 GROUP BY [Registry], [SiteID]
 ),

NineMonths AS 
(
 SELECT 
  [Registry]
 ,[SiteID]
 ,COUNT([SubjectID]) AS [Nine]
 FROM PTS 
 WHERE [MonthsSinceLastVisit] <= 9
 GROUP BY [Registry], [SiteID]
 ),

NineAndTwelve AS 
(
 SELECT 
  [Registry]
 ,[SiteID]
 ,COUNT([SubjectID]) AS [NineAndTwelve]
 FROM PTS 
 WHERE [MonthsSinceLastVisit] > 9 AND [MonthsSinceLastVisit] <= 12
 GROUP BY [Registry], [SiteID]
 ),
 
TwelveAndFifteen AS 
(
 SELECT 
  [Registry]
 ,[SiteID]
 ,COUNT([SubjectID]) AS [TwelveAndFifteen]
 FROM PTS 
 WHERE [MonthsSinceLastVisit] > 12 AND [MonthsSinceLastVisit] <= 15
 GROUP BY [Registry], [SiteID]
 ),

FifteenAndEighteen AS 
(
 SELECT 
  [Registry]
 ,[SiteID]
 ,COUNT([SubjectID]) AS [FifteenAndEighteen]
 FROM PTS 
 WHERE [MonthsSinceLastVisit] > 15 AND [MonthsSinceLastVisit] <= 18
 GROUP BY [Registry], [SiteID]
 ),
 
Eighteen AS 
(
 SELECT 
  [Registry]
 ,[SiteID]
 ,COUNT([SubjectID]) AS [Eighteen]
 FROM PTS 
 WHERE [MonthsSinceLastVisit] > 18
 GROUP BY [Registry], [SiteID]
 )

  SELECT DISTINCT
	 PTS.[Registry]
	,PTS.[SFRegistry]
	,PTS.[SiteID]
	,PTS.[SFSiteStatus]
	,CONCAT(SF.[pmFirstName], ' ', SF.[pmLastName]) AS [RegistryManager]
	,[TotalNonExited]
	,[Nine]
	,[NineAndTwelve]
	,[TwelveAndFifteen]
	,[FifteenAndEighteen]
	,[Eighteen]
 FROM PTS 
 LEFT JOIN NonExited NE ON PTS.Registry = NE.Registry AND PTS.SiteID = NE.SiteID
 LEFT JOIN NineMonths NM ON PTS.Registry = NM.Registry AND PTS.SiteID = NM.SiteID
 LEFT JOIN NineAndTwelve NT ON PTS.Registry = NT.Registry AND PTS.SiteID = NT.SiteID
 LEFT JOIN TwelveAndFifteen TF ON PTS.Registry = TF.Registry AND PTS.SiteID = TF.SiteID
 LEFT JOIN FifteenAndEighteen FE ON PTS.Registry = FE.Registry AND PTS.SiteID = FE.SiteID
 LEFT JOIN Eighteen E ON PTS.Registry = E.Registry AND PTS.SiteID = E.SiteID
 LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON PTS.SFRegistry = SF.[name] AND PTS.[SiteID] = SF.[siteNumber]
 
GO
