USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_ExitReport]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [PSO500].[v_op_ExitReport] AS

SELECT SIT.[Site Number] AS [Site ID],
       PAT.[Caption] AS SubjectID,   
	   VIS.[Visit Object VisitDate] AS [VisitDate],
	   VIS.[Visit Object Procaption] AS [VisitType],
	   E.[EXIT2_exit_reason] AS [Exit Reason],
	   E.[EXIT2_other_specify] AS [Other Exit Reason, Specify]

FROM [OMNICOMM_PSO].[inbound].[VISIT] VIS
INNER JOIN [OMNICOMM_PSO].[inbound].[Patients] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
INNER JOIN [172.21.8.121].[DataModel_TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[EXIT] E ON E.VisitId = VIS.VisitId
WHERE VIS.[Visit Object Procaption] = 'Exit'
AND VIS.[Visit Object VisitDate] <> ''
AND SIT.[Site Number] NOT IN (998, 999)
AND VIS.[Visit Object VisitDate] >=  (SELECT MAX(VisitDate) FROM [Reporting].[PSO500].[v_op_VisitLog] VL WHERE VL.SubjectID=PAT.[Caption] AND VL.SiteID=SIT.[Site Number] AND VL.VisitType IN ('Enrollment', 'Follow-up'))

GO
