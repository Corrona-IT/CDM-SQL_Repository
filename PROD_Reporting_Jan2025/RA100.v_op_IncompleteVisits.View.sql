USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_IncompleteVisits]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =================================================
-- Author:		Kevin Soe
-- =================================================



CREATE view [RA100].[v_op_IncompleteVisits]  as

SELECT SV.[SiteID]
      ,SS.SiteStatus
	  --,RS.currentStatus AS [SiteStatus]
      ,SV.[SubjectID]
      ,SV.[VisitType]
      ,SV.[VisitDate]
	  ,DATEPART(QUARTER,SV.[VisitDate]) AS [Quarter]
	  ,DATEPART(YEAR,SV.[VisitDate]) AS [Year]
      ,SV.[VisitID]
      ,SV.[VisitSequence]
	  ,[IS].IS_ISATTEST
	  ,[IS].[Form Object Status] AS FormStatus
	  ,'Incomplete' AS CompletionStatus
  FROM [Reporting].[RA100].[t_op_SubjectVisits] SV
  LEFT JOIN [OMNICOMM_RA100].[dbo].[IS] [IS] ON [IS].VisitId=SV.VisitId
  LEFT JOIN RA100.v_op_SiteStatus SS ON SS.SiteID = SV.SiteID
  --LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.SiteNumber=SV.[SiteID] AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
  WHERE SV.VisitType IN ('Enrollment', 'Exit', 'Follow-up')
  AND (ISNULL([IS].[IS_ISATTEST], '') IS NULL OR [IS].[Form Object Status]<> 'Signed')


GO
