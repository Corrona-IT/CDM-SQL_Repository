USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_AllSubjects]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author: Kevin Soe
-- Create date: 22-FEB-2021
-- Description:	Create view for List of All Subjects for RA-100
-- =============================================


CREATE VIEW [RA100].[v_op_AllSubjects] AS

SELECT 

 [Patient Information_Site Number] AS [SiteID]
,CAST([Patient Information_Patient Number] AS bigint) AS [SubjectID]
,[Patient Information_Patient Number] AS [SubIDL0s]
,[PatientID]

FROM [OMNICOMM_RA100].[dbo].[PAT]
WHERE [Site Object SiteNo] NOT LIKE '99%'
GO
