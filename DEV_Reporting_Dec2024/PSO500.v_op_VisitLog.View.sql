USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_VisitLog]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [PSO500].[v_op_VisitLog] AS


WITH ProviderID AS
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

,VLOG AS
(
SELECT VIS.VisitId
      ,CAST(SIT.[Site Number] AS int) AS SiteID
      ,PAT.[PatientNo] AS SubjectID
	  ,VIS.VisitDate AS VisitDate
	  ,SUBSTRING(DATENAME(month, VIS.VisitDate),1 , 3) AS [Month]
	  ,DATEPART(YYYY, VIS.VisitDate) AS [Year]
	  ,VIS.ProCaption AS VisitType
	  ,V.Visit_VISVIRMD AS DataCollectionType
	  ,CAST(VIS.[InstanceNo] AS int) as VisitSequence
	  ,CAST(PID.ProviderID AS int) AS ProviderID

FROM OMNICOMM_PSO.inbound.[G_Site Information] SIT
INNER JOIN OMNICOMM_PSO.inbound.[Patients] PAT ON SIT.SiteId=PAT.SiteId
INNER JOIN OMNICOMM_PSO.inbound.[Visits] VIS ON VIS.PatientId=PAT.PatientId
LEFT JOIN OMNICOMM_PSO.inbound.VISIT V ON V.VisitId=VIS.VisitId
LEFT JOIN ProviderID PID on PID.VisitId=VIS.VisitId and PID.PatientId=VIS.PatientId
WHERE ISNULL(VIS.VisitDate, '') <> ''
AND VIS.ProCaption IN ('Enrollment', 'Follow-up', 'Exit')
AND [Site Number] NOT IN (997, 998, 999)
)

SELECT DISTINCT VisitId
      ,VLOG.SiteID
	  ,CASE WHEN VLOG.SiteID IN (998, 999) THEN 'Active'
	   ELSE SS.SiteStatus
	   END AS SiteStatus
	  ,RS.currentStatus AS SFSiteStatus
	  ,SubjectID
	  ,VisitDate
	  ,[Month]
	  ,[Year]
	  ,VisitType
	  ,DataCollectionType
	  ,VisitSequence
	  ,CASE WHEN VisitType = 'Exit' THEN 99
	    WHEN VisitType = 'Enrollment' THEN 0
		WHEN VisitType = 'Follow-up' THEN ROW_NUMBER() OVER (PARTITION BY SubjectID, VisitType ORDER BY VisitDate)  
		END AS CalcVisitSequence
	  ,CASE WHEN ISNULL(ProviderID, '')='' THEN CAST(NULL AS int)
	   ELSE ProviderID
	   END AS ProviderID
	  ,'PSO-500' AS Registry
	  ,'Psoriasis (PSO-500)' AS RegistryName
FROM VLOG 
LEFT JOIN [Reporting].[PSO500].[v_op_SiteStatus2] SS ON SS.SiteID=VLOG.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]='Psoriasis (PSO-500)' AND CAST(RS.[siteNumber] AS int)=CAST(VLOG.SiteID AS int)
WHERE ISNULL(VisitDate, '')<>''

--ORDER BY SiteID desc, SubjectID, VisitDate






GO
