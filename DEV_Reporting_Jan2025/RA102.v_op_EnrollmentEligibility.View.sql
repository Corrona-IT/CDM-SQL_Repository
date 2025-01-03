USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_EnrollmentEligibility]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =================================================
-- Author:		Kevin Soe
-- Create date: 3/29/2021
-- Description:	View for Updated Enrollment Eligibility
-- =================================================



CREATE VIEW [RA102].[v_op_EnrollmentEligibility]  AS

/*Obtain list of eligible or prescribed at visit drugs from Reimbursement Eligibility view. Ensure MTX is renamed to always sort to bottom.*/

WITH EligList AS
(
SELECT 
	   CASE WHEN PP.[Drug]='MTX' THEN 'ZZ_MTX'
			ELSE PP.[Drug]
			END AS 
		   [DrugOrder] 
	   ,PP.[SourceVisitID]
	   ,PP.[VisitTypeID]
	   ,PP.[EDCFormID]
	   ,PP.[SubjectID]
	   ,EE.[Visitdate]
	   ,PP.[Drug]
	   ,PP.[DrugNameOther]
	   ,PP.[EligibleDrug]
	   ,PP.[Originator]
	   ,PP.[OriginatorGroup]
	   ,PP.[PrescAtVisit]
	   ,PP.[PriorUse]
	   ,PP.[EnrolledOnTheOriginator]
	   ,PP.[DrugReqSatisfied] 
	   FROM [Reimbursement].[cdb_rajp].[v_EnrollmentEligibility] EE
	   LEFT JOIN [Reimbursement].[cdb_rajp].[v_Drugs_PrescAtVisit_PriorUse] PP ON EE.[SourceVisitID] = PP.[SourceVisitID]
	   WHERE [EligibleDrug] = '1' OR [PrescAtVisit] = '1'
),

/*Order drugs so drugs that satisfy requirements, eligible drugs, and drugs prescribed at visit are always ordered above all other drugs.*/

OrderedDrugs AS
(
SELECT  
		ROW_NUMBER() OVER(PARTITION BY [SubjectID], [VisitDate] ORDER BY [SubjectID], [VisitDate], [DrugReqSatisfied] DESC, [EligibleDrug] DESC, [PrescAtVisit] DESC, [DrugOrder]) AS [RowNumber] 
	   ,[SourceVisitID]
	   ,[VisitTypeID]
	   ,[EDCFormID]
	   ,[SubjectID]
	   ,[VisitDate]
	   ,[Drug]
	   ,[DrugNameOther]
	   ,[EligibleDrug]
	   ,[Originator]
	   ,[OriginatorGroup]
	   ,[PrescAtVisit]
	   ,[PriorUse]
	   ,[EnrolledOnTheOriginator]
	   ,[DrugReqSatisfied]
	   FROM EligList
),

/*Select the top drug from ordered list of drugs for each subject.*/

EligibleDrugs AS
(
SELECT
	   *
	   FROM OrderedDrugs
	   WHERE [RowNumber] = '1'
),

/*Combine with visit log and EDC data and calculate eligibility status and eligibility review columns*/

