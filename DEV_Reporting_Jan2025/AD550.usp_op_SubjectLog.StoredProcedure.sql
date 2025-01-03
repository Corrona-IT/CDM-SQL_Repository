USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_SubjectLog]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 02/23/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of new Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [AD550].[usp_op_SubjectLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar](50) NULL,
	[SubjectID] [nvarchar] (25) NOT NULL,
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
	  ,SFSiteStatus
INTO #SiteStatus
FROM [Reporting].[AD550].[v_SiteStatus]

--SELECT * FROM #SiteStatus

IF OBJECT_ID('tempdb.dbo.#Subjects') IS NOT NULL  DROP TABLE #Subjects 

SELECT DISTINCT CAST(SiteID AS int) AS SiteID
      ,SubjectID
	  ,patientId
      ,[Status]

INTO #Subjects
FROM [Reporting].[AD550].[v_op_subjects]
WHERE [status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #Subjects ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 

SELECT CAST(S.SiteID AS int) AS SiteID
      ,E.subNum AS SubjectID
	  ,E.subjectId AS PatientID
	  ,E.exit_date AS ExitDate
	  ,E.eventName AS VisitType
	  ,E.exit_reason_dec AS ExitReason
	  ,e.exit_reason_specify AS OtherExitReason

INTO #EXITS

FROM [RCC_AD550].[staging].[exitdetails] E
LEFT JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=E.[subjectId] AND S.[status] NOT IN ('Removed', 'Incomplete')


--SELECT * FROM #EXITS

IF OBJECT_ID('tempdb..#VisitLog') IS NOT NULL  DROP TABLE #VisitLog 

SELECT *

INTO #VisitLog

FROM 
(
SELECT S.[SiteID]
      ,S.[SubjectID]
	  ,S.PatientID
      ,(SELECT VL.[VisitDate] FROM [AD550].[t_op_VisitLog] VL WHERE VL.patientId=S.patientId AND VL.VisitType='Enrollment' AND ISNULL(VL.VisitDate, '')<>'') AS EnrollmentDate
	  ,(SELECT TOP(1) birthdate FROM [RCC_AD550].[staging].[subject] SD WHERE SD.subjectId=S.patientId) AS [YOB]
	  ,E.ExitDate
	  ,E.ExitReason
	  ,E.OtherExitReason AS ExitReasonDetails

FROM #Subjects S
LEFT JOIN #EXITS E ON E.PatientID=S.patientId AND E.SiteID=S.SiteID
) E
WHERE ISNULL(EnrollmentDate, '')<>''

--SELECT * FROM #VisitLog ORDER BY SiteID, SubjectID


TRUNCATE TABLE [Reporting].[AD550].[t_op_SubjectLog];

INSERT INTO [Reporting].[AD550].[t_op_SubjectLog]
(
	[SiteID],
	[SiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[EnrollmentDate],
	[YOB],
	[ExitDate],
	[ExitReason],
	[ExitReasonDetails]
)

SELECT VL.SiteID
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
	  ,VL.SubjectID
	  ,VL.EnrollmentDate
	  ,VL.[YOB]
	  ,VL.ExitDate
	  ,CASE WHEN ISNULL(VL.ExitDate, '')<>'' AND ISNULL(VL.ExitReason, '')<>'' THEN ExitReason
	   WHEN ISNULL(VL.ExitDate, '')<>'' AND ISNULL(VL.ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ''
	   END AS ExitReason
	  ,VL.ExitReasonDetails
FROM #VisitLog VL
LEFT JOIN #SiteStatus SS ON SS.SiteID=VL.SiteID
WHERE ISNULL(VL.SiteID, '') NOT IN ('', 1440)


--SELECT * FROM [Reporting].[AD550].[t_op_SubjectLog] ORDER BY SiteID, SubjectID

END

GO
