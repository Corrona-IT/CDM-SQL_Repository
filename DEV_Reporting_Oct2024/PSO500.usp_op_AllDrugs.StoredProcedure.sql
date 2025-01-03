USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_AllDrugs]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 8/23/2018
-- Description:	Procedure to create table for Other Drugs at Enrollment and Follow-up
-- ==================================================================================

CREATE PROCEDURE [PSO500].[usp_op_AllDrugs] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [Reporting].[PSO500].[t_op_AllDrugs]
(
	   [VisitID] [bigint] NOT NULL
      ,[SiteID] [int] NOT NULL
      ,[PatientId] [bigint] NOT NULL
      ,[SubjectID] [varchar] (30) NOT NULL
      ,[VisitType] [nvarchar] (150) NULL
      ,[VisitDate] [date] NULL
      ,[crfName] [nvarchar] (250) NULL
      ,[crfStatus] [nvarchar] (150) NULL
      ,[Treatment] [nvarchar] (250) NULL
      ,[otherTreatment] [nvarchar] (250) NULL
      ,[TreatmentStatus] [nvarchar] (150) NULL
      ,[FirstDoseToday] [nvarchar] (150) NULL
      ,[firstUse] [nvarchar] (25) NULL
	  ,[enteredStartDate] [nvarchar] (12) NULL
      ,[startDate] [date] NULL
      ,[StartReasons] [nvarchar] (30) NULL
      ,[changeDate] [date] NULL
      ,[changeReasons] [nvarchar] (150) NULL
      ,[Dose] [nvarchar] (150) NULL
      ,[Frequency] [nvarchar] (150) NULL
      ,[stopDate] [date] NULL
      ,[StopReasons] [nvarchar] (30) NULL

);

*/


IF OBJECT_ID('tempdb.dbo.#ALLDRUGS') IS NOT NULL BEGIN DROP TABLE #ALLDRUGS END;

SELECT [VisitID]
      ,[SiteID]
      ,[PatientId]
      ,[SubjectID]
      ,[VisitType]
      ,CAST([VisitDate] AS date) AS [VisitDate]
      ,[crfName]
      ,[crfStatus]
      ,[Treatment]
      ,[otherTreatment]
      ,[TreatmentStatus]
      ,[FirstDoseToday]
      ,[firstUse]
	  ,enteredStartDate
      ,CASE WHEN [startDate]='' THEN CAST(NULL AS date)
	   ELSE CAST([startDate] AS date)
	   END AS [startDate]
      ,[StartReasons]
      ,CASE WHEN ISDATE([changeDate])=0 THEN CAST(NULL AS date)
	   ELSE CAST([changeDate] AS date)
	   END AS [changeDate]
      ,[changeReasons]
      ,[Dose]
      ,[Frequency]
      ,CASE WHEN ISDATE([stopDate])=0 THEN CAST(NULL AS date)
	   ELSE CAST([stopDate] AS date)
	   END AS [stopDate]
      ,[StopReasons]

INTO #ALLDRUGS
FROM 
(
SELECT [VisitID]
      ,[SiteID]
      ,[PatientId]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[crfName]
      ,[crfStatus]
      ,[Treatment]
      ,[otherTreatment]
      ,[TreatmentStatus]
      ,[FirstDoseToday]
      ,[firstUse]
	  ,enteredStartDate
      ,CASE WHEN RIGHT(startDate, 2) ='//' THEN REPLACE(startDate, '/', '/01')
	   WHEN UPPER([startDate]) LIKE'%UNK%' THEN ''
	   ELSE [startDate]
	   END AS [startDate]
      ,[StartReasons]
      ,CASE WHEN RIGHT(changeDate, 2) ='//' THEN REPLACE(startDate, '/', '/01')
	   WHEN UPPER([changeDate]) LIKE '%UNK%' THEN ''
	   ELSE [changeDate]
	   END AS [changeDate]
      ,[changeReasons]
      ,[Dose]
      ,[Frequency]
      ,CASE WHEN RIGHT(stopDate, 2) ='//' THEN REPLACE(startDate, '/', '/01')
	   WHEN UPPER([stopDate]) LIKE'%UNK%' THEN ''
	   ELSE [stopDate]
	   END AS [stopDate]
      ,[StopReasons]
  FROM [PSO500].[v_op_EnrollmentDrugs]
  WHERE ISNULL(VisitDate, '')<>''
  

UNION

  SELECT [VisitID]
      ,[SiteID]
      ,[PatientId]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[crfName]
      ,[crfStatus]
      ,[Treatment]
      ,[otherTreatment]
      ,[TreatmentStatus]
      ,[FirstDoseToday]
      ,[firstUse]
	  ,'' AS enteredStartDate
      ,CASE WHEN RIGHT(startDate, 2) ='//' THEN REPLACE(startDate, '/', '/01')
	   WHEN UPPER([startDate]) LIKE '%UNK%' THEN ''
	   WHEN LEN([startDate])=8 THEN [startDate] + '01'
	   ELSE [startDate]
	   END AS [startDate]
      ,[StartReasons]
      ,CASE WHEN RIGHT(changeDate, 2) ='//' THEN REPLACE(startDate, '/', '/01')
	   WHEN UPPER([changeDate]) LIKE '%UNK%' THEN ''
	   WHEN LEN([changeDate])=8 THEN [changeDate] + '01'
	   ELSE [changeDate]
	   END AS [changeDate]
      ,[changeReasons]
      ,[Dose]
      ,[Frequency]
      ,CASE WHEN RIGHT(stopDate, 2) ='//' THEN REPLACE(startDate, '/', '/01')
	   WHEN UPPER([stopDate]) LIKE '%UNK%' THEN ''
	   WHEN LEN([stopDate])=8 THEN [stopDate] + '01'
	   ELSE [stopDate]
	   END AS [stopDate]
      ,[StopReasons]
  FROM [Reporting].[PSO500].[v_op_FollowUpDrugs]
    ) AD
		 
--SELECT * FROM #ALLDRUGS WHERE ISNULL(startDate, '')<>'' and ISDATE(startDate)=0

TRUNCATE TABLE [Reporting].[PSO500].[t_op_AllDrugs];

INSERT INTO [Reporting].[PSO500].[t_op_AllDrugs]
(
	   [VisitID]
      ,[SiteID]
      ,[PatientId]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[crfName]
      ,[crfStatus]
      ,[Treatment]
      ,[otherTreatment]
      ,[TreatmentStatus]
      ,[FirstDoseToday]
      ,[firstUse]
	  ,[enteredStartDate]
      ,[startDate]
      ,[startReasons]
      ,[changeDate]
      ,[changeReasons]
      ,[Dose]
      ,[Frequency]
      ,[stopDate]
      ,[stopReasons]
)

SELECT DISTINCT [VisitID]
      ,[SiteID]
      ,[PatientId]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[crfName]
      ,[crfStatus]
      ,[Treatment]
      ,[otherTreatment]
      ,[TreatmentStatus]
      ,[FirstDoseToday]
      ,[firstUse]
	  ,[enteredStartDate]
      ,[startDate]
      ,[startReasons]
      ,[changeDate]
      ,[changeReasons]
      ,[Dose]
      ,[Frequency]
      ,[stopDate]
      ,[stopReasons]
FROM #ALLDRUGS 

--SELECT * FROM [Reporting].[PSO500].[t_op_AllDrugs] ORDER BY SiteID, SubjectID, VisitDate, Treatment, otherTreatment



END



GO
