USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_ModifiedSubjectIDs]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [RA100].[v_op_ModifiedSubjectIDs] AS


WITH RA_AUDIT AS
(
SELECT *
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[EXP_All Groups Template PatInfo_AUDIT]
WHERE QuestNa = 'Patient Number'
)

SELECT *
FROM RA_AUDIT



GO
