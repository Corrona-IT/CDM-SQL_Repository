USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_RecruitmentReport]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















		 --SELECT * FROM
CREATE VIEW [NMO750].[v_op_RecruitmentReport] AS

--Get list of first entry dates from the audit trail for each subject

WITH EntryDates AS 
(
SELECT 
	 [subjectId]
	,MIN([auditDate]) AS [firstEntry]
FROM [RCC_NMOSD750].[api].[auditlogs]
WHERE eventTypeId = '5438' --eventTypeId 5438 = first audit of value for the Participation Date field
GROUP BY [subjectId]
),

--Get list of all screened patients with reimbursement info

Screened AS
(
SELECT DISTINCT
	   S.[status]
      ,S.[studySiteId]
	  ,SS.[Name] AS [Site]
	  ,LEFT(SS.[name],4) AS [SiteID]
      ,S.[uniqueIdentifier] AS [SubjectID]
	  ,S.[id]  AS [IdentificationNumber]
      ,E.[firstEntry]
	  --,CONVERT(VARCHAR(10), DATEADD(SECOND,CAST(S.[dateScreened] AS bigint)/1000 ,'1970/1/1'), 120) AS [calcDateScreened]
      ,VD.[visit_dt] AS [EnrollmentDate]
	  --,S.[rcOid]
      --,S.[forceManualSubjectNumber]
      --,S.[studyId]
      --,S.[customEnrollCrfUsed]
      --,S.[email]
      --,S.[updateDate]
      ,S.[studySiteName]
	  ,SR.[screen_eligible_pay] AS [EligibleForScreeningPay]
	  ,SR.[screen_ineligible_pay_rsn] AS [ReasonNotEligibleOrUnderReview]
	  ,SR.[screen_ineligible_pay_rsn_txt] AS [OtherReasonSpecify]
	  ,SR.[screen_eligible_pay_except] AS [ExceptionGranted]
	  ,SR.[screen_eligible_pay_except_rsn] AS [ExceptionReason]
	  ,SR.[screen_paid] AS [ScreeningPaid]
	  ,SR.[screen_paid_quarter] AS [QuarterPaid]
	  ,SR.[screen_paid_year] AS [YearPaid]
	  ,SR.[screen_paid_date] AS [VisitPaidDate]
	  ,SR.[screen_paid_checkno] AS [CheckNo]
      ,S.[id]
  --SELECT * FROM [RCC_NMOSD750].[staging].[screeningreimbursement] -- SELECT * 
  FROM [RCC_NMOSD750].[api].[subjects] S
  LEFT JOIN [RCC_NMOSD750].[staging].[screeningreimbursement] SR ON S.[id] = SR.[subjectId]
  LEFT JOIN [RCC_NMOSD750].[api].[study_sites] SS ON S.[studySiteId] = SS.[id]
  LEFT JOIN [RCC_NMOSD750].[staging].[visitdate] VD ON VD.[subjectId] = S.[id] AND VD.eventName = 'Enrollment'
  LEFT JOIN EntryDates E ON S.[id] = E.subjectId
  WHERE S.[status] <> 'Removed'
  ),

--Calculate days since entry versus report run date and enrollment date

DaysSince AS
(
  SELECT
	  [SiteID]
	 ,[SubjectID]
	 ,[IdentificationNumber]
	 ,[firstEntry] AS [DateEntered]
	 ,[EnrollmentDate]
	 ,CASE 
		WHEN [firstEntry] IS NOT NULL AND [EnrollmentDate] IS NOT NULL
		THEN DATEDIFF(dd,[firstEntry],[EnrollmentDate]) 
		WHEN [firstEntry] IS NOT NULL AND [EnrollmentDate] IS NULL
		THEN DATEDIFF(dd,[firstEntry],GETDATE()) 
		ELSE NULL
	  END AS [DaysSinceEntered]

	  FROM Screened
)


