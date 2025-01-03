USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_DuplicateVisits]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [RA100].[v_op_DuplicateVisits] AS


with DUPLICATES as
(SELECT SIT.[Site Information_Site Number] AS [Site ID]
      ,PAT.[Patient Object PatientNo] AS [Subject ID]
	  ,CAST(VIS.[Visit Object VisitDate] as date) AS [Visit Date]
      ,VIS.[Visit Object Procaption] AS [Visit Type]
	  ,FORMS.[Status] as [Visit Status]
      ,VIS.[Visit Object InstanceNo] AS [Visit Object InstanceNo]
	  ,(SELECT COUNT(VIS2.[Visit Object InstanceNo]) FROM [OMNICOMM_RA100].[dbo].[VISIT] VIS2
	    WHERE VIS2.PatientId=PAT.PatientId AND VIS2.[Visit Object Procaption]=VIS.[Visit Object Procaption]
		AND VIS2.[Visit Object InstanceNo]=VIS.[Visit Object InstanceNo]) AS [Count of Visit]
	  ,ROW_NUMBER() OVER (PARTITION BY SIT.[Site Information_Site Number], PAT.[Patient Object PatientNo], VIS.[Visit Object Procaption], VIS.[Visit Object InstanceNo] ORDER BY SIT.[Site Information_Site Number], 
	   PAT.[Patient Object PatientNo], VIS.[Visit Object VisitDate], VIS.[Visit Object Procaption], VIS.[Visit Object InstanceNo]) AS RowNumber

FROM [OMNICOMM_RA100].[dbo].[VISIT] VIS
INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.PatientId = VIS.PatientId
inner join [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[Forms] FORMS ON vis.formid=forms.formid
INNER JOIN [OMNICOMM_RA100].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId

WHERE VIS.[Visit Object Procaption] IN ('Enrollment', 'Follow-up', 'Exit')
AND VIS.[Visit Object VisitDate] <> ''
AND (SELECT COUNT(VIS2.[Visit Object InstanceNo]) FROM [OMNICOMM_RA100].[dbo].[VISIT] VIS2
	    WHERE VIS2.PatientId=PAT.PatientId AND VIS2.[Visit Object Procaption]=VIS.[Visit Object Procaption]
		AND VIS2.[Visit Object InstanceNo]=VIS.[Visit Object InstanceNo])>1
)

SELECT [Site ID]
      ,CAST([Subject ID] AS dec(10,0)) AS[Subject ID]
	  ,Cast([Visit Date] AS date) AS [Visit Date]
	  ,[Visit Type]
	  ,[Visit Status]
	  ,[Visit Object InstanceNo]
	  ,[Count of Visit]
      ,RowNumber

FROM DUPLICATES D


GO
