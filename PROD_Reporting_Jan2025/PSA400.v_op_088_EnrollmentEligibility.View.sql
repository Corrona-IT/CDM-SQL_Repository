USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_088_EnrollmentEligibility]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [PSA400].[v_op_088_EnrollmentEligibility] AS

WITH ReimburseView AS
(
SELECT SourceVisitID
      ,SUBNUM
	  ,REVNUM
	  ,SourceVisitSeq
	  ,PAGENAME
	  ,PAGEDISPLAY
	  ,PAGEID
	  ,PAGESEQ
	  ,DRUG_NAME
	  ,DRUG_NAME_DEC
	  ,DRUG_NO_PRIOR_USE
	  ,DRUG_RX_TODAY
	  ,DRUG_RX_TODAY_DEC
	  ,EligibleForEval
	  ,Originator
	  ,OriginatorGroup
	  ,Diagnosed_DATA
	  ,IncidentUse_LOGIC
	  ,CurrentUse_LOGIC
	  ,CurrentUse_DATA
	  ,FormTypeName
	  ,EFU
	  ,VisitDate
	  ,StartDate
	  ,EndDate
	  ,DrugReqSatisfied
	  ,Payment_Add
FROM [Reimbursement].[cdb_spa].[v_Drugs_PrescAtVisit_PriorUse] WHERE FormTypeName = 'MDEN'
)

,VISDT AS
(
SELECT SITENUM, 
       SUBNUM, 
	   VISITDATE, 
	   VISNAME 
FROM MERGE_SPA.dbo.VS_01 
WHERE VisitID IN (10, 11)
)

,Diagnose AS
(
SELECT D.SITENUM, 
       E.SUBID, 
	   E.SUBNUM, 
	   DX_PA, 
	   DX_AS 
FROM MERGE_SPA.dbo.EP_01 E
JOIN [MERGE_SPA].[dbo].[DAT_SUB] D on E.Subid=D.Subid AND E.SUBNUM=D.SUBNUM
UNION
SELECT D.SITENUM, 
       E.SUBID, 
	   E.SUBNUM, 
	   DX_PA, 
	   DX_AS 
FROM MERGE_SPA.dbo.EPRO_01 E
JOIN [MERGE_SPA].[dbo].[DAT_SUB] D on E.Subid=D.Subid AND E.SubNum=D.SUBNUM 
)

SELECT R.Revnum AS RevNum
      ,V.SiteNum AS SiteID
	  ,R.SubNum AS SubjectID
	  ,V.VisitDate AS VisitDate
	  ,Diagnosed_DATA AS Diagnosis
	  ,R.PageDisplay AS PageDisplayName
	  ,R.Drug_Name_DEC AS DrugName
	  ,R.Drug_No_Prior_Use AS NoPriorUse
	  ,R.Drug_Rx_Today_DEC AS ChangesToday
	  ,CAST(R.EligibleForEval AS INT) AS EligibleDrug
	  ,CAST(R.Originator as INT) AS Originator
	  ,R.OriginatorGroup AS DrugGroup
	  ,R.[DrugReqSatisfied] AS DrugRequirementSatisfied
FROM ReimburseView R 
JOIN VISDT V on R.SUBNUM=V.SUBNUM 
JOIN Diagnose on Diagnose.SUBNUM=R.SUBNUM
WHERE V.SITENUM NOT IN (99997, 99998, 99999)

---ORDER BY SiteID, SubjectID





GO
