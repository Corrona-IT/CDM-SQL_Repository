USE [Reporting]
GO
/****** Object:  StoredProcedure [IBD600].[usp_op_IncompleteVisits]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ================================================================
-- Author:		Kaye Mowrey
-- Create date: 16Aug2024
-- Description:	Procedure for Site Report Data Entry Completion
-- ================================================================


CREATE PROCEDURE [IBD600].[usp_op_IncompleteVisits] AS


BEGIN
	SET NOCOUNT ON;

/*
CREATE TABLE [IBD600].[t_op_IncompleteVisits]
(
       [SiteID] [int] NOT NULL,
	   [SiteStatus] [nvarchar] (20) NULL,
	   [SFSiteStatus] [nvarchar] (50) NULL,
       [SubjectID] [nvarchar] (30) NULL,
	   [SUBID] [varchar] (30) NULL,
	   [VisitType] [nvarchar](50) NULL,
	   [VisitSequence] [int] NULL,
	   [VisitDate] [date] NULL,
	   [CompletionStatus] [nvarchar] (30) NULL
);
*/


/******Get list of Incomplete and Unpaid Visits******/

IF OBJECT_ID('tempdb.dbo.#IncompleteVisits') IS NOT NULL BEGIN DROP TABLE #IncompleteVisits END

