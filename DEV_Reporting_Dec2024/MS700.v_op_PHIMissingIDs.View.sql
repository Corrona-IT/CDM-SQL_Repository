USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_PHIMissingIDs]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [MS700].[v_op_PHIMissingIDs] AS

SELECT [STNO] AS SiteID
      ,[SUBJID] AS SubjectID
      ,'Subject Missing in PHI EDC' AS [ID Missing In]
FROM [Reporting].[MS700].[t_HB]
WHERE [SUBJID] NOT IN (
	SELECT [uniqueIdentifier] FROM [RCC_MS700].[api].[subjects]) 
AND [SITEID] NOT LIKE '99%'

UNION

SELECT SiteID
      ,SubjectID
      ,'Subject Missing in MS Registry EDC' AS [ID Missing In]
FROM [Reporting].[MS700].[v_op_VisitLog] 
WHERE VisitType='Enrollment' AND SubjectID NOT IN (SELECT SUBJID FROM [Reporting].[MS700].[t_HB])


--ORDER BY SiteID, SubjectID

GO
