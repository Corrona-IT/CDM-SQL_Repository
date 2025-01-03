USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_AllMedsENRFU]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: 7/12/2018
-- Description:	Procedure for All Medications at Enrollment and Follow-up
--              Does not include Test Sites 997, 998, 999
-- ===========================================================================

CREATE PROCEDURE [RA100].[usp_op_AllMedsENRFU] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



/*
CREATE TABLE [RA100].[t_op_AllMedsENRandFU](
       [SiteID] [int] NOT NULL
      ,[SubjectID] [bigint] NOT NULL
	  ,[VisitDate] [date] NULL
	  ,[VisitType] [nvarchar] (250) NULL
	  ,[CRF Name] [nvarchar] (350) NULL
	  ,[Treatment] [nvarchar] (300) NULL
	  ,[If Other specify] [nvarchar] (300) NULL
	  ,[First Use Start Date] [nvarchar] (20) NULL
	  ,[Current User Current Dose] [nvarchar] (50) NULL
	  ,[Current User Current Dose specify] [nvarchar] (25) NULL
	  ,[Current User Frequency] [nvarchar] (50) NULL
	  ,[Current User Frequency specify] [nvarchar] (25) NULL
	  ,[Past But Not Current User Most Recent Dose] [nvarchar] (50) NULL
	  ,[Past But Not Current User Most Recent Dose specify] [nvarchar] (25) NULL
	  ,[Past But Not Current User Most Recent Use] [nvarchar] (20) NULL
	  ,[Changes Planned Today] [nvarchar] (50) NULL
	  ,[Reason Code 1] [nvarchar] (5) NULL
	  ,[Reason Code 2] [nvarchar] (5) NULL
	  ,[Reason Code 3] [nvarchar] (5) NULL

) ON [PRIMARY]
GO
*/

TRUNCATE TABLE [Reporting].[RA100].[t_op_AllMedsENRandFU]

INSERT INTO [Reporting].[RA100].[t_op_AllMedsENRandFU]
(
       [SiteID]
      ,[SubjectID]
	  ,[VisitDate]
	  ,[VisitType]
	  ,[CRF Name]
	  ,[Treatment]
	  ,[If Other specify]
	  ,[First Use Start Date]
	  ,[Current User Current Dose]
	  ,[Current User Current Dose specify]
	  ,[Current User Frequency]
	  ,[Current User Frequency specify]
	  ,[Past But Not Current User Most Recent Dose]
	  ,[Past But Not Current User Most Recent Dose specify]
	  ,[Past But Not Current User Most Recent Use]
	  ,[Changes Planned Today]
	  ,[Reason Code 1]
	  ,[Reason Code 2]
	  ,[Reason Code 3]

)





SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHEQ4.[Form Object Caption] AS [CRF Name]
	  ,PHEQ4.[PHE9B_CMTRT5] AS [Treatment]
	  ,PHEQ4.[PHE9B_CMOTH1] AS [If Other specify]
	  ,PHEQ4.[PHE9B_CMFDAT5] AS [First Use Start Date]
	  ,PHEQ4.[PHE9B_CMDSTC5] AS [Current User Current Dose]
	  ,PHEQ4.[PHE9B_CMDOSPE] AS [Current User Current Dose specify]
	  ,PHEQ4.[PHE9B_CMDOSF_5] AS [Current User Frequency]
	  ,PHEQ4.[PHE9B_CMFRESPE] AS [Current User Frequency specify]
	  ,PHEQ4.[PHE9B_CMDSTR5] AS [Past But Not Current User Most Recent Dose]
	  ,PHEQ4.[PHE9B_CMDOSPAS] AS [Past But Not Current User Most Recent Dose specify]
	  ,PHEQ4.[PHE9B_CMRDAT5] AS [Past But Not Current User Most Recent Use]
	  ,PHEQ4.[PHE9B_CMCH5] AS [Changes Planned Today]
	  ,PHEQ4.[PHE9B_CMRNA5] AS [Reason Code 1]
	  ,PHEQ4.[PHE9B_CMRNB5] AS [Reason Code 2]
	  ,PHEQ4.[PHE9B_CMRNC5] AS [Reason Code 3]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ4_PHE9B] PHEQ4 ON PHEQ4.VisitId = VIS.VisitID
WHERE VIS.VisitType IN ('Enrollment')
AND ISNULL(VIS.VisitDate, '') <> '' 
AND PHEQ4.[PHE9B_CMTRT5] <> ''

