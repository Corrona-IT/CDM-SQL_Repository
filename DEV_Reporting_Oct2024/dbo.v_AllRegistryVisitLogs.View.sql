USE [Reporting]
GO
/****** Object:  View [dbo].[v_AllRegistryVisitLogs]    Script Date: 11/13/2024 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [dbo].[v_AllRegistryVisitLogs] AS


(
SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
      ,'' AS [SubjectIDError]
      ,VL.[Registry]
	  ,'Atopic Dermatitis (AD-550)' AS RegistryName
  FROM [Reporting].[AD550].[t_op_VisitLog] VL


UNION

  SELECT DISTINCT VL.[SiteID]
      ,[SiteStatus]
	  ,CAST([SubjectID] AS nvarchar) AS SubjectID
	  ,[ProviderID]
      ,CASE WHEN [VisitType]='Follow-Up' THEN 'Follow-up'
	   ELSE VisitType
	   END AS VisitType
      ,[DataCollectionType]
      ,[VisitSequence]
      ,[VisitDate]
      ,[SubjectIDError]
      ,[Registry]
	  ,'Multiple Sclerosis (MS-700)' AS RegistryName
  FROM [MS700].[v_op_VisitLog] VL

UNION

  SELECT DISTINCT VL.[SiteID]
      ,[SiteStatus]
	  ,CAST([SubjectID] AS nvarchar) AS SubjectID
      ,[ProviderID]
	  ,CASE WHEN [VisitType]='Follow-Up' THEN 'Follow-up'
	   ELSE VisitType
	   END AS VisitType
	  ,[DataCollectionType]
      ,[CalcVisitSequence] AS VisitSequence
      ,[VisitDate]
	  ,'' AS [SubjectIDError]
      ,[Registry]
	  ,'Inflammatory Bowel Disease (IBD-600)' AS RegistryName
  FROM [IBD600].[v_op_VisitLog] VL
  WHERE ISNULL(VisitDate, '')<>''

UNION

  SELECT DISTINCT VL.[SiteID]
      ,[EDCSiteStatus]
	  ,[SubjectID]
      ,[ProviderID]
	  ,VisitType
	  ,'' AS DataCollectionType
      ,VisitSequence
      ,[VisitDate]
	  ,'' AS [SubjectIDError]
      ,'NMOSD-750' AS Registry
	  ,RegistryName
  FROM [NMO750].[t_op_VisitLog] VL
  WHERE SiteID <> 1440

UNION

  SELECT DISTINCT VL.[SiteID]
      ,[SiteStatus]
      ,CAST([SubjectID] AS nvarchar) AS SubjectID
	  ,[ProviderID]
	  ,CASE WHEN [VisitType]='Follow-Up' THEN 'Follow-up'
	   ELSE VisitType
	   END AS VisitType
	  ,[DataCollectionType]
      ,[CalcVisitSequence] AS VisitSequence
      ,[VisitDate]
	  ,'' AS SubjectIDError
      ,[Registry]
	  ,'Psoriatic Arthritis & Spondyloarthritis (PSA-400)' AS RegistryName
  FROM [PSA400].[v_op_VisitLog] VL


UNION

  SELECT DISTINCT VL.[SiteID]
      ,[SiteStatus]
      ,CAST([SubjectID] AS nvarchar) AS SubjectID
	  ,[ProviderID]
	  ,[VisitType]
	  ,[DataCollectionType]
      ,[CalcVisitSequence] AS VisitSequence
      ,[VisitDate]
	  ,'' AS SubjectIDError
      ,[Registry]
	  ,'Psoriasis (PSO-500)' AS RegistryName
  FROM [PSO500].[v_op_VisitLog] VL

/*
UNION

  SELECT DISTINCT VL.[SiteID]
      ,[SiteStatus]
      ,CAST([SubjectID] AS nvarchar) AS SubjectID
      ,[ProviderID]
	  ,CASE WHEN [VisitType]='Follow-Up' THEN 'Follow-up'
	   ELSE VisitType
	   END AS VisitType
	  ,'' AS [DataCollectionType]
      ,[CalcVisitSequence] AS VisitSequence
      ,[VisitDate]
	  ,'' AS SubjectIDError
      ,[Registry]
	  ,'Rheumatoid Arthritis (RA-100,02-021)' AS RegistryName
  FROM [RA100].[v_op_VisitLog] VL
*/

UNION

  SELECT DISTINCT VL.[SiteID]
      ,[SiteStatus]
	  ,CAST([SubjectID] AS nvarchar) AS SubjectID
      ,[ProviderID]
	  ,CASE WHEN [VisitType]='Follow-Up' THEN 'Follow-up'
	   ELSE VisitType
	   END AS VisitType
	  ,'' AS [DataCollectionType]
      ,[CalcVisitSequence] AS VisitSequence
      ,[VisitDate]
	  ,'' AS SubjectIDError
      ,[Registry]
	  ,'Japan RA Registry (RA-102)' AS RegistryName
  FROM [RA102].[v_op_VisitLog] VL

)

GO
