USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_SubjectLog]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- ===================================================================================================
-- Author:		Kevin Soe
-- Create date: 10/07/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/1/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [RA102].[usp_op_SubjectLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA102].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (2000) NULL

);
*/

TRUNCATE TABLE [RA102].[t_op_SubjectLog];

IF OBJECT_ID('temp..#SiteStatus_RAJ') IS NOT NULL BEGIN DROP TABLE #SiteStatus_RAJ END

SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
      ,CASE WHEN ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
INTO #SiteStatus_RAJ
FROM [MERGE_RA_Japan].[dbo].[DAT_SITES]
WHERE SITENUM NOT IN (9998, 9999)

---SELECT * FROM #SiteStatus


IF OBJECT_ID('temp..#EX_RAJ') IS NOT NULL BEGIN DROP TABLE #EX_RAJ END

SELECT A.[SITENUM] AS [SiteID]
      ,A.[SUBNUM] AS [SubjectID]
	  --V1 ExitDate
	  --,A.[DISCONTINUE_DATE] AS [ExitDate]
	  --V1.1 ExitDate
	  ,CASE
		WHEN A.[DISCONTINUE_DATE] = '' THEN NULL
		ELSE A.[DISCONTINUE_DATE]
		END AS ExitDate
	  ,A.[EXIT_REASON_DIS] AS [ExitReason]
	  ,A.[OTHER_SPECIFY] AS [ExitReasonOther]
INTO #EX_RAJ	  
FROM Reporting.RA102.v_op_083_ExitReport A
WHERE SITENUM NOT IN (9998, 9999)


INSERT INTO [RA102].[t_op_SubjectLog]
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
	  ,SUB.[BIRTHDATE] AS YOB
	  ,E.ExitDate
	  ,CASE WHEN ISNULL(ExitDate, '')<>'' AND ISNULL(ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ExitReason
	   END AS ExitReason
	  ,E.ExitReasonOther AS ExitReasonDetails


FROM [RA102].[v_op_VisitLog] VL
LEFT JOIN #SiteStatus_RAJ SS ON SS.SiteID=VL.SiteID
LEFT JOIN [MERGE_RA_Japan].[staging].[SUB_01] SUB ON SUB.vID=VL.vID
LEFT JOIN #EX_RAJ E ON E.SubjectID=VL.SubjectID
WHERE VisitType Like 'Enroll%'
AND ISNULL(VisitDate, '')<>''
AND VL.SiteID NOT IN (9998, 9999)
ORDER BY VL.SiteID, VL.SubjectID


END



GO
