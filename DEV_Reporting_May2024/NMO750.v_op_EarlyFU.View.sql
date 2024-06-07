USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_EarlyFU]    Script Date: 6/6/2024 8:58:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [NMO750].[v_op_EarlyFU] AS

--Get list of Enrollment and FU Visits from Visit Log
/*Incomplete visits at FU are not populated in this report*/

WITH Visits AS
(
SELECT DISTINCT V.SiteID
      ,V.SubjectID
      ,V.patientId
	  ,V.ProviderID
	  ,V.eventDefinitionId
	  ,V.VisitType
	  ,V.eventOccurrence
	  ,VisitSequence
      ,V.VisitDate
	  ,V.EligibleVisit
	  , V.EDCSiteStatus
  FROM [Reporting].[NMO750].[t_op_VisitLog] V
  WHERE V.eventDefinitionId=11174
  UNION
SELECT DISTINCT V.SiteID
      ,V.SubjectID
      ,V.patientId
	  ,V.ProviderID
	  ,V.eventDefinitionId
	  ,V.VisitType
	  ,V.eventOccurrence
	  ,VisitSequence
      ,V.VisitDate
	  ,V.EligibleVisit
	  , V.EDCSiteStatus
  FROM [Reporting].[NMO750].[t_op_VisitLog] V
  WHERE V.eventDefinitionId=11175
  AND ISNULL(IncompleteVisit, '')<>'Incomplete'  
)

--Determine days since last eligible visit and get information on early visits (rules satisfied) and exceptions

,DaysSinceLastVisit AS
(
SELECT A.SiteID
      ,A.SubjectID
	  ,A.patientId
	  ,A.ProviderID
	  ,A.VisitType
	  ,A.eventDefinitionId
	  ,A.VisitSequence
	  ,A.eventOccurrence
	  ,A.PreviousVisitDate
	  ,A.VisitDate
	  ,A.EDCSiteStatus
	  ,DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate) AS DaysSinceLastVisit
	  ,CASE WHEN REIMB.pay_earlyfu_oow=1 THEN 'Yes'
	   WHEN REIMB.pay_earlyfu_oow=0 THEN 'No'
	   ELSE ''
	   END AS OutOfWindow
	  ,CASE WHEN REIMB.pay_earlyfu_status=1 THEN 'Yes'
	   WHEN REIMB.pay_earlyfu_status=0 THEN 'No'
	   WHEN REIMB.pay_earlyfu_status=2 THEN 'Under review (outcome TBD)'
	   ELSE ''
	   END AS EarlyVisitRulesSatisfied
	  ,CASE WHEN REIMB.pay_earlyfu_pay_exception=1 THEN 'Yes'
	   WHEN REIMB.pay_earlyfu_pay_exception=0 THEN 'No'
	   ELSE ''
	   END AS ExceptionGranted
	  ,REIMB.pay_earlyfu_pay_exception_reason AS ExceptionReason
	  ,CASE	
			WHEN REIMB.pay_visit_confirmed_incomplete is NULL then 'No'
			when REIMB.pay_visit_confirmed_incomplete =0 then 'No'
			when REIMB.pay_visit_confirmed_incomplete =1 then 'Yes'
	  end AS PermanentlyIncomplete
FROM
(
SELECT V.SiteID
      ,V.SubjectID
	  ,V.patientId
	  ,V.ProviderID
	  ,V.VisitType
	  ,V.eventDefinitionId
	  ,V.VisitSequence
	  ,V.eventOccurrence
	  ,V.VisitDate
	  , V.EDCSiteStatus
	  ,(SELECT MAX(VisitDate) FROM Visits V2 WHERE V2.SiteID=V.SiteID AND V2.SubjectID=V.SubjectID AND V.VisitDate>V2.VisitDate AND V2.EligibleVisit='Yes') AS PreviousVisitDate
FROM Visits V
WHERE ISNULL(V.VisitDate, '')<>''

) A
LEFT JOIN [RCC_NMOSD750].[staging].[visitreimbursement] REIMB ON REIMB.subjectId=A.patientId AND REIMB.eventName=A.VisitType AND REIMB.eventOccurrence=A.eventOccurrence
)


--Get final listing of FUs, days since previous visit, and early rules/exceptions

SELECT DISTINCT SiteID,
       SubjectID,
	   patientId,
	   ProviderID,
	   VisitType,
	   eventDefinitionId,
	   eventOccurrence,
	   VisitSequence,
	   PreviousVisitDate,
	   VisitDate,
	   DaysSinceLastVisit,
	   --eventCrfId,
	   --hasData,
	   OutOfWindow,
	   CASE WHEN ISNULL(EarlyVisitRulesSatisfied, '')='' THEN 'Not reviewed'
	   ELSE EarlyVisitRulesSatisfied
	   END AS EarlyVisitRulesSatisfied,
	   ExceptionGranted,
	   ExceptionReason,
	   PermanentlyIncomplete,
	   EDCSiteStatus
	   --SiteStatus

FROM DaysSinceLastVisit
WHERE VisitType='Follow-up'
AND ISNULL(DaysSinceLastVisit, 0)<150


--ORDER BY SiteID, SubjectID, VisitDate

GO
