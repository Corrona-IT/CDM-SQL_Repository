USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_MULTIREG_VisitAccruals_TEST]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--==============================================================
--Author: Kaye Mowrey 08Jun2021
--Description:	Create table Multi Registry Visit Accruals
--V2 Update Date: 1Mar2021
--V2 Developer: Kevin Soe
--V2 Description: Add AA-560
--===============================================================

			  --EXECUTE
CREATE PROCEDURE [MULTI].[usp_op_MULTIREG_VisitAccruals_TEST] AS

BEGIN
	SET NOCOUNT ON;


IF OBJECT_ID('tempdb..#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT DISTINCT SiteID,
       SiteStatus,
	   SFSiteStatus,
       SubjectID,
	   ProviderID,
	   VisitType,
	   DataCollectionType,
	   VisitSequence,
	   VisitDate,
	   FirstEntry,
	   DifferenceInDays,
	   Registry,
	   RegistryName
INTO #Visits
FROM
(
SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[AD550].[t_op_VisitLog] VL
  LEFT JOIN [Reporting].[AD550].[t_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND DE.VisitType=VL.VisitType AND DE.VisitDate=VL.VisitDate AND VL.Registry='AD-550'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')
  
  UNION

  SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[IBD600].[v_op_VisitLog] VL
  LEFT JOIN [Reporting].[IBD600].[t_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND SUBSTRING(DE.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE.VisitDate=VL.VisitDate AND VL.Registry='IBD-600'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')

  UNION

  SELECT DISTINCT VL.[SiteID]
      ,'Active' as SiteStatus
	  ,'Approved / Active' AS SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[VisitProviderID] AS [ProviderID]
      ,CASE WHEN (VL.VisitType = 'GPP Flare (Populated)' OR VL.VisitType = 'GPP Flare (Manual)') THEN ('GPP Flare')
	   WHEN VL.VisitType = 'Follow-Up (Non-flaring)' THEN 'Follow-Up'
	   ELSE VL.VisitType
	   END AS [VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,DE.[VisitDate]
	  ,DE.[DEcompletion] AS [FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,'GPP-510' AS [Registry]
      ,'Generalized Pustular Psoriasis (GPP-510)' AS [RegistryName]
  FROM [Reporting].[GPP510].[v_op_DataEntryLag_test] DE 
  LEFT JOIN [Reporting].[GPP510].[v_op_VisitLog_test] VL ON DE.SiteID=VL.SiteID AND VL.VisitSequence=DE.VisitSeq AND VL.VisitType= DE.VisitType --AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) --AND SUBSTRING(DE.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) --AND DE.VisitDate=VL.VisitDate-- AND VL.Registry='IBD-600'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-Up (Non-flaring)', 'GPP Flare (Manual)', 'GPP Flare (Populated)') AND VL.VID = DE.VID

  UNION

  SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[MS700].[v_op_VisitLog] VL
  LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND 
  UPPER(DE.VisitType)=UPPER(VL.Visittype) and DE.VisitSequence=VL.VisitSequence
  AND DE.VisitDate=VL.VisitDate AND VL.Registry='MS-700'
  --SUBSTRING(DE.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) 
    WHERE VL.VisitType IN ('Enrollment', 'Follow-up')


  UNION

  SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[PSA400].[v_op_VisitLog] VL
  LEFT JOIN [Reporting].[PSA400].[t_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND SUBSTRING(DE.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE.VisitDate=VL.VisitDate AND VL.Registry='PSA-400'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')

  UNION

  SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[CompletionDate] AS FirstEntry
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[PSO500].[v_op_VisitLog] VL
  LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] DE ON DE.SiteNumber=VL.SiteID AND CAST(DE.SubjectId AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND SUBSTRING(DE.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE.VisitDate=VL.VisitDate AND VL.Registry='PSO-500'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')

  UNION
/*
  SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,NULL AS [DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[CompletionDate] AS FirstEntry
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[RA100].[v_op_VisitLog] VL
  LEFT JOIN [Reporting].[RA100].[t_op_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND DE.VisitType=VL.VisitType AND DE.VisitDate=VL.VisitDate AND VL.Registry='RA-100'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')

  UNION
  */
  SELECT DISTINCT VL.[SiteID]
      ,VL.SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,NULL AS [DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[RA102].[v_op_VisitLog] VL
  LEFT JOIN [Reporting].[RA102].[t_op_109_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND SUBSTRING(DE.VisitType, 1, 6)=SUBSTRING(VL.VisitType , 1, 6) AND DE.VisitDate=VL.VisitDate AND VL.Registry='RA-102'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')

  UNION

    SELECT DISTINCT VL.[SiteID]
	  ,VL.EDCSiteStatus AS SiteStatus
	  ,VL.SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,NULL AS [DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
  FROM [Reporting].[NMO750].[t_op_VisitLog] VL
  LEFT JOIN [Reporting].[NMO750].[t_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND UPPER(DE.VisitType)=UPPER(VL.VisitType) AND DE.VisitDate=VL.VisitDate AND VL.Registry='NMOSD-750'
  WHERE VL.SiteID<>1440
  AND VL.VisitType IN ('Enrollment', 'Follow-up')

  UNION

    SELECT DISTINCT VL.[SiteID]
	  ,VL.SiteStatus
	  ,RS.currentStatus AS SFSiteStatus
      ,CAST(VL.[SubjectID] AS nvarchar) AS SubjectID
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,DE.[FirstEntry]
	  ,DE.[DifferenceInDays] AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName] --SELECT * 
  FROM [regetlprod].[Reporting].[AA560].[t_op_VisitLog] VL
  LEFT JOIN [regetlprod].[Reporting].[AA560].[t_op_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND CAST(DE.SubjectID AS nvarchar)=CAST(VL.SubjectID AS nvarchar) AND DE.VisitType=VL.VisitType  AND DE.VisitDate=VL.VisitDate AND VL.Registry='AA-560'
  LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=VL.SiteID AND RS.[name]='Alopecia Areata (AA-560)'
  WHERE VL.SiteID NOT LIKE '99%'
  AND VL.VisitType IN ('Enrollment', 'Follow-up')
) A

TRUNCATE TABLE [Reporting].[dbo].[t_op_MULTIREG_VisitAccruals_test]

INSERT INTO [Reporting].[dbo].[t_op_MULTIREG_VisitAccruals_TEST]

(
	   [Registry],
	   [RegistryName],
	   [SiteID],
	   [SiteStatus],
	   [SFSiteStatus],
       [SubjectID],
	   [ProviderID],
	   [VisitType],
	   [DataCollectionType],
	   [VisitSequence],
	   [VisitDate],
	   [FirstEntry],
	   [DifferenceInDays]
)

SELECT Registry,
	   RegistryName,
	   SiteID,
	   SiteStatus,
	   SFSiteStatus,
       SubjectID,
	   ProviderID,
	   VisitType,
	   DataCollectionType,
	   VisitSequence,
	   CAST(VisitDate AS date) AS VisitDate,
	   CAST(FirstEntry AS date) AS FirstEntry,
	   DifferenceInDays
FROM #Visits VL
WHERE --Registry='GPP-510' AND 
ISNULL(VisitDate, '')<>''

--SELECT * FROM [Reporting].[dbo].[t_op_MULTIREG_VisitAccruals] WHERE Registry='GPP-510' --AND FirstEntry >= 'November 17, 2021' AND SalesforceStatus='Approved / Active' ORDER BY Registry, SiteID, SubjectID, VisitDate

END


GO
