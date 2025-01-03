USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_IncompleteVisits]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*This view is not being used - it is an attempt at writing directly from data tables instead of audit trail, but unable to match other report as of 27Mar2024*/

CREATE VIEW [IBD600].[v_op_IncompleteVisits] AS


WITH INCOMPLETEVISITS AS
(
SELECT V.SITENUM AS SiteID
      ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,V.VISITSEQ AS VisitSequence
	  ,VISCOMP.VISIT_COMPLETE AS MarkedComplete
	  ,CAST(V.VISITDATE AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
	  ,R.VISIT_PAID
	  ,R.PAY_3_1100
FROM [MERGE_IBD].[staging].[VISIT] V
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON V.vID=VISCOMP.vID
LEFT JOIN [MERGE_IBD].[staging].[REIMB] R ON R.vID=VISCOMP.vID
WHERE 1=1
AND VISITDATE IS NOT NULL
AND VISCOMP.VISIT_COMPLETE IS NULL
AND ISNULL(VISIT_PAID, '')=''
--ORDER BY SiteID, SubjectID, VisitDate, VisitSequence

UNION

SELECT E.SITENUM AS SiteID
      ,E.SUBNUM AS SubjectID
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
WHERE DISCONTINUE_DT IS NOT NULL
AND VISCOMP.EXIT_COMPLETE IS NULL
AND ISNULL(R.VISIT_PAID, '')=''


UNION

SELECT P.SITENUM AS SiteID
      ,P.SUBNUM AS SubjectID
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
WHERE PEQ_FC_DT IS NOT NULL
AND PEQ_RPT_TYPE_DEC NOT IN ('Not an event','Pregnancy previously reported to Corrona (duplicate)', 'Pregnancy previously reported (duplicate)')
AND VISCOMP.PREGNANCY_COMPLETE IS NULL
AND ISNULL(R.VISIT_PAID, '')=''

UNION

SELECT T.SITENUM AS SiteID
      ,T.SUBNUM AS SubjectID
	  ,T.VISNAME AS VisitType
	  ,T.VISITSEQ AS VisitSequence
	  ,VISCOMP.TAE_COMPLETE --as MarkedComplete
	  ,CAST(T.AE_FORM_COMPLETED_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
	  ,R.visit_paid
	  ,R.PAY_3_1100
FROM [MERGE_IBD].[staging].[TAE] T
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON T.vID=VISCOMP.vID AND T.VISNAME=VISCOMP.VISNAME AND T.SUBID=VISCOMP.SUBID AND T.VISITSEQ=VISCOMP.VISITSEQ
LEFT JOIN [MERGE_IBD].[staging].[REIMB] R ON R.vID=T.vID AND R.VISNAME=T.VISNAME AND R.SUBID=T.SUBID AND R.VISITSEQ=R.VISITSEQ
WHERE AE_FORM_COMPLETED_DT IS NOT NULL
AND AE_RPT_STATUS_DEC NOT IN ('Not an event','Previously reported to Corrona as a TAE (duplicate)', 'Previously reported (duplicate)')
AND ISNULL(VISCOMP.TAE_COMPLETE, '')=''
AND ISNULL(R.VISIT_PAID, '')=''
--AND t.sitenum=6062   --'60622580014'
)


SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VisitSequence
	  ,VisitDate
	  ,CompletionStatus
FROM INCOMPLETEVISITS
--order by SiteID, SubjectID

GO
