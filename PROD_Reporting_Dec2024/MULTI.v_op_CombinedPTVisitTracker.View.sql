USE [Reporting]
GO
/****** Object:  View [MULTI].[v_op_CombinedPTVisitTracker]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =================================================
-- Author:		Kevin Soe
-- Create date: 11/17/2022
-- Description:	View that combines all PT Visit Trackers
-- V2 Create Date: 3/7/2023
-- V2 Author: Kevin Soe
-- =================================================
		   --SELECT * FROM
 CREATE VIEW [MULTI].[v_op_CombinedPTVisitTracker] AS

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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]
 FROM [IBD600].[t_op_PatientVisitTracker]

 UNION

 SELECT 
	 'GPP-510' AS [Registry]
	,'Generalized Pustular Psoriasis  (GPP-510)' AS [SFRegistry]
	,SFU.[SiteID]
	,SFU.[SiteStatus] AS [SFSiteStatus]
	,SFU.[SubjectID]
	,SFU.[YOB]
	,SL.[EnrollmentDate] AS [EnrollmentDate]
	,SFU.[LastEligibleVisitDate] AS [LastVisitDate]
	,SFU.[LastEligibleVisitType] AS [VisitType]
	,SFU.[MonthsSinceLastVisit]
	,SFU.[VisitStatus]
	,SFU.[EarliestEligNextFU]
	,SFU.[TargetNextFuVisitDate]
	,CASE 
		WHEN SFU.[MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN SFU.[MonthsSinceLastVisit] >9.00 and SFU.[MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN SFU.[MonthsSinceLastVisit] >12.00 and SFU.[MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN SFU.[MonthsSinceLastVisit] >15.00 and SFU.[MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN SFU.[MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN SFU.[MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN SFU.[MonthsSinceLastVisit] >9.00 and SFU.[MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN SFU.[MonthsSinceLastVisit] >12.00 and SFU.[MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN SFU.[MonthsSinceLastVisit] >15.00 and SFU.[MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN SFU.[MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]
 FROM [GPP510].[v_op_SubjectFollowupTracker] SFU
 LEFT JOIN [GPP510].[v_op_subjectlog] SL ON SL.SubjectID = SFU.SubjectID

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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]--SELECT *
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]--SELECT *
 FROM [PSO500].[t_op_PatientVisitTracker]  PT
 LEFT JOIN (SELECT [name], [siteNumber], [currentStatus] FROM [Salesforce].[dbo].[registryStatus] WHERE [name] = 'Psoriasis (PSO-500)') RS ON PT.[SiteID] = RS.[siteNumber]

/* REMOVING RA-100 - DATA IN DATA WAREHOUSE
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]--SELECT *
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
	,CASE 
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN 1
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN 2
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN 3
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN 4
		WHEN [MonthsSinceLastVisit] >18.00 THEN 5
	 ELSE NULL 
	 END AS [ActiveGroupNumber]--SELECT *
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
		WHEN [MonthsSinceLastVisit] <= 9.00 THEN '(1) <= 9 mo. FU'
		WHEN [MonthsSinceLastVisit] >9.00 and [MonthsSinceLastVisit] <=12.00 THEN '(2) >9 and <=12 mo. FU'
		WHEN [MonthsSinceLastVisit] >12.00 and [MonthsSinceLastVisit] <=15.00 THEN '(3) >12 and <=15 mo. FU'
		WHEN [MonthsSinceLastVisit] >15.00 and [MonthsSinceLastVisit] <=18.00 THEN '(4) >15 and <=18 mo. FU'
		WHEN [MonthsSinceLastVisit] >18.00 THEN '(5) >18 mo. WITHOUT FU'
	 ELSE NULL 
	 END AS [ActiveGroup]
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
GO
