USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_IncompleteVisits]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [PSO500].[v_op_IncompleteVisits] AS 


WITH INCOMPLETE AS
(

SELECT ES.[TrlObjectVisitID]
      ,ES.[VisitId]
      ,V.[InstanceNo]
      ,ES.[VisitType] as [VisitEventType]
	  ,CAST(V.[VisitDate] AS date) AS [VisitDate]
      ,ES.[Subject_Id]
      ,ES.[SiteNo]
      ,ES.[EverAllSigned]
	  ,NULL AS [PayableReportType]
FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllVisits] ES
LEFT JOIN [OMNICOMM_PSO].[inbound].[Visits] V on ES.VisitId=V.VisitId
WHERE ES.[SiteNo] NOT IN (997, 998, 999)

AND [EverAllSigned]=0
AND [VisitType] <> 'Exit'
AND ISNULL(V.[VisitDate], '')<>''


UNION

SELECT ES.[TrlObjectVisitID]
      ,ES.[VisitId]
      ,E.[InstanceNo]
      ,ES.[VisitType] as [VisitEventType]
	  ,CAST(E.[Sys. VisitDate] AS date) AS [VisitDate]
      ,ES.[Subject_Id]
      ,ES.[SiteNo]
      ,ES.[EverAllSigned]
	  ,NULL AS [PayableReportType]
FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllVisits] ES
LEFT JOIN [OMNICOMM_PSO].[inbound].[G_EXIT1] E on ES.[TrlObjectVisitID]=E.[TrlObjectVisitID]
WHERE ES.[SiteNo] NOT IN (997, 998, 999)

AND ES.[EverAllSigned]=0
AND ES.[VisitType] = 'Exit'
and ISNULL(E.[Sys. VisitDate], '')<>''

/*
UNION

SELECT ES.[TrlObjectVisitID]
      ,ES.[VisitId]
      ,ES.[InstanceNo]
      ,ES.[EventType] as [VisitEventType]
	  ,CASE WHEN  ISNULL(FollowUpVisitDate, '')<>'' THEN CAST(FollowUpVisitDate AS date)
	   WHEN ISNULL(FollowUpVisitDate, '')='' THEN CAST(EventOnsetDate AS date)
	   ELSE NULL
	   END AS [VisitDate]
      ,ES.[SubjectID] as [Subject_Id]
      ,ES.[SiteNumber] as [SiteNo]
      ,ES.[BothPagesSigned] as [EverAllSigned]
	  ,ES.[PayableReportType]
	  --		select *
FROM [Reimbursement].[reports].[PSO_LOCAL_015_2] ES
WHERE ES.[SiteNumber] NOT LIKE '99%'
AND (FollowUpVisitDate IS NOT NULL OR EventOnsetDate IS NOT NULL)
AND ES.BothPagesSigned=0
and isnull(ES.[SubjectID], '')<>''
AND isnumeric(ES.[SubjectID])=1
*/
)

SELECT [TrlObjectVisitID]
      ,CAST([VisitId] AS bigint) AS [VisitID]
	  ,CAST([SiteNo] AS int) AS [SiteID]
	  ,SS.SiteStatus
	  ,[Subject_Id] AS [SubjectID]
	  ,[VisitEventType]
	  ,CAST([InstanceNo] AS int) AS [VisitSequence]
	  ,CAST([VisitDate] AS date) AS [VisitDate]
	  ,'Incomplete' AS [CompletionStatus]
FROM INCOMPLETE I
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=I.SiteNo
---ORDER BY [SiteNo], [Subject_Id], [VisitDate], [InstanceNo]




GO
