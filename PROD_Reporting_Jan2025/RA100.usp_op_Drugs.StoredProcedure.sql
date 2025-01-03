USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_Drugs]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- ===========================================================================
-- Author:		Kaye Mowrey
-- Updated date: 8/1/2022
-- Description:	Procedure for Drug Tables separate from CAT or EER
-- ===========================================================================


CREATE PROCEDURE [RA100].[usp_op_Drugs] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



/*


CREATE TABLE [RA100].[t_op_Enrollment_Drugs](
	[VisitId] [nvarchar](20) NULL,
	[PatientId] [nvarchar](20) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitType] [nvarchar](40) NULL,
	[VisitDate] [date] NULL,
	[PageDescription] [nvarchar](150) NULL,
	[Page4FormStatus] [nvarchar](40) NULL,
	[Page5FormStatus] [nvarchar](40) NULL,
	[NoTreatment] [int] NULL,
	[Treatment] [nvarchar] (350) NULL,
	[TreatmentName] [nvarchar](350) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[CalcStartDate] [date] NULL,
	[CurrentDose] [nvarchar](100) NULL,
	[CurrentFrequency] [nvarchar](250) NULL,
	[MostRecentDoseNotCurrentDose] [nvarchar](200) NULL,
	[MostRecentPastUseDate] [nvarchar](20) NULL
) ON [PRIMARY]
GO

CREATE TABLE [RA100].[t_op_FollowUp_Drugs](
	[VisitOrder] [int] NULL,
	[VisitId] [nvarchar](20) NULL,
	[PatientId] [nvarchar](20) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](30) NULL,
	[VisitDate] [date] NULL,
	[PageDescription] [nvarchar](100) NULL,
	[Page4FormStatus] [nvarchar](30) NULL,
	[Page5FormStatus] [nvarchar](30) NULL,
	[NoTreatment] [int] NULL,
	[RowID] [int] NULL,
	[Treatment] [nvarchar] (300) NULL,
	[TreatmentName] [nvarchar](300) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[CalcStartDate] [date] NULL,
	[CurrentDose] [nvarchar](100) NULL,
	[CurrentFrequency] [nvarchar](150) NULL,
	[MostRecentDoseNotCurrentDose] [nvarchar](100) NULL,
	[MostRecentPastUseDate] [nvarchar](20) NULL
) ON [PRIMARY]
GO

*/

IF OBJECT_ID('tempdb..#B') IS NOT NULL BEGIN DROP TABLE #B END;

/**************Enrollment visits in the database that have an Enrollment date**********************/

SELECT E.VisitID
      ,E.SiteID
	  ,E.SiteStatus
      ,E.SubjectID
	  ,E.VisitType
	  ,E.ProviderID AS ProviderID
	  ,E.[YOB] AS YearofBirth
	  ,DATEPART(YY, E.VisitDate) - E.[YOB] AS Age
	  ,E.VisitDate
	  ,E.OnsetYear
	  ,DATEPART(YY, E.VisitDate) - E.OnsetYear as YearsSinceOnset
	  ,(SELECT MIN(VisitDate) FROM [RA100].[t_op_SubjectVisits_wNoDates] E2 WHERE E2.VisitType='Follow-up' AND E2.SubjectID=E.SubjectID AND ISNULL(E2.VisitDate, '')<>'') AS FirstFUDate
	  ,CASE WHEN E.VisitDate <= '2013-02-25' THEN 99
	   WHEN E.VisitDate > '2013-02-25' AND E.VisitDate <= '2019-05-31' THEN 0
	   WHEN E.VisitDate >= '2019-06-01' THEN 1
	   WHEN ISNULL(E.VisitDate, '')='' THEN 99
	   ELSE NULL
	   END AS EligibilityVersion  

INTO #B
FROM [RA100].[t_op_SubjectVisits_wNoDates] E
WHERE E.VisitType='Enrollment'
--AND SubjectID=6080047

--SELECT * FROM #B WHERE SubjectID=19201147


IF OBJECT_ID('tempdb..#C') IS NOT NULL BEGIN DROP TABLE #C END;

/****************Page 4 - Rituxan use at Enrollment visit*************/

