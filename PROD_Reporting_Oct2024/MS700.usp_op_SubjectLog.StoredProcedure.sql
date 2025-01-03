USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_SubjectLog]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


                                                                                                                                                                                                                                                                                                                                          













-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 02/23/2020
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/1/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of new Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [MS700].[usp_op_SubjectLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [MS700].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SubjectID] [bigint] NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (2000) NULL,

);
*/


IF OBJECT_ID('tempdb..#SiteStatus') IS NOT NULL  DROP TABLE #SiteStatus 

SELECT DISTINCT SS.SiteID
      ,SS.[SiteStatus]
	  ,RS.[currentStatus] AS SFSiteStatus
INTO #SiteStatus
FROM [MS700].[v_SiteStatus] SS
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=SS.SiteID AND RS.[name]='Multiple Sclerosis (MS-700)'

--SELECT * FROM #SiteStatus


IF OBJECT_ID('tempdb..#EXITS') IS NOT NULL  DROP TABLE #EXITS 

SELECT S.SiteID
      ,E.subNum AS SubjectID
	  ,E.subjectId AS PatientID
	  ,CASE
		WHEN E.exit_date = '' THEN NULL
		ELSE E.exit_date
		END AS ExitDate
	  ,E.eventName AS VisitType
	  ,E.exit_reason_dec AS ExitReason
	  ,e.exit_reason_specify AS OtherExitReason

INTO #EXITS

FROM [RCC_MS700].[staging].[exitstatus] E
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON S.patientId=E.[subjectId] 
AND S.SiteID<>1440
WHERE E.exit_date IS NOT NULL OR E.exit_reason_dec IS NOT NULL


--SELECT * FROM #EXITS

IF OBJECT_ID('tempdb..#VisitLog') IS NOT NULL  DROP TABLE #VisitLog 

SELECT VL.[SiteID]
      ,VL.[SubjectID]
	  ,VL.PatientID
      ,VL.[VisitType]
      ,VL.[VisitSequence]
      ,VL.[VisitDate] AS EnrollmentDate
	  ,D.birthdate AS [YOB]
	  ,E.ExitDate
	  ,E.ExitReason
	  ,E.OtherExitReason AS ExitReasonDetails

INTO #VisitLog

FROM [MS700].[v_op_VisitLog] VL
LEFT JOIN [RCC_MS700].[staging].[subjectdemography] D ON VL.PatientID=D.subjectId AND D.eventId=3042 
LEFT JOIN #EXITS E ON E.PatientID=VL.PatientID AND E.SiteID=VL.SiteID
WHERE VL.eventId=3042
AND VL.EligibleVisit='Yes'

--SELECT * FROM #VisitLog

TRUNCATE TABLE [Reporting].[MS700].[t_op_SubjectLog];

INSERT INTO [Reporting].[MS700].[t_op_SubjectLog]
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
	  ,CASE 
	   WHEN ISNULL(VL.ExitDate, '')<>'' AND ISNULL(VL.ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ExitReason
	   END AS ExitReason
	  ,VL.ExitReasonDetails
FROM #VisitLog VL
LEFT JOIN #SiteStatus SS ON SS.SiteID=VL.SiteID

--SELECT * FROM [Reporting].[MS700].[t_op_SubjectLog] ORDER BY SiteID, SubjectID

END




GO
