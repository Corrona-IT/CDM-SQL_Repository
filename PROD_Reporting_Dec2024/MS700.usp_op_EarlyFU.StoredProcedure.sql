USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_EarlyFU]    Script Date: 12/9/2024 2:46:41 PM ******/
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
CREATE TABLE [MS700].[t_op_EarlyFU]
(
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
	   [OutOfWindow] [varchar](150) NULL,
	   [EarlyVisitRulesSatisfied] [varchar](100) NULL,
	   [ExceptionGranted] [varchar](100) NULL,
	   [ExceptionReason] [varchar](250) NULL
);
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
  AND V.VisitType IN ('Enrollment', 'Follow-Up') 

--SELECT * FROM #Visits



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
	  ,CASE WHEN REIMB.pay_2_1000=0 THEN 'No'
	   WHEN REIMB.pay_2_1000=1 THEN 'Yes'
	   ELSE CAST(REIMB.pay_2_1000 AS varchar)
	   END AS OutOfWindow
	  ,CASE WHEN ISNULL(REIMB.pay_2_1001_dec, '')='' THEN 'Not reviewed'
	   ELSE REIMB.pay_2_1001_dec
	   END AS EarlyVisitRulesSatisfied
	  ,REIMB.pay_2_1002_dec AS ExceptionGranted
	  ,REIMB.pay_2_1003 AS ExceptionReason

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
	[OutOfWindow],
	[EarlyVisitRulesSatisfied],
	[ExceptionGranted],
	[ExceptionReason]

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
	[OutOfWindow],
	[EarlyVisitRulesSatisfied],
	[ExceptionGranted],
	[ExceptionReason]

FROM #DaysSinceLastVisit LV
WHERE DaysSinceLastVisit<150

--SELECT * FROM [Reporting].[MS700].[t_op_EarlyFU] WHERE SubjectID IN (70261640041, 70261640106)


END

GO