SELECT PHEQ4.VisitId
      ,PHEQ4.[PatientId]
	  ,CAST(PHEQ4.[Site Object SiteNo] AS int) AS SiteID
      ,CAST(PHEQ4.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,PHEQ4.[Visit Object ProCaption] AS VisitType
	  ,CAST(PHEQ4.[Visit Object VisitDate] AS date) AS VisitDate
	  ,PHEQ4.[Form Object Caption] AS PageDescription
	  ,PHEQ4.[Form Object Status] AS Page4FormStatus
	  ,Q5.[Form Object Status] AS Page5FormStatus
	  ,PHEQ4.[PHE9A_CMNODRUG] AS NoTreatment
	  ,CASE WHEN (PHEQ4.PHE9C_CMAPP6=1 OR ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' OR ISNULL(PHE9C_CMRDAT6, '')<>'') THEN PHEQ4.PHE9C_CMTRT6
	   ELSE ''
	   END AS Treatment
	  ,CASE WHEN (PHEQ4.PHE9C_CMAPP6=1 OR ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' OR ISNULL(PHE9C_CMRDAT6, '')<>'') THEN PHEQ4.PHE9C_CMTRT6
	   ELSE ''
	   END AS TreatmentName
	  ,PHEQ4.PHE9C_CMCHRIT AS ChangesToday

	  ,PHEQ4.PHE9C_CMFDAT6 AS FirstUseDate

	  ,CASE WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) <=28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 > PHEQ4.PHE9C_CMRDAT6)  AND LEN(PHEQ4.PHE9C_CMFDAT6)=7 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 6, 2) + '-' + RIGHT('00' + CAST(DATEPART(dd, PHEQ4.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10))
	  WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) > 28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 > PHEQ4.PHE9C_CMRDAT6)  AND LEN(PHEQ4.PHE9C_CMFDAT6)=7 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 6, 2) + '-01'  AS VARCHAR(10))
	  WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) <=28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 < PHEQ4.PHE9C_CMRDAT6) AND LEN(PHEQ4.PHE9C_CMRDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 6, 2) + '-' + RIGHT('00' + CAST(DATEPART(dd, PHEQ4.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10))
	   WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) > 28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 < PHEQ4.PHE9C_CMRDAT6) AND LEN(PHEQ4.PHE9C_CMRDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 6, 2) + '-01' AS VARCHAR(10))
	   WHEN ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND  (PHEQ4.PHE9C_CMFDAT6 > PHEQ4.PHE9C_CMRDAT6) AND LEN(PHEQ4.PHE9C_CMFDAT6)=4 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-06-01' AS VARCHAR(10))
	   WHEN ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND  (PHEQ4.PHE9C_CMFDAT6 < PHEQ4.PHE9C_CMRDAT6) AND LEN(PHEQ4.PHE9C_CMRDAT6)=4 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 1, 4) + '-06-01' AS VARCHAR(10))
		WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) <=28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 = PHEQ4.PHE9C_CMRDAT6)  AND LEN(PHEQ4.PHE9C_CMFDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 6, 2) + '-' + RIGHT('00' + CAST(DATEPART(dd, PHEQ4.[Visit Object VisitDate]) AS varchar(2)), 2)  AS VARCHAR(10))
		WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) >28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 = PHEQ4.PHE9C_CMRDAT6)  AND LEN(PHEQ4.PHE9C_CMFDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 6, 2) + '-01' AS VARCHAR(10))
		WHEN ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND (PHEQ4.PHE9C_CMFDAT6 = PHEQ4.PHE9C_CMRDAT6)  AND LEN(PHEQ4.PHE9C_CMFDAT6)=4 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-06-01' AS VARCHAR(10))
		WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) <=28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')='' AND LEN(PHEQ4.PHE9C_CMFDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 6, 2) + '-' + RIGHT('00' + CAST(DATEPART(dd, PHEQ4.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10))
		WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) >28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')='' AND LEN(PHEQ4.PHE9C_CMFDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 6, 2) + '-01' AS VARCHAR(10))
		WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) <=28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')='' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND LEN(PHEQ4.PHE9C_CMRDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 6, 2) + '-' + RIGHT('00' + CAST(DATEPART(dd, PHEQ4.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10)) 
		WHEN DATEPART(dd, PHEQ4.[Visit Object VisitDate]) >28 AND ISNULL(PHEQ4.PHE9C_CMFDAT6, '')='' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND LEN(PHEQ4.PHE9C_CMRDAT6)=7 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 1, 4) + '-' + SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 6, 2) + '-01' AS VARCHAR(10))
		WHEN ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')='' AND LEN(PHEQ4.PHE9C_CMFDAT6)=4 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMFDAT6, 1, 4) + '-06-01' AS VARCHAR(10))
		WHEN ISNULL(PHEQ4.PHE9C_CMFDAT6, '')='' AND ISNULL(PHEQ4.PHE9C_CMRDAT6, '')<>'' AND LEN(PHEQ4.PHE9C_CMRDAT6)=4 THEN CAST(SUBSTRING(PHEQ4.PHE9C_CMRDAT6, 1, 4) + '-06-01' AS VARCHAR(10))
	   ELSE NULL
       END AS CalcStartDate
	  ,'' AS CurrentDose
	  ,'' AS CurrentFrequency
	  ,CAST(PHEQ4.PHE9C_CMDSTR6 AS nvarchar) AS MostRecentDoseNotCurrentDose

	  ,PHEQ4.PHE9C_CMRDAT6 AS MostRecentPastUseDate

INTO #C
FROM [OMNICOMM_RA100].[dbo].[PHEQ4] PHEQ4
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ5] Q5 ON Q5.VisitId=PHEQ4.VisitId
WHERE (PHEQ4.PHE9C_CMAPP6=1 OR ISNULL(PHEQ4.PHE9C_CMFDAT6, '')<>'' OR ISNULL(PHE9C_CMRDAT6, '')<>'')
order by CalcStartDate desc

--SELECT * FROM #C WHERE SubjectID=1060474
--WHERE PHEQ4.[Site Object SiteNo] NOT IN (997, 998, 999)

IF OBJECT_ID('tempdb..#D') IS NOT NULL BEGIN DROP TABLE #D END;

/************Page 4 - Biologic use at Enrollment visit************/