--Calculate eligibility statuses 

 SELECT
	  CAST(S.[SiteID] AS INT) AS [SiteID]
	 ,S.[IdentificationNumber]
	 ,S.[SubjectID]
	 ,CAST(S.[firstEntry] AS DATE) AS [DateEntered]
	 ,CAST(S.[EnrollmentDate] AS DATE) AS [EnrollmentDate]
	 ,CASE
		--WHEN S.[EligibleForScreeningPay] = 0 AND [ExceptionGranted] = 1 THEN 'Eligible-Exception'
		WHEN S.[EligibleForScreeningPay] = 2 THEN 'Under review (outcome TBD)'
		WHEN S.[EligibleForScreeningPay] = 1 THEN 'Eligible - Reviewed'
		WHEN D.[DaysSinceEntered] <= 3 AND S.[EligibleForScreeningPay] IS NULL 
		AND ([ExceptionGranted] <> 1 OR [ExceptionGranted] IS NULL)THEN 'Not Eligible'
		WHEN S.[EligibleForScreeningPay] = 0 THEN 'Not Eligible - Reviewed'
		WHEN [ExceptionGranted] = 1 THEN 'Eligible - Exception'
		WHEN D.[DaysSinceEntered] > 3 THEN 'Eligible'
		--WHEN D.[DaysSinceEntered] > 3 AND S.[EligibleForScreeningPay] = 1 THEN 'Eligible - Reviewed'

	 END AS [ScreeningPayEligibility]
	 ,D.[DaysSinceEntered]
	--CASE
	--	WHEN S.[EligibleForScreeningPay] = 2 THEN 'Under review (outcome TBD)'
	--	WHEN S.[EligibleForScreeningPay] = 1 THEN 'Yes'
	--	WHEN S.[EligibleForScreeningPay] = 0 THEN 'No'
	--	ELSE NULL
	--END AS [EligibleForScreeningPay]
	 ,CASE
		WHEN S.[ReasonNotEligibleOrUnderReview] = 1 THEN 'Screening requirements were not met'
		WHEN S.[ReasonNotEligibleOrUnderReview] = 99 THEN CONCAT('Other reason (specify) - ',[OtherReasonSpecify])
		ELSE NULL
	  END AS [ReasonNotEligibleOrUnderReview]
	 --,S.[OtherReasonSpecify]
	 ,CASE
		WHEN S.[ExceptionGranted] = 1 THEN CONCAT('Yes - ', S.[ExceptionReason])
		WHEN S.[ExceptionGranted] = 0 THEN 'No'
		ELSE NULL
	  END AS [ExceptionGranted]
	 --,S.[ExceptionReason]
	 --,S.[ScreeningPaid]
	 --,S.[QuarterPaid]
	 --,S.[YearPaid]
	 ,CASE 
		WHEN [subject_eligible] = '1' THEN 'Yes'
		WHEN [subject_eligible] = '0' THEN 'No'
		ELSE NULL
	  END AS [EligibilityCriteria]
	 ,CASE
		WHEN [subject_consent] = '1' THEN 'Yes'
		WHEN [subject_consent] = '0' THEN 'No'
		ELSE NULL 
	  END AS [Consent]
	 ,[subject_no_consent_reason] AS [NoConsentReason]
	 ,CASE WHEN [ScreeningPaid] = '1' THEN 'Yes'
	  ELSE NULL
	  END AS [ScreeningPaid]
	 ,[QuarterPaid]
	 ,[YearPaid]
	 ,CAST(S.[VisitPaidDate] AS DATE) AS [VisitPaidDate]
	 ,S.[CheckNo]


	  FROM Screened S
	  LEFT JOIN DaysSince D ON S.[IdentificationNumber] = D.[IdentificationNumber]
	  LEFT JOIN [RCC_NMOSD750].[staging].[subjectinfo] I on S.[IdentificationNumber] = I.[subjectId]
GO
