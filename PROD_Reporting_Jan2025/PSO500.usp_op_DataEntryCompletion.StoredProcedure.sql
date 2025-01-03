USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_DataEntryCompletion]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- ==================================================================================
-- Author:		Kevin Soe
-- Create date: 12/9/2020
-- Description:	Procedure to create table PSO Data Entry Completion Report
-- ==================================================================================


CREATE PROCEDURE [PSO500].[usp_op_DataEntryCompletion] AS

/* 

CREATE TABLE [Reporting].[PSO500].[t_op_DataEntryCompletion]
(
	   [VisitID] [bigint] NOT NULL
      ,[SiteID] [int] NOT NULL
	  ,[SiteStatus] [nvarchar] (30) NULL
      ,[SubjectID] [nvarchar] (20) NOT NULL
      ,[VisitEventType] [nvarchar] (150) NULL
	  ,[VisitSequence] [int] NOT NULL
      ,[VisitDate] [date] NULL
      ,[IncompleteMDForms] [nvarchar] (600) NULL
      ,[IncompleteSUForms] [nvarchar] (600) NULL

);

*/

TRUNCATE TABLE [Reporting].[PSO500].[t_op_DataEntryCompletion]

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Get a list of all forms ever signed based on the audit trail

IF OBJECT_ID('tempdb..#SignedForms') IS NOT NULL BEGIN DROP TABLE #SignedForms END

SELECT * 
INTO #SignedForms
FROM (

SELECT CONCAT([VisitID],[FormsDescription]) AS [IncompleteForm], [VisitID], [FormsDescription]
 --SELECT *
	FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllForms]
	WHERE [WasSigned] = '1'
	--WHERE CONCAT([TrlObjectVisitID], [FormsDescription]) NOT IN (SELECT CONCAT([TrlObjectVisitID],[FormsDescription]) FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllForms] WHERE [WasSigned] = '1')
	--AND [FormsDescription] NOT IN (SELECT [FormsDescription] FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllForms] WHERE [WasSigned] = '1')
	) G

--Determine which forms have never been signed by comparing against list of ever signed forms and order by page name so pages sort as close to EDC order as possible

IF OBJECT_ID('tempdb..#UnSignedForms') IS NOT NULL BEGIN DROP TABLE #UnSignedForms END

SELECT * 
INTO #UnSignedForms
FROM (
	SELECT 
	   ES.[VisitID]
	  ,ES.[SiteNumber]
	  ,ES.[SubjectID]
	  ,ES.[VisitsDescription] as [VisitEventType]
	  ,CAST(V.[VisitDate] AS date) AS [VisitDate]
	  ,ES.[FormsDescription]
	  ,CASE
	   WHEN ES.[FormsDescription] LIKE 'Visit' THEN 0
	   WHEN ES.[FormsDescription] LIKE 'Clinical Diagnosis%' THEN 1
	   WHEN ES.[FormsDescription] LIKE 'Infections%' THEN 2
	   WHEN ES.[FormsDescription] LIKE 'Clinical Features%' THEN 3
	   WHEN ES.[FormsDescription] LIKE 'Topical Corticosteroids%' THEN 4
	   WHEN ES.[FormsDescription] LIKE 'Light/Laser Therapy%' THEN 5
	   WHEN ES.[FormsDescription] LIKE 'Non-Biologic%' THEN 6
	   WHEN ES.[FormsDescription] LIKE 'Biologic Medications%' THEN 7
	   WHEN ES.[FormsDescription] LIKE 'Changes Made Today%' THEN 8
	   WHEN ES.[FormsDescription] LIKE 'Systemic Meds Not Started%' THEN 9
	   WHEN ES.[FormsDescription] LIKE 'TB Testing%' THEN 10
	   WHEN ES.[FormsDescription] LIKE 'Skin%' THEN 11
	   WHEN ES.[FormsDescription] LIKE 'PASI%' THEN 12
	   WHEN ES.[FormsDescription] LIKE 'Lab%' THEN 13
	   WHEN ES.[FormsDescription] LIKE 'Demographics%' THEN 14
	   WHEN ES.[FormsDescription] LIKE 'Medical History%' THEN 15
	   WHEN ES.[FormsDescription] LIKE 'Family Med History%' THEN 16
	   WHEN ES.[FormsDescription] LIKE 'Work Status and Insurance%' THEN 17
	   WHEN ES.[FormsDescription] LIKE 'Medications%' THEN 18
	   WHEN ES.[FormsDescription] LIKE 'Medical Conditions%' THEN 19
	   WHEN ES.[FormsDescription] LIKE 'Overall Well-Being%' THEN 20
	   WHEN ES.[FormsDescription] LIKE 'Work and Activity%' THEN 21
	   WHEN ES.[FormsDescription] LIKE '%Exit%' THEN 22
	   ELSE 99
	   END AS [FormOrder]
      ,V.[InstanceNo]
  --SELECT *
	FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllForms] ES
	LEFT JOIN [OMNICOMM_PSO].[inbound].[Visits] V on ES.VisitId=V.VisitId
	WHERE ES.[FormsDescription] <> 'Eligibility' AND
	ES.[VisitsDescription] IN ('Enrollment', 'Follow-up', 'Exit') AND
	ES.[SiteNumber] NOT LIKE '99%' AND
	CONCAT(ES.[VisitID],ES.[FormsDescription]) NOT IN
	(SELECT [IncompleteForm] FROM #SignedForms)
	) D