SELECT PHEQ4_PHE9B.VisitId
      ,PHEQ4_PHE9B.[PatientId]
	  ,CAST(PHEQ4_PHE9B.[Site Object SiteNo] AS int) AS SiteID
      ,CAST(PHEQ4_PHE9B.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,PHEQ4_PHE9B.[Visit Object ProCaption] AS VisitType
	  ,CAST(PHEQ4_PHE9B.[Visit Object VisitDate] AS date) AS VisitDate
	  ,PHEQ4_PHE9B.[Form Object Caption] AS PageDescription
	  ,PHEQ4_PHE9B.[Form Object Status] AS Page4FormStatus 
	  ,Q5.[Form Object Status] AS Page5FormStatus
	  ,PHEQ4.[PHE9A_CMNODRUG] AS NoTreatment

	  ,CASE WHEN (UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) LIKE '%UPADA%' OR UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) LIKE '%RINV%') THEN 'upadacitinib (Rinvoq)'
	   WHEN (UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) LIKE '%SIM%ARIA%') THEN 'golimumab (Simponi Aria)'
	   ELSE PHEQ4_PHE9B.PHE9B_CMTRT5
	   END AS Treatment

	  ,CASE WHEN (UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) LIKE '%UPADA%' OR UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) LIKE '%RINV%') THEN 'upadacitinib (Rinvoq)'
	   WHEN (UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) LIKE '%SIM%ARIA%') THEN 'golimumab (Simponi Aria)'
	   WHEN ISNULL(PHEQ4_PHE9B.PHE9B_CMOTH1, '')<>'' AND (UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) NOT LIKE '%UPADA%' OR UPPER(PHEQ4_PHE9B.PHE9B_CMOTH1) NOT LIKE '%RINV%') THEN PHEQ4_PHE9B.PHE9B_CMTRT5 + (': ' + PHEQ4_PHE9B.PHE9B_CMOTH1)
	   ELSE PHEQ4_PHE9B.PHE9B_CMTRT5 
	   END AS TreatmentName

	  ,PHEQ4_PHE9B.[PHE9B_CMCH5] AS  ChangesToday
	  ,PHEQ4_PHE9B.[PHE9B_CMFDAT5] AS FirstUseDate

	  ,CASE WHEN DATEPART(dd, PHEQ4_PHE9B.[Visit Object VisitDate]) <=28 AND ISNULL(PHEQ4_PHE9B.[PHE9B_CMFDAT5], '')<>'' AND LEN(PHEQ4_PHE9B.[PHE9B_CMFDAT5])=7 AND ISNULL(PHEQ4_PHE9B.[PHE9B_CMFDAT5], '')<>'' THEN CAST(SUBSTRING(PHEQ4_PHE9B.[PHE9B_CMFDAT5], 1, 4) + '-' + SUBSTRING(PHEQ4_PHE9B.[PHE9B_CMFDAT5], 6, 2)  + '-' + RIGHT('00' + CAST(DATEPART(dd, PHEQ4_PHE9B.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10))
	  WHEN DATEPART(dd, PHEQ4_PHE9B.[Visit Object VisitDate]) >28 AND ISNULL(PHEQ4_PHE9B.[PHE9B_CMFDAT5], '')<>'' AND LEN(PHEQ4_PHE9B.[PHE9B_CMFDAT5])=7 AND ISNULL(PHEQ4_PHE9B.[PHE9B_CMFDAT5], '')<>'' THEN CAST(SUBSTRING(PHEQ4_PHE9B.[PHE9B_CMFDAT5], 1, 4) + '-' + SUBSTRING(PHEQ4_PHE9B.[PHE9B_CMFDAT5], 6, 2)  + '-01' AS VARCHAR(10))

	  WHEN ISNULL(PHEQ4_PHE9B.[PHE9B_CMFDAT5], '')<>'' AND LEN(PHEQ4_PHE9B.[PHE9B_CMFDAT5])=4 AND ISNULL(PHEQ4_PHE9B.[PHE9B_CMFDAT5], '')<>'' THEN CAST(SUBSTRING(PHEQ4_PHE9B.[PHE9B_CMFDAT5], 1, 4) + '-06-01' AS VARCHAR(10))
	   ELSE NULL
       END AS CalcStartDate

	  ,ISNULL(CAST(PHEQ4_PHE9B.[PHE9B_CMDOSPE] AS nvarchar), '') + REPLACE(PHEQ4_PHE9B.[PHE9B_CMDSTC5],'__', ' ') AS CurrentDose
	  ,COALESCE(REPLACE(PHEQ4_PHE9B.[PHE9B_CMDOSF_5], '_', (' ' + CAST(PHEQ4_PHE9B.[PHE9B_CMFRESPE] AS nvarchar) + ' ')), PHEQ4_PHE9B.[PHE9B_CMDOSF_5]) AS CurrentFrequency
	  ,ISNULL(CAST(PHEQ4_PHE9B.[PHE9B_CMDOSPAS] AS nvarchar), '') + REPLACE(PHEQ4_PHE9B.[PHE9B_CMDSTR5],'__', ' ') AS MostRecentDoseNotCurrentDose
	  ,PHEQ4_PHE9B.[PHE9B_CMRDAT5] AS MostRecentPastUseDate

INTO #D
FROM [OMNICOMM_RA100].[dbo].[PHEQ4_PHE9B] PHEQ4_PHE9B
JOIN [OMNICOMM_RA100].[dbo].[PHEQ4] PHEQ4 ON PHEQ4.VisitId=PHEQ4_PHE9B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ5] Q5 ON Q5.VisitId=PHEQ4_PHE9B.VisitId

--WHERE PHEQ4_PHE9B.[Site Object SiteNo] NOT IN (997, 998, 999)



--SELECT * FROM #D WHERE Treatment LIKE '%(other%'

IF OBJECT_ID('tempdb..#E') IS NOT NULL BEGIN DROP TABLE #E END;

/**********Page 5 - DMARD use at Enrollment visit************/

SELECT Q5.VisitId
      ,Q5.[PatientId]
	  ,CAST(Q5.[Site Object SiteNo] AS int) AS SiteID
      ,Q5.[Patient Object PatientNo] AS SubjectID
	  ,Q5.[Visit Object ProCaption] AS VisitType
	  ,Q5.[Visit Object VisitDate] AS VisitDate
	  ,Q5.[Form Object Caption] AS PageDescription
	  ,Q4.[Form Object Status] AS Page4FormStatus
	  ,Q5.[Form Object Status] AS Page5FormStatus
	  ,Q5.[PHE11A_PHEQ9NO] AS NoTreatment

	  ,Q5_11B.[PHE11B_CMTRT_34] AS Treatment

	  ,CASE WHEN ISNULL(Q5_11B.PHE11B_CMOTH1, '')<>'' THEN Q5_11B.[PHE11B_CMTRT_34] + ': ' + PHE11B_CMOTH1
	   ELSE Q5_11B.[PHE11B_CMTRT_34] 
	   END AS TreatmentName

	  ,Q5_11B.[PHE11B_CMCH34] AS ChangesToday
	  ,Q5_11B.[PHE11B_CMFDAT34] AS FirstUseDate

	  ,CASE WHEN DATEPART(dd, Q5.[Visit Object VisitDate]) <=28 AND ISNULL((Q5_11B.[PHE11B_CMFDAT34]), '')<>'' AND LEN(Q5_11B.[PHE11B_CMFDAT34])=7 AND ISNULL(Q5_11B.[PHE11B_CMFDAT34], '')<>'' THEN CAST(SUBSTRING(Q5_11B.[PHE11B_CMFDAT34], 1, 4) + '-' + SUBSTRING(Q5_11B.[PHE11B_CMFDAT34], 6, 2)  + '-' + RIGHT('00' + CAST(DATEPART(dd, Q5.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10))
	  WHEN DATEPART(dd, Q5.[Visit Object VisitDate]) >28 AND ISNULL((Q5_11B.[PHE11B_CMFDAT34]), '')<>'' AND LEN(Q5_11B.[PHE11B_CMFDAT34])=7 AND ISNULL(Q5_11B.[PHE11B_CMFDAT34], '')<>'' THEN CAST(SUBSTRING(Q5_11B.[PHE11B_CMFDAT34], 1, 4) + '-' + SUBSTRING(Q5_11B.[PHE11B_CMFDAT34], 6, 2)  + '-01' AS VARCHAR(10))
	  WHEN ISNULL((Q5_11B.[PHE11B_CMFDAT34]), '')<>'' AND LEN(Q5_11B.[PHE11B_CMFDAT34])=4 AND ISNULL(Q5_11B.[PHE11B_CMFDAT34], '')<>'' THEN CAST(SUBSTRING(Q5_11B.[PHE11B_CMFDAT34], 1, 4) + '-06-01' AS VARCHAR(10))
	   ELSE NULL
       END AS CalcStartDate

	  ,ISNULL(CAST(Q5_11B.[PHE11B_CMDOSPE] AS nvarchar), '') + REPLACE(Q5_11B.[PHE11B_CMDSTC34],'__', ' ') AS CurrentDose
	  ,Q5_11B.[PHE11B_CMDOSF34] AS CurrentFrequency
	  ,ISNULL(CAST(Q5_11B.[PHE11B_CMDOSPAS] AS nvarchar), '') + REPLACE(Q5_11B.[PHE11B_CMDSTR34],'__', ' ') AS MostRecentDoseNotCurrentDose
	  ,Q5_11B.[PHE11B_CMRDAT34] AS MostRecentPastUseDate

INTO #E	  
FROM [OMNICOMM_RA100].[dbo].[PHEQ5] Q5
JOIN [OMNICOMM_RA100].[dbo].[PHEQ5_PHE11B] Q5_11B ON Q5.VisitId=Q5_11B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHEQ4_PHE9B] Q4 ON Q4.VisitId=Q5.VisitId
order by CalcStartDate desc
--WHERE Q5.[Site Object SiteNo] NOT IN (997, 998, 999)

--SELECT * FROM #E WHERE SubjectID=100706806



IF OBJECT_ID('tempdb..#F') IS NOT NULL BEGIN DROP TABLE #F END;

/************Page 4 - Drug use combined at Enrollment visit************/
	

CREATE TABLE #F
(
VisitId nvarchar(20),
[PatientId] nvarchar(20),
SiteID int,
SubjectID bigint,
VisitType nvarchar(30),
VisitDate date,
PageDescription nvarchar(100),
Page4FormStatus nvarchar(30),
Page5FormStatus nvarchar(30),
NoTreatment int,
Treatment nvarchar(300),
TreatmentName nvarchar(300),
ChangesToday nvarchar(50),
FirstUseDate nvarchar(20),
CalcStartDate date,
CurrentDose nvarchar(100),
CurrentFrequency nvarchar(150),
MostRecentDoseNotCurrentDose nvarchar(100),
MostRecentPastUseDate nvarchar(20),

)


INSERT INTO #F

SELECT VisitId,
[PatientId] ,
SiteID ,
SubjectID ,
VisitType ,
VisitDate ,
PageDescription ,
Page4FormStatus ,
Page5FormStatus ,
NoTreatment ,
Treatment,
TreatmentName ,
ChangesToday ,
FirstUseDate ,
CASE WHEN ISNULL(CalcStartDate, '')='' THEN CAST(NULL AS date)
WHEN ISNULL(CalcStartDate, '')<>'' THEN CAST(CalcStartDate AS date)
END AS CalcStartDate,
CurrentDose ,
CurrentFrequency ,
MostRecentDoseNotCurrentDose ,
MostRecentPastUseDate 
FROM #C

UNION 

SELECT VisitId,
[PatientId] ,
SiteID ,
SubjectID ,
VisitType ,
VisitDate ,
PageDescription ,
Page4FormStatus ,
Page5FormStatus ,
NoTreatment ,
Treatment,
TreatmentName ,
ChangesToday ,
FirstUseDate ,
CASE WHEN ISNULL(CalcStartDate, '')='' THEN CAST(NULL AS date)
WHEN ISNULL(CalcStartDate, '')<>'' THEN CAST(CalcStartDate AS date)
END AS CalcStartDate,
CurrentDose ,
CurrentFrequency ,
MostRecentDoseNotCurrentDose ,
MostRecentPastUseDate 
FROM #D


UNION

SELECT VisitId,
[PatientId] ,
SiteID ,
SubjectID ,
VisitType ,
VisitDate ,
PageDescription ,
Page4FormStatus ,
Page5FormStatus ,
NoTreatment ,
Treatment,
TreatmentName ,
ChangesToday ,
FirstUseDate ,
CASE WHEN ISNULL(CalcStartDate, '')='' THEN CAST(NULL AS date)
WHEN ISNULL(CalcStartDate, '')<>'' THEN CAST(CalcStartDate AS date)
END AS CalcStartDate,
CurrentDose ,
CurrentFrequency ,
MostRecentDoseNotCurrentDose ,
MostRecentPastUseDate 
FROM #E


--SELECT * FROM #F WHERE Treatment LIKE '%(other)%'

TRUNCATE TABLE [Reporting].[RA100].[t_op_Enrollment_Drugs];

--SELECT * FROM [Reporting].[RA100].[t_op_Enrollment_Drugs] WHERE Treatment LIKE '%(other)%'


INSERT INTO [Reporting].[RA100].[t_op_Enrollment_Drugs]
SELECT VisitId
      ,[PatientId]
	  ,SiteID
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,PageDescription
	  ,Page4FormStatus
	  ,Page5FormStatus
	  ,NoTreatment
	  ,CASE WHEN TreatmentName='Other: Xeljanz ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ XR' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN TreatmentName='Other: Xeljanz xr' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ (%' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE '%RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ)' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RENV' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RIVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %UPADACIT%' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %OLUMIAN%' THEN 'baricitinib (Olumiant)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %SIMPONI%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %SIM%ARIA%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %HUMIRA%' THEN 'adalimumab (Humira)'
	   WHEN UPPER(TreatmentName) LIKE '%INFLECTRA%' THEN 'Inflectra (infliximab-dyyb)'
	   ELSE Treatment
	   END AS Treatment
	  
	  ,CASE WHEN TreatmentName='Other: Xeljanz ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ XR' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN TreatmentName='Other: Xeljanz xr' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ (%' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE '%RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ)' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RENV' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RIVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %UPADACIT%' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %OLUMIAN%' THEN 'baricitinib (Olumiant)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %SIMPONI%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %SIM%ARIA%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %HUMIRA%' THEN 'adalimumab (Humira)'
	   WHEN UPPER(TreatmentName) LIKE '%INFLECTRA%' THEN 'Inflectra (infliximab-dyyb)'
	   ELSE TreatmentName
	   END AS TreatmentName

	  ,ChangesToday
	  ,FirstUseDate
	  ,CONVERT(date, CalcStartDate, 23) AS CalcStartDate
	  ,CurrentDose
	  ,CurrentFrequency
	  ,MostRecentDoseNotCurrentDose
	  ,MostRecentPastUseDate 
FROM #F

--SELECT * FROM #F WHERE SubjectID=100706806


IF OBJECT_ID('tempdb.dbo.#CC') IS NOT NULL BEGIN DROP TABLE #CC END;

/****************Page 4 - Rituxan use at Follow-up visits*************/

SELECT Q4.VisitId
      ,Q4.[PatientId]
	  ,CAST(Q4.[Site Object SiteNo] AS int) AS SiteID
      ,CAST(Q4.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,CAST(Q1.[PHF1_CPHIDF] AS int) AS ProviderID
	  ,Q4.[Visit Object ProCaption] AS VisitType
	  ,CAST(Q4.[Visit Object VisitDate] AS date) AS VisitDate
	  ,Q4.[Form Object Caption] AS PageDescription
	  ,Q4.[Form Object Status] AS Page4FormStatus
	  ,Q5.[Form Object Status] AS Page5FormStatus
	  ,Q4.[PHF8A_CMNODRUG] AS NoTreatment
	  ,Q4.[ItemInstanceNo] AS RowID
	  ,CASE WHEN (Q4.[PHF8C_CMAPP6]=1 OR ISNULL(Q4.[PHF8C_CMMDAT6], '')<>'') 
	   THEN Q4.[PHF8C_CMTRT6]
	   ELSE ''
	   END AS Treatment
	  ,CASE WHEN (Q4.[PHF8C_CMAPP6]=1 OR ISNULL(Q4.[PHF8C_CMMDAT6], '')<>'') 
	   THEN Q4.[PHF8C_CMTRT6]
	   ELSE ''
	   END AS TreatmentName
	  ,Q4.[PHF8C_CMCHRIT] AS ChangesToday
	  ,'' AS FirstUseDate
	  ,CAST(NULL AS date) AS CalcStartDate
	  ,'' AS CurrentDose
	  ,'' AS CurrentFrequency

	  ,CAST(Q4.[PHF8C_CMDSTR6] AS nvarchar) AS MostRecentDoseNotCurrentDose
	  ,Q4.[PHF8C_CMMDAT6] AS MostRecentPastUseDate
INTO #CC
FROM [OMNICOMM_RA100].[dbo].[PHFQ4] Q4
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=Q4.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ5] Q5 ON Q5.VisitId=Q4.VisitId
--WHERE Q4.[Site Object SiteNo] NOT IN (997, 998, 999)
WHERE (Q4.[PHF8C_CMAPP6]=1 OR ISNULL(Q4.[PHF8C_CMMDAT6], '')<>'' OR ISNULL([PHF8C_CMMDAT7], '')<>'')

-- SELECT * FROM #CC ORDER BY SiteID, SubjectID, VisitDate 


IF OBJECT_ID('tempdb.dbo.#DD') IS NOT NULL BEGIN DROP TABLE #DD END;

/************Page 4 - Biologic use at Follow-up visits************/

SELECT PHF8B.VisitId
      ,PHF8B.[PatientId]
	  ,CAST(PHF8B.[Site Object SiteNo] AS int) AS SiteID
      ,CAST(PHF8B.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,CAST(Q1.[PHF1_CPHIDF] AS int) AS ProviderID
	  ,PHF8B.[Visit Object ProCaption] AS VisitType
	  ,CAST(PHF8B.[Visit Object VisitDate] AS date) AS VisitDate
	  ,PHF8B.[Form Object Caption] AS PageDescription
	  ,PHF8B.[Form Object Status] AS Page4FormStatus 
	  ,Q5.[Form Object Status] AS Page5FormStatus
	  ,Q4.[PHF8A_CMNODRUG] AS NoTreatment
	  ,PHF8B.[ItemInstanceNo] AS RowID
	  ,CASE WHEN (UPPER([PHF8B_CMOTH1]) LIKE '%UPADA%' OR UPPER([PHF8B_CMOTH1]) LIKE '%RINV%') THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER([PHF8B_CMOTH1]) LIKE '%SIM%ARIA%' THEN 'golimumab (Simponi Aria)'
	   ELSE PHF8B.[PHF8B_CMTRT5] 
	   END AS Treatment
	  ,CASE WHEN (UPPER([PHF8B_CMOTH1]) LIKE '%UPADA%' OR UPPER([PHF8B_CMOTH1]) LIKE '%RINV%') THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER([PHF8B_CMOTH1]) LIKE '%SIM%ARIA%' THEN 'golimumab (Simponi Aria)'
	   WHEN ISNULL(PHF8B.[PHF8B_CMOTH1], '')<>'' AND (UPPER([PHF8B_CMOTH1]) NOT LIKE '%UPADA%' OR UPPER([PHF8B_CMOTH1]) NOT LIKE '%RINV%') THEN PHF8B.[PHF8B_CMTRT5] + (': ' + PHF8B.[PHF8B_CMOTH1])
	   ELSE PHF8B.[PHF8B_CMTRT5] 
	   END AS TreatmentName
	  ,PHF8B.[PHF8B_CMCH5] AS  ChangesToday
	  ,PHF8B.PHF8B_CMSTDT5 AS FirstUseDate

	  ,CASE WHEN DATEPART(dd, PHF8B.[Visit Object VisitDate])> 28 AND RTRIM(ISNULL(PHF8B.PHF8B_CMSTDT5, ''))<>'' AND LEN(PHF8B.PHF8B_CMSTDT5)=7 THEN CAST(SUBSTRING(PHF8B.PHF8B_CMSTDT5, 1, 4) + '-' + SUBSTRING(PHF8B.PHF8B_CMSTDT5, 6, 2) + '-01'  AS VARCHAR(10))
	  WHEN DATEPART(dd, PHF8B.[Visit Object VisitDate])<=28 AND RTRIM(ISNULL(PHF8B.PHF8B_CMSTDT5, ''))<>'' AND LEN(PHF8B.PHF8B_CMSTDT5)=7 THEN CAST(SUBSTRING(PHF8B.PHF8B_CMSTDT5, 1, 4) + '-' + SUBSTRING(PHF8B.PHF8B_CMSTDT5, 6, 2) + + '-' + RIGHT('00' + CAST(DATEPART(dd, PHF8B.[Visit Object VisitDate]) AS varchar(2)), 2) AS VARCHAR(10))
      WHEN RTRIM(ISNULL(PHF8B.PHF8B_CMSTDT5, ''))<>'' AND LEN(PHF8B.PHF8B_CMRDAT5)=4 THEN CAST(SUBSTRING(PHF8B.PHF8B_CMSTDT5, 1, 4) + '-06-01' AS VARCHAR(10))
	   ELSE NULL
       END AS CalcStartDate

	  ,ISNULL(CAST(PHF8B.[PHF8B_CMDOSPE] AS nvarchar), '') + REPLACE(PHF8B.[PHF8B_CMDSTC5],'__', ' ') AS CurrentDose
	  ,COALESCE(REPLACE(PHF8B.[PHF8B_CMDOSF_5], '_', (' ' + CAST(PHF8B.[PHF8B_CMFRESPE] AS nvarchar) + ' ')), PHF8B.[PHF8B_CMDOSF_5]) AS CurrentFrequency
	  ,ISNULL(CAST(PHF8B.[PHF8B_CMDOSPAS] AS nvarchar), '') + REPLACE(PHF8B.[PHF8B_CMDSTR5],'__', ' ') AS MostRecentDoseNotCurrentDose
	  ,PHF8B.[PHF8B_CMRDAT5] AS MostRecentPastUseDate

INTO #DD
FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] PHF8B
JOIN [OMNICOMM_RA100].[dbo].[PHFQ4] Q4 ON Q4.VisitId=PHF8B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ5] Q5 ON Q5.VisitId=PHF8B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=PHF8B.VisitId
--WHERE PHF8B.[Site Object SiteNo] NOT IN (997, 998, 999)

--SELECT * FROM #DD ORDER BY SiteID, SubjectID, VisitDate


/*
IF OBJECT_ID('tempdb..#EE') IS NOT NULL BEGIN DROP TABLE #EE END;

/**********Page 5 - DMARD use at Follow-up visits************/

SELECT Q5.VisitId
      ,Q5.[PatientId]
	  ,CAST(Q5.[Site Object SiteNo] AS int) AS SiteID
      ,Q5.[Patient Object PatientNo] AS SubjectID
	  ,CAST(Q1.[PHF1_CPHIDF] AS int) AS ProviderID
	  ,Q5.[Visit Object ProCaption] AS VisitType
	  ,Q5.[Visit Object VisitDate] AS VisitDate
	  ,Q5.[Form Object Caption] AS PageDescription
	  ,Q4.[Form Object Status] AS Page4FormStatus
	  ,Q5.[Form Object Status] AS Page5FormStatus
	  ,Q5.[PHF10A_PHF11NO] AS NoTreatment
	  ,CASE WHEN ISNULL(Q5_10B.[PHF10B_CMOTH1], '')<>'' THEN Q5_10B.[PHF10B_CMTRT_34] + ': ' + [PHF10B_CMOTH1]
	   ELSE Q5_10B.[PHF10B_CMTRT_34] 
	   END AS TreatmentName
	  ,Q5_10B.[PHF10B_CMCH34] AS ChangeToday
	  ,Q5_10B.[PHF10B_CMSTDT34] AS FirstUseDate
	  ,CASE WHEN ISNULL((Q5_10B.[PHF10B_CMSTDT34]), '')<>'' AND LEN(Q5_10B.[PHF10B_CMSTDT34])=7 AND ISNULL(Q5_10B.[PHF10B_CMSTDT34], '')<>'' THEN CAST(SUBSTRING(Q5_10B.[PHF10B_CMSTDT34], 1, 4) + '-' + SUBSTRING(Q5_10B.[PHF10B_CMSTDT34], 6, 2) + '-01'  AS VARCHAR(10))
	        WHEN ISNULL((Q5_10B.[PHF10B_CMSTDT34]), '')<>'' AND LEN(Q5_10B.[PHF10B_CMSTDT34])=4 AND ISNULL(Q5_10B.[PHF10B_CMSTDT34], '')<>'' THEN CAST(SUBSTRING(Q5_10B.[PHF10B_CMSTDT34], 1, 4) + '-06-01' AS VARCHAR(10))
	   ELSE NULL
       END AS CalcStartDate
	  ,ISNULL(CAST(Q5_10B.[PHF10B_CMDOSPE] AS nvarchar), '') + REPLACE(Q5_10B.[PHF10B_CMDSTC34],'__', ' ') AS CurrentDose
	  ,Q5_10B.[PHF10B_CMDOSF34] AS CurrentFrequency
	  ,ISNULL(CAST(Q5_10B.[PHF10B_CMDOSPAS] AS nvarchar), '') + REPLACE(Q5_10B.[PHF10B_CMDSTR34],'__', ' ') AS MostRecentDoseNotCurrentDose
	  ,Q5_10B.[PHF10B_CMRDAT34] AS MostRecentUseDate
INTO #EE  
FROM [OMNICOMM_RA100].[dbo].[PHFQ5] Q5
JOIN [OMNICOMM_RA100].[dbo].[PHFQ5_PHF10B] Q5_10B ON Q5.VisitId=Q5_10B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] Q4 ON Q4.VisitId=Q5.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=Q5.VisitId
WHERE Q5.[Site Object SiteNo] NOT IN (997, 998, 999)
AND (ISNULL(Q5_10B.[PHF10B_CMTRT_34], '')<>''  OR ISNULL(Q5.[PHF10A_PHF11NO], '')<>'')

