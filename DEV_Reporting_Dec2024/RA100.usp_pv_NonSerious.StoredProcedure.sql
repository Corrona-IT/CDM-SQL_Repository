USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_pv_NonSerious]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Kevin Soe
-- Create date: 12-Oct-2021
-- Description:	List of all Non-Serious adverse events (those without a {TAE} designation) 
-- along with info on any Drugs of Interest (DOI) they may be on based on drugs entered at the same visit 
-- the non-serious event was recorded.
-- =============================================

/*
			 SELECT * FROM
CREATE TABLE [RA100].[t_pv_NonSerious]
(
	[Site ID] [int] NULL,
	[SiteStatus] [nvarchar](1024) NULL,
	[Subject ID] [nvarchar](1024) NULL,
	[VisitID] [bigint] NULL,
	[Visit Date] [date] NULL,
	[Visit Name] [nvarchar](1024) NULL,
	[Co-M/Tox/Inf] [nvarchar](1024) NULL,
	[Specified Other] [nvarchar](1024) NULL,
	[Onset Date] [nvarchar](1024) NULL,
	[DOI At Visit] [nvarchar](1024) NULL,
	[Other Specify] [nvarchar](1024) NULL,
	[Last Modification Date] [date] NULL
);
*/


			   --EXECUTE
CREATE PROCEDURE [RA100].[usp_pv_NonSerious]  as

		     --SELECT * FROM
TRUNCATE TABLE [Reporting].[RA100].[t_pv_NonSerious];

IF OBJECT_ID('tempdb.dbo.#Bari') IS NOT NULL BEGIN DROP TABLE #Bari END
--(
SELECT
       [PHF8B_CMTRT5] AS [DOI]
	  ,[VisitId]
--SELECT * FROM #Bari
INTO #Bari
FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] 
WHERE [PHF8B_CMTRT5] = 'baricitinib (Olumiant)'
--),

IF OBJECT_ID('tempdb.dbo.#Oren') IS NOT NULL BEGIN DROP TABLE #Oren END
SELECT
       [PHF8B_CMTRT5] AS [DOI]
	  ,[VisitId]
--SELECT * FROM #Oren
INTO #Oren
FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] 
WHERE [PHF8B_CMTRT5] = 'abatacept (Orencia)'
--),


IF OBJECT_ID('tempdb.dbo.#Rinv') IS NOT NULL BEGIN DROP TABLE #Rinv END
--SELECT * FROM #Rinv
SELECT * INTO #Rinv FROM
(SELECT 'upadacitinib (Rinvoq)' AS [DOI]
	  ,[PHF8B_CMOTH1] AS [OTH]
	  ,[VisitId]

FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] 
WHERE [PHF8B_CMTRT5] = 'Other' 
		AND 
		([PHF8B_CMOTH1] LIKE '%Rinvoq%'
		 OR
		 [PHF8B_CMOTH1] LIKE '%upadacitinib%'
		 OR
		 [PHF8B_CMOTH1] LIKE '%Rinv%'
		 OR
		 [PHF8B_CMOTH1] LIKE '%upad%')
UNION 
SELECT   'upadacitinib (Rinvoq)' AS [DOI]
	  ,[PHF10B_CMOTH1] AS [OTH]
	  ,[VisitId]

FROM [OMNICOMM_RA100].[dbo].[PHFQ5_PHF10B]
WHERE [PHF10B_CMTRT_34] = 'Other' 
		AND 
		([PHF10B_CMOTH1] LIKE '%Rinvoq%'
		 OR
		 [PHF10B_CMOTH1] LIKE '%upadacitinib%'
		 OR
		 [PHF10B_CMOTH1] LIKE '%Rinv%'
		 OR
		 [PHF10B_CMOTH1] LIKE '%upad%')
		 ) R
--),


