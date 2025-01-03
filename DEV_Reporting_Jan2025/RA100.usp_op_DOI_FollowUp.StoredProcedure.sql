USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_DOI_FollowUp]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- ==========================================================================================
-- Author:		Kaye Mowrey
-- Update date: 3/24/2021 
-- Description:	Procedure for Drugs at FollowUp updated with new Registry Enrollment Status
-- ==========================================================================================


CREATE PROCEDURE [RA100].[usp_op_DOI_FollowUp] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



IF OBJECT_ID('tempdb.dbo.#C') IS NOT NULL BEGIN DROP TABLE #C END;

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
	   END AS TreatmentName
	  ,Q4.[PHF8C_CMCHRIT] AS ChangesToday
	  ,'' AS FirstUseDate
	  ,CAST(NULL AS date) AS CalcStartDate
	  ,'' AS CurrentDose
	  ,'' AS CurrentFrequency

	  ,CAST(Q4.[PHF8C_CMDSTR6] AS nvarchar) AS MostRecentDoseNotCurrentDose
	  ,Q4.[PHF8C_CMMDAT6] AS MostRecentPastUseDate
INTO #C
FROM [OMNICOMM_RA100].[dbo].[PHFQ4] Q4
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=Q4.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ5] Q5 ON Q5.VisitId=Q4.VisitId
--WHERE Q4.[Site Object SiteNo] NOT IN (997, 998, 999)
WHERE (Q4.[PHF8C_CMAPP6]=1 OR ISNULL(Q4.[PHF8C_CMMDAT6], '')<>'' OR ISNULL([PHF8C_CMMDAT7], '')<>'')

-- SELECT * FROM #C ORDER BY SiteID, SubjectID, VisitDate 


IF OBJECT_ID('tempdb.dbo.#D') IS NOT NULL BEGIN DROP TABLE #D END;

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

INTO #D
FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] PHF8B
JOIN [OMNICOMM_RA100].[dbo].[PHFQ4] Q4 ON Q4.VisitId=PHF8B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ5] Q5 ON Q5.VisitId=PHF8B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=PHF8B.VisitId
--WHERE PHF8B.[Site Object SiteNo] NOT IN (997, 998, 999)

--SELECT * FROM #D ORDER BY SiteID, SubjectID, VisitDate


/*
IF OBJECT_ID('tempdb..#E') IS NOT NULL BEGIN DROP TABLE #E END;

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
INTO #E	  
FROM [OMNICOMM_RA100].[dbo].[PHFQ5] Q5
JOIN [OMNICOMM_RA100].[dbo].[PHFQ5_PHF10B] Q5_10B ON Q5.VisitId=Q5_10B.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] Q4 ON Q4.VisitId=Q5.VisitId
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=Q5.VisitId
WHERE Q5.[Site Object SiteNo] NOT IN (997, 998, 999)
AND (ISNULL(Q5_10B.[PHF10B_CMTRT_34], '')<>''  OR ISNULL(Q5.[PHF10A_PHF11NO], '')<>'')

--SELECT * FROM #E ORDER BY SiteID, SubjectID, VisitDate
*/


IF OBJECT_ID('tempdb.dbo.#F') IS NOT NULL BEGIN DROP TABLE #F END;

/************Page 4 - Biologic use combined at Follow-up visits************/
	
CREATE TABLE #F
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
TreatmentName nvarchar(300),
ChangesToday nvarchar(50),
FirstUseDate nvarchar(10),
CalcStartDate date,
CurrentDose nvarchar(100),
CurrentFrequency nvarchar(150),
MostRecentDoseNotCurrentDose nvarchar(100),
MostRecentPastUseDate nvarchar(20),

)


INSERT INTO #F
SELECT * FROM #C
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
	   WHEN Page4FormStatus='No Data' THEN 'No data'
	   ELSE TreatmentName
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
	    
FROM #D
WHERE Page4FormStatus <> 'No Data'
--WHERE (ISNULL(NoTreatment, '')<>'' OR ISNULL(TreatmentName, '')<>'')



IF OBJECT_ID('tempdb.dbo.#VisitOrder') IS NOT NULL BEGIN DROP TABLE #VisitOrder END;


