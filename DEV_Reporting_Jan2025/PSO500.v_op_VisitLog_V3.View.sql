USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_VisitLog_V3]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [PSO500].[v_op_VisitLog_V3] AS


WITH MONTH_NAME AS
(
      select cast(1  as int) as MonthCode, 'Jan' as MonthString
union select cast(2  as int) as MonthCode, 'Feb' as MonthString
union select cast(3  as int) as MonthCode, 'Mar' as MonthString
union select cast(4  as int) as MonthCode, 'Apr' as MonthString
union select cast(5  as int) as MonthCode, 'May' as MonthString
union select cast(6  as int) as MonthCode, 'Jun' as MonthString
union select cast(7  as int) as MonthCode, 'Jul' as MonthString
union select cast(8  as int) as MonthCode, 'Aug' as MonthString
union select cast(9  as int) as MonthCode, 'Sep' as MonthString
union select cast(10 as int) as MonthCode, 'Oct' as MonthString
union select cast(11 as int) as MonthCode, 'Nov' as MonthString
union select cast(12 as int) as MonthCode, 'Dec' as MonthString
)

,ProviderID AS
(
SELECT VisitId
      ,PatientId
      ,[Patient Object PatientNo] AS SubjectID
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[Visit Object ProCaption] AS VisitType
	  ,PE1_md_cod AS ProviderID
FROM OMNICOMM_PSO.inbound.PE

UNION

SELECT VisitId
      ,PatientId
      ,[Patient Object PatientNo] AS SubjectID
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[Visit Object ProCaption] AS VisitType
	  ,PE1f_md_cod_fu AS ProviderID
FROM OMNICOMM_PSO.inbound.PE2

UNION

SELECT VisitId
      ,PatientId
      ,[Sys. PatientNo] AS SubjectID
	  ,CAST([Sys. VisitDate] AS date) AS VisitDate
	  ,[Sys. VisitCaption] AS VisitType
	  ,Physician_Cod AS ProviderID
FROM OMNICOMM_PSO.inbound.G_EXIT1

)


SELECT VIS.VisitId
      ,CAST(SIT.[Site Number] AS int) AS SiteID
      ,PAT.[PatientNo] AS SubjectID
	  ,VIS.VisitDate AS VisitDate
	  ,MonthString AS [Month]
	  ,DATEPART(YYYY, VIS.VisitDate) AS [Year]
	  ,VIS.ProCaption AS VisitType
	  ,CAST(VIS.[InstanceNo] AS int) as VisitSequence
	  ,CAST(PID.ProviderID AS int) AS ProviderID
	  ,'PSO-500' AS Registry


FROM OMNICOMM_PSO.inbound.[G_Site Information] SIT
INNER JOIN OMNICOMM_PSO.inbound.[Patients] PAT ON SIT.SiteId=PAT.SiteId
INNER JOIN OMNICOMM_PSO.inbound.[Visits] VIS ON VIS.PatientId=PAT.PatientId
LEFT JOIN ProviderID PID on PID.VisitId=VIS.VisitId and PID.PatientId=VIS.PatientId
LEFT JOIN MONTH_NAME MN ON DATEPART(M, VIS.VISITDATE)=MN.MonthCode
WHERE ISNULL(VIS.VisitDate, '') <> ''
AND VIS.ProCaption IN ('Enrollment', 'Follow-up', 'Exit')
AND [Site Number] NOT IN (997, 998, 999)


--ORDER BY SIT.[Site Number], PAT.[PatientNo], VIS.VisitDate






GO
