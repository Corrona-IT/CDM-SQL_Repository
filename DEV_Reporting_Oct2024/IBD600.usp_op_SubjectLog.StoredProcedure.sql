USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_SubjectLog]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 04/16/2019
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/1/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of new Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [IBD600].[usp_op_SubjectLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_op_SubjectLog]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar] (10) NULL,
	[SFSiteStatus] [nvarchar] (75) NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[EnrollmentDate] [date] NOT NULL,
	[YOB] [int] NULL,
	[ExitDate] [date] NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (2000) NULL,

);
*/



IF OBJECT_ID('temp.dbo.#SiteStatus') IS NOT NULL BEGIN DROP TABLE #SiteStatus END

SELECT DISTINCT(CAST(SITENUM AS int)) AS SiteID
      ,CASE WHEN ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
	  ,RS.currentStatus AS SFSiteStatus
INTO #SiteStatus
FROM [MERGE_IBD].[dbo].[DAT_SITES] S
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=S.SITENUM AND RS.[name]='Inflammatory Bowel Disease (IBD-600)'

--SELECT * FROM #SiteStatus

IF OBJECT_ID('tempdb..#VisitLog') IS NOT NULL BEGIN DROP TABLE #VisitLog END

SELECT DISTINCT CAST(DP.SITENUM AS bigint) AS [SiteID]
      ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,DP.SUBNUM AS [SubjectID]
	  ,CAST(VIS.VISITDATE AS date) AS [EnrollmentDate]
	  ,PTDEM.BIRTHDATE AS YOB
	  --V1 ExitDate
	  --,EX.DISCONTINUE_DT AS ExitDate
	  --V1.1 ExitDate
	  ,CASE
		WHEN EX.DISCONTINUE_DT = '' THEN NULL
		ELSE EX.DISCONTINUE_DT
		END AS ExitDate
	  ,EX.EXIT_REASON_DEC AS ExitReason
	  ,EX.EXIT_REASON_OTH_TXT AS ExitReasonDetails

INTO #VisitLog --SELECT * 
FROM MERGE_IBD.staging.DAT_PAGS AS DP 
LEFT OUTER JOIN MERGE_IBD.staging.VISIT AS VIS ON VIS.SUBID = DP.SUBID AND VIS.vID = DP.vID
LEFT JOIN [MERGE_IBD].[staging].[PT_DEMOG] PTDEM ON DP.SUBNUM=PTDEM.SUBNUM AND VIS.vID = PTDEM.vID
LEFT JOIN #SiteStatus SS ON SS.SiteID=DP.SITENUM
LEFT JOIN MERGE_IBD.staging.[EXIT] EX ON EX.SUBID = DP.SUBID
WHERE DP.PAGENAME = 'Visit Date'
AND DP.VISNAME='Enrollment'
AND (ISNULL(VIS.VISITDATE, '')<>'' OR EXIT_REASON IS NOT NULL)

--SELECT * FROM #VisitLog

TRUNCATE TABLE [Reporting].[IBD600].[t_op_SubjectLog];


INSERT INTO [Reporting].[IBD600].[t_op_SubjectLog]
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

SELECT SiteID
      ,SiteStatus
	  ,SFSiteStatus
	  ,SubjectID
	  ,EnrollmentDate
	  ,YOB
	  ,ExitDate
	  ,CASE WHEN ISNULL(ExitDate, '')<>'' AND ISNULL(ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ExitReason
	   END AS ExitReason
	  ,ExitReasonDetails
FROM #VisitLog
WHERE ISNULL(EnrollmentDate, '')<>''


--SELECT * FROM [Reporting].[IBD600].[t_op_SubjectLog]

END



GO
