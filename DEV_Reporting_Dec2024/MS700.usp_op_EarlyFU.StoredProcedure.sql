USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_EarlyFU]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =========================================================
-- Author:		Kaye Mowrey
-- Create date: 2/11/2020
-- Description:	Procedure for Early Follow Up (t_op_EarlyFU)
-- =========================================================


CREATE PROCEDURE [MS700].[usp_op_EarlyFU] AS
	-- Add the parameters for the stored procedure here


BEGIN
	SET NOCOUNT ON;

/*
CREATE TABLE [MS700].[t_op_EarlyFU](
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[PatientID] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[VisitType] [varchar](50) NULL,
	[eventOccurrence] [int] NULL,
	[VisitSequence] [int] NULL,
	[VisitDate] [date] NULL,
	[DaysSinceLastVisit] [bigint] NULL,
	[eventCrfId] [bigint] NULL,
	[EligibleVisit] [varchar] (10) NULL,
	[OutOfWindow] [varchar](150) NULL,
	[EarlyVisitRulesSatisfied] [varchar](100) NULL,
	[ExceptionGranted] [varchar](100) NULL,
	[ExceptionReason] [varchar](250) NULL,
	[PermanentlyIncomplete] [varchar](10) NULL,
	[IneligibleVirtualVisit] [varchar] (10) NULL,
) ON [PRIMARY]
GO
*/


/******Get list of Visits******/

IF OBJECT_ID('tempdb.dbo.#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT DISTINCT [SiteID]
      ,[SubjectID]
      ,[PatientID]
      ,CASE WHEN [VisitType]='Enrollment' THEN 'Enrollment Visit'
	   WHEN [VisitType]='Follow-Up' THEN 'Follow-Up Visit'
	   ELSE [VisitType]
	   END AS [VisitType]
      ,[VisitDate]
      ,[ProviderID]
      ,[eventOccurrence]
      ,[VisitSequence]
	  ,[eventCrfid]
	  ,EligibleVisit

  INTO #Visits
  FROM [Reporting].[MS700].[v_op_VisitLog] V
  WHERE ISNULL(V.VisitDate, '')<>''
  AND V.eventId IN (3042, 3043) 

--SELECT * FROM #Visits ORDER BY SiteID, SubjectID



/******Determine days since last visit and get reimbursement information******/

IF OBJECT_ID('tempdb.dbo.#DaysSinceLastVisit') IS NOT NULL BEGIN DROP TABLE #DaysSinceLastVisit END

SELECT A.SiteID
      ,A.SubjectID
	  ,A.PatientID
	  ,A.ProviderID
	  ,A.VisitType
	  ,A.VisitSequence
	  ,A.eventOccurrence
	  ,A.VisitDate
	  ,DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate) AS DaysSinceLastVisit
	  ,A.eventCrfId 
	  ,A.EligibleVisit
	  ,CASE WHEN REIMB.pay_2_1000=0 THEN 'No'
	   WHEN REIMB.pay_2_1000=1 THEN 'Yes'
	   ELSE CAST(REIMB.pay_2_1000 AS varchar)
	   END AS OutOfWindow
	  ,CASE WHEN ISNULL(REIMB.pay_2_1001_dec, '')='' THEN 'Not reviewed'
	   ELSE REIMB.pay_2_1001_dec
	   END AS EarlyVisitRulesSatisfied
	  ,REIMB.pay_2_1002_dec AS ExceptionGranted
	  ,REIMB.pay_2_1003 AS ExceptionReason
	  ,CASE WHEN REIMB.pay_3_1300_dec='No' THEN 'Yes'
	   ELSE ''
	   END AS PermanentlyIncomplete
	  ,CASE WHEN pay_2_1400=1 AND pay_2_1401=0 THEN 'Yes'
	   ELSE 'No'
	   END AS IneligibleVirtualVisit

INTO #DaysSinceLastVisit
FROM
(
SELECT V.SiteID
      ,V.SubjectID
	  ,V.patientId
	  ,V.ProviderID
	  ,V.VisitType
	  ,V.VisitSequence
	  ,V.eventOccurrence
	  ,V.VisitDate
	  ,(SELECT MAX(VisitDate) FROM #Visits V2 WHERE V2.SiteID=V.SiteID AND V2.PatientID=V.PatientID AND V.VisitDate>V2.VisitDate AND V2.EligibleVisit='Yes') AS PreviousVisitDate
	  ,V.eventCrfId
	  ,V.EligibleVisit

FROM #Visits V
WHERE ISNULL(V.VisitDate, '')<>''
) A
LEFT JOIN [RCC_MS700].[staging].[visitreimbursement] REIMB ON REIMB.subjectId=A.PatientID AND REIMB.eventName=A.VisitType AND REIMB.[eventOccurrence]=A.eventOccurrence

--SELECT * FROM #DaysSinceLastVisit WHERE IneligibleVirtualVisit='Yes' ORDER BY SiteID, SubjectID, VisitDate

TRUNCATE TABLE [Reporting].[MS700].[t_op_EarlyFU]

INSERT INTO [Reporting].[MS700].[t_op_EarlyFU] 
(
	[SiteID],
	[SubjectID],
	[PatientID],
    [VisitType],
	[eventOccurrence],
	[VisitSequence],
	[VisitDate],
	[DaysSinceLastVisit],
	[eventCrfId],
	[EligibleVisit],
	[OutOfWindow],
	[EarlyVisitRulesSatisfied],
	[ExceptionGranted],
	[ExceptionReason],
	[PermanentlyIncomplete],
	[IneligibleVirtualVisit]

)

SELECT DISTINCT [SiteID],
	[SubjectID],
	[PatientID],
    [VisitType],
	[eventOccurrence],
	[VisitSequence],
	[VisitDate],
	[DaysSinceLastVisit],
	[eventCrfId],
	[EligibleVisit],
	[OutOfWindow],
	[EarlyVisitRulesSatisfied],
	[ExceptionGranted],
	[ExceptionReason],
	[PermanentlyIncomplete],
	[IneligibleVirtualVisit]

FROM #DaysSinceLastVisit LV
WHERE DaysSinceLastVisit<150
AND ISNULL(PermanentlyIncomplete, '')=''


--SELECT * FROM [Reporting].[MS700].[t_op_EarlyFU] ORDER BY SiteID, SubjectID, eventOccurrence


END

GO