/************Page 4 - Biologics use at Follow-up visits with Visit Order Sequence #************/

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
AND VisitId IN (SELECT VisitId FROM #F)


--SELECT * FROM #VisitOrder WHERE SubjectID=100206321 ORDER BY VisitOrder


IF OBJECT_ID('tempdb.dbo.#ExitVisits') IS NOT NULL BEGIN DROP TABLE #ExitVisits END;

/************Exit Visit Information************/

SELECT DISTINCT *
INTO #ExitVisits
FROM
(
SELECT DISTINCT VisitId
      ,ROW_NUMBER() OVER(PARTITION BY [Site Object SiteNo], [Patient Object PatientNo] ORDER BY [Site Object SiteNo], [Patient Object PatientNo], [Visit Object VisitDate], [VisitID] DESC) AS VisitOrder
      ,CAST([Site Object SiteNo] AS int) AS SiteID
      ,CAST([Patient Object PatientNo] AS bigint) AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate

FROM [OMNICOMM_RA100].[dbo].[VISIT] V
WHERE [Visit Object ProCaption]='Exit'
AND ISNULL([Visit Object VisitDate], '')<>''
AND V.[Visit Object VisitDate] > (SELECT DISTINCT MAX([Visit Object VisitDate]) FROM [OMNICOMM_RA100].[dbo].[VISIT] V2 WHERE V2.[Site Object SiteNo]=V.[Site Object SiteNo] AND V2.[Patient Object PatientNo]= V.[Patient Object PatientNo] AND V2.[Visit Object ProCaption]='Follow-up')
) EXITS
WHERE VisitOrder=1

--SELECT * FROM #ExitVisits EV WHERE SubjectID=27010076 ORDER BY SubjectID, VisitDate 
--SELECT SiteID, SubjectID, VisitDate, COUNT(SUBJECTID) AS Count FROM #ExitVisits GROUP BY SiteID, SubjectID, VisitDate ORDER BY COUNT DESC, SubjectID

IF OBJECT_ID('tempdb.dbo.#F2') IS NOT NULL BEGIN DROP TABLE #F2 END;

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
	   
INTO #F2
FROM #F F
LEFT JOIN #VisitOrder VO ON VO.VisitId=F.VisitId
WHERE F.VisitDate NOT IN (SELECT VisitDate FROM [Reporting].[RA100].[t_op_DOI_Enrollment] Enrollment WHERE Enrollment.SubjectID=F.SubjectID)
AND F.VisitId IN (SELECT VisitId FROM #D) 


--SELECT * FROM #F2 F2 WHERE SubjectID=100206321 ORDER BY SiteID, SubjectID, VisitDate, VisitOrder


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
F2.TreatmentName,
F2.ChangesToday,
F2.FirstUseDate,
F2.CalcStartDate,
F2.CurrentDose,
F2.CurrentFrequency,
F2.MostRecentDoseNotCurrentDose,
F2.MostRecentPastUseDate

FROM #F2 F2
WHERE (ISNULL(F2.NoTreatment, '')<>'' OR ISNULL(F2.TreatmentName, '')<>'')

--SELECT * FROM [Reporting].[RA100].[t_op_FollowUp_Drugs] WHERE SubjectID=100206321 AND VisitOrder=1



/*****Put multiple instances of same FU Treatment at same visit on a single line*****/

IF OBJECT_ID('tempdb.dbo.#MERGED') IS NOT NULL BEGIN DROP TABLE #MERGED END;

SELECT [VisitId]
      ,VisitOrder
      ,[SiteID]
	  ,ProviderID
      ,[SubjectID]
      ,[VisitDate]
	  ,[VisitType]
      ,CASE WHEN MAX(NoTreatment)=1 THEN 'No treatment'
	   ELSE [TreatmentName]
	   END AS TreatmentName
	  ,MAX(NoTreatment) AS NoTreatment
	  ,MAX(Page4FormStatus) AS Page4FormStatus
      ,MAX([ChangesToday]) AS ChangesToday
      ,MAX([CalcStartDate]) AS CalcStartDate
	  ,MAX(FirstUseDate) AS FirstUseDate
      ,MAX([CurrentDose]) AS CurrentDose
      ,MAX([MostRecentDoseNotCurrentDose]) AS MostRecentDoseNotCurrentDose
      ,MAX([MostRecentPastUseDate]) AS MostRecentPastUseDate
INTO #MERGED
FROM
(
  SELECT VisitId
        ,VisitOrder
        ,SiteID
		,ProviderID
		,SubjectID
		,VisitDate
		,VisitType
		,NoTreatment
		--,TreatmentName
		,CASE WHEN SubjectID=74020193 AND TreatmentName LIKE 'Other: Xeljanz%' THEN 'tofacitinib (Xeljanz XR)'
		 ELSE TreatmentName
		 END AS TreatmentName
		,Page4FormStatus
		,ChangesToday
		,CalcStartDate
		,FirstUseDate
		,CurrentDose
		,MostRecentDoseNotCurrentDose
		,MostRecentPastUseDate
  FROM [RA100].[t_op_FollowUp_Drugs]
  WHERE ISNULL(TreatmentName, '')<>'' OR NoTreatment=1

) A
GROUP BY VisitID, VisitOrder, SiteID, ProviderID, SubjectID, VisitDate, VisitType, TreatmentName
ORDER BY SiteID, SubjectID, VisitDate, TreatmentName


--SELECT * FROM #MERGED WHERE SubjectID=6030077 ORDER BY SiteID, SubjectID, VisitDate


/*****Determine Treatment status*****/

IF OBJECT_ID('tempdb.dbo.#FUChg') IS NOT NULL BEGIN DROP TABLE #FUChg END;

SELECT [VisitId]
      ,VisitOrder
      ,[SiteID]
	  ,[ProviderID]
      ,[SubjectID]
      ,[VisitDate]
	  ,[VisitType]
      ,[TreatmentName]
	  ,NoTreatment
	  ,Page4FormStatus
	  ,PastUseDate
	  ,COALESCE(PreviousVisitDate, EnrollDate) AS PreviousVisitDate
	  ,CalcStartDate
	  ,FirstUseDate
	  ,CurrentDose
	  ,MostRecentDoseNotCurrentDose
	  ,CASE WHEN ISNULL(PastUseDate, '')<>'' THEN DATEDIFF(M, PreviousVisitDate, PastUseDate) 
	   ELSE NULL
	   END AS StopMonths
	  ,ChangesToday
	  ,CASE WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(ChangesToday, '') IN ('', 'Stop drug') AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CurrentDose, '')='' AND DATEDIFF(M, PastUseDate, VisitDate)>1 THEN 'Stopped since last visit'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(ChangesToday, '')='' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CalcStartDate, '')<>'' AND PastUseDate < CalcStartDate THEN 'Stopped and re-started drug'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND PastUseDate<VisitDate AND ISNULL(CalcStartDate, '')<>'' THEN 'Stopped and re-started drug'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND PastUseDate<VisitDate AND ChangesToday='Start drug' AND ISNULL(CalcStartDate, '')='' THEN 'Stopped drug since last visit and prescribed at current visit'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND PastUseDate > CalcStartDate THEN 'continued'

	   WHEN ISNULL(ChangesToday, '')<>'' THEN ChangesToday
	   WHEN TreatmentName IN ('Investigational Agent', 'rituximab (Rituxan)') AND ISNULL(ChangesToday, '')='' THEN 'continued'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CalcStartDate, '')<>'' AND ISNULL(CurrentDose, '')<>'' AND DATEADD(D, DAY(VisitDate)-1, CalcStartDate)<=VisitDate AND CalcStartDate>PastUseDate THEN 'Stopped and re-started drug'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CurrentDose, '')='' AND DATEADD(DD, 30, PastUseDate)>=PreviousVisitDate THEN 'Stopped since last visit'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CurrentDose, '')='' AND PastUseDate<PreviousVisitDate THEN 'Stopped since last visit'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CurrentDose, '')<>'' AND ISNULL(CalcStartDate, '')<>'' AND MostRecentDoseNotCurrentDose<>CurrentDose AND CalcStartDate=PastUseDate AND ISNULL(PreviousVisitDate,'')<>'' AND  CalcStartDate>=PreviousVisitDate THEN 'continued'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CalcStartDate, '')<>'' AND ISNULL(CurrentDose, '')<>'' AND CalcStartDate<=PastUseDate AND ISNULL(PreviousVisitDate,'')<>'' AND  DATEADD(D, DAY(PreviousVisitDate), CalcStartDate)>=PreviousVisitDate AND NOT EXISTS (SELECT SubjectID FROM [RA100].[t_op_FollowUp_Drugs] D WHERE D.SiteID=M1.SiteID AND D.SubjectID=M1.SubjectID AND D.VisitDate=M1.PreviousVisitDate AND D.TreatmentName=M1.TreatmentName AND D.ChangesToday='Start drug') THEN 'Started and stopped drug between visits'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(PastUseDate, '')<>'' AND ISNULL(CalcStartDate, '')<>'' AND ISNULL(CurrentDose, '')<>'' AND CalcStartDate<=PastUseDate AND ISNULL(PreviousVisitDate,'')<>'' AND  DATEADD(D, DAY(PreviousVisitDate), CalcStartDate)>=PreviousVisitDate AND EXISTS (SELECT SubjectID FROM [RA100].[t_op_FollowUp_Drugs] D WHERE D.SiteID=M1.SiteID AND D.SubjectID=M1.SubjectID AND D.VisitDate=M1.PreviousVisitDate AND D.TreatmentName=M1.TreatmentName AND D.ChangesToday='Start drug') THEN 'Started and stopped drug'
	   WHEN ISNULL(CalcStartDate, '')<>'' AND ISNULL(PastUseDate, '')='' AND ISNULL(MostRecentDoseNotCurrentDose, '')='' AND DATEADD(D, DAY(VisitDate), CalcStartDate)<VisitDate AND ISNULL(PreviousVisitDate, '')<>'' AND CalcStartDate>=PreviousVisitDate AND ChangesToday<>'Start drug' AND NOT EXISTS (SELECT SubjectID FROM [RA100].[t_op_FollowUp_Drugs] D WHERE D.SiteID=M1.SiteID AND D.SubjectID=M1.SubjectID AND D.VisitDate=PreviousVisitDate AND D.TreatmentName=M1.TreatmentName AND D.ChangesToday='Start drug') THEN 'Started between visits' 
	   WHEN ISNULL(CalcStartDate, '')<>'' AND ISNULL(PastUseDate, '')='' AND ISNULL(MostRecentDoseNotCurrentDose, '')='' AND CalcStartDate<VisitDate AND ISNULL(PreviousVisitDate, '')<>'' AND CalcStartDate>=PreviousVisitDate AND EXISTS (SELECT SubjectID FROM [RA100].[t_op_FollowUp_Drugs] D WHERE D.SiteID=M1.SiteID AND D.SubjectID=M1.SubjectID AND D.VisitDate=PreviousVisitDate AND D.TreatmentName=M1.TreatmentName AND D.ChangesToday='Start drug') THEN 'continued'  
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(CurrentDose, '')='' and ISNULL(MostRecentDoseNotCurrentDose, '')<>'' THEN 'Stopped since last visit'
   	   WHEN ISNULL(CalcStartDate, '')<>'' AND ISNULL(PastUseDate, '')='' AND ISNULL(MostRecentDoseNotCurrentDose, '')='' AND CalcStartDate<VisitDate AND ISNULL(PreviousVisitDate, '')='' THEN 'continued'
	   WHEN TreatmentName<>'rituximab (Rituxan)' AND ISNULL(CurrentDose, '')<>'' and ISNULL(MostRecentDoseNotCurrentDose, '')='' AND ISNULL(ChangesToday, '')='' THEN 'continued'
	   ELSE ChangesToday
	   END AS CalcChangesToday

