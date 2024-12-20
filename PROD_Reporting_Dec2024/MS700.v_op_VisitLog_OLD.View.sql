USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_VisitLog_OLD]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







/*Listing of all visits in the MS EDC that have a visit date regardless of completeness*/

CREATE VIEW [MS700].[v_op_VisitLog_OLD] AS

WITH VISLIST AS
(
SELECT S.[StudySiteName] AS SiteID
      ,V.[subNum] AS SubjectID
	  ,S.[id] AS PatientID
	  ,'Enrollment' AS VisitType
	  ,0 AS VisitSequence
	  ,V.[visit_dt] AS VisitDate
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventOccurrence
FROM [RCC_MS700].[staging].[visitinformation] V
LEFT JOIN [RCC_MS700].[api].[subjects] S ON V.subjectId=S.[id]

WHERE S.[StudySiteName]<>'Corrona'
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND V.[eventName]='Enrollment Visit'

UNION

SELECT S.[StudySiteName] AS SiteID
      ,V.[subNum] AS SubjectID
	  ,S.[id] AS PatientID
	  ,'Follow-Up' AS VisitType
	  ,ROW_NUMBER() OVER(PARTITION BY S.[StudySiteName], v.[subNum] ORDER BY V.[visit_dt]) AS VisitSequence
	  ,V.[visit_dt] AS VisitDate
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
  	  ,V.eventOccurrence
FROM [RCC_MS700].[staging].[visitinformation] V
LEFT JOIN [RCC_MS700].[api].[subjects] S ON V.subjectId=S.[id]

WHERE S.[StudySiteName]<>'Corrona'
AND S.[status] NOT IN ('Removed', 'Incomplete')
AND V.[eventName]='Follow-Up Visit'

UNION

SELECT S.[StudySiteName] AS SiteID
      ,E.[subNum] AS SubjectID
	  ,S.[id] AS PatientID
	  ,'Exit' AS VisitType
	  ,99 AS VisitSequence
	  ,E.[exit_date] AS VisitDate
	  ,E.[md_cod_exit] AS ProviderID
	  ,E.eventCrfId
	  ,E.eventOccurrence
FROM [RCC_MS700].[staging].[exitstatus] E
LEFT JOIN [RCC_MS700].[api].[subjects] S ON E.subjectId=S.[id]

WHERE S.[StudySiteName]<>'Corrona'
AND S.[status] NOT IN ('Removed', 'Incomplete')
)

SELECT DISTINCT SiteID
      ,SubjectID
	  ,PatientID
	  ,VisitType
	  ,VisitSequence
	  ,VisitDate
	  ,ProviderID
	  ,eventCrfId
	  ,eventOccurrence
FROM VISLIST V


--SELECT * FROM [RCC_MS700].[staging].[visitinformation]
--SELECT * FROM FROM [RCC_MS700].[api].[subjects]
--SELECT * FROM [RCC_MS700].[staging].[exitstatus]



GO
