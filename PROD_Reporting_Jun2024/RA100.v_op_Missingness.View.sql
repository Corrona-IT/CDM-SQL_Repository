USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_Missingness]    Script Date: 7/15/2024 12:41:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =================================================
-- Author:		Kevin Soe
-- Create date: 09/27/2022
-- Description:	Determine critical assesments are missing. 1=Missing 0=Not Missing
-- =================================================

		 --SELECT * FROM
CREATE VIEW [RA100].[v_op_Missingness] AS

SELECT 
	 CAST(VIS.[Site Object SiteNo] AS int) AS [SiteID]
	,VIS.[Patient Object PatientNo] AS [SubjectID]
	,VIS.[Visit Object ProCaption] AS [VisitType]
	,CAST(VIS.[Visit Object VisitDate] AS DATE) AS [VisitDate]
	,'' AS [VisitCode]
	,CASE 
		WHEN PE1.[PHE3_T28ORRES] IS NULL THEN 1
		--WHEN PE1.[PHE3_S28ORRES] IS NOT NULL THEN 0
		ELSE 0
	 END AS [28T]
	,CASE 
		WHEN PE1.[PHE3_S28ORRES] IS NULL THEN 1
		--WHEN PE1.[PHE3_S28ORRES] IS NOT NULL THEN 0
		ELSE 0
	 END AS [28S]
	,CASE 
		WHEN PE1.[PHE4_PGA] IS NULL THEN 1
		--WHEN PE1.[PHE4_PGA] IS NOT NULL THEN 0
		ELSE 0
	 END AS [PGA]
	,CASE 
		WHEN ISNULL(PE2.[PEQ8A_PEQ801],'')='' AND ISNULL(PE2.[PEQ8A_PEQ802],'')='' AND ISNULL(PE2.[PEQ8A_PEQ803],'')='' AND  ISNULL(PE2.[PEQ8A_PEQ804],'')='' AND ISNULL(PE2.[PEQ8A_PEQ804],'')='' AND ISNULL(PE2.[PEQ8A_PEQ805],'')='' AND ISNULL(PE2.[PEQ8A_PEQ806],'')='' AND ISNULL(PE2.[PEQ8A_PEQ807],'')='' AND ISNULL(PE2.[PEQ8A_PEQ808],'')='' AND ISNULL(PE2.[PEQ8A_PEQ805],'')='' AND ISNULL(PE2.[PEQ8B_PEQ810],'')='' AND ISNULL(PE2.[PEQ8B_PEQ811],'')='' AND ISNULL(PE2.[PEQ8B_PEQ812],'')='' AND ISNULL(PE2.[PEQ8B_PEQ813],'')='' AND ISNULL(PE2.[PEQ8B_PEQ814],'')='' AND ISNULL(PE2.[PEQ8B_PEQ815],'')='' AND ISNULL(PE2.[PEQ8B_PEQ816],'')='' AND ISNULL(PE2.[PEQ8C_PEQ817],'')='' AND ISNULL(PE2.[PEQ8C_PEQ818],'')='' AND ISNULL(PE2.[PEQ8C_PEQ819],'')='' AND ISNULL(PE2.[PEQ8C_PEQ820],'')='' AND ISNULL(PE2.[PEQ8D_PEQ821],'')='' AND ISNULL(PE2.[PEQ8D_PEQ822],'')='' AND ISNULL(PE2.[PEQ8D_PEQ823],'')='' AND ISNULL(PE2.[PEQ8D_PEQ824],'')='' AND ISNULL(PE2.[PEQ8D_PEQ825],'')='' AND ISNULL(PE2.[PEQ8D_PEQ826],'')='' AND ISNULL(PE2.[PEQ8D_PEQ827],'')='' AND ISNULL(PE2.[PEQ8D_PEQ828],'')='' AND ISNULL(PE2.[PEQ8D_PEQ829],'')='' AND ISNULL(PE2.[PEQ8D_PEQ830],'')='' AND ISNULL(PE2.[PEQ8D_PEQ831],'')='' AND ISNULL(PE2.[PEQ8E_PEQ832],'')='' AND ISNULL(PE2.[PEQ8E_PEQ833],'')='' AND ISNULL(PE2.[PEQ8E_PEQ834],'')='' AND ISNULL(PE2.[PEQ8E_PEQ836],'')='' AND ISNULL(PE2.[PEQ8E_PEQ837],'')='' AND ISNULL(PE2.[PEQ8E_PEQ838],'')='' AND ISNULL(PE2.[PEQ8F_PEQ839],'')='' AND ISNULL(PE2.[PEQ8F_PEQ840],'')='' AND ISNULL(PE2.[PEQ8F_PEQ841],'')='' AND ISNULL(PE2.[PEQ8F_PEQ842],'')='' 
		THEN 1
		--WHEN PF2.[PEQ10_PEQ10] IS NOT NULL THEN 0
		ELSE 0
	 END AS [HAQ]
	,CASE 
		WHEN PE3.[PEQ10_PEQ10] IS NULL THEN 1
		--WHEN PE3.[PEQ10_PEQ10] IS NOT NULL THEN 0
		ELSE 0
	 END AS [PGV]
	--,PE3.[PEQ10_PEQ10]  AS [PGVActual]
	,CASE 
		WHEN ISNULL(PE5.[PEQ18_PEQ21A],'')='' AND ISNULL(PE5.[PEQ18_PEQ21B],'')='' AND ISNULL(PE5.[PEQ18_PEQ21C],'')='' AND  ISNULL(PE5.[PEQ18_PEQ21D],'')='' AND ISNULL(PE5.[PEQ18_PEQ21E],'')='' THEN 1
		--WHEN PE5.[PEQ10_PEQ10] IS NOT NULL THEN 0
		ELSE 0
	 END AS [EQ5]	 --SELECT *
  FROM [OMNICOMM_RA100].[dbo].[VISIT] VIS
  LEFT JOIN --SELECT * FROM
  [OMNICOMM_RA100].[dbo].[PHEQ1] PE1 ON VIS.PatientId = PE1.[PatientId] AND VIS.[VisitId] = PE1.[VisitId]
  LEFT JOIN --SELECT TOP 10 * FROM
  [OMNICOMM_RA100].[dbo].[PEQ2] PE2 ON VIS.PatientId = PE2.[PatientId] AND VIS.[VisitId] = PE2.[VisitId]
  LEFT JOIN --SELECT * FROM
 [OMNICOMM_RA100].[dbo].[PEQ3] PE3 ON VIS.PatientId = PE3.[PatientId] AND VIS.[VisitId] = PE3.[VisitId]
  LEFT JOIN --SELECT * FROM
 [OMNICOMM_RA100].[dbo].[PEQ5] PE5 ON VIS.PatientId = PE5.[PatientId] AND VIS.[VisitId] = PE5.[VisitId]
  WHERE VIS.[Visit Object ProCaption] = 'Enrollment'
  AND ISNULL(VIS.[Visit Object VisitDate],'')<>''
  AND [VIS].[Site Object SiteNo] NOT IN ('999','998')

  UNION