--Get list of Incomplete visits based on query for V1 of DE Completion report


IF OBJECT_ID('tempdb..#Incomplete') IS NOT NULL BEGIN DROP TABLE #Incomplete END

SELECT * 
INTO #Incomplete
FROM 
(
SELECT ES.[TrlObjectVisitID]
      ,ES.[VisitId]
      ,V.[InstanceNo]
      ,ES.[VisitType] as [VisitEventType]
	  ,CAST(V.[VisitDate] AS date) AS [VisitDate]
      ,ES.[Subject_Id]
      ,ES.[SiteNo]
      ,ES.[EverAllSigned]
	  ,NULL AS [PayableReportType]  
FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllVisits] ES
LEFT JOIN [OMNICOMM_PSO].[inbound].[Visits] V on ES.VisitId=V.VisitId
WHERE ES.[SiteNo] NOT IN (997, 998, 999)
AND [EverAllSigned]=0
AND [VisitType] <> 'Exit'
AND ISNULL(V.[VisitDate], '')<>''

UNION

SELECT ES.[TrlObjectVisitID]
      ,ES.[VisitId]
      ,E.[InstanceNo]
      ,ES.[VisitType] as [VisitEventType]
	  ,CAST(E.[Sys. VisitDate] AS date) AS [VisitDate]
      ,ES.[Subject_Id]
      ,ES.[SiteNo]
      ,ES.[EverAllSigned]
	  ,NULL AS [PayableReportType]
FROM [Reimbursement].[reports].[PSO_LOCAL_EverSignedAllVisits] ES
LEFT JOIN [OMNICOMM_PSO].[inbound].[G_EXIT1] E on ES.[TrlObjectVisitID]=E.[TrlObjectVisitID]
WHERE ES.[SiteNo] NOT IN (997, 998, 999)
AND ES.[EverAllSigned]=0
AND ES.[VisitType] = 'Exit'
and ISNULL(E.[Sys. VisitDate], '')<>''

/*
UNION

SELECT ES.[TrlObjectVisitID]
      ,ES.[VisitId]
      ,ES.[InstanceNo]
      ,ES.[EventType] as [VisitEventType]
	  ,CASE WHEN  ISNULL(FollowUpVisitDate, '')<>'' THEN CAST(FollowUpVisitDate AS date)
	   WHEN ISNULL(FollowUpVisitDate, '')='' THEN CAST(EventOnsetDate AS date)
	   ELSE NULL
	   END AS [VisitDate]
      ,ES.[SubjectID] as [Subject_Id]
      ,ES.[SiteNumber] as [SiteNo]
      ,ES.[BothPagesSigned] as [EverAllSigned]
	  ,ES.[PayableReportType]
	  --		select *
FROM [Reimbursement].[reports].[PSO_LOCAL_015_2] ES
WHERE ES.[SiteNumber] NOT LIKE '99%'
AND (FollowUpVisitDate IS NOT NULL OR EventOnsetDate IS NOT NULL)
AND ES.BothPagesSigned=0
and isnull(ES.[SubjectID], '')<>''
AND isnumeric(ES.[SubjectID])=1
*/
) L

--Determine List of visits that have been confirmed incomplete in the EDC

IF OBJECT_ID('tempdb..#ConfirmedIncomplete') IS NOT NULL BEGIN DROP TABLE #ConfirmedIncomplete END

SELECT * 
INTO #ConfirmedIncomplete
FROM 
(
SELECT [VisitID]
FROM [OMNICOMM_PSO].[inbound].[ELG]
WHERE [ELGCONF_confirmed_incomplete] IS NOT NULL
) W

INSERT INTO [Reporting].[PSO500].[t_op_DataEntryCompletion]

