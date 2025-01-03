USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_085_ExitReport]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [PSA400].[v_op_085_ExitReport]  as 

----Get Exit Page 1 Information from EX_01 and EXIT_01
WITH EXINFO AS
(
SELECT SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,VISNAME AS VisitType
	  ,DISCONTINUE_DATE AS DateQuestionnaireCompleted
	  ,PHYSICIAN_COD AS ProviderID
	  ,EXIT_REASON_DEC AS ExitReason
	  ,OTHER_SPECIFY AS ExitReasonOther
	  ,STATUSID_DEC AS ExitPageStatus
FROM MERGE_SPA.dbo.EX_01 
WHERE STATUSID IN (5, 10, 15, 20, 25, 30)
AND DISCONTINUE_DATE <> ''


UNION 


SELECT SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,VISNAME AS VisitType
	  ,DISCONTINUE_DATE AS DateQuestionnaireCompleted
	  ,MD_COD AS ProviderID
	  ,EXIT_REASON_DEC AS ExitReason
	  ,OTHER_SPECIFY AS ExitReasonOther
	  ,STATUSID_DEC AS ExitPageStatus
FROM MERGE_SPA.dbo.EXIT_01 
WHERE STATUSID IN (5, 10, 15, 20, 25, 30)
AND DISCONTINUE_DATE <> ''

)

SELECT A.SiteID
      ,A.SubjectID
	  ,A.VisitType
	  ,A.DateQuestionnaireCompleted
	  ,A.ProviderID
	  ,A.ExitReason
	  ,A.ExitReasonOther
	  ,A.ExitPageStatus
FROM EXINFO A
--ORDER BY A.SiteID, A.SubjectID, A.VisitType, A.DateQuestionnaireCompleted






GO