EnrolledList AS 
(
SELECT  DISTINCT
	   VL.[vID]
      ,VL.[SiteID]
	  ,RS.[currentStatus]
      ,VL.[SubjectID]
      ,VL.[VisitType]
      ,VL.[ProviderID]
	  ,VL.[VisitDate]
	  ,SB.[IDENT2] AS [YOB-Sub]
	  ,CASE 
		WHEN YEAR(VL.[VisitDate]) - SB.[IDENT2] >= 18 THEN 'Yes'
		ELSE 'No'
		END AS [AtLeast18]
	  ,EE.[YR_ONSET_RA] AS [YearRAOnset]
	  --Add [DrugNameOther] to spec
	  --Need to figure out the correct way to bring Eligible drug in
	  ,CASE WHEN ED.[DrugNameOther] = 'upadacitinib (Rinvoq)' THEN 'RINVOQ'
			WHEN ED.[DrugNameOther] = 'peficitinib (Smyraf)' THEN 'SMYRAF' 
			WHEN ED.[DrugNameOther] = 'filgotinib (Jyseleca)' THEN 'JYSELECA'
			ELSE ED.[Drug]
	   END AS [Drug]
	  ,CASE WHEN ED.[DrugNameOther] = 'upadacitinib (Rinvoq)' THEN ''
			WHEN ED.[DrugNameOther] = 'peficitinib (Smyraf)' THEN '' 
			WHEN ED.[DrugNameOther] = 'filgotinib (Jyseleca)' THEN ''
			ELSE ED.[DrugNameOther]
	   END AS [DrugNameOther] 
	  ,ED.[EligibleDrug]
	  ,CASE WHEN ED.[PrescAtVisit] = '1' THEN 'Yes' ELSE 'No' END AS [PrescAtVisit]
	  ,CASE WHEN ED.[PriorUse] = '1' THEN 'Yes' ELSE 'No' END AS [PriorUse]
	  ,ED.[DrugReqSatisfied]
	  ,VS.[INELIGIBLE]
	  ,VS.[INELIGIBLE_DEC] AS [PatientEligible]
	  ,VS.[INELIGIBLE_EXCEPTION]
	  ,VS.[INELIGIBLE_EXCEPTION_DEC] AS [EligibilityException]
	  ,VS.[INELIGIBLE_RSN]
	  ,VS.[INELIGIBLE_RSN_DEC] AS [IneligibleReason]
	  /*INELIGIBLE Codelist 1 = Yes 0 = No 2 = Under review (outcome TBD) 
	    INELIGIBLE_EXCEPTION Codelist 1 = Yes 0 = No
		INELIGIBLE_RSN Codelist 1 = Wrong diagnosis 2 = Not on an eligible medication 3 = Too young 4 = Other*/
	  ,CASE WHEN VS.[INELIGIBLE] = '1' THEN 'Eligible'
			WHEN VS.[INELIGIBLE] = '2' THEN 'Under Review'
			WHEN VS.[INELIGIBLE] = '0' AND VS.[INELIGIBLE_EXCEPTION] = '1' THEN 'Eligible'
			WHEN VS.[INELIGIBLE] = '0' AND VS.[INELIGIBLE_EXCEPTION] <> '1' THEN 'Not Eligible'
			ELSE NULL
			END AS 
	   [EligibilityReview]
  FROM [Reporting].[RA102].[v_op_VisitLog] VL
  LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[siteNumber] =CAST(VL.[SiteID] AS nvarchar)
  LEFT JOIN [MERGE_RA_Japan].[dbo].[DAT_SUB] SB ON SB.[SUBNUM] = VL.[SubjectID]
  LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VS ON VS.[SITENUM] = VL.[SiteID] AND VS.[vID] = VL.[vID] AND VS.[SUBNUM] = VL.[SubjectID]
  LEFT JOIN [Reimbursement].[cdb_rajp].[v_EnrollmentEligibility] EE ON EE.[SourceVisitID] = VL.[vID] AND EE.[SubjectID] = VL.[SubjectID]
  LEFT JOIN [EligibleDrugs] ED ON ED.[SourceVisitID] = VL.[vID] AND ED.[SubjectID] = VL.[SubjectID]
  --LEFT JOIN [NonEligibleDrugs] ND ON ND.[SourceVisitID] = VL.[vID] AND ND.[SubjectID] = VL.[SubjectID]
  WHERE VL.[VisitType] = 'Enrollment'
)

--SELECT * FROM [MERGE_RA_Japan].[staging].[VIS_DATE] 

SELECT 
	   [vID]
	  ,[SiteID]
	  ,[currentStatus]
	  ,[SubjectID]
	  ,[VisitType]
	  ,[ProviderID]
	  ,CAST([VisitDate] AS DATE) AS [VisitDate]
	  ,[YOB-Sub]
	  ,[AtLeast18]
	  ,[YearRAOnset]
	  ,[Drug]
	  ,[DrugNameOther]
	  ,[EligibleDrug]
	  ,CASE
			WHEN [Drug] IS NULL THEN NULL 
			ELSE [PrescAtVisit]
			END AS
	   [PrescAtVisit]
	  ,CASE
			WHEN [Drug] IS NULL THEN NULL 
			ELSE [PriorUse]
			END AS
	   [PriorUse]
	  ,[DrugReqSatisfied]
	  ,CASE WHEN [AtLeast18] = 'Yes' AND [YearRAOnset] IS NOT NULL AND [Drug] IS NOT NULL AND [DrugReqSatisfied] = '1' THEN 'Eligible'
			WHEN [AtLeast18] = 'Yes' AND [YearRAOnset] IS NULL AND [Drug] IS NOT NULL AND [DrugReqSatisfied] = '1' THEN 'Onset Year Missing'
			WHEN [AtLeast18] < 18 THEN 'Not Eligible'
			WHEN [Yob-Sub] IS NULL THEN 'Not Eligible'
			WHEN [YearRAOnset] IS NULL THEN 'Not Eligible'
			WHEN [PrescAtVisit] = 'No' THEN 'Not Eligible'
			WHEN [PriorUse] = 'Yes' THEN 'Not Eligible'
			ELSE 'Not Eligible'
			END AS 
	    [RegistryEnrollmentStatus]
	   ,[IneligibleReason]
	   ,[PatientEligible]
	   ,[EligibilityException]
	   ,[EligibilityReview]
  FROM [EnrolledList]
GO