SELECT 
	 CAST(VIS.[Site Object SiteNo] AS int) AS [SiteID]
	,VIS.[Patient Object PatientNo] AS [SubjectID]
	,VIS.[Visit Object ProCaption] AS [VisitType]
	,CAST(VIS.[Visit Object VisitDate] AS DATE) AS [VisitDate]
	,'' AS [VisitCode]
	,CASE 
		WHEN PF1.[PHF2_T28ORRES] IS NULL THEN 1
		--WHEN PF1.[PHF2_S28ORRES] IS NOT NULL THEN 0
		ELSE 0
	 END AS [28T]
	,CASE 
		WHEN PF1.[PHF2_S28ORRES] IS NULL THEN 1
		--WHEN PF1.[PHF2_S28ORRES] IS NOT NULL THEN 0
		ELSE 0
	 END AS [28S]
	,CASE 
		WHEN PF1.[PHF3_PGAF] IS NULL THEN 1
		--WHEN PF1.[PHF3_PGAF] IS NOT NULL THEN 0
		ELSE 0
	 END AS [PGA]
	,CASE 
		WHEN ISNULL(PF2.[PFQ4A_PEQ801],'')='' AND ISNULL(PF2.[PFQ4A_PEQ802],'')='' AND ISNULL(PF2.[PFQ4A_PEQ803],'')='' AND  ISNULL(PF2.[PFQ4A_PEQ804],'')='' AND ISNULL(PF2.[PFQ4A_PEQ804],'')='' AND ISNULL(PF2.[PFQ4A_PEQ805],'')='' AND ISNULL(PF2.[PFQ4A_PEQ806],'')='' AND ISNULL(PF2.[PFQ4A_PEQ807],'')='' AND ISNULL(PF2.[PFQ4A_PEQ808],'')='' AND ISNULL(PF2.[PFQ4A_PEQ805],'')='' AND ISNULL(PF2.[PFQ4B_PEQ810],'')='' AND ISNULL(PF2.[PFQ4B_PEQ811],'')='' AND ISNULL(PF2.[PFQ4B_PEQ812],'')='' AND ISNULL(PF2.[PFQ4B_PEQ813],'')='' AND ISNULL(PF2.[PFQ4B_PEQ814],'')='' AND ISNULL(PF2.[PFQ4B_PEQ815],'')='' AND ISNULL(PF2.[PFQ4B_PEQ816],'')='' AND ISNULL(PF2.[PFQ4C_PEQ817],'')='' AND ISNULL(PF2.[PFQ4C_PEQ818],'')='' AND ISNULL(PF2.[PFQ4C_PEQ819],'')='' AND ISNULL(PF2.[PFQ4C_PEQ820],'')='' AND ISNULL(PF2.[PFQ4D_PEQ821],'')='' AND ISNULL(PF2.[PFQ4D_PEQ822],'')='' AND ISNULL(PF2.[PFQ4D_PEQ823],'')='' AND ISNULL(PF2.[PFQ4D_PEQ824],'')='' AND ISNULL(PF2.[PFQ4D_PEQ825],'')='' AND ISNULL(PF2.[PFQ4D_PEQ826],'')='' AND ISNULL(PF2.[PFQ4D_PEQ827],'')='' AND ISNULL(PF2.[PFQ4D_PEQ828],'')='' AND ISNULL(PF2.[PFQ4D_PEQ829],'')='' AND ISNULL(PF2.[PFQ4D_PEQ830],'')='' AND ISNULL(PF2.[PFQ4D_PEQ831],'')='' AND ISNULL(PF2.[PFQ4E_PEQ832],'')='' AND ISNULL(PF2.[PFQ4E_PEQ833],'')='' AND ISNULL(PF2.[PFQ4E_PEQ834],'')='' AND ISNULL(PF2.[PFQ4E_PEQ836],'')='' AND ISNULL(PF2.[PFQ4E_PEQ837],'')='' AND ISNULL(PF2.[PFQ4E_PEQ838],'')='' AND ISNULL(PF2.[PFQ4F_PEQ839],'')='' AND ISNULL(PF2.[PFQ4F_PEQ840],'')='' AND ISNULL(PF2.[PFQ4F_PEQ841],'')='' AND ISNULL(PF2.[PFQ4F_PEQ842],'')='' 
		THEN 1
		--WHEN PF2.[PEQ10_PEQ10] IS NOT NULL THEN 0
		ELSE 0
	 END AS [HAQ]
	,CASE 
		WHEN PF3.[PFQ6_PFQ8] IS NULL THEN 1
		--WHEN PF3.[PFQ6_PFQ8] IS NOT NULL THEN 0
		ELSE 0
	 END AS [PGV]
	--,PF3.[PFQ6_PFQ8] AS [PGVActual]
	,CASE 
		WHEN ISNULL(PF4.[PFQ10_PFQ12A],'')='' AND ISNULL(PF4.[PFQ10_PFQ12B],'')='' AND ISNULL(PF4.[PFQ10_PFQ12C],'')='' AND  ISNULL(PF4.[PFQ10_PFQ12D],'')='' AND ISNULL(PF4.[PFQ10_PFQ12D],'')='' THEN 1
		--WHEN PF4.[PEQ10_PEQ10] IS NOT NULL THEN 0
		ELSE 0
	 END AS [EQ5]--SELECT *
  FROM [OMNICOMM_RA100].[dbo].[VISIT] VIS
  LEFT JOIN --SELECT * FROM
  [OMNICOMM_RA100].[dbo].[PHFQ1] PF1 ON VIS.PatientId = PF1.[PatientId] AND VIS.[VisitId] = PF1.[VisitId]
  LEFT JOIN --SELECT * FROM
 [OMNICOMM_RA100].[dbo].[PFQ2] PF2 ON VIS.PatientId = PF2.[PatientId] AND VIS.[VisitId] = PF2.[VisitId]
  LEFT JOIN --SELECT * FROM
 [OMNICOMM_RA100].[dbo].[PFQ3] PF3 ON VIS.PatientId = PF3.[PatientId] AND VIS.[VisitId] = PF3.[VisitId]
  LEFT JOIN --SELECT * FROM
 [OMNICOMM_RA100].[dbo].[PFQ4] PF4 ON VIS.PatientId = PF4.[PatientId] AND VIS.[VisitId] = PF4.[VisitId]
  WHERE VIS.[Visit Object ProCaption] = 'Follow-up'
  AND ISNULL(VIS.[Visit Object VisitDate],'')<>''
  AND [VIS].[Site Object SiteNo] NOT IN ('999','998')
GO
