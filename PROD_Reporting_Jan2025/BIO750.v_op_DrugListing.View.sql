USE [Reporting]
GO
/****** Object:  View [BIO750].[v_op_DrugListing]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BIO750].[v_op_DrugListing] AS


SELECT [SiteID]
      ,[SubjectID]
      ,[Treatment]
      ,[DrugStatus]
      ,COALESCE([DateStarted], [DatePrescribed]) AS DateStarted
      ,[DateStopped]

  FROM [NMO750].[t_op_DrugListing]

  UNION

SELECT SiteID
      ,SubjectID
	  ,'No medications listed for this subject' AS Treatment
	  ,'' AS DrugStatus
	  ,CAST(NULL AS date) AS DateStarted
	  ,CAST(NULL AS date) as DateStopped

FROM [NMO750].[t_op_VisitLog]
WHERE SubjectID NOT IN (SELECT SubjectID FROM [NMO750].[t_op_DrugListing])


GO
