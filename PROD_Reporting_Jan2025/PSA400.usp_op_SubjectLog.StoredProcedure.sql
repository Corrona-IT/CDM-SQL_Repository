USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_op_SubjectLog]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/2/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of new Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [PSA400].[usp_op_SubjectLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [PSA400].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SubjectID] [nvarchar](25) NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (2000) NULL

);
*/



IF OBJECT_ID('temp..#SiteStatus') IS NOT NULL BEGIN DROP TABLE #SiteStatus END

SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
      ,CASE WHEN ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
INTO #SiteStatus
FROM [MERGE_SPA].[dbo].[DAT_SITES]
WHERE SITENUM NOT IN (99997, 99998, 99999)

---SELECT * FROM #SiteStatus


IF OBJECT_ID('temp..#EX') IS NOT NULL BEGIN DROP TABLE #EX END

SELECT A.SiteID
      ,A.SubjectID
	  --V1 ExitDate
	  --,A.DateQuestionnaireCompleted AS ExitDate
	  --V1.1 ExitDate
	  ,CASE
		WHEN A.DateQuestionnaireCompleted = '' THEN NULL
		ELSE A.DateQuestionnaireCompleted
		END AS ExitDate
	  ,A.ExitReason
	  ,A.ExitReasonOther
INTO #EX	  
FROM Reporting.PSA400.v_op_085_ExitReport A
WHERE SiteID NOT IN (99997, 99998, 99999)
AND DateQuestionnaireCompleted IS NOT NULL OR ExitReason IS NOT NULL

TRUNCATE TABLE [PSA400].[t_op_SubjectLog];

INSERT INTO [PSA400].[t_op_SubjectLog]
(
	[SiteID],
	[SiteStatus],
	[SubjectID],
	[EnrollmentDate],
	[YOB],
	[ExitDate],
	[ExitReason],
	[ExitReasonDetails]
)

SELECT DISTINCT VL.[SiteID]
      ,SS.SiteStatus
      ,VL.[SubjectID]
      ,VL.[VisitDate] AS EnrollmentDate
	  ,COALESCE(ES.BIRTHDATE, ESUB.BIRTHDATE) AS YOB
	  ,E.ExitDate
	  ,CASE 
	   WHEN ISNULL(ExitDate, '')<>'' AND ISNULL(ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ExitReason
	   END AS ExitReason
	  ,E.ExitReasonOther AS ExitReasonDetails


FROM [PSA400].[v_op_VisitLog] VL
LEFT JOIN #SiteStatus SS ON SS.SiteID=VL.SiteID
LEFT JOIN [MERGE_SPA].[staging].[ES_01] ES ON ES.vID=VL.vID
LEFT JOIN [MERGE_SPA].[staging].[ESUB_01] ESUB ON ESUB.vID=VL.vID
LEFT JOIN #EX E ON E.SubjectID=VL.SubjectID
WHERE VisitType LIKE 'Enroll%'
AND ISNULL(VisitDate, '')<>''
AND VL.SiteID NOT IN (99997, 99998, 99999)
ORDER BY VL.SiteID, VL.SubjectID


END



GO
