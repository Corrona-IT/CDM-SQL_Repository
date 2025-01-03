USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_AllSubjectsWTrlIDs]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author: Kevin Soe
-- Create date: 7-Feb-2022
-- Description:	Create view for List of All Subjects W TrlObjectPatientIDs for RA-100
-- =============================================
		 --SELECT * FROM
CREATE VIEW [RA100].[v_op_AllSubjectsWTrlIDs] AS

SELECT 

	   [Site Number] AS [SiteID]
	  ,CAST([Patient Number] AS bigint) AS [SubjectID]
      ,[Patient Number] AS [SubIDL0s]
	  ,[TrlObjectPatientId] AS [PatientID]

  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[GL_Patient Information]
  WHERE [Site Number] NOT LIKE '99%'
GO
