USE [Reporting]
GO
/****** Object:  View [POWER].[v_op_uat_CaseManagementLookup]    Script Date: 8/1/2024 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [POWER].[v_op_uat_CaseManagementLookup]  AS

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY patient_id, first_name, last_name, preferredcontact DESC, preferredemail DESC, bestphone DESC, preferredTime DESC, timezone_code DESC, city, [state]) AS ROWNUM
      ,patient_id AS SubjectID
      ,first_name AS firstName
	  ,last_name AS lastName
	  ,preferredcontact AS preferredContactMethod
	  ,preferredemail AS emailAddress
	  ,bestphone AS phoneNumber
	  ,preferredTime AS preferredContactTimeOfDay
	  ,timezone_code AS timeZone
	  ,city AS City
	  ,[state] AS [State]

FROM [APowerUAT].[dbo].[case_management]

--ORDER BY patient_id, ROWNUM
GO