SELECT DISTINCT *
INTO #IncompleteVisits
FROM 
(
SELECT V.SITENUM AS SiteID
	  ,SS.SiteStatus
	  ,SS.SFSiteStatus
      ,V.SUBNUM AS SubjectID
	  ,V.SUBID
	  ,V.VISNAME AS VisitType
	  ,V.VISITSEQ AS VisitSequence
	  ,VISCOMP.VISIT_COMPLETE AS MarkedComplete
	  ,CAST(V.VISITDATE AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
	  ,R.VISIT_PAID
	  ,R.PAY_3_1100
FROM [MERGE_IBD].[staging].[VISIT] V
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON V.vID=VISCOMP.vID
LEFT JOIN [MERGE_IBD].[staging].[REIMB] R ON R.vID=V.vID
LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=V.SITENUM
WHERE 1=1
AND VISITDATE IS NOT NULL
AND VISCOMP.VISIT_COMPLETE IS NULL
AND ISNULL(VISIT_PAID, '')=''
AND R.PAY_3_1100 IS NULL

--ORDER BY SiteID, SubjectID, VisitDate, VisitSequence

UNION

SELECT E.SITENUM AS SiteID
		,SS.SiteStatus
		,SS.SFSiteStatus
      ,E.SUBNUM AS SubjectID
	  ,E.SUBID
	  ,E.VISNAME AS VisitType
	  ,E.VISITSEQ AS VisitSequence
	  ,VISCOMP.EXIT_COMPLETE as MarkedComplete
	  ,CAST(E.DISCONTINUE_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
	  ,R.VISIT_PAID
	  ,R.PAY_3_1100
FROM [MERGE_IBD].[staging].[EXIT] E
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON E.vID=VISCOMP.vID
LEFT JOIN [MERGE_IBD].[staging].[REIMB] R ON R.vID=E.vID
LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=E.SITENUM
WHERE DISCONTINUE_DT IS NOT NULL
AND VISCOMP.EXIT_COMPLETE IS NULL
AND ISNULL(R.VISIT_PAID, '')=''
AND R.PAY_3_1100 IS NULL


UNION

SELECT P.SITENUM AS SiteID
		,SS.SiteStatus
		,SS.SFSiteStatus
      ,P.SUBNUM AS SubjectID
	  ,P.SUBID
	  ,P.VISNAME AS VisitType
	  ,P.VISITSEQ AS VisitSequence
	  ,VISCOMP.PREGNANCY_COMPLETE as MarkedComplete
	  ,CAST(P.PEQ_FC_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
	  ,R.visit_paid
	  ,R.PAY_3_1100
FROM [MERGE_IBD].[staging].[PEQ] P
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON P.vID=VISCOMP.vID
LEFT JOIN [MERGE_IBD].[staging].[REIMB] R ON R.vID=P.vID
LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=P.SITENUM
WHERE PEQ_FC_DT IS NOT NULL
AND PEQ_RPT_TYPE_DEC NOT IN ('Not an event','Pregnancy previously reported to Corrona (duplicate)', 'Pregnancy previously reported (duplicate)')
AND VISCOMP.PREGNANCY_COMPLETE IS NULL
AND ISNULL(R.VISIT_PAID, '')=''
AND R.PAY_3_1100 IS NULL

UNION

SELECT T.SITENUM AS SiteID
		,SS.SiteStatus
		,SS.SFSiteStatus
      ,T.SUBNUM AS SubjectID
	  ,T.SUBID
	  ,T.VISNAME AS VisitType
	  ,T.VISITSEQ AS VisitSequence
	  ,VISCOMP.TAE_COMPLETE as MarkedComplete
	  ,CAST(T.AE_FORM_COMPLETED_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
	  ,R.visit_paid
	  ,R.PAY_3_1100
FROM [MERGE_IBD].[staging].[TAE] T
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON T.vID=VISCOMP.vID AND T.VISNAME=VISCOMP.VISNAME AND T.SUBID=VISCOMP.SUBID AND T.VISITSEQ=VISCOMP.VISITSEQ
LEFT JOIN [MERGE_IBD].[staging].[REIMB] R ON R.vID=T.vID AND R.VISNAME=T.VISNAME AND R.SUBID=T.SUBID AND R.VISITSEQ=R.VISITSEQ
LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=T.SITENUM
WHERE AE_FORM_COMPLETED_DT IS NOT NULL
AND AE_RPT_STATUS_DEC NOT IN ('Not an event','Previously reported to Corrona as a TAE (duplicate)', 'Previously reported (duplicate)')
AND ISNULL(VISCOMP.TAE_COMPLETE, '')=''
AND ISNULL(R.VISIT_PAID, '')=''
AND R.PAY_3_1100 IS NULL

) ic

--SELECT * FROM #IncompleteVisits ORDER BY SubjectID, VisitDate


/******Get List of Completed (No Records) Visits******/

IF OBJECT_ID('tempdb.dbo.#NoRecords') IS NOT NULL BEGIN DROP TABLE #NoRecords END

SELECT SP.SiteID
	,SS.SiteStatus
	,SS.SFSiteStatus
	,'' AS SubjectID
	,NULL AS SUBID
	,'' AS VisitType
	,'' AS VisitID
	,'' AS VisitSequence
	,CAST(NULL AS date) AS VisitDate
	,'All records completed' AS [CompletionStatus]
	,'' AS PAY_3_1100 
INTO #NoRecords
FROM [IBD600].[v_SiteParameter] SP
LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
WHERE SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM #IncompleteVisits)


TRUNCATE TABLE [Reporting].[IBD600].[t_op_IncompleteVisits]

INSERT INTO [Reporting].[IBD600].[t_op_IncompleteVisits]
(
[SiteID],
[SiteStatus],
[SFSiteStatus],
[SubjectID],
[SUBID],
[VisitType],
[VisitSequence],
[VisitDate],
[CompletionStatus]
)

SELECT DISTINCT [SiteID],
[SiteStatus],
[SFSiteStatus],
[SubjectID],
[SUBID],
[VisitType],
[VisitSequence],
[VisitDate],
[CompletionStatus]
FROM #IncompleteVisits

UNION

SELECT DISTINCT [SiteID],
[SiteStatus],
[SFSiteStatus],
[SubjectID],
[SUBID],
[VisitType],
[VisitSequence],
[VisitDate],
[CompletionStatus]
FROM #NoRecords


--SELECT * FROM [Reporting].[IBD600].[t_op_IncompleteVisits] WHERE SiteID = 6084 ORDER BY SiteID, SubjectID, VisitDate

END

GO
