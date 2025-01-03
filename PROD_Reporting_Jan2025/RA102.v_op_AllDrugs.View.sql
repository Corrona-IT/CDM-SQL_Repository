USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_AllDrugs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [RA102].[v_op_AllDrugs] AS 
(
SELECT 0 AS VisitOrder
      ,[VisitId]
      ,[PatientId]
      ,[SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[PageDescription]
      ,[Page4FormStatus]
      ,[Page5FormStatus]
      ,[NoTreatment]
	  ,NULL AS RowID
      ,[TreatmentName]
      ,[ChangesToday]
      ,[FirstUseDate]
      ,[CalcStartDate]
      ,[CurrentDose]
      ,[CurrentFrequency]
      ,[MostRecentDoseNotCurrentDose]
      ,[MostRecentPastUseDate]
  FROM [RA100].[t_op_Enrollment_Drugs]

  UNION

  SELECT [VisitOrder]
      ,[VisitId]
      ,[PatientId]
      ,[SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[PageDescription]
      ,[Page4FormStatus]
      ,[Page5FormStatus]
      ,[NoTreatment]
      ,[RowID]
      ,[TreatmentName]
      ,[ChangesToday]
      ,[FirstUseDate]
      ,[CalcStartDate]
      ,[CurrentDose]
      ,[CurrentFrequency]
      ,[MostRecentDoseNotCurrentDose]
      ,[MostRecentPastUseDate]
  FROM [RA100].[t_op_FollowUp_Drugs]

  )

GO
