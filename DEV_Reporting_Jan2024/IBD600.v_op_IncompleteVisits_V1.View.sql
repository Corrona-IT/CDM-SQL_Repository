USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_IncompleteVisits_V1]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [IBD600].[v_op_IncompleteVisits_V1] AS


WITH INCOMPLETEVISITS AS
(
SELECT CAST(V.SITENUM AS int) AS SiteID
      ,V.SUBNUM AS SubjectID
	  ,V.VISNAME AS VisitType
	  ,CAST(V.VISITSEQ AS int) AS VisitSequence
	  ,VISCOMP.VISIT_COMPLETE AS MarkedComplete
	  ,CAST(V.VISITDATE AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
FROM [MERGE_IBD].[staging].[VISIT] V
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON V.vID=VISCOMP.vID
WHERE VISITDATE IS NOT NULL
AND VISCOMP.VISIT_COMPLETE IS NULL

UNION

SELECT CAST(E.SITENUM AS int) AS SiteID
      ,E.SUBNUM AS SubjectID
	  ,E.VISNAME AS VisitType
	  ,CAST(E.VISITSEQ AS int) AS VisitSequence
	  ,VISCOMP.EXIT_COMPLETE as MarkedComplete
	  ,CAST(E.DISCONTINUE_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
FROM [MERGE_IBD].[staging].[EXIT] E
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON E.vID=VISCOMP.vID
WHERE DISCONTINUE_DT IS NOT NULL
AND VISCOMP.EXIT_COMPLETE IS NULL

UNION

SELECT CAST(P.SITENUM AS int) AS SiteID
      ,P.SUBNUM AS SubjectID
	  ,P.VISNAME AS VisitType
	  ,CAST(P.VISITSEQ AS int) AS VisitSequence
	  ,VISCOMP.PREGNANCY_COMPLETE as MarkedComplete
	  ,CAST(P.PEQ_FC_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
FROM [MERGE_IBD].[staging].[PEQ] P
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON P.vID=VISCOMP.vID
WHERE PEQ_FC_DT IS NOT NULL
AND VISCOMP.PREGNANCY_COMPLETE IS NULL

UNION

SELECT CAST(T.SITENUM AS int) AS SiteID
      ,T.SUBNUM AS SubjectID
	  ,T.VISNAME AS VisitType
	  ,CAST(T.VISITSEQ AS int) AS VisitSequence
	  ,VISCOMP.TAE_COMPLETE as MarkedComplete
	  ,CAST(T.AE_FORM_COMPLETED_DT AS date) AS VisitDate
	  ,'Incomplete' AS CompletionStatus
FROM [MERGE_IBD].[staging].[TAE] T
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VISCOMP ON T.vID=VISCOMP.vID
WHERE AE_FORM_COMPLETED_DT IS NOT NULL
AND VISCOMP.TAE_COMPLETE IS NULL
	
)


SELECT SiteID
      ,SubjectID
	  ,VisitType
	  ,VisitSequence
	  ,VisitDate
	  ,CompletionStatus
FROM INCOMPLETEVISITS


GO
