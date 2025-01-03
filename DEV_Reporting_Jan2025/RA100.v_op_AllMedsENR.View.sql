USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_AllMedsENR]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [RA100].[v_op_AllMedsENR] AS

Select
SIT.[Site Information_Site Number] AS [Site ID],
PAT.[Caption] AS [Subject ID],
PEQ1.[PEQ2_BRTHDAT] AS [Year of Birth],
PHEQ1.[PHE3_RASTYR] AS [MD - Year of Onset],
CAST(VIS.[Visit Object VisitDate] AS DATE) AS [Visit Date],
VIS.[Visit Object Procaption] AS [Visit Type],
--PHEQ4.[Form Object Caption] AS [CRF Name],
PHEQ9B.[PHE9B_CMCH5] AS [Changes Planned Today],
'Bio and Small Molecules' AS [Treatment Type],
PHEQ4.[PHE9A_CMNODRUG] AS [No Treatment?],
PHEQ9B.[PHE9B_CMTRT5] AS [Treatment],
PHEQ9B.[PHE9B_CMOTH1] AS [If Other, specify],
PHEQ9B.[PHE9B_CMFDAT5] AS [Date of First Use],
PHEQ9B.[PHE9B_CMRDAT5] AS [Past User(Non-Rituxan) - Date of Most Recent Use],
PHEQ9B.[PHE9B_CMDSTC5] AS [CURRENT USER Current Dose/Dose of most recent infusion],
PHEQ9B.[PHE9B_CMDOSPE] AS [CURRENT USER Current Dose(specify)],
PHEQ9B.[PHE9B_CMDOSF_5] AS [CURRENT USER Frequency],
PHEQ9B.[PHE9B_CMFRESPE] AS [CURRENT USER Frequency(specify)],
PHEQ9B.[PHE9B_CMDSTR5] AS [PAST BUT NOT CURRENT USER Most Recent Dose],
PHEQ9B.[PHE9B_CMDOSPAS] AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)],
PHEQ9B.[PHE9B_CMRNA5] AS [Reason Code 1],
PHEQ9B.[PHE9B_CMRNB5] AS [Reason Code 2],
PHEQ9B.[PHE9B_CMRNC5] AS [Reason Code 3]
FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[VISIT] VIS
INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[Patients] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ4] PHEQ4 ON PHEQ4.VisitId = VIS.VisitID
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ4_PHE9B] PHEQ9B ON PHEQ9B.VisitId = VIS.VisitID
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PEQ1] PEQ1 ON PEQ1.VisitId = VIS.VisitId
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
WHERE VIS.[Visit Object Procaption] IN ('Enrollment')
AND VIS.[Visit Object VisitDate] <> '' 

UNION

Select
SIT.[Site Information_Site Number] AS [Site ID],
PAT.[Caption] AS [Subject ID],
PEQ1.[PEQ2_BRTHDAT] AS [Year of Birth],
PHEQ1.[PHE3_RASTYR] AS [MD - Year of Onset],
CAST(VIS.[Visit Object VisitDate] AS DATE) AS [Visit Date],
VIS.[Visit Object Procaption] AS [Visit Type],
--PHEQ4.[Form Object Caption] AS [CRF Name],
PHEQ4.[PHE9C_CMCHRIT] AS [Changes Planned Today],
'Bio and Small Molecules' AS [Treatment Type],
PHEQ4.[PHE9A_CMNODRUG] AS [No Treatment?],
PHEQ4.[PHE9C_CMTRT6] AS [Treatment],
'' AS [If Other, specify],
PHEQ4.[PHE9C_CMFDAT6] AS [Date of First Use],
PHEQ4.[PHE9C_CMRDAT6] AS [Past User(Non-Rituxan) - Date of Most Recent Use],
CAST(PHEQ4.[PHE9C_CMDSTR6] AS nvarchar(5)) AS [CURRENT USER Current Dose/Dose of most recent infusion],
'' AS [CURRENT USER Current Dose(specify)],
'' AS [CURRENT USER Frequency],
'' AS [CURRENT USER Frequency(specify)],
'' AS [PAST BUT NOT CURRENT USER Most Recent Dose],
'' AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)],
PHEQ4.[PHE9C_CMRNARIT] AS [Reason Code 1],
PHEQ4.[PHE9C_CMRNBRIT] AS [Reason Code 2],
PHEQ4.[PHE9C_CMRNCRIT] AS [Reason Code 3]
FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[VISIT] VIS
INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[Patients] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ4] PHEQ4 ON PHEQ4.VisitId = VIS.VisitID
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ4_PHE9B] PHEQ9B ON PHEQ9B.VisitId = VIS.VisitID
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PEQ1] PEQ1 ON PEQ1.VisitId = VIS.VisitId
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
WHERE VIS.[Visit Object Procaption] IN ('Enrollment')
AND VIS.[Visit Object VisitDate] <> '' 
AND PHEQ4.[PHE9C_CMAPP6] != '0'

