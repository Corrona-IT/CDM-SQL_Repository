USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_OtherDrugInformation]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [RA100].[v_op_OtherDrugInformation]  AS

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHEQ4.[Form Object Caption] AS [CRF Name]
	  ,PHEQ4.[PHE9B_CMTRT5] AS [Treatment]
	  ,PHEQ4.[PHE9B_CMOTH1] AS [If Other, specify]
	  ,PHEQ4.[PHE9B_CMDSTC5] AS [CURRENT USER Current Dose]
	  ,PHEQ4.[PHE9B_CMDOSPE] AS [CURRENT USER Current Dose(specify)]
	  ,PHEQ4.[PHE9B_CMDOSF_5] AS [CURRENT USER Frequency]
	  ,PHEQ4.[PHE9B_CMFRESPE] AS [CURRENT USER Frequency(specify)]
	  ,PHEQ4.[PHE9B_CMDSTR5] AS [PAST BUT NOT CURRENT USER Most Recent Dose]
	  ,PHEQ4.[PHE9B_CMDOSPAS] AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ4_PHE9B] PHEQ4 ON PHEQ4.VisitId = VIS.VisitID
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] PHFQ1 ON PHFQ1.VisitID = VIS.VisitID
WHERE VIS.VisitType IN ('Enrollment')
AND VIS.VisitDate <> '' AND PHEQ4.[PHE9B_CMTRT5] = 'Other'

UNION

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHEQ5.[Form Object Caption] AS [CRF Name]
	  ,PHEQ5.[PHE11B_CMTRT_34] AS [Treatment]
	  ,PHEQ5.[PHE11B_CMOTH1] AS [If Other, specify]
	  ,PHEQ5.[PHE11B_CMDSTC34] AS [CURRENT USER Current Dose]
	  ,PHEQ5.[PHE11B_CMDOSPE] AS [CURRENT USER Current Dose(specify)]
	  ,PHEQ5.[PHE11B_CMDOSF34] AS [CURRENT USER Frequency]
	  ,PHEQ5.[PHE11B_CMFRESPE] AS [CURRENT USER Frequency(specify)]
	  ,PHEQ5.[PHE11B_CMDSTR34] AS [PAST BUT NOT CURRENT USER Most Recent Dose]
	  ,PHEQ5.[PHE11B_CMDOSPAS] AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ5_PHE11B] PHEQ5 ON PHEQ5.VisitId = VIS.VisitID
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] PHFQ1 ON PHFQ1.VisitID = VIS.VisitID
WHERE VIS.VisitType IN ('Enrollment')
AND VIS.VisitDate <> '' AND PHEQ5.[PHE11B_CMTRT_34] = 'Other'

UNION

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHFQ4.[Form Object Caption] AS [CRF Name]
	  ,PHFQ4.[PHF8B_CMTRT5] AS [Treatment]
	  ,PHFQ4.[PHF8B_CMOTH1] AS [If Other, specify]
	  ,PHFQ4.[PHF8B_CMDSTC5] AS [CURRENT USER Current Dose]
	  ,PHFQ4.[PHF8B_CMDOSPE] AS [CURRENT USER Current Dose(specify)]
	  ,PHFQ4.[PHF8B_CMDOSF_5] AS [CURRENT USER Frequency]
	  ,PHFQ4.[PHF8B_CMFRESPE] AS [CURRENT USER Frequency(specify)]
	  ,PHFQ4.[PHF8B_CMDSTR5] AS [PAST BUT NOT CURRENT USER Most Recent Dose]
	  ,PHFQ4.[PHF8B_CMDOSPAS] AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] PHFQ4 ON PHFQ4.VisitId = VIS.VisitID
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] PHFQ1 ON PHFQ1.VisitID = VIS.VisitID
WHERE VIS.VisitType IN ('Follow-up')
AND VIS.VisitDate <> '' AND PHFQ4.[PHF8B_CMTRT5] = 'Other'

UNION

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHFQ5.[Form Object Caption] AS [CRF Name]
	  ,PHFQ5.[PHF10B_CMTRT_34] AS [Treatment]
	  ,PHFQ5.[PHF10B_CMOTH1] AS [If Other, specify]
	  ,PHFQ5.[PHF10B_CMDSTC34] AS [CURRENT USER Current Dose]
	  ,PHFQ5.[PHF10B_CMDOSPE] AS [CURRENT USER Current Dose(specify)]
	  ,PHFQ5.[PHF10B_CMDOSF34] AS [CURRENT USER Frequency]
	  ,PHFQ5.[PHF10B_CMFRESPE] AS [CURRENT USER Frequency(specify)]
	  ,PHFQ5.[PHF10B_CMDSTR34] AS [PAST BUT NOT CURRENT USER Most Recent Dose]
	  ,PHFQ5.[PHF10B_CMDOSPAS] AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ5_PHF10B] PHFQ5 ON PHFQ5.VisitId = VIS.VisitID
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] PHFQ1 ON PHFQ1.VisitID = VIS.VisitID
WHERE VIS.VisitType IN ('Follow-up')
AND VIS.VisitDate <> '' AND PHFQ5.[PHF10B_CMTRT_34] = 'Other'


GO
