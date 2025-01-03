USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_EarlyFU]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =========================================================
-- Author:		Kaye Mowrey
-- Create date: 2/11/2020
-- Description:	Procedure for Early Follow Up (t_op_EarlyFU)
-- =========================================================


CREATE PROCEDURE [IBD600].[usp_op_EarlyFU] AS
	-- Add the parameters for the stored procedure here


BEGIN
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_op_EarlyFU]
(
       [SiteID] [int] NOT NULL,
	   [SiteStatus] [nvarchar] (20) NULL,
	   [SFSiteStatus] [nvarchar] (50) NULL,
       [SubjectID] [nvarchar] (20) NOT NULL,
	   [SUBID] [bigint] NOT NULL,
	   [ProviderID] [int] NULL,
	   [VisitType] [nvarchar](50) NULL,
	   [CalcVisitSequence] [int] NULL,
	   [VisitSequence] [int] NULL,
	   [VisitDate] [date] NULL,
	   [PreviousVisitDate] [date] NULL,
	   [EligibleVisit] [nvarchar] (10) NULL,
	   [DaysSinceLastVisit] [bigint] NULL,
	   [BioRepositoryAssoc] [nvarchar] (10) NULL,
	   [BioRepositoryVisitType] [nvarchar] (200) NULL,
	   [OutOfWindow] [nvarchar](50) NULL,
	   [EarlyVisitRulesSatisfied] [nvarchar](50) NULL,
	   [ExceptionGranted] [nvarchar](50) NULL,
	   [ExceptionReason] [nvarchar](250) NULL,
	   [VisitPaid] [nvarchar] (10) NULL
);
*/


/******Get list of Visits******/

IF OBJECT_ID('tempdb.dbo.#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT DISTINCT V.[vID]
      ,V.[SiteID]
      ,V.[SiteStatus]
	  ,V.[SFSiteStatus]
      ,V.[SubjectID]
      ,V.[SUBID]
      ,V.[VisitType]
      ,V.[VisitDate]
      ,V.[ProviderID]
	  ,V.[calcVisitSequence]
      ,V.[VisitSequence]
	  ,V.EligibleVisit
	  ,V.BioRepositoryAssoc
	  ,V.BioRepositoryVisitType
INTO #Visits
FROM [Reporting].[IBD600].[v_op_VisitLog] V
WHERE ISNULL(V.VisitDate, '')<>''
  AND V.VisitType IN ('Enrollment', 'Follow-Up') 

--SELECT * FROM #Visits ORDER BY SubjectID, VisitDate


/******Determine days since last visit and get reimbursement information******/

IF OBJECT_ID('tempdb.dbo.#DaysSinceLastVisit') IS NOT NULL BEGIN DROP TABLE #DaysSinceLastVisit END

SELECT A.vID
      ,A.SiteID
      ,A.SiteStatus
	  ,A.SFSiteStatus
      ,A.SubjectID
	  ,A.SUBID
	  ,A.ProviderID
	  ,A.VisitType
	  ,A.calcVisitSequence
	  ,A.VisitSequence
	  ,A.VisitDate
	  ,A.PreviousVisitDate
	  ,A.EligibleVisit
	  ,A.BioRepositoryAssoc
	  ,A.BioRepositoryVisitType
	  ,DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate) AS DaysSinceLastVisit
	  ,CASE WHEN (OutOfWindow='Yes' OR DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate)<150) THEN 'Yes' ELSE '' END AS OutOfWindow
	  ,CASE WHEN (OutOfWindow='Yes' OR DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate)<150) AND ISNULL(ExceptionGranted, '')='' AND ISNULL(EarlyVisitRulesSatisified, '')='' AND VisitPaid='Yes' THEN 'Unknown-paid visit'
	   WHEN (OutOfWindow='Yes' OR DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate)<150) AND ISNULL(ExceptionGranted, '')='' AND ISNULL(EarlyVisitRulesSatisified, '')='' AND ISNULL(VisitPaid,'')='' THEN 'Not reviewed'
	   WHEN DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate) >= 150 AND EarlyVisitRulesSatisified='No' AND ExceptionGranted='No' THEN 'No - internal fields need review'
	   ELSE EarlyVisitRulesSatisified
	   END AS EarlyVisitRulesSatisified
	  ,ExceptionGranted
	  ,ExceptionReason
	  ,VisitPaid
