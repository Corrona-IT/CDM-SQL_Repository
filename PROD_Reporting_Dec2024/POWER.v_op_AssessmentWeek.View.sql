USE [Reporting]
GO
/****** Object:  View [POWER].[v_op_AssessmentWeek]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE VIEW [POWER].[v_op_AssessmentWeek]  AS


SELECT DISTINCT CASE WHEN t_op_CaseMgmtCompliance.AssessmentWeek IS NULL THEN 99
                ELSE t_op_CaseMgmtCompliance.AssessmentWeek
				END AS AssessmentWeekOrder,
CASE WHEN [Reporting].[POWER].t_op_CaseMgmtCompliance.AssessmentWeek=99 THEN 'n/a'
WHEN ISNULL(t_op_CaseMgmtCompliance.AssessmentWeek, '')='' THEN 'n/a'
ELSE CAST([Reporting].[POWER].t_op_CaseMgmtCompliance.AssessmentWeek AS nvarchar) 
END AS AssessmentWeek 
FROM [Reporting].[POWER].t_op_CaseMgmtCompliance
--ORDER BY AssessmentWeekOrder

GO