INTO #FUChg
FROM 
(
SELECT [VisitId]
      ,VisitOrder
      ,[SiteID]
	  ,[ProviderID]
      ,[SubjectID]
      ,[VisitDate]
	  ,[VisitType]
      ,[TreatmentName]
	  ,NoTreatment
	  ,Page4FormStatus
  	  ,MostRecentPastUseDate
	  ,CASE WHEN ISNULL(MostRecentPastUseDate, '')<>'' THEN 
	   CONVERT(VARCHAR, (LEFT(MostRecentPastUseDate, 4) + '-' + RIGHT(MostRecentPastUseDate, 2) + '-01'), 110)
	   ELSE MostRecentPastUseDate
	   END AS PastUseDate
	  ,(SELECT VisitDate FROM [RA100].[t_op_Enrollment_Drugs] E WHERE E.SiteID=M.SiteID AND E.SubjectID=M.SubjectID AND E.ChangesToday='Start drug' AND E.TreatmentName=M.TreatmentName) AS EnrollDate
	  ,(SELECT MAX(VisitDate) FROM [RA100].[t_op_FollowUp_Drugs] B WHERE B.SiteID=M.SiteID AND B.SubjectID=M.SubjectID AND B.VisitDate<M.VisitDate) AS PreviousVisitDate
	   ,ChangesToday
	   ,CalcStartDate
	   ,FORMAT(CalcStartDate, 'MMM-yyyy') AS FirstUseDate
	   ,CurrentDose
	   ,MostRecentDoseNotCurrentDose

FROM #MERGED M
) M1