INTO #DaysSinceLastVisit
FROM
(
SELECT V.vID
      ,V.SiteID
      ,V.SiteStatus
	  ,V.SFSiteStatus
      ,V.SubjectID
	  ,V.SUBID
	  ,V.ProviderID
	  ,V.VisitType
	  ,V.calcVisitSequence
	  ,V.VisitSequence
	  ,V.VisitDate
	  ,(SELECT MAX(VisitDate) FROM #Visits V2 WHERE V2.SiteID=V.SiteID AND V2.SUBID=V.SUBID AND V.VisitDate>V2.VisitDate AND V2.EligibleVisit IN ('', 'Yes')) AS PreviousVisitDate
	  ,V.EligibleVisit
	  ,V.BioRepositoryAssoc
	  ,V.BioRepositoryVisitType
	  ,CASE WHEN REIMB.OOW_FU_DETECTED='X' THEN 'Yes' 
	   ELSE '' 
	   END AS OutOfWindow
	  ,REIMB.OOW_FU_PERMITTED_DEC AS EarlyVisitRulesSatisified
	  ,REIMB.OOW_FU_EXCEPTION_DEC AS ExceptionGranted
	  ,REIMB.OOW_FU_EXCEPTION_RSN AS ExceptionReason
	  ,CASE WHEN REIMB.VISIT_PAID='X' THEN 'Yes' ELSE REIMB.VISIT_PAID END AS VisitPaid
FROM #Visits V
LEFT JOIN [MERGE_IBD].[staging].[REIMB] REIMB ON REIMB.SUBNUM=V.SubjectID AND REIMB.vID=V.vID
AND REIMB.PAGENAME='Visit Date'
WHERE ISNULL(V.VisitDate, '')<>''
) A
--SELECT * FROM [MERGE_IBD].[staging].[REIMB] REIMB where pay_3_1100='X'  and visit_paid_exception is null
--SELECT * FROM #DaysSinceLastVisit ORDER BY SiteID, SubjectID, VisitDate

TRUNCATE TABLE [Reporting].[IBD600].[t_op_EarlyFU]

INSERT INTO [Reporting].[IBD600].[t_op_EarlyFU]
(
[SiteID],
[SiteStatus],
[SFSiteStatus],
[SubjectID],
[SUBID],
[ProviderID],
[VisitType],
[CalcVisitSequence],
[VisitSequence],
[VisitDate],
[PreviousVisitDate],
[EligibleVisit],
[DaysSinceLastVisit],
[BioRepositoryAssoc],
[BioRepositoryVisitType],
[OutOfWindow],
[EarlyVisitRulesSatisfied],
[ExceptionGranted],
[ExceptionReason],
[VisitPaid]
)

SELECT DISTINCT [SiteID],
		[SiteStatus],
		[SFSiteStatus],
		[SubjectID],
		[SUBID],
		[ProviderID],
		[VisitType],
		[CalcVisitSequence],
		[VisitSequence],
		[VisitDate],
		[PreviousVisitDate],
		[EligibleVisit],
		[DaysSinceLastVisit],
		[BioRepositoryAssoc],
		[BioRepositoryVisitType],
		[OutOfWindow],
		[EarlyVisitRulesSatisified],
		[ExceptionGranted],
		[ExceptionReason],
		[VisitPaid]
FROM #DaysSinceLastVisit LV
WHERE (DaysSinceLastVisit>=150 AND EarlyVisitRulesSatisified='No' AND ExceptionGranted = 'No')
OR (DaysSinceLastVisit<150 OR OutOfWindow='Yes')


--SELECT * FROM [Reporting].[IBD600].[t_op_EarlyFU] ORDER BY SiteID, SubjectID, VisitDate

END

GO
