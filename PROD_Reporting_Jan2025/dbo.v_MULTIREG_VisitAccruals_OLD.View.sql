USE [Reporting]
GO
/****** Object:  View [dbo].[v_MULTIREG_VisitAccruals_OLD]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [dbo].[v_MULTIREG_VisitAccruals_OLD] AS

WITH Visits AS
(
SELECT DISTINCT VL.[SiteID]
      ,VL.[SubjectID]
      ,VL.[ProviderID]
      ,VL.[VisitType]
      ,VL.[DataCollectionType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate]
	  ,COALESCE(DE.[FirstEntry], DE2.[FirstEntry], DE3.[FirstEntry], DE4.[FirstEntry], DE5.[CompletionDate], DE6.[CompletionDate], DE7.[FirstEntry]) AS FirstEntry
	  ,COALESCE(DE.[DifferenceInDays] , DE2.[DifferenceInDays] , DE3.[DifferenceInDays] , DE4.[DifferenceInDays] , DE5.[DifferenceInDays] , DE6.[DifferenceInDays]) AS [DifferenceInDays]
      ,VL.[Registry]
      ,VL.[RegistryName]
	  ,RS.[currentStatus] AS SalesforceStatus
  FROM [Reporting].[dbo].[v_AllRegistryVisitLogs] VL
  LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]=VL.[RegistryName] AND RS.[siteNumber]=VL.SiteID
  LEFT JOIN [Reporting].[AD550].[t_DataEntryLag] DE ON DE.SiteID=VL.SiteID AND DE.SubjectID=VL.SubjectID AND DE.VisitType=VL.VisitType AND DE.VisitDate=VL.VisitDate AND VL.Registry='AD-550'
  LEFT JOIN [Reporting].[IBD600].[t_DataEntryLag] DE2 ON DE2.SiteID=VL.SiteID AND DE2.SubjectID=VL.SubjectID AND SUBSTRING(DE2.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE2.VisitDate=VL.VisitDate AND VL.Registry='IBD-600'
  LEFT JOIN [Reporting].[MS700].[t_DataEntryLag] DE3 ON DE3.SiteID=VL.SiteID AND DE3.SubjectID=VL.SubjectID AND SUBSTRING(DE3.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE3.VisitDate=VL.VisitDate AND VL.Registry='MS-700'
  LEFT JOIN [Reporting].[PSA400].[t_DataEntryLag] DE4 ON DE4.SiteID=VL.SiteID AND DE4.SubjectID=VL.SubjectID AND SUBSTRING(DE4.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE4.VisitDate=VL.VisitDate AND VL.Registry='PSA-400'
  LEFT JOIN [Reporting].[PSO500].[v_op_DataEntryLag] DE5 ON DE5.SiteNumber=VL.SiteID AND DE5.SubjectId=VL.SubjectID AND SUBSTRING(DE5.VisitType, 1, 6)=SUBSTRING(VL.VisitType, 1, 6) AND DE5.VisitDate=VL.VisitDate AND VL.Registry='PSO-500'
  LEFT JOIN [Reporting].[RA100].[t_op_DataEntryLag] DE6 ON DE6.SiteID=VL.SiteID AND DE6.SubjectID=VL.SubjectID AND DE6.VisitType=VL.VisitType AND DE6.VisitDate=VL.VisitDate AND VL.Registry='RA-100'
  LEFT JOIN [Reporting].[RA102].[t_op_109_DataEntryLag] DE7 ON DE7.SiteID=VL.SiteID AND DE7.SubjectID=VL.SubjectID AND SUBSTRING(DE7.VisitType, 1, 6)=SUBSTRING(VL.VisitType , 1, 6) AND DE7.VisitDate=VL.VisitDate AND VL.Registry='RA-102'
  WHERE VL.VisitType IN ('Enrollment', 'Follow-up')
)

SELECT SiteID,
       SubjectID,
	   ProviderID,
	   VisitType,
	   DataCollectionType,
	   VisitSequence,
	   CAST(VisitDate AS date) AS VisitDate,
	   CAST(FirstEntry AS date) AS FirstEntry,
	   DifferenceInDays,
	   Registry,
	   RegistryName,
	   SalesforceStatus
FROM Visits

 -- ORDER BY Registry, SiteID, SubjectID, VisitDate

/*

--PSA VISIT COUNT ISSUE (DUPLICATE ROWS BECAUSE OF VERSIONING):
  SELECT A.SiteID,
         A.SubjectID,
		 A.VisitType,
		 B.VisitType,
		 A.VisitDate,
		 B.VisitDate
FROM [Reporting].[PSA400].[t_DataEntryLag] A
  INNER JOIN [Reporting].[PSA400].[t_DataEntryLag] B ON B.SiteID=A.SiteID AND B.SubjectID=A.SubjectID AND B.VisitDate=A.VisitDate
  WHERE A.Visittype<>B.VisitType
*/

GO
