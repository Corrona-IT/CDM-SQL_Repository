USE [Reporting]
GO
/****** Object:  View [RA100].[v_pv_NSAEDetectionWithOrenciaIndicator]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [RA100].[v_pv_NSAEDetectionWithOrenciaIndicator]  as




SELECT DISTINCT
      SIT.[Site Number] AS [Site ID],
      PAT.[Caption] AS [Subject ID],
	  CAST(P.[Visit Object VisitDate] AS date) AS [Visit Date],
	  P.[Visit Object Caption] AS [Visit Name],
	  P.[PHF6B_CMT1] AS [Co-M/Tox/Inf],
	  P.[PHF6B_CMTSPC1] AS [Specified Other],
	  CASE WHEN PHFQ4.[PHF8B_CMTRT5] = 'abatacept (Orencia)'
	  THEN 'Yes'
	  ELSE 'No'
	  END AS [Orencia Recorded at Visit?],
	  CAST(P.[Form Object LastChange] AS date) AS [Last Modification Date]
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[Patients] PAT
INNER JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
INNER JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ2_PHF6B] P ON P.PatientId = PAT.PatientID
LEFT JOIN 
	(
		SELECT [PHF8B_CMTRT5], [VisitId] 
		FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ4_PHF8B] 
		WHERE [PHF8B_CMTRT5] = 'abatacept (Orencia)') AS PHFQ4 ON PHFQ4.VisitId = P.VisitId
WHERE P.[PHF6B_CMAPP1] <> ''
AND P.[PHF6B_CMT1] NOT LIKE '%TAE%'

UNION

SELECT DISTINCT 
      SIT.[Site Number] AS [Site ID],
      PAT.[Caption] AS [Subject ID],
	  P2.[Visit Object VisitDate] AS [Visit Date],
	  P2.[Visit Object Caption] AS [Visit Name],
	  P2.[PHF6C_CMT2] AS [Co-M/Tox/Inf],
	  P2.[PHF6C_CMTSPC2] AS [Specified Other],
	  CASE WHEN PHFQ4.[PHF8B_CMTRT5] = 'abatacept (Orencia)'
	  THEN 'Yes'
	  ELSE 'No'
	  END AS [Orencia Recorded at Visit?],
	  CAST(P2.[Form Object LastChange] AS date) AS [Last Modification Date]
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[Patients] PAT
INNER JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
INNER JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ2_PHF6C] P2 ON P2.PatientId = PAT.PatientID
LEFT JOIN 
	(
		SELECT [PHF8B_CMTRT5], [VisitId] 
		FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ4_PHF8B] 
		WHERE [PHF8B_CMTRT5] = 'abatacept (Orencia)') AS PHFQ4 ON PHFQ4.VisitId = P2.VisitId
WHERE P2.[PHF6C_CMAPP2] <> ''
AND P2.[PHF6C_CMT2] NOT LIKE '%TAE%'

UNION

SELECT DISTINCT 
      SIT.[Site Number] AS [Site ID],
      PAT.[Caption] AS [Subject ID],
	  P3.[Visit Object VisitDate] AS [Visit Date],
	  P3.[Visit Object Caption] AS [Visit Name],
	  P3.[PHF7B_INFSITE] AS [Co-M/Tox/Inf],
	  P3.[PHF7B_INFSP1] AS [Specified Other],
	  CASE WHEN PHFQ4.[PHF8B_CMTRT5] = 'abatacept (Orencia)'
	  THEN 'Yes'
	  ELSE 'No'
	  END AS [Orencia Recorded at Visit?],
	  CAST(P3.[Form Object LastChange] AS date) AS [Last Modification Date]
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[Patients] PAT
INNER JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
INNER JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ3_PHF7B] P3 ON P3.PatientId = PAT.PatientID
LEFT JOIN 
	(
		SELECT [PHF8B_CMTRT5], [VisitId] 
		FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ4_PHF8B] 
		WHERE [PHF8B_CMTRT5] = 'abatacept (Orencia)') AS PHFQ4 ON PHFQ4.VisitId = P3.VisitId
WHERE P3.[PHF7B_INFAPP] <> ''
AND P3.[PHF7B_AEHOSPY] IS NULL 
AND P3.[PHF7B_AEPAY] IS NULL



GO