IF OBJECT_ID('tempdb.dbo.#Oth') IS NOT NULL BEGIN DROP TABLE #Oth END
SELECT * INTO #Oth FROM
(SELECT
       [PHF8B_CMTRT5] AS [DOI]
	  ,[PHF8B_CMOTH1] AS [OTH]
	  ,[VisitId]
--SELECT * FROM #Oth

FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] 
WHERE [PHF8B_CMTRT5] = 'Other'
AND [PHF8B_CMOTH1] NOT LIKE '%Rinvoq%'
AND [PHF8B_CMOTH1] NOT LIKE '%upadacitinib%'
AND [PHF8B_CMOTH1] NOT LIKE '%Rinv%'
AND [PHF8B_CMOTH1] NOT LIKE '%upad%'

UNION

SELECT
       [PHF10B_CMTRT_34] AS [DOI]
	  ,[PHF10B_CMOTH1] AS [OTH]
	  ,[VisitId]
--SELECT * FROM #Oth

FROM [OMNICOMM_RA100].[dbo].[PHFQ5_PHF10B]
WHERE [PHF10B_CMTRT_34] = 'Other'
AND [PHF10B_CMOTH1] NOT LIKE '%Rinvoq%'
AND [PHF10B_CMOTH1] NOT LIKE '%upadacitinib%'
AND [PHF10B_CMOTH1] NOT LIKE '%Rinv%'
AND [PHF10B_CMOTH1] NOT LIKE '%upad%'
) O

--SELECT * FROM #DOIAtVisit
IF OBJECT_ID('tempdb.dbo.#DOIAtVisit') IS NOT NULL BEGIN DROP TABLE #DOIAtVisit END
	SELECT * INTO #DOIAtVisit FROM
	(	SELECT [DOI], NULL AS [OTH], [VisitId]
		FROM #Bari	  
		UNION		  
		SELECT [DOI], NULL AS [OTH], [VisitId]
		FROM #Oren
		UNION
		SELECT [DOI], [OTH], [VisitId]
		FROM #Rinv	  
		UNION		  
		SELECT [DOI], [OTH], [VisitId]
		FROM #Oth) DOI


--SELECT * FROM #NSAES
IF OBJECT_ID('tempdb.dbo.#NSAES') IS NOT NULL BEGIN DROP TABLE #NSAES END
	SELECT * INTO #NSAES FROM
		(SELECT DISTINCT
			SIT.[Site Information_Site Number] AS [Site ID],
			PAT.[Patient Information_Patient Number] AS [Subject ID],
			P.[VisitID] AS [VisitID],
			P.[Visit Object VisitDate] AS [Visit Date],
			P.[Visit Object Caption] AS [Visit Name],
			P.[PHF6B_CMT1] AS [Co-M/Tox/Inf],
			P.[PHF6B_CMTSPC1] AS [Specified Other],
			P.[PHF6B_CMSTDT3] AS [Onset Date],
			P.[Form Object LastChange] AS [Last Modification Date]
		FROM [OMNICOMM_RA100].[dbo].[PAT] PAT
		INNER JOIN [OMNICOMM_RA100].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ2_PHF6B] P ON P.PatientId = PAT.PatientID
		WHERE P.[PHF6B_CMAPP1] <> ''
		AND P.[PHF6B_CMT1] NOT LIKE '%TAE%'

		UNION

		SELECT DISTINCT 
		    SIT.[Site Information_Site Number] AS [Site ID],
		    PAT.[Patient Information_Patient Number] AS [Subject ID],
			P2.[VisitID] AS [VisitID],
			P2.[Visit Object VisitDate] AS [Visit Date],
			P2.[Visit Object Caption] AS [Visit Name],
			P2.[PHF6C_CMT2] AS [Co-M/Tox/Inf],
			P2.[PHF6C_CMTSPC2] AS [Specified Other],
			P2.[PHF6C_CMSTDT4] AS [Onset Date],
			P2.[Form Object LastChange] AS [Last Modification Date]
		FROM [OMNICOMM_RA100].[dbo].[PAT] PAT
		INNER JOIN [OMNICOMM_RA100].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ2_PHF6C] P2 ON P2.PatientId = PAT.PatientID
		WHERE P2.[PHF6C_CMAPP2] <> ''
		AND P2.[PHF6C_CMT2] NOT LIKE '%TAE%'

		UNION
		
		SELECT DISTINCT 
		    SIT.[Site Information_Site Number] AS [Site ID],
		    PAT.[Patient Information_Patient Number] AS [Subject ID],
			P3.[VisitID] AS [VisitID],
			P3.[Visit Object VisitDate] AS [Visit Date],
			P3.[Visit Object Caption] AS [Visit Name],
			P3.[PHF7B_INFSITE] AS [Co-M/Tox/Inf],
			P3.[PHF7B_INFSP1] AS [Specified Other],
			P3.[PHF7B_INFDAT2] AS [Onset Date],
			P3.[Form Object LastChange] AS [Last Modification Date]
		FROM [OMNICOMM_RA100].[dbo].[PAT] PAT
		INNER JOIN [OMNICOMM_RA100].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId
		INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHFQ3_PHF7B] P3 ON P3.PatientId = PAT.PatientID
		WHERE P3.[PHF7B_INFAPP] <> ''
		AND P3.[PHF7B_AEHOSPY] IS NULL 
		AND P3.[PHF7B_AEPAY] IS NULL
		) N