UNION

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHEQ5.[Form Object Caption] AS [CRF Name]
	  ,PHEQ5.[PHE11B_CMTRT_34] AS [Treatment]
	  ,PHEQ5.[PHE11B_CMOTH1] AS [If Other specify]
	  ,PHEQ5.[PHE11B_CMFDAT34] AS [First Use Start Date]
	  ,PHEQ5.[PHE11B_CMDSTC34] AS [Current User Current Dose]
	  ,PHEQ5.[PHE11B_CMDOSPE] AS [Current User Current Dose specify]
	  ,PHEQ5.[PHE11B_CMDOSF34] AS [Current User Frequency]
	  ,PHEQ5.[PHE11B_CMFRESPE] AS [Current User Frequency(specify)]
	  ,PHEQ5.[PHE11B_CMDSTR34] AS [Past But Not Current User Most Recent Dose]
	  ,PHEQ5.[PHE11B_CMDOSPAS] AS [Past But Not Current User Most Recent Dose specify]
	  ,PHEQ5.[PHE11B_CMRDAT34] AS [Past But Not Current User Most Recent Use]
	  ,PHEQ5.[PHE11B_CMCH34] AS [Changes Planned Today]
	  ,PHEQ5.[PHE11B_CMRNA34] AS [Reason Code 1]
	  ,PHEQ5.[PHE11B_CMRNB34] AS [Reason Code 2]
	  ,PHEQ5.[PHE11B_CMRNC34] AS [Reason Code 3]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ5_PHE11B] PHEQ5 ON PHEQ5.VisitId = VIS.VisitID
WHERE VIS.VisitType IN ('Enrollment')
AND ISNULL(VIS.VisitDate, '') <> '' 
AND PHEQ5.[PHE11B_CMTRT_34] <> ''

UNION

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHFQ4.[Form Object Caption] AS [CRF Name]
	  ,PHFQ4.[PHF8B_CMTRT5] AS [Treatment]
	  ,PHFQ4.[PHF8B_CMOTH1] AS [If Other specify]
	  ,PHFQ4.[PHF8B_CMSTDT5] AS [First Use Start Date]
	  ,PHFQ4.[PHF8B_CMDSTC5] AS [Current User Current Dose]
	  ,PHFQ4.[PHF8B_CMDOSPE] AS [Current User Current Dose specify]
	  ,PHFQ4.[PHF8B_CMDOSF_5] AS [Current User Frequency]
	  ,PHFQ4.[PHF8B_CMFRESPE] AS [Current User Frequency specify]
	  ,PHFQ4.[PHF8B_CMDSTR5] AS [Past But Not Current User Most Recent Dose]
	  ,PHFQ4.[PHF8B_CMDOSPAS] AS [Past But Not Current User Most Recent Dose specify]
	  ,PHFQ4.[PHF8B_CMRDAT5] AS [Past But Not Current User Most Recent Use]
	  ,PHFQ4.[PHF8B_CMCH5] AS [Changes Planned Today]
	  ,PHFQ4.[PHF8B_CMRNAF5] AS [Reason Code 1]
	  ,PHFQ4.[PHF8B_CMRNBF5] AS [Reason Code 2]
	  ,PHFQ4.[PHF8B_CMRNCF5] AS [Reason Code 3] 
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] PHFQ4 ON PHFQ4.VisitId = VIS.VisitID
WHERE VIS.VisitType IN ('Follow-up')
AND ISNULL(VIS.VisitDate, '') <> '' 
AND PHFQ4.[PHF8B_CMTRT5] <> ''

UNION

SELECT VIS.SiteID
      ,VIS.SubjectID
	  ,VIS.VisitDate
	  ,VIS.VisitType
	  ,PHFQ5.[Form Object Caption] AS [CRF Name]
	  ,PHFQ5.[PHF10B_CMTRT_34] AS [Treatment]
	  ,PHFQ5.[PHF10B_CMOTH1] AS [If Other specify]
	  ,PHFQ5.[PHF10B_CMSTDT34] AS [First Use Start Date]
	  ,PHFQ5.[PHF10B_CMDSTC34] AS [Current User Current Dose]
	  ,PHFQ5.[PHF10B_CMDOSPE] AS [Current User Current Dose specify]
	  ,PHFQ5.[PHF10B_CMDOSF34] AS [Current User Frequency]
	  ,PHFQ5.[PHF10B_CMFRESPE] AS [Current User Frequency specify]
	  ,PHFQ5.[PHF10B_CMDSTR34] AS [Past But Not Current User Most Recent Dose]
	  ,PHFQ5.[PHF10B_CMDOSPAS] AS [Past But Not Current User Most Recent Dose specify]
	  ,PHFQ5.[PHF10B_CMRDAT34] AS [Past But Not Current User Most Recent Use]
	  ,PHFQ5.[PHF10B_CMCH34] AS [Changes Planned Today]
	  ,PHFQ5.[PHF10B_CMRNAF34] AS [Reason Code 1]
	  ,PHFQ5.[PHF10B_CMRNBF34] AS [Reason Code 2]
	  ,PHFQ5.[PHF10B_CMRNCF34] AS [Reason Code 3]
FROM [Reporting].[RA100].[t_op_SubjectVisits] VIS
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ5_PHF10B] PHFQ5 ON PHFQ5.VisitId = VIS.VisitID
WHERE VIS.VisitType IN ('Follow-up')
AND ISNULL(VIS.VisitDate, '') <> ''
AND PHFQ5.[PHF10B_CMTRT_34] <> ''

END

GO