UNION

Select
SIT.[Site Information_Site Number] AS [Site ID],
PAT.[Caption] AS [Subject ID],
PEQ1.[PEQ2_BRTHDAT] AS [Year of Birth],
PHEQ1.[PHE3_RASTYR] AS [MD - Year of Onset],
CAST(VIS.[Visit Object VisitDate] AS DATE) AS [Visit Date],
VIS.[Visit Object Procaption] AS [Visit Type],
--PHEQ4.[Form Object Caption] AS [CRF Name],
PHEQ11B.[PHE11B_CMCH34] AS [Changes Planned Today],
'DMARDs and Corticosteroids' AS [Treatment Type],
PHEQ5.[PHE11A_PHEQ9NO] AS [No Treatment?],
PHEQ11B.[PHE11B_CMTRT_34] AS [Treatment],
PHEQ11B.[PHE11B_CMOTH1] AS [If Other, specify],
PHEQ11B.[PHE11B_CMFDAT34] AS [Date of First Use],
PHEQ11B.[PHE11B_CMRDAT34] AS [Past User(Non-Rituxan) - Date of Most Recent Use],
PHEQ11B.[PHE11B_CMDSTC34] AS [CURRENT USER Current Dose/Dose of most recent infusion],
PHEQ11B.[PHE11B_CMDOSPE] AS [CURRENT USER Current Dose(specify)],
PHEQ11B.[PHE11B_CMDOSF34] AS [CURRENT USER Frequency],
PHEQ11B.[PHE11B_CMFRESPE] AS [CURRENT USER Frequency(specify)],
PHEQ11B.[PHE11B_CMDSTR34] AS [PAST BUT NOT CURRENT USER Most Recent Dose],
PHEQ11B.[PHE11B_CMDOSPAS] AS [PAST BUT NOT CURRENT USER Most Recent Dose(specify)],
PHEQ11B.[PHE11B_CMRNA34] AS [Reason Code 1],
PHEQ11B.[PHE11B_CMRNB34] AS [Reason Code 2],
PHEQ11B.[PHE11B_CMRNC34] AS [Reason Code 3]
FROM [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[VISIT] VIS
INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[Patients] PAT ON PAT.PatientId = VIS.PatientId
INNER JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[SITE] SIT ON SIT.SiteId = PAT.SiteId
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ5] PHEQ5 ON PHEQ5.VisitId = VIS.VisitID
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ5_PHE11B] PHEQ11B ON PHEQ11B.VisitId = VIS.VisitID
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PEQ1] PEQ1 ON PEQ1.VisitId = VIS.VisitId
LEFT JOIN [172.16.81.24].[DataModel_TMCORE_PRODUCTION].[dbo].[PHEQ1] PHEQ1 ON PHEQ1.VisitId = VIS.VisitId
WHERE VIS.[Visit Object Procaption] IN ('Enrollment')
AND VIS.[Visit Object VisitDate] <> '' 
GO