INSERT INTO [Reporting].[RA100].[t_pv_NonSerious]
(
	 [Site ID]
	,[SiteStatus]
	,[Subject ID]
	,[VisitID]
	,[Visit Date]
	,[Visit Name]
	,[Co-M/Tox/Inf]
	,[Specified Other]
	,[Onset Date]
	,[DOI At Visit]
	,[Other Specify]
	,[Last Modification Date]
)


		SELECT DISTINCT
			NSAES.[Site ID],
			SSTATUS.[SiteStatus],
			NSAES.[Subject ID],
			NSAES.[VisitID],
			NSAES.[Visit Date],
			NSAES.[Visit Name],
			NSAES.[Co-M/Tox/Inf],
			NSAES.[Specified Other],
			NSAES.[Onset Date],
		--CONCAT(CASE
		--	WHEN OREN.[PHF8B_CMTRT5] LIKE '%Orencia%' 
		--	THEN 'abatacept (Orencia)' 
		--	ELSE '' END,
		--CASE
		--	WHEN OREN.[PHF8B_CMTRT5] LIKE '%Orencia%' AND BARI.[PHF8B_CMTRT5] LIKE '%Olumiant%'
		--	THEN ', '
		--	ELSE '' END,
		--CASE
		--	WHEN BARI.[PHF8B_CMTRT5] LIKE '%Olumiant%'
		--	THEN 'baricitinib (Olumiant)'
		--	ELSE '' END) AS [DOI At Visit],		
			STUFF((SELECT ', ' + DOI FROM #DOIATVISIT D WHERE D.[VisitID]=NSAES.[VisitID] AND DOI <> '' FOR XML PATH('')),1,1, '') AS [DOI At Visit],
			--D.[OTH],
			STUFF((SELECT ', ' + OTH FROM #DOIATVISIT D WHERE D.[VisitID]=NSAES.[VisitID] AND DOI IS NOT NULL FOR XML PATH('')),1,1, '') AS [Other Specify],
			CAST(NSAES.[Last Modification Date] AS DATE) AS [Last Modification Date]
		FROM #NSAES NSAES
		--LEFT JOIN OREN ON OREN.[VisitID]=NSAES.[VisitID]
		--LEFT JOIN BARI ON BARI.[VisitID]=NSAES.[VisitID]
		LEFT JOIN [RA100].[v_op_SiteStatus] SSTATUS ON SSTATUS.[SiteID]=NSAES.[Site ID]
		LEFT JOIN #DOIAtVisit D  ON NSAES.[VisitID] = D.[VisitId]
		
				  


GO
