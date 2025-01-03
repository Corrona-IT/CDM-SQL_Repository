USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_VisitLogIncludesIneligible_v2]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [PSO500].[v_op_VisitLogIncludesIneligible_v2] AS


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

SELECT CAST(SIT.[Site Number] AS int) AS SiteID
      ,CAST(PAT.[PatientNo] AS bigint) AS SubjectID
	  ,CAST(VIS.VisitDate AS date) AS VisitDate
	  ,MonthString AS [Month]
	  ,DATEPART(YYYY, VIS.VisitDate) AS [Year]
	  ,VIS.ProCaption AS VisitType
	  ,CAST(VPI.ProviderID AS int) AS VisitProviderID

FROM OMNICOMM_PSO.inbound.[G_Site Information] SIT
INNER JOIN OMNICOMM_PSO.inbound.[Patients] PAT ON SIT.SiteId=PAT.SiteId
INNER JOIN OMNICOMM_PSO.inbound.[Visits] VIS ON VIS.PatientId=PAT.PatientId
LEFT JOIN [Reporting].[PSO500].[v_op_VisitProviderIDs] VPI ON VPI.VisitId=VIS.VisitID
LEFT JOIN MONTH_NAME MN ON DATEPART(M, VIS.VISITDATE)=MN.MonthCode
WHERE ISNULL(VIS.VisitDate, '') <> ''
AND VIS.ProCaption IN ('Enrollment', 'Follow-up', 'Exit')
AND SIT.[Site Number] NOT IN (997, 998, 999)



---ORDER BY SIT.[Site Number], PAT.[PatientNo], VIS.VisitDate



GO