--SELECT * FROM #FUChg WHERE SubjectID=6080047 ORDER BY SiteID, SubjectID, VisitDate


IF OBJECT_ID('tempdb.dbo.#G') IS NOT NULL BEGIN DROP TABLE #G END;

/************Enrollment starter listing where DOIInitiationStatus='prescribed at visit'************/

SELECT DISTINCT Enrollment.SiteID
	  ,Enrollment.SiteStatus
	  ,Enrollment.SubjectID
	  ,Enrollment.VisitType
	  ,Enrollment.ProviderID
	  ,Enrollment.YearofBirth
	  ,Enrollment.Age
	  ,Enrollment.VisitDate
	  ,Enrollment.OnsetYear
	  ,Enrollment.JuvenileRA
	  ,Enrollment.YearsSinceOnset
	  ,Enrollment.EligibilityVersion
	  ,Enrollment.PageDescription
	  ,Enrollment.Page4FormStatus
	  ,Enrollment.Page5FormStatus
	  ,Enrollment.NoTreatment
	  ,Enrollment.TreatmentName
	  ,Enrollment.ChangesToday
	  ,Enrollment.FirstUseDate
	  ,Enrollment.StartDate
	  ,Enrollment.MonthsSinceStartToVisit
	  ,Enrollment.CurrentDose
	  ,Enrollment.CurrentFrequency
	  ,Enrollment.MostRecentDoseNotCurrentDose
	  ,Enrollment.MostRecentPastUseDate
	  ,Enrollment.DrugOfInterest
	  ,Enrollment.DrugHierarchy
	  ,Enrollment.DOIInitiationStatus
	  ,Enrollment.AdditionalDOI
	  ,Enrollment.SubscriberDOI
	  ,Enrollment.TwelveMonthInitiationRule
	  ,Enrollment.PriorJAKiUse
	  ,Enrollment.FirstTimeUse
	  ,Enrollment.RegistryEnrollmentStatus

INTO #G
FROM [Reporting].[RA100].[t_op_DOI_Enrollment] Enrollment
WHERE Enrollment.ROWNUM=1 
AND Enrollment.DOIInitiationStatus='prescribed at visit'

--SELECT * FROM #G G WHERE SubjectID=100206321 VisitDate >= '2022-01-01' ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb.dbo.#H') IS NOT NULL BEGIN DROP TABLE #H END;

/*** Current Drugs at First FU ***/

SELECT DISTINCT VisitOrder
      ,VisitId
      ,SubjectID
	  ,STUFF((
        SELECT ', '+ TreatmentName 
        FROM #F2 FF
		WHERE FF.VisitId=F2.VisitId
		AND ISNULL(FF.CurrentDose, '')<>''
		---AND E.VisitOrder=1
		---AND E.TreatmentName<>G.DrugOfInterest
        FOR XML PATH('')
        )
        ,1,1,'') AS CurrentTreatment
INTO #H
FROM #F2 F2
WHERE VisitOrder=1

--SELECT * FROM #F2 WHERE SubjectID=100206321
--SELECT * FROM #H WHERE SubjectID=100206321


IF OBJECT_ID('tempdb.dbo.#I1') IS NOT NULL BEGIN DROP TABLE #I1 END;

/***********Follow Up DOIInitiationStatus='prescribed at visit'************/
SELECT *,
        ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, NextVisitDrugHierarchy, FUTreatmentName) AS DrugOrder