--SELECT * FROM #EE ORDER BY SiteID, SubjectID, VisitDate
*/


IF OBJECT_ID('tempdb.dbo.#FF') IS NOT NULL BEGIN DROP TABLE #FF END;

/************Page 4 - Biologic use combined at Follow-up visits************/
	
CREATE TABLE #FF
(
VisitId bigint,
[PatientId] nvarchar(20),
SiteID int,
SubjectID bigint,
ProviderID int,
VisitType nvarchar(30),
VisitDate date,
PageDescription nvarchar(100),
Page4FormStatus nvarchar(30),
Page5FormStatus nvarchar(30),
NoTreatment int,
RowID int,
Treatment nvarchar(300),
TreatmentName nvarchar(300),
ChangesToday nvarchar(50),
FirstUseDate nvarchar(10),
CalcStartDate date,
CurrentDose nvarchar(100),
CurrentFrequency nvarchar(150),
MostRecentDoseNotCurrentDose nvarchar(100),
MostRecentPastUseDate nvarchar(20),

)


INSERT INTO #FF
SELECT * FROM #CC
WHERE Page4FormStatus <> 'No Data'

UNION  

SELECT VisitId
      ,[PatientId]
	  ,SiteID
	  ,SubjectID
	  ,ProviderID
	  ,VisitType
	  ,VisitDate
	  ,PageDescription
	  ,Page4FormStatus
	  ,Page5FormStatus
	  ,NoTreatment
	  ,RowID  
	  ,CASE WHEN TreatmentName='Other: Xeljanz ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ XR' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN TreatmentName='Other: Xeljanz xr' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ (%' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE '%RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ)' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RIVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %UPADACIT%' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %SIMP%ARIA%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %ARIA%SIMP%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE '%INFLECTRA%' THEN 'Inflectra (infliximab-dyyb)'
	   WHEN Page4FormStatus='No Data' THEN 'No data'
	   ELSE Treatment
	   END AS Treatment
	  ,CASE WHEN TreatmentName='Other: Xeljanz ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ ER' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ XR' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN TreatmentName='Other: Xeljanz xr' THEN 'tofacitinib (Xeljanz XR)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ (%' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE '%OTHER: XELJANZ' THEN 'tofacitinib (Xeljanz)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE '%RENVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RINVOQ)' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %RIVOQ' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %UPADACIT%' THEN 'upadacitinib (Rinvoq)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %SIMP%ARIA%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE 'OTHER: %ARIA%SIMP%' THEN 'golimumab (Simponi Aria)'
	   WHEN UPPER(TreatmentName) LIKE '%INFLECTRA%' THEN 'Inflectra (infliximab-dyyb)'
	   WHEN Page4FormStatus='No Data' THEN 'No data'
	   ELSE Treatment
	   END AS TreatmentName
	  ,ChangesToday
	  ,FirstUseDate
	  ,CASE WHEN ISNULL(CalcStartDate, '')='' THEN CAST(NULL AS date)
	   WHEN ISNULL(CalcStartDate, '')<>'' THEN CAST(CalcStartDate AS date)
	   END AS CalcStartDate
	  ,CurrentDose
	  ,CurrentFrequency
	  ,MostRecentDoseNotCurrentDose
	  ,MostRecentPastUseDate
	    
FROM #DD
WHERE Page4FormStatus <> 'No Data'
--WHERE (ISNULL(NoTreatment, '')<>'' OR ISNULL(TreatmentName, '')<>'')

--SELECT * FROM #DD


IF OBJECT_ID('tempdb.dbo.#VisitOrder') IS NOT NULL BEGIN DROP TABLE #VisitOrder END;

/**Page 4 - Biologics use at Follow-up visits with Visit Order Sequence #**/

SELECT DISTINCT VisitId
      ,ROW_NUMBER() OVER(PARTITION BY [Site Object SiteNo], [Patient Object PatientNo] ORDER BY [Site Object SiteNo], [Patient Object PatientNo], [Visit Object VisitDate]) AS VisitOrder
      ,CAST([Site Object SiteNo] AS int) AS SiteID
      ,CAST([Patient Object PatientNo] AS bigint) AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate

INTO #VisitOrder
FROM [OMNICOMM_RA100].[dbo].[VISIT] VISIT
--[Site Object SiteNo] NOT IN ('997', '998', '999')
WHERE [Visit Object ProCaption]='Follow-up'
AND [Visit Object VisitDate] NOT IN (SELECT VisitDate FROM [Reporting].[RA100].[t_op_DOI_Enrollment] Enrollment WHERE Enrollment.SubjectID=VISIT.[Patient Object PatientNo])
AND VisitId IN (SELECT VisitId FROM #FF)


--SELECT * FROM #VisitOrder WHERE SubjectID=100206321 ORDER BY VisitOrder


IF OBJECT_ID('tempdb.dbo.#ExitVisits') IS NOT NULL BEGIN DROP TABLE #ExitVisits END;

/************Exit Visit Information************/

SELECT DISTINCT VisitId
      ,ROW_NUMBER() OVER(PARTITION BY [Site Object SiteNo], [Patient Object PatientNo] ORDER BY [Site Object SiteNo], [Patient Object PatientNo], [Visit Object VisitDate]) AS VisitOrder
      ,CAST([Site Object SiteNo] AS int) AS SiteID
      ,CAST([Patient Object PatientNo] AS bigint) AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate

INTO #ExitVisits
FROM [OMNICOMM_RA100].[dbo].[VISIT] V
--WHERE [Site Object SiteNo] NOT IN ('997', '998', '999')
WHERE [Visit Object ProCaption]='Exit'
AND ISNULL([Visit Object VisitDate], '')<>''
AND V.[Visit Object VisitDate] > (SELECT MAX([Visit Object VisitDate]) FROM [OMNICOMM_RA100].[dbo].[VISIT] V2 WHERE V2.[Site Object SiteNo]=V.[Site Object SiteNo] AND V2.[Patient Object PatientNo]= V.[Patient Object PatientNo] AND V2.[Visit Object ProCaption]='Follow-up')

--SELECT * FROM #ExitVisits EV WHERE SubjectID=100206321 ORDER BY SubjectID, VisitDate

IF OBJECT_ID('tempdb.dbo.#FF2') IS NOT NULL BEGIN DROP TABLE #FF2 END;

/************Page 4 - Biologics use at Follow-up visits with Visit Order Sequence #************/

SELECT VO.VisitOrder,
    F.VisitId,
	F.[PatientId],
	F.SiteID,
	F.SubjectID,
	F.ProviderID,
	F.VisitType,
	F.VisitDate,
	F.PageDescription,
	F.Page4FormStatus,
	F.NoTreatment,
	F.RowID,
	F.Treatment,
	F.TreatmentName,
	F.ChangesToday,
	F.FirstUseDate,
	CASE WHEN ISNULL(RTRIM(F.CalcStartDate), '')='' THEN NULL
	ELSE CAST(F.CalcStartDate AS date)
	END AS CalcStartDate,
	F.CurrentDose,
	F.CurrentFrequency,
	F.MostRecentDoseNotCurrentDose,
	F.MostRecentPastUseDate
	   
INTO #FF2
FROM #FF F
LEFT JOIN #VisitOrder VO ON VO.VisitId=F.VisitId
WHERE F.VisitDate NOT IN (SELECT VisitDate FROM [Reporting].[RA100].[t_op_DOI_Enrollment] Enrollment WHERE Enrollment.SubjectID=F.SubjectID)
AND F.VisitId IN (SELECT VisitId FROM #DD) 


--SELECT * FROM #FF2 F2 WHERE SubjectID=100206321 ORDER BY SiteID, SubjectID, VisitDate, VisitOrder


/*

CREATE TABLE [Reporting].[RA100].[t_op_FollowUp_Drugs]
(
VisitOrder int,
VisitId bigint,
[PatientId] nvarchar(20),
SiteID int,
SubjectID bigint,
ProviderID int,
VisitType nvarchar(30),
VisitDate date,
PageDescription nvarchar(100),
Page4FormStatus nvarchar(30),
Page5FormStatus nvarchar(30),
NoTreatment int,
RowID int,
Treatment nvarchar(300),
TreatmentName nvarchar(300),
ChangesToday nvarchar(50),
FirstUseDate nvarchar(20),
CalcStartDate date,
CurrentDose nvarchar(100),
CurrentFrequency nvarchar(150),
MostRecentDoseNotCurrentDose nvarchar(100),
MostRecentPastUseDate nvarchar(20),

) ON [PRIMARY]
GO
*/


TRUNCATE TABLE [Reporting].[RA100].[t_op_FollowUp_Drugs];

--SELECT * FROM [Reporting].[RA100].[t_op_FollowUp_Drugs]  --Biologics only

INSERT INTO [Reporting].[RA100].[t_op_FollowUp_Drugs]
(
VisitOrder,
VisitId,
[PatientId],
SiteID,
SubjectID,
ProviderID,
VisitType,
VisitDate,
PageDescription,
Page4FormStatus,
NoTreatment,
RowID,
Treatment,
TreatmentName,
ChangesToday,
FirstUseDate,
CalcStartDate,
CurrentDose,
CurrentFrequency,
MostRecentDoseNotCurrentDose,
MostRecentPastUseDate
)	   

SELECT DISTINCT F2.VisitOrder,
F2.VisitId,
F2.[PatientId],
F2.SiteID,
F2.SubjectID,
F2.ProviderID,
F2.VisitType,
F2.VisitDate,
F2.PageDescription,
F2.Page4FormStatus,
F2.NoTreatment,
F2.RowID,
F2.Treatment,
F2.TreatmentName,
F2.ChangesToday,
F2.FirstUseDate,
F2.CalcStartDate,
F2.CurrentDose,
F2.CurrentFrequency,
F2.MostRecentDoseNotCurrentDose,
F2.MostRecentPastUseDate

FROM #FF2 F2
WHERE (ISNULL(F2.NoTreatment, '')<>'' OR ISNULL(F2.TreatmentName, '')<>'')

END

GO
