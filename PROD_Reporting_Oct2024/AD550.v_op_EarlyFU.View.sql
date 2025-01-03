USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_EarlyFU]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [AD550].[v_op_EarlyFU] AS

--Get list of Enrollment and eligible Follow-up visits from Visit Log

WITH Visits AS
(
SELECT DISTINCT SiteID,
       SiteStatus,
	   SFSiteStatus,
       SubjectID,
	   patientId,
	   ProviderID,
	   eventId,
	   VisitType,
	   eventOccurrence,
	   VisitDate,
	   EligibleVisit
  FROM [AD550].[t_op_VisitLog] V
  WHERE V.eventId=8031  -- Enrollment
UNION
  SELECT DISTINCT SiteID,
       SiteStatus,
	   SFSiteStatus,
       SubjectID,
	   patientId,
	   ProviderID,
	   eventId,
	   VisitType,
	   eventOccurrence,
	   VisitDate,
	   EligibleVisit
  FROM [AD550].[t_op_VisitLog] V
  WHERE V.eventId=8034  -- Follow-up
  AND ISNULL(EligibleVisit, '')<>'No'
 )

 --Determine days since last eligible visit and get information on early visits (rules satisfied) and exceptions

,DaysSinceLastVisit AS (
SELECT A.SiteID
      ,A.SubjectID
	  ,A.patientId
	  ,A.ProviderID
	  ,A.VisitType
	  ,A.eventId
	  ,A.eventOccurrence
	  ,A.VisitDate
	  ,DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate) AS DaysSinceLastVisit
	  ,REIMB.pay_earlyfu_oow_dec AS OutOfWindow
	  ,REIMB.pay_earlyfu_status_dec AS EarlyVisitRulesSatisfied
	  ,REIMB.pay_earlyfu_pay_exception_dec AS ExceptionGranted
	  ,REIMB.pay_earlyfu_exception_reason AS ExceptionReason
	  --SELECT * FROM [RCC_AD550].[staging].[visitreimbursement]
FROM
(
SELECT V.SiteID
      ,V.SubjectID
	  ,V.patientId
	  ,V.ProviderID
	  ,V.VisitType
	  ,V.eventId
	  ,V.eventOccurrence
	  ,V.VisitDate
	  ,(SELECT MAX(VisitDate) FROM Visits V2 WHERE V2.SiteID=V.SiteID AND V2.SubjectID=V.SubjectID AND V.VisitDate>V2.VisitDate AND V2.EligibleVisit='Yes') AS PreviousVisitDate
FROM VISITS V
WHERE ISNULL(V.VisitDate, '')<>''
) A
LEFT JOIN [RCC_AD550].[staging].[visitreimbursement] REIMB ON REIMB.subjectId=A.patientId AND REIMB.eventId=A.eventId AND REIMB.eventOccurrence=A.eventOccurrence
)

SELECT DISTINCT SiteID,
       SubjectID,
	   patientId,
	   ProviderID,
	   VisitType,
	   eventId,
	   eventOccurrence,
	   VisitDate,
	   DaysSinceLastVisit,
	   OutOfWindow,
	   CASE WHEN ISNULL(EarlyVisitRulesSatisfied, '')='' THEN 'Not reviewed'
	   ELSE EarlyVisitRulesSatisfied
	   END AS EarlyVisitRulesSatisfied,
	   ExceptionGranted,
	   ExceptionReason
FROM DaysSinceLastVisit
WHERE eventId=8034
AND ISNULL(DaysSinceLastVisit, 0)<150
AND ISNULL(ExceptionGranted, '')<>'Yes'

--ORDER BY SiteID, SubjectID, VisitDate

GO