INTO #I1
FROM
(
SELECT DISTINCT Enroll.SiteID
	  ,Enroll.SiteStatus
	  ,Enroll.SubjectID
	  ,Enroll.VisitType
	  ,Enroll.ProviderID
	  ,Enroll.YearofBirth
	  ,Enroll.Age
	  ,Enroll.VisitDate
	  ,Enroll.OnsetYear
	  ,Enroll.JuvenileRA
	  ,Enroll.YearsSinceOnset
	  ,Enroll.EligibilityVersion
	  ,Enroll.PageDescription
	  ,Enroll.Page4FormStatus
	  ,Enroll.Page5FormStatus
	  ,Enroll.NoTreatment
	  ,Enroll.TreatmentName
	  ,Enroll.ChangesToday
	  ,Enroll.FirstUseDate

      ,CASE WHEN F2.TreatmentName<>Enroll.DrugOfInterest THEN FORMAT(Enroll.VisitDate, 'MMM-yyyy')
	   WHEN ISNULL(F2.TreatmentName, '')<>'' AND F2.TreatmentName=Enroll.DrugOfInterest AND ISNULL(F2.PastUseDate, '')<>'' AND (F2.PastUseDate <= F2.CalcStartDate OR F2.CalcChangesToday=
	  'Stopped and re-started drug') THEN FORMAT(Enroll.VisitDate, 'MMM-yyyy') 
	   WHEN ISNULL(F2.TreatmentName, '')<>'' AND ISNULL(F2.CalcStartDate, '')<>'' AND ISNULL(F2.PastUseDate, '')='' THEN FORMAT(F2.CalcStartDate, 'MMM-yyyy')
	   WHEN F2.TreatmentName<>'rituximab (Rituxan)' AND ISNULL(F2.PastUseDate, '')<>'' AND ISNULL(F2.CalcStartDate, '')<>'' AND F2.PastUseDate > F2.CalcStartDate THEN FORMAT(CalcStartDate, 'MMM-yyyy')
	   WHEN ISNULL(F2.TreatmentName, '')='' AND (NOT EXISTS (SELECT SubjectID from #F2 F3 WHERE F3.SubjectID=Enroll.SubjectID) AND EXISTS (SELECT SubjectID FROM #ExitVisits EV WHERE EV.SubjectID=Enroll.SubjectID)) THEN (SELECT DISTINCT MAX( FORMAT(VisitDate, 'MMM-yyyy')) FROM #ExitVisits EV WHERE EV.SubjectID=Enroll.SubjectID)
	   WHEN ISNULL(F2.TreatmentName, '')<>ISNULL(Enroll.DrugOfInterest, '') AND EXISTS (SELECT SubjectID from #F2 F3 WHERE F3.SubjectID=Enroll.SubjectID ) THEN Enroll.StartDate
	   WHEN NOT EXISTS (SELECT SubjectID from #F2 F3 WHERE F3.SubjectID=Enroll.SubjectID) AND NOT EXISTS (SELECT SubjectID FROM #ExitVisits EV WHERE EV.SubjectID=Enroll.SubjectID) THEN Enroll.StartDate
	   WHEN ISNULL(F2.CalcStartDate, '')='' THEN Enroll.StartDate
	   ELSE NULL
	   END AS FUStartDate

	  ,Enroll.MonthsSinceStartToVisit
	  ,Enroll.CurrentDose
	  ,Enroll.CurrentFrequency
	  ,Enroll.MostRecentDoseNotCurrentDose
	  ,Enroll.MostRecentPastUseDate
	  ,Enroll.DrugOfInterest
	  ,F2.VisitOrder
	  ,F2.Page4FormStatus AS FUPage4FormStatus
	  ,F2.NoTreatment AS FUNoTreatment
	  ,F2.TreatmentName AS FUTreatmentName
	  ,CASE WHEN Enroll.DrugOfInterest=F2.TreatmentName THEN F2.TreatmentName
	   WHEN F2.NoTreatment=1 THEN 'no match'
	   WHEN Enroll.DrugOfInterest<>F2.TreatmentName THEN 'no match'
	   ELSE ''
	   END AS DOIFUMatch
	 ,CASE WHEN Enroll.DrugOfInterest=F2.TreatmentName THEN 10
	  WHEN F2.NoTreatment=1 THEN 20
	  WHEN Enroll.DrugOfInterest<>F2.TreatmentName AND F2.CurrentDose<>'' THEN 30
	  WHEN Enroll.DrugOfInterest<>F2.TreatmentName AND F2.TreatmentName='rituximab (Rituxan)' AND ISNULL(F2.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(F2.PastUseDate, '')<>'' THEN 40
	  WHEN Enroll.DrugOfInterest<>F2.TreatmentName AND F2.TreatmentName<>'rituximab (Rituxan)' AND ISNULL(F2.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(F2.PastUseDate, '')<>'' THEN 50
	  WHEN Enroll.DrugOfInterest<>F2.TreatmentName AND F2.TreatmentName='rituximab (Rituxan)' AND F2.ChangesToday='Start drug' THEN 60
	  WHEN Enroll.DrugOfInterest<>F2.TreatmentName AND F2.MostRecentDoseNotCurrentDose<>'' OR ISNULL(F2.PastUseDate, '')<>'' THEN 40
	  WHEN ISNULL(F2.TreatmentName, '')='' AND ISNULL(F2.NoTreatment, '')='' THEN 80
	  ELSE 90
	  END AS NextVisitDrugHierarchy
	  ,F2.VisitDate AS FUVisitDate
	  ,CASE WHEN Enroll.DrugOfInterest=F2.TreatmentName THEN 'match at next visit'
	   --WHEN UPPER(Enroll.DrugOfInterest) LIKE '%XELJ%' and UPPER(F2.TreatmentName) LIKE '%XELJ%' THEN 'match at next visit'
	   WHEN Enroll.DrugOfInterest<>F2.TreatmentName AND ISNULL(F2.TreatmentName, '')<>'' THEN 'no match at next visit'
	   WHEN ISNULL(F2.VisitOrder, '')='' THEN 'no next visit'
	   WHEN F2.Page4FormStatus='no data' THEN 'no data'
	   WHEN F2.NoTreatment=1 AND ISNULL(F2.TreatmentName, '')='' THEN 'no match at next visit'
	   ELSE ''
	   END AS NextVisitStatus
	  ,(SELECT DISTINCT MAX(VisitDate) FROM #ExitVisits EX WHERE EX.SubjectID=Enroll.SubjectID) AS ExitDate
	  ,F2.ChangesToday AS DOIFUChangesToday
	  ,F2.CalcChangesToday AS DOIFUCalcChangesToday
	  ,F2.FirstUseDate AS DOIFUFirstUseDate
	  ,F2.CalcStartDate AS DOIFUStartDate
	  ,F2.CurrentDose AS DOIFUCurrentDose
	  ,F2.PastUseDate AS DOIFUMostRecentPastUseDate
	  ,F2.MostRecentDoseNotCurrentDose AS DOIFUMostRecentDoseNotCurrentDose
	  ,Enroll.DrugHierarchy
	  ,Enroll.DOIInitiationStatus
	  ,Enroll.AdditionalDOI
	  ,Enroll.SubscriberDOI
	  ,Enroll.TwelveMonthInitiationRule
	  ,Enroll.PriorJAKiUse
	  ,Enroll.FirstTimeUse
	  ,Enroll.RegistryEnrollmentStatus

FROM #G Enroll
LEFT JOIN #FUChg F2 ON F2.SiteID=Enroll.SiteID AND F2.SubjectID=Enroll.SubjectID AND F2.VisitOrder=1
) EFU

--SELECT * FROM #I1 WHERE SubjectID=100206321

IF OBJECT_ID('tempdb..#I') IS NOT NULL BEGIN DROP TABLE #I END;

/***First Follow Up After Enrollment Where Enrollment DOIInitiationStatus='prescribed at visit'***/

SELECT DISTINCT SiteID
      ,SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,ProviderID
	  ,YearofBirth
	  ,Age
	  ,VisitDate
	  ,OnsetYear
	  ,JuvenileRA
	  ,YearsSinceOnset
	  ,EligibilityVersion
	  ,PageDescription
	  ,Page4FormStatus
	  ,Page5FormStatus
	  ,NoTreatment
	  ,TreatmentName
	  ,ChangesToday
	  ,FirstUseDate
	  ,FUStartDate
	  ,MonthsSinceStartToVisit
	  ,CurrentDose
	  ,CurrentFrequency
	  ,MostRecentDoseNotCurrentDose
	  ,MostRecentPastUseDate
	  ,DrugOfInterest
	  ,VisitOrder
	  ,FUPage4FormStatus
	  ,FUNoTreatment
	  ,FUTreatmentName
	  ,DOIFUMatch
	  ,FUVisitDate
	  ,NextVisitStatus
	  ,ExitDate
	  ,DOIFUChangesToday
	  ,DOIFUCalcChangesToday
	  ,DOIFUFirstUseDate
	  ,DOIFUStartDate
	  ,DOIFUCurrentDose
	  ,DOIFUMostRecentPastUseDate
	  ,DOIFUMostRecentDoseNotCurrentDose
	  ,DrugHierarchy
	  ,DOIInitiationStatus
	  ,AdditionalDOI
	  ,SubscriberDOI
	  ,TwelveMonthInitiationRule
	  ,PriorJAKiUse
	  ,FirstTimeUse
	  ,RegistryEnrollmentStatus

INTO #I
FROM #I1 I1
WHERE I1.DrugOrder=1

/***Note that 'Other: ' drugs do not always pull in as matching - i.e. Subject 35060607 which has 'Other: actemra sq' at Enrollment and ' Other: actemra' at FU****/

---SELECT * FROM #I WHERE SubjectID=100206321 ORDER BY SiteID, SubjectID, VisitDate 



/******ENROLLMENT AND FIRST FOLLOW-UP TABLE******/

/*
CREATE TABLE [RA100].[t_op_DOI_Enroll_FirstFU](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](30) NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [nvarchar](30) NULL,
	[ProviderID] [varchar](10) NULL,
	[YearofBirth] [int] NULL,
	[VisitDate] [date] NULL,
	[OnsetYear] [int] NULL,
	[EligibilityVersion] [int] NULL,
	[DrugOfInterest] [nvarchar](300) NULL,
	[ChangesToday] [nvarchar](50) NULL,
	[FirstUseDate] [nvarchar](20) NULL,
	[StartDate] [nvarchar](10) NULL,
	[DOIInitiationStatus] [varchar](150) NULL,
	[AdditionalDOI] [varchar](1000) NULL,
	[SubscriberDOI] [varchar](10) NULL,
	[TwelveMonthInitiationRule] [varchar](25) NULL,
	[PriorJAKiUse] [varchar](10) NULL,
	[FirstTimeUse] [varchar](30) NULL,
	[RegistryEnrollmentStatus] [varchar](300) NULL,
	[ConfirmationVisitDate] [date] NULL,
	[InitiationStatus] [nvarchar](200) NULL,
	[SubscriberDOIAccrual] [nvarchar](200) NULL,
	[CsdmardCount] [int] NULL
) ON [PRIMARY]
GO
*/



/*
IF OBJECT_ID('tempdb..#CsdmardCount') IS NOT NULL BEGIN DROP TABLE #CsdmardCount END;

/***Get running count of csDMARDs - from Jan 1, 2022 to Mar 18, 2022***/

SELECT ROW_NUMBER() OVER(PARTITION BY VisitType ORDER BY SiteID, SubjectID, VisitDate) AS CsdmardCount,
       VisitId,
       PatientId,
	   SiteID, 
	   SubjectID,
	   VisitType,
	   VisitDate,
	   OnsetYear,
	   DrugOfInterest
INTO #CsdmardCount
FROM [Reporting].[RA100].[t_op_DOI_Enrollment] 
WHERE ROWNUM=1 AND PageDescription LIKE '(Page 5)%' AND VisitDate >= '2022-01-01' AND  VisitDate < '2022-03-18' AND RegistryEnrollmentStatus='Eligible' AND DrugOfInterest='cDMARD' 

--select count(*) from #CsdmardCount
*/


TRUNCATE  TABLE [Reporting].[RA100].[t_op_DOI_Enroll_FirstFU];


INSERT INTO [Reporting].[RA100].[t_op_DOI_Enroll_FirstFU]
(
SiteID,
SiteStatus,
SubjectID, 
VisitType,
ProviderID,
YearofBirth,
VisitDate,
OnsetYear,
EligibilityVersion,
DrugOfInterest,
ChangesToday,
FirstUseDate,
StartDate,
DOIInitiationStatus, 
AdditionalDOI,
SubscriberDOI, 
TwelveMonthInitiationRule, 
PriorJAKiUse,
FirstTimeUse ,
RegistryEnrollmentStatus,
InitiationStatus,
ConfirmationVisitDate,
SubscriberDOIAccrual, 
CsdmardCount
)


(
SELECT DISTINCT I.SiteID,
I.SiteStatus,
I.SubjectID, 
I.VisitType,
I.ProviderID,
I.YearofBirth,
I.VisitDate,
I.OnsetYear,
I.EligibilityVersion,
I.DrugOfInterest,
I.ChangesToday,
I.FirstUseDate,
I.FUStartDate,
I.DOIInitiationStatus, 
I.AdditionalDOI,
I.SubscriberDOI, 
I.TwelveMonthInitiationRule, 
I.PriorJAKiUse,
I.FirstTimeUse,
I.RegistryEnrollmentStatus,
CASE WHEN I.DrugOfInterest='Investigational Agent' THEN ''
     WHEN NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')='' THEN 'pending'
     WHEN NextVisitStatus='no match at next visit' THEN 'drug not started'
	 WHEN NextVisitStatus='match at next visit' AND (DOIFUChangesToday='Stop drug' OR ISNULL(DOIFUMostRecentPastUseDate, '')<>'') THEN 'drug stopped'
	WHEN NextVisitStatus='match at next visit' AND FUTreatmentName<>'rituximab (Rituxan)' AND DOIFUChangesToday='' AND ISNULL(DOIFUMostRecentDoseNotCurrentDose, '')<>'' THEN 'drug stopped'
     WHEN NextVisitStatus='match at next visit' AND DOIFUChangesToday='Start drug' AND ISNULL(DOIFUFirstUseDate, '')='' AND ISNULL(DOIFUCurrentDose, '')='' AND ISNULL(DOIFUMostRecentDoseNotCurrentDose, '')='' THEN 'unknown-start'
	 WHEN NextVisitStatus='match at next visit' AND DOIFUChangesToday='Change dose' OR ISNULL(FUStartDate, '')<>'' OR DOIFUCalcChangesToday='continued' THEN 'confirmed'
     WHEN NextVisitStatus='match at next visit' AND I.DrugOfInterest<>'Investigational Agent' AND DOIFUChangesToday NOT IN ('Start drug', 'Stop drug') AND DOIFUCalcChangesToday NOT IN ('Stopped since last visit', 'Stop drug') AND ISNULL(DOIFUMostRecentPastUseDate, '')='' THEN 'confirmed'
     WHEN NextVisitStatus='match at next visit' AND ISNULL(DOIFUCurrentDose, '')<>'' THEN 'confirmed'
     WHEN NextVisitStatus='match at next visit' AND FUTreatmentName='rituximab (Rituxan)' AND DOIFUChangesToday<>'Stop drug' THEN 'confirmed'
     WHEN NextVisitStatus='match at next visit' AND ISNULL(ChangesToday, '')='' AND ISNULL(DOIFUFirstUseDate, '')='' AND ISNULL(DOIFUCurrentDose, '')='' AND ISNULL(DOIFUMostRecentDoseNotCurrentDose, '')='' THEN 'unknown-start'
	WHEN NextVisitStatus='match at next visit' AND DOIFUChangesToday='Start drug' AND DOIFUCalcChangesToday='Start drug' THEN 'drug not started'
	WHEN NextVisitStatus='match at next visit' AND DOIFUChangesToday='Start drug' AND DOIFUCalcChangesToday='Stopped since last visit and new start at current visit' THEN 'confirmed - stopped started again at current visit'
	WHEN NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')<>'' THEN 'unknown-exited'
	WHEN NextVisitStatus='no data' AND ISNULL(ExitDate, '')<>'' AND ExitDate>=I.VisitDate THEN 'unknown-exited'
	WHEN NextVisitStatus='no data' AND ISNULL(ExitDate, '')='' THEN 'no data'
	ELSE ''
END AS InitiationStatus,
CASE WHEN I.DrugOfInterest='Investigational Agent' THEN ''
     WHEN NextVisitStatus='match at next visit' THEN CONVERT(varchar(10), FUVisitDate, 23)
	 WHEN NextVisitStatus='no next visit' THEN NULL
	 WHEN NextVisitStatus='no match at next visit' THEN CONVERT(varchar(10), FUVisitDate, 23)
	 WHEN NextVisitStatus='no data' THEN CONVERT(varchar(10), FUVisitDate, 23)
	 ELSE ''
END AS ConfirmationVisitDate,
CASE WHEN I.DrugOfInterest='Investigational Agent' THEN ''
     WHEN I.DrugOfInterest<>'baricitinib (Olumiant)' THEN '-'
     WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='yes' THEN 'no'
	 WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND TwelveMonthInitiationRule='not met' AND DOIInitiationStatus='continued' THEN 'no'
	 WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='continued' AND TwelveMonthInitiationRule='met' AND NextVisitStatus='match at next visit' AND (DOIFUChangesToday='Change dose' OR ISNULL(DOIFUCurrentDose, '')<>'') THEN 'yes'
     WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='continued' AND
	   TwelveMonthInitiationRule='met' AND NextVisitStatus='no match at next visit' THEN 'no (revoked)'
     WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='continued' AND TwelveMonthInitiationRule='met' AND NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')<>'' THEN 'yes'
	 WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='continued' AND TwelveMonthInitiationRule='met' AND NextVisitStatus='match at next visit' AND DOIFUChangesToday='Stop drug' THEN 'no (revoked)'
	 WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='prescribed at visit' AND 
	 	 NextVisitStatus='match at next visit' AND DOIFUChangesToday='Change dose' THEN 'yes'
     WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='prescribed at visit' AND 
	    NextVisitStatus='match at next visit' AND ISNULL(DOIFUCurrentDose, '')<>'' THEN 'yes'
     WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND  DOIInitiationStatus='prescribed at visit' 
           AND NextVisitStatus='no match at next visit' THEN 'no (revoked)'
	 WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND  DOIInitiationStatus='prescribed at visit' 
	       AND NextVisitStatus='no next visit' AND ISNULL(ExitDate, '')<>'' THEN 'no (revoked)'
	 WHEN I.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND  DOIInitiationStatus='prescribed at visit' 
	       AND NextVisitStatus='match at next visit' AND (DOIFUChangesToday='Stop drug' OR ISNULL(DOIFUMostRecentPastUseDate, '')<>'') THEN 'yes'
	 ELSE ''
	 END AS SubscriberDOIAccrual,
	 CAST(NULL AS int) AS CsdmardCount
FROM #I I
--LEFT JOIN #CsdmardCount CC ON CC.SiteID=I.SiteID AND CC.SubjectID=I.SubjectID

UNION

SELECT DISTINCT Enrollment.SiteID,
SiteStatus,
Enrollment.SubjectID, 
Enrollment.VisitType,
ProviderID,
YearofBirth,
Enrollment.VisitDate,
Enrollment.OnsetYear,
EligibilityVersion,
Enrollment.DrugOfInterest,
ChangesToday,
FirstUseDate,
StartDate,
DOIInitiationStatus, 
AdditionalDOI,
SubscriberDOI, 
TwelveMonthInitiationRule, 
PriorJAKiUse,
FirstTimeUse,
RegistryEnrollmentStatus,
NULL AS ConfirmationVisitDate,
'' AS InitiationStatus,
CASE WHEN Enrollment.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND DOIInitiationStatus='prescribed at visit' THEN 'yes'
WHEN Enrollment.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='no' AND TwelveMonthInitiationRule='met' THEN 'yes'
WHEN Enrollment.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='yes' AND TwelveMonthInitiationRule='met' THEN 'no'
WHEN Enrollment.DrugOfInterest='baricitinib (Olumiant)' AND PriorJAKiUse='yes' AND TwelveMonthInitiationRule='not met' THEN 'no'
ELSE '-'
END AS SubscriberDOIAccrual,
	 CAST(NULL AS int) AS CsdmardCount

FROM [Reporting].[RA100].[t_op_DOI_Enrollment] Enrollment
--LEFT JOIN #CsdmardCount CC ON CC.VisitId=Enrollment.VisitId
WHERE Enrollment.ROWNUM=1 
AND Enrollment.DOIInitiationStatus<>'prescribed at visit'
)

--SELECT * FROM [Reporting].[RA100].[t_op_DOI_Enroll_FirstFU] W




END

GO
