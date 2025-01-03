USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_VisitProviderIDs]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [PSO500].[v_op_VisitProviderIDs] AS

SELECT CAST(VisitId AS bigint) AS VisitID
	  ,[Sys. SiteNo] AS SiteID
	  ,[TrlObjectPatientID] as PatientID
	  ,CAST([Sys. PatientNo] AS bigint) AS SubjectID
	  ,CAST([Sys. VisitDate] AS date) AS VisitDate
	  ,[Sys. VisitCaption] AS VisitType
      ,Physician_Cod AS ProviderID
FROM OMNICOMM_PSO.inbound.[G_EXIT1]
WHERE [Sys. SiteNo] NOT IN (997, 998, 999)

UNION

SELECT CAST(VisitId AS bigint) AS VisitID
	  ,CAST([Site Object SiteNo] AS int) AS SiteID
      ,PatientId
	  ,CAST([Patient Object PatientNo] AS bigint) AS SubjectID
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[Visit Object Description] AS VisitType
	  ,CAST([PE1_md_cod] AS int) AS ProviderID
FROM OMNICOMM_PSO.inbound.[PE]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)

UNION 

SELECT CAST(VisitId AS bigint) AS VisitID
	  ,CAST([Site Object SiteNo] AS int) AS SiteID
      ,PatientId
	  ,CAST([Patient Object PatientNo] AS bigint) AS SubjectID
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[Visit Object Description] AS VisitType
	  ,CAST([PE1F_md_cod_fu] AS int) AS ProviderID
FROM OMNICOMM_PSO.inbound.[PE2]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)

GO
