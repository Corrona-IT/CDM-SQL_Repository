USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_SubjectLog]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 02/23/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of new Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [NMO750].[usp_op_SubjectLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SubjectID] [nvarchar] (10) NOT NULL,
	[patientId] [bigint] NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (2000) NULL,

);
*/


IF OBJECT_ID('tempdb.dbo.#SiteStatus') IS NOT NULL  DROP TABLE #SiteStatus 

SELECT DISTINCT SiteID
      ,[SiteStatus]

INTO #SiteStatus
FROM [Reporting].[NMO750].[v_SiteStatus]

--SELECT * FROM #SiteStatus

IF OBJECT_ID('tempdb.dbo.#Subjects') IS NOT NULL  DROP TABLE #Subjects 

SELECT DISTINCT CAST(SiteID AS int) AS SiteID
      ,SubjectID
	  ,patientId
      ,[Status]

INTO #Subjects
FROM [Reporting].[NMO750].[v_op_subjects]
WHERE [status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #Subjects ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 

SELECT CAST(S.SiteID AS int) AS SiteID
      ,EX.subNum AS SubjectID
	  ,EX.subjectId AS patientId
	  ,EX.exit_date AS ExitDate
	  ,EX.eventName AS VisitType
	  ,E.exit_reason_dec AS ExitReason
	  ,e.exit_reason_specify AS OtherExitReason

INTO #EXITS

FROM [RCC_NMOSD750].[staging].[exitdate] EX
LEFT JOIN [RCC_NMOSD750].[staging].[exitdetails] E ON E.subNum=EX.subNum and E.eventiD=Ex.eventId and E.eventOccurrence=Ex.eventOccurrence
LEFT JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.patientId=E.[subjectId] AND S.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #EXITS ORDER BY SubjectID

IF OBJECT_ID('tempdb..#VisitLog') IS NOT NULL  DROP TABLE #VisitLog 

SELECT VL.[SiteID]
      ,SS.[SiteStatus]
      ,VL.[SubjectID]
	  ,VL.patientId
      ,(SELECT VL.[VisitDate] FROM [NMO750].[t_op_VisitLog] VL2 WHERE VL.patientId=VL2.patientId AND VL2.VisitType='Enrollment') AS EnrollmentDate
	  ,(SELECT TOP(1) subject_yob FROM [RCC_NMOSD750].[staging].[subjectinfo] SD WHERE SD.subjectId=VL.patientId) AS [YOB]
	  ,E.ExitDate
	  ,E.ExitReason
	  ,E.OtherExitReason AS ExitReasonDetails

INTO #VisitLog 
FROM [Reporting].[NMO750].[t_op_VisitLog] VL
LEFT JOIN #SiteStatus SS ON SS.SiteID=VL.SiteID
LEFT JOIN #EXITS E ON E.SubjectID=VL.SubjectID
WHERE VL.VisitType='Enrollment'
AND VL.EligibleVisit='Yes'
--SELECT * FROM #VisitLog ORDER BY SiteID, SubjectID


TRUNCATE TABLE [Reporting].[NMO750].[t_op_SubjectLog];

INSERT INTO [Reporting].[NMO750].[t_op_SubjectLog]
(
	[SiteID],
	[SiteStatus],
	[SubjectID],
	[patientId],
	[EnrollmentDate],
	[YOB],
	[ExitDate],
	[ExitReason],
	[ExitReasonDetails]
)

SELECT VL.SiteID
      ,VL.SiteStatus
	  ,VL.SubjectID
	  ,VL.patientId
	  ,VL.EnrollmentDate
	  ,VL.[YOB]
	  ,VL.ExitDate
	  ,CASE WHEN ISNULL(VL.ExitDate, '')<>'' AND ISNULL(VL.ExitReason, '')<>'' THEN ExitReason
	   WHEN ISNULL(VL.ExitDate, '')<>'' AND ISNULL(VL.ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ''
	   END AS ExitReason
	  ,VL.ExitReasonDetails
FROM #VisitLog VL
WHERE ISNULL(VL.SiteID, '')<>''


--SELECT * FROM [Reporting].[NMO750].[t_op_SubjectLog] ORDER BY SiteID, SubjectID



END

GO
