USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_Dashboard]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [PSO500].[v_op_Dashboard] AS

SELECT [Site ID] AS [SiteID]
      ,[Subject ID] AS [SubjectID]
      ,[Eligible Treatment] AS [EligibleTreatment]
      ,CAST([Enrollment Date] AS DATE) AS [EnrollmentDate]
	  ,DATEPART(Month, [Enrollment Date]) AS [EnrollmentMonth]
	  ,DATEPART(Year, [Enrollment Date]) AS [EnrollmentYear]
  FROM [PSO500].[t_EligDashboard]

GO
