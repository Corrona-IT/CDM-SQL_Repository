USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_EarlyFU]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =================================================
-- Author:		Kevin Soe
-- Create date: 4/11/2021
-- Description:	Procedure for RA102 Early FU report  
-- =================================================

			  --EXECUTE 
CREATE PROCEDURE [RA102].[usp_op_EarlyFU] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA102].[t_op_EarlyFU]
(
       [SiteID] [int] NOT NULL,
       [SubjectID] [bigint] NOT NULL,
	   [ProviderID] [int] NULL,
	   [VisitType] [varchar](50) NULL,
	   [CalcVisitSequence] [int] NULL,
	   [VisitSequence] [int] NULL,
	   [VisitDate] [date] NULL,
	   [DaysSinceLastVisit] [bigint] NULL,
	   [vID] [bigint] NULL,
	   [OutOfWindow] [varchar](150) NULL,
	   [EarlyVisitRulesSatisfied] [varchar](100) NULL,
	   [ExceptionGranted] [varchar](100) NULL,
	   [ExceptionReason] [varchar](250) NULL
);
*/


TRUNCATE TABLE [Reporting].[RA102].[t_op_EarlyFU]

--SELECT * FROM [Reporting].[MS700].[t_op_EarlyFU]

/******Get list of Visits******/

IF OBJECT_ID('tempdb.dbo.#Visits') IS NOT NULL BEGIN DROP TABLE #Visits END

SELECT DISTINCT 
	   [vID]
	  ,[SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[ProviderID]
      ,[VisitSequence]
	  ,[CalcVisitSequence]

  INTO #Visits --SELECT *
  FROM [Reporting].[RA102].[v_op_VisitLog] V
  WHERE ISNULL(V.VisitDate, '')<>''
  AND V.VisitType IN ('Enrollment', 'Follow-Up') 

--SELECT * FROM #Visits



/******Determine days since last visit and get reimbursement information******/

IF OBJECT_ID('tempdb.dbo.#DaysSinceLastVisit') IS NOT NULL BEGIN DROP TABLE #DaysSinceLastVisit END

SELECT A.SiteID
      ,A.SubjectID
	  ,A.ProviderID
	  ,A.VisitType
	  ,A.VisitSequence
	  ,A.CalcVisitSequence
	  ,A.VisitDate
	  ,DATEDIFF(DD, A.PreviousVisitDate, A.VisitDate) AS DaysSinceLastVisit
	  ,A.vID 
	  ,CASE WHEN VIS.OOW_FU_DETECTED IS NULL THEN 'Not reviewed'
	   WHEN VIS.OOW_FU_DETECTED = 'X' THEN 'Yes'
	   ELSE 'Not Reviewed'
	   END AS OutOfWindow
	  ,CASE WHEN ISNULL(VIS.OOW_FU_PERMITTED_DEC, '')='' THEN 'Not reviewed'
	   ELSE VIS.OOW_FU_PERMITTED_DEC
	   END AS EarlyVisitRulesSatisfied
	  ,CASE WHEN VIS.OOW_FU_EXCEPTION_DEC LIKE '%No%' THEN 'No'
	   WHEN VIS.OOW_FU_EXCEPTION_DEC LIKE '%Yes%' THEN 'Yes'
	   ELSE NULL 
	   END AS ExceptionGranted
	  ,VIS.OOW_FU_EXCEPTION_RSN AS ExceptionReason

INTO #DaysSinceLastVisit
FROM
(
SELECT V.SiteID
      ,V.SubjectID
	  ,V.ProviderID
	  ,V.VisitType
	  ,V.VisitSequence
	  ,V.CalcVisitSequence
	  ,V.VisitDate
	  ,(SELECT VisitDate FROM #Visits V2 WHERE V2.SiteID=V.SiteID AND V2.SubjectID=V.SubjectID AND V2.CalcVisitSequence=(V.CalcVisitSequence-1)) AS PreviousVisitDate
	  ,V.vID

FROM #Visits V
WHERE ISNULL(V.VisitDate, '')<>''

) A --SELECT * FROM [MERGE_RA_JAPAN].[staging].[VIS_DATE]
LEFT JOIN [MERGE_RA_JAPAN].[staging].[VIS_DATE] VIS ON VIS.SUBNUM=A.SubjectID AND VIS.vID=A.vID

--SELECT * FROM #DaysSinceLastVisit

INSERT INTO [Reporting].[RA102].[t_op_EarlyFU] 
(
	[SiteID],
	[SubjectID],
	[ProviderID],
    [VisitType],
	[CalcVisitSequence],
	[VisitSequence],
	[VisitDate],
	[DaysSinceLastVisit],
	[vID],
	[OutOfWindow],
	[EarlyVisitRulesSatisfied],
	[ExceptionGranted],
	[ExceptionReason]

)

SELECT DISTINCT [SiteID],
	[SubjectID],
	[ProviderID],
    [VisitType],
	[CalcVisitSequence],
	[VisitSequence],
	[VisitDate],
	[DaysSinceLastVisit],
	[vID],
	[OutOfWindow],
	[EarlyVisitRulesSatisfied],
	[ExceptionGranted],
	[ExceptionReason]

FROM #DaysSinceLastVisit LV
WHERE DaysSinceLastVisit<150




END

GO