SELECT CAST([VisitId] AS bigint) AS [VisitID]
	  ,CAST([SiteNo] AS int) AS [SiteID]
	  ,SS.SiteStatus
	  ,[Subject_Id] AS [SubjectID]
	  ,[VisitEventType]
	  ,CAST([InstanceNo] AS int) AS [VisitSequence]
	  ,CAST([VisitDate] AS date) AS [VisitDate]
	  ,CASE 
	   --WHEN [VisitEventType] = 'Exit' THEN 'N/A'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%' OR [FormsDescription] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, '')) IS NULL 
	   THEN 'Complete'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDEN, Infections_MDEN, Clinical Features_MDEN, Topical Corticosteroids_MDEN, Light/Laser Therapy_MDEN, Non-Biologic Medications_MDEN, Biologic Medications_MDEN, Changes Made Today_MDEN, TB Testing_MDEN, Skin_MDEN, PASI_MDEN'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDEN, Infections_MDEN, Clinical Features_MDEN, Topical Corticosteroids_MDEN, Light/Laser Therapy_MDEN, Non-Biologic Medications_MDEN, Non-Biologic Medications_MDEN, Biologic Medications_MDEN, Changes Made Today_MDEN, TB Testing_MDEN, Skin_MDEN, PASI_MDEN'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDEN, Infections_MDEN, Clinical Features_MDEN, Topical Corticosteroids_MDEN, Light/Laser Therapy_MDEN, Non-Biologic Medications_MDEN, Biologic Medications_MDEN, Biologic Medications_MDEN, Changes Made Today_MDEN, TB Testing_MDEN, Skin_MDEN, PASI_MDEN'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDEN, Infections_MDEN, Clinical Features_MDEN, Topical Corticosteroids_MDEN, Light/Laser Therapy_MDEN, Non-Biologic Medications_MDEN, Non-Biologic Medications_MDEN, Biologic Medications_MDEN, Biologic Medications_MDEN, Changes Made Today_MDEN, TB Testing_MDEN, Skin_MDEN, PASI_MDEN'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDFU, Infections_MDFU, Clinical Features_MDFU, Topical Corticosteroids_MDFU, Light/Laser Therapy_MDFU, Non-Biologic Medications_MDFU, Biologic Medications_MDFU, Changes Made Today_MDFU, Systemic Meds Not Started_MDFU, TB Testing_MDFU, Skin_MDFU, PASI_MDFU'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDFU, Infections_MDFU, Clinical Features_MDFU, Topical Corticosteroids_MDFU, Light/Laser Therapy_MDFU, Non-Biologic Medications_MDFU, Non-Biologic Medications_MDFU, Biologic Medications_MDFU, Changes Made Today_MDFU, Systemic Meds Not Started_MDFU, TB Testing_MDFU, Skin_MDFU, PASI_MDFU'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDFU, Infections_MDFU, Clinical Features_MDFU, Topical Corticosteroids_MDFU, Light/Laser Therapy_MDFU, Non-Biologic Medications_MDFU, Biologic Medications_MDFU, Biologic Medications_MDFU, Changes Made Today_MDFU, Systemic Meds Not Started_MDFU, TB Testing_MDFU, Skin_MDFU, PASI_MDFU'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Clinical Diagnosis_MDFU, Infections_MDFU, Clinical Features_MDFU, Topical Corticosteroids_MDFU, Light/Laser Therapy_MDFU, Non-Biologic Medications_MDFU, Non-Biologic Medications_MDFU, Biologic Medications_MDFU, Biologic Medications_MDFU, Changes Made Today_MDFU, Systemic Meds Not Started_MDFU, TB Testing_MDFU, Skin_MDFU, PASI_MDFU'
	   THEN 'All'
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%Exit%' OR [FormsDescription] LIKE '%Visit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Visit, Subject Exit Questionnaire'
	   THEN 'All'
	   ELSE 
	   LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND ([FormsDescription] LIKE '%_MD%' OR [FormsDescription] LIKE '%Visit%' OR [FormsDescription] LIKE '%Exit%') ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   END 
	   AS [IncompleteMDForms]
	  ,CASE 
	   WHEN [VisitEventType] = 'Exit' THEN NULL
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND [FormsDescription] LIKE '%_SU%' ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))IS NULL 
	   THEN 'Complete' 
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND [FormsDescription] LIKE '%_SU%' ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Demographics_SUEN, Medical History_SUEN, Family Med History_SUEN, Medications_SUEN, Medical Conditions_SUEN, Overall Well-Being_SUEN, Work and Activity_SUEN'
	   THEN 'All' 
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND [FormsDescription] LIKE '%_SU%' ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Demographics_SUEN, Medical History1_SUEN, Family Med History_SUEN, Medications_SUEN, Medical Conditions_SUEN, Overall Well-Being_SUEN, Work and Activity_SUEN'
	   THEN 'All' 
	   WHEN LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND [FormsDescription] LIKE '%_SU%' ORDER BY [FormOrder] FOR XML PATH('')),1,1, ''))
	   = 'Work Status and Insurance_SUFU, Medications_SUFU, Medical Conditions_SUFU, Overall Well-Being_SUFU, Work and Activity_SUFU'
	   THEN 'All' 
	   ELSE 
	   LTRIM(STUFF((SELECT ', ' + [FormsDescription] FROM #UnSignedForms US WHERE US.[VisitID] = I.[VisitID] AND [FormsDescription] LIKE '%_SU%' ORDER BY [FormOrder] FOR XML PATH('')),1,1, '')) 
	   END 
	   AS [IncompleteSUForms]
FROM #INCOMPLETE I
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=I.SiteNo
WHERE I.[VisitID] NOT IN (SELECT [VisitID] FROM #ConfirmedIncomplete)
---ORDER BY [SiteNo], [Subject_Id], [VisitDate], [Instance]

END 

--SELECT * FROM [Reporting].[PSO500].[t_op_DataEntryCompletion]

GO
