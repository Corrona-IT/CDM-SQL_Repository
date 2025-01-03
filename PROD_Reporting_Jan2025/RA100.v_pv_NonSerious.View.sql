USE [Reporting]
GO
/****** Object:  View [RA100].[v_pv_NonSerious]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [RA100].[v_pv_NonSerious]  as

WITH 

BARI AS
	(
		SELECT [PHF8B_CMTRT5], [VisitId] 
		FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ4_PHF8B] 
		WHERE [PHF8B_CMTRT5] = 'baricitinib (Olumiant)'
		)

,OREN AS 
	(	
		SELECT [PHF8B_CMTRT5], [VisitId] 
		FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ4_PHF8B] 
		WHERE [PHF8B_CMTRT5] = 'abatacept (Orencia)'
		)

,NSAES AS
	(
		SELECT DISTINCT
			SIT.[Site Number] AS [Site ID],
			PAT.[Patient Information_Patient Number] AS [Subject ID],
			P.[VisitID] AS [VisitID],
			P.[Visit Object VisitDate] AS [Visit Date],
			P.[Visit Object Caption] AS [Visit Name],
			P.[PHF6B_CMT1] AS [Co-M/Tox/Inf],
			P.[PHF6B_CMTSPC1] AS [Specified Other],
			P.[PHF6B_CMSTDT3] AS [Onset Date],
			P.[Form Object LastChange] AS [Last Modification Date]
		FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PAT] PAT
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ2_PHF6B] P ON P.PatientId = PAT.PatientID
		WHERE P.[PHF6B_CMAPP1] <> ''
		AND P.[PHF6B_CMT1] NOT LIKE '%TAE%'

		UNION

		SELECT DISTINCT 
		    SIT.[Site Number] AS [Site ID],
		    PAT.[Patient Information_Patient Number] AS [Subject ID],
			P2.[VisitID] AS [VisitID],
			P2.[Visit Object VisitDate] AS [Visit Date],
			P2.[Visit Object Caption] AS [Visit Name],
			P2.[PHF6C_CMT2] AS [Co-M/Tox/Inf],
			P2.[PHF6C_CMTSPC2] AS [Specified Other],
			P2.[PHF6C_CMSTDT4] AS [Onset Date],
			P2.[Form Object LastChange] AS [Last Modification Date]
		FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PAT] PAT
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ2_PHF6C] P2 ON P2.PatientId = PAT.PatientID
		WHERE P2.[PHF6C_CMAPP2] <> ''
		AND P2.[PHF6C_CMT2] NOT LIKE '%TAE%'

		UNION
		
		SELECT DISTINCT 
		    SIT.[Site Number] AS [Site ID],
		    PAT.[Patient Information_Patient Number] AS [Subject ID],
			P3.[VisitID] AS [VisitID],
			P3.[Visit Object VisitDate] AS [Visit Date],
			P3.[Visit Object Caption] AS [Visit Name],
			P3.[PHF7B_INFSITE] AS [Co-M/Tox/Inf],
			P3.[PHF7B_INFSP1] AS [Specified Other],
			P3.[PHF7B_INFDAT2] AS [Onset Date],
			P3.[Form Object LastChange] AS [Last Modification Date]
		FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PAT] PAT
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ3_PHF7B] P3 ON P3.PatientId = PAT.PatientID
		WHERE P3.[PHF7B_INFAPP] <> ''
		AND P3.[PHF7B_AEHOSPY] IS NULL 
		AND P3.[PHF7B_AEPAY] IS NULL
		)

		SELECT DISTINCT
			NSAES.[Site ID],
			SSTATUS.[SiteStatus],
			NSAES.[Subject ID],
			NSAES.[Visit Date],
			NSAES.[Visit Name],
			NSAES.[Co-M/Tox/Inf],
			NSAES.[Specified Other],
			NSAES.[Onset Date],
			CONCAT(CASE
				WHEN OREN.[PHF8B_CMTRT5] LIKE '%Orencia%' 
				THEN 'abatacept (Orencia)' 
				ELSE '' END,
			CASE
				WHEN OREN.[PHF8B_CMTRT5] LIKE '%Orencia%' AND BARI.[PHF8B_CMTRT5] LIKE '%Olumiant%'
				THEN ', '
				ELSE '' END,
			CASE
				WHEN BARI.[PHF8B_CMTRT5] LIKE '%Olumiant%'
				THEN 'baricitinib (Olumiant)'
				ELSE '' END) AS [DOI At Visit],		 
			CAST(NSAES.[Last Modification Date] AS DATE) AS [Last Modification Date]
		FROM NSAES
		LEFT JOIN OREN ON OREN.[VisitID]=NSAES.[VisitID]
		LEFT JOIN BARI ON BARI.[VisitID]=NSAES.[VisitID]
		LEFT JOIN [RA100].[v_op_SiteStatus] SSTATUS ON SSTATUS.[SiteID]=NSAES.[Site ID]
		
				  


GO
