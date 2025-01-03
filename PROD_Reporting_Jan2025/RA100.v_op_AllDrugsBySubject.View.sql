USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_AllDrugsBySubject]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [RA100].[v_op_AllDrugsBySubject]  AS

SELECT DISTINCT *
FROM
(
SELECT DISTINCT [SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[NoTreatment]
      ,[TreatmentName]
      ,[ChangesToday]
      ,[FirstUseDate]
      ,[CurrentDose]
      ,[CurrentFrequency]
      ,[MostRecentDoseNotCurrentDose]
      ,[MostRecentPastUseDate]
  FROM [RA100].[t_op_Enrollment_Drugs]
  WHERE PageDescription='(Page 4)Provider Enrollment Questionnaire'
  
  UNION

  SELECT DISTINCT [SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitDate]
      ,[NoTreatment]
      ,[TreatmentName]
      ,[ChangesToday]
      ,[FirstUseDate]
      ,[CurrentDose]
      ,[CurrentFrequency]
      ,[MostRecentDoseNotCurrentDose]
      ,[MostRecentPastUseDate]
  FROM [RA100].[t_op_FollowUp_Drugs]
) AllDrugs
--WHERE SubjectID NOT IN (SELECT SubjectID FROM [RA100].[v_op_Exits])
--ORDER BY SiteID, SubjectID, VisitDate, TreatmentName

GO
