USE [Reporting]
GO
/****** Object:  View [PSO500].[v_EligDashboard]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [PSO500].[v_EligDashboard] AS

WITH DASHBOARD AS
(
SELECT ROW_NUMBER() OVER (PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, [Eligible Treatment]) AS ROWNUM
      ,[SiteID]
      ,[SubjectID]
	  ,[Eligible Treatment]
      ,[EnrollmentDate]
 
  FROM [PSO500].[t_Elig]
 WHERE ISNULL([Eligible Treatment],'')<>'' 
 )


 SELECT [SiteID] AS [Site ID]
	   ,[SubjectID] AS [Subject ID]
	   ,[Eligible Treatment]
	   ,CAST([EnrollmentDate] AS DATE) AS [Enrollment Date]

FROM DASHBOARD 
WHERE ROWNUM=1

---ORDER BY SITENUMBER, SUBJECTID







GO
